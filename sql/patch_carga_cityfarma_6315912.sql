-- Cityfarma Iztapalapa · venta 6315912 · 21-ago-2026 09:15
-- Comercializadora Yalesa / Cityfarma · PAGADO
-- 11 renglones · suma P.U.×qty = $2,570.99 (el ticket parte IVA $79.94 ya va en el P.U.)
-- El ticket no trae caducidad: Recibir captura MMAA de la caja.
-- Este SQL solo deja el producto en catálogo. El stock entra al confirmar pistola.
-- 4 ya estaban · 7 altas.
--
-- Elige UNA vía: este SQL **o** Importar CSV. No las dos.
-- Ejecutar en Supabase SQL Editor (archivo completo).

begin;

create temp table _fc_cf6315912 (
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

insert into _fc_cf6315912 values
  (1, '7501050613453', 'FC-06134531', 'Afrin Adulto spray 20 mL', 'Respiratorio', 'marca', 2, 75.38, 120.74, 5, '2601928', 'Afrin', 'Spray 20 mL', 'Oximetazolina', null, false, 'Ticket Cityfarma 6315912 · ya existía', false),
  (2, '7501050623766', 'FC-05062376', 'Afrin No Drip solución nasal 15 mL', 'Respiratorio', 'marca', 2, 115.52, 185.00, 2, '2601390', 'Afrin', 'Solución 15 mL', 'Oximetazolina', null, false, 'Ticket Cityfarma 6315912 · distinto de Afrin No Drip spray 7501050624732', true),
  (3, '7501165001725', 'FC-16500172', 'Allegra fexofenadina 180 mg C/10', 'Alergia', 'marca', 1, 362.97, 436.00, 2, 'GMX0303', 'Allegra', 'Caja con 10 tabletas', 'Fexofenadina', '180 mg', false, 'Ticket Cityfarma 6315912 · costo cerca de menudeo, margen 20%', true),
  (4, '7501065001337', 'FC-06500133', 'Caltrate 600 + D C/30', 'Vitaminas', 'marca', 2, 153.59, 246.00, 2, 'T75M', 'Caltrate', 'Caja con 30 tabletas', 'Carbonato de calcio + vitamina D', '600 mg', false, 'Ticket Cityfarma 6315912', true),
  (5, '7502276040368', 'FC-60403681', 'Desenfriol D', 'Respiratorio', 'marca', 3, 61.68, 86.00, 5, '2601928', 'Desenfriol', 'C/30', 'Clorfenamina/Fenilefrina/Paracetamol', null, false, 'Ticket Cityfarma 6315912 · lote igual al de Afrin Adulto: confirmar en caja', false),
  (6, '7502276040405', 'FC-76040610', 'Desenfriolito Plus Masticables', 'Analgésico', 'marca', 2, 57.76, 93.00, 5, 'X26RXS', 'Bayer', 'C/24 1 mg/2.5 mg/80 mg', 'Clorfenamina/Fenilefrina/Paracetamol', null, false, 'Ticket Cityfarma 6315912 · costo subió; PVP 63→93 para no vender a 8%', false),
  (7, '7501300421524', 'FC-30042152', 'Dolac ketorolaco 10 mg C/10 cápsulas', 'Analgésico', 'marca', 3, 99.73, 160.00, 2, 'T0623', 'Dolac', 'Caja con 10 cápsulas', 'Ketorolaco', '10 mg', true, 'Ticket Cityfarma 6315912 · receta. Distinto de ketorolaco genérico AMSA/Maver', true),
  (8, '3664798074680', 'FC-79807468', 'Enterogermina 2 billones C/10', 'Gastro', 'marca', 1, 200.00, 320.00, 2, '6I086', 'Enterogermina', 'Caja con 10 frascos 5 mL', 'Bacillus clausii', '2 billones', false, 'Ticket Cityfarma 6315912', true),
  (9, '7501289511421', 'FC-9511421', 'Pasta Lassar Andromaco 30 g', 'Botiquín', 'marca', 2, 22.50, 31.89, 2, '26PL029', 'Andromaco', 'Frasco 30 g', 'Óxido de zinc 25%', null, false, 'Ticket Cityfarma 6315912 · stock estaba en 0', false),
  (10, '7501289511414', 'FC-28951141', 'Pasta Lassar Andromaco 60 g', 'Botiquín', 'marca', 2, 47.37, 76.00, 2, '26PL057', 'Andromaco', 'Frasco 60 g', 'Óxido de zinc 25%', null, false, 'Ticket Cityfarma 6315912 · distinta de la de 30 g', true),
  (11, '4001895928765', 'FC-89592876', 'Tegaderm 3M 10 x 12 cm C/50', 'Dispositivo médico', 'marca', 1, 579.55, 696.00, 1, '344JWY', 'Tegaderm', 'Caja con 50 apósitos 10 x 12 cm', null, null, false, 'Ticket Cityfarma 6315912 · caja C/50. Costo alto, margen 20%', true);

do $$
declare
  r record;
  v_pid bigint;
  v_lid bigint;
  n_alta integer := 0;
  n_recv integer := 0;
  n_skip integer := 0;
begin
  for r in select * from _fc_cf6315912 order by linea loop
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
      ) f;      n_alta := n_alta + 1;
    else
      update public.productos set
        costo = r.costo,
        precio = r.precio,
        stock_minimo = r.stock_minimo
      where id = v_pid;
    end if;

    -- proveedor vive en lotes.proveedor_id, no en productos (el lote nace al confirmar)

    update public.productos set
      marca = r.marca,
      presentacion = r.presentacion,
      principio_activo = coalesce(r.principio_activo, principio_activo),
      concentracion = coalesce(r.concentracion, concentracion),
      categoria = r.categoria
    where id = v_pid;
  end loop;

  raise notice 'Cityfarma 6315912: % altas de catálogo (stock = Recibir)', n_alta;
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
from _fc_cf6315912 t
left join public.productos p on p.codigo_barras = t.ean or p.sku = t.sku
left join lateral (
  select l.* from public.lotes l
  where l.producto_id = p.id and l.numero_lote = t.lote and coalesce(l.activo, true)
  order by l.id desc
  limit 1
) l on true
order by t.linea;

commit;
