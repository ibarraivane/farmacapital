-- ============================================================================
-- FARMA CAPITAL — Altas de fotos + pegar EAN  16-ago-2026
--
-- 1) 5 productos que ya existen: solo se les pega el código de la foto.
-- 2) 28 presentaciones de las fotos que no tenían SKU + ezetimiba 28.
--    Costo del ticket Equilibrio 440393. Precio ceil(costo*1.6).
--    Stock = piezas del ticket.
--
-- No pisa un EAN que ya tenga valor. No crea si el SKU o el EAN
-- ya existen. Idempotente. Los 7 sin ticket se dejan fuera.
-- ============================================================================

-- 1) Pegar EAN en SKUs que ya están
update public.productos set
  codigo_barras = '7502001165397',
  activo = true
where sku = 'EQ-SON233'
  and coalesce(codigo_barras,'') = ''
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502001165397' and o.sku <> 'EQ-SON233'
  );

update public.productos set
  codigo_barras = '7501349022485',
  activo = true
where sku = 'EQ-AMS292'
  and coalesce(codigo_barras,'') = ''
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501349022485' and o.sku <> 'EQ-AMS292'
  );

update public.productos set
  codigo_barras = '7501109763986',
  activo = true
where sku = 'EQ-QUI091'
  and coalesce(codigo_barras,'') = ''
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501109763986' and o.sku <> 'EQ-QUI091'
  );

update public.productos set
  codigo_barras = '7502223111202',
  activo = true
where sku = 'EQ-QUM014'
  and coalesce(codigo_barras,'') = ''
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502223111202' and o.sku <> 'EQ-QUM014'
  );

update public.productos set
  codigo_barras = '7502226292182',
  activo = true
where sku = 'FC-6898B64F'
  and coalesce(codigo_barras,'') = ''
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502226292182' and o.sku <> 'FC-6898B64F'
  );


-- 2) Altas
do $alta$
declare
  r record;
  v_pid bigint;
begin
  for r in
    select * from (values
      -- sku, ean, nombre, categoria, tipo, presentacion, pa, forma, marca, conc, unid, costo, stock, receta
      ('EQ-AMS328'::text, '7501349024267'::text,
       'Ketorolaco 3 Amp 30 Mg'::text,
       'Analgésico'::text, 'generico'::text,
       'Caja con 3 ampolletas'::text, 'Ketorolaco'::text,
       'Solución inyectable'::text, 'AMSA'::text, '30 mg/mL'::text, 3::int,
       11.33::numeric, 3::int, true::boolean),
      ('EQ-AMS253', '7501349027329',
       'Dexametasona 1 Fa 8mg/2 Ml',
       'Antiinflamatorio', 'generico',
       'Caja con 1 ampolleta', 'Dexametasona',
       'Solución inyectable', 'AMSA', '8 mg/2 mL', 1,
       8.55, 10, true),
      ('EQ-AMS362', '7501349025929',
       'Diclofenaco 2 Fa 75mg/3 Ml',
       'Antiinflamatorio', 'generico',
       'Caja con 2 ampolletas', 'Diclofenaco',
       'Solución inyectable', 'AMSA', '75 mg/3 mL', 2,
       15.80, 2, true),
      ('EQ-BEA313', '7501342803067',
       'Dexametasona 20 Tab 1 Mg',
       'Antiinflamatorio', 'generico',
       'Caja con 20 tabletas', 'Dexametasona',
       'Tableta', 'beadvance', '1 mg', 20,
       22.25, 1, true),
      ('EQ-AMS221', '7501349025806',
       'Telmisartán 28 Tab 80 Mg',
       'Hipertensión', 'generico',
       'Caja con 28 tabletas', 'Telmisartán',
       'Tableta', 'AMSA', '80 mg', 28,
       51.70, 2, true),
      ('EQ-AMS275', '7501349024540',
       'Ezetimiba/Simvasta 28 Tab 10/20 Mg',
       'Cardiovascular', 'generico',
       'Caja con 28 tabletas', 'Ezetimiba / Simvastatina',
       'Tableta', 'AMSA', '10 mg / 20 mg', 28,
       100.08, 1, true),
      ('EQ-MAV295', '7502009746239',
       'Erispan Comp 10 Tab 5/0.25 Mg',
       'Alergia', 'generico',
       'Caja con 10 tabletas', 'Loratadina / Betametasona',
       'Tableta', 'Maver', '5 mg / 0.25 mg', 10,
       8.27, 3, true),
      ('EQ-MAV187', '7502009744129',
       'Erispan Compuesto 1 Sol 5/100mg/60 Ml',
       'Alergia', 'generico',
       'Frasco 60 mL', 'Loratadina / Betametasona',
       'Solución', 'Maver', '5 mg / 100 mg / 100 mL', null,
       22.53, 1, true),
      ('EQ-MAV318', '7502009746727',
       'Cariden 20 Tab 6 Mg',
       'Hormonales', 'generico',
       'Caja con 20 tabletas', 'Deflazacort',
       'Tableta', 'Maver', '6 mg', 20,
       52.87, 1, true),
      ('EQ-MAV134', '7502009741487',
       'Doltrix 10 Tab 250/10 Mg',
       'Analgésico', 'generico',
       'Caja con 10 tabletas', 'Clonixinato / Hioscina',
       'Tableta', 'Maver', '250 mg / 10 mg', 10,
       56.45, 2, true),
      ('EQ-MAV167', '7502009742392',
       'Doltrix 20 Tab 125/10 Mg',
       'Analgésico', 'generico',
       'Caja con 20 tabletas', 'Clonixinato / Hioscina',
       'Tableta', 'Maver', '125 mg / 10 mg', 20,
       70.30, 1, true),
      ('EQ-MAV064', '7503000422191',
       'Presistín 30 Tab 10 Mg',
       'Gastro', 'generico',
       'Caja con 30 tabletas', 'Cisaprida',
       'Tableta', 'Maver', '10 mg', 30,
       33.93, 1, true),
      ('EQ-MAV039', '7502009740435',
       'Laritol 10 Tab 10 Mg',
       'Alergia', 'marca',
       'Caja con 10 tabletas', 'Loratadina',
       'Tableta', 'Maver', '10 mg', 10,
       7.01, 5, false),
      ('EQ-MAV115', '7502009741005',
       'Laritol Ex 10 Tab 30/5 Mg',
       'Respiratorio', 'marca',
       'Caja con 10 tabletas', 'Loratadina / Ambroxol',
       'Tableta', 'Maver', '30 mg / 5 mg', 10,
       21.66, 2, false),
      ('EQ-MAV182', '7502009743856',
       'Laritol D 10 Tab 30/5 Mg',
       'Alergia', 'marca',
       'Caja con 10 tabletas', 'Fenilefrina / Loratadina',
       'Tableta liberación prolongada', 'Maver', '30 mg / 5 mg', 10,
       38.59, 2, false),
      ('EQ-MAV174', '7502009742095',
       'Flexiver Compuesto 10 Caps 215/15 Mg',
       'Antiinflamatorio', 'generico',
       'Caja con 10 cápsulas', 'Meloxicam / Metocarbamol',
       'Cápsula', 'Maver', '15 mg / 215 mg', 10,
       40.06, 1, true),
      ('EQ-MAV228', '7502009745126',
       'Cefagen 10 Tab 500 Mg',
       'Antibiótico', 'generico',
       'Caja con 10 tabletas', 'Cefuroxima',
       'Tableta', 'Maver', '500 mg', 10,
       144.13, 1, true),
      ('EQ-OFF008', '7502004401409',
       'Dexne Nasal 1 Got 10 Ml',
       'Respiratorio', 'marca',
       'Frasco 10 mL', 'Fenilefrina / Dexametasona / Neomicina',
       'Gotas nasales', 'Offenbach', '1 / 3.5 / 2.5 mg / mL', null,
       37.87, 1, true),
      ('EQ-OFF010', '7502004401454',
       'Dexne Oftálmico 1 Got 5 Ml',
       'Otro', 'marca',
       'Frasco 5 mL', 'Dexametasona / Neomicina',
       'Gotas oftálmicas', 'Offenbach', '1 mg / 3.5 mg / mL', null,
       33.74, 1, true),
      ('EQ-AVT205', '7502209858237',
       'Elaphterón 28 Tab 25 Mg',
       'Otro', 'marca',
       'Caja con 28 tabletas', 'Lamotrigina',
       'Tableta dispersable', 'Avitus', '25 mg', 28,
       25.40, 1, true),
      ('EQ-LOE155', '7502211788423',
       'Indometacina 6 Supositorios 100 Mg',
       'Antiinflamatorio', 'generico',
       'Caja con 6 supositorios', 'Indometacina',
       'Supositorio', 'Loeffler', '100 mg', 6,
       92.35, 1, true),
      ('EQ-LOE132', '7502211789277',
       'Faribrox Tm Adulto 1 Jbe 150 Ml',
       'Respiratorio', 'marca',
       'Frasco 150 mL', 'Ambroxol / Dextrometorfano',
       'Jarabe', 'Loeffler', '225 mg / 225 mg / 100 mL', null,
       23.19, 1, false),
      ('EQ-SON033', '7502001160019',
       'Busconet 1 Fa 250/20mg/5 Ml',
       'Analgésico', 'generico',
       'Caja con 1 ampolleta 5 mL', 'Hioscina / Metamizol sódico',
       'Solución inyectable', 'SON''S', '20 mg / 2.5 g / 5 mL', 1,
       33.38, 1, true),
      ('EQ-SON092', '7502001162518',
       'Meclison 1 Got 15 Ml',
       'Gastro', 'generico',
       'Frasco gotero 15 mL', 'Meclozina / Piridoxina',
       'Solución', 'SON''S', '8.33 mg / 16.66 mg / mL', null,
       21.20, 1, false),
      ('EQ-FAC0058', '7502006921974',
       'Farmiver Junior 1 Susp 200/400mg/20 Ml',
       'Otro', 'marca',
       'Frasco 20 mL', 'Quinfamida / Albendazol',
       'Suspensión', 'Fármacos Continentales', '200 mg / 400 mg / 20 mL', null,
       24.72, 1, true),
      ('EQ-SER093', '7501258206723',
       'Oxital-C 10 Comp 1 G',
       'Vitaminas', 'marca',
       'Tubo con 10 comprimidos efervescentes', 'Ácido ascórbico',
       'Tableta efervescente', 'Serral', '1000 mg', 10,
       45.14, 3, false),
      ('EQ-ALP0628', '7502226293776',
       'Metamizol Sódico 3 Amp 1g/2 Ml',
       'Analgésico', 'generico',
       'Caja con 3 ampolletas', 'Metamizol sódico',
       'Solución inyectable', 'Alpharma', '1 g / 2 mL', 3,
       14.68, 2, true),
      ('EQ-MAI142', '785118753955',
       'Figral 10 Tab 50 Mg',
       'Otro', 'marca',
       'Caja con 10 tabletas', 'Sildenafil',
       'Tableta', 'MAVI', '50 mg', 10,
       46.41, 5, true),
      ('EQ-PGE033', '7503008344785',
       'Gelubrín 10 Caps 400 Mg',
       'Analgésico', 'generico',
       'Caja con 10 cápsulas', 'Ibuprofeno',
       'Cápsula', 'Gelubrín', '400 mg', 10,
       15.21, 5, false)
    ) as t(
      sku, ean, nombre, categoria, tipo,
      presentacion, pa, forma, marca, conc,
      unid, costo, stock, receta
    )
  loop
    v_pid := null;
    select id into v_pid from public.productos
     where sku = r.sku or codigo_barras = r.ean
     limit 1;
    if v_pid is not null then
      raise notice 'YA EXISTÍA % (id %)', r.sku, v_pid;
      continue;
    end if;

    insert into public.productos (
      nombre, sku, codigo_barras, categoria, tipo,
      presentacion, principio_activo, denominacion_generica,
      forma_farmaceutica, marca, concentracion, unidades_por_caja,
      costo, precio, stock, stock_minimo, activo, requiere_receta
    ) values (
      r.nombre, r.sku, r.ean, r.categoria, r.tipo,
      r.presentacion, r.pa, r.pa,
      r.forma, r.marca, r.conc, r.unid,
      r.costo, ceil(r.costo * 1.6),
      r.stock, 1, true, r.receta
    );
    raise notice 'CREADO %', r.sku;
  end loop;
end
$alta$;


select sku, nombre, codigo_barras, costo, precio, stock, activo
from public.productos
where sku in (
  'EQ-SON233','EQ-AMS292','EQ-QUI091','EQ-QUM014','FC-6898B64F',
  'EQ-AMS328','EQ-AMS253','EQ-AMS362','EQ-BEA313','EQ-AMS221','EQ-AMS275',
  'EQ-MAV295','EQ-MAV187','EQ-MAV318','EQ-MAV134','EQ-MAV167','EQ-MAV064',
  'EQ-MAV039','EQ-MAV115','EQ-MAV182','EQ-MAV174','EQ-MAV228',
  'EQ-OFF008','EQ-OFF010','EQ-AVT205','EQ-LOE155','EQ-LOE132',
  'EQ-SON033','EQ-SON092','EQ-FAC0058','EQ-SER093','EQ-ALP0628',
  'EQ-MAI142','EQ-PGE033'
)
order by sku;
