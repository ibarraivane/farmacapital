-- ============================================================================
-- Nadro factura 6091723171 · 2026-10-29 · $1,119.31 → cola Recibir
--
-- CFDI UUID C371578D-9D96-4DB3-9287-EEEF524F59EB · efectivo · FARMACAPITAL
-- 8 renglones. Altas stock 0 si el EAN no existe.
-- Softclix / Telmisartán 40 mg ya en catálogo: costo ticket, no baja PVP bueno.
-- Nombres de ficha (iNadro / packshot), no del ticket. Fotos en catalogo-propia/.
-- Stock al escanear + MMAA de la caja. No inventar 0000.
-- SIN do $$. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temp table _fc_nd6091723171 (
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
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null default false,
  imagen text
) on commit drop;

insert into _fc_nd6091723171 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, imagen
) values
(1, '4015630018277', 'FC-30018277',
 'Accu-Chek Softclix lancetas',
 'ACCU-CHEK SOFTCLIX LANCETAS 25',
 2, 65.92, 83, 'marca', 'Dispositivos',
 'Diabetes', 'Lancetas', 'Accu-Chek', 'Roche',
 'Caja con 25 piezas', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/accu-chek-softclix-25-4015630018277.jpg'),
(2, '7502002461290', 'FC-02461290',
 'Bpollen gel 2.5%',
 'BPOLLEN 2.5% GEL TB 60 G',
 1, 170.78, 214, 'marca', 'Medicamentos',
 'Dermatológico', 'Gel', 'Farmapiel', 'Farmapiel',
 'Tubo 60 g', 'Peróxido de benzoilo', '2.5%', false,
 'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-2.5-7502002461290.jpg'),
(3, '7502002461306', 'FC-02461306',
 'Bpollen gel 5%',
 'BPOLLEN 5% GEL TB 60 G',
 1, 185.63, 233, 'marca', 'Medicamentos',
 'Dermatológico', 'Gel', 'Farmapiel', 'Farmapiel',
 'Tubo 60 g', 'Peróxido de benzoilo', '5%', false,
 'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-5-7502002461306.jpg'),
(4, '5016003770500', 'FC-03770500',
 'Contour Plus tiras reactivas',
 'CONTOUR PLUS TIRAS REACTIVAS C/25',
 1, 136.01, 171, 'marca', 'Dispositivos',
 'Diabetes', 'Tiras', 'Contour Plus', 'Ascensia',
 'Caja con 25 tiras', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/contour-plus-tiras-25-5016003770500.jpg'),
(5, '650240032424', 'FC-40032424',
 'Asepxia polvo compacto Beige Claro',
 'MJE ASEPXIA BB PVO COMP BEI CLA 10G',
 1, 126.02, 158, 'marca', 'Cuidado personal',
 'Maquillaje', 'Polvo compacto', 'Asepxia', 'Genomma Lab',
 '10 g', 'Ácido salicílico', null, false,
 'https://www.farmacapital.mx/catalogo-propia/asepxia-polvo-beige-claro-650240032424.jpg'),
(6, '650240032431', 'FC-40032431',
 'Asepxia polvo compacto Canela',
 'MJE ASEPXIA PVO COM TONO CANELA 10G',
 1, 126.02, 158, 'marca', 'Cuidado personal',
 'Maquillaje', 'Polvo compacto', 'Asepxia', 'Genomma Lab',
 '10 g', 'Ácido salicílico', null, false,
 'https://www.farmacapital.mx/catalogo-propia/asepxia-polvo-canela-650240032431.jpg'),
(7, '7501349025844', 'FC-49025844',
 'Telmisartán 40 mg',
 'TELMISARTAN 40 MG 28 TAB    LGEN',
 3, 34.00, 55, 'generico', 'Medicamentos',
 'Cardiovascular', 'Tableta', 'AMSA', 'AMSA',
 'Caja con 28 tabletas', 'Telmisartán', '40 mg', true,
 'https://www.farmacapital.mx/catalogo-propia/telmisartan-40mg-28tab-7501349025844.jpg'),
(8, '7501349025400', 'FC-49025400',
 'Telmisartán 80 mg',
 'TELMISARTAN 80 MG 14 TAB    LGEN',
 2, 28.92, 47, 'generico', 'Medicamentos',
 'Cardiovascular', 'Tableta', 'AMSA', 'AMSA',
 'Caja con 14 tabletas', 'Telmisartán', '80 mg', true,
 'https://www.farmacapital.mx/catalogo-propia/telmisartan-80mg-14tab-7501349025400.jpg');

-- ═══════════════════════════════════════════════════════════
-- Altas (solo si el EAN / SKU aún no existen)
-- ═══════════════════════════════════════════════════════════
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Nadro 6091723171 · 2026-10-29 · listo para pistola',
  t.costo,
  t.precio,
  0, 1, true, t.receta,
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion,
  t.laboratorio, t.imagen, t.imagen
from _fc_nd6091723171 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean or p.sku = t.sku
  );

-- Costos del ticket (no baja PVP bueno).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from _fc_nd6091723171 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 1
    or nullif(btrim(p.codigo_barras), '') is null
  );

-- Completar ficha / foto si falta (no pisa foto ni nombre bueno).
update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8
      or p.nombre ~* '^(MJE |BLOQ |TELMISARTAN .*LGEN|BPOLLEN .*TB)'
      then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  categoria = coalesce(nullif(trim(p.categoria), ''), t.categoria),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean),
  requiere_receta = case when t.receta then true else p.requiere_receta end
from _fc_nd6091723171 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- ═══════════════════════════════════════════════════════════
-- Recepción borrador
-- ═══════════════════════════════════════════════════════════
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6091723171',
  '2026-10-29',
  1119.31,
  'borrador',
  'Factura Nadro 6091723171 · 29-oct-2026 · Softclix · Bpollen · Contour Plus · Asepxia · Telmisartán AMSA · $1,119.31 · CFDI C371578D-9D96-4DB3-9287-EEEF524F59EB · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '6091723171' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 1119.31,
  fecha = '2026-10-29',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6091723171 · 29-oct-2026 · Softclix · Bpollen · Contour Plus · Asepxia · Telmisartán AMSA · $1,119.31 · CFDI C371578D-9D96-4DB3-9287-EEEF524F59EB · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '6091723171'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6091723171'
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
from _fc_nd6091723171 t
join public.recepciones r
  on r.folio = '6091723171'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select public.fc_buscar_producto_escaneo(t.ean) as pid
) v on true
order by t.linea;

commit;

-- Verificación rápida (opcional):
-- select folio, proveedor, total_ticket, estado from recepciones where folio = '6091723171';
-- select codigo_escaneado, nombre_snapshot, cantidad, costo_estimado, pendiente_alta
-- from recepcion_items where recepcion_id = (select id from recepciones where folio = '6091723171' limit 1)
-- order by id;
