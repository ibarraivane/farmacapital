-- ============================================================================
-- Ticket vs ventas vs lotes — 2026-08-19
--
-- Las 6 fichas que bajaron 1→0 SÍ se vendieron (pedidos 28, 37, 38, 40, 43).
-- Lo que faltaba era mercancía de ticket colgada en otra ficha, o ficha
-- duplicada vacía. Este script:
--   1) Devuelve a su SKU los lotes Equilibrio mal asignados (sin venta).
--   2) Carga Tabcin Active y Redoxon 2-pack que nunca entraron a lotes.
--   3) Apaga fichas duplicadas vacías (Ampicilina foto, Fotosun FMX).
--   4) Apaga lotes fantasma (qty 0, activo, cantidad_inicial > 0).
--
-- Después: sql/patch_create_sale_precio_unidad_regla.sql
-- (fn_ensure_lote_stock_vendible + create_sale para no vender sin lote).
--
-- Idempotente. Correr en SQL Editor (service role / postgres).
-- ============================================================================

begin;

-- 1) Pioglitazona 30 mg AMS401 (2 pza, lote U25T360) estaba en EQ-ULT146 (15 mg).
--    Un ajuste inline FEFO se comió ese lote porque caducaba antes.
update public.lotes l
   set producto_id = p.id,
       cantidad_actual = 2,
       activo = true
  from public.productos p
 where l.id = 1179
   and l.numero_lote = 'U25T360'
   and p.sku = 'FC-49024175'
   and coalesce(l.cantidad_actual, 0) = 0;

insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
select p.id, 'entrada', 2,
       'Reasignar lote U25T360 desde EQ-ULT146 · ticket Equilibrio AMS401'
  from public.productos p
 where p.sku = 'FC-49024175'
   and not exists (
     select 1 from public.movimientos_inventario m
      where m.producto_id = p.id
        and m.motivo like 'Reasignar lote U25T360%'
   );

-- 2) Pregabalina C/14 AMS231 (1 pza, U26F252) estaba en EQ-AMS232 (C/28).
update public.lotes l
   set producto_id = p.id,
       cantidad_actual = 1,
       activo = true
  from public.productos p
 where l.id = 1146
   and l.numero_lote = 'U26F252'
   and p.sku = 'FC-49025967'
   and coalesce(l.cantidad_actual, 0) = 0;

insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
select p.id, 'entrada', 1,
       'Reasignar lote U26F252 desde EQ-AMS232 · ticket Equilibrio AMS231'
  from public.productos p
 where p.sku = 'FC-49025967'
   and not exists (
     select 1 from public.movimientos_inventario m
      where m.producto_id = p.id
        and m.motivo like 'Reasignar lote U26F252%'
   );

-- 3) Pregabalina 150 mg AMS234: no había ficha. El lote U26F083 quedó en AMS232.
do $$
declare
  v_pid bigint;
begin
  select id into v_pid from public.productos where sku = 'EQ-AMS234' limit 1;
  if v_pid is null then
    insert into public.productos (
      nombre, sku, categoria, tipo, descripcion,
      costo, precio, stock, stock_minimo, activo, requiere_receta,
      marca, presentacion, principio_activo, concentracion, forma_farmaceutica
    ) values (
      'Pregabalina 28 Cáps 150 mg AMSA',
      'EQ-AMS234',
      'Medicamentos',
      'generico',
      'Ticket Equilibrio 440393 · AMS234 · lote U26F083. Alta 2026-08-19: el lote había quedado en EQ-AMS232.',
      65.67,
      105,
      0,
      1,
      true,
      true,
      'AMSA',
      'Caja con 28 cápsulas',
      'Pregabalina',
      '150 mg',
      'Cápsula'
    ) returning id into v_pid;
  end if;

  update public.lotes
     set producto_id = v_pid,
         cantidad_actual = 1,
         activo = true
   where id = 1183
     and numero_lote = 'U26F083'
     and coalesce(cantidad_actual, 0) = 0;

  insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
  select v_pid, 'entrada', 1,
         'Reasignar lote U26F083 desde EQ-AMS232 · ticket Equilibrio AMS234'
   where not exists (
     select 1 from public.movimientos_inventario m
      where m.producto_id = v_pid
        and m.motivo like 'Reasignar lote U26F083%'
   );
end $$;

-- 4) Tabcin Active · ticket Farmalive 2 pza · nunca hubo lote.
insert into public.lotes (
  producto_id, numero_lote, cantidad_inicial, cantidad_actual,
  costo_unitario, activo
)
select p.id, 'TK-FL-080826-TABCIN-ACTIVE', 2, 2, p.costo, true
  from public.productos p
 where p.sku = 'FC-08499689'
   and coalesce(p.stock, 0) = 0
   and not exists (
     select 1 from public.lotes l
      where l.producto_id = p.id and coalesce(l.cantidad_actual, 0) > 0
   );

insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
select p.id, 'entrada', 2, 'Alta lote ticket Farmalive 9861 · Tabcin Active C/12 ×2'
  from public.productos p
 where p.sku = 'FC-08499689'
   and not exists (
     select 1 from public.movimientos_inventario m
      where m.producto_id = p.id
        and m.motivo like '%Tabcin Active%'
   );

-- 5) Redoxon 2-pack · ticket Farmalive 1 pza · nunca hubo lote.
--    FC-8421321 (tubo c/10, otro EAN) no se toca.
insert into public.lotes (
  producto_id, numero_lote, cantidad_inicial, cantidad_actual,
  costo_unitario, activo
)
select p.id, 'TK-FL-080826-REDOXON-2PACK', 1, 1, p.costo, true
  from public.productos p
 where p.sku = 'FC-08421321'
   and coalesce(p.stock, 0) = 0
   and not exists (
     select 1 from public.lotes l
      where l.producto_id = p.id and coalesce(l.cantidad_actual, 0) > 0
   );

insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
select p.id, 'entrada', 1, 'Alta lote ticket Farmalive 9861 · Redoxon 1g 2-pack ×1'
  from public.productos p
 where p.sku = 'FC-08421321'
   and not exists (
     select 1 from public.movimientos_inventario m
      where m.producto_id = p.id
        and m.motivo like '%Redoxon 1g 2-pack%'
   );

-- 6) Duplicados vacíos: Ampicilina foto (el stock vive en FC-D210172A, lote 126H505)
--    y Fotosun FMX (el stock vive en FC-00E8A9C7).
update public.productos
   set activo = false
 where sku in ('FC-90973703', 'FMX-300861')
   and coalesce(stock, 0) = 0
   and coalesce(activo, true);

-- 7) Lotes fantasma: qty 0, siguen activos, sí se recibieron alguna vez.
--    Tapan Reabasto/POS si se usa "hay lote" en vez de "hay piezas".
update public.lotes
   set activo = false
 where coalesce(activo, true)
   and coalesce(cantidad_actual, 0) = 0
   and coalesce(cantidad_inicial, 0) > 0;

commit;

-- Verificación
select p.sku, p.nombre, p.stock, p.activo,
       l.numero_lote, l.cantidad_actual, l.activo as lote_activo, l.fecha_caducidad
  from public.productos p
  left join public.lotes l
    on l.producto_id = p.id and coalesce(l.activo, true)
 where p.sku in (
   'FC-54549819','FC-30622622','FC-82200016','FC-75354321',
   'FC-58793249','EQ-QUI127','FC-90973703','FC-D210172A',
   'FMX-300861','FC-00E8A9C7','FC-49024175','EQ-ULT146',
   'FC-49025967','EQ-AMS232','EQ-AMS234','FC-08499689',
   'FC-08421321','FC-8421321','FC-01162365','FC-42507240'
 )
 order by p.sku, l.id;
