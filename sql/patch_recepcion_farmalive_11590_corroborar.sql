-- Farmalive 11590 ya cargó stock/lotes SIN fecha (lote RX inventado, no de fábrica).
-- Arma el documento Recibir para corroborar MMAA en caja, sin volver a sumar piezas.
-- Idempotente. Pegar en Supabase DESPUÉS de:
--   1) sql/patch_recepcion_pdf_confirmar_20260821.sql
--   2) Cerrar o terminar el borrador de Cityfarma 6315912 (Recibir solo muestra un borrador).

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
  where folio = '11590' and coalesce(proveedor, '') ilike '%farmalive%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Farmalive 11590 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('Farmalive', '11590', '2026-08-21', 704.42, 'borrador',
              'Ticket Farmalive 11590 · stock ya recibido; falta caducidad de caja')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 704.42, updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
        ('7501065054029', 'Tums surtido tabletas masticables C/48', 2, 85.26::numeric, 'RX-FARMALIVE-20260821-11590'),
        ('7501019064807', 'Tena Pants Comfort grande C/13', 1, 113.62, 'RX-FARMALIVE-20260821-11590'),
        ('7500435179980', 'Oral-B enjuague bucal 100% 250 mL', 2, 47.79, 'RX-FARMALIVE-20260821-11590'),
        ('7891051037878', 'Oral-B enjuague bucal Complete 250 mL', 2, 47.50, 'RX-FARMALIVE-20260821-11590'),
        ('5000174305449', 'Fixodent Original crema dental 40 mL', 2, 93.30, 'RX-FARMALIVE-20260821-11590'),
        ('020800600330', 'Tampax Super C/10', 1, 43.12, 'RX-FARMALIVE-20260821-11590')
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
        v_lid
      );
    end loop;

    raise notice 'Recepcion Farmalive lista id=% — Recibir y corroborar MMAA (un borrador a la vez)', v_id;
  end if;
end $$;

commit;

select id, folio, proveedor, estado, (select count(*) from public.recepcion_items i where i.recepcion_id = r.id) as renglones
from public.recepciones r
where folio in ('11590', '6315912')
order by updated_at desc;
