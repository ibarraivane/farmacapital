-- Dulcería La Victoria · nota T280033139 · 2026-09-05 11:33
-- Ticket imprime "DULCERIA LA FAMOSA" (WinCaja LAFAM73305) pero el negocio
-- es Dulcería La Victoria, Bodega F-20 Central de Abasto
-- (correo quejas_ysug@dulcerialavictoria.com.mx).
-- Total tarjeta $404.89. 5 exhibidores/cuadretas → piezas de mostrador.
--
-- SIN EAN en el ticket: no se inventan códigos. codigo_barras queda null
-- hasta escanear la caja. Stock al confirmar en Recibir + MMAA de la caja.
-- No poner caducidad 0000.
--
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Ver docs/analisis/DIAGNOSTICO_DULCERIA_LA_VICTORIA_T280033139.md

begin;

insert into public.proveedores (nombre, activo)
select 'Dulcería La Victoria', true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower('Dulcería La Victoria')
);

create temp table _fc_lv_t280033139 (
  linea integer primary key,
  sku text not null,
  snap text not null,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  categoria text not null,
  tipo text not null,
  qty integer not null,
  costo numeric(12,4) not null,
  precio numeric(12,2) not null
) on commit drop;

insert into _fc_lv_t280033139
  (linea, sku, snap, nombre, marca, presentacion, categoria, tipo, qty, costo, precio)
values
  (1, 'FC-LV-SKITTLES24', 'SKITTLES ORIGINAL, 24/10PZ',
   'Skittles Original bolsa', 'Skittles', 'Bolsa (caja mayoreo 24/10PZ)',
   'Impulso', 'marca', 24, 3.1083, 5.00),
  (2, 'FC-LV-HALLSY12', 'HALLS YERBA 30/12PZ',
   'Halls Yerbabuena pack', 'Halls', 'Pack (cuadreta 12 · master 30)',
   'Impulso', 'marca', 12, 6.1667, 9.00),
  (3, 'FC-LV-ORBITFRE40', 'ORBIT 4P FRESA, 24/40PZ',
   'Orbit 4''s Fresa', 'Orbit', 'Pack 4 pastillas (exhibidor 40)',
   'Impulso', 'marca', 40, 2.1765, 4.00),
  (4, 'FC-LV-ORBITHB40', 'ORBIT 4P HIERBABUENA, 24/40PZ',
   'Orbit 4''s Hierbabuena', 'Orbit', 'Pack 4 pastillas (exhibidor 40)',
   'Impulso', 'marca', 40, 2.1765, 4.00),
  (5, 'FC-LV-CLORETS40', 'CLORETS 4 S PLUS 24/40PZ',
   'Clorets Plus 4''s', 'Clorets', 'Pack 4 pastillas (exhibidor 40)',
   'Impulso', 'marca', 40, 2.0543, 3.00);

-- Altas sin EAN (null). Completar codigo_barras al escanear la caja.
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  marca, presentacion, costo, precio, stock, stock_minimo,
  activo, requiere_receta
)
select
  t.nombre,
  t.sku,
  null,
  t.categoria,
  t.tipo,
  'Alta Dulcería La Victoria T280033139 · 2026-09-05 · EAN pendiente de caja · ticket decía La Famosa',
  t.marca,
  t.presentacion,
  t.costo,
  t.precio,
  0,
  greatest(2, least(t.qty / 4, 10)),
  true,
  false
from _fc_lv_t280033139 t
where not exists (
  select 1 from public.productos p where p.sku = t.sku
);

update public.productos p
set
  costo = t.costo,
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end,
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
  categoria = t.categoria
from _fc_lv_t280033139 t
where p.sku = t.sku;

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Dulcería La Victoria',
  'T280033139',
  '2026-09-05',
  404.89,
  'borrador',
  'Nota T280033139 · ticket imprime La Famosa (LAFAM73305) · negocio La Victoria F-20 · EAN pendiente de caja · stock al confirmar pistola/toque'
where not exists (
  select 1 from public.recepciones
  where folio = 'T280033139'
    and coalesce(proveedor, '') ilike '%victoria%'
);

update public.recepciones
set
  total_ticket = 404.89,
  fecha = '2026-09-05',
  proveedor = 'Dulcería La Victoria',
  notas = 'Nota T280033139 · ticket imprime La Famosa (LAFAM73305) · negocio La Victoria F-20 · EAN pendiente de caja · stock al confirmar pistola/toque',
  updated_at = now()
where folio = 'T280033139'
  and coalesce(proveedor, '') ilike '%victoria%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'T280033139'
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
  t.snap,
  t.qty,
  null,
  null,
  t.costo,
  false,
  'pdf',
  false,
  (
    exists (
      select 1 from public.lotes l
      where l.producto_id = p.id
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_lv_t280033139 t
join public.recepciones r
  on r.folio = 'T280033139'
 and coalesce(r.proveedor, '') ilike '%victoria%'
 and r.estado = 'borrador'
join public.productos p on p.sku = t.sku
order by t.linea;

commit;

select
  i.id,
  p.sku,
  p.codigo_barras as ean,
  left(i.nombre_snapshot, 40) as snap,
  left(p.nombre, 36) as nombre,
  i.cantidad as pzas,
  i.costo_estimado,
  p.precio as pvp,
  case when p.codigo_barras is null then 'EAN PENDIENTE' else 'OK' end as ean_estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
join public.productos p on p.id = i.producto_id
where r.folio = 'T280033139' and coalesce(r.proveedor, '') ilike '%victoria%'
order by i.id;
