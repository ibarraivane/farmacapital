-- Levic · factura interna A 9012242979 · CFDI 14-sep-2026 03:41
-- Folio fiscal C7F561F1-1FC5-4B04-99CF-3CF83FA37ED8 (OCR parcial) · entrega 832819990 · PUE efectivo $1557.92
-- Receptor LUIS ANGEL PALILLERO VENTURA · 24 renglones · 46 pzas (TOT 46 hoja 2).
-- Subtotal CFDI $1538.94 + IVA $18.98 = $1557.92.
-- Costo = Precio neto. Lote = de fábrica (sí viene en la factura; OCR de foto).
-- Caducidad del papel NO se escribe aquí: Recibir captura MMAA de la caja.
-- 0000 es inválido.
-- TODO foto: Visoti bloqueado en este entorno; copiar packshot a
--   public/catalogo-propia/ y SQL de imagen_url después del deploy.
--
-- 6 ya estaban · 18 altas nuevas.
-- Altas: stock 0. En existentes solo se actualiza costo (no el PVP).
-- Idempotente. Pegar en Supabase SQL Editor (archivo completo).

begin;

-- ── 1) Catálogo: altas faltantes + costo de esta factura ──────────
do $$
declare
  r record;
  v_pid bigint;
  n_alta integer := 0;
  n_costo integer := 0;
begin
  for r in
    select * from (values
      ('7506335701214', 'EQ-ACC092', 'HT-Bloc Accord ondansetrón 1 amp 4 mg/2 mL', 'Medicamentos', 'marca', 44.64::numeric, 72.00, 2, 'Accord', 'Caja con 1 ampolleta 4 mg/2 mL', 'Ondansetrón', '4 mg/2 mL', true, 'Factura Levic 9012242979 · clave ACC092 · lote M2408436', true),
      ('7501384541163', 'EQ-ALP0608', 'Carbamazepina Alpharma 20 tab 200 mg', 'Medicamentos', 'generico', 18.75, 30.00, 1, 'Alpharma', 'Caja con 20 tabletas', 'Carbamazepina', '200 mg', true, 'Factura Levic 9012242979 · clave ALP0608 · lote 7230526', false),
      ('7501349020122', 'EQ-AMS132', 'Clonixinato de lisina AMSA 5 amp 100 mg/2 mL', 'Medicamentos', 'generico', 28.97, 47.00, 2, 'AMSA', 'Caja con 5 ampolletas 100 mg/2 mL', 'Clonixinato de lisina', '100 mg/2 mL', true, 'Factura Levic 9012242979 · clave AMS132 · lote B26A507', true),
      ('7501349014190', 'EQ-AMS147', 'Ácido alendrónico AMSA 30 tab 10 mg', 'Medicamentos', 'generico', 23.55, 38.00, 1, 'AMSA', 'Caja con 30 tabletas', 'Ácido alendrónico', '10 mg', true, 'Factura Levic 9012242979 · clave AMS147 · lote U26A275', true),
      ('7501277071685', 'EQ-APO216', 'Prochor Apotex propranolol 30 tab 40 mg', 'Medicamentos', 'marca', 23.96, 39.00, 2, 'Apotex', 'Caja con 30 tabletas', 'Propranolol', '40 mg', true, 'Factura Levic 9012242979 · clave APO216 · lote 0806M26', true),
      ('7502209850231', 'EQ-AVT218', 'Zagapsol amlodipino 10 tab 5 mg', 'Medicamentos', 'generico', 4.37, 7.00, 2, 'Zagapsol', 'Caja con 10 tabletas', 'Amlodipino', '5 mg', true, 'Factura Levic 9012242979 · clave AVT218 · lote SF26155', true),
      ('7501342804408', 'EQ-BEA424', 'Metoprolol beadvance 20 tab 100 mg', 'Medicamentos', 'generico', 7.67, 13.00, 2, 'beadvance', 'Caja con 20 tabletas', 'Metoprolol', '100 mg', true, 'Factura Levic 9012242979 · clave BEA424 · lote 670186', false),
      ('7501842951657', 'EQ-GEN062', 'Pakid Genética paracetamol/ibuprofeno 20 tab 325/200 mg', 'Medicamentos', 'marca', 27.88, 45.00, 2, 'Pakid', 'Caja con 20 tabletas', 'Paracetamol / Ibuprofeno', '325 mg / 200 mg', false, 'Factura Levic 9012242979 · clave GEN062 · lote 614015A', true),
      ('6358975544000', 'EQ-JAV050', 'Clorofil Jahvs solución clorofila 500 mL', 'Suplementos', 'marca', 61.15, 98.00, 1, 'Clorofil Jahvs', 'Frasco 500 mL', 'Clorofila', null, false, 'Factura Levic 9012242979 · clave JAV050 · lote 0200107', true),
      ('7506022315038', 'EQ-JAY216', 'Navontec Jayor ondansetrón 3 amp 8 mg/4 mL', 'Medicamentos', 'marca', 55.87, 90.00, 2, 'Jayor', 'Caja con 3 ampolletas 8 mg/4 mL', 'Ondansetrón', '8 mg/4 mL', true, 'Factura Levic 9012242979 · clave JAY216 · lote 6A0023C06', true),
      ('7502211788690', 'EQ-LOE123', 'Diotexona Loeffler dimeticona gotero 10 g/100 mL 30 mL', 'Medicamentos', 'marca', 44.64, 72.00, 1, 'Loeffler', 'Frasco gotero 30 mL', 'Dimeticona', '10 g/100 mL', false, 'Factura Levic 9012242979 · clave LOE123 · lote R2511440', false),
      ('7502009742798', 'EQ-MAV176', 'Laritol EX Maver loratadina/ambroxol solución 30 mL', 'Medicamentos', 'marca', 16.87, 27.00, 2, 'Maver', 'Frasco gotero 30 mL', 'Loratadina / Ambroxol', '100 mg / 600 mg / 100 mL', false, 'Factura Levic 9012242979 · clave MAV176 · lote 262633', true),
      ('7502009746321', 'EQ-MAV300', 'Nisolver Maver prednisolona solución 100 mL', 'Medicamentos', 'marca', 73.74, 118.00, 2, 'Maver', 'Frasco 100 mL', 'Prednisolona', '1 mg/mL', true, 'Factura Levic 9012242979 · clave MAV300 · lote 260451', true),
      ('7502009747274', 'EQ-MAV342', 'Dolver Maver ibuprofeno 10 tab 600 mg', 'Medicamentos', 'marca', 17.61, 29.00, 2, 'Maver', 'Caja con 10 tabletas', 'Ibuprofeno', '600 mg', false, 'Factura Levic 9012242979 · clave MAV342 · lote 264180', true),
      ('7502009748035', 'EQ-MAV364', 'Tinitrend Maver tretinoína crema 0.05% 30 g', 'Medicamentos', 'marca', 33.12, 53.00, 2, 'Maver', 'Tubo 30 g', 'Tretinoína', '0.05%', true, 'Factura Levic 9012242979 · clave MAV364 · lote 261915', true),
      ('7502009747410', 'EQ-MAV375', 'Tinitrend Maver tretinoína crema 0.05% 40 g', 'Medicamentos', 'marca', 41.24, 66.00, 2, 'Maver', 'Tubo 40 g', 'Tretinoína', '0.05%', true, 'Factura Levic 9012242979 · clave MAV375 · lote 260872', true),
      ('7503027446279', 'EQ-PGE057', 'Gelubrin Progela ibuprofeno 10 cáps 600 mg', 'Medicamentos', 'marca', 22.58, 37.00, 2, 'Gelubrin', 'Caja con 10 cápsulas', 'Ibuprofeno', '600 mg', false, 'Factura Levic 9012242979 · clave PGE057 · lote U0400', false),
      ('7501563380163', 'EQ-RAD081', 'Fumarato ferroso Randall 50 tab 200 mg', 'Medicamentos', 'generico', 14.20, 23.00, 1, 'Randall', 'Caja con 50 tabletas', 'Fumarato ferroso', '200 mg', false, 'Factura Levic 9012242979 · clave RAD081 · lote 28563', false),
      ('7501563380415', 'EQ-RAD097', 'Tretinoína Randall crema 0.05% 20 g', 'Medicamentos', 'generico', 10.93, 18.00, 2, 'Randall', 'Tubo 20 g', 'Tretinoína', '0.05%', true, 'Factura Levic 9012242979 · clave RAD097 · lote 21902', true),
      ('7502227876428', 'EQ-RAM141', 'Breflumar Raam flunarizina 20 tab 5 mg', 'Medicamentos', 'marca', 28.38, 46.00, 2, 'Raam', 'Caja con 20 tabletas', 'Flunarizina', '5 mg', true, 'Factura Levic 9012242979 · clave RAM141 · lote RBR029', true),
      ('7501258203593', 'EQ-SER024', 'Lonixer Serral clonixinato 10 tab 125 mg', 'Medicamentos', 'marca', 30.65, 50.00, 2, 'Serral', 'Caja con 10 tabletas', 'Clonixinato de lisina', '125 mg', true, 'Factura Levic 9012242979 · clave SER024 · lote 260057', true),
      ('7501258203586', 'EQ-SER025', 'Lonixer Serral clonixinato 10 tab 250 mg', 'Medicamentos', 'marca', 37.63, 61.00, 2, 'Serral', 'Caja con 10 tabletas', 'Clonixinato de lisina', '250 mg', true, 'Factura Levic 9012242979 · clave SER025 · lote 260186', false),
      ('7506281106019', 'EQ-STR005', 'Ferro-4 Streger 30 grageas 300/150/50/10 mg', 'Suplementos', 'marca', 57.49, 92.00, 1, 'Streger', 'Caja con 30 grageas', 'Fumarato ferroso / vitaminas', '300/150/50/10 mg', false, 'Factura Levic 9012242979 · clave STR005 · lote SU01US', true),
      ('7501122960201', 'EQ-VAL063', 'Arretin tretinoína crema 0.05% 30 g', 'Medicamentos', 'marca', 184.45, 296.00, 1, 'Arretin', 'Tubo 30 g', 'Tretinoína', '0.05%', true, 'Factura Levic 9012242979 · clave VAL063 · lote 430098', true)
    ) as t(ean, sku, nombre, categoria, tipo, costo, precio, stock_minimo,
           marca, presentacion, principio, concentracion, receta, notas, es_alta)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    if v_pid is null then
      v_pid := public.fc_buscar_producto_escaneo(r.sku);
    end if;

    if v_pid is null then
      select f.producto_id into v_pid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', r.nombre,
          'sku', r.sku,
          'codigo_barras', r.ean,
          'categoria', r.categoria,
          'tipo', r.tipo,
          'descripcion', r.notas,
          'costo', r.costo,
          'precio', r.precio,
          'stock_minimo', r.stock_minimo,
          'activo', true,
          'requiere_receta', r.receta
        ),
        0, null, null::date, r.costo, null::bigint
      ) f;
      n_alta := n_alta + 1;
    else
      update public.productos set
        costo = r.costo,
        stock_minimo = greatest(coalesce(stock_minimo, 0), r.stock_minimo),
        codigo_barras = coalesce(nullif(codigo_barras, ''), r.ean)
      where id = v_pid;
      n_costo := n_costo + 1;
    end if;

    update public.productos set
      marca = coalesce(nullif(marca, ''), r.marca),
      presentacion = coalesce(nullif(presentacion, ''), r.presentacion),
      principio_activo = coalesce(nullif(principio_activo, ''), r.principio),
      concentracion = coalesce(nullif(concentracion, ''), r.concentracion)
    where id = v_pid;
  end loop;

  raise notice 'Levic 9012242979: % altas de catálogo, % costos actualizados (stock = Recibir)',
    n_alta, n_costo;
end $$;

-- ── 2) Cola Recibir (borrador, sin sumar piezas) ──────────────────
do $$
declare
  v_id bigint;
  r record;
  v_pid bigint;
begin
  select id into v_id
  from public.recepciones
  where folio = '9012242979' and coalesce(proveedor, '') ilike '%levic%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Levic 9012242979 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('Levic', '9012242979', '2026-09-14', 1557.92, 'borrador',
              'Factura Levic A 9012242979 · CFDI C7F561F1-1FC5-4B04-99CF-3CF83FA37ED8 · entrega 832819990 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja; TODO foto Visoti/catalogo-propia para altas nuevas')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 1557.92, fecha = '2026-09-14',
          proveedor = 'Levic', notas = 'Factura Levic A 9012242979 · CFDI C7F561F1-1FC5-4B04-99CF-3CF83FA37ED8 · entrega 832819990 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja; TODO foto Visoti/catalogo-propia para altas nuevas', updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
        ('7506335701214', 'HT-Bloc Accord ondansetrón 1 amp 4 mg/2 mL', 2, 44.64::numeric, 'EQ-ACC092', 'M2408436'),
        ('7501384541163', 'Carbamazepina Alpharma 20 tab 200 mg', 1, 18.75, 'EQ-ALP0608', '7230526'),
        ('7501349020122', 'Clonixinato de lisina AMSA 5 amp 100 mg/2 mL', 2, 28.97, 'EQ-AMS132', 'B26A507'),
        ('7501349014190', 'Ácido alendrónico AMSA 30 tab 10 mg', 1, 23.55, 'EQ-AMS147', 'U26A275'),
        ('7501277071685', 'Prochor Apotex propranolol 30 tab 40 mg', 3, 23.96, 'EQ-APO216', '0806M26'),
        ('7502209850231', 'Zagapsol amlodipino 10 tab 5 mg', 2, 4.37, 'EQ-AVT218', 'SF26155'),
        ('7501342804408', 'Metoprolol beadvance 20 tab 100 mg', 3, 7.67, 'EQ-BEA424', '670186'),
        ('7501842951657', 'Pakid Genética paracetamol/ibuprofeno 20 tab 325/200 mg', 2, 27.88, 'EQ-GEN062', '614015A'),
        ('6358975544000', 'Clorofil Jahvs solución clorofila 500 mL', 1, 61.15, 'EQ-JAV050', '0200107'),
        ('7506022315038', 'Navontec Jayor ondansetrón 3 amp 8 mg/4 mL', 2, 55.87, 'EQ-JAY216', '6A0023C06'),
        ('7502211788690', 'Diotexona Loeffler dimeticona gotero 10 g/100 mL 30 mL', 1, 44.64, 'EQ-LOE123', 'R2511440'),
        ('7502009742798', 'Laritol EX Maver loratadina/ambroxol solución 30 mL', 2, 16.87, 'EQ-MAV176', '262633'),
        ('7502009746321', 'Nisolver Maver prednisolona solución 100 mL', 2, 73.74, 'EQ-MAV300', '260451'),
        ('7502009747274', 'Dolver Maver ibuprofeno 10 tab 600 mg', 2, 17.61, 'EQ-MAV342', '264180'),
        ('7502009748035', 'Tinitrend Maver tretinoína crema 0.05% 30 g', 2, 33.12, 'EQ-MAV364', '261915'),
        ('7502009747410', 'Tinitrend Maver tretinoína crema 0.05% 40 g', 2, 41.24, 'EQ-MAV375', '260872'),
        ('7503027446279', 'Gelubrin Progela ibuprofeno 10 cáps 600 mg', 3, 22.58, 'EQ-PGE057', 'U0400'),
        ('7501563380163', 'Fumarato ferroso Randall 50 tab 200 mg', 1, 14.20, 'EQ-RAD081', '28563'),
        ('7501563380415', 'Tretinoína Randall crema 0.05% 20 g', 2, 10.93, 'EQ-RAD097', '21902'),
        ('7502227876428', 'Breflumar Raam flunarizina 20 tab 5 mg', 2, 28.38, 'EQ-RAM141', 'RBR029'),
        ('7501258203593', 'Lonixer Serral clonixinato 10 tab 125 mg', 3, 30.65, 'EQ-SER024', '260057'),
        ('7501258203586', 'Lonixer Serral clonixinato 10 tab 250 mg', 3, 37.63, 'EQ-SER025', '260186'),
        ('7506281106019', 'Ferro-4 Streger 30 grageas 300/150/50/10 mg', 1, 57.49, 'EQ-STR005', 'SU01US'),
        ('7501122960201', 'Arretin tretinoína crema 0.05% 30 g', 1, 184.45, 'EQ-VAL063', '430098')
      ) as t(ean, nombre, qty, costo, sku, lote)
    loop
      v_pid := public.fc_buscar_producto_escaneo(r.ean);
      if v_pid is null then
        v_pid := public.fc_buscar_producto_escaneo(r.sku);
      end if;

      insert into public.recepcion_items (
        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
        origen, confirmado, lote_distinto, lote_id
      ) values (
        v_id, v_pid, r.ean, r.nombre, r.qty, null, r.lote, r.costo,
        (v_pid is null), 'pdf', false,
        (v_pid is not null and exists (
          select 1 from public.lotes l
          where l.producto_id = v_pid and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
            and l.numero_lote is distinct from r.lote
        )),
        null
      );
    end loop;

    raise notice 'Recepcion Levic 9012242979 lista id=% — escanear caja por caja', v_id;
  end if;
end $$;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '9012242979' and coalesce(r.proveedor, '') ilike '%levic%'
order by i.id;
