-- Cityfarma 6315912 ya cargó stock/lotes SIN fecha.
-- Arma el documento Recibir para corroborar MMAA en caja, sin volver a sumar piezas.
-- Idempotente. Pegar en Supabase después de patch_recepcion_pdf_confirmar_20260821.sql.

begin;

do $$
declare
  v_id bigint;
  r record;
  v_pid bigint;
  v_lid bigint;
  v_piso int;
begin
  select id into v_id
  from public.recepciones
  where folio = '6315912' and coalesce(proveedor, '') ilike '%cityfarma%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Cityfarma 6315912 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('Cityfarma Iztapalapa', '6315912', '2026-08-21', 2570.99, 'borrador',
              'Ticket Cityfarma 6315912 · stock ya recibido; falta caducidad de caja')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 2570.99, updated_at = now()
      where id = v_id;
    end if;

  for r in
    select * from (values
      ('7501050613453', 'Afrin Adulto spray 20 mL', 2, 75.38::numeric, '2601928'),
      ('7501050623766', 'Afrin No Drip solución nasal 15 mL', 2, 115.52, '2601390'),
      ('7501165001725', 'Allegra fexofenadina 180 mg C/10', 1, 362.97, 'GMX0303'),
      ('7501065001337', 'Caltrate 600 + D C/30', 2, 153.59, 'T75M'),
      ('7502276040368', 'Desenfriol D', 3, 61.68, '2601928'),
      ('7502276040405', 'Desenfriolito Plus Masticables', 2, 57.76, 'X26RXS'),
      ('7501300421524', 'Dolac ketorolaco 10 mg C/10', 3, 99.73, 'T0623'),
      ('3664798074680', 'Enterogermina 2 billones C/10', 1, 200.00, '6I086'),
      ('7501289511421', 'Pasta Lassar Andromaco 30 g', 2, 22.50, '26PL029'),
      ('7501289511414', 'Pasta Lassar Andromaco 60 g', 2, 47.37, '26PL057'),
      ('4001895928765', 'Tegaderm 3M 10 x 12 cm C/50', 1, 579.55, '344JWY')
    ) as t(ean, nombre, qty, costo, lote)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    v_lid := null;
    v_piso := 0;
    if v_pid is not null then
      select count(*)::int into v_piso
      from public.lotes l
      where l.producto_id = v_pid and coalesce(l.activo, true) and coalesce(l.cantidad_actual, 0) > 0;

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

  raise notice 'Recepcion Cityfarma lista id=% — abrir Inventario → Recibir y corroborar MMAA', v_id;
  end if;
end $$;

commit;

select id, folio, proveedor, estado, (select count(*) from public.recepcion_items i where i.recepcion_id = r.id) as renglones
from public.recepciones r
where folio = '6315912';
