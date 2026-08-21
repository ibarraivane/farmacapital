-- Farmalive Club Iztapalapa 1 · ticket 11590 · 21-ago-2026 09:46
-- Central de Abastos · tarjeta crédito $704.42
-- 6 renglones · costo = precio NETO (después del descuento del ticket).
-- El ticket no trae lote de fábrica. Lote de recepción (como Recibir):
--   RX-FARMALIVE-20260821-11590  = tienda + fecha + folio.
-- No es el lote impreso en la caja. Al abrirla, cámbialo en Lotes y pon caducidad.
--
-- 6 altas. El Tums C/48 NO es el Tums de 8 tab (FC-65054135 / 7501065054043).
-- ADDITIVO e idempotente (si ya existe ese RX- en el producto, no vuelve a recibir).
--
-- Corre este archivo .sql en Supabase. NO pegues el CSV.
-- Elige UNA vía: este SQL o Importar CSV. No las dos.
-- proveedor no existe en productos: se guarda en lotes.proveedor_id.

begin;

create temp table _fc_fl11590 (
  linea integer,
  ean text primary key,
  sku text not null,
  nombre text not null,
  categoria text not null,
  tipo text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  stock_minimo integer not null,
  lote text not null,
  marca text,
  presentacion text,
  principio_activo text,
  concentracion text,
  requiere_receta boolean not null default false,
  notas text,
  es_alta boolean not null
) on commit drop;

insert into _fc_fl11590 values
  (1, '7501065054029', 'FC-65054029', 'Tums surtido tabletas masticables C/48', 'Gastro', 'marca', 2, 85.26, 137.00, 2, 'RX-FARMALIVE-20260821-11590', 'Tums', 'Caja con 48 tabletas masticables', 'Carbonato de calcio', null, false, 'Ticket Farmalive 11590 · ≠ Tums 8 tab FC-65054135 EAN 7501065054043', true),
  (2, '7501019064807', 'FC-19064807', 'Tena Pants Comfort grande C/13', 'Higiene', 'marca', 1, 113.62, 182.00, 1, 'RX-FARMALIVE-20260821-11590', 'Tena', 'Bolsa con 13 pants talla grande', null, null, false, 'Ticket Farmalive 11590 · Essity', true),
  (3, '7500435179980', 'FC-43517980', 'Oral-B enjuague bucal 100% 250 mL', 'Cuidado personal', 'marca', 2, 47.79, 77.00, 2, 'RX-FARMALIVE-20260821-11590', 'Oral-B', 'Botella 250 mL', null, null, false, 'Ticket Farmalive 11590', true),
  (4, '7891051037878', 'FC-51037878', 'Oral-B enjuague bucal Complete 250 mL', 'Cuidado personal', 'marca', 2, 47.50, 76.00, 2, 'RX-FARMALIVE-20260821-11590', 'Oral-B', 'Botella 250 mL', null, null, false, 'Ticket Farmalive 11590 · distinto del Oral-B 100%', true),
  (5, '5000174305449', 'FC-74305449', 'Fixodent Original crema dental 40 mL', 'Cuidado personal', 'marca', 2, 93.30, 150.00, 2, 'RX-FARMALIVE-20260821-11590', 'Fixodent', 'Tubo 40 mL', null, null, false, 'Ticket Farmalive 11590 · adhesivo para dentadura', true),
  (6, '020800600330', 'FC-08006033', 'Tampax Super C/10', 'Higiene', 'marca', 1, 43.12, 69.00, 1, 'RX-FARMALIVE-20260821-11590', 'Tampax', 'Caja con 10 tampones super', null, null, false, 'Ticket Farmalive 11590 · UPC 12 dígitos 020800600330', true);

do $$
declare
  r record;
  v_pid bigint;
  v_lid bigint;
  n_alta integer := 0;
  n_recv integer := 0;
  n_skip integer := 0;
begin
  for r in select * from _fc_fl11590 order by linea loop
    select p.id into v_pid
    from public.productos p
    where p.codigo_barras = r.ean or p.sku = r.sku
    order by case when p.codigo_barras = r.ean then 0 else 1 end, p.id
    limit 1;

    if v_pid is null then
      select f.producto_id into v_pid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', r.nombre,
          'sku', r.sku,
          'codigo_barras', r.ean,
          'categoria', r.categoria,
          'tipo', r.tipo,
          'descripcion', r.notas,
          'costo', r.costo,
          'precio', r.precio,
          'stock_minimo', r.stock_minimo,
          'activo', true,
          'requiere_receta', r.requiere_receta
        ),
        0,  -- catálogo sin stock; Recibir + pistola
        null,
        null::date,
        r.costo,
        null::bigint
      ) f;
      n_alta := n_alta + 1;
    else
      update public.productos set
        costo = r.costo,
        precio = r.precio,
        stock_minimo = r.stock_minimo
      where id = v_pid;
    end if;

    update public.productos set
      marca = r.marca,
      presentacion = r.presentacion,
      principio_activo = coalesce(r.principio_activo, principio_activo),
      concentracion = coalesce(r.concentracion, concentracion),
      categoria = r.categoria
    where id = v_pid;
  end loop;

  raise notice 'Farmalive 11590: % altas de catálogo (stock = Recibir)', n_alta;
end $$;

select
  t.linea,
  t.sku,
  t.ean,
  left(t.nombre, 42) as nombre,
  t.qty as pzas_ticket,
  p.stock as stock_bd,
  t.costo as costo_ticket,
  p.costo as costo_bd,
  t.precio as pvp,
  p.precio as pvp_bd,
  l.numero_lote,
  l.cantidad_actual as lote_qty,
  case
    when p.id is null then 'SIN PRODUCTO'
    when l.id is null then 'SIN LOTE'
    else 'OK'
  end as estado
from _fc_fl11590 t
left join public.productos p on p.codigo_barras = t.ean or p.sku = t.sku
left join lateral (
  select l.* from public.lotes l
  where l.producto_id = p.id and l.numero_lote = t.lote and coalesce(l.activo, true)
  order by l.id desc
  limit 1
) l on true
order by t.linea;

commit;
