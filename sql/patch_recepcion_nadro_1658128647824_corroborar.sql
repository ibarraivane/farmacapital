-- Pedido Nadro 1658128647824-01 (2026-08-30) — cola Recibir, borrador.
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
  where folio = '1658128647824-01' and coalesce(proveedor, '') ilike '%nadro%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Nadro 1658128647824-01 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('Nadro', '1658128647824-01', '2026-08-30', 5617.17, 'borrador',
              'Pedido Nadro 1658128647824-01 · entrega 31-ago · cola Recibir; stock al confirmar pistola')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 5617.17, fecha = '2026-08-30', proveedor = 'Nadro', updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
        ('', 'OMEPRAZOL 20 MG FCO 60 CAPS LGEN', 2, 26.82::numeric, null),
        ('', 'OMEPRAZOL 20 MG 14 CAPS LGEN', 2, 9.50, null),
        ('', 'OMEPRAZOL 20MG 30 CAPS LGEN', 2, 16.13, null),
        ('', 'IRBES (nombre cortado en el PDF)', 3, 59.66, null),
        ('', 'IRBESARTAN 150MG 14 TAB LGEN', 2, 50.00, null),
        ('', 'IRBESARTAN 150MG FCO 28 TAB LGEN', 2, 97.42, null),
        ('', 'IRBESARTAN 150MG 28 TAB LGEN', 2, 92.36, null),
        ('', 'Irbesartán + Hidroclorotiazida Camber 150/12.5 mg C/28', 1, 91.86, null),
        ('7501361124013', 'Talco Odolex Fresh 150 g', 1, 15.82, 'FC-61124013'),
        ('', 'DOXICICLIN 100MG 10CAPS KEN LGEN', 1, 23.86, null),
        ('', 'Roxidolin Doxiciclina 100 mg C/10', 1, 21.15, null),
        ('', 'Oxitetraciclina 500 mg C/16 cápsulas', 2, 70.00, null),
        ('', 'Klarix Claritromicina 250 mg C/10', 2, 44.88, null),
        ('', 'Cefuroxima 750 mg FA + ampolleta 5 ml', 2, 42.56, null),
        ('', 'CEFALOTINA 1G S INY FA 5ML LGEN', 2, 56.28, null),
        ('', 'PIOGLITAZONA 15 MG 7 TAB LGEN', 3, 13.35, null),
        ('', 'Bactrim F 800/160 mg 15 tabletas', 1, 331.87, null),
        ('', 'OMEPRAZOL 40MG S.INY. AMP LGEN', 1, 29.06, null),
        ('', 'Bactrim 200/40 mg suspensión 100 ml', 1, 188.44, null),
        ('7501054507901', 'Labello Fresa 4.8 g', 2, 54.87, 'FC-45079011'),
        ('7501054504870', 'Labello Clásico 4.8 g', 2, 54.87, 'FC-54504870'),
        ('', 'CeraVe gel limpiador control imperfecciones 236 ml', 1, 273.91, null),
        ('', 'Oxímetro Inhala Care pulso dedo FS10E', 1, 303.80, null),
        ('', 'Toallas húmedas Tena para adulto', 1, 55.00, null),
        ('7501054558682', 'Crema corporal Nivea Milk', 4, 25.86, 'FC-54558682'),
        ('', 'Labello Med Protection 4.8 g', 1, 54.87, null),
        ('', 'Labello Caring Beauty Red 4.8 g', 1, 79.58, null),
        ('', 'DEFLAZACORT 30 MG 10 TAB LGEN', 1, 110.89, null),
        ('75073114', 'Rexona Men Clinical Clean stick 46 g', 7, 55.68, null),
        ('6502400323252', 'Suerox 8 iones Lima-Limón 630 ml', 1, 12.42, 'FC-40032325'),
        ('', 'Rexona Women Clinical Classic stick 46 g', 3, 55.68, null),
        ('', 'Electrolife Zero Uva 625 ml', 2, 19.36, null),
        ('', 'Tampones Saba Compactos Super', 1, 31.39, null),
        ('', 'Alli Triple 50/.25/50/50 mg C/6', 3, 79.87, null),
        ('', 'Eucerin pH5 (nombre cortado en el PDF)', 1, 85.20, null),
        ('', 'COMP B (nombre cortado en el PDF)', 1, 55.76, null),
        ('', 'Parches Saba térmicos C/3', 1, 57.41, null),
        ('', 'Picot-Plus 9 sobres polvo efervescente', 1, 46.12, null),
        ('', 'Panty protector Saba largo C/28', 1, 27.28, null),
        ('', 'PIOGLITAZONA 30MG 7 TAB LGEN', 6, 17.76, null),
        ('', 'Gentamicina 160 mg solución inyectable 2 ml Amsa', 1, 12.71, null),
        ('7501165011649', 'Buscapina 10 mg 24 grageas', 2, 172.04, null),
        ('', 'Buscapina Duo 10/500 mg C/10', 1, 122.36, null),
        ('', 'Vitacilina ungüento 16 g', 2, 25.19, null),
        ('', 'Vitacilina ungüento 28 g', 3, 37.57, null),
        ('', 'Syncol 500/25/15 mg 12 comprimidos', 1, 97.12, null),
        ('7501008498866', 'Flanax 550 mg 6 tabletas', 1, 105.00, null),
        ('7502001166066', 'Barmicil compuesto crema 40 g', 1, 21.08, 'FC-01166066'),
        ('', 'Flanax Nocto 220/25 mg 20 comprimidos', 1, 130.50, null),
        ('', 'Flanax 660 mg 8 tabletas', 1, 230.00, null)
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

    raise notice 'Recepcion Nadro 1658128647824-01 lista id=% — escanear caja por caja', v_id;
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
where r.folio = '1658128647824-01' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
