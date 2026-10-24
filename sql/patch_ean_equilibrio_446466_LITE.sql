-- EANs Equilibrio 446466 — LITE v2 (sin updated_at, sin ilike masivo).
-- Preferible pegar los ONLY por separado si sigue fallando:
--   patch_ean_equilibrio_tusilen_ONLY.sql
--   patch_ean_equilibrio_ruquimax_ONLY.sql

-- Tusilen
update public.productos
set
  codigo_barras = '7506624900809',
  nombre = 'Tusilen adulto jarabe 118 ml',
  marca = coalesce(nullif(btrim(marca), ''), 'Tusilen'),
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Avitus'),
  presentacion = 'Frasco 118 ml',
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Jarabe'),
  principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Dextrometorfano / guaifenesina / fenilefrina'),
  concentracion = coalesce(nullif(btrim(concentracion), ''), '0.300/2.4/0.050 g/100 ml')
where sku = 'EQ-AVT195'
  and (codigo_barras is null or btrim(codigo_barras) = '' or codigo_barras = '7506624900809');

update public.productos
set sku = 'FC-24900809'
where sku = 'EQ-AVT195'
  and codigo_barras = '7506624900809'
  and not exists (select 1 from public.productos p2 where p2.sku = 'FC-24900809');

update public.recepcion_items i
set
  codigo_escaneado = '7506624900809',
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo('7506624900809'),
    public.fc_buscar_producto_escaneo('FC-24900809'),
    public.fc_buscar_producto_escaneo('EQ-AVT195'),
    i.producto_id
  ),
  nombre_snapshot = 'Tusilen adulto jarabe 118 ml',
  pendiente_alta = (
    coalesce(
      public.fc_buscar_producto_escaneo('7506624900809'),
      public.fc_buscar_producto_escaneo('FC-24900809'),
      public.fc_buscar_producto_escaneo('EQ-AVT195'),
      i.producto_id
    ) is null
  )
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '446466'
  and r.estado = 'borrador'
  and (i.nombre_snapshot ilike '%TUSILEN%' or i.nombre_snapshot ilike '%Tusilen%');

-- Ruquimax
update public.productos
set
  codigo_barras = '7501258215947',
  nombre = 'Ruquimax hidroxicloroquina 200 mg C/20',
  marca = 'Ruquimax',
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Serral'),
  presentacion = 'Caja con 20 tabletas',
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tableta'),
  principio_activo = 'Hidroxicloroquina',
  concentracion = '200 mg',
  requiere_receta = true
where sku = 'EQ-SER181'
  and (codigo_barras is null or btrim(codigo_barras) = '' or codigo_barras = '7501258215947');

update public.productos
set sku = 'FC-58215947'
where sku = 'EQ-SER181'
  and codigo_barras = '7501258215947'
  and not exists (select 1 from public.productos p2 where p2.sku = 'FC-58215947');

update public.recepcion_items i
set
  codigo_escaneado = '7501258215947',
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo('7501258215947'),
    public.fc_buscar_producto_escaneo('FC-58215947'),
    public.fc_buscar_producto_escaneo('EQ-SER181'),
    i.producto_id
  ),
  nombre_snapshot = 'Ruquimax hidroxicloroquina 200 mg C/20',
  pendiente_alta = (
    coalesce(
      public.fc_buscar_producto_escaneo('7501258215947'),
      public.fc_buscar_producto_escaneo('FC-58215947'),
      public.fc_buscar_producto_escaneo('EQ-SER181'),
      i.producto_id
    ) is null
  )
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '446466'
  and r.estado = 'borrador'
  and (
    i.nombre_snapshot ilike '%RUQUIMOX%'
    or i.nombre_snapshot ilike '%Ruquimax%'
    or i.nombre_snapshot ilike '%SER181%'
  );
