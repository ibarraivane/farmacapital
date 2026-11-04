-- Equilibrio · ticket 450233 · 2026-11-02 · cliente 307513 Palillero · pedido online Iztapalapa 2 · Total $1,125.10 (subtotal P.U. $1,059.92 + IVA $65.18) · 15 renglones / 42 pzas. Claves EQF → EAN ficha/BuscaMed/Costofarma. Lote de fábrica sí. Caducidad NO: MMAA de la caja. 0000 inválido.
-- 7 alta(s) stock 0. 8 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_450233 (
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

insert into _fc_eq_450233 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502009749698', 'FC-09749698', 'Bromhexina/oxeladina', 'MAV414 BROMHE/OXELAD 1 JBE 60/120MG/100/120', 2, 70.81, 89, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Maver', 'Maver', 'Frasco 225 ml', 'Bromhexina / oxeladina', '60 mg/100 ml / 120 mg/100 ml', true, false, 'https://www.farmacapital.mx/catalogo-propia/verxolin-bromhexina-oxeladina-maver-7502009749698.jpg', 'catalogo-propia/verxolin-bromhexina-oxeladina-maver-7502009749698.jpg', '265229'),
  (2, '7503003406402', 'FC-34064021', 'Cotonetes Quirmex', 'QIR016 HISOPOS 1 ENVASE 100 PZAS', 7, 9.29, 12, 'marca', 'Higiene', 'Curación', 'Cotonetes', 'Quirmex', 'Quirmex', 'Envase 100 pzas', null, null, false, true, null, null, 'H1402226'),
  (3, '7503003406402', 'FC-34064021', 'Cotonetes Quirmex', 'QIR016 HISOPOS 1 ENVASE 100 PZAS', 3, 9.29, 12, 'marca', 'Higiene', 'Curación', 'Cotonetes', 'Quirmex', 'Quirmex', 'Envase 100 pzas', null, null, false, true, null, null, 'H1402026'),
  (4, '7502223112445', 'EQ-QUM052', 'Quimikan benzocaína 200 mg/mL', 'QUM052 QUIMIKAN 1 SOL C/ APLI 10 ML 200MG/ 1 ML', 3, 71.10, 114, 'generico', 'Medicamentos', null, 'Solución bucal', 'Quimikan', 'Quimpharma', 'Frasco 10 mL con aplicador', 'Benzocaína', '200 mg/mL', false, true, null, null, '26FS34'),
  (5, '7503003406051', 'FC-03406051', 'Gasa estéril Quirmex 10×10', 'QIR023 GASA ESTERILIZADA 10 SOB 10CMX10CM', 10, 9.89, 13, 'marca', 'Higiene', 'Curación', 'Gasa', 'Quirmex', 'Quirmex', 'Caja con 10 sobres 10×10 cm', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/quirmex-gasa-esteril-10x10-c10-7503003406051.jpg', 'catalogo-propia/quirmex-gasa-esteril-10x10-c10-7503003406051.jpg', 'GS2922826'),
  (6, '0780083144302', 'FC-83144302', 'Collifrin Adulto oximetazolina 0.05%', 'COL145 COLLIFRIN ADULTO 1 SOL 50MG/20 ML', 5, 33.73, 54, 'generico', 'Medicamentos', 'Respiratorio', 'Solución nasal', 'Collifrin', 'Collins', 'Frasco 20 mL', 'Oximetazolina', '0.05%', false, true, null, null, '26140881'),
  (7, '7502009747052', 'FC-09747052', 'Coriver paracetamol 750 mg', 'MAV344 CORIVER 10 TAB 750 MG', 2, 8.04, 11, 'marca', 'Analgésico', null, 'Tableta', 'Coriver', 'Maver', 'Caja con 10 tabletas', 'Paracetamol', '750 mg', false, true, null, null, '263137'),
  (8, '7502001164697', 'EQ-SON096', 'Fenimeth V óvulos 500 mg / 100000 UI', 'SON098 FENIMETH V 12 OVS 500MG/100,000 UI', 3, 37.59, 61, 'generico', 'Medicamentos', 'Ginecología', 'Óvulo', 'Fenimeth', 'Son''s', 'Caja con 12 óvulos', 'Metronidazol / nistatina', '500 mg / 100000 UI', true, true, null, null, '26071744'),
  (9, '7503014377883', 'FC-14377883', 'Max Sens Uva', 'PBY019 MAX SENS UVA 1 CARTERA 3+1', 1, 28.12, 36, 'marca', 'Salud sexual', null, 'Preservativo', 'Max Sens', 'Playboy', 'Cartera 3+1', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/max-sens-uva-3plus1-7503014377883.jpg', 'catalogo-propia/max-sens-uva-3plus1-7503014377883.jpg', 'MUV070626'),
  (10, '7503014377890', 'FC-14377890', 'Max Sens Chocomenta', 'PBY021 MAX SENS CHOCOMENTA 1 CARTERA 3+1', 1, 28.11, 36, 'marca', 'Salud sexual', null, 'Preservativo', 'Max Sens', 'Playboy', 'Cartera 3+1', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/max-sens-chocomenta-3plus1-7503014377890.jpg', 'catalogo-propia/max-sens-chocomenta-3plus1-7503014377890.jpg', 'MCH010226'),
  (11, '7503014377197', 'EQ-PBY007', 'Max Sens Tropicana Mix', 'PBY007 MAX SENS TROPICANA MIX 1 BLISTER 3+1', 1, 28.13, 36, 'marca', 'Salud sexual', null, 'Preservativo', 'Max Sens', 'Playboy', 'Blíster 3+1', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/max-sens-tropicana-mix-3plus1-7503014377197.jpg', 'catalogo-propia/max-sens-tropicana-mix-3plus1-7503014377197.jpg', 'TRP110726'),
  (12, '75034498', 'FC-75034498', 'Playboy Texturizado', 'PBY003 PLAYBOY TEXTURIZADO 1 BLISTER C/3 PZAS', 1, 37.53, 47, 'marca', 'Salud sexual', null, 'Preservativo', 'Playboy', 'Playboy', 'Blíster con 3 pzas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/playboy-texturizado-c3-75034498.jpg', 'catalogo-propia/playboy-texturizado-c3-75034498.jpg', '1330626'),
  (13, '75034481', 'FC-75034481', 'Playboy Extra Sensible', 'PBY002 PLAYBOY EXTRA SENSIBLE 1 BLISTER 3 PZAS', 1, 37.51, 47, 'marca', 'Salud sexual', null, 'Preservativo', 'Playboy', 'Playboy', 'Blíster con 3 pzas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/playboy-extra-sensible-c3-75034481.jpg', 'catalogo-propia/playboy-extra-sensible-c3-75034481.jpg', '2050426'),
  (14, '7503014377876', 'FC-14377876', 'Max Sens Fresa', 'PBY018 MAX SENS FRESA 1 BLISTER 3+1', 1, 28.15, 36, 'marca', 'Salud sexual', null, 'Preservativo', 'Max Sens', 'Playboy', 'Blíster 3+1', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/max-sens-fresa-3plus1-7503014377876.jpg', 'catalogo-propia/max-sens-fresa-3plus1-7503014377876.jpg', 'MFR090726'),
  (15, '7503014377180', 'EQ-PBY008', 'Max Sens Passion Mix', 'PBY008 MAX SENS PASSION MIX 1 BLISTER 3+1', 1, 28.15, 36, 'marca', 'Salud sexual', null, 'Preservativo', 'Max Sens', 'Playboy', 'Blíster 3+1', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/max-sens-passion-mix-3plus1-7503014377180.jpg', 'catalogo-propia/max-sens-passion-mix-3plus1-7503014377180.jpg', 'PAS210626');

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
  'Alta Equilibrio 450233 · 2026-11-02 · listo para pistola',
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
  from _fc_eq_450233
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
  from _fc_eq_450233
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
  from _fc_eq_450233
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '450233',
  '2026-11-02',
  1125.10,
  'borrador',
  'Ticket Equilibrio folio 450233 · cliente 307513 Luis Angel · 02-nov-2026 · 42 pzas · $1,125.10 · lote de fábrica en renglón; MMAA de la caja · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '450233'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 1125.10,
  fecha = '2026-11-02',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio folio 450233 · cliente 307513 Luis Angel · 02-nov-2026 · 42 pzas · $1,125.10 · lote de fábrica en renglón; MMAA de la caja · cola Recibir',
  updated_at = now()
where folio = '450233'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '450233'
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
from _fc_eq_450233 t
join public.recepciones r
  on r.folio = '450233'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

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
where r.folio = '450233'
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
from _fc_eq_450233 t
order by t.linea;

commit;
