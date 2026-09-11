-- ============================================================================
-- Farmalive ticket 97 — altas de lo que Recibir marcó «Pendiente de alta»
-- + re-enlace de Suerox (el ticket trae EAN sin dígito verificador).
--
-- Stock 0: entra al escanear con pistola + MMAA de la caja (no inventar 0000).
-- PVP = ceil(costo × 1.25) marca, salvo Pharmaton promo (costo $0.01 → PVP mercado).
-- Fotos en public/catalogo-propia/ → https://www.farmacapital.mx/catalogo-propia/…
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temp table _fc_alta_fl97 (
  ean text primary key,
  sku text not null,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  forma_farmaceutica text,
  categoria text not null,
  subcategoria text,
  descripcion text not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  requiere_receta boolean not null default false,
  foto text
) on commit drop;

insert into _fc_alta_fl97 values
  (
    '7501165011656', 'FC-65011656',
    'Buscapina Fem hioscina 20 mg / ibuprofeno 400 mg 10 tabletas',
    'Buscapina', 'Caja con 10 tabletas', 'Tableta',
    'Medicamentos', 'Analgésico / antiespasmódico',
    'Farmalive 97 · ficha Sanofi/Opella · cólico menstrual · EAN 7501165011656',
    130.34, 163, false,
    'https://www.farmacapital.mx/catalogo-propia/buscapina-fem-10-tab.jpg'
  ),
  (
    '7501868950702', 'FC-68950702',
    'Vaso recolector de muestras Dibar 100 ml',
    'Dibar', 'Vaso 100 ml', 'Dispositivo',
    'Curación', 'Material de curación',
    'Farmalive 97 · vaso recolector Dibar · EAN 7501868950702 · foto pendiente',
    5.00, 7, false,
    null
  ),
  (
    '7501080921139', 'FC-80921139',
    'Nair crema depilatoria piel sensible 150 ml',
    'Nair', 'Tubo 150 ml', 'Crema',
    'Cuidado personal', 'Depilación',
    'Farmalive 97 · Church & Dwight · EAN 7501080921139',
    81.60, 102, false,
    'https://www.farmacapital.mx/catalogo-propia/nair-piel-sensible-150ml.jpg'
  ),
  (
    '7503006698316', 'FC-06698316',
    'Microdacyn 60 solución antiséptica 120 ml',
    'Microdacyn', 'Spray 120 ml', 'Solución',
    'Curación', 'Antiséptico',
    'Farmalive 97 · More Pharma / Sanfer · ácido hipocloroso · EAN 7503006698316',
    168.56, 211, false,
    'https://www.farmacapital.mx/catalogo-propia/microdacyn-60-solucion-120ml.jpg'
  ),
  (
    '037836041358', 'FC-36041358',
    'Hinds crema corporal Natural piel reseca 230 ml',
    'Hinds', 'Frasco 230 ml', 'Crema',
    'Cuidado personal', 'Crema corporal',
    'Farmalive 97 · Grisi · ficha hinds.com.mx Natural 230 ml · EAN 037836041358',
    35.28, 45, false,
    'https://www.farmacapital.mx/catalogo-propia/hinds-natural-230ml.jpg'
  ),
  (
    '037836041266', 'FC-36041266',
    'Hinds crema corporal Clásica Rosa piel reseca 230 ml',
    'Hinds', 'Frasco 230 ml', 'Crema',
    'Cuidado personal', 'Crema corporal',
    'Farmalive 97 · Grisi · ficha hinds.com.mx Clásica 230 ml · EAN 037836041266',
    35.28, 45, false,
    'https://www.farmacapital.mx/catalogo-propia/hinds-clasica-rosa-230ml.jpg'
  ),
  (
    '7501086494286', 'FC-86494286',
    'Oral-B cepillo dental Clásico 60 cerdas suaves',
    'Oral-B', '1 cepillo', 'Cepillo dental',
    'Cuidado personal', 'Higiene bucal',
    'Farmalive 97 · P&G Oral-B Clásico 60 suave · EAN 7501086494286 · foto pendiente',
    22.93, 29, false,
    null
  ),
  (
    '7501006719932', 'FC-06719932',
    'Oral-B cepillo dental Complet mediano 2×1',
    'Oral-B', '2 cepillos', 'Cepillo dental',
    'Cuidado personal', 'Higiene bucal',
    'Farmalive 97 · P&G Oral-B Complet mediano 2×1 · EAN 7501006719932',
    30.38, 38, false,
    'https://www.farmacapital.mx/catalogo-propia/oral-b-complet-mediano-2x1.jpg'
  ),
  (
    '056100024798', 'FC-00024798',
    'Always toallas sanitarias nocturnas con alas 8 pzas',
    'Always', 'Bolsa con 8 toallas', 'Toalla sanitaria',
    'Cuidado personal', 'Protección femenina',
    'Farmalive 97 · P&G Always nocturna alas C/8 · EAN 056100024798 · foto pendiente',
    27.25, 35, false,
    null
  ),
  (
    '7501048621408', 'FC-48621408',
    'Protec torundas de algodón 150 bolitas',
    'Protec', 'Bolsa con 150 bolitas', 'Torunda',
    'Curación', 'Material de curación',
    'Farmalive 97 · Degasa Protec · EAN 7501048621408',
    20.19, 26, false,
    'https://www.farmacapital.mx/catalogo-propia/torundas-protec-150-bolitas.jpg'
  ),
  (
    '7500435182041', 'FC-35182041',
    'Herbal Essences mousse rizos definidos 200 ml 2 pack',
    'Herbal Essences', '2 envases 200 ml', 'Mousse',
    'Cuidado personal', 'Cabello',
    'Farmalive 97 · P&G Herbal Essences rizos · EAN 7500435182041',
    114.95, 144, false,
    'https://www.farmacapital.mx/catalogo-propia/herbal-essences-mousse-rizos-2pack.jpg'
  ),
  (
    '7501287630506', 'FC-87630506',
    'Terramicina oxitetraciclina 125 mg 24 trociscos',
    'Terramicina', 'Caja con 24 trociscos', 'Trocisco',
    'Medicamentos', 'Antibiótico',
    'Farmalive 97 · Pfizer · oxitetraciclina 125 mg · requiere receta · EAN 7501287630506',
    186.59, 234, true,
    'https://www.farmacapital.mx/catalogo-propia/terramicina-trociscos-24.jpg'
  ),
  (
    '7500435179980', 'FC-35179980',
    'Oral-B enjuague bucal 100% 250 ml',
    'Oral-B', 'Frasco 250 ml', 'Enjuague bucal',
    'Cuidado personal', 'Higiene bucal',
    'Farmalive 97 · P&G Oral-B 100% · EAN 7500435179980',
    49.29, 62, false,
    'https://www.farmacapital.mx/catalogo-propia/oral-b-enjuague-100-250ml.jpg'
  ),
  (
    '7891051037878', 'FC-51037878',
    'Oral-B enjuague bucal Complet 250 ml',
    'Oral-B', 'Frasco 250 ml', 'Enjuague bucal',
    'Cuidado personal', 'Higiene bucal',
    'Farmalive 97 · P&G Oral-B Complet · EAN 7891051037878',
    49.00, 62, false,
    'https://www.farmacapital.mx/catalogo-propia/oral-b-enjuague-complet-250ml.jpg'
  ),
  (
    '7506552900247', 'FC-52900247',
    'Quirmex almohadillas rectangulares 100 pzas',
    'Quirmex', 'Bolsa con 100 pzas', 'Almohadilla',
    'Curación', 'Material de curación',
    'Farmalive 97 · Quirmex · EAN 7506552900247 · foto pendiente',
    32.83, 42, false,
    null
  ),
  (
    '7501019068911', 'FC-19068911',
    'Saba protectores diarios tradicional largo 28 pzas',
    'Saba', 'Bolsa con 28 protectores', 'Protector diario',
    'Cuidado personal', 'Protección femenina',
    'Farmalive 97 · Essity Saba · EAN 7501019068911 · foto pendiente',
    25.77, 33, false,
    null
  ),
  (
    '3664798062243', 'FC-98062243',
    'Pharmaton Complete 100 tabletas',
    'Pharmaton', 'Caja con 100 tabletas', 'Tableta',
    'Medicamentos', 'Vitamínico',
    'Farmalive 97 · Opella Pharmaton Complete C/100 · promo ticket $0.01 · PVP mercado · EAN 3664798062243',
    0.01, 160, false,
    'https://www.farmacapital.mx/catalogo-propia/pharmaton-complete-c100.jpg'
  );

-- Altas: solo si el EAN / SKU no existen.
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, subcategoria,
  imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-FL97-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  'marca',
  t.descripcion,
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.requiere_receta,
  t.marca,
  t.presentacion,
  t.forma_farmaceutica,
  t.subcategoria,
  t.foto,
  t.foto
from _fc_alta_fl97 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean
       or p.sku = t.sku
  );

-- Galería: una fila por foto propia (idempotente).
-- ux_producto_imagenes_una_principal: solo 1 es_principal=true por producto.
-- Siempre insertar en false; bajar la actual; subir la nuestra (2 pasos).
insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.foto,
  'catalogo-propia/' || regexp_replace(t.foto, '^.*/', ''),
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  false,
  'propia'
from _fc_alta_fl97 t
join public.productos p on p.codigo_barras = t.ean
where t.foto is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url = t.foto
  );

update public.producto_imagenes i
set es_principal = false
from _fc_alta_fl97 t
join public.productos p on p.codigo_barras = t.ean
where i.producto_id = p.id
  and t.foto is not null
  and coalesce(i.es_principal, false)
  and i.url is distinct from t.foto;

update public.producto_imagenes i
set es_principal = true
from _fc_alta_fl97 t
join public.productos p on p.codigo_barras = t.ean
where i.producto_id = p.id
  and t.foto is not null
  and i.url = t.foto
  and not coalesce(i.es_principal, false);

-- Re-enlace exacto por EAN del ticket (altas nuevas + las que ya existían).
update public.recepcion_items i
set
  producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '97'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
  and r.estado = 'borrador'
  and coalesce(i.pendiente_alta, false)
  and i.producto_id is null
  and nullif(btrim(i.codigo_escaneado), '') is not null
  and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null;

-- Suerox: ticket trae 12 dígitos; catálogo tiene EAN-13 con dígito verificador.
update public.recepcion_items i
set
  producto_id = p.id,
  pendiente_alta = false
from public.recepciones r
join public.productos p
  on p.codigo_barras in ('6502400721541', '6502400322712')
 and (
      (i.codigo_escaneado = '650240072154' and p.codigo_barras = '6502400721541')
   or (i.codigo_escaneado = '650240032271' and p.codigo_barras = '6502400322712')
 )
where i.recepcion_id = r.id
  and r.folio = '97'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
  and r.estado = 'borrador'
  and coalesce(i.pendiente_alta, false)
  and i.producto_id is null;

commit;

-- Diagnóstico
select
  r.folio,
  count(*) as renglones,
  count(*) filter (where i.pendiente_alta) as siguen_pendiente_alta,
  count(*) filter (where i.producto_id is not null) as con_producto
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '97'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
group by r.folio;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 42) as ticket,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'OK' end as estado,
  left(p.nombre, 42) as catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '97'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
order by i.pendiente_alta desc, i.id;
