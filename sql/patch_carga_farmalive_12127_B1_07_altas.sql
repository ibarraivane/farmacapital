-- Farmalive 12127 · B1-7/8 · altas (8 SKUs)
-- Lote chico. Idempotente. Sin fc_buscar (evita Load failed).

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select *
from (values
  ('Lotrimin Power spray', 'FC-08491041', '7501008491041', 'Dermatología', 'Antifúngico', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 90.30::numeric, 113::numeric, 0::integer, 1::integer, true, false, 'Lotrimin', 'Spray 150 mL', 'Spray', 'Tolnaftato', null::text, 'Bayer', 'https://www.farmacapital.mx/catalogo-propia/lotrimin-power-spray-150ml-7501008491041.jpg', 'https://www.farmacapital.mx/catalogo-propia/lotrimin-power-spray-150ml-7501008491041.jpg'),
  ('Sukrol Mujer', 'FC-30020716', '6758730020716', 'Vitaminas', null::text, 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 131.30::numeric, 165::numeric, 0::integer, 1::integer, true, false, 'Sukrol', 'Caja 30 tabletas', 'Tableta', null::text, null::text, 'Farmamédica', 'https://www.farmacapital.mx/catalogo-propia/sukrol-mujer-30-tab-6758730020716.jpg', 'https://www.farmacapital.mx/catalogo-propia/sukrol-mujer-30-tab-6758730020716.jpg'),
  ('Vanart Hierbas shampoo', 'FC-00331318', '6502400331318', 'Cuidado personal', 'Capilar', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 26.46::numeric, 34::numeric, 0::integer, 1::integer, true, false, 'Vanart', 'Frasco 750 mL', 'Shampoo', null::text, null::text, 'Genomma Lab', null::text, null::text),
  ('Vanart Rosa enjuague', 'FC-00331554', '6502400331554', 'Cuidado personal', 'Capilar', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 42.53::numeric, 54::numeric, 0::integer, 1::integer, true, false, 'Vanart', 'Frasco 750 mL', 'Enjuague', null::text, null::text, 'Genomma Lab', null::text, null::text),
  ('Herbal Essences Ondas Perfectas mousse', 'FC-35169004', '7500435169004', 'Cuidado personal', 'Capilar', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 69.56::numeric, 87::numeric, 0::integer, 1::integer, true, false, 'Herbal Essences', 'Envase 200 g', 'Mousse', null::text, null::text, 'P&G', null::text, null::text),
  ('Head & Shoulders Limpieza Renovadora', 'FC-35162265', '7500435162265', 'Cuidado personal', 'Capilar', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 123.03::numeric, 154::numeric, 0::integer, 1::integer, true, false, 'Head & Shoulders', 'Frasco 650 mL', 'Shampoo', null::text, null::text, 'P&G', null::text, null::text),
  ('Vaso recolector Degasa', 'FC-48640034', '7501048640034', 'Botiquín', 'Material médico', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 4.37::numeric, 6::numeric, 0::integer, 1::integer, true, false, 'Degasa', '1 unidad', 'Vaso', null::text, null::text, 'Degasa', null::text, null::text),
  ('Ensure Advance vainilla', 'FC-33958717', '7501033958717', 'Suplemento', 'Nutrición clínica', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 50.47::numeric, 64::numeric, 0::integer, 1::integer, true, false, 'Ensure', 'Frasco 237 mL', 'Líquido', null::text, null::text, 'Abbott', 'https://www.farmacapital.mx/catalogo-propia/ensure-advance-vainilla-237ml-7501033958717.jpg', 'https://www.farmacapital.mx/catalogo-propia/ensure-advance-vainilla-237ml-7501033958717.jpg')
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
where codigo_barras in ('7501008491041', '6758730020716', '6502400331318', '6502400331554', '7500435169004', '7500435162265', '7501048640034', '7501033958717');
