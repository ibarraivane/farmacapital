-- Equilibrio 446466 — Tusilen EAN (1 solo producto).
-- Si falla, copia el texto rojo del error.

-- Solo toca EQ-AVT195 (alta del ticket). No renombra SKU si FC-24900809 ya existe.
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
  and (
    codigo_barras is null
    or btrim(codigo_barras) = ''
    or codigo_barras = '7506624900809'
  );

-- Si ya quedó con SKU canónico:
update public.productos
set
  codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7506624900809'),
  nombre = 'Tusilen adulto jarabe 118 ml'
where sku = 'FC-24900809';

-- Renombrar SKU solo si el destino está libre
update public.productos
set sku = 'FC-24900809'
where sku = 'EQ-AVT195'
  and codigo_barras = '7506624900809'
  and not exists (select 1 from public.productos p2 where p2.sku = 'FC-24900809');

-- Renglón Recibir
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
  and (
    i.nombre_snapshot ilike '%TUSILEN%'
    or i.nombre_snapshot ilike '%Tusilen%'
    or coalesce(i.codigo_escaneado, '') in ('EQ-AVT195', 'FC-24900809')
  );

select sku, codigo_barras, left(nombre, 40) as nombre
from public.productos
where sku in ('EQ-AVT195', 'FC-24900809')
   or codigo_barras = '7506624900809';
