-- Lactopram infantil 150 mg sabor chocolate · Progela
-- EAN: 7503008344495 (distinto del Lactopram adulto 430 mg C/20 · 7503008344488)
-- INSERT ONLY: no modifica filas existentes ni el Lactopram adulto.
-- Completar costo/precio reales en Inventario (abajo van placeholders 0.01 solo para cumplir NOT NULL).
-- Ejecutar en Supabase SQL Editor (copiar desde archivo, no del chat).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras in ('7503008344495', '75030083444950')
       or p.sku in ('FC-08344495', 'FC-8344495')
       or (p.nombre ilike '%lactopram%' and p.nombre ilike '%infantil%')
       or (p.nombre ilike '%lactopram%' and p.nombre ilike '%150%' and p.nombre ilike '%chocolate%')
  ) then
    raise notice 'Lactopram infantil ya existe; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Lactopram infantil 150 mg sabor chocolate',
      'sku', 'FC-08344495',
      'codigo_barras', '7503008344495',
      'categoria', 'Gastro',
      'tipo', 'marca',
      'descripcion', 'Lactopram infantil 150 mg chocolate Progela EAN 7503008344495',
      'costo', 0.01,
      'precio', 0.01,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', false
    ),
    0,
    null,
    null,
    null,
    null::bigint
  ) f;

  update public.productos set
    marca = 'Lactopram',
    presentacion = '150 mg sabor chocolate',
    principio_activo = 'Lactobacillus',
    forma_farmaceutica = 'Polvo o sobres',
    subcategoria = 'Probiótico infantil'
  where id = v_pid;

  raise notice 'Lactopram infantil restaurado id % — pon costo/precio/stock reales en Inventario', v_pid;
end $$;

commit;

-- Verificacion: deben coexistir adulto + infantil (2 filas si ambos existen)
select
  p.id,
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.activo,
  p.precio,
  p.costo,
  p.stock
from public.productos p
where p.codigo_barras in ('7503008344495', '7503008344488')
   or p.nombre ilike '%lactopram%'
order by p.codigo_barras;
