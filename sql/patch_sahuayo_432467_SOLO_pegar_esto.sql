-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Sahuayo folio 432467 · 26-nov-2024 · $892.43 · 14 renglones / 28 pzas
-- Merge a GitHub NO crea la tarjeta. Este Run sí.
-- Sin bloques dollar-quote. Sin galería extra. Idempotente en borrador.
-- Al final: VERIFICACION con folio 432467 en borrador.
-- Luego: tablet Recibir → recargar → tarjeta Sahuayo 432467.
-- =============================================================================

-- Sahuayo · ticket 432467 · 2024-11-26 05:02 · Central Abastos F26/F28 · Total $892.43
-- (subtotal $825.53 + impuesto $66.90) · 14 renglones / 28 pzas.
-- Claves ticket → EAN ficha/BuscaMed/YZA/Fénix. Sin lote en el papel.
-- Caducidad NO: MMAA de la caja. 0000 inválido.
-- 8 alta(s) stock 0. 6 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_sah_432467 (
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
  receta boolean not null,
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_sah_432467 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501943441804', 'FC-43441804', 'Huggies Supreme etapa 5 Niño', 'PZA.HUGGIE SU E5 NIÑO5X36 1/36', 1, 314.37, 393, 'marca', 'Bebés', 'Pañales', null, 'Huggies', 'Kimberly-Clark', 'Bolsa con 36 pañales etapa 5', null, null, false, true, null, null, null),
  (2, '013117050103', 'FC-11705010', 'Affective Predoblado', 'PZA.AFFECTIVE PREDOBLADO 1/10', 1, 71.18, 89, 'marca', 'Higiene', 'Incontinencia', null, 'Affective', 'PI Mabe', 'Bolsa con 10 protectores unitalla', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/affective-predoblado-10-013117050103.jpg', 'catalogo-propia/affective-predoblado-10-013117050103.jpg', null),
  (3, '7501017375189', 'FC-17375189', 'KleenBebé Absorsec Grande', 'PZA.KBB ABSORSEC GRANDE 1/14 U', 1, 50.36, 63, 'marca', 'Bebés', 'Pañales', null, 'KleenBebé', 'Kimberly-Clark', 'Bolsa con 14 pañales talla Grande etapa 4', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-absorsec-grande-14-7501017375189.jpg', 'catalogo-propia/kleenbebe-absorsec-grande-14-7501017375189.jpg', null),
  (4, '7506425648634', 'FC-25648634', 'KleenBebé Suavelastic RN', 'PZA.KBB SUAVEL RN E1 20s 1/20', 1, 48.99, 62, 'marca', 'Bebés', 'Pañales', null, 'KleenBebé', 'Kimberly-Clark', 'Bolsa con 20 pañales RN etapa 1', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-suavelastic-rn-20-7506425648634.jpg', 'catalogo-propia/kleenbebe-suavelastic-rn-20-7506425648634.jpg', null),
  (5, '7501943418509', 'FC-43418509', 'Kotex Nocturna con alas', 'PZA.KOTEX NOCTU.C/A 8s 1/8 UNI', 2, 15.80, 20, 'marca', 'Higiene', 'Toallas femeninas', null, 'Kotex', 'Kimberly-Clark', 'Paquete con 8 toallas nocturna con alas', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/kotex-nocturna-alas-8-7501943418509.jpg', 'catalogo-propia/kotex-nocturna-alas-8-7501943418509.jpg', null),
  (6, '7506339394719', 'FC-01405335', 'Naturella Nocturna con alas', 'PZA.NATURELLA NOCTURN C/A 1/8', 5, 18.89, 24, 'marca', 'Higiene', 'Toallas femeninas', null, 'Naturella', 'P&G', 'Paquete con 8 toallas nocturna con alas', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/naturella-nocturna-alas-8-7506339394719.jpg', 'catalogo-propia/naturella-nocturna-alas-8-7506339394719.jpg', null),
  (7, '7501019006609', 'FC-19006609', 'Saba Buenas Noches', 'PZA.SABA BUENAS NOCHES 1/10 UN', 2, 21.35, 27, 'marca', 'Higiene', 'Toallas femeninas', null, 'Saba', 'Essity', 'Paquete con 10 toallas extra largas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/saba-buenas-noches-10-7501019006609.jpg', 'catalogo-propia/saba-buenas-noches-10-7501019006609.jpg', null),
  (8, '7501943411449', 'FC-43411449', 'Kotex Maxi Nocturna con alas', 'PZA.KOTEX MAXI NOC.ALA10s 1/10', 2, 16.00, 20, 'marca', 'Higiene', 'Toallas femeninas', null, 'Kotex', 'Kimberly-Clark', 'Paquete con 10 toallas maxi nocturna con alas', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/kotex-maxi-nocturna-alas-10-7501943411449.jpg', 'catalogo-propia/kotex-maxi-nocturna-alas-10-7501943411449.jpg', null),
  (9, '7501019030352', 'FC-19030352', 'Saba Confort Manzanilla con alas', 'PZA.SABA CONF. MLLA. REGC/A 1/10', 1, 17.18, 22, 'marca', 'Higiene', 'Toallas femeninas', null, 'Saba', 'Essity', 'Paquete con 10 toallas regular con alas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/saba-confort-manzanilla-alas-10-7501019030352.jpg', 'catalogo-propia/saba-confort-manzanilla-alas-10-7501019030352.jpg', null),
  (10, '7500435133531', 'FC-35133531', 'Always Seca Protección Total', 'PZA.ALWAYS SECA PROT. TOTA 1/10', 3, 22.40, 28, 'marca', 'Higiene', 'Toallas femeninas', null, 'Always', 'P&G', 'Paquete con 10 toallas día con alas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/always-proteccion-total-seca-10-7500435133531.jpg', 'catalogo-propia/always-proteccion-total-seca-10-7500435133531.jpg', null),
  (11, '7501943424623', 'FC-43424623', 'Kotex Anatómica Manzanilla con alas', 'PZA.KOTEX ANATOMICA C/A 1/10 U', 2, 14.69, 19, 'marca', 'Higiene', 'Toallas femeninas', null, 'Kotex', 'Kimberly-Clark', 'Paquete con 10 toallas anatómicas con alas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/kotex-anatomica-manzanilla-alas-10-7501943424623.jpg', 'catalogo-propia/kotex-anatomica-manzanilla-alas-10-7501943424623.jpg', null),
  (12, '7501019030345', 'FC-19030345', 'Saba Confort Manzanilla sin alas', 'PZA.SABA CONF. MLLA. REGS/A 1/10', 2, 13.74, 18, 'marca', 'Higiene', 'Toallas femeninas', null, 'Saba', 'Essity', 'Paquete con 10 toallas regular sin alas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/saba-confort-manzanilla-sin-alas-10-7501019030345.jpg', 'catalogo-propia/saba-confort-manzanilla-sin-alas-10-7501019030345.jpg', null),
  (13, '7506309895208', 'FC-01157296', 'Naturella Manzanilla con alas', 'PZA.NATURELLA C/MANZA. C/A 1/8', 4, 11.21, 15, 'marca', 'Higiene', 'Toallas femeninas', null, 'Naturella', 'P&G', 'Paquete con 8 toallas regular con alas', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/naturella-manzanilla-alas-8-7506309895208.jpg', 'catalogo-propia/naturella-manzanilla-alas-8-7506309895208.jpg', null),
  (14, '7506309893471', 'FC-09893471', 'Always Ultrafina Nocturna con alas', 'PZA.ALWAYS NOC. ULTRAF. C/A 1/7', 1, 20.70, 26, 'marca', 'Higiene', 'Toallas femeninas', null, 'Always', 'P&G', 'Paquete con 7 toallas nocturna ultrafina con alas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/always-ultrafina-nocturna-alas-7-7506309893471.jpg', 'catalogo-propia/always-ultrafina-nocturna-alas-7-7506309893471.jpg', null);

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
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Sahuayo 432467 · 2024-11-26 · listo para pistola',
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
  select distinct on (ean) *
  from _fc_sah_432467
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (ean) *
  from _fc_sah_432467
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
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
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from _fc_sah_432467
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Sahuayo',
  '432467',
  '2024-11-26',
  892.43,
  'borrador',
  'Ticket Sahuayo folio 432467 · 26-nov-2024 05:02 · Central Abastos F26/F28 · 28 pzas · $892.43 · sin lote en papel; MMAA de la caja · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '432467'
    and coalesce(proveedor, '') ilike '%sahuayo%'
);

update public.recepciones
set
  total_ticket = 892.43,
  fecha = '2024-11-26',
  proveedor = 'Sahuayo',
  notas = 'Ticket Sahuayo folio 432467 · 26-nov-2024 05:02 · Central Abastos F26/F28 · 28 pzas · $892.43 · sin lote en papel; MMAA de la caja · cola Recibir',
  updated_at = now()
where folio = '432467'
  and coalesce(proveedor, '') ilike '%sahuayo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '432467'
  and coalesce(r.proveedor, '') ilike '%sahuayo%'
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
  t.nombre,
  t.qty,
  null,
  t.lote,
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
from _fc_sah_432467 t
join public.recepciones r
  on r.folio = '432467'
 and coalesce(r.proveedor, '') ilike '%sahuayo%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
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
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '432467'
  and coalesce(r.proveedor, '') ilike '%sahuayo%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_sah_432467 t
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
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '432467'
  and coalesce(r.proveedor, '') ilike '%sahuayo%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket;
