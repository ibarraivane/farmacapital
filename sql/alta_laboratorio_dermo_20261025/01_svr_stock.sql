-- ============================================================================
-- FARMACAPITAL — SVR stock a precio de laboratorio (oct-2026)
-- Costo = factura de compra. Precio = Lista FarmaCapital (IVA incluido).
-- Pasa a anaquel (bajo_pedido = false) con lote S/L si aún no hay piezas.
-- Regenerar: python3 scripts/generar_alta_laboratorio_dermo.py
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temporary table _fc_svr_lab (
  ean text primary key,
  sku text not null,
  nombre text not null,
  presentacion text,
  forma text,
  cantidad integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  imagen_url text
) on commit drop;

insert into _fc_svr_lab (ean, sku, nombre, presentacion, forma, cantidad, costo, precio, imagen_url) values
  ('3662361002450', 'FC-61002450', 'SVR Sebiaclear Ampoule Flash 30 ml', '30 ml', 'Ampolla', 10, 763.25, 1119.00, ''),
  ('3662361000364', 'FC-61000364', 'SVR Sebiaclear Sérum 30 ml', '30 ml', 'Sérum', 10, 692.25, 1019.00, 'https://www.farmacapital.mx/catalogo-propia/svr-sebiaclear-serum-30ml.jpg'),
  ('3662361002597', 'FC-61002597', 'SVR Sun Secure Blur SPF50+ 50 ml (sin color)', '50 ml', 'Crema mousse', 20, 532.50, 779.00, ''),
  ('3662361003167', 'FC-61003167', 'SVR Sun Secure Blur Teinté Hâlé SPF50+ 50 ml (con color)', '50 ml', 'Crema mousse', 10, 532.50, 779.00, ''),
  ('3662361004300', 'FC-61004300', 'SVR Hyalu Biotic Rechargeable 50 ml', '50 ml', 'Gel', 10, 1125.35, 1649.00, ''),
  ('3662361003792', 'FC-61003792', 'SVR Physiopure Gelée Moussante 200 ml', '200 ml', 'Gelée', 10, 386.95, 569.00, ''),
  ('3662361001897', 'FC-61001897', 'SVR Topialyse Gel Lavant 400 ml', '400 ml', 'Gel', 10, 475.70, 559.00, ''),
  ('3662361003402', 'FC-61003402', 'SVR Sebiaclear Gel Moussant 400 ml', '400 ml', 'Gel', 10, 589.30, 859.00, 'https://www.farmacapital.mx/catalogo-propia/svr-sebiaclear-gel-moussant-400ml.jpg'),
  ('3662361000937', 'FC-61000937', 'SVR Ampoule B3 Hydra 30 ml', '30 ml', 'Ampolla', 10, 1004.65, 1479.00, ''),
  ('3662361000401', 'FC-61000401', 'SVR Ampoule C Anti-Ox 30 ml', '30 ml', 'Ampolla', 10, 1022.40, 1499.00, '');

do $$
declare
  r record;
  v_pid bigint;
  v_lid bigint;
  v_sku text;
begin
  for r in select * from _fc_svr_lab loop
    v_sku := r.sku;
    select p.id into v_pid
      from public.productos p
     where p.codigo_barras = r.ean
     order by p.id
     limit 1;

    if v_pid is null then
      if exists (
        select 1 from public.productos p
         where p.sku = v_sku
           and coalesce(p.codigo_barras, '') <> r.ean
      ) then
        v_sku := 'FC-ND-' || right(r.ean, 8);
      end if;

      select f.producto_id, f.lote_id into v_pid, v_lid
        from public.create_producto_with_lote(
          jsonb_build_object(
            'nombre', r.nombre,
            'sku', v_sku,
            'codigo_barras', r.ean,
            'categoria', 'Cuidado personal',
            'tipo', 'marca',
            'descripcion', 'SVR · compra directa laboratorio · FarmaCapital oct-2026',
            'costo', r.costo,
            'precio', r.precio,
            'stock_minimo', 2,
            'activo', true,
            'requiere_receta', false
          ),
          r.cantidad,
          'S/L',
          null::date,
          r.costo,
          null::bigint
        ) f;
    else
      declare
        v_stock integer;
        v_faltan integer;
      begin
        select coalesce(sum(l.cantidad_actual), 0) into v_stock
          from public.lotes l
         where l.producto_id = v_pid
           and coalesce(l.activo, true);
        v_faltan := r.cantidad - v_stock;
        if v_faltan > 0 then
          select f.lote_id into v_lid
            from public.receive_merchandise_lote(
              v_pid, v_faltan, 'S/L', null::date, r.costo, 'SVR laboratorio', null::bigint
            ) f;
        end if;
      end;
    end if;

    update public.productos set
      nombre = r.nombre,
      marca = 'SVR',
      laboratorio = 'SVR',
      presentacion = r.presentacion,
      forma_farmaceutica = r.forma,
      subcategoria = 'Dermatología',
      categoria = 'Cuidado personal',
      tipo = 'marca',
      requiere_receta = false,
      codigo_barras = r.ean,
      costo = r.costo,
      precio = r.precio,
      stock_minimo = greatest(coalesce(stock_minimo, 0), 2),
      activo = true,
      bajo_pedido = false,
      imagen_url = coalesce(nullif(btrim(r.imagen_url), ''), nullif(btrim(imagen_url), ''))
     where id = v_pid;

    -- Referencia de compra laboratorio (hoy)
    delete from public.producto_precios_referencia
     where producto_id = v_pid
       and fuente = 'svr'
       and origen = 'import_csv'
       and fecha = current_date;

    insert into public.producto_precios_referencia
      (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
    values (
      v_pid, 'svr', 'compra', r.costo, r.ean, 'import_csv',
      'SVR laboratorio · stock FarmaCapital · PVP ' || r.precio::text
    );
  end loop;
end $$;

commit;

select
  p.sku, p.codigo_barras as ean, p.nombre, p.costo, p.precio,
  round((p.precio - p.costo) / nullif(p.precio, 0) * 100, 1) as margen_pct,
  p.stock, p.bajo_pedido, p.activo
from public.productos p
where p.codigo_barras in (
  '3662361002450','3662361000364','3662361002597','3662361003167','3662361004300',
  '3662361003792','3662361001897','3662361003402','3662361000937','3662361000401'
)
order by p.nombre;
