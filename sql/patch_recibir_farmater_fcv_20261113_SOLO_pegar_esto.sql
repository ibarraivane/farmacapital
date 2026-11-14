-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Farmater Ventas / Cityfarma · FCV-20261113 · 13-nov-2026 → cola Recibir.
-- Merge a GitHub NO lo crea. Sin bloques dollar-quote. Sin producto_imagenes.
-- Caducidad null: MMAA de la caja. No inventar 0000.
-- Al final: VERIFICACION con folio FCV-20261113 en borrador.
-- Luego: tablet Recibir → recargar → aparece la tarjeta Cityfarma.
-- =============================================================================


-- ========== Cityfarma Iztapalapa FCV-20261113 ==========
-- Cityfarma Iztapalapa · folio FCV-20261113 · 2026-11-13 · total $1,153.37 · 15 renglones
-- Carrito farmaterventas.com. P.U. oferta con IVA.
-- 6 alta(s) stock 0. 9 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_fcv_20261113 (
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

insert into _fc_fcv_20261113 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen
) values
  (1, '7502231321778', 'FC-31321778', 'Olopatadina 2 mg/ml', 'OLOPATADINA 2.0MG/ML GTS OFT 5ML *MIC*', 1, 139.25, 223, 'generico', 'Medicamentos', 'Oftálmico', 'Gotas oftálmicas', 'Olopatadina', 'Micromex', 'Frasco gotero 5 ml', 'Olopatadina', '2 mg/ml', true, false, null),
  (2, '7501300420541', 'FC-00420541', 'Aliren 50/3/300 mg', 'ALIREN 50/3/300MG CAP C/24 *SGF*', 1, 118.68, 149, 'marca', 'Medicamentos', 'Respiratorio', 'Cápsulas', 'Aliren', 'Siegfried Rhein', 'Caja con 24 cápsulas', 'Amantadina / clorfenamina / paracetamol', '50/3/300 mg', false, true, 'https://www.farmacapital.mx/catalogo-propia/aliren-50-3-300-c24-7501300420541.jpg'),
  (3, '7500462933746', 'FC-62933746', 'Inha-Rub', 'INHA-RUB UNG 40GR *ADN*', 1, 19.89, 25, 'marca', 'Cuidado personal', 'Respiratorio', 'Ungüento', 'Inha-Rub', 'ADN Pharma', 'Tarro 40 g', 'Alcanfor / mentol / eucalipto', null, false, false, null),
  (4, '7590002012475', 'FC-02012475', 'Vicks VapoRub', 'VICK VAPORUB UNG 100GR *P&G*', 1, 194.38, 243, 'marca', 'Cuidado personal', 'Respiratorio', 'Ungüento', 'Vicks', 'Procter & Gamble', 'Tarro 100 g', 'Alcanfor / mentol / eucalipto', null, false, true, null),
  (5, '7501573900269', 'FC-73900269', 'Quitadol 750 mg', '*FC* QUITADOL 750MG. TAB. C/10 *BMP*', 5, 7.78, 13, 'generico', 'Analgésico', null, 'Tabletas', 'Quitadol', 'Biomep', 'Caja con 10 tabletas', 'Paracetamol', '750 mg', false, false, null),
  (6, '7502211783282', 'FC-11783282', 'Erbitrax 1%', '*FC* ERBITRAX 1% CREMA 30GR. *LOE*PI', 2, 24.35, 39, 'generico', 'Dermatología', null, 'Crema', 'Erbitrax', 'Loeffler', 'Tubo 30 g', 'Terbinafina', '1%', false, true, null),
  (7, '7502211783275', 'FC-11783275', 'Erbitrax 1%', '*FC* ERBITRAX 1% CREMA 15GR. *LOE*', 2, 18.90, 31, 'generico', 'Dermatología', null, 'Crema', 'Erbitrax', 'Loeffler', 'Tubo 15 g', 'Terbinafina', '1%', false, false, null),
  (8, '7501537102395', 'FMX-502376', 'Norapred 50 mg', '*FC* NORAPRED 50MG. TAB. C/20 *BRU*', 3, 31.43, 51, 'generico', 'Medicamentos', null, 'Tabletas', 'Norapred', 'Brudifarma', 'Caja con 20 tabletas', 'Prednisolona', '50 mg', true, true, null),
  (9, '7501537103484', 'FC-37103484', 'Oxolbrul adulto', '*FC* OXOLBRUL ADT 225/225MG/100ML SOL 120ML *BRU*', 2, 20.12, 33, 'generico', 'Medicamentos', 'Respiratorio', 'Solución oral', 'Oxolbrul', 'Brudifarma', 'Frasco 120 ml', 'Ambroxol / dextrometorfano', '225/225 mg/100 ml', false, false, null),
  (10, '7502009746239', 'EQ-MAV295', 'Erispan compuesto 5/0.25 mg', '*FC* ERISPAN COMPUESTO 5.0/0.25MG TAB C/10 *MVE*', 3, 8.38, 11, 'marca', 'Medicamentos', null, 'Tabletas', 'Erispan', 'Maver', 'Caja con 10 tabletas', 'Betametasona / dexclorofeniramina', '5 mg / 0.25 mg', true, true, null),
  (11, '7502009740916', 'FC-50AC2C82', 'Erispan Hypack 8 mg/2 ml', '*FC* ERISPAN 8MG/2ML SOL INY. C/1 *MVE*', 3, 23.31, 30, 'marca', 'Medicamentos', null, 'Solución inyectable', 'Erispan', 'Maver', 'Frasco ámpula 2 ml', 'Betametasona', '8 mg/2 ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/erispan-hypack-8mg-7502009740916.jpg'),
  (12, '7501109790739', 'FC-09790739', 'Normex leche de magnesia', '*FC* CADP 11-2027 NORMEX 8.5GR SUSP 60ML. *QYF*', 2, 12.02, 16, 'marca', 'Gastro', null, 'Suspensión', 'Normex', 'Química y Farmacia', 'Frasco 60 ml', 'Hidróxido de magnesio', '8.5 g/100 ml', false, true, null),
  (13, '7503008344785', 'EQ-PGE033', 'Gelubrin 400 mg', '*FC* GELUBRIN 400MG CAP C/10 *PRO*', 10, 12.27, 20, 'generico', 'Analgésico', null, 'Cápsulas', 'Gelubrin', 'Progela', 'Caja con 10 cápsulas', 'Ibuprofeno', '400 mg', false, true, null),
  (14, '7501842900099', 'FC-42900099', 'Adopren 400 mg', '*FC* ADOPREN 400MG TAB C/10 *GEN* R', 3, 10.82, 18, 'generico', 'Analgésico', null, 'Tabletas', 'Adopren', 'Genética', 'Caja con 10 tabletas', 'Ibuprofeno', '400 mg', true, false, null),
  (15, '7501125100130', 'FMX-503320', 'Solución CS 0.9%', '*FC* SOLUC. CS 1000ML. *PIS* R', 4, 36.73, 59, 'generico', 'Hidratación', null, 'Solución intravenosa', 'Solución CS', 'PiSA', 'Bolsa 1000 ml', 'Cloruro de sodio', '0.9%', true, true, null);

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
  'Alta Cityfarma Iztapalapa FCV-20261113 · 2026-11-13 · listo para pistola',
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
  from _fc_fcv_20261113
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
  from _fc_fcv_20261113
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
  from _fc_fcv_20261113
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'FCV-20261113',
  '2026-11-13',
  1153.37,
  'borrador',
  'Farmater Ventas (farmaterventas.com) · carrito 13-nov-2026 21:11 · folio interno FCV-20261113 (sin No. pedido post-checkout en fotos) · 15 renglones · P.U. oferta con IVA · total $1,153.37 · Normex vitrina CADP 11-2027 → caducidad null (MMAA de caja) · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = 'FCV-20261113'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 1153.37,
  fecha = '2026-11-13',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Farmater Ventas (farmaterventas.com) · carrito 13-nov-2026 21:11 · folio interno FCV-20261113 (sin No. pedido post-checkout en fotos) · 15 renglones · P.U. oferta con IVA · total $1,153.37 · Normex vitrina CADP 11-2027 → caducidad null (MMAA de caja) · cola Recibir',
  updated_at = now()
where folio = 'FCV-20261113'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'FCV-20261113'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
from _fc_fcv_20261113 t
join public.recepciones r
  on r.folio = 'FCV-20261113'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
where r.folio = 'FCV-20261113'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
from _fc_fcv_20261113 t
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
where r.folio = 'FCV-20261113'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket
order by r.folio;
