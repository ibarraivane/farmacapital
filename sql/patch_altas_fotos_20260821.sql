-- ============================================================================
-- Altas / recepción de las fotos de mostrador 21-ago-2026
--
-- Un solo archivo. Idempotente: si el lote ya está, no suma otra vez.
-- Si ya corriste los patch_alta_* sueltos de hoy, este no duplica stock.
-- Ejecutar en Supabase SQL Editor (archivo completo).
-- No escribir productos.proveedor (esa columna no existe).
--
--  1. Laritol 10 mg C/10 Maver              7502009740435  lote 257226   5 pza
--  2. Popram 14 tab 40 mg AMSA              7501349028364  lote U25N288  2 pza
--  3. Elevit 1 C/30 Bayer                   7501008497623  lote 476244   1 pza
--  4. Laritol D inf jarabe 50 mL            7502009741784  lote 262393   1 pza
--  5. Ampigrin PFC jarabe 60 mL Collins     780083148577   lote 26140890 1 pza
--  6. Broncolin Etiqueta Verde 140 mL       714706910609   lote JEVZ03466 1 pza
--  7. Aguja SensiMedical 22G x 32 mm C/100  7506022304124  lote 2411816005 100 pza
--  8. Perilla Edigar N1 (jeringa pera)      2008480100010  INTERNO sticker
--  9. Copa lavaojos de vidrio               2008490100017  INTERNO sticker
-- 10. Velázquez alcanfor pastillas          753048936018  SOLO ficha (cad 02.2023 VENCIDA)
--
-- Culminax pediátrico 250 mg/5 mL chabacano 150 mL: SIN código en las fotos.
--   No se da de alta. No uses el del adulto 7502009747779.
--
-- Códigos 20… son sticker de tienda (prefijo GS1 20), no GTIN de fábrica.
-- Pegar etiqueta en la caja / copa. Distintos del rastrillo 2008470100013.
-- ============================================================================

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_lid bigint;
begin
  for r in
    select * from (values
      -- ean, sku, alt_sku, nombre, marca, presentacion, forma, principio,
      -- concentracion, categoria, tipo, descripcion, costo, precio, qty,
      -- lote, cad, receta, stock_min, patron, modo
      -- modo: receive | barcode_only | catalog_no_stock
      (
        '7502009740435'::text, 'EQ-MAV039'::text, 'FC-09740435'::text,
        'Laritol loratadina 10 mg C/10'::text, 'Maver'::text,
        'Caja con 10 tabletas'::text, 'Tabletas'::text, 'Loratadina'::text, '10 mg'::text,
        'Alergia'::text, 'marca'::text,
        'Fotos 20260821 · Equilibrio 440393 MAV039 · EAN 7502009740435'::text,
        7.01::numeric, 12::numeric, 5::integer,
        '257226'::text, '2027-12-01'::date, false, 2,
        '%laritol%10%tab%'::text, 'receive'::text
      ),
      (
        '7501349028364', 'EQ-AMS279', 'FC-49028364',
        'Popram pantoprazol 40 mg C/14', 'AMSA',
        'Caja con 14 tabletas', 'Tabletas', 'Pantoprazol', '40 mg',
        'Gastro', 'generico',
        'Fotos 20260821 · Equilibrio 440393 AMS279 · EAN 7501349028364 · ≠ C/28 7501349028845 EQ-AMS498',
        26.26, 43, 2,
        'U25N288', '2027-11-01'::date, false, 1,
        '%popram%14%', 'receive'
      ),
      (
        '7501008497623', 'FC-08497623', null,
        'Elevit 1 comprimidos C/30', 'Bayer',
        'Caja con 30 comprimidos', 'Comprimido', null, null,
        'Vitaminas', 'marca',
        'Fotos 20260821 · Bayer Elevit 1 · lote 476244 · PMP caja $569.04 · costo $350',
        350, 560, 1,
        '476244', '2027-10-01'::date, false, 1,
        '%elevit%1%', 'receive'
      ),
      (
        '7502009741784', 'EQ-MAV118', null,
        'Laritol D infantil jarabe 50 mL', 'Maver',
        'Frasco 50 mL', 'Jarabe', 'Loratadina / Fenilefrina', '100 mg / 50 mg / 5 mL',
        'Alergia', 'marca',
        'Fotos 20260821 · Equilibrio 440393 MAV118 · EAN 7502009741784 · PMP $132 · ≠ Laritol 10 mg ni D tabs',
        26.44, 43, 1,
        '262393', '2028-04-01'::date, false, 1,
        '%laritol%d%jarabe%', 'receive'
      ),
      (
        '780083148577', 'EQ-COL213', null,
        'Ampigrin PFC jarabe infantil 60 mL', 'Collins',
        'Frasco 60 mL', 'Jarabe', null, '3 g / 0.50 g / 0.02 g / 60 mL',
        'Antibiótico', 'marca',
        'Fotos 20260821 · Equilibrio 440393 COL213 · UPC 780083148577 · PMP $162.63 · receta. ≠ Culminax. ≠ Ampigrin inyectable.',
        24.91, 40, 1,
        '26140890', '2028-04-01'::date, true, 1,
        '%ampigrin%pfc%', 'receive'
      ),
      (
        '714706910609', 'FC-06910609', 'FL-6910609',
        'Broncolin Etiqueta Verde jarabe oral 140 mL', 'Broncolin',
        'Frasco 140 mL', 'Jarabe', null, null,
        'Herbolario', 'marca',
        'Fotos 20260821 · lote JEVZ03466 · PMP $145.50 · costo Farmalive $74.28 · ≠ Etiqueta Azul 714706100307',
        74.28, 119, 1,
        'JEVZ03466', '2029-06-01'::date, false, 1,
        '%broncolin%verde%', 'receive'
      ),
      (
        '7506022304124', 'FMX-504321', 'FC-22304124',
        'Aguja hipodérmica SensiMedical 22G x 32 mm', 'SensiMedical',
        'Caja con 100 piezas · venta por pieza', 'Aguja hipodérmica', null, '22G x 32 mm',
        'Dispositivo médico', 'marca',
        'Fotos 20260821 · Farma MX 504321 · EAN 7506022304124 · lote 2411816005 · Reg. 1014C2017 SSA · ≠ jeringas',
        0.55, 1, 100,
        '2411816005', '2029-11-30'::date, false, 20,
        '%aguja%22%32%', 'receive'
      ),
      (
        '2008480100010', 'FC-BCF59548', null,
        'Perilla Edigar N1 (jeringa pera toda de hule)', 'Edigar',
        'Caja No. 1 · 1 pieza de hule', 'Perilla / jeringa pera', null, 'No. 1',
        'Botiquín', 'marca',
        'Fotos 20260821 · Edigar jeringa pera toda de hule No. 1. Codigo INTERNO 2008480100010 (prefijo 20, sticker). Ya existía SKU FC-BCF59548 sin EAN. Costo IFC $15.50. ≠ N0/N2–N6.',
        15.50, 25, 1,
        'S/L', null::date, false, 2,
        '%perilla%n1%', 'barcode_only'
      ),
      (
        '2008490100017', 'IFC-LAVAOJOS', 'FC-49010001',
        'Copa lavaojos de vidrio', 'Arfam',
        '1 copa de vidrio', 'Copa lavaojos', null, null,
        'Botiquín', 'marca',
        'Fotos 20260821 · copa lavaojos vidrio, sin marca ni EAN de fábrica. Codigo INTERNO 2008490100017 (prefijo 20, sticker). Costo IFC $11.',
        11.00, 18, 1,
        'S/L', null::date, false, 1,
        '%lava%ojo%', 'barcode_only'
      ),
      (
        '753048936018', 'IFC-ALCANFOR', null,
        'Velázquez alcanfor pastillas C/50 sobres', 'Velázquez',
        'Caja con 50 sobres', 'Pastillas', 'Alcanfor', null,
        'Botiquín', 'marca',
        'Fotos 20260821 · EAN/UPC de caja 753048936018 · cad impresa 02.2023 VENCIDA. NO recibir lote a anaquel. Desechar la pieza física.',
        127.50, 204, 0,
        null, null::date, false, 0,
        '%alcanfor%pastilla%', 'catalog_no_stock'
      )
    ) as t(
      ean, sku, alt_sku, nombre, marca, presentacion, forma, principio,
      concentracion, categoria, tipo, descripcion, costo, precio, qty,
      lote, cad, receta, stock_min, patron, modo
    )
  loop
    v_pid := null;
    v_lid := null;

    select p.id into v_pid
    from public.productos p
    where p.codigo_barras = r.ean
       or p.sku = r.sku
       or (r.alt_sku is not null and p.sku = r.alt_sku)
       or (
         r.patron is not null
         and p.nombre ilike r.patron
         -- Popram 14 no debe caer en el de 28
         and not (r.sku = 'EQ-AMS279' and p.nombre ilike '%28%')
         -- Laritol 10 mg no debe caer en EX / D / jarabe
         and not (
           r.sku = 'EQ-MAV039'
           and (
             p.nombre ilike '% ex%'
             or p.nombre ilike '%laritol d%'
             or p.nombre ilike '%jarabe%'
             or p.nombre ilike '%soluci%'
           )
         )
         -- Agujas, no jeringas
         and not (r.sku = 'FMX-504321' and p.nombre ilike '%jeringa%')
         -- Perilla N1, no N10 ni otras tallas
         and not (
           r.sku = 'FC-BCF59548'
           and (
             p.nombre ilike '%n2%'
             or p.nombre ilike '%n3%'
             or p.nombre ilike '%n4%'
             or p.nombre ilike '%n5%'
             or p.nombre ilike '%n6%'
             or p.nombre ilike '%n 0%'
             or p.nombre ilike '%n0%'
           )
         )
       )
    order by case
      when p.codigo_barras = r.ean then 0
      when p.sku = r.sku then 1
      when r.alt_sku is not null and p.sku = r.alt_sku then 2
      else 3
    end, p.id
    limit 1;

    if v_pid is null then
      if r.modo = 'catalog_no_stock' then
        select f.producto_id into v_pid
        from public.create_producto_with_lote(
          jsonb_build_object(
            'nombre', r.nombre,
            'sku', r.sku,
            'codigo_barras', r.ean,
            'categoria', r.categoria,
            'tipo', r.tipo,
            'descripcion', r.descripcion,
            'costo', r.costo,
            'precio', r.precio,
            'stock_minimo', r.stock_min,
            'activo', true,
            'requiere_receta', r.receta
          ),
          0,
          null,
          null::date,
          r.costo,
          null::bigint
        ) f;
        raise notice 'FICHA (sin stock) % sku % ean % id %', r.nombre, r.sku, r.ean, v_pid;
      else
        select f.producto_id, f.lote_id into v_pid, v_lid
        from public.create_producto_with_lote(
          jsonb_build_object(
            'nombre', r.nombre,
            'sku', r.sku,
            'codigo_barras', r.ean,
            'categoria', r.categoria,
            'tipo', r.tipo,
            'descripcion', r.descripcion,
            'costo', r.costo,
            'precio', r.precio,
            'stock_minimo', r.stock_min,
            'activo', true,
            'requiere_receta', r.receta
          ),
          r.qty,
          r.lote,
          r.cad,
          r.costo,
          null::bigint
        ) f;
        raise notice 'CREADO % sku % ean % id % lote %', r.nombre, r.sku, r.ean, v_pid, v_lid;
      end if;
    else
      -- Producto ya estaba: pegar EAN si faltaba. No inventar 750… encima de un GTIN real.
      update public.productos set
        codigo_barras = r.ean
      where id = v_pid
        and (codigo_barras is null or btrim(codigo_barras) = '');

      if r.modo = 'receive' then
        if exists (
          select 1 from public.lotes l
          where l.producto_id = v_pid
            and l.numero_lote = r.lote
            and coalesce(l.activo, true)
        ) then
          if r.cad is not null then
            update public.lotes set
              fecha_caducidad = r.cad
            where producto_id = v_pid
              and numero_lote = r.lote
              and (fecha_caducidad is null or fecha_caducidad <> r.cad);
          end if;
          raise notice 'SKIP recibir % lote % ya existe (id %)', r.nombre, r.lote, v_pid;
        else
          select f.lote_id into v_lid
          from public.receive_merchandise_lote(
            v_pid, r.qty, r.lote, r.cad, r.costo,
            null, null::bigint
          ) f;
          raise notice 'RECIBIDO % id % lote %', r.nombre, v_pid, v_lid;
        end if;

        update public.productos set
          costo = r.costo,
          precio = r.precio,
          stock_minimo = greatest(coalesce(stock_minimo, 0), r.stock_min)
        where id = v_pid
          and coalesce(costo, 0) <= r.costo + 0.01;
      elsif r.modo = 'barcode_only' then
        raise notice 'CODIGO pegado % sku existente id % ean % (no suma stock)', r.nombre, v_pid, r.ean;
      elsif r.modo = 'catalog_no_stock' then
        raise notice 'FICHA alcanfor id % ean % — NO recibir cad 02.2023', v_pid, r.ean;
      end if;
    end if;

    update public.productos set
      nombre = case
        when r.sku = 'FC-BCF59548' then r.nombre
        when r.sku = 'IFC-LAVAOJOS' then r.nombre
        else nombre
      end,
      sku = coalesce(nullif(sku, ''), r.sku),
      marca = coalesce(nullif(marca, ''), r.marca),
      presentacion = coalesce(nullif(presentacion, ''), r.presentacion),
      forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), r.forma),
      principio_activo = coalesce(nullif(principio_activo, ''), r.principio),
      concentracion = coalesce(nullif(concentracion, ''), r.concentracion),
      categoria = coalesce(nullif(categoria, ''), r.categoria),
      tipo = r.tipo,
      requiere_receta = r.receta
    where id = v_pid;
  end loop;

  raise notice 'Culminax pediatrico 250 mg/5 mL: SIN EAN en fotos; no se alta. No uses 7502009747779 (adulto).';
end $$;

commit;

select
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.marca,
  p.categoria,
  p.costo,
  p.precio,
  p.stock,
  p.requiere_receta,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras in (
    '7502009740435', '7501349028364', '7501008497623', '7502009741784',
    '780083148577', '714706910609', '7506022304124',
    '2008480100010', '2008490100017', '753048936018'
  )
   or p.sku in (
    'EQ-MAV039', 'EQ-AMS279', 'FC-08497623', 'EQ-MAV118', 'EQ-COL213',
    'FC-06910609', 'FL-6910609', 'FMX-504321',
    'FC-BCF59548', 'IFC-LAVAOJOS', 'IFC-ALCANFOR'
  )
order by p.sku, l.fecha_caducidad;
