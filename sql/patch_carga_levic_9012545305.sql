-- Levic · factura interna A 9012545305 · CFDI 2026-10-26
-- Folio fiscal B57229E5-7DBB-4B9F-A23E-B1D28E33B872 (OCR foto) · PUE efectivo $1844.92
-- Receptor LUIS ANGEL PALILLERO VENTURA · 12 renglones · 59 pzas (TOT 59 hoja 1).
-- Subtotal CFDI $1750.53 + IVA $94.39 (Cintapore $20.07 + Microdacyn $74.32) = $1844.92.
-- Costo = Precio neto. Lote = de fábrica (sí viene en la factura).
-- Caducidad del papel NO se escribe aquí: Recibir captura MMAA de la caja.
-- 0000 es inválido.
-- BEA215 sin EAN público: alta por SKU EQ-BEA215; completar codigo_barras al escanear.
--
-- 7 ya estaban · 5 altas nuevas.
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
      ('7503004908721', 'FC-1BF03D35', 'Acetónido de fluocinolona Alpharma crema 0.01%', 'Medicamentos', 'generico', 19.79::numeric, 32.00, 2, 'Alpharma', 'Tubo 40 g', 'Acetónido de fluocinolona', '0.01%', 'Crema', true, 'Factura Levic 9012545305 · clave ALP0598 · lote 2605164', null, false),
      ('7502226294476', 'EQ-ALP0673', 'Acetónido de fluocinolona Alpharma crema 0.01%', 'Medicamentos', 'generico', 11.46, 19.00, 2, 'Alpharma', 'Tubo 20 g', 'Acetónido de fluocinolona', '0.01%', 'Crema', true, 'Factura Levic 9012545305 · clave ALP0673 · lote 2609272', 'https://www.farmacapital.mx/catalogo-propia/acetonido-fluocinolona-alpharma-20g-7502226294476.jpg', true),
      (null, 'EQ-BEA215', 'Diclofenaco beadvance 100 mg', 'Medicamentos', 'generico', 7.67, 13.00, 2, 'beadvance', 'Caja con 20 tabletas de liberación prolongada', 'Diclofenaco', '100 mg', 'Tabletas', true, 'Factura Levic 9012545305 · clave BEA215 · lote SMM2088', 'https://www.farmacapital.mx/catalogo-propia/diclofenaco-beadvance-100mg-20-tabs.jpg', true),
      ('7501573906407', 'FC-73906407', 'Lozamir-V clotrimazol crema 2%', 'Medicamentos', 'marca', 22.52, 29.00, 2, 'Biomep', 'Tubo 20 g con 3 aplicadores', 'Clotrimazol', '2%', 'Crema', true, 'Factura Levic 9012545305 · clave BIO149 · lote CE2607', null, false),
      ('7501573909859', 'FC-73909859', 'Sarox omeprazol 20 mg', 'Medicamentos', 'marca', 15.00, 19.00, 2, 'Biomep', 'Caja con 28 cápsulas', 'Omeprazol', '20 mg', 'Cápsulas', true, 'Factura Levic 9012545305 · clave BIO213 · lote SG2653', null, false),
      ('7501537102845', 'EQ-BRU053', 'Nediclon diclofenaco 100 mg', 'Medicamentos', 'generico', 8.84, 15.00, 4, 'Bruluart', 'Caja con 20 grageas de liberación prolongada', 'Diclofenaco', '100 mg', 'Grageas', true, 'Factura Levic 9012545305 · clave BRU053 · lote 807352', null, false),
      ('7501537102067', 'EQ-BRU070', 'Soltrim trimetoprima/sulfametoxazol 40/200', 'Medicamentos', 'marca', 28.00, 35.00, 2, 'Bruluart', 'Frasco suspensión 120 mL', 'Trimetoprima / Sulfametoxazol', '40 mg / 200 mg / 5 mL', 'Suspensión', true, 'Factura Levic 9012545305 · clave BRU070 · lote 2605486', 'https://www.farmacapital.mx/catalogo-propia/soltrim-suspension-40-200-120ml-bruluart-7501537102067.jpg', true),
      ('7501088545658', 'EQ-CHI029', 'Mydocalm-A paracetamol/tolperisona 300/50 mg', 'Medicamentos', 'marca', 363.75, 455.00, 1, 'Chinoin', 'Caja con 30 cápsulas', 'Paracetamol / Tolperisona', '300 mg / 50 mg', 'Cápsulas', true, 'Factura Levic 9012545305 · clave CHI029 · lote BFC021', 'https://www.farmacapital.mx/catalogo-propia/mydocalm-a-paracetamol-tolperisona-300-50-30-caps-7501088545658.jpg', true),
      ('7506484500034', 'FC-84500034', 'Cintapore micropore piel', 'Botiquín', 'marca', 125.43, 157.00, 1, 'Codifarma', 'Caja con 12 rollos 2.5 cm × 5 m', null, null, 'Cinta', false, 'Factura Levic 9012545305 · clave COD106 · lote 2804022', 'https://www.farmacapital.mx/catalogo-propia/cintapore-piel-2.5x5.jpg', false),
      ('7502006920021', 'FC-06920021', 'Motilaxil-T picosulfato de sodio 5 mg', 'Medicamentos', 'marca', 17.95, 23.00, 2, 'Fármacos Continentales', 'Caja con 20 tabletas', 'Picosulfato de sodio', '5 mg', 'Tabletas', false, 'Factura Levic 9012545305 · clave FAC0059 · lote ITG265092', null, false),
      ('7502227874417', 'EQ-RAM092', 'Raamcedo aceclofenaco 100 mg', 'Medicamentos', 'marca', 46.04, 58.00, 2, 'Raam', 'Caja con 10 tabletas', 'Aceclofenaco', '100 mg', 'Tabletas', true, 'Factura Levic 9012545305 · clave RAM092 · lote RMD033', 'https://www.farmacapital.mx/catalogo-propia/raamcedo-aceclofenaco-100mg-10-raam-7502227874417.jpg', true),
      ('7503006698316', 'FC-06698316', 'Microdacyn 60 solución antiséptica 120 ml', 'Botiquín', 'marca', 154.84, 194.00, 2, 'Microdacyn', 'Frasco spray 120 mL', 'Ácido hipocloroso', null, 'Solución', false, 'Factura Levic 9012545305 · clave SFE159 · lote 209GD984', 'https://www.farmacapital.mx/catalogo-propia/microdacyn-60-solucion-120ml.jpg', false)
    ) as t(ean, sku, nombre, categoria, tipo, costo, precio, stock_minimo,
           marca, presentacion, principio, concentracion, forma, receta, notas, imagen, es_alta)
  loop
    v_pid := null;
    if r.ean is not null then
      v_pid := public.fc_buscar_producto_escaneo(r.ean);
    end if;
    if v_pid is null then
      v_pid := public.fc_buscar_producto_escaneo(r.sku);
    end if;

    if v_pid is null then
      select f.producto_id into v_pid
      from public.create_producto_with_lote(
        jsonb_strip_nulls(jsonb_build_object(
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
          'requiere_receta', r.receta,
          'imagen_url', r.imagen
        )),
        0, null, null::date, r.costo, null::bigint
      ) f;
      n_alta := n_alta + 1;
    else
      update public.productos set
        costo = r.costo,
        stock_minimo = greatest(coalesce(stock_minimo, 0), r.stock_minimo),
        codigo_barras = case
          when r.ean is not null then coalesce(nullif(codigo_barras, ''), r.ean)
          else codigo_barras
        end,
        imagen_url = coalesce(nullif(btrim(imagen_url), ''), r.imagen)
      where id = v_pid;
      n_costo := n_costo + 1;
    end if;

    update public.productos set
      marca = coalesce(nullif(marca, ''), r.marca),
      presentacion = coalesce(nullif(presentacion, ''), r.presentacion),
      principio_activo = coalesce(nullif(principio_activo, ''), r.principio),
      concentracion = coalesce(nullif(concentracion, ''), r.concentracion),
      forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), r.forma)
    where id = v_pid;
  end loop;

  raise notice 'Levic 9012545305: % altas de catálogo, % costos actualizados (stock = Recibir)',
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
  where folio = '9012545305' and coalesce(proveedor, '') ilike '%levic%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Levic 9012545305 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('Levic', '9012545305', '2026-10-26', 1844.92, 'borrador',
              'Factura Levic A 9012545305 · CFDI B57229E5-7DBB-4B9F-A23E-B1D28E33B872 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja; TODO EAN BEA215 de la caja (packshot ya en catalogo-propia)')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 1844.92, fecha = '2026-10-26',
          proveedor = 'Levic', notas = 'Factura Levic A 9012545305 · CFDI B57229E5-7DBB-4B9F-A23E-B1D28E33B872 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja; TODO EAN BEA215 de la caja (packshot ya en catalogo-propia)', updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
        ('7503004908721', 'Acetónido de fluocinolona Alpharma crema 0.01%', 5, 19.79::numeric, 'FC-1BF03D35', '2605164'),
        ('7502226294476', 'Acetónido de fluocinolona Alpharma crema 0.01%', 5, 11.46, 'EQ-ALP0673', '2609272'),
        (null, 'Diclofenaco beadvance 100 mg', 5, 7.67, 'EQ-BEA215', 'SMM2088'),
        ('7501573906407', 'Lozamir-V clotrimazol crema 2%', 5, 22.52, 'FC-73906407', 'CE2607'),
        ('7501573909859', 'Sarox omeprazol 20 mg', 5, 15.00, 'FC-73909859', 'SG2653'),
        ('7501537102845', 'Nediclon diclofenaco 100 mg', 20, 8.84, 'EQ-BRU053', '807352'),
        ('7501537102067', 'Soltrim trimetoprima/sulfametoxazol 40/200', 2, 28.00, 'EQ-BRU070', '2605486'),
        ('7501088545658', 'Mydocalm-A paracetamol/tolperisona 300/50 mg', 1, 363.75, 'EQ-CHI029', 'BFC021'),
        ('7506484500034', 'Cintapore micropore piel', 1, 125.43, 'FC-84500034', '2804022'),
        ('7502006920021', 'Motilaxil-T picosulfato de sodio 5 mg', 5, 17.95, 'FC-06920021', 'ITG265092'),
        ('7502227874417', 'Raamcedo aceclofenaco 100 mg', 2, 46.04, 'EQ-RAM092', 'RMD033'),
        ('7503006698316', 'Microdacyn 60 solución antiséptica 120 ml', 3, 154.84, 'FC-06698316', '209GD984')
      ) as t(ean, nombre, qty, costo, sku, lote)
    loop
      v_pid := null;
      if r.ean is not null then
        v_pid := public.fc_buscar_producto_escaneo(r.ean);
      end if;
      if v_pid is null then
        v_pid := public.fc_buscar_producto_escaneo(r.sku);
      end if;

      insert into public.recepcion_items (
        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
        origen, confirmado, lote_distinto, lote_id
      ) values (
        v_id, v_pid, coalesce(r.ean, r.sku), r.nombre, r.qty, null, r.lote, r.costo,
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

    raise notice 'Recepcion Levic 9012545305 lista id=% — escanear caja por caja', v_id;
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
where r.folio = '9012545305' and coalesce(r.proveedor, '') ilike '%levic%'
order by i.id;
