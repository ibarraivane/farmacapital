-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Tickets 17-nov-2026 → cola Recibir (borrador).
-- Merge a GitHub NO los crea. Sin bloques dollar-quote. Sin producto_imagenes.
-- Caducidad null: MMAA de la caja. No inventar 0000.
-- Cada ticket es begin/commit independiente.
-- Al final: VERIFICACION FINAL con los 6 folios en borrador.
-- Luego: tablet Recibir → recargar → aparecen las tarjetas.
-- =============================================================================


-- ========== El Surtidor de su Farmacia 161443 ==========
-- El Surtidor · folio 161443 · 2026-11-17 · total $216.00 · 5 renglones · costo = importe neto
-- 0 alta(s) stock 0. 5 ya estaban: solo costo / ficha vacia, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_sur_161443 (
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
  imagen text,
  lote text
) on commit drop;

insert into _fc_sur_161443 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, '7501125149221', 'FC-25149221', 'Electrolit Fresa-Kiwi 625 ml', 'ELECTROLIT LIQ 625ML FRESA-KIWI', 2, 19.00, 24, 'marca', 'Suero oral', null, null, 'Electrolit', 'Pisa', 'Botella 625 ml', null, null, false, true, null, null),
  (2, '7501125104688', 'FC-25104688', 'Electrolit Naranja-Mandarina 625 ml', 'ELECTROLIT LIQ 625ML NARANJA-MANDARINA', 2, 19.00, 24, 'marca', 'Suero oral', null, null, 'Electrolit', 'Pisa', 'Botella 625 ml', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/electrolit-naranja-mandarina-625ml-7501125104688.jpg', null),
  (3, '7501125144851', 'FC-25144851', 'Electrolit Uva 625 ml', 'ELECTROLIT LIQ 625ML UVA', 2, 19.00, 24, 'marca', 'Suero oral', null, null, 'Electrolit', 'Pisa', 'Botella 625 ml', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/electrolit-uva-625ml-7501125144851.jpg', null),
  (4, '7501001157296', 'FC-01157296', 'Naturella flujo moderado', 'NATURELLA FLUJO MOD S/ALAS C/8', 5, 13.00, 17, 'marca', 'Higiene', null, 'Toallas sanitarias', 'Naturella', null, 'Caja con 8 toallas', null, null, false, true, null, null),
  (5, '7501001405335', 'FC-01405335', 'Naturella noche con alas', 'NATURELLA NOCHE CON ALAS C/8', 2, 18.50, 24, 'marca', 'Higiene', null, 'Toallas sanitarias', 'Naturella', null, 'Caja con 8 toallas', null, null, false, true, null, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when not exists (
      select 1 from public.productos p where p.sku = t.sku
    ) then t.sku
    when t.ean is not null and not exists (
      select 1 from public.productos p
      where p.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    when t.ean is not null then
      'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta El Surtidor de su Farmacia 161443 · 2026-11-17 · listo para pistola',
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
  from _fc_sur_161443
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  ))
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        t.ean is null
        or nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = (
      case
        when not exists (
          select 1 from public.productos x where x.sku = t.sku
        ) then t.sku
        when t.ean is not null and not exists (
          select 1 from public.productos x
          where x.sku = ('FC-ND-' || right(t.ean, 8))
        ) then 'FC-ND-' || right(t.ean, 8)
        when t.ean is not null then
          'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
        else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
      end
    )
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_sur_161443
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
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
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_sur_161443
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'El Surtidor de su Farmacia',
  '161443',
  '2026-11-17',
  216.00,
  'borrador',
  'El Surtidor · venta 161443 · Bodega F48 · 17-nov-2026 11:04 · Luis · Electrolit c/desc. mayoreo + Naturella · cola Recibir; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '161443'
    and coalesce(proveedor, '') ilike '%surtidor%'
);

update public.recepciones
set
  total_ticket = 216.00,
  fecha = '2026-11-17',
  proveedor = 'El Surtidor de su Farmacia',
  notas = 'El Surtidor · venta 161443 · Bodega F48 · 17-nov-2026 11:04 · Luis · Electrolit c/desc. mayoreo + Naturella · cola Recibir; MMAA de la caja',
  updated_at = now()
where folio = '161443'
  and coalesce(proveedor, '') ilike '%surtidor%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '161443'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
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
  t.snap,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_sur_161443 t
join public.recepciones r
  on r.folio = '161443'
 and coalesce(r.proveedor, '') ilike '%surtidor%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku),
    (
      select p2.id from public.productos p2
      where nullif(btrim(t.ean), '') is not null
        and nullif(btrim(p2.codigo_barras), '') = nullif(btrim(t.ean), '')
      order by p2.id
      limit 1
    ),
    (
      select p2.id from public.productos p2
      where p2.sku = t.sku
      order by p2.id
      limit 1
    )
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
where r.folio = '161443'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  t.lote,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku),
      (
        select p2.id from public.productos p2
        where t.ean is not null
          and nullif(btrim(p2.codigo_barras), '') = t.ean
        order by p2.id
        limit 1
      ),
      (
        select p2.id from public.productos p2
        where p2.sku = t.sku
        order by p2.id
        limit 1
      )
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_sur_161443 t
order by t.linea;

commit;


-- ========== Equilibrio 451922 ==========
-- Equilibrio · folio 451922 · 2026-11-17 · total $1,541.23 · 13 renglones / 70 pzas
-- 2 alta(s) stock 0. 11 ya estaban: solo costo / ficha vacia, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_eq_451922 (
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
  imagen text,
  lote text
) on commit drop;

insert into _fc_eq_451922 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, '0780083142308', 'FC-83142308', 'Tempire paracetamol gotas 100 mg/mL', 'COL090 TEMPIRE 1 GOT 100MG/30 ML', 3, 19.20, 31, 'generico', 'Medicamentos', 'Respiratorio', 'Gotas', 'Tempire', 'Collins', 'Frasco 30 mL con pipeta', 'Paracetamol', '100 mg/mL', false, true, null, '26141560'),
  (2, '0780083144302', 'FC-83144302', 'Collifrin Adulto oximetazolina 0.05%', 'COL145 COLLIFRIN ADULTO 1 SOL 50MG/20 ML', 6, 32.38, 52, 'generico', 'Medicamentos', 'Respiratorio', 'Solucion nasal', 'Collifrin', 'Collins', 'Frasco 20 mL', 'Oximetazolina', '0.05%', false, true, null, '26141294'),
  (3, '7502227426449', 'FC-7426449', 'Nesajar pinaverio/dimeticona 100/300 mg', 'GEP014 NESAJAR 16 CAPS 300/100 MG', 3, 111.21, 140, 'marca', 'Medicamentos', null, 'Capsulas', 'Nesajar', 'Gelpharma', 'Caja con 16 capsulas', 'Pinaverio / Dimeticona', '100 mg / 300 mg', true, true, null, '260274'),
  (4, '7501573902584', 'FC-73902584', 'Sarox omeprazol 20 mg', 'BIO067 SAROX 14 CAPS 20 MG', 10, 7.80, 10, 'marca', 'Medicamentos', null, 'Capsulas', 'Sarox', 'Biomep', 'Caja con 14 capsulas', 'Omeprazol', '20 mg', true, true, null, 'SH26006'),
  (5, '7502227426869', 'EQ-VIT055', 'Rotumal diclofenaco gel 1.16%', 'VIT055 ROTUMAL 1 GEL 60G/1.16 %', 2, 23.02, 29, 'marca', 'Medicamentos', null, 'Gel', 'Rotumal', 'Vitae', 'Tubo 60 g', 'Diclofenaco', '1.16%', false, true, null, '261306'),
  (6, '7502009746321', 'EQ-MAV300', 'Nisolver prednisolona 1 mg/mL', 'MAV300 NISOLVER 1 SOL 100 ML', 5, 69.42, 87, 'marca', 'Medicamentos', null, 'Solucion oral', 'Nisolver', 'Maver', 'Frasco 100 mL', 'Prednisolona', '1 mg/mL', true, true, 'https://www.farmacapital.mx/catalogo-propia/nisolver-prednisolona-1mg-ml-100ml-7502009746321.jpg', '260451'),
  (7, '7501349022515', 'FC-22B18244', 'Cefotaxima IM 1 g/4 mL', 'AMS263 CEFOTAXIMA I.M. 1 FA 1G/4 ML', 5, 32.33, 52, 'generico', 'Medicamentos', null, 'Solucion inyectable', 'AMSA', 'AMSA', 'Frasco ampula 1 g/4 mL', 'Cefotaxima', '1 g/4 mL', true, true, null, 'J2611085'),
  (8, null, 'EQ-ALP0607', 'Diclofenaco 75 mg/3 mL C/2 ampolletas', 'ALP0607 DICLOFENACO 2 AMP 75MG/3 ML', 2, 16.19, 26, 'generico', 'Medicamentos', null, 'Solucion inyectable', 'Alpharma', 'Alpharma', 'Caja con 2 ampolletas de 3 mL', 'Diclofenaco sodico', '75 mg/3 mL', true, false, null, '2601498'),
  (9, '7501573909859', 'FC-73909859', 'Sarox omeprazol 20 mg', 'BIO213 SAROX 28 CAPS 20 MG', 5, 14.39, 18, 'marca', 'Medicamentos', null, 'Capsulas', 'Sarox', 'Biomep', 'Caja con 28 capsulas', 'Omeprazol', '20 mg', true, true, null, 'SH26113'),
  (10, '7502227870532', 'EQ-RAM038', 'Voydol ketorolaco 10 mg', 'RAM038 VOYDOL 10 TAB 10 MG', 5, 5.72, 8, 'marca', 'Medicamentos', null, 'Tabletas', 'Voydol', 'Raam', 'Caja con 10 tabletas', 'Ketorolaco', '10 mg', true, true, null, 'RVD0226'),
  (11, '7501349024267', 'EQ-AMS328', 'Ketorolaco 30 mg/1 mL C/3 ampolletas', 'AMS328 KETOROLACO 3 AMP 30 MG', 4, 11.05, 18, 'generico', 'Medicamentos', null, 'Solucion inyectable', 'AMSA', 'AMSA', 'Caja con 3 ampolletas de 1 mL', 'Ketorolaco trometamina', '30 mg/1 mL', true, true, null, '2611001'),
  (12, '7501349023369', 'EQ-AMS160', 'Ketorolaco sublingual 30 mg C/6', 'AMS160 KETOROLACO TROMETAMINA 6 TAB SL 30 MG', 10, 8.99, 15, 'generico', 'Medicamentos', null, 'Tableta sublingual', 'AMSA', 'AMSA', 'Caja con 6 tabletas sublinguales', 'Ketorolaco trometamina', '30 mg', true, true, null, 'U26Y032'),
  (13, '7501349024328', 'EQ-AMS496', 'Ketorolaco sublingual 30 mg C/4', 'AMS496 KETOROLACO SL 4 TAB 30 MG', 10, 5.59, 9, 'generico', 'Medicamentos', null, 'Tableta sublingual', 'AMSA', 'AMSA', 'Caja con 4 tabletas sublinguales', 'Ketorolaco trometamina', '30 mg', true, false, null, 'U26F370');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when not exists (
      select 1 from public.productos p where p.sku = t.sku
    ) then t.sku
    when t.ean is not null and not exists (
      select 1 from public.productos p
      where p.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    when t.ean is not null then
      'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Equilibrio 451922 · 2026-11-17 · listo para pistola',
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
  from _fc_eq_451922
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  ))
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        t.ean is null
        or nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = (
      case
        when not exists (
          select 1 from public.productos x where x.sku = t.sku
        ) then t.sku
        when t.ean is not null and not exists (
          select 1 from public.productos x
          where x.sku = ('FC-ND-' || right(t.ean, 8))
        ) then 'FC-ND-' || right(t.ean, 8)
        when t.ean is not null then
          'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
        else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
      end
    )
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_eq_451922
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
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
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_eq_451922
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '451922',
  '2026-11-17',
  1541.23,
  'borrador',
  'Equilibrio Iztapalapa 2 · ticket 451922 · pedido online · 17-nov-2026 10:53 · cliente 307513 Luis Angel Palillero · costo = P.U. neto · lote de fabrica; caducidad NO (MMAA de la caja) · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '451922'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 1541.23,
  fecha = '2026-11-17',
  proveedor = 'Equilibrio',
  notas = 'Equilibrio Iztapalapa 2 · ticket 451922 · pedido online · 17-nov-2026 10:53 · cliente 307513 Luis Angel Palillero · costo = P.U. neto · lote de fabrica; caducidad NO (MMAA de la caja) · cola Recibir',
  updated_at = now()
where folio = '451922'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '451922'
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
  coalesce(nullif(btrim(t.ean), ''), t.sku),
  t.snap,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_eq_451922 t
join public.recepciones r
  on r.folio = '451922'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku),
    (
      select p2.id from public.productos p2
      where nullif(btrim(t.ean), '') is not null
        and nullif(btrim(p2.codigo_barras), '') = nullif(btrim(t.ean), '')
      order by p2.id
      limit 1
    ),
    (
      select p2.id from public.productos p2
      where p2.sku = t.sku
      order by p2.id
      limit 1
    )
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
where r.folio = '451922'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  t.lote,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku),
      (
        select p2.id from public.productos p2
        where t.ean is not null
          and nullif(btrim(p2.codigo_barras), '') = t.ean
        order by p2.id
        limit 1
      ),
      (
        select p2.id from public.productos p2
        where p2.sku = t.sku
        order by p2.id
        limit 1
      )
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_eq_451922 t
order by t.linea;

commit;


-- ========== IFC 134202 ==========
-- IFC · folio 134202 · 2026-11-17 · total $372.00 · 4 renglones / 6 pzas
-- 4 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacia, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_ifc_134202 (
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
  imagen text,
  lote text
) on commit drop;

insert into _fc_ifc_134202 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, null, 'FC-MIY-RANA-MED', 'Miyako ferula para dedo tipo rana mediana', 'MIYAKO FERULA PARA DEDO TIPO RANA MED 22087', 2, 62.00, 78, 'marca', 'Botiquin', null, 'Ferula', 'Miyako', null, '1 pieza mediana', null, null, false, false, null, null),
  (2, null, 'FC-MIY-RECTA-CH', 'Miyako ferula para dedo recta chica', 'MIYAKO FERULA PARA DEDO RECTA CHICA 22089', 1, 62.00, 78, 'marca', 'Botiquin', null, 'Ferula', 'Miyako', null, '1 pieza chica', null, null, false, false, null, null),
  (3, '0750187760234', 'FC-87760234', 'Miyako ferula para dedo recta grande', 'MIYAKO FERULA PARA DEDO RECTA GRANDE 81979', 1, 62.00, 78, 'marca', 'Botiquin', null, 'Ferula', 'Miyako', null, '1 pieza grande', null, null, false, false, null, null),
  (4, null, 'FC-MIY-RECTA-MED', 'Miyako ferula para dedo recta mediana', 'MIYAKO FERULA PARA DEDO RECTA MEDIANA', 2, 62.00, 78, 'marca', 'Botiquin', null, 'Ferula', 'Miyako', null, '1 pieza mediana', null, null, false, false, null, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when not exists (
      select 1 from public.productos p where p.sku = t.sku
    ) then t.sku
    when t.ean is not null and not exists (
      select 1 from public.productos p
      where p.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    when t.ean is not null then
      'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta IFC 134202 · 2026-11-17 · listo para pistola',
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
  from _fc_ifc_134202
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  ))
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        t.ean is null
        or nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = (
      case
        when not exists (
          select 1 from public.productos x where x.sku = t.sku
        ) then t.sku
        when t.ean is not null and not exists (
          select 1 from public.productos x
          where x.sku = ('FC-ND-' || right(t.ean, 8))
        ) then 'FC-ND-' || right(t.ean, 8)
        when t.ean is not null then
          'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
        else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
      end
    )
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_ifc_134202
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
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
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_ifc_134202
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC',
  '134202',
  '2026-11-17',
  372.00,
  'borrador',
  'IFC F8 Tienda · CJ 01 Fol 134202 · 17-nov-2026 11:38 · Luis · efectivo · Miyako ferulas mayoreo · cola Recibir; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '134202'
    and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set
  total_ticket = 372.00,
  fecha = '2026-11-17',
  proveedor = 'IFC',
  notas = 'IFC F8 Tienda · CJ 01 Fol 134202 · 17-nov-2026 11:38 · Luis · efectivo · Miyako ferulas mayoreo · cola Recibir; MMAA de la caja',
  updated_at = now()
where folio = '134202'
  and coalesce(proveedor, '') ilike '%ifc%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '134202'
  and coalesce(r.proveedor, '') ilike '%ifc%'
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
  t.snap,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_ifc_134202 t
join public.recepciones r
  on r.folio = '134202'
 and coalesce(r.proveedor, '') ilike '%ifc%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku),
    (
      select p2.id from public.productos p2
      where nullif(btrim(t.ean), '') is not null
        and nullif(btrim(p2.codigo_barras), '') = nullif(btrim(t.ean), '')
      order by p2.id
      limit 1
    ),
    (
      select p2.id from public.productos p2
      where p2.sku = t.sku
      order by p2.id
      limit 1
    )
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
where r.folio = '134202'
  and coalesce(r.proveedor, '') ilike '%ifc%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  t.lote,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku),
      (
        select p2.id from public.productos p2
        where t.ean is not null
          and nullif(btrim(p2.codigo_barras), '') = t.ean
        order by p2.id
        limit 1
      ),
      (
        select p2.id from public.productos p2
        where p2.sku = t.sku
        order by p2.id
        limit 1
      )
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_ifc_134202 t
order by t.linea;

commit;


-- ========== Farma Mayoreo V01000004500 ==========
-- Farma Mayoreo · folio V01000004500 · 2026-11-17 · total $1,625.91
-- P.U. con IVA. Suma renglones = total.
-- 6 alta(s) stock 0. 1 ya estaban: solo costo / ficha vacia, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_fm_4500 (
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
  imagen text,
  lote text
) on commit drop;

insert into _fc_fm_4500 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, '7501088575396', 'FC-88575396', 'Troferit 3 mg/mL jarabe 120 mL', 'TROFERIT 3MG/ML CON FRASCO 120ML', 1, 144.97, 182, 'marca', 'Medicamentos', null, 'Jarabe', 'Troferit', null, 'Frasco 120 mL', 'Levodropropizina', '3 mg/mL', true, false, null, 'BFG058'),
  (2, '7501037907117', 'FC-7907117', 'Bisolvon solucion adulto 120 mL', 'BISOLVON SOLUCION ADULTO FRASCO CON 120 ML', 2, 146.98, 184, 'marca', 'Medicamentos', null, 'Solucion', 'Bisolvon', 'Sanofi', 'Frasco 120 mL', 'Bromhexina', '160 mg/100 mL', false, true, null, '23980029'),
  (3, '7501159580182', 'FC-59580182', 'Sinuberase probioticos 4 billones', 'SINUBERASE PROBIOTICOS CAJA CON 10 AMPOLLETAS', 3, 217.98, 273, 'marca', 'Gastro', null, 'Ampolletas', 'Sinuberase', null, 'Caja con 10 ampolletas', 'Bacillus clausii', '4 billones UFC', false, false, null, '61175'),
  (4, '7501089810526', 'FC-89810526', 'Picosend amoniaco 3.5%', 'PICOSEND AMONIACO SOLUCION 3.5% TUBO CON 11 ML', 2, 73.98, 93, 'marca', 'Botiquin', null, 'Solucion', 'Picosend', null, 'Tubo 11 mL', null, '3.5%', false, false, null, null),
  (5, '7501089810625', 'FC-89810625', 'Picosend Protect repelente 120 mL', 'PICOSEND PROTECT REPELENTE 120ML', 2, 81.98, 103, 'marca', 'Botiquin', null, 'Repelente', 'Picosend', null, 'Frasco 120 mL', null, null, false, false, null, null),
  (6, '75012571', 'FC-75012571', 'Picosend Protect travel 50 mL', 'REPEL PICOSEND PROTECT TRAVE 50 ML', 3, 38.98, 49, 'marca', 'Botiquin', null, 'Repelente', 'Picosend', null, 'Frasco 50 mL', null, null, false, false, null, null),
  (7, '7501299368145', 'FC-99368145', 'Sensibit D NF', 'SENSIBIT D NF 2X1', 2, 52.09, 66, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Sensibit', null, '2x1', null, null, false, false, null, '010484');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when not exists (
      select 1 from public.productos p where p.sku = t.sku
    ) then t.sku
    when t.ean is not null and not exists (
      select 1 from public.productos p
      where p.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    when t.ean is not null then
      'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Farma Mayoreo V01000004500 · 2026-11-17 · listo para pistola',
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
  from _fc_fm_4500
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  ))
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        t.ean is null
        or nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = (
      case
        when not exists (
          select 1 from public.productos x where x.sku = t.sku
        ) then t.sku
        when t.ean is not null and not exists (
          select 1 from public.productos x
          where x.sku = ('FC-ND-' || right(t.ean, 8))
        ) then 'FC-ND-' || right(t.ean, 8)
        when t.ean is not null then
          'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
        else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
      end
    )
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_fm_4500
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
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
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_fm_4500
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farma Mayoreo',
  'V01000004500',
  '2026-11-17',
  1625.91,
  'borrador',
  'Farma Mayoreo · ID Venta V01000004500 · 17-nov-2026 11:31 · TC BBVA $1,625.91 · P.U. ya traen IVA (suma renglones = total) · lote de fabrica; caducidad NO · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = 'V01000004500'
    and coalesce(proveedor, '') ilike '%farma mayoreo%'
);

update public.recepciones
set
  total_ticket = 1625.91,
  fecha = '2026-11-17',
  proveedor = 'Farma Mayoreo',
  notas = 'Farma Mayoreo · ID Venta V01000004500 · 17-nov-2026 11:31 · TC BBVA $1,625.91 · P.U. ya traen IVA (suma renglones = total) · lote de fabrica; caducidad NO · cola Recibir',
  updated_at = now()
where folio = 'V01000004500'
  and coalesce(proveedor, '') ilike '%farma mayoreo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'V01000004500'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
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
  t.snap,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_fm_4500 t
join public.recepciones r
  on r.folio = 'V01000004500'
 and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku),
    (
      select p2.id from public.productos p2
      where nullif(btrim(t.ean), '') is not null
        and nullif(btrim(p2.codigo_barras), '') = nullif(btrim(t.ean), '')
      order by p2.id
      limit 1
    ),
    (
      select p2.id from public.productos p2
      where p2.sku = t.sku
      order by p2.id
      limit 1
    )
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
where r.folio = 'V01000004500'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  t.lote,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku),
      (
        select p2.id from public.productos p2
        where t.ean is not null
          and nullif(btrim(p2.codigo_barras), '') = t.ean
        order by p2.id
        limit 1
      ),
      (
        select p2.id from public.productos p2
        where p2.sku = t.sku
        order by p2.id
        limit 1
      )
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_fm_4500 t
order by t.linea;

commit;


-- ========== Farmaceuticos Tenorio 15341570 ==========
-- Tenorio · folio 15341570 · 2026-11-17 · total $6,982.85 · 28 renglones
-- 16 alta(s) stock 0. 12 ya estaban: solo costo / ficha vacia, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_tn_15341570 (
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
  imagen text,
  lote text
) on commit drop;

insert into _fc_tn_15341570 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, '7501070613044', 'FC-70613044', 'Andantol isotipendilo jalea 25 g', 'ANDANTOL 25GR JALEA', 2, 173.80, 218, 'marca', 'Dermatologia', null, 'Jalea', 'Andantol', 'Sanfer', 'Tubo 25 g', 'Isotipendilo', '0.75 g/100 g', false, false, null, null),
  (2, '7841141004068', 'FC-41104068', 'Arluy Duo 200/300 mg', 'ARLUY DUO 200MG/300MG', 1, 682.02, 853, 'marca', 'Medicamentos', null, 'Tabletas', 'Arluy Duo', null, 'Caja', null, '200 mg / 300 mg', true, false, null, null),
  (3, '7506331301142', 'FC-31301142', 'Autevazen 500 mg', 'AUTEVAZEN 500MG C60', 1, 83.52, 105, 'marca', 'Medicamentos', null, 'Capsulas', 'Autevazen', null, 'Caja con 60 capsulas', null, '500 mg', true, false, null, null),
  (4, '7501008409572', 'FC-08409572', 'Berocca Cal Mag', 'BEROCCA CAL MAG C 10', 1, 144.05, 181, 'marca', 'Suplementos', null, 'Tabletas efervescentes', 'Berocca', null, 'Caja con 10 tabletas', null, null, false, false, null, null),
  (5, '0714706903359', 'FC-06903359', 'Bronco Rub exhalador C/12', 'BRONCO RUB EXH C12 P', 1, 133.35, 167, 'marca', 'Botiquin', null, 'Pastillas', 'Bronco Rub', null, 'Caja con 12 pastillas', null, null, false, false, null, null),
  (6, '7501065095718', 'FC-65095718', 'Centrum Balance', 'CENTRUM BALANCE C30T', 1, 136.52, 171, 'marca', 'Suplementos', null, 'Tabletas', 'Centrum', null, 'Frasco con 30 tabletas', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/centrum-balance-30-tabletas-7501065095718.jpg', null),
  (7, '3664798074680', 'FC-79807468', 'Enterogermina 2 billones', 'ENTEROGERMINA 2 BILL', 3, 200.00, 250, 'marca', 'Gastro', null, 'Ampolletas', 'Enterogermina', null, 'Caja con 10 ampolletas', 'Bacillus clausii', '2 billones UFC', false, true, null, null),
  (8, '7501165010628', 'FC-15010628', 'Enterogermina 4 billones', 'ENTEROGERMINA 4 BILL', 2, 442.76, 554, 'marca', 'Gastro', null, 'Ampolletas', 'Enterogermina', null, 'Caja con 10 ampolletas', 'Bacillus clausii', '4 billones UFC', false, false, null, null),
  (9, '7502009740916', 'FC-50AC2C82', 'Erispan Hypack 8 mg/2 ml', 'ERISPAN HYPACK 8MG/2', 5, 24.80, 31, 'marca', 'Medicamentos', null, 'Solucion inyectable', 'Erispan', 'Maver', 'Frasco ampula 2 ml', 'Betametasona', '8 mg/2 ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/erispan-hypack-8mg-7502009740916.jpg', null),
  (10, '7501159525015', 'FC-9525015', 'Eucaliptine jarabe 140 ml', 'EUCALIPTINE JBE 140', 1, 141.56, 177, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Eucaliptine', null, 'Frasco 140 ml', null, null, false, true, null, null),
  (11, '7501300421968', 'FC-00421968', 'Exbufen apixaban', 'EXBUFEN APIXABAN TAB', 2, 166.67, 209, 'marca', 'Medicamentos', null, 'Tabletas', 'Exbufen', null, 'Caja', 'Apixaban', null, true, false, null, null),
  (12, '7501008497340', 'FC-84973401', 'Flanax 550 mg', 'FLANAX 550 C 12 TABS', 2, 173.02, 217, 'marca', 'Medicamentos', null, 'Tabletas', 'Flanax', null, 'Caja con 12 tabletas', 'Naproxeno sodico', '550 mg', false, true, 'https://www.farmacapital.mx/catalogo-propia/flanax-550mg-12tab-7501008497340.jpg', null),
  (13, '7501008498866', 'FC-08498866', 'Flanax 550 mg', 'FLANAX 550MG C6 TABS', 2, 98.16, 123, 'marca', 'Medicamentos', null, 'Tabletas', 'Flanax', null, 'Caja con 6 tabletas', 'Naproxeno sodico', '550 mg', false, true, 'https://www.farmacapital.mx/catalogo-propia/flanax-550mg-6tab-7501008498866.jpg', null),
  (14, '0780083148966', 'FC-83148966', 'Gelmicin crema 40 g', 'GELMICIN CRA 40G BE', 3, 21.71, 28, 'marca', 'Dermatologia', null, 'Crema', 'Gelmicin', null, 'Tubo 40 g', null, null, false, false, null, null),
  (15, '3664798073256', 'FC-98073256', 'Histiacil GR3 ambroxol', 'HISTIACIL GR3 AMBROX', 1, 121.18, 152, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Histiacil', 'Opella', 'Frasco', 'Ambroxol', null, false, true, null, null),
  (16, '3664798073232', 'FC-98073232', 'Histiacil GR3 ambroxol', 'HISTIACIL GR3 AMBROX', 1, 121.18, 152, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Histiacil', 'Opella', 'Frasco', 'Ambroxol', null, false, false, null, null),
  (17, '7501064560163', 'FC-64560163', 'Iodex Cristal', 'IODEX CRISTAL 24', 3, 71.99, 90, 'marca', 'Botiquin', null, 'Unguento', 'Iodex', null, '60 g', null, null, false, true, null, null),
  (18, '7501349024328', 'EQ-AMS496', 'Ketorolaco sublingual 30 mg C/4', 'KETOROLACO 30MG C/4', 8, 6.49, 11, 'generico', 'Medicamentos', null, 'Tableta sublingual', 'AMSA', 'AMSA', 'Caja con 4 tabletas sublinguales', 'Ketorolaco trometamina', '30 mg', true, false, null, null),
  (19, '7501349023369', 'EQ-AMS160', 'Ketorolaco sublingual 30 mg C/6', 'KETOROLACO 30MG C6 T', 5, 9.98, 16, 'generico', 'Medicamentos', null, 'Tableta sublingual', 'AMSA', 'AMSA', 'Caja con 6 tabletas sublinguales', 'Ketorolaco trometamina', '30 mg', true, true, null, null),
  (20, '7501075713176', 'FC-75713176', 'Lamblit 500 mg', 'LAMBLIT 500 MG C 30', 5, 18.28, 23, 'marca', 'Medicamentos', null, 'Tabletas', 'Lamblit', null, 'Caja con 30 tabletas', null, '500 mg', true, false, null, null),
  (21, '7502001161627', 'EQ-SON083', 'Lisonin 600 mg/2 ml', 'LISONIN 600 MG C 1 A', 3, 31.48, 40, 'marca', 'Medicamentos', null, 'Solucion inyectable', 'Lisonin', 'Sons', 'Ampolleta 2 ml', 'Lincomicina', '600 mg/2 ml', true, true, null, null),
  (22, '7502001161641', 'FC-01161641', 'Lisonin 600 mg solucion inyectable', 'LISONIN 600MG SOL I', 3, 56.13, 71, 'marca', 'Medicamentos', null, 'Solucion inyectable', 'Lisonin', 'Sons', 'Ampolleta', 'Lincomicina', '600 mg', true, false, null, null),
  (23, '7501258214766', 'FC-58214766', 'Menirol', 'MENIROL C28T 10 24', 2, 95.12, 119, 'marca', 'Medicamentos', null, 'Tabletas', 'Menirol', null, 'Caja con 28 tabletas', null, null, false, false, null, null),
  (24, '7501007535487', 'FC-07535487', 'Motrin gotas pediatricas', 'MOTRIN GTS PED FSA', 1, 113.76, 143, 'marca', 'Medicamentos', null, 'Gotas', 'Motrin', null, 'Frasco', 'Ibuprofeno', null, false, false, null, null),
  (25, '7501537102395', 'FMX-502376', 'Norapred 50 mg', 'NORAPRED 50MG C20 PR', 5, 30.88, 50, 'generico', 'Medicamentos', null, 'Tabletas', 'Norapred', 'Brudifarma', 'Caja con 20 tabletas', 'Prednisolona', '50 mg', true, true, null, null),
  (26, '7502235760672', 'FC-35760672', 'Sienna suplemento alimenticio', 'SIENNA SUPLEM ALIM C', 1, 1048.94, 1312, 'marca', 'Suplementos', null, 'Suplemento', 'Sienna', null, 'Caja', null, null, false, false, null, null),
  (27, '7501349029729', 'FC-49029729', 'Telmisartan/hidroclorotiazida', 'TELMISARTAN HIDROCLO', 2, 42.74, 69, 'generico', 'Medicamentos', null, 'Tabletas', 'AMSA', 'AMSA', 'Caja', 'Telmisartan / Hidroclorotiazida', null, true, false, null, null),
  (28, '7590002012468', 'FC-02012468', 'Vicks VapoRub 50 g', 'VAPORUB 50GR TARRO', 3, 85.56, 107, 'marca', 'Botiquin', null, 'Unguento', 'Vicks', null, 'Tarro 50 g', null, null, false, true, null, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when not exists (
      select 1 from public.productos p where p.sku = t.sku
    ) then t.sku
    when t.ean is not null and not exists (
      select 1 from public.productos p
      where p.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    when t.ean is not null then
      'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Farmaceuticos Tenorio 15341570 · 2026-11-17 · listo para pistola',
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
  from _fc_tn_15341570
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  ))
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        t.ean is null
        or nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = (
      case
        when not exists (
          select 1 from public.productos x where x.sku = t.sku
        ) then t.sku
        when t.ean is not null and not exists (
          select 1 from public.productos x
          where x.sku = ('FC-ND-' || right(t.ean, 8))
        ) then 'FC-ND-' || right(t.ean, 8)
        when t.ean is not null then
          'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
        else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
      end
    )
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_tn_15341570
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
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
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_tn_15341570
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmaceuticos Tenorio',
  '15341570',
  '2026-11-17',
  6982.85,
  'borrador',
  'Farmaceuticos Tenorio · folio 15341570 · 17-nov-2026 10:37 · 28 renglones · EANs validados por digito de control · Enterogermina 2 bill EAN canonico 3664798074680 · total = suma P.U. · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '15341570'
    and coalesce(proveedor, '') ilike '%tenorio%'
);

update public.recepciones
set
  total_ticket = 6982.85,
  fecha = '2026-11-17',
  proveedor = 'Farmaceuticos Tenorio',
  notas = 'Farmaceuticos Tenorio · folio 15341570 · 17-nov-2026 10:37 · 28 renglones · EANs validados por digito de control · Enterogermina 2 bill EAN canonico 3664798074680 · total = suma P.U. · cola Recibir',
  updated_at = now()
where folio = '15341570'
  and coalesce(proveedor, '') ilike '%tenorio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '15341570'
  and coalesce(r.proveedor, '') ilike '%tenorio%'
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
  t.snap,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_tn_15341570 t
join public.recepciones r
  on r.folio = '15341570'
 and coalesce(r.proveedor, '') ilike '%tenorio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku),
    (
      select p2.id from public.productos p2
      where nullif(btrim(t.ean), '') is not null
        and nullif(btrim(p2.codigo_barras), '') = nullif(btrim(t.ean), '')
      order by p2.id
      limit 1
    ),
    (
      select p2.id from public.productos p2
      where p2.sku = t.sku
      order by p2.id
      limit 1
    )
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
where r.folio = '15341570'
  and coalesce(r.proveedor, '') ilike '%tenorio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  t.lote,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku),
      (
        select p2.id from public.productos p2
        where t.ean is not null
          and nullif(btrim(p2.codigo_barras), '') = t.ean
        order by p2.id
        limit 1
      ),
      (
        select p2.id from public.productos p2
        where p2.sku = t.sku
        order by p2.id
        limit 1
      )
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_tn_15341570 t
order by t.linea;

commit;


-- ========== El Surtidor de su Farmacia 161448 ==========
-- El Surtidor · folio 161448 · 2026-11-17 · total $334.00 · 2 renglones
-- 2 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacia, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_sur_161448 (
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
  imagen text,
  lote text
) on commit drop;

insert into _fc_sur_161448 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, '7501102614506', 'FC-02614506', 'Kola Loka brocha', 'KOLA LOKA BROCHA C/8', 1, 167.00, 209, 'marca', 'Botiquin', null, 'Pegamento', 'Kola Loka', null, 'Caja con 8 piezas', null, null, false, false, null, null),
  (2, '7501102611000', 'FC-02611000', 'Kola Loka gota', 'KOLA LOKA C/10 GOTA', 1, 167.00, 209, 'marca', 'Botiquin', null, 'Pegamento', 'Kola Loka', null, 'Caja con 10 goteros', null, null, false, false, null, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when not exists (
      select 1 from public.productos p where p.sku = t.sku
    ) then t.sku
    when t.ean is not null and not exists (
      select 1 from public.productos p
      where p.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    when t.ean is not null then
      'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta El Surtidor de su Farmacia 161448 · 2026-11-17 · listo para pistola',
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
  from _fc_sur_161448
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  ))
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        t.ean is null
        or nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = (
      case
        when not exists (
          select 1 from public.productos x where x.sku = t.sku
        ) then t.sku
        when t.ean is not null and not exists (
          select 1 from public.productos x
          where x.sku = ('FC-ND-' || right(t.ean, 8))
        ) then 'FC-ND-' || right(t.ean, 8)
        when t.ean is not null then
          'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
        else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
      end
    )
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_sur_161448
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
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
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_sur_161448
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'El Surtidor de su Farmacia',
  '161448',
  '2026-11-17',
  334.00,
  'borrador',
  'El Surtidor · venta 161448 · Bodega F48 · 17-nov-2026 11:09 · Luis · Kola Loka brocha + gota (16% IVA incluido en P.U.) · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '161448'
    and coalesce(proveedor, '') ilike '%surtidor%'
);

update public.recepciones
set
  total_ticket = 334.00,
  fecha = '2026-11-17',
  proveedor = 'El Surtidor de su Farmacia',
  notas = 'El Surtidor · venta 161448 · Bodega F48 · 17-nov-2026 11:09 · Luis · Kola Loka brocha + gota (16% IVA incluido en P.U.) · cola Recibir',
  updated_at = now()
where folio = '161448'
  and coalesce(proveedor, '') ilike '%surtidor%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '161448'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
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
  t.snap,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_sur_161448 t
join public.recepciones r
  on r.folio = '161448'
 and coalesce(r.proveedor, '') ilike '%surtidor%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku),
    (
      select p2.id from public.productos p2
      where nullif(btrim(t.ean), '') is not null
        and nullif(btrim(p2.codigo_barras), '') = nullif(btrim(t.ean), '')
      order by p2.id
      limit 1
    ),
    (
      select p2.id from public.productos p2
      where p2.sku = t.sku
      order by p2.id
      limit 1
    )
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
where r.folio = '161448'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  t.lote,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku),
      (
        select p2.id from public.productos p2
        where t.ean is not null
          and nullif(btrim(p2.codigo_barras), '') = t.ean
        order by p2.id
        limit 1
      ),
      (
        select p2.id from public.productos p2
        where p2.sku = t.sku
        order by p2.id
        limit 1
      )
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_sur_161448 t
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
    (r.folio = '161443' and coalesce(r.proveedor, '') ilike '%surtidor%')
 or (r.folio = '451922' and coalesce(r.proveedor, '') ilike '%equilibrio%')
 or (r.folio = '134202' and coalesce(r.proveedor, '') ilike '%ifc%')
 or (r.folio = 'V01000004500' and coalesce(r.proveedor, '') ilike '%farma mayoreo%')
 or (r.folio = '15341570' and coalesce(r.proveedor, '') ilike '%tenorio%')
 or (r.folio = '161448' and coalesce(r.proveedor, '') ilike '%surtidor%')
)
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket
order by r.folio;
