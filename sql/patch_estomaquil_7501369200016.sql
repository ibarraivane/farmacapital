-- ============================================================================
-- ALTA Estomaquil Polvo C/20 sobres · EAN 7501369200016
--
-- No apareció en ticket FarmaLive FL-080826 (#9861 OCR) — por eso no se cargó
-- con el patch de faltantes. Alta manual para búsqueda en inventario.
--
-- Ajusta v_qty, v_costo y v_precio si tienes ticket de compra.
-- Valores por defecto: referencia mercado ~$133 venta / costo estimado +35% margen.
-- (precio NOT NULL en productos — no se puede insertar sin precio)
-- ============================================================================

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_qty integer := 0;
  v_costo numeric(10,2) := 98.79;
  v_precio numeric(10,2) := 133.37;
begin
  select id into v_pid
  from public.productos
  where sku = 'FC-69200016'
     or codigo_barras = '7501369200016'
  limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Estomaquil Polvo C/20',
        'sku', 'FC-69200016',
        'codigo_barras', '7501369200016',
        'categoria', 'Producto',
        'tipo', 'marca',
        'descripcion', 'Estomaquil Polvo C/20 sobres 3 g — Higia. Alta manual (no en ticket FL-080826).',
        'costo', v_costo,
        'precio', v_precio,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      v_qty,
      null,
      null,
      v_costo,
      null
    ) f;

    update public.productos set
      marca = 'Higia',
      presentacion = 'C/20 sobres 3 g',
      forma_farmaceutica = 'Polvo',
      principio_activo = 'Bismuto subsalicilato; Hidróxido de magnesio; Carbonato de calcio',
      subcategoria = 'Digestivo / antiácido'
    where id = v_pid;
  else
    update public.productos set
      nombre = 'Estomaquil Polvo C/20',
      sku = 'FC-69200016',
      codigo_barras = '7501369200016',
      marca = coalesce(nullif(btrim(marca), ''), 'Higia'),
      presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/20 sobres 3 g'),
      forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Polvo'),
      principio_activo = coalesce(
        nullif(btrim(principio_activo), ''),
        'Bismuto subsalicilato; Hidróxido de magnesio; Carbonato de calcio'
      ),
      subcategoria = coalesce(nullif(btrim(subcategoria), ''), 'Digestivo / antiácido'),
      costo = coalesce(costo, v_costo),
      precio = coalesce(precio, v_precio),
      activo = true
    where id = v_pid;
  end if;
end $$;

commit;

select id, sku, codigo_barras, nombre, marca, presentacion, stock, costo, precio
from public.productos
where codigo_barras = '7501369200016'
   or sku = 'FC-69200016';
