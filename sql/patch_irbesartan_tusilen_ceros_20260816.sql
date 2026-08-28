-- ============================================================================
-- FARMA CAPITAL — Irbesartán 300 / Tusilen ped + ceros  16-ago-2026
--
-- 1) Los dos EAN que pediste NO estaban. Se dan de alta con el ticket
--    Equilibrio 440393 (costo del ticket, precio ceil 60% genérico /
--    30% marca como el Tusilen adulto).
-- 2) 8 productos activos con costo 0 y precio 0: se llena desde el
--    mismo CSV. Mornin (Omeprazol 40) no viene en ningún ticket — se deja.
-- 3) Ixicrol fantasma (stock 0): el EAN pasa a EQ-NOV092 (ya tiene
--    costo/precio/stock) y el fantasma se apaga.
--
-- No pisa un costo o precio que ya tenga valor. Idempotente.
-- ============================================================================

-- 1) Altas que faltaban
do $alta$
declare
  v_id bigint;
begin
  -- Irbesartán 300 mg C/14 AMSA · foto 0026 · ticket AMS424 · $76.49
  v_id := null;
  select id into v_id from public.productos
   where codigo_barras = '7501349020535' or sku = 'EQ-AMS424'
   limit 1;
  if v_id is null then
    insert into public.productos (
      nombre, sku, codigo_barras, categoria, tipo,
      presentacion, principio_activo, denominacion_generica,
      forma_farmaceutica, marca, concentracion, unidades_por_caja,
      costo, precio, stock, stock_minimo, activo, requiere_receta
    ) values (
      'Irbesartán 300 mg C/14 AMSA',
      'EQ-AMS424', '7501349020535', 'Hipertensión', 'generico',
      'Caja con 14 tabletas', 'Irbesartán', 'Irbesartán',
      'Tableta', 'AMSA', '300 mg', 14,
      76.49, ceil(76.49 * 1.6), 1, 1, true, true
    );
    raise notice 'CREADO EQ-AMS424 Irbesartán 300';
  else
    raise notice 'YA EXISTÍA Irbesartán 300 (id %)', v_id;
  end if;

  -- Tusilen pediátrico 118 mL Avitus · foto 0104 · ticket AVT135 · $24.89
  v_id := null;
  select id into v_id from public.productos
   where codigo_barras = '7502209810358' or sku = 'EQ-AVT135'
   limit 1;
  if v_id is null then
    insert into public.productos (
      nombre, sku, codigo_barras, categoria, tipo,
      presentacion, principio_activo, denominacion_generica,
      forma_farmaceutica, marca, concentracion,
      costo, precio, stock, stock_minimo, activo, requiere_receta
    ) values (
      'Tusilen pediátrico jarabe 118 mL',
      'EQ-AVT135', '7502209810358', 'Respiratorio', 'marca',
      'Frasco 118 mL', 'Dextrometorfano / Guaifenesina / Paracetamol',
      'Dextrometorfano / Guaifenesina / Paracetamol',
      'Jarabe', 'Avitus', '300/120/15 mg / 100 mL',
      24.89, ceil(24.89 * 1.3), 1, 1, true, false
    );
    raise notice 'CREADO EQ-AVT135 Tusilen pediátrico';
  else
    raise notice 'YA EXISTÍA Tusilen pediátrico (id %)', v_id;
  end if;
end
$alta$;


-- 2) Ceros: solo si costo y precio siguen en 0
update public.productos set
  costo = 48.22,
  precio = ceil(48.22 * 1.6)
where sku = 'FC-09745027'                          -- Galaver 250 mL · MAV250
  and coalesce(costo,0) = 0 and coalesce(precio,0) = 0;

update public.productos set
  costo = 40.91,
  precio = ceil(40.91 * 1.6)
where sku = 'FC-18754259'                          -- Supratex jarabe · MAI157
  and coalesce(costo,0) = 0 and coalesce(precio,0) = 0;

update public.productos set
  costo = 70.37,
  precio = ceil(70.37 * 1.6)
where sku = 'FC-23111387'                          -- Drosequim infantil · QUM069
  and coalesce(costo,0) = 0 and coalesce(precio,0) = 0;

update public.productos set
  costo = 21.00,
  precio = ceil(21.00 * 1.6)
where sku = 'FC-49024151'                          -- Metoclopramida 6 amp · AMS418
  and coalesce(costo,0) = 0 and coalesce(precio,0) = 0;

update public.productos set
  costo = 18.36,
  precio = ceil(18.36 * 1.6)
where sku = 'FC-49024175'                          -- Pioglitazona 30 mg · AMS401
  and coalesce(costo,0) = 0 and coalesce(precio,0) = 0;

update public.productos set
  costo = 25.09,
  precio = ceil(25.09 * 1.6)
where sku = 'FC-49025967'                          -- Pregabalina 14 · AMS231
  and coalesce(costo,0) = 0 and coalesce(precio,0) = 0;

update public.productos set
  costo = 25.48,
  precio = ceil(25.48 * 1.6)
where sku = 'FC-90973703'                          -- Ampicilina 1 g FA · AMS375
  and coalesce(costo,0) = 0 and coalesce(precio,0) = 0;


-- 3) Ixicorl: el bueno es EQ-NOV092 (stock 2, $21.72 / $35).
--    El FC- tiene el EAN y stock 0.
update public.productos set codigo_barras = null
where sku = 'FC-75718041' and codigo_barras = '7501075718041';

update public.productos set
  codigo_barras = case when coalesce(codigo_barras,'') = '' then '7501075718041' else codigo_barras end,
  activo = true
where sku = 'EQ-NOV092';

update public.productos set activo = false
where sku = 'FC-75718041' and coalesce(stock,0) = 0;


select sku, nombre, codigo_barras, costo, precio, stock, activo
from public.productos
where sku in (
  'EQ-AMS424','EQ-AVT135','FC-262F2A30','FC-1DAD5EF1',
  'FC-09745027','FC-18754259','FC-23111387','FC-49024151',
  'FC-49024175','FC-49025967','FC-90973703','EQ-NOV092',
  'FC-75718041','FC-01162365'
)
order by sku;
