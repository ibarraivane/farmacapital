-- Levic 9012078353 ya cargó stock/lotes SIN fecha (lote de fábrica sí; MMAA de la caja).
-- Arma el documento Recibir para corroborar MMAA, sin volver a sumar piezas.
-- Idempotente. Pegar en Supabase DESPUÉS de patch_carga_levic_9012078353.sql.

begin;

do $$
declare
  v_id bigint;
  r record;
  v_pid bigint;
  v_lid bigint;
begin
  select id into v_id
  from public.recepciones
  where folio = '9012078353' and coalesce(proveedor, '') ilike '%levic%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Levic 9012078353 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('Levic', '9012078353', '2026-08-20', 637.25, 'borrador',
              'Factura Levic A 9012078353 · cola Recibir; stock al confirmar pistola')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 637.25, updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
        ('7501342802749', 'Sildenafil beadvance 50 mg 1 tableta', 4, 4.90::numeric, 'ECM297C'),
        ('7501573909958', 'Colchicina 30 Tab 1 Mg', 2, 31.24, 'SD2602'),
        ('7501048335138', 'Agua oxigenada Dermocleen 100 mL', 2, 8.08, '3A206030'),
        ('7501048335169', 'Agua oxigenada Dermocleen 230 mL', 2, 11.57, '3A196054'),
        ('7502009745478', 'Ideliver Pro duloxetina 60 mg C/14', 4, 63.74, '283429'),
        ('7501109769063', 'Agecaps minoxidil hombre 5% solución 60 mL', 1, 150.00, '26C063'),
        ('7502216800984', 'Acemetacina 14 cáps 90 mg', 2, 52.31, '68N323A')
      ) as t(ean, nombre, qty, costo, lote)
    loop
      v_pid := public.fc_buscar_producto_escaneo(r.ean);
      v_lid := null;
      if v_pid is not null then
        select l.id into v_lid
        from public.lotes l
        where l.producto_id = v_pid and l.numero_lote = r.lote and coalesce(l.activo, true)
        order by l.id desc
        limit 1;
      end if;

      insert into public.recepcion_items (
        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
        cantidad, numero_lote, costo_estimado, pendiente_alta,
        origen, confirmado, lote_distinto, lote_id
      ) values (
        v_id, v_pid, r.ean, r.nombre, r.qty, r.lote, r.costo,
        (v_pid is null), 'pdf', false,
        (exists (
          select 1 from public.lotes l
          where l.producto_id = v_pid and coalesce(l.activo, true) and coalesce(l.cantidad_actual, 0) > 0
            and l.numero_lote is distinct from r.lote
        )),
        null
      );
    end loop;

    raise notice 'Recepcion Levic lista id=% — Recibir y corroborar MMAA', v_id;
  end if;
end $$;

commit;

select id, folio, proveedor, estado, (select count(*) from public.recepcion_items i where i.recepcion_id = r.id) as renglones
from public.recepciones r
where folio in ('9012078353', '11590', '6315912')
order by updated_at desc;
