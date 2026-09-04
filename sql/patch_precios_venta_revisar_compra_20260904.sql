-- Piso > mercado. Aplica el PISO (no el min de Similares).
-- Revísalo: te puede dejar caro vs Similares. No corre en el lote seguro.
-- 12 productos
begin;

-- Backup de PVP antes de aplicar. Idempotente.
create table if not exists public.productos_precio_backup_20260904 as
select id, sku, nombre, precio, costo, codigo_barras, now() as respaldado_en
from public.productos
where false;

insert into public.productos_precio_backup_20260904 (id, sku, nombre, precio, costo, codigo_barras, respaldado_en)
select p.id, p.sku, p.nombre, p.precio, p.costo, p.codigo_barras, now()
from public.productos p
where not exists (
  select 1 from public.productos_precio_backup_20260904 b where b.id = p.id
);

-- XL-3 Xtra C/12 · FC-00170941 · $48.96 → $59 (+20.5%) · costo $36.26 · revisar_compra
update public.productos
   set precio = 59
 where sku = 'FC-00170941'
   and costo is not null and costo > 0
   and 59 > costo
   and abs(coalesce(precio, 0) - 59) >= 1.5;
-- Electrolit Coco · FC-25104411 · $32.15 → $29 (-9.8%) · costo $20.09 · revisar_compra
update public.productos
   set precio = 29
 where sku = 'FC-25104411'
   and costo is not null and costo > 0
   and 29 > costo
   and abs(coalesce(precio, 0) - 29) >= 1.5;
-- Electrolit Eresa-Kiwi · FC-25149221 · $32.15 → $29 (-9.8%) · costo $20.09 · revisar_compra
update public.productos
   set precio = 29
 where sku = 'FC-25149221'
   and costo is not null and costo > 0
   and 29 > costo
   and abs(coalesce(precio, 0) - 29) >= 1.5;
-- Electrolit Uva · FC-51448511 · $32.81 → $29 (-11.6%) · costo $20.50 · revisar_compra
update public.productos
   set precio = 29
 where sku = 'FC-51448511'
   and costo is not null and costo > 0
   and 29 > costo
   and abs(coalesce(precio, 0) - 29) >= 1.5;
-- Histiacil NF adulto jarabe · FC-28979502 · $161.72 → $165 (+2.0%) · costo $121.91 · revisar_compra
update public.productos
   set precio = 165
 where sku = 'FC-28979502'
   and costo is not null and costo > 0
   and 165 > costo
   and abs(coalesce(precio, 0) - 165) >= 1.5;
-- Desenfriol · FC-60403681 · $100.81 → $86 (-14.7%) · costo $63.00 · revisar_compra
update public.productos
   set precio = 86
 where sku = 'FC-60403681'
   and costo is not null and costo > 0
   and 86 > costo
   and abs(coalesce(precio, 0) - 86) >= 1.5;
-- Contac Ultra · FC-50608272 · $43.66 → $52 (+19.1%) · costo $32.34 · revisar_compra
update public.productos
   set precio = 52
 where sku = 'FC-50608272'
   and costo is not null and costo > 0
   and 52 > costo
   and abs(coalesce(precio, 0) - 52) >= 1.5;
-- Saridon · FC-84095411 · $84.18 → $88 (+4.5%) · costo $64.75 · revisar_compra
update public.productos
   set precio = 88
 where sku = 'FC-84095411'
   and costo is not null and costo > 0
   and 88 > costo
   and abs(coalesce(precio, 0) - 88) >= 1.5;
-- Flanax · FC-84973401 · $237.51 → $247 (+4.0%) · costo $182.70 · revisar_compra
update public.productos
   set precio = 247
 where sku = 'FC-84973401'
   and costo is not null and costo > 0
   and 247 > costo
   and abs(coalesce(precio, 0) - 247) >= 1.5;
-- Amifarin · FC-D5AC44CA · $59.52 → $62 (+4.2%) · costo $45.78 · revisar_compra
update public.productos
   set precio = 62
 where sku = 'FC-D5AC44CA'
   and costo is not null and costo > 0
   and 62 > costo
   and abs(coalesce(precio, 0) - 62) >= 1.5;
-- Tarmin 2 Mg /12 · FC-88915491 · $77.00 → $79 (+2.6%) · costo $58.50 · revisar_compra
update public.productos
   set precio = 79
 where sku = 'FC-88915491'
   and costo is not null and costo > 0
   and 79 > costo
   and abs(coalesce(precio, 0) - 79) >= 1.5;
-- Gentamicina · FC-60F627D5 · $84.12 → $71 (-15.6%) · costo $52.57 · revisar_compra
update public.productos
   set precio = 71
 where sku = 'FC-60F627D5'
   and costo is not null and costo > 0
   and 71 > costo
   and abs(coalesce(precio, 0) - 71) >= 1.5;

commit;
