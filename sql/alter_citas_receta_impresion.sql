-- FarmaCapital: cola de impresión de recetas (consultorio → caja planta baja)
-- Ejecutar en Supabase SQL Editor tras deploy del FE.

ALTER TABLE public.citas
  ADD COLUMN IF NOT EXISTS receta_impresion jsonb;

COMMENT ON COLUMN public.citas.receta_impresion IS
  'Cola impresión receta: { estado: pendiente|impresa|cancelada, solicitada_at, impresa_at, folio, medico_id, medico_nombre, medico_especialidad, medico_cedula, firma_modo, firma_data_url?, diagnostico_snapshot?, medicamentos_snapshot? }';

CREATE OR REPLACE FUNCTION public.empleado_solicitar_impresion_receta(
  p_session_token uuid,
  p_cita_id       bigint,
  p_payload       jsonb DEFAULT '{}'::jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_dummy bigint;
  v_meta  jsonb;
  v_folio text;
BEGIN
  v_dummy := public.fn_require_empleado(p_session_token);

  IF p_cita_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cita requerida');
  END IF;

  v_folio := coalesce(nullif(trim(p_payload->>'folio'), ''), 'RX-' || p_cita_id::text);

  v_meta := jsonb_build_object(
    'estado', 'pendiente',
    'solicitada_at', to_jsonb(now()),
    'impresa_at', null,
    'folio', v_folio,
    'medico_id', p_payload->'medico_id',
    'medico_nombre', coalesce(p_payload->>'medico_nombre', ''),
    'medico_especialidad', coalesce(p_payload->>'medico_especialidad', ''),
    'medico_cedula', coalesce(p_payload->>'medico_cedula', ''),
    'firma_modo', CASE WHEN p_payload->>'firma_modo' = 'digital' THEN 'digital' ELSE 'fisica' END,
    'firma_data_url', CASE
      WHEN p_payload->>'firma_modo' = 'digital' AND coalesce(p_payload->>'firma_data_url', '') <> ''
        THEN p_payload->>'firma_data_url'
      ELSE null
    END,
    'diagnostico_snapshot', coalesce(p_payload->>'diagnostico', ''),
    'notas_snapshot', coalesce(p_payload->>'notas', ''),
    'medicamentos_snapshot', CASE
      WHEN jsonb_typeof(p_payload->'medicamentos') = 'array' THEN p_payload->'medicamentos'
      ELSE '[]'::jsonb
    END
  );

  UPDATE public.citas
     SET receta_impresion = v_meta,
         medico_id = CASE
           WHEN (p_payload->>'medico_id') ~ '^[0-9]+$' THEN (p_payload->>'medico_id')::bigint
           ELSE medico_id
         END,
         diagnostico = CASE
           WHEN coalesce(nullif(trim(p_payload->>'diagnostico'), ''), '') <> '' THEN trim(p_payload->>'diagnostico')
           ELSE diagnostico
         END,
         notas_medico = CASE
           WHEN p_payload ? 'notas' THEN nullif(trim(p_payload->>'notas'), '')
           ELSE notas_medico
         END,
         medicamentos_prescritos = CASE
           WHEN jsonb_typeof(p_payload->'medicamentos') = 'array'
                AND jsonb_array_length(p_payload->'medicamentos') > 0
             THEN p_payload->'medicamentos'
           ELSE medicamentos_prescritos
         END
   WHERE id = p_cita_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cita no encontrada');
  END IF;

  RETURN jsonb_build_object('success', true, 'folio', v_folio, 'receta_impresion', v_meta);
END;
$$;

CREATE OR REPLACE FUNCTION public.empleado_marcar_receta_impresa(
  p_session_token uuid,
  p_cita_id       bigint
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_dummy bigint;
  v_prev  jsonb;
BEGIN
  v_dummy := public.fn_require_empleado(p_session_token);

  IF p_cita_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cita requerida');
  END IF;

  SELECT receta_impresion INTO v_prev FROM public.citas WHERE id = p_cita_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cita no encontrada');
  END IF;

  UPDATE public.citas
     SET receta_impresion = coalesce(v_prev, '{}'::jsonb)
       || jsonb_build_object('estado', 'impresa', 'impresa_at', to_jsonb(now()))
   WHERE id = p_cita_id;

  RETURN jsonb_build_object('success', true);
END;
$$;

CREATE OR REPLACE FUNCTION public.empleado_listar_recetas_por_imprimir(
  p_session_token uuid,
  p_desde date DEFAULT (CURRENT_DATE - 2),
  p_hasta date DEFAULT (CURRENT_DATE + 1)
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_dummy bigint;
BEGIN
  v_dummy := public.fn_require_empleado(p_session_token);

  RETURN coalesce((
    SELECT jsonb_agg(to_jsonb(t) ORDER BY t.solicitada_at DESC NULLS LAST)
    FROM (
      SELECT
        c.id,
        c.nombre,
        c.telefono,
        c.fecha,
        c.hora,
        c.motivo,
        c.estado,
        c.pago_estado,
        c.diagnostico,
        c.notas_medico,
        c.medicamentos_prescritos,
        c.receta_impresion,
        (c.receta_impresion->>'solicitada_at') AS solicitada_at
      FROM public.citas c
      WHERE c.fecha BETWEEN coalesce(p_desde, CURRENT_DATE - 2) AND coalesce(p_hasta, CURRENT_DATE + 1)
        AND coalesce(c.receta_impresion->>'estado', '') = 'pendiente'
        AND (c.estado)::text NOT IN ('cancelada', 'no_asistio')
      ORDER BY (c.receta_impresion->>'solicitada_at') DESC NULLS LAST
      LIMIT 40
    ) t
  ), '[]'::jsonb);
END;
$$;

GRANT EXECUTE ON FUNCTION public.empleado_solicitar_impresion_receta(uuid, bigint, jsonb) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.empleado_marcar_receta_impresa(uuid, bigint) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.empleado_listar_recetas_por_imprimir(uuid, date, date) TO anon, authenticated;
