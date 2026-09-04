-- Subidas aceptadas 4-sep-2026: misma caja + nombre de Similares.
-- Cloxan $15, Alopurinol $35, Zukedib $40.
-- Ibupro-Cafe $41 y Tropharma $62 ya estaban en patch_precios_venta_aplicar_20260904.sql
-- Correr en el Editor de Supabase. No baja ningún precio.

begin;

create table if not exists public.productos_precio_backup_20260904_sim as
select id, sku, nombre, precio, costo, codigo_barras, now() as respaldado_en
from public.productos
where false;

insert into public.productos_precio_backup_20260904_sim
  (id, sku, nombre, precio, costo, codigo_barras, respaldado_en)
select p.id, p.sku, p.nombre, p.precio, p.costo, p.codigo_barras, now()
from public.productos p
where p.sku in ('FC-1DA570E3', 'FC-ACA2A2F6', 'FC-52D2A43A')
  and not exists (
    select 1 from public.productos_precio_backup_20260904_sim b where b.sku = p.sku
  );

-- Cloxan ambroxol 30 mg 20 comp · FC-1DA570E3 · ~$13 → $15 (piso)
-- Similares: AMBROXOL 30 MG 20 COMPRIMIDOS $25
update public.productos
   set precio = 15
 where sku = 'FC-1DA570E3'
   and costo is not null and costo > 0
   and 15 > costo
   and coalesce(precio, 0) is distinct from 15;

-- Alopurinol 300 mg 20 tabs · FC-ACA2A2F6 · ~$34 → $35 (piso)
-- Similares: ALOPURINOL 300 MG 20 TABLETAS $33
update public.productos
   set precio = 35
 where sku = 'FC-ACA2A2F6'
   and costo is not null and costo > 0
   and 35 > costo
   and coalesce(precio, 0) is distinct from 35;

-- Zukedib glimepirida 2 mg 30 · FC-52D2A43A · ~$38 → $40 (piso)
-- Similares: GLIMEPIRIDA 2 MG 30 TABLETAS $63 — no saltamos a 63
update public.productos
   set precio = 40
 where sku = 'FC-52D2A43A'
   and costo is not null and costo > 0
   and 40 > costo
   and coalesce(precio, 0) is distinct from 40;

commit;
