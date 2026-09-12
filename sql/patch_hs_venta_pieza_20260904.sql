-- Head & Shoulders Limpieza Renovadora: se vende el sobre 10 ml, no la tira.
-- Compra: Exprezo ticket 1279718 (2026-08-30) · Tira 24 sachets · $51.21
-- Costo sobre = 51.21 / 24 ≈ 2.13 · PVP $4 (~47% margen, misma lógica Optims).
-- EAN del sobre (impreso): 7590002008898
-- Idempotente: si ya tiene el EAN de pieza, no vuelve a multiplicar stock.
--
-- Foto: DESPUÉS de deploy Vercel (JPG en public/catalogo-propia/).

begin;

-- Lotes: 1 tira recibida → 24 sobres (solo si aún figura como Tira/Pack).
update public.lotes l
   set cantidad_actual = case
         when coalesce(l.cantidad_actual, 0) between 1 and 5
              and p.nombre ilike '%Tira%24%'
           then l.cantidad_actual * 24
         else l.cantidad_actual
       end,
       costo_unitario = round((51.21 / 24)::numeric, 4)
  from public.productos p
 where l.producto_id = p.id
   and p.sku = 'FC-EXP-HS24'
   and coalesce(p.codigo_barras, '') is distinct from '7590002008898';

-- Alta si nunca se corrió el patch Exprezo 14.
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta
)
select
  'Head & Shoulders Limpieza Renovadora sobre 10 ml',
  'FC-EXP-HS24',
  '7590002008898',
  'Cuidado personal',
  'marca',
  'Sobre Head & Shoulders Limpieza Renovadora shampoo control caspa, 10 ml. Se vende el sobre (no la tira). Tira 24 sobres · al recibir cargar 24 pzas (costo tira÷24). EAN 7590002008898. Ticket Exprezo 1279718: Tira Shampoo Head & Shoulders 24 sachets 10 ml.',
  round((51.21 / 24)::numeric, 2),
  4,
  24,
  1,
  true,
  false
where not exists (
  select 1 from public.productos
   where sku = 'FC-EXP-HS24'
      or codigo_barras = '7590002008898'
);

update public.productos
   set nombre = 'Head & Shoulders Limpieza Renovadora sobre 10 ml',
       marca = 'Head & Shoulders',
       presentacion = 'Sobre 10 ml',
       forma_farmaceutica = 'Sobre',
       categoria = 'Cuidado personal',
       tipo = 'marca',
       codigo_barras = '7590002008898',
       precio = 4,
       costo = round((51.21 / 24)::numeric, 2),
       venta_unidad = false,
       unidades_por_caja = 0,
       precio_unidad = 0,
       stock_unidades = 0,
       stock = case
         when coalesce(codigo_barras, '') is distinct from '7590002008898'
              and nombre ilike '%Tira%24%'
              and coalesce(stock, 0) between 1 and 5
           then stock * 24
         when coalesce(stock, 0) = 0
           then 24
         else stock
       end,
       imagen_url = 'https://www.farmacapital.mx/catalogo-propia/head-shoulders-limpieza-renovadora-sobre-10ml.jpg',
       imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/head-shoulders-limpieza-renovadora-sobre-10ml.jpg',
       descripcion = 'Sobre Head & Shoulders Limpieza Renovadora shampoo control caspa, 10 ml. Se vende el sobre (no la tira). Tira 24 sobres · al recibir cargar 24 pzas (costo tira÷24 = 2.13). EAN 7590002008898. Ticket Exprezo 1279718: Tira Shampoo Head & Shoulders 24 sachets 10 ml. Compra tira $51.21 · PVP sobre $4.'
 where sku = 'FC-EXP-HS24'
    or codigo_barras = '7590002008898';

-- Galería principal
do $$
declare
  v_pid integer;
  v_url text := 'https://www.farmacapital.mx/catalogo-propia/head-shoulders-limpieza-renovadora-sobre-10ml.jpg';
  v_pos integer;
begin
  select id into v_pid
    from public.productos
   where sku = 'FC-EXP-HS24'
      or codigo_barras = '7590002008898'
   order by case when sku = 'FC-EXP-HS24' then 0 else 1 end
   limit 1;

  if v_pid is null then
    raise exception 'No está H&S (FC-EXP-HS24 / 7590002008898)';
  end if;

  update public.producto_imagenes
     set es_principal = false
   where producto_id = v_pid
     and es_principal
     and url is distinct from v_url;

  if exists (
    select 1 from public.producto_imagenes
     where producto_id = v_pid and url = v_url
  ) then
    update public.producto_imagenes
       set es_principal = true,
           origen = 'propia',
           storage_path = 'catalogo-propia/head-shoulders-limpieza-renovadora-sobre-10ml.jpg'
     where producto_id = v_pid and url = v_url;
  else
    select coalesce(max(posicion), -1) + 1 into v_pos
      from public.producto_imagenes where producto_id = v_pid;
    insert into public.producto_imagenes
      (producto_id, url, storage_path, posicion, es_principal, origen)
    values
      (v_pid, v_url, 'catalogo-propia/head-shoulders-limpieza-renovadora-sobre-10ml.jpg',
       v_pos, true, 'propia');
  end if;
end
$$;

commit;

select sku, left(nombre, 56) as nombre, codigo_barras as ean,
       costo, precio, stock, presentacion,
       round(((precio - costo) / nullif(precio, 0)) * 100, 1) as margen_pct
  from public.productos
 where sku = 'FC-EXP-HS24'
    or codigo_barras = '7590002008898';
