-- Equilibrio 446466 — Ruquimax EAN (caja; ticket decía Ruquimox).
-- 1 solo producto por SKU. Sin updated_at. Sin ilike masivo.

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
  and (
    codigo_barras is null
    or btrim(codigo_barras) = ''
    or codigo_barras = '7501258215947'
  );

update public.productos
set
  codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7501258215947'),
  nombre = 'Ruquimax hidroxicloroquina 200 mg C/20',
  marca = 'Ruquimax',
  principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Hidroxicloroquina'),
  concentracion = coalesce(nullif(btrim(concentracion), ''), '200 mg')
where sku = 'FC-58215947';

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
    or coalesce(i.codigo_escaneado, '') in ('EQ-SER181', 'FC-58215947')
  );

select sku, codigo_barras, left(nombre, 48) as nombre
from public.productos
where sku in ('EQ-SER181', 'FC-58215947')
   or codigo_barras = '7501258215947';
