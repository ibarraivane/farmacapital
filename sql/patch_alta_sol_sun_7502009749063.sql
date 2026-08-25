-- Sol Sun Cara/Face · protector solar facial en crema, hidratacion profunda
-- con acido hialuronico y aloe vera.
-- EAN: 7502009749063 · Lote: 07026067 · Caducidad ABR/29 (se guarda 2029-04-30)
-- Precio de venta: 48.45 · Costo de compra pendiente (entra como 0.01).
-- Pendiente de la caja: FPS y gramaje del contenido neto, no se leian en la foto.
-- INSERT ONLY: no modifica filas existentes.
-- Ejecutar en Supabase SQL Editor (copiar desde el archivo, no del chat).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_precio numeric := 48.45;
  v_costo numeric := 0.01;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras in ('7502009749063', '75020097490630')
       or p.sku = 'FC-09749063'
       or p.nombre ilike '%sol sun%'
  ) then
    raise notice 'Sol Sun ya existe; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Sol Sun protector solar facial crema hidratacion profunda',
      'sku', 'FC-09749063',
      'codigo_barras', '7502009749063',
      'categoria', 'Cuidado personal',
      'tipo', 'marca',
      'descripcion', 'Sol Sun Cara Face protector solar facial con acido hialuronico y aloe vera · EAN 7502009749063 · falta FPS y gramaje del empaque',
      'costo', v_costo,
      'precio', v_precio,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', false
    ),
    1,
    '07026067',
    '2029-04-30'::date,
    v_costo,
    null::bigint,
    'Farma MX'
  ) f;

  update public.productos set
    marca = 'Sol Sun',
    presentacion = 'Crema facial en tubo',
    principio_activo = 'Acido hialuronico y aloe vera',
    forma_farmaceutica = 'Crema',
    subcategoria = 'Protector solar'
  where id = v_pid;

  raise notice 'Sol Sun creado id % lote % — falta costo real y foto en Inventario', v_pid, v_lid;
end $$;

commit;

-- Verificacion
select
  p.id,
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.costo,
  p.precio,
  p.stock,
  p.imagen_url,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras = '7502009749063'
   or p.sku = 'FC-09749063';

-- Cuando tengas el costo del ticket:
-- begin;
-- update public.productos set costo = <COSTO> where sku = 'FC-09749063';
-- update public.lotes l set costo_unitario = <COSTO>
--   from public.productos p where l.producto_id = p.id and p.sku = 'FC-09749063';
-- commit;
