-- Farmalive 12127 · B1-1/8 · altas (8 SKUs)
-- Lote chico. Idempotente. Sin fc_buscar (evita Load failed).

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select *
from (values
  ('Suavelastic Jumbo', 'FC-43444966', '7501943444966', 'Higiene', 'Pañales', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 249.61::numeric, 313::numeric, 0::integer, 1::integer, true, false, 'Suavelastic', 'Paquete 40 pañales talla jumbo', 'Pañal', null::text, null::text, 'Kimberly-Clark', 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-suavelastic-jumbo-40-7501943444966.jpg', 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-suavelastic-jumbo-40-7501943444966.jpg'),
  ('Suavelastic Mediano', 'FC-43444928', '7501943444928', 'Higiene', 'Pañales', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 185.81::numeric, 233::numeric, 0::integer, 1::integer, true, false, 'Suavelastic', 'Paquete 40 pañales talla mediana', 'Pañal', null::text, null::text, 'Kimberly-Clark', null::text, null::text),
  ('Absorsec Grande', 'FC-17372751', '7501017372751', 'Higiene', 'Pañales', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 148.76::numeric, 186::numeric, 0::integer, 1::integer, true, false, 'Absorsec', 'Paquete 40 pañales talla grande', 'Pañal', null::text, null::text, 'Kimberly-Clark', null::text, null::text),
  ('Suavelastic Chico', 'FC-43434622', '7501943434622', 'Higiene', 'Pañales', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 149.94::numeric, 188::numeric, 0::integer, 1::integer, true, false, 'Suavelastic', 'Paquete 40 pañales talla chica', 'Pañal', null::text, null::text, 'Kimberly-Clark', null::text, null::text),
  ('Saba Amore con alas', 'FC-19031137', '7501019031137', 'Cuidado personal', 'Higiene femenina', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 11.12::numeric, 14::numeric, 0::integer, 1::integer, true, false, 'Saba', 'Paquete 8 toallas', 'Toallas', null::text, null::text, 'SCA', null::text, null::text),
  ('Suavelastic Vitta E toallitas', 'FC-25618200', '7506425618200', 'Higiene', 'Toallitas', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 29.20::numeric, 37::numeric, 0::integer, 1::integer, true, false, 'Suavelastic', 'Paquete 80 toallitas', 'Toallitas', null::text, null::text, 'Kimberly-Clark', null::text, null::text),
  ('Kimbies Durazno Aloe toallitas', 'FC-25601790', '7506425601790', 'Higiene', 'Toallitas', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 14.41::numeric, 19::numeric, 0::integer, 1::integer, true, false, 'Kimbies', 'Paquete 90 toallitas', 'Toallitas', null::text, null::text, 'Kimberly-Clark', null::text, null::text),
  ('Absorsec toallitas', 'FC-43471337', '7501943471337', 'Higiene', 'Toallitas', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 13.72::numeric, 18::numeric, 0::integer, 1::integer, true, false, 'Absorsec', 'Paquete 90 toallitas', 'Toallitas', null::text, null::text, 'Kimberly-Clark', null::text, null::text)
) as v(
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
where not exists (
  select 1 from public.productos p where p.codigo_barras = v.codigo_barras
)
  and not exists (
  select 1 from public.productos p where p.sku = v.sku
);

select count(*) as ya_en_catalogo
from public.productos
where codigo_barras in ('7501943444966', '7501943444928', '7501017372751', '7501943434622', '7501019031137', '7506425618200', '7506425601790', '7501943471337');
