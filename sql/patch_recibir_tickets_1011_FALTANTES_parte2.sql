-- ========== Farmalive 16337 ==========
-- Farmalive · folio 16337 · 2026-11-10 · total $1,912.97 · 18 renglones · costo neto
-- 11 alta(s) stock 0. 7 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_fl_16337 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text
) on commit drop;

insert into _fc_fl_16337 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen
) values
  (1, '6502400315021', 'FC-00315021', 'Tukol-D jarabe infantil', 'TUKOL D JBE INF 120 ML', 2, 129.75, 163, 'marca', 'Medicamentos', null, 'Jarabe', 'Tukol-D', 'Genomma', 'Frasco 120 ml', 'Guaifenesina / Dextrometorfano', null, false, true, null),
  (2, '3614225108785', 'FC-25108785', 'Koleston 50 castaño claro', 'TINTE KOLESTON # 50 CASTANO CLARO', 1, 53.20, 67, 'marca', 'Cuidado personal', 'Cabello', 'Tinte', 'Koleston', 'Wella / HFC', 'Kit', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/koleston-50-castano-claro.jpg'),
  (3, '7501298219370', 'FC-98219370', 'Iliadin Lub spray infantil', 'ILIADIN LUB SPRAY INF 20 ML', 3, 144.06, 181, 'marca', 'Medicamentos', null, 'Spray', 'Iliadin', 'P&G Health', 'Frasco 20 ml', null, null, false, false, null),
  (4, '7502208894779', 'FC-08894779', 'Tribedoce', 'TRIBEDOCE TAB C/30 NVO', 5, 17.64, 23, 'marca', 'Vitaminas', null, 'Tabletas', 'Tribedoce', 'Bruluart', 'Caja con 30 tabletas', 'Tiamina / Piridoxina / Cianocobalamina', null, false, true, null),
  (5, '7502304290246', 'FC-04290246', 'GUM kit viaje infantil Bob Esponja', 'KIT VIAJE GUM INF BOB ESPONJA 3 PZAS', 2, 42.83, 54, 'marca', 'Cuidado personal', 'Higiene bucal', 'Kit', 'GUM', 'Sunstar', '3 piezas', null, null, false, false, null),
  (6, '070942125352', 'FC-42125352', 'GUM kit de ortodoncia', 'CEPILLO GUM KIT DE ORTODONCIA 6 PZ', 1, 115.74, 145, 'marca', 'Cuidado personal', 'Higiene bucal', 'Kit', 'GUM', 'Sunstar', '6 piezas', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/gum-kit-ortodoncia-6pzas-070942125352.jpg'),
  (7, '070942303194', 'FC-42303194', 'GUM hilo dental 128 m', 'HILO DENTAL GUM 128 MTS', 1, 50.37, 63, 'marca', 'Cuidado personal', 'Higiene bucal', 'Hilo dental', 'GUM', 'Sunstar', '128 m', null, null, false, false, null),
  (8, '7501008491140', 'FC-08491140', 'Tabcin Pods Active', 'TABCIN PODS ACTIVE CAPS C/12 2PACK', 2, 117.60, 147, 'marca', 'Medicamentos', null, 'Cápsulas', 'Tabcin', 'Bayer', '2 packs con 12 cápsulas', null, null, false, false, null),
  (9, '070942302357', 'FC-42302357', 'GUM capuchones para cepillos', 'CAPUCHONES GUM P/CEPILLOS C/4', 1, 27.34, 35, 'marca', 'Cuidado personal', 'Higiene bucal', 'Accesorio', 'GUM', 'Sunstar', 'Caja con 4', null, null, false, false, null),
  (10, '7501007533896', 'FC-07533896', 'Cotonetes Johnson''s', 'COTONETES JOHNSON''S BOLSA C/150', 2, 28.03, 36, 'marca', 'Cuidado personal', null, 'Hisopos', 'Johnson''s', 'Kenvue', 'Bolsa con 150', null, null, false, false, null),
  (11, '7501033953361', 'FC-33953361', 'Ensure polvo chocolate', 'ENSURE PVO CHOCOLATE 400 GR', 1, 281.06, 352, 'marca', 'Vitaminas', 'Nutrición', 'Polvo', 'Ensure', 'Abbott', 'Lata 400 g', null, null, false, false, null),
  (12, '759684272103', 'FC-84272103', 'Cotonetes Kiuts', 'COTONETES KIUTS BOTE C/100', 5, 12.19, 16, 'marca', 'Cuidado personal', null, 'Hisopos', 'Kiuts', 'Jaloma', 'Bote con 100', null, null, false, false, null),
  (13, '759684273094', 'FC-84273094', 'Cotonetes Kiuts', 'COTONETES KIUTS BOTE C/50', 2, 6.92, 9, 'marca', 'Cuidado personal', null, 'Hisopos', 'Kiuts', 'Jaloma', 'Bote con 50', null, null, false, false, null),
  (14, '7501125174797', 'FC-25174797', 'Electrolit mora azul', 'ELECTROLIT MORA AZUL 625 ML', 2, 19.60, 25, 'marca', 'Suero', null, 'Solución', 'Electrolit', 'Pisa', 'Botella 625 ml', null, null, false, true, null),
  (15, '7501125187179', 'FC-25187179', 'Electrolit guayaba', 'ELECTROLIT GUAYABA 625 ML', 1, 19.60, 25, 'marca', 'Suero', null, 'Solución', 'Electrolit', 'Pisa', 'Botella 625 ml', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/electrolit-guayaba-625ml-7501125187179.jpg'),
  (16, '7501125149221', 'FC-25149221', 'Electrolit fresa-kiwi', 'ELECTROLIT FRESA-KIWI 625 ML', 2, 19.60, 25, 'marca', 'Suero', null, 'Solución', 'Electrolit', 'Pisa', 'Botella 625 ml', null, null, false, true, null),
  (17, '714706918964', 'FC-06918964', 'Properlas propóleo y eucalipto', 'PROPERLAS PROPOLEO Y EUCALIPTO 50 G', 1, 27.83, 35, 'marca', 'Medicamentos', null, 'Pastillas', 'Properlas', 'Broncolin', '50 g', null, null, false, false, null),
  (18, '714706918940', 'FC-06918940', 'Properlas propóleo y jengibre', 'PROPERLAS BRONCOLIN PROP Y JENGIBRE 50GR', 1, 27.83, 35, 'marca', 'Medicamentos', null, 'Pastillas', 'Properlas', 'Broncolin', '50 g', null, null, false, false, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.ean is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Farmalive 16337 · 2026-11-10 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_fl_16337
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_fl_16337
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = case
    when t.ean is not null then coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
    else p.codigo_barras
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_fl_16337
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '16337',
  '2026-11-10',
  1912.97,
  'borrador',
  'Farmalive Club Iztapalapa 1 · ticket 16337 · 10-nov-2026 18:31 · subtotal $1,973 − descuento $60.03 = $1,912.97 · costo = P.U. neto · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '16337'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 1912.97,
  fecha = '2026-11-10',
  proveedor = 'Farmalive',
  notas = 'Farmalive Club Iztapalapa 1 · ticket 16337 · 10-nov-2026 18:31 · subtotal $1,973 − descuento $60.03 = $1,912.97 · costo = P.U. neto · cola Recibir',
  updated_at = now()
where folio = '16337'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '16337'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  coalesce(nullif(btrim(t.ean), ''), t.sku),
  t.nombre,
  t.qty,
  null,
  null,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_fl_16337 t
join public.recepciones r
  on r.folio = '16337'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '16337'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_fl_16337 t
order by t.linea;

commit;


-- ========== Bodega F-42 28786 ==========
-- Bodega F-42 · folio 28786 · 2026-11-10 · total $2,319.12 · 43 renglones · P.U. con IVA
-- 40 alta(s) stock 0. 3 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_bf42_28786 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text
) on commit drop;

insert into _fc_bf42_28786 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen
) values
  (1, '7506306209862', 'FC-06209862', 'Axe Anarchy Fresh Love for Her spray 150 ml', 'DEO AXE SPY 150ML 48H ANARCHY FRESH LOVE FOR HER', 1, 45.83, 58, 'marca', 'Cuidado personal', null, 'Spray', 'Axe', 'Unilever', '150 ml', null, null, false, false, null),
  (2, '7506306213081', 'FC-06213081', 'Axe Music Fresh spray 150 ml', 'DESOD AXE MUSIC FRES 48H SPY150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', null, 'Spray', 'Axe', 'Unilever', '150 ml', null, null, false, false, null),
  (3, '7506306209855', 'FC-06209855', 'Axe Anarchy for Her spray 150 ml', 'DESOD AXE ANARC FLO 48H SPY 150ML', 1, 45.83, 58, 'marca', 'Cuidado personal', null, 'Spray', 'Axe', 'Unilever', '150 ml', null, null, false, false, null),
  (4, '7506306245686', 'FC-06245686', 'Axe Epic Fresh spray 150 ml', 'DESOD AXE MEN EPIC-F 48H SPY 150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', null, 'Spray', 'Axe', 'Unilever', '150 ml', null, null, false, false, null),
  (5, '7506306251847', 'FC-06251847', 'Axe Black Remix spray 210 ml', 'DESOD AXE BLACK REMIX SPY 210 ML', 1, 68.73, 86, 'marca', 'Cuidado personal', null, 'Spray', 'Axe', 'Unilever', '210 ml', null, null, false, false, null),
  (6, '7791293025810', 'FC-93025810', 'Axe Fusion spray 150 ml', 'DESOD AXE MEN FUSION SPY 150ML', 1, 45.83, 58, 'marca', 'Cuidado personal', null, 'Spray', 'Axe', 'Unilever', '150 ml', null, null, false, false, null),
  (7, '7509546073767', 'FC-46073767', 'Stefano Black spray 113 g', 'DESOD STEFANO BLACK SPY 113G', 1, 61.18, 77, 'marca', 'Cuidado personal', null, 'Spray', 'Stefano', null, '113 g', null, null, false, false, null),
  (8, '7506306250604', 'FC-06250604', 'Axe Dark Temptation spray 210 ml', 'DESOD AXE MEN DARK TEM SPY 210ML', 1, 68.73, 86, 'marca', 'Cuidado personal', null, 'Spray', 'Axe', 'Unilever', '210 ml', null, null, false, false, null),
  (9, '7506306244795', 'FC-06244795', 'Axe Intense spray 150 ml', 'DESOD AXE INTENSE 48H SPY 150ML', 1, 45.83, 58, 'marca', 'Cuidado personal', null, 'Spray', 'Axe', 'Unilever', '150 ml', null, null, false, false, null),
  (10, '7791293025780', 'FC-93025780', 'Axe Apollo spray 150 ml', 'DESOD AXE MEN APOLLO SPY 150ML', 1, 45.83, 58, 'marca', 'Cuidado personal', null, 'Spray', 'Axe', 'Unilever', '150 ml', null, null, false, false, null),
  (11, '7509546694702', 'FC-46694702', 'Stefano Next Level spray 150 ml', 'DESOD STEFANO NEXT LEVEL SPY150MLN', 1, 61.18, 77, 'marca', 'Cuidado personal', null, 'Spray', 'Stefano', null, '150 ml', null, null, false, false, null),
  (12, '7791293025803', 'FC-93025803', 'Axe Excite spray 150 ml', 'DESOD AXE MEN EXCITE SPY 150ML', 1, 45.83, 58, 'marca', 'Cuidado personal', null, 'Spray', 'Axe', 'Unilever', '150 ml', null, null, false, false, null),
  (13, '8700216334655', 'FC-16334655', 'Old Spice Wolfthorn stick 50 g', 'OLD SPICE 50GR STICK WOLFTHORN', 2, 56.20, 71, 'marca', 'Cuidado personal', null, 'Stick', 'Old Spice', 'P&G', '50 g', null, null, false, false, null),
  (14, '7506309806068', 'FC-09806068', 'Old Spice Fresh gel 80 g', 'DESOD OLD SPICE FRESH-GEL80G', 2, 69.70, 88, 'marca', 'Cuidado personal', null, 'Gel', 'Old Spice', 'P&G', '80 g', null, null, false, false, null),
  (15, '810120501628', 'FC-20501628', 'Grisi Control Azufre jabón 100 g', 'JBN GRISI CONTROL AZUFRE 100 G', 1, 40.40, 51, 'marca', 'Cuidado personal', 'Piel', 'Jabón', 'Grisi', null, '100 g', null, null, false, false, null),
  (16, '7503014119032', 'FC-14119032', 'Jabón de azufre con miel 80 g', 'AZUFRE JABON C MIEL 80 GR', 1, 15.06, 19, 'marca', 'Cuidado personal', 'Piel', 'Jabón', 'Azufre', null, '80 g', null, null, false, false, null),
  (17, '7505514121782', 'FC-14121782', 'Jabón proteína de arroz y concha nácar 80 g', 'JABON DE PROTEINA DE ARROZ Y CONCHA NACAR 80GR', 1, 17.78, 23, 'marca', 'Cuidado personal', 'Piel', 'Jabón', 'Concha Nácar', null, '80 g', null, null, false, false, null),
  (18, '850040940121', 'FC-40940121', 'Grisi Agua de Rosas jabón 125 g', 'GRISI 125GR JBN AGUA ROSAS SUAV', 1, 21.72, 28, 'marca', 'Cuidado personal', 'Piel', 'Jabón', 'Grisi', null, '125 g', null, null, false, false, null),
  (19, '7501022150818', 'FC-22150818', 'Grisi Concha Nácar jabón 125 g', 'JBN GRISI CONCHA NACAR 125G', 1, 21.72, 28, 'marca', 'Cuidado personal', 'Piel', 'Jabón', 'Grisi', null, '125 g', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/grisi-concha-nacar-jabon-125g.jpg'),
  (20, '7501027278487', 'FC-27278487', 'Obao Fresquísima roll-on 65 g', 'DESOD OBAO FRESC SVE R-ON 65G', 1, 30.71, 39, 'marca', 'Cuidado personal', null, 'Roll-on', 'Obao', null, '65 g', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/obao-fresquissima-rollon-65g.jpg'),
  (21, '7509552876284', 'FC-52876284', 'Obao Dermo Niacinamida roll-on 65 g', 'DEO OBAO ROLL 65GR DERMO NIACINAMID', 1, 27.63, 35, 'marca', 'Cuidado personal', null, 'Roll-on', 'Obao', null, '65 g', null, null, false, false, null),
  (22, '75076221', 'FC-AXE-EPIC-ST', 'Axe Epic Fresh stick 45 g', 'DESOD AXE MEN EPIC-F 48H STICK 45G', 1, 52.50, 66, 'marca', 'Cuidado personal', null, 'Stick', 'Axe', 'Unilever', '45 g', null, null, false, false, null),
  (23, '7509552909821', 'FC-52909821', 'Obao Rosa Tea roll-on 65 g', 'DESOD OBAO RSA TEN 48H R-ON 65G', 1, 30.72, 39, 'marca', 'Cuidado personal', null, 'Roll-on', 'Obao', null, '65 g', null, null, false, false, null),
  (24, '7509546073781', 'FC-46073781', 'Stefano Midnight spray 113 g', 'DESOD STEFANO MID-N SPY 113G', 1, 61.18, 77, 'marca', 'Cuidado personal', null, 'Spray', 'Stefano', null, '113 g', null, null, false, false, null),
  (25, '75076238', 'FC-AXE-APOL-ST', 'Axe Apollo stick 45 g', 'DESOD AXE MEN APOLLO 48H STICK 45G', 1, 52.50, 66, 'marca', 'Cuidado personal', null, 'Stick', 'Axe', 'Unilever', '45 g', null, null, false, false, null),
  (26, '7501035911208', 'FC-35911208', 'Palmolive Aquarium jabón líquido 221 ml', 'JBN LIQ PALMOL AQUARIUM 221ML', 2, 24.06, 31, 'marca', 'Cuidado personal', null, 'Jabón líquido', 'Palmolive', 'Colgate-Palmolive', '221 ml', null, null, false, false, null),
  (27, '7509546059556', 'FC-46059556', 'Palmolive Neutro Balance Dermol jabón líquido 221 ml', 'JBN LIQ PALMOL N-BAL DERMOL 221MLN', 2, 37.43, 47, 'marca', 'Cuidado personal', null, 'Jabón líquido', 'Palmolive', 'Colgate-Palmolive', '221 ml', null, null, false, false, null),
  (28, '7501022150092', 'FC-22150092', 'Grisi Leche de Burra jabón 125 g', 'JBN GRISI LECHE DE BURRA 125G', 1, 21.88, 28, 'marca', 'Cuidado personal', 'Piel', 'Jabón', 'Grisi', null, '125 g', null, null, false, false, null),
  (29, '7501019006623', 'FC-19006623', 'Saba Buenas Noches con alas', 'TAS SANIT SABA B-NOCHES ALAS C/8', 3, 27.50, 35, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toalla sanitaria', 'Saba', null, 'Caja con 8', null, null, false, false, null),
  (30, '7509552876352', 'FC-52876352', 'Obao Dermo Magnesio roll-on 65 g', 'DESOD OBAO 65G DERMO EF MAGNE R ON', 1, 31.10, 39, 'marca', 'Cuidado personal', null, 'Roll-on', 'Obao', null, '65 g', null, null, false, false, null),
  (31, '7509552876369', 'FC-52876369', 'Obao Dermo Zinc roll-on 65 g', 'DESOD OBAO 65G DERMO EF ZINC R ON', 1, 31.66, 40, 'marca', 'Cuidado personal', null, 'Roll-on', 'Obao', null, '65 g', null, null, false, false, null),
  (32, '7501361156007', 'FC-61156007', 'Avant Concha Nácar crema corporal 90 g', 'AVANT CONCHA NACAR 90GR CREMA CORPORAL', 2, 21.76, 28, 'marca', 'Cuidado personal', 'Piel', 'Crema', 'Avant', null, '90 g', null, null, false, false, null),
  (33, '7501022104217', 'FC-22104217', 'Grisi Concha Nácar crema 110 g', 'CRA GRISI SDA CONCHA NACAR 110G', 2, 55.93, 70, 'marca', 'Cuidado personal', 'Piel', 'Crema', 'Grisi', null, '110 g', null, null, false, false, null),
  (34, '7506267923654', 'FC-67923654', 'Honey Keeper gel manzanilla y miel 200 ml', 'GEL HONEY KEEPER MZNILL MIE 200ML', 1, 41.76, 53, 'marca', 'Cuidado personal', 'Piel', 'Gel', 'Honey Keeper', null, '200 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/honey-keeper-gel-manzanilla-200ml.jpg'),
  (35, '3614225108914', 'FC-25108914', 'Koleston 77 castaño bambi', 'TIN KOLESTON CRA CAST BAMBI 77', 1, 54.07, 68, 'marca', 'Cuidado personal', 'Cabello', 'Tinte', 'Koleston', 'Wella / HFC', 'Kit', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/koleston-77-castano-bambi-3614225108914.jpg'),
  (36, '850040940602', 'FC-40940602', 'Grisi Organogal Silver shampoo kit', 'GRISI 400ML SH ORGAN SILVER + 130ML CANAS F LATI', 1, 87.35, 110, 'marca', 'Cuidado personal', 'Cabello', 'Shampoo', 'Grisi', null, '400 ml + 130 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/grisi-organogal-silver-kit.jpg'),
  (37, '7509552901511', 'FC-52901511', 'Fructis rizos elásticos 48h 300 ml', 'CRA FRUCTIS RISOS ELAS48H300', 1, 46.08, 58, 'marca', 'Cuidado personal', 'Cabello', 'Crema', 'Fructis', 'Garnier', '300 ml', null, null, false, false, null),
  (38, '7509552908749', 'FC-52908749', 'Fructis pelo dañado perfecto 300 ml', 'CRA FRUCTIS PEI B-DANO PERF 300ML', 1, 46.08, 58, 'marca', 'Cuidado personal', 'Cabello', 'Crema', 'Fructis', 'Garnier', '300 ml', null, null, false, false, null),
  (39, '7501048351046', 'FC-48351046', 'Protec gel antibacterial lima-limón 125 ml', 'PROTEC LIMA-LIMON 125 ML GEL ANTIBACTERIAL', 3, 19.40, 25, 'marca', 'Cuidado personal', 'Antiséptico', 'Gel', 'Protec', null, '125 ml', null, null, false, false, null),
  (40, '7501199416168', 'FC-99416168', 'X-Treme Attraction gel 200 g', 'GEL X-TREME ATTRACTION 200G', 3, 22.61, 29, 'marca', 'Cuidado personal', 'Cabello', 'Gel', 'X-Treme', null, '200 g', null, null, false, false, null),
  (41, '7509546072272', 'FC-46072272', 'Colgate Kids Fresantástico 50 g', 'C D COLGATE KIDS FRESANTASTICO 50G', 2, 21.39, 27, 'marca', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', 'Colgate', 'Colgate-Palmolive', '50 g', null, null, false, false, null),
  (42, '7509552914696', 'FC-52914696', 'Fructis control definición rizos 300 ml', 'CRA FRUCTIS PEI CONT-DEF RIZ 300ML', 1, 46.08, 58, 'marca', 'Cuidado personal', 'Cabello', 'Crema', 'Fructis', 'Garnier', '300 ml', null, null, false, false, null),
  (43, '7501048351039', 'FC-48351039', 'Protec gel antibacterial 50 ml', 'PROTEC 50ML GEL ANTIBACTERIAL C24', 3, 13.85, 18, 'marca', 'Cuidado personal', 'Antiséptico', 'Gel', 'Protec', null, '50 ml', null, null, false, false, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.ean is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Bodega F-42 28786 · 2026-11-10 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_bf42_28786
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_bf42_28786
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = case
    when t.ean is not null then coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
    else p.codigo_barras
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_bf42_28786
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42',
  '28786',
  '2026-11-10',
  2319.12,
  'borrador',
  'Bodega F-42 Ejidos del Moral · Caja 4/28786 · 10-nov-2026 17:26 · Público en general · TC $2,319.12 · P.U. ya con IVA · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '28786'
    and coalesce(proveedor, '') ilike '%bodega%f-42%'
);

update public.recepciones
set
  total_ticket = 2319.12,
  fecha = '2026-11-10',
  proveedor = 'Bodega F-42',
  notas = 'Bodega F-42 Ejidos del Moral · Caja 4/28786 · 10-nov-2026 17:26 · Público en general · TC $2,319.12 · P.U. ya con IVA · cola Recibir',
  updated_at = now()
where folio = '28786'
  and coalesce(proveedor, '') ilike '%bodega%f-42%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '28786'
  and coalesce(r.proveedor, '') ilike '%bodega%f-42%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  coalesce(nullif(btrim(t.ean), ''), t.sku),
  t.nombre,
  t.qty,
  null,
  null,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_bf42_28786 t
join public.recepciones r
  on r.folio = '28786'
 and coalesce(r.proveedor, '') ilike '%bodega%f-42%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '28786'
  and coalesce(r.proveedor, '') ilike '%bodega%f-42%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_bf42_28786 t
order by t.linea;

commit;


-- ========== Farmacias Especializadas 1-5573418 ==========
-- Farmacias Especializadas · folio 1-5573418 · 2026-11-10 · total $1,084.46
-- ACTÚA 2+1: qty=3, costo=361.49. EAN 7730766001067.
-- 1 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_fesa_15573418 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text
) on commit drop;

insert into _fc_fesa_15573418 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen
) values
  (1, '7730766001067', 'FC-66001067', 'Vilzermet vildagliptina/metformina 50/1000 mg', 'VILZERMET 50 MG / 1000 MG COM CAJ C/30', 3, 361.49, 452, 'marca', 'Medicamentos', 'Diabetes', 'Comprimidos', 'Vilzermet', 'Asofarma', 'Caja con 30 comprimidos', 'Vildagliptina / Metformina', '50 mg / 1000 mg', true, false, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.ean is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Farmacias Especializadas 1-5573418 · 2026-11-10 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_fesa_15573418
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_fesa_15573418
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = case
    when t.ean is not null then coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
    else p.codigo_barras
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_fesa_15573418
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmacias Especializadas',
  '1-5573418',
  '2026-11-10',
  1084.46,
  'borrador',
  'FESA / Fármacos Especializados · folio contact center 1-5573418 · Id 6635450 · 10-nov-2026 10:46 · Suc. Iztapalapa · ACTÚA 2+1 Vilzermet (3 pzas, pagó 2 @ $542.23) · costo unitario promedio $361.49 · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '1-5573418'
    and coalesce(proveedor, '') ilike '%especializada%'
);

update public.recepciones
set
  total_ticket = 1084.46,
  fecha = '2026-11-10',
  proveedor = 'Farmacias Especializadas',
  notas = 'FESA / Fármacos Especializados · folio contact center 1-5573418 · Id 6635450 · 10-nov-2026 10:46 · Suc. Iztapalapa · ACTÚA 2+1 Vilzermet (3 pzas, pagó 2 @ $542.23) · costo unitario promedio $361.49 · cola Recibir',
  updated_at = now()
where folio = '1-5573418'
  and coalesce(proveedor, '') ilike '%especializada%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '1-5573418'
  and coalesce(r.proveedor, '') ilike '%especializada%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  coalesce(nullif(btrim(t.ean), ''), t.sku),
  t.nombre,
  t.qty,
  null,
  null,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_fesa_15573418 t
join public.recepciones r
  on r.folio = '1-5573418'
 and coalesce(r.proveedor, '') ilike '%especializada%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '1-5573418'
  and coalesce(r.proveedor, '') ilike '%especializada%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_fesa_15573418 t
order by t.linea;

commit;


-- ========== VERIFICACION FINAL ==========
select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where (
    (r.folio = '7993605' and coalesce(r.proveedor, '') ilike '%benavides%')
 or (r.folio = 'S339687' and coalesce(r.proveedor, '') ilike '%cityfarma%')
 or (r.folio = '451326' and coalesce(r.proveedor, '') ilike '%equilibrio%')
 or (r.folio = '16337' and coalesce(r.proveedor, '') ilike '%farmalive%')
 or (r.folio = '28786' and coalesce(r.proveedor, '') ilike '%bodega%f-42%')
 or (r.folio = '1-5573418' and coalesce(r.proveedor, '') ilike '%especializada%')
)
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket
order by r.folio;
