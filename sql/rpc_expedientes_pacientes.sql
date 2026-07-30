-- Expedientes clínicos: listado de pacientes y citas por teléfono (vía RPC + sesión empleado).
-- Ejecutar en Supabase si Expedientes aparece vacío en admin.

begin;

create or replace function public.empleado_listar_pacientes_expedientes(
  p_session_token uuid,
  p_limite        int default 500
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_lim   int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_lim := greatest(1, least(coalesce(p_limite, 500), 2000));

  return coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'telefono', g.telefono,
        'nombre', g.nombre,
        'primera', g.primera,
        'ultima', g.ultima,
        'n', g.n,
        'n_completadas', g.n_completadas
      )
      order by g.ultima desc nulls last
    )
    from (
      select
        trim(c.telefono) as telefono,
        coalesce(
          max(nullif(trim(c.nombre), '')) filter (where c.fecha = sub.ultima),
          max(nullif(trim(c.nombre), ''))
        ) as nombre,
        min(c.fecha) as primera,
        max(c.fecha) as ultima,
        count(*)::int as n,
        count(*) filter (
          where (c.estado)::text in ('completada', 'en_consulta')
             or coalesce(trim(c.diagnostico), '') <> ''
             or c.consulta_fin_at is not null
        )::int as n_completadas
      from public.citas c
      inner join (
        select trim(telefono) as telefono, max(fecha) as ultima
        from public.citas
        where trim(coalesce(telefono, '')) <> ''
          and (estado)::text <> 'cancelada'
        group by trim(telefono)
      ) sub on trim(c.telefono) = sub.telefono
      where trim(coalesce(c.telefono, '')) <> ''
        and (c.estado)::text <> 'cancelada'
      group by trim(c.telefono), sub.ultima
      having count(*) filter (
        where (c.estado)::text in ('completada', 'en_consulta')
           or coalesce(trim(c.diagnostico), '') <> ''
           or c.consulta_fin_at is not null
      ) > 0
      order by max(c.fecha) desc nulls last
      limit v_lim
    ) g
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_listar_citas_expediente_paciente(
  p_session_token uuid,
  p_telefono      text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_tel   text;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_tel := trim(coalesce(p_telefono, ''));
  if v_tel = '' then
    return '[]'::jsonb;
  end if;

  return coalesce((
    select jsonb_agg(row_js order by fecha_ord desc, hora_ord desc nulls last)
    from (
      select
        jsonb_build_object(
          'id', c.id,
          'nombre', c.nombre,
          'telefono', c.telefono,
          'fecha', c.fecha,
          'hora', c.hora,
          'motivo', c.motivo,
          'estado', c.estado,
          'pago_estado', c.pago_estado,
          'diagnostico', c.diagnostico,
          'notas_medico', c.notas_medico,
          'medicamentos_prescritos', c.medicamentos_prescritos,
          'signos_vitales', c.signos_vitales,
          'expediente_json', c.expediente_json,
          'procedimientos_realizados', c.procedimientos_realizados,
          'duracion_consulta_segundos', c.duracion_consulta_segundos,
          'confirmada_inicio_at', c.confirmada_inicio_at,
          'consulta_fin_at', c.consulta_fin_at,
          'ingreso_doctor', c.ingreso_doctor,
          'precio_consulta_cobrado', c.precio_consulta_cobrado,
          'consumibles_consulta', coalesce(cc.js, '[]'::jsonb)
        ) as row_js,
        c.fecha as fecha_ord,
        c.hora as hora_ord
      from public.citas c
      left join lateral (
        select jsonb_agg(
          jsonb_build_object(
            'id', x.id,
            'cantidad', x.cantidad,
            'precio', x.precio,
            'cobrado', x.cobrado,
            'nombre', x.nombre,
            'producto_id', x.producto_id
          )
          order by x.id
        ) as js
        from public.consumibles_consulta x
        where x.cita_id = c.id
      ) cc on true
      where trim(coalesce(c.telefono, '')) = v_tel
        and (c.estado)::text <> 'cancelada'
    ) q
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_pacientes_expedientes(uuid, int) to anon, authenticated;
grant execute on function public.empleado_listar_citas_expediente_paciente(uuid, text) to anon, authenticated;

commit;
