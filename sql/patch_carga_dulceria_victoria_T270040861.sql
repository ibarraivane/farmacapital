-- Dulcería La Victoria · nota T270040861 · 2026-09-18 12:17
-- Ticket imprime «DULCERIA LA FAMOSA» (WinCaja, clave LAFAM21702) pero el negocio
-- es Dulcería La Victoria, Bodega F-20 Central de Abasto
-- (correo quejas_ysug@dulcerialavictoria.com).
-- Total tarjeta $445.34. Mayoreo → piezas de mostrador.
-- Turin 4/600GR ×1 → 4 conejos de 600 g. KitKat 22/9PZ ×1 → 22 packs.
-- Turin y KitKat salen al buscar «chocolate» o «chocolates» (categoría Chocolates).
-- Halls y Skittles se quedan en Impulso.
--
-- SIN EAN en el ticket: no se inventan códigos. codigo_barras queda null
-- hasta escanear la caja. Stock al confirmar en Recibir + MMAA de la caja.
-- TODO foto: packshot del conejo y del pack KitKat. No usar placeholder de otra cadena.
-- No poner caducidad 0000.
--
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

insert into public.proveedores (nombre, activo)
select 'Dulcería La Victoria', true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower('Dulcería La Victoria')
);

create temp table _fc_lv_t270040861 (
  linea integer primary key,
  sku text not null,
  snap text not null,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  categoria text not null,
  subcategoria text,
  tipo text not null,
  qty integer not null,
  costo numeric(12,4) not null,
  precio numeric(12,2) not null
) on commit drop;

insert into _fc_lv_t270040861
  (linea, sku, snap, nombre, marca, presentacion, categoria, subcategoria, tipo, qty, costo, precio)
values

  (1, 'FC-LV-TURIN600', 'TURIN CONEJO FOCO VIT. 4/600GR', 'Turin Conejo foco chocolate 600 g', 'Turin', 'Conejo 600 g (caja mayoreo 4)', 'Chocolates', 'Chocolates', 'marca', 4, 76.1475, 107.00),
  (2, 'FC-LV-KITKAT22', 'NESTLE KITKAT EXTRA MILK & COCOA 22/9PZ', 'KitKat Extra Milk & Cocoa chocolate', 'KitKat', 'Pack 9 piezas (exhibidor 22)', 'Chocolates', 'Chocolates', 'marca', 22, 6.3977, 9.00);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, costo, precio, stock, stock_minimo,
  activo, requiere_receta
)
select
  t.nombre,
  t.sku,
  null,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Dulcería La Victoria T270040861 · 2026-09-18 · EAN pendiente de caja · ticket decía La Famosa',
  t.marca,
  t.presentacion,
  t.costo,
  t.precio,
  0,
  greatest(2, least(t.qty / 4, 10)),
  true,
  false
from _fc_lv_t270040861 t
where not exists (
  select 1 from public.productos p where p.sku = t.sku
);

update public.productos p
set
  nombre = t.nombre,
  costo = t.costo,
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end,
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
  categoria = t.categoria,
  subcategoria = coalesce(t.subcategoria, p.subcategoria)
from _fc_lv_t270040861 t
where p.sku = t.sku;

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Dulcería La Victoria',
  'T270040861',
  '2026-09-18',
  445.34,
  'borrador',
  'Nota T270040861 · ticket imprime La Famosa · negocio La Victoria F-20 · Turin Conejo 4 pzas + KitKat Extra 22 packs · EAN pendiente de caja · stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'T270040861'
    and coalesce(proveedor, '') ilike '%victoria%'
);

update public.recepciones
set
  total_ticket = 445.34,
  fecha = '2026-09-18',
  proveedor = 'Dulcería La Victoria',
  notas = 'Nota T270040861 · ticket imprime La Famosa · negocio La Victoria F-20 · Turin Conejo 4 pzas + KitKat Extra 22 packs · EAN pendiente de caja · stock al confirmar pistola',
  updated_at = now()
where folio = 'T270040861'
  and coalesce(proveedor, '') ilike '%victoria%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'T270040861'
  and coalesce(r.proveedor, '') ilike '%victoria%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  p.id,
  null,
  t.nombre,
  t.qty,
  null,
  null,
  t.costo,
  (p.id is null),
  'pdf',
  false,
  false,
  null
from _fc_lv_t270040861 t
join public.recepciones r
  on r.folio = 'T270040861'
 and coalesce(r.proveedor, '') ilike '%victoria%'
 and r.estado = 'borrador'
left join public.productos p on p.sku = t.sku
order by t.linea;

select r.folio, r.estado, r.total_ticket, count(i.*) as renglones, sum(i.cantidad) as piezas
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = 'T270040861' and coalesce(r.proveedor, '') ilike '%victoria%'
group by r.id, r.folio, r.estado, r.total_ticket;

commit;
