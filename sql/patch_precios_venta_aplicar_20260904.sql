-- PVP dentro de ±30% / −20%, siempre arriba del costo.
-- Generado por scripts/generar_sql_precios_venta_20260904.py
-- 10 productos
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

-- Afrin Adulto rojo spray · FC-06134531 · $120.74 → $113 (-6.4%) · costo $75.46 · bajar
update public.productos
   set precio = 113
 where sku = 'FC-06134531'
   and costo is not null and costo > 0
   and 113 > costo
   and abs(coalesce(precio, 0) - 113) >= 1.5;
-- Amikacina · FC-11294615 · $51.11 → $55 (+7.6%) · costo $31.94 · subir
update public.productos
   set precio = 55
 where sku = 'FC-11294615'
   and costo is not null and costo > 0
   and 55 > costo
   and abs(coalesce(precio, 0) - 55) >= 1.5;
-- Penipot · FC-F183C6E9 · $25.28 → $31 (+22.6%) · costo $19.44 · subir
update public.productos
   set precio = 31
 where sku = 'FC-F183C6E9'
   and costo is not null and costo > 0
   and 31 > costo
   and abs(coalesce(precio, 0) - 31) >= 1.5;
-- Clindamicina · FC-9A4E4C31 · $141.48 → $135 (-4.6%) · costo $88.42 · bajar
update public.productos
   set precio = 135
 where sku = 'FC-9A4E4C31'
   and costo is not null and costo > 0
   and 135 > costo
   and abs(coalesce(precio, 0) - 135) >= 1.5;
-- Enjuague Buc Listerine Cuidado Total · FC-31887928 · $89.00 → $97 (+9.0%) · costo $63.53 · subir
update public.productos
   set precio = 97
 where sku = 'FC-31887928'
   and costo is not null and costo > 0
   and 97 > costo
   and abs(coalesce(precio, 0) - 97) >= 1.5;
-- Pedialyte · FC-33954740 · $38.10 → $35 (-8.1%) · costo $23.81 · bajar
update public.productos
   set precio = 35
 where sku = 'FC-33954740'
   and costo is not null and costo > 0
   and 35 > costo
   and abs(coalesce(precio, 0) - 35) >= 1.5;
-- Ibupro-Cafe · FC-3D0F54B7 · $39.08 → $41 (+4.9%) · costo $30.06 · mantener
update public.productos
   set precio = 41
 where sku = 'FC-3D0F54B7'
   and costo is not null and costo > 0
   and 41 > costo
   and abs(coalesce(precio, 0) - 41) >= 1.5;
-- Tropharma · FC-86A95D07 · $57.89 → $62 (+7.1%) · costo $44.53 · subir
update public.productos
   set precio = 62
 where sku = 'FC-86A95D07'
   and costo is not null and costo > 0
   and 62 > costo
   and abs(coalesce(precio, 0) - 62) >= 1.5;
-- Dac (Paracetamol + Diclofenaco) · FC-1FFBB505 · $54.79 → $66 (+20.5%) · costo $42.14 · subir
update public.productos
   set precio = 66
 where sku = 'FC-1FFBB505'
   and costo is not null and costo > 0
   and 66 > costo
   and abs(coalesce(precio, 0) - 66) >= 1.5;
-- Jabon Grisi Avena · FC-22150801 · $31.00 → $33 (+6.5%) · costo $21.72 · subir
update public.productos
   set precio = 33
 where sku = 'FC-22150801'
   and costo is not null and costo > 0
   and 33 > costo
   and abs(coalesce(precio, 0) - 33) >= 1.5;

commit;
