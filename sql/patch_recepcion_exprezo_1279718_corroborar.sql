-- Pedido Exprezo 1279718 (2026-08-30) — cola Recibir, borrador.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.
-- Idempotente. Pegar en Supabase → SQL Editor → Run.

begin;

do $$
declare
  v_id bigint;
  r record;
  v_pid bigint;
begin
  select id into v_id
  from public.recepciones
  where folio = '1279718' and coalesce(proveedor, '') ilike '%exprezo%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Exprezo 1279718 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('Exprezo', '1279718', '2026-08-30', 1981.55, 'borrador',
              'Pedido Exprezo 1279718 · entrega 31-ago · cola Recibir; stock al confirmar pistola · surtido $97 no es renglón')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 1981.55, fecha = '2026-08-30', proveedor = 'Exprezo', updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
        ('', 'Jabón Palmolive Naturals Neutro Balance 100 g 8 Pack', 1, 114.40::numeric, null),
        ('', 'Tira Shampoo Head & Shoulders 24 sachets 10 ml', 1, 51.21, null),
        ('7509546073033', 'Shampoo Caprice Acti-Ceramidas 200 ml', 1, 19.30, 'FC-46073033'),
        ('', 'Pack 48 sobres Shampoo Palmolive Optims 10 ml', 1, 75.30, null),
        ('7501008497340', 'Flanax 550 mg 12 Tabs', 3, 189.65, 'FC-84973401'),
        ('7506475102421', 'Gerber Etapa 2 Manzana 100 g', 3, 10.68, null),
        ('7506475102469', 'Gerber Etapa 2 Mango 100 g', 3, 10.68, null),
        ('7506475102452', 'Gerber Etapa 2 Pera 100 g', 3, 10.68, null),
        ('7506475102476', 'Gerber Etapa 2 Durazno 100 g', 3, 10.68, null),
        ('7506475102537', 'Gerber Etapa 2 Comida Casera Pollo 100 g', 4, 10.68, null),
        ('7506475102520', 'Gerber Etapa 2 Comida Casera Res 100 g', 4, 10.68, null),
        ('0608875005092', 'Papilla Heinz Pouch Manzana 113 g', 3, 14.40, null),
        ('7501058651129', 'GERBER POUCH JR FRUT MIXT 95 g', 3, 12.79, null),
        ('7506205809248', 'Enfagrow Premium Etapa 3 lata 800 g', 1, 306.00, null),
        ('650240013805', 'Alliviax Desinflamatorio 550 mg C/10', 3, 100.50, null),
        ('7506306246652', 'Jabón Dove blanco 90 g', 6, 18.63, null),
        ('7506425652716', 'Jabón Escudo Azul 135 g', 3, 13.65, 'FC-25652716')
      ) as t(ean, nombre, qty, costo, sku)
    loop
      v_pid := null;
      if r.ean is not null and btrim(r.ean) <> '' then
        v_pid := public.fc_buscar_producto_escaneo(r.ean);
      end if;
      if v_pid is null and r.sku is not null then
        v_pid := public.fc_buscar_producto_escaneo(r.sku);
      end if;

      insert into public.recepcion_items (
        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
        origen, confirmado, lote_distinto, lote_id
      ) values (
        v_id, v_pid, nullif(btrim(r.ean), ''), r.nombre, r.qty, null, null, r.costo,
        (v_pid is null), 'pdf', false,
        (v_pid is not null and exists (
          select 1 from public.lotes l
          where l.producto_id = v_pid and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
        )),
        null
      );
    end loop;

    raise notice 'Recepcion Exprezo 1279718 lista id=% — escanear caja por caja', v_id;
  end if;
end $$;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '1279718' and coalesce(r.proveedor, '') ilike '%exprezo%'
order by i.id;
