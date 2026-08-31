-- 14 renglones Exprezo 1279718 que Recibir marcó sin catálogo.
-- 11 con EAN. 3 packs sin barra (no se inventa código): se tocan a mano.
-- Stock 0. Sin lote ni caducidad. Idempotente. Supabase → SQL Editor → Run.
-- No vuelvas a pegar patch_recepcion_exprezo_*: borra lo ya escaneado.

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_sku text;
  v_creados int := 0;
  v_existian int := 0;
  v_enlazados int := 0;
  n int;
begin
  for r in
    select * from (values
        ('7506306246652', 'FC-06246652', 'Jabón Dove blanco 90 g', 18.63::numeric, 25, 'marca', 'Cuidado personal', false),
        ('650240013805', 'FC-40013805', 'Alliviax desinflamatorio 550 mg 10 tabletas', 100.50, 134, 'marca', 'Medicamentos', false),
        ('7506205809248', 'FC-05809248', 'Enfagrow Premium etapa 3 lata 800 g', 306.00, 408, 'marca', 'Bebés', false),
        ('7501058651129', 'FC-58651129', 'Gerber Junior pouch frutas mixtas 95 g', 12.79, 18, 'marca', 'Bebés', false),
        ('0608875005092', 'FC-75005092', 'Heinz pouch papilla manzana 113 g', 14.40, 20, 'marca', 'Bebés', false),
        ('7506475102520', 'FC-75102520', 'Gerber Etapa 2 comida casera res 100 g', 10.68, 15, 'marca', 'Bebés', false),
        ('7506475102537', 'FC-75102537', 'Gerber Etapa 2 comida casera pollo 100 g', 10.68, 15, 'marca', 'Bebés', false),
        ('7506475102476', 'FC-75102476', 'Gerber Etapa 2 durazno 100 g', 10.68, 15, 'marca', 'Bebés', false),
        ('7506475102452', 'FC-75102452', 'Gerber Etapa 2 pera 100 g', 10.68, 15, 'marca', 'Bebés', false),
        ('7506475102469', 'FC-75102469', 'Gerber Etapa 2 mango 100 g', 10.68, 15, 'marca', 'Bebés', false),
        ('7506475102421', 'FC-75102421', 'Gerber Etapa 2 manzana 100 g', 10.68, 15, 'marca', 'Bebés', false)
    ) as t(ean, sku, nombre, costo, precio, tipo, categoria, receta)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    if v_pid is not null then
      v_existian := v_existian + 1;
    else
      v_sku := r.sku;
      if exists (
        select 1 from public.productos p
        where p.sku = v_sku
          and coalesce(p.codigo_barras, '') <> r.ean
      ) then
        v_sku := 'FC-EX-' || right(r.ean, 8);
      end if;
      insert into public.productos (
        nombre, sku, codigo_barras, categoria, tipo, descripcion,
        costo, precio, stock, stock_minimo, activo, requiere_receta, proveedor
      ) values (
        r.nombre, v_sku, r.ean, r.categoria, r.tipo,
        'Alta Exprezo 1279718 · 2026-08-31 · listo para pistola',
        r.costo, r.precio, 0, 1, true, r.receta, 'Exprezo'
      )
      returning id into v_pid;
      v_creados := v_creados + 1;
    end if;
  end loop;

  for r in
    select * from (values
        ('FC-EXP-PALM8', 'Jabón Palmolive Neutro Balance 100 g 8 pack', 'Jabón Palmolive Naturals Neutro Balance 100 g 8 Pack', 114.40::numeric, 153),
        ('FC-EXP-HS24', 'Tira Head & Shoulders 24 sobres 10 ml', 'Tira Shampoo Head & Shoulders 24 sachets 10 ml', 51.21, 69),
        ('FC-EXP-OPT48', 'Pack 48 sobres Palmolive Optims 10 ml', 'Pack 48 sobres Shampoo Palmolive Optims 10 ml', 75.30, 101)
    ) as t(sku, nombre, snap, costo, precio)
  loop
    select id into v_pid from public.productos where sku = r.sku limit 1;
    if v_pid is not null then
      v_existian := v_existian + 1;
    else
      insert into public.productos (
        nombre, sku, codigo_barras, categoria, tipo, descripcion,
        costo, precio, stock, stock_minimo, activo, requiere_receta, proveedor
      ) values (
        r.nombre, r.sku, null, 'Cuidado personal', 'marca',
        'Alta Exprezo 1279718 · pack sin EAN de caja · tocar renglón',
        r.costo, r.precio, 0, 1, true, false, 'Exprezo'
      )
      returning id into v_pid;
      v_creados := v_creados + 1;
    end if;

    update public.recepcion_items i
    set producto_id = v_pid, pendiente_alta = false
    from public.recepciones rec
    where i.recepcion_id = rec.id
      and rec.folio = '1279718'
      and coalesce(rec.proveedor, '') ilike '%exprezo%'
      and i.pendiente_alta
      and i.producto_id is null
      and coalesce(nullif(btrim(i.codigo_escaneado), ''), '') = ''
      and i.nombre_snapshot = r.snap;
    get diagnostics n = row_count;
    v_enlazados := v_enlazados + n;
  end loop;

  update public.recepcion_items i
  set
    producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
    pendiente_alta = false
  where i.pendiente_alta
    and i.producto_id is null
    and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null;
  get diagnostics n = row_count;
  v_enlazados := v_enlazados + n;

  raise notice 'Exprezo 14: creados=% ya_estaban=% renglones_enlazados=%',
    v_creados, v_existian, v_enlazados;
end
$$;

commit;

select sku, codigo_barras as ean, left(nombre, 52) as nombre, costo, precio, stock
from public.productos
where codigo_barras in (
  '7506306246652',
  '650240013805',
  '7506205809248',
  '7501058651129',
  '0608875005092',
  '7506475102520',
  '7506475102537',
  '7506475102476',
  '7506475102452',
  '7506475102469',
  '7506475102421'
)
   or sku in (
  'FC-EXP-PALM8',
  'FC-EXP-HS24',
  'FC-EXP-OPT48'
)
order by nombre;
