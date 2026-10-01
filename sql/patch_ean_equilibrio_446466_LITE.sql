-- EANs Equilibrio 446466 — LITE (Tusilen + Ruquimax).

-- 7) Tusilen adulto
update public.productos set
  codigo_barras = '7506624900809',
  sku = case when sku = 'EQ-AVT195' then 'FC-24900809' else sku end,
  nombre = 'Tusilen adulto jarabe 118 ml',
  marca = coalesce(nullif(btrim(marca), ''), 'Tusilen'),
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Avitus / Allen'),
  presentacion = 'Frasco 118 ml',
  principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Dextrometorfano / guaifenesina / fenilefrina'),
  concentracion = coalesce(nullif(btrim(concentracion), ''), '0.300/2.4/0.050 g/100 ml'),
  updated_at = now()
where sku in ('EQ-AVT195', 'FC-24900809')
  or id = public.fc_buscar_producto_escaneo('7506624900809');

update public.recepcion_items i set
  codigo_escaneado = '7506624900809',
  producto_id = coalesce(public.fc_buscar_producto_escaneo('7506624900809'), public.fc_buscar_producto_escaneo('FC-24900809'), i.producto_id),
  nombre_snapshot = 'Tusilen adulto jarabe 118 ml',
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id and r.folio = '446466' and r.estado = 'borrador'
  and i.nombre_snapshot ilike '%TUSILEN%';

-- 8) Ruquimax (caja; ticket decía Ruquimox)
update public.productos set
  codigo_barras = '7501258215947',
  sku = case when sku = 'EQ-SER181' then 'FC-58215947' else sku end,
  nombre = 'Ruquimax hidroxicloroquina 200 mg C/20',
  marca = 'Ruquimax',
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Serral'),
  presentacion = 'Caja con 20 tabletas',
  principio_activo = 'Hidroxicloroquina',
  concentracion = '200 mg',
  updated_at = now()
where sku in ('EQ-SER181', 'FC-58215947')
  or id = public.fc_buscar_producto_escaneo('7501258215947')
  or nombre ilike '%ruquimox%';

update public.recepcion_items i set
  codigo_escaneado = '7501258215947',
  producto_id = coalesce(public.fc_buscar_producto_escaneo('7501258215947'), public.fc_buscar_producto_escaneo('FC-58215947'), i.producto_id),
  nombre_snapshot = 'Ruquimax hidroxicloroquina 200 mg C/20',
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id and r.folio = '446466' and r.estado = 'borrador'
  and (i.nombre_snapshot ilike '%RUQUIMOX%' or i.nombre_snapshot ilike '%Ruquimax%' or i.nombre_snapshot ilike '%SER181%');
