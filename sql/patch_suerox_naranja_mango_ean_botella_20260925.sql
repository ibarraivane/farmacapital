-- ============================================================================
-- Suerox Vitamins naranja-mango 630 mL — EAN real de la botella
--
-- Catálogo / tickets Farmalive tenían código interno 6502400721471 (prefijo 650,
-- no GS1 México). La pistola lee el EAN de la botella: 7501048607214
-- (ref. Genomma 013443). Por eso Recibir decía «no corresponde».
--
-- SKU se queda FC-00721471 (historial). El 650… queda como alias en descripción
-- por si algún ticket viejo aún lo trae.
-- Pegar en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

-- Si ya existiera un duplicado con el EAN bueno y otro SKU, no pisar: avisar.
do $$
declare
  v_canonic bigint;
  v_viejo bigint;
begin
  select id into v_canonic
  from public.productos
  where codigo_barras = '7501048607214'
  order by id
  limit 1;

  select id into v_viejo
  from public.productos
  where sku = 'FC-00721471'
     or codigo_barras = '6502400721471'
  order by case when sku = 'FC-00721471' then 0 else 1 end, id
  limit 1;

  if v_canonic is not null and v_viejo is not null and v_canonic <> v_viejo then
    raise notice 'Hay dos filas (id % con EAN botella, id % FC-00721471). Revisa a mano; no se fusionan.',
      v_canonic, v_viejo;
    return;
  end if;

  if v_viejo is null and v_canonic is null then
    -- Alta mínima por si nunca corrieron la carga Farmalive
    insert into public.productos (
      nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
      costo, precio, stock, stock_minimo, activo, requiere_receta,
      marca, presentacion, forma_farmaceutica, laboratorio
    ) values (
      'Suerox Vitamins naranja-mango 630 mL',
      'FC-00721471',
      '7501048607214',
      'Bebidas',
      'Electrolitos',
      'generico',
      'EAN botella 7501048607214 · ref. Genomma 013443 · alias Farmalive 6502400721471',
      14.73,
      24,
      0,
      1,
      true,
      false,
      'Suerox',
      'Botella 630 mL',
      'Bebida',
      'Genomma Lab'
    );
    raise notice 'Suerox naranja-mango creado con EAN botella';
    return;
  end if;

  update public.productos set
    codigo_barras = '7501048607214',
    nombre = 'Suerox Vitamins naranja-mango 630 mL',
    marca = coalesce(nullif(btrim(marca), ''), 'Suerox'),
    laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Genomma Lab'),
    presentacion = coalesce(nullif(btrim(presentacion), ''), 'Botella 630 mL'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Bebida'),
    categoria = coalesce(nullif(btrim(categoria), ''), 'Bebidas'),
    subcategoria = coalesce(nullif(btrim(subcategoria), ''), 'Electrolitos'),
    descripcion = case
      when descripcion ilike '%6502400721471%' and descripcion ilike '%7501048607214%' then descripcion
      when descripcion ilike '%6502400721471%' then
        btrim(descripcion) || ' · EAN botella 7501048607214 · ref. 013443'
      else
        coalesce(nullif(btrim(descripcion), '') || ' · ', '')
        || 'EAN botella 7501048607214 · ref. Genomma 013443 · alias Farmalive 6502400721471'
    end,
    updated_at = now()
  where id = coalesce(v_viejo, v_canonic);
end $$;

-- Borradores Farmalive vivos: el renglón debe traer el EAN que pinta la pistola.
update public.recepcion_items i
set
  codigo_escaneado = '7501048607214',
  nombre_snapshot = 'Suerox Vitamins naranja-mango 630 mL'
from public.recepciones r
where i.recepcion_id = r.id
  and r.estado = 'borrador'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
  and (
    i.codigo_escaneado = '6502400721471'
    or (
      i.producto_id in (
        select p.id from public.productos p
        where p.sku = 'FC-00721471'
           or p.codigo_barras in ('7501048607214', '6502400721471')
      )
      and coalesce(i.codigo_escaneado, '') in ('6502400721471', '650240072147', '')
    )
  );

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  left(p.descripcion, 120) as descripcion
from public.productos p
where p.sku = 'FC-00721471'
   or p.codigo_barras in ('7501048607214', '6502400721471');

select
  r.folio,
  r.proveedor,
  r.estado,
  i.codigo_escaneado,
  i.nombre_snapshot,
  i.cantidad,
  i.confirmado
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%farmalive%'
  and r.estado = 'borrador'
  and (
    i.codigo_escaneado in ('7501048607214', '6502400721471')
    or i.nombre_snapshot ilike '%naranja%mango%'
  )
order by r.folio, i.id;
