-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Nadro folio 6092511913 · factura 2026-11-19 · total $497.57 → cola Recibir
-- Merge a GitHub NO lo crea. SIN bloques dollar-quote. Sin producto_imagenes.
-- Caducidad null: MMAA de la caja. No inventar 0000.
-- Costo = VALOR UNITARIO. PVP solo si precio ≤1 (marca +25% / genérico +60%).
-- Idempotente mientras el ticket siga en borrador.
-- Luego: tablet Recibir → recargar → aparece la tarjeta Nadro 6092511913.
-- =============================================================================

begin;

create temp table _fc_nd6092511913 (
  linea integer primary key,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  marca text,
  presentacion text,
  forma text,
  laboratorio text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  alta_nueva boolean not null,
  imagen text
) on commit drop;

insert into _fc_nd6092511913
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion, receta, alta_nueva, imagen)
values
  (
    1,
    '7501349029460',
    'FC-49029460',
    'Diosmina/Hesperidina 450/50 mg',
    'DIOSMINA/HESPE 450/50MG 20TAB LGEN',
    2,
    49.88,
    80,
    'generico',
    'Medicamentos',
    'Circulación',
    'AMSA',
    'Caja con 20 tabletas',
    'Tableta',
    'AMSA',
    'Diosmina / Hesperidina',
    '450 mg / 50 mg',
    false,
    true,
    'https://www.farmacapital.mx/catalogo-propia/diosmina-hesperidina-450-50-20tab-7501349029460.jpg'
  ),
  (
    2,
    '7501125100123',
    'FC-25100123',
    'Solución CS Pisa cloruro de sodio 0.9%',
    'ISOT CLOR SOD CS 500ML PLAST12',
    2,
    51.24,
    65,
    'marca',
    'Hidratación',
    'Soluciones',
    'PiSA',
    'Frasco 500 ml',
    'Solución inyectable',
    'Pisa',
    'Cloruro de sodio',
    '0.9%',
    false,
    false,
    'https://www.farmacapital.mx/catalogo-propia/solucion-cs-pisa-500ml-7501125100123.jpg'
  ),
  (
    3,
    '7501109790739',
    'FC-09790739',
    'Normex leche de magnesia',
    'LECHE-MAGN NORMEX SUSP 60 ML',
    1,
    13.14,
    17,
    'marca',
    'Gastro',
    null,
    'Normex',
    'Frasco 60 ml',
    'Suspensión',
    'Química y Farmacia',
    'Hidróxido de magnesio',
    '8.5 g/100 ml',
    false,
    false,
    'https://www.farmacapital.mx/catalogo-propia/normex-leche-magnesia-60ml-7501109790739.jpg'
  ),
  (
    4,
    '7502231320665',
    'FC-31320665',
    'Lubrex',
    'LUBREX SOLUCION AL0.5% 10ML LGEN',
    1,
    235.98,
    295,
    'marca',
    'Oftalmología',
    null,
    'Lubrex',
    'Frasco gotero 10 ml',
    'Solución oftálmica',
    'Micro Pharmaceuticals',
    'Carboximetilcelulosa sódica',
    '0.5%',
    false,
    false,
    'https://www.farmacapital.mx/catalogo-propia/lubrex-0.5-10ml.jpg'
  ),
  (
    5,
    '75050764',
    'FC-75050764',
    'Neomicina Polimixina B Bacitracina',
    'NEOPOL B/BAC 3.5MG T.B 3.5G LGEN',
    1,
    46.21,
    74,
    'generico',
    'Oftalmología',
    'Antibióticos',
    'OPKO',
    'Tubo 3.5 g',
    'Ungüento oftálmico',
    'Pharmacos Exakta',
    'Neomicina / Polimixina B / Bacitracina',
    '3.5 mg / 5000 UI / 400 UI por g',
    true,
    true,
    'https://www.farmacapital.mx/catalogo-propia/neomicina-polimixina-bacitracina-ung-oft-75050764.jpg'
  );

-- Altas nuevas (solo si el EAN no existe).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, forma_farmaceutica,
  principio_activo, concentracion, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Nadro 6092511913 · 2026-11-19 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.laboratorio,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.imagen,
  t.imagen
from _fc_nd6092511913 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ficha de mostrador (marca real, no casa Nadro LGEN).
update public.productos p set
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), t.forma),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), t.concentracion),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), t.subcategoria),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),
  categoria = coalesce(nullif(btrim(p.categoria), ''), t.categoria),
  tipo = coalesce(nullif(btrim(p.tipo), ''), t.tipo),
  requiere_receta = t.receta,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean),
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''), t.imagen),
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    when p.nombre ilike '%LGEN%' or p.nombre ilike 'DIOSMIN%' or p.nombre ilike 'NEOPOL%'
      then t.nombre
    else p.nombre
  end
from _fc_nd6092511913 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

-- Costos del ticket (PVP solo si estaba en 0 / ≤1).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end,
  activo = true,
  stock_minimo = greatest(coalesce(p.stock_minimo, 0), 1)
from _fc_nd6092511913 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 1
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6092511913',
  '2026-11-19',
  497.57,
  'borrador',
  'Pedido Nadro 6092511913 · factura 19-11-26 · $497.57 · Diosmina AMSA + Sol CS Pisa ×2 + Normex + Lubrex + Neopol · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '6092511913' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 497.57,
  fecha = '2026-11-19',
  proveedor = 'Nadro',
  notas = 'Pedido Nadro 6092511913 · factura 19-11-26 · $497.57 · Diosmina AMSA + Sol CS Pisa ×2 + Normex + Lubrex + Neopol · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '6092511913'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6092511913'
  and coalesce(r.proveedor, '') ilike '%nadro%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  t.ean,
  t.snap,
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
from _fc_nd6092511913 t
join public.recepciones r
  on r.folio = '6092511913'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

-- VERIFICACION
select
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  coalesce(sum(i.cantidad), 0) as piezas,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar,
  bool_or(coalesce(i.pendiente_alta, false)) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '6092511913'
  and coalesce(r.proveedor, '') ilike '%nadro%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 48) as nombre_catalogo,
  case when p.imagen_url is null then 'SIN FOTO' else 'OK' end as foto
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '6092511913' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
