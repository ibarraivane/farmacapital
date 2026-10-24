-- EANs IFC 126446 — LITE (pegar entero o de a bloque).

-- EANs IFC 126446 + Equilibrio 446466 — versión LIGERA (sin temp table).
-- Si «Load failed»: pegá de a 1 bloque (cada update … ;).
-- No toca costos ni cantidades.

-- 1) Try C/12
update public.productos set
  codigo_barras = '6932119800025',
  sku = case when sku = 'FC-IFC-CORTA-TRY12' then 'FC-19800025' else sku end,
  nombre = 'Cortaúñas Try mediano C/12',
  marca = coalesce(nullif(btrim(marca), ''), 'Try'),
  presentacion = 'Paquete C/12 (no venta individual)',
  updated_at = now()
where sku in ('FC-IFC-CORTA-TRY12', 'FC-19800025')
  or id = public.fc_buscar_producto_escaneo('6932119800025');

update public.recepcion_items i set
  codigo_escaneado = '6932119800025',
  producto_id = coalesce(public.fc_buscar_producto_escaneo('6932119800025'), public.fc_buscar_producto_escaneo('FC-19800025'), i.producto_id),
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id and r.folio = '126446' and r.estado = 'borrador'
  and (i.nombre_snapshot ilike '%CORTAUNAS TRY%' or i.nombre_snapshot ilike '%Cortaúñas Try%');

-- 2) Bobo C/12
update public.productos set
  codigo_barras = '6976824588236',
  sku = case when sku = 'FC-IFC-CORTA-BOBO12' then 'FC-24588236' else sku end,
  nombre = 'Cortaúñas Bobo mediano sin cadena C/12',
  marca = coalesce(nullif(btrim(marca), ''), 'Bobo'),
  presentacion = 'Paquete C/12',
  updated_at = now()
where sku in ('FC-IFC-CORTA-BOBO12', 'FC-24588236')
  or id = public.fc_buscar_producto_escaneo('6976824588236');

update public.recepcion_items i set
  codigo_escaneado = '6976824588236',
  producto_id = coalesce(public.fc_buscar_producto_escaneo('6976824588236'), public.fc_buscar_producto_escaneo('FC-24588236'), i.producto_id),
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id and r.folio = '126446' and r.estado = 'borrador'
  and (i.nombre_snapshot ilike '%CORTAUNAS BOBO%' or i.nombre_snapshot ilike '%Cortaúñas Bobo%');

-- 3) Curtis Lady 57LC
update public.productos set
  codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7501370204577'),
  sku = case when sku = 'FC-IFC-PINZA-LADY' then 'FC-70204577' else sku end,
  nombre = 'Curtis Lady pinza tijera cejas',
  marca = coalesce(nullif(btrim(marca), ''), 'Curtis'),
  presentacion = '1 pieza · modelo 57LC',
  updated_at = now()
where sku in ('FC-IFC-PINZA-LADY', 'FC-70204577')
  or id = public.fc_buscar_producto_escaneo('7501370204577');

update public.recepcion_items i set
  codigo_escaneado = '7501370204577',
  producto_id = coalesce(public.fc_buscar_producto_escaneo('7501370204577'), public.fc_buscar_producto_escaneo('FC-70204577'), i.producto_id),
  nombre_snapshot = 'Curtis Lady pinza tijera cejas',
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id and r.folio = '126446' and r.estado = 'borrador'
  and (i.nombre_snapshot ilike '%PINZA DEPILAR LADY%' or i.nombre_snapshot ilike '%Lady pinza%' or i.nombre_snapshot ilike '%Pinza depilar Lady%');

-- 4) Yoli enchinador
update public.productos set
  codigo_barras = '7501370202023',
  sku = case when sku = 'FC-IFC-YOLI-ENCH' then 'FC-70202023' else sku end,
  nombre = 'Yoli enchinador de pestañas',
  marca = coalesce(nullif(btrim(marca), ''), 'Yoli'),
  presentacion = '1 pieza · modelo 102CV',
  updated_at = now()
where sku in ('FC-IFC-YOLI-ENCH', 'FC-70202023')
  or id = public.fc_buscar_producto_escaneo('7501370202023');

update public.recepcion_items i set
  codigo_escaneado = '7501370202023',
  producto_id = coalesce(public.fc_buscar_producto_escaneo('7501370202023'), public.fc_buscar_producto_escaneo('FC-70202023'), i.producto_id),
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id and r.folio = '126446' and r.estado = 'borrador'
  and i.nombre_snapshot ilike '%YOLI%';

-- 5) Alicata / set
update public.productos set
  codigo_barras = '6855265655229',
  sku = case when sku = 'FC-IFC-ALICATA-GDE' then 'FC-65655229' else sku end,
  nombre = 'Alicata / set manicure económico mango colores',
  presentacion = 'Pieza / set',
  updated_at = now()
where sku in ('FC-IFC-ALICATA-GDE', 'FC-65655229')
  or id = public.fc_buscar_producto_escaneo('6855265655229');

update public.recepcion_items i set
  codigo_escaneado = '6855265655229',
  producto_id = coalesce(public.fc_buscar_producto_escaneo('6855265655229'), public.fc_buscar_producto_escaneo('FC-65655229'), i.producto_id),
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id and r.folio = '126446' and r.estado = 'borrador'
  and i.nombre_snapshot ilike '%ALICATA%';

-- 6) Mercurio ricino → EAN ya conocido FC-00001292
update public.productos set
  codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '3311000001292'),
  nombre = coalesce(nullif(btrim(nombre), ''), 'Mercurio aceite de ricino 50 ml'),
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Frasco 50 ml'),
  updated_at = now()
where sku in ('FC-IFC-MER-RICINO', 'FC-00001292')
  or id = public.fc_buscar_producto_escaneo('3311000001292');

update public.recepcion_items i set
  codigo_escaneado = '3311000001292',
  producto_id = coalesce(public.fc_buscar_producto_escaneo('3311000001292'), public.fc_buscar_producto_escaneo('FC-00001292'), i.producto_id),
  nombre_snapshot = 'Mercurio aceite de ricino 50 ml',
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id and r.folio = '126446' and r.estado = 'borrador'
  and i.nombre_snapshot ilike '%RICINO%';

