-- Farmaceuticos Tenorio · folio 3811849 · 2026-10-15 22:58
-- Cliente 20077 Palillero Ventura Luis Angel. Ref 2134457. Ruta Puebla. 1 caja.
-- Subtotal 1376.79 + IVA 17.09 = 1393.88. El IVA solo cae en colonia y agua oxigenada.
-- Esas dos llevan el 16% dentro del costo (35.35 y 17.73) para que los renglones sumen el total.
-- Lote de la factura. Caducidad null: MMAA de la caja. No inventar 0000.
-- Aktyzar: se mueve el EAN 7502274792207 del LGEN FC-16792555 a EQ-SOF066
-- y se devuelve 7502216792555 al LGEN, si esas fichas siguen así.
-- 8 alta(s) stock 0. 7 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

-- Aktyzar C/14: el EAN de la caja está en el LGEN. La ficha buena es EQ-SOF066.
update public.productos
set codigo_barras = '7502216792555'
where sku = 'FC-16792555'
  and codigo_barras = '7502274792207'
  and exists (select 1 from public.productos where sku = 'EQ-SOF066')
  and not exists (
    select 1 from public.productos
    where codigo_barras = '7502216792555' and sku <> 'FC-16792555'
  );

update public.productos
set codigo_barras = '7502274792207'
where sku = 'EQ-SOF066'
  and coalesce(nullif(trim(codigo_barras), ''), '') = ''
  and not exists (
    select 1 from public.productos
    where codigo_barras = '7502274792207' and sku <> 'EQ-SOF066'
  );

create temp table _fc_tn_3811849 (
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

insert into _fc_tn_3811849 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '780083148577', 'EQ-COL213', 'Ampigrin PFC jarabe infantil 60 mL', 'AMPIGRIN PFC INF JBE', 2, 24.69, 31, 'marca', 'Antibiótico', null, 'Jarabe', 'Collins', 'Collins', 'Frasco 60 mL', null, '3 g / 0.50 g / 0.02 g / 60 mL', true, true, null, null, '26141865'),
  (2, '7503027446279', 'FC-5C8C9C11', 'Gelubrin 600 mg', 'GELUBRIN 600MG CAP C/10', 5, 20.12, 33, 'generico', 'Antiinflamatorio', null, 'Cápsulas', 'Gelubrin', 'Progela', 'Caja con 10 cápsulas', 'Ibuprofeno', '600 mg', false, true, null, null, 'U0590'),
  (3, '7506494600472', 'FC-94600472', 'Aba-Pen 20/400 mg', 'ABA-PEN 20/400MG TAB C/10', 2, 34.56, 44, 'marca', 'Antiinflamatorio', 'Antiespasmódico', 'Tabletas', 'Aba-Pen', 'Schoen', 'Caja con 10 tabletas', 'Hioscina / ibuprofeno', '20/400 mg', false, false, 'https://www.farmacapital.mx/catalogo-propia/aba-pen-20-400mg-c10-7506494600472.jpg', 'catalogo-propia/aba-pen-20-400mg-c10-7506494600472.jpg', '162066'),
  (4, '7501022104262', 'FC-22104262', 'Ricitos de Oro manzanilla', 'AGUA DE COLONIA RICITOS DE ORO 100ML', 2, 35.35, 45, 'marca', 'Cuidado personal', 'Bebé', 'Colonia', 'Ricitos de Oro', 'Grisi', 'Frasco 100 mL', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/ricitos-de-oro-manzanilla-100ml-7501022104262.jpg', 'catalogo-propia/ricitos-de-oro-manzanilla-100ml-7501022104262.jpg', '4262'),
  (5, '759684315275', 'FC-84315275', 'Agua oxigenada Jaloma', 'AGUA OXIGENADA ATOMIZADOR 224ML', 3, 17.73, 23, 'marca', 'Botiquín', null, 'Solución', 'Jaloma', null, 'Atomizador 224 mL', 'Peróxido de hidrógeno', '3% (10 volúmenes)', false, false, 'https://www.farmacapital.mx/catalogo-propia/jaloma-agua-oxigenada-atomizador-224ml-759684315275.jpg', 'catalogo-propia/jaloma-agua-oxigenada-atomizador-224ml-759684315275.jpg', '0171561'),
  (6, '7501349027343', 'FC-49027343', 'Amsafast orlistat 120 mg', 'AMSAFAST 120MG CAP C/21', 3, 83.14, 104, 'marca', 'Gastro', 'Obesidad', 'Cápsulas', 'Amsafast', 'AMSA', 'Caja con 21 cápsulas', 'Orlistat', '120 mg', true, true, null, null, 'U26Y166'),
  (7, '7501349020436', 'FC-49020436', 'Gabapentina 300 mg', 'GABAPENTINA 300MG CAP C/15', 2, 22.88, 37, 'generico', 'Medicamentos', null, 'Cápsulas', 'AMSA', 'AMSA', 'Caja con 15 cápsulas', 'Gabapentina', '300 mg', true, true, null, null, 'U26Y406'),
  (8, '7501384541620', 'FC-84541620', 'Gabapentina 400 mg', 'GABAPENTINA 400MG CAP C/15', 2, 49.92, 80, 'generico', 'Medicamentos', null, 'Cápsulas', 'Psicofarma', 'Psicofarma', 'Caja con 15 cápsulas', 'Gabapentina', '400 mg', true, true, null, null, '6080726'),
  (9, '7502274792207', 'EQ-SOF066', 'Aktyzar omeprazol 20 mg', 'AKTYZAR 20MG CAP C/14', 5, 7.90, 10, 'marca', 'Gastro', null, 'Cápsulas', 'Aktyzar', 'Solfran', 'Caja con 14 cápsulas', 'Omeprazol', '20 mg', false, true, null, null, '61992'),
  (10, '7502227426715', 'FC-27426715', 'Algidol 600 mg', 'ALGIDOL 600MG CAP C/10', 4, 23.21, 30, 'marca', 'Analgésico', null, 'Cápsulas', 'Algidol', 'Gelpharma', 'Caja con 10 cápsulas', 'Ibuprofeno', '600 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/algidol-600mg-c10-7502227426715.jpg', 'catalogo-propia/algidol-600mg-c10-7502227426715.jpg', '260994'),
  (11, '7501471888393', 'EQ-TEC0550', 'Tiarotec 5 mg', 'TIAROTEC 5MG TAB C/20', 2, 37.25, 47, 'marca', 'Medicamentos', null, 'Tabletas', 'Tiarotec', 'Tecnofarma', 'Caja con 20 tabletas', 'Tiamazol', '5 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/tiarotec-5mg-c20-7501471888393.jpg', 'catalogo-propia/tiarotec-5mg-c20-7501471888393.jpg', '441133'),
  (12, '7502001167278', 'FC-01167278', 'Sinmison''s 2 mg', 'SINMISON''S 2MG TAB C/14', 2, 16.32, 21, 'marca', 'Medicamentos', 'Urología', 'Tabletas', 'Sinmison''s', 'Química Son''s', 'Caja con 14 tabletas', 'Tolterodina', '2 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/sinmison-2mg-c14-7502001167278.jpg', 'catalogo-propia/sinmison-2mg-c14-7502001167278.jpg', '26030903'),
  (13, '7502001167308', 'FC-01167308', 'Sinmison''s 2 mg', 'SINMISON''S 2MG TAB C/28', 2, 35.02, 44, 'marca', 'Medicamentos', 'Urología', 'Tabletas', 'Sinmison''s', 'Química Son''s', 'Caja con 28 tabletas', 'Tolterodina', '2 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/sinmison-2mg-c28-7502001167308.jpg', 'catalogo-propia/sinmison-2mg-c28-7502001167308.jpg', '26030903'),
  (14, '7501349021112', 'FC-49021112', 'Levetiracetam 500 mg', 'LEVETIRACETAM 500MG TAB C/60', 1, 97.51, 157, 'generico', 'Medicamentos', null, 'Tabletas', 'AMSA', 'AMSA', 'Caja con 60 tabletas', 'Levetiracetam', '500 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/levetiracetam-amsa-500mg-c60-7501349021112.jpg', 'catalogo-propia/levetiracetam-amsa-500mg-c60-7501349021112.jpg', 'U26Y100'),
  (15, '7506353200287', 'FC-53200287', 'Endoestat 10 g/100 mL', 'ENDOESTAT 10GR/100ML SOLUC 300ML', 1, 248.84, 312, 'marca', 'Medicamentos', null, 'Solución', 'Endoestat', 'Nucitec', 'Frasco 300 mL', 'Levetiracetam', '10 g/100 mL', true, false, 'https://www.farmacapital.mx/catalogo-propia/endoestat-10g-100ml-300ml-7506353200287.jpg', 'catalogo-propia/endoestat-10g-100ml-300ml-7506353200287.jpg', 'J692036');

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
  'Alta Farmaceuticos Tenorio 3811849 · 2026-10-15 · listo para pistola',
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
  from _fc_tn_3811849
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
  from _fc_tn_3811849
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
  from _fc_tn_3811849
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmaceuticos Tenorio',
  '3811849',
  '2026-10-15',
  1393.88,
  'borrador',
  'Factura Farmaceuticos Tenorio folio 3811849 · 15-oct-2026 22:58 · cliente 20077 Palillero Ventura · ref 2134457 · ruta Puebla · 1 caja · cola Recibir, stock al confirmar pistola y MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '3811849'
    and coalesce(proveedor, '') ilike '%tenorio%'
);

update public.recepciones
set
  total_ticket = 1393.88,
  fecha = '2026-10-15',
  proveedor = 'Farmaceuticos Tenorio',
  notas = 'Factura Farmaceuticos Tenorio folio 3811849 · 15-oct-2026 22:58 · cliente 20077 Palillero Ventura · ref 2134457 · ruta Puebla · 1 caja · cola Recibir, stock al confirmar pistola y MMAA',
  updated_at = now()
where folio = '3811849'
  and coalesce(proveedor, '') ilike '%tenorio%'
  and estado = 'borrador';

delete from public.recepcion_items
where recepcion_id in (
  select id
  from public.recepciones
  where folio = '3811849'
    and coalesce(proveedor, '') ilike '%tenorio%'
    and estado = 'borrador'
);

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
from _fc_tn_3811849 t
join public.recepciones r
  on r.id = (
    select id
    from public.recepciones
    where folio = '3811849'
      and coalesce(proveedor, '') ilike '%tenorio%'
      and estado = 'borrador'
    limit 1
  )
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
from _fc_tn_3811849 t
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
where r.folio = '3811849'
  and coalesce(r.proveedor, '') ilike '%tenorio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_tn_3811849 t
order by t.linea;

commit;
