-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Reintento: Cityfarma 15341570 + El Surtidor 161448 (17-nov-2026)
-- Si el editor quedó abortado por el intento anterior, la primera línea limpia la sesión.
-- Sin dollar-quote / sin producto_imagenes. Caducidad null → MMAA de la caja.
-- =============================================================================

rollback;

-- ========== Cityfarma Iztapalapa 15341570 ==========
-- Cityfarma · folio 15341570 · 2026-11-17 · total $6,982.85 · 28 renglones
-- 16 alta(s) stock 0. 12 ya estaban: solo costo / ficha vacia, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_cf_15341570 (
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

insert into _fc_cf_15341570 (
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
  (8, '7501165010826', 'FC-65010826', 'Enterogermina 4 billones', 'ENTEROGERMINA 4 BILL', 2, 442.76, 554, 'marca', 'Gastro', null, 'Ampolletas', 'Enterogermina', null, 'Caja con 10 ampolletas', 'Bacillus clausii', '4 billones UFC', false, false, null, null),
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
  'Alta Cityfarma Iztapalapa 15341570 · 2026-11-17 · listo para pistola',
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
  from _fc_cf_15341570
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
  from _fc_cf_15341570
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
  from _fc_cf_15341570
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
  'Cityfarma Iztapalapa',
  '15341570',
  '2026-11-17',
  6982.85,
  'borrador',
  'Cityfarma Iztapalapa · orden 15341570 · 17-nov-2026 10:37 · Eduardo Alcantara · cliente Luis Angel Palillero · 28 renglones · EANs validados por digito de control · Enterogermina 2 bill EAN canonico 3664798074680 · total = suma P.U. · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '15341570'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 6982.85,
  fecha = '2026-11-17',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Cityfarma Iztapalapa · orden 15341570 · 17-nov-2026 10:37 · Eduardo Alcantara · cliente Luis Angel Palillero · 28 renglones · EANs validados por digito de control · Enterogermina 2 bill EAN canonico 3664798074680 · total = suma P.U. · cola Recibir',
  updated_at = now()
where folio = '15341570'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '15341570'
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
from _fc_cf_15341570 t
join public.recepciones r
  on r.folio = '15341570'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
from _fc_cf_15341570 t
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



-- ========== VERIFICACION ==========
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
    (r.folio = '15341570' and coalesce(r.proveedor, '') ilike '%cityfarma%')
 or (r.folio = '161448' and coalesce(r.proveedor, '') ilike '%surtidor%')
)
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket
order by r.folio;
