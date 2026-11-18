-- Corrige CFE de la Sra. Yola (9-oct-2026): se tecleó $67 del recibo
-- (confundieron el +$8 del botón) y con recargo $10 quedó $77.
-- Correcto: recibo $65 + recargo $10 = $75. Compensación MP 1% = $0.65.
--
-- Folio: SRV-20261009-000153
-- Point ya cobró $77 en terminal; este parche solo alinea el registro
-- (corte / flujo / Mi Día). El reembolso de $2 en MP, si aplica, es aparte.
--
-- Idempotente: si ya está en $65 + $10 = $75, no reescribe.
-- Ejecutar en Supabase SQL Editor.

begin;

do $$
declare
  v_ps   public.pagos_servicio%rowtype;
  v_nota text := 'Corregido 9-oct: recibo $65 + recargo $10 = $75 (antes $67+$10=$77; Sra. Yola)';
begin
  select * into v_ps
  from public.pagos_servicio
  where folio = 'SRV-20261009-000153'
  limit 1;

  if v_ps.id is null then
    raise exception 'No existe el folio SRV-20261009-000153.';
  end if;

  if upper(btrim(coalesce(v_ps.proveedor, ''))) <> 'CFE' then
    raise exception 'El folio % no es CFE (proveedor=%). No se tocó.',
      v_ps.folio, v_ps.proveedor;
  end if;

  -- Ya corregido
  if round(v_ps.monto_servicio, 2) = 65
     and round(v_ps.comision, 2) = 10
     and round(v_ps.total_cobrado, 2) = 75 then
    raise notice 'Ya está corregido: % · servicio % · recargo % · total % · MP %',
      v_ps.folio, v_ps.monto_servicio, v_ps.comision, v_ps.total_cobrado, v_ps.compensacion_mp;
    return;
  end if;

  if not (
    round(v_ps.monto_servicio, 2) = 67
    and round(v_ps.comision, 2) = 10
    and round(v_ps.total_cobrado, 2) = 77
  ) then
    raise exception
      'El folio % no tiene el monto esperado ($67+$10=$77). Actual: servicio=% recargo=% total=%. No se tocó.',
      v_ps.folio, v_ps.monto_servicio, v_ps.comision, v_ps.total_cobrado;
  end if;

  update public.pagos_servicio
  set monto_servicio = 65,
      comision = 10,
      total_cobrado = 75,
      compensacion_mp = 0.65,
      costo_liquidacion = 65,
      notas = case
        when coalesce(notas, '') ilike '%Corregido 9-oct%' then notas
        when coalesce(btrim(notas), '') = '' then v_nota
        else notas || ' · ' || v_nota
      end
  where id = v_ps.id
    and round(monto_servicio, 2) = 67
    and round(comision, 2) = 10
    and round(total_cobrado, 2) = 77;

  if not found then
    raise exception 'No se pudo corregir %', v_ps.folio;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      null,
      'sql_patch',
      'corregir_pago_servicio',
      'pagos_servicio',
      v_ps.id::text,
      jsonb_build_object(
        'folio', v_ps.folio,
        'proveedor', v_ps.proveedor,
        'antes', jsonb_build_object(
          'monto_servicio', 67,
          'comision', 10,
          'total_cobrado', 77,
          'compensacion_mp', 0.67
        ),
        'despues', jsonb_build_object(
          'monto_servicio', 65,
          'comision', 10,
          'total_cobrado', 75,
          'compensacion_mp', 0.65
        ),
        'motivo', 'Sra. Yola CFE: recibo 65 + recargo 10'
      )
    );
  exception when others then null;
  end;

  raise notice 'Corregido % (CFE Yola): $67+$10=$77 → $65+$10=$75 (MP $0.67 → $0.65)',
    v_ps.folio;
end $$;

commit;
