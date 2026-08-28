-- Levic · factura interna A 9012078353 · CFDI 20-ago-2026 00:44
-- Folio fiscal 9E99EEE5-8369-4D61-8E09-17F0ECBB6670 · PUE efectivo $637.25
-- Receptor LUIS ANGEL PALILLERO VENTURA · 7 renglones (hoja 1; totales cuadran).
-- Costo = Precio neto del CFDI (no el PMP). Lote = de fábrica (sí viene en la factura).
-- Caducidad del papel NO se escribe aquí: Recibir captura MMAA de la caja.
-- Este SQL solo deja el producto en catálogo. El stock entra al confirmar pistola.
--
-- 5 ya estaban · 2 altas (sildenafil 1 tab, Agecaps minoxidil).
--
-- Elige UNA vía: este SQL **o** Importar CSV. No las dos.
-- Ejecutar en Supabase SQL Editor (archivo completo).
-- proveedor no existe en productos: se guarda en lotes.proveedor_id.

begin;

create temp table _fc_lv9012078353 (
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

insert into _fc_lv9012078353 values
  (1, '7501342802749', 'EQ-BEA267', 'Sildenafil beadvance 50 mg 1 tableta', 'Medicamentos', 'generico', 4, 4.90, 8.00, 4, 'ECM297C', 'beadvance', '1 tableta', 'Sildenafil', '50 mg', false, 'Factura Levic 9012078353 · ≠ Sildenafil C/4 100 mg EQ-ULT145 · ≠ Figral C/10', true),
  (2, '7501573909958', 'EQ-BIO212', 'Colchicina 30 Tab 1 Mg', 'Medicamentos', 'generico', 2, 31.24, 50.00, 2, 'SD2602', 'Biomep', 'Caja con 30 tabletas', 'Colchicina', '1 mg', false, 'Factura Levic 9012078353 · ya existía EQ-BIO212', false),
  (3, '7501048335138', 'FC-83351381', 'Agua oxigenada Dermocleen 100 mL', 'Botiquín', 'marca', 2, 8.08, 13.00, 2, '3A206030', 'Dermocleen', 'Frasco 100 mL', 'Peróxido de hidrógeno', '2.5 a 3.5%', false, 'Factura Levic 9012078353 · ya existía FC-83351381 (a veces listado como Protec)', false),
  (4, '7501048335169', 'FC-83351691', 'Agua oxigenada Dermocleen 230 mL', 'Botiquín', 'marca', 2, 11.57, 19.00, 2, '3A196054', 'Dermocleen', 'Frasco 230 mL', 'Peróxido de hidrógeno', '2.5 a 3.5%', false, 'Factura Levic 9012078353 · ya existía FC-83351691 · ≠ 100 mL', false),
  (5, '7502009745478', 'EQ-MAV236', 'Ideliver Pro duloxetina 60 mg C/14', 'Medicamentos', 'marca', 4, 63.74, 102.00, 2, '283429', 'Maver', 'Caja con 14 tabletas', 'Duloxetina', '60 mg', false, 'Factura Levic 9012078353 · ya existía EQ-MAV236 · costo subió; PVP 96→102', false),
  (6, '7501109769063', 'EQ-QUI139', 'Agecaps minoxidil hombre 5% solución 60 mL', 'Cuidado personal', 'marca', 1, 150.00, 240.00, 1, '26C063', 'Agecaps', 'Frasco 60 mL', 'Minoxidil', '5%', false, 'Factura Levic 9012078353 · Química y Farmacia · PMP $600', true),
  (7, '7502216800984', 'FC-C9F4ACCC', 'Acemetacina 14 cáps 90 mg', 'Analgésico', 'generico', 2, 52.31, 84.00, 2, '68N323A', 'Ultra', 'Caja con 14 cápsulas', 'Acemetacina', '90 mg', false, 'Factura Levic 9012078353 · ya existía FC-C9F4ACCC · pegar EAN si faltaba', false);

do $$
declare
  r record;
  v_pid bigint;
  v_lid bigint;
  n_alta integer := 0;
  n_recv integer := 0;
  n_skip integer := 0;
begin
  for r in select * from _fc_lv9012078353 order by linea loop
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
        stock_minimo = greatest(coalesce(stock_minimo, 0), r.stock_minimo),
        codigo_barras = coalesce(nullif(codigo_barras, ''), r.ean)
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

  raise notice 'Levic 9012078353: % altas de catálogo (stock = Recibir)', n_alta;
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
from _fc_lv9012078353 t
left join public.productos p on p.codigo_barras = t.ean or p.sku = t.sku
left join lateral (
  select l.* from public.lotes l
  where l.producto_id = p.id and l.numero_lote = t.lote and coalesce(l.activo, true)
  order by l.id desc
  limit 1
) l on true
order by t.linea;

commit;
