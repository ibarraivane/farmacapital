-- Equilibrio · ticket 448644 · 2026-10-19 · sucursal Iztapalapa 2
-- Pedido online. Total $1,059.65 · 8 renglones / 29 pzas.
-- Claves EQF → EAN ficha/Levic. Lote de fábrica sí.
-- Caducidad NO: MMAA de la caja. 0000 inválido.
-- Renglón ácido ascórbico: nombre cortado en foto (Kaomycin/Eye-Mo); asignado AMSA 6 amp 1 g/10 mL EAN 7501349022119 · lote U0227. Confirmar en caja.
-- AMS365 Zolmitriptano → EAN Ultra/AMSA 7502216805446 (2 tab 2.5 mg).
-- 2 alta(s) stock 0. 6 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_448644 (
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

insert into _fc_eq_448644 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502211780359', 'FC-11780359', 'Aflusil ibuprofeno suspensión', 'LOE001 AFLUSIL 1 SUSP 2G/120ML', 3, 19.20, 31, 'generico', 'Medicamentos', null, 'Suspensión', 'Aflusil', 'Loeffler', 'Frasco 120 mL', 'Ibuprofeno', '2 g/120 mL', false, true, null, null, 'R2602932'),
  (2, '0780083141929', 'FC-83141929', 'Dolprin ibuprofeno suspensión', 'COL039 DOLPRIN 1 SUSP 100MG/5/120 ML', 3, 27.33, 44, 'generico', 'Medicamentos', null, 'Suspensión', 'Dolprin', 'Collins', 'Frasco 120 mL', 'Ibuprofeno', '100 mg/5 mL', false, true, null, null, '26141339'),
  (3, '7502009740206', 'FC-6519183A', 'Clamoxin amoxicilina/clavulanato suspensión', 'MAV011 CLAMOXIN 1 SUSP 125/31.25MG/5/60 ML', 3, 27.82, 45, 'generico', 'Medicamentos', null, 'Suspensión', 'Clamoxin', 'Maver', 'Frasco 60 mL', 'Amoxicilina / ácido clavulánico', '125/31.25 mg/5 mL', true, true, null, null, '262274'),
  (4, '7501258207010', 'FC-58207010', 'Oxital-C 2 g', 'SER141 OXITAL C 10 COMP 2G', 5, 61.20, 77, 'marca', 'Medicamentos', null, 'Tableta efervescente', 'Oxital-C', 'Serral', 'Tubo con 10 tabletas', 'Ácido ascórbico', '2 g', false, true, null, null, '260140'),
  (5, '7501349025844', 'EQ-AMS237', 'Telmisartán 40 mg', 'AMS237 TELMISARTAN 28 TAB 40 MG', 3, 34.06, 55, 'generico', 'Medicamentos', null, 'Tableta', 'AMSA', 'AMSA', 'Caja con 28 tabletas', 'Telmisartán', '40 mg', true, true, null, null, 'U26A262'),
  (6, '7501258206723', 'EQ-SER093', 'Oxital-C 1 g', 'SER093 OXITAL C 10 COMP 1G', 5, 45.11, 73, 'generico', 'Medicamentos', null, 'Tableta efervescente', 'Oxital-C', 'Serral', 'Tubo con 10 tabletas', 'Ácido ascórbico', '1 g', false, true, null, null, '260400'),
  (7, '7501349022119', 'FC-49022119', 'Ácido ascórbico 1 g/10 mL', 'ACIDO ASCORBICO 6 AMP 1G/10 ML', 5, 28.39, 46, 'generico', 'Medicamentos', null, 'Solución inyectable', 'AMSA', 'AMSA', 'Caja con 6 ampolletas', 'Ácido ascórbico', '1 g/10 mL', false, false, null, null, 'U0227'),
  (8, '7502216805446', 'EQ-AMS365', 'Zolmitriptano 2.5 mg', 'AMS365 ZOLMITRIPTANO 2 TAB 2.5 MG', 2, 30.46, 49, 'generico', 'Medicamentos', null, 'Tableta dispersable', 'AMSA', 'Ultra / AMSA', 'Caja con 2 tabletas', 'Zolmitriptano', '2.5 mg', true, false, null, null, 'U26A344');

-- Una fila por EAN (mismo producto con 2 lotes no debe insertar 2 veces el SKU).
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
  'Alta Equilibrio 448644 · 2026-10-19 · listo para pistola',
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
  from _fc_eq_448644
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (ean) *
  from _fc_eq_448644
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

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
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
  from _fc_eq_448644
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '448644',
  '2026-10-19',
  1059.65,
  'borrador',
  'Ticket Equilibrio 448644 · pedido online Iztapalapa 2 · 19-oct-2026 · 29 pzas · $1,059.65 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '448644'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 1059.65,
  fecha = '2026-10-19',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 448644 · pedido online Iztapalapa 2 · 19-oct-2026 · 29 pzas · $1,059.65 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '448644'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '448644'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
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
from _fc_eq_448644 t
join public.recepciones r
  on r.folio = '448644'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  t.foto_file,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from _fc_eq_448644 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = t.imagen or i.storage_path = t.foto_file)
  );

-- Diagnóstico
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
where r.folio = '448644'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_eq_448644 t
order by t.linea;

commit;
