-- Blister en medicamentos con venta por pieza (2026-10-03)
-- Pegar en Supabase → SQL Editor.
--
-- Qué hace:
-- 1) Solo tabletas/cápsulas/pastillas con venta_unidad que aún no tenían blister.
-- 2) piezas_por_blister con la regla del sistema (prioriza tiras de 10).
-- 3) Aspirina 500 mg (C/40 y C/80): precio_blister = $20.
-- 4) Los demás: precio sugerido con la misma regla de margen que la pieza.
-- 5) Convierte stock_unidades enteros a stock_blisters solo si blister
--    estaba en 0 (no inventa caducidad ni mueve cajas cerradas).
--
-- Contexto: de 103 productos con venta_unidad, 42 son medicamentos en
-- tableta/cápsula; 33 ya tenían blister. Este patch cierra los 8 que faltaban.
-- Idempotente: re-correr no vuelve a partir el stock.

begin;

create temporary table _blister_meds (
  sku text primary key,
  piezas_por_blister integer not null,
  precio_blister numeric not null,
  convertir_stock boolean not null default false
) on commit drop;

insert into _blister_meds (sku, piezas_por_blister, precio_blister, convertir_stock) values
  ('FC-08491074', 10, 20, true),  -- Aspirina 500 mg C/80 · 8 blisters × $20
  ('FC-08491096', 10, 17, true),  -- Cafiaspirina tartrato C/100
  ('FC-08496701', 6, 27, true),   -- Aspirina efervescente C/12
  ('FC-08499818', 10, 20, true),  -- Aspirina 500 mg · 8 blisters × $20
  ('FC-50608272', 6, 25, true),   -- Contac Ultra C/12 tabletas
  ('FC-60403681', 10, 31, true),  -- Desenfriol D
  ('FC-84335531', 12, 54, true),  -- Cafiaspirina Forte C/24
  ('FC-8491966', 10, 20, true);   -- Aspirina 500 mg C/40 · 4 blisters × $20

update public.productos p
   set piezas_por_blister = m.piezas_por_blister,
       precio_blister = m.precio_blister,
       stock_blisters = case
         when m.convertir_stock
          and coalesce(p.stock_blisters, 0) = 0
          and coalesce(p.piezas_por_blister, 0) = 0
          and coalesce(p.stock_unidades, 0) >= m.piezas_por_blister
         then coalesce(p.stock_unidades, 0) / m.piezas_por_blister
         else coalesce(p.stock_blisters, 0)
       end,
       stock_unidades = case
         when m.convertir_stock
          and coalesce(p.stock_blisters, 0) = 0
          and coalesce(p.piezas_por_blister, 0) = 0
          and coalesce(p.stock_unidades, 0) >= m.piezas_por_blister
         then coalesce(p.stock_unidades, 0) % m.piezas_por_blister
         else coalesce(p.stock_unidades, 0)
       end
  from _blister_meds m
 where p.sku = m.sku
   and coalesce(p.venta_unidad, false) = true;

-- Verificación
select p.sku, p.nombre, p.unidades_por_caja, p.piezas_por_blister,
       public.blisters_por_caja(p.unidades_por_caja, p.piezas_por_blister) as blisters_caja,
       p.precio_blister, p.precio_unidad, p.stock_blisters, p.stock_unidades
  from public.productos p
  join _blister_meds m on m.sku = p.sku
 order by p.nombre;

commit;
