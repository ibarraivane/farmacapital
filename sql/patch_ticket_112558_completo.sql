-- ============================================================================
-- CORRECCIÓN COMPLETA ticket 112558 · El Surtidor de su Farmacia · 08-08-2026
-- 34 productos · cantidades + costo unitario NETO (Total÷pzas, c/descuento) + marcas
--
-- Columnas ticket: Precio (lista) → Importe → Descuento → Total (s/IVA)
-- costo unitario = Total ÷ cantidad
-- Regenerar: python3 scripts/generar_patch_ticket_112558.py
-- Ejecutar UNA vez en Supabase SQL Editor.
-- NO ejecutar patch_cantidades_tickets_completo.sql sobre estos SKUs (contradice el ticket).
-- ============================================================================

begin;

-- Alta si falta: Diapro Confort Gde C/10
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-43475014' or codigo_barras = '7501943475014') then
    perform * from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Diapro Confort Gde C/10',
        'sku', 'FC-43475014',
        'codigo_barras', '7501943475014',
        'categoria', 'Cuidado personal',
        'tipo', 'marca',
        'descripcion', 'Diapro Confort Gde C/10 — ticket 112558',
        'costo', 99.0,
        'precio', 149,
        'stock_minimo', 2,
        'activo', true,
        'requiere_receta', false
      ),
      2,
      'TK-112558-8G',
      null,
      99.0,
      null
    );
    update public.productos set
      marca = 'Diapro',
      presentacion = 'C/10',
      forma_farmaceutica = null,
      proveedor = 'El Surtidor de su Farmacia'
    where sku = 'FC-43475014' or codigo_barras = '7501943475014';
  end if;
end $$;

-- Alta si falta: Glucerna líquido 237 ml vainilla
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-33956126' or codigo_barras = '7501033956126') then
    perform * from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Glucerna líquido 237 ml vainilla',
        'sku', 'FC-33956126',
        'codigo_barras', '7501033956126',
        'categoria', 'Suplemento',
        'tipo', 'marca',
        'descripcion', 'Glucerna líquido 237 ml vainilla — ticket 112558',
        'costo', 47.5,
        'precio', 72,
        'stock_minimo', 2,
        'activo', true,
        'requiere_receta', false
      ),
      2,
      'TK-112558-19V',
      null,
      47.5,
      null
    );
    update public.productos set
      marca = 'Glucerna',
      presentacion = '237 ML',
      forma_farmaceutica = 'Líquido',
      proveedor = 'El Surtidor de su Farmacia'
    where sku = 'FC-33956126' or codigo_barras = '7501033956126';
  end if;
end $$;


create temp table _fc_tk112558 (
  sku text primary key,
  codigo_barras text,
  qty integer not null,
  precio_lista numeric(10,2),
  pct_desc numeric(5,2),
  importe numeric(10,2),
  descuento numeric(10,2),
  total_linea numeric(10,2),
  costo_unitario numeric(10,2) not null,
  precio_venta numeric(10,2) not null,
  nombre text not null,
  marca text not null,
  presentacion text,
  categoria text,
  forma_farmaceutica text
) on commit drop;

insert into _fc_tk112558 values
  ('FC-68900264','7501868900264',48,9.0,10.05,432.0,43.43,388.57,8.1,14,'Alcohol Dibar 125 ml rojo','Dibar','125 ML','Botiquín','Alcohol'),
  ('FC-68960257','7501868960257',12,56.0,4.99,672.0,33.55,638.45,53.2,80,'Alcohol Dibar 1 L rojo','Dibar','1 L','Botiquín','Alcohol'),
  ('FC-68900226','7501868900226',36,16.5,4.99,594.0,29.65,564.35,15.68,24,'Alcohol Dibar 250 ml rojo','Dibar','250 ML','Botiquín','Alcohol'),
  ('FC-68990023','7501868990023',24,30.0,5.99,720.0,43.15,676.85,28.2,43,'Alcohol Dibar 500 ml rojo','Dibar','500 ML','Botiquín','Alcohol'),
  ('FC-77620056','7501677620056',3,19.0,0,57.0,0.0,57.0,19.0,29,'Agua destilada La Flor 1 L','La Flor','1 L','Botiquín','Agua destilada'),
  ('FC-00003920','3311000003920',10,15.0,0,150.0,0.0,150.0,15.0,23,'Arnica Mercurio','Mercurio',null,'Producto',null),
  ('FC-76000260','7506376000260',1,80.0,0,80.0,0.0,80.0,80.0,120,'Crema Vitacilina amarilla aclaradora','Vitacilina',null,'Cuidado personal','Crema'),
  ('FC-76000253','7506376000253',1,80.0,0,80.0,0.0,80.0,80.0,120,'Crema Vitacilina roja antiarrugas 100 g','Vitacilina','100 G','Cuidado personal','Crema'),
  ('FC-43475014','7501943475014',2,99.0,0,198.0,0.0,198.0,99.0,149,'Diapro Confort Gde C/10','Diapro','C/10','Cuidado personal',null),
  ('FC-16800803','7501116800803',2,85.0,0,170.0,0.0,170.0,85.0,128,'Diapro Confort Med C/10','Diapro','C/10','Cuidado personal',null),
  ('FC-86901100','7501186901100',5,7.4,0,37.0,0.0,37.0,7.4,13,'Alcohol Dibar 125 ml azul','Dibar','125 ML','Botiquín','Alcohol'),
  ('FC-68901131','7501868901131',5,41.0,0,205.0,0.0,205.0,41.0,62,'Alcohol Dibar azul 1 L','Dibar','1 L','Botiquín','Alcohol'),
  ('FC-68901117','7501868901117',5,11.3,0,56.5,0.0,56.5,11.3,17,'Alcohol Dibar 250 ml azul','Dibar','250 ML','Botiquín','Alcohol'),
  ('FC-68901124','7501868901124',1,120.0,0,120.0,0.0,120.0,120.0,180,'Alcohol Dibar azul 500 ml','Dibar','500 ML','Botiquín','Alcohol'),
  ('FC-98223704','7501298223704',2,280.5,52.0,561.0,291.72,269.28,134.64,202,'Bolo Eurobion tab C/20','Eurobion','C/20','Medicamento','Tabletas'),
  ('FC-33950100','7501033950100',2,42.0,0,84.0,0.0,84.0,42.0,63,'Ensure líquido 236 ml chocolate','Ensure','236 ML','Suplemento','Líquido'),
  ('FC-33950063','7501033950063',2,42.0,0,84.0,0.0,84.0,42.0,63,'Pediasure líquido 236 ml fresa','Pediasure','236 ML','Suplemento','Líquido'),
  ('FC-33950070','7501033950070',2,42.0,0,84.0,0.0,84.0,42.0,63,'Ensure líquido 236 ml vainilla','Ensure','236 ML','Suplemento','Líquido'),
  ('FC-33956133','7501033956133',2,51.04,6.94,102.08,7.08,95.0,47.5,72,'Glucerna líquido 237 ml chocolate','Glucerna','237 ML','Suplemento','Líquido'),
  ('FC-33956126','7501033956126',2,47.5,0,95.0,0.0,95.0,47.5,72,'Glucerna líquido 237 ml vainilla','Glucerna','237 ML','Suplemento','Líquido'),
  ('FC-33956140','7501033956140',2,47.5,0,95.0,0.0,95.0,47.5,72,'Glucerna SR líquido 237 ml fresa','Glucerna','237 ML','Suplemento','Líquido'),
  ('FC-07521317','7501507521317',100,1.2,0,119.99,0.0,119.99,1.2,7,'Gotero cristal','Genérico',null,'Botiquín','Gotero'),
  ('FC-01157296','7501001157296',5,17.0,0,85.0,0.0,85.0,17.0,26,'Naturella flujo moderado C/8 con alas','Naturella','C/8','Higiene','Toallas sanitarias'),
  ('FC-01405335','7501001405335',5,18.5,0,92.5,0.0,92.5,18.5,28,'Naturella noche con alas C/8','Naturella','C/8','Higiene','Toallas sanitarias'),
  ('FC-33951008','7501033951008',2,44.0,0,88.0,0.0,88.0,44.0,66,'Pediasure líquido 236 ml chocolate','Pediasure','236 ML','Suplemento','Líquido'),
  ('FC-33954245','7501033954245',2,44.0,0,88.0,0.0,88.0,44.0,66,'Pediasure líquido 236 ml fresa','Pediasure','236 ML','Suplemento','Líquido'),
  ('FC-33950209','7501033950209',2,44.0,0,88.0,0.0,88.0,44.0,66,'Pediasure líquido 236 ml vainilla','Pediasure','236 ML','Suplemento','Líquido'),
  ('FC-19006623','7501019006623',10,9.8,0,99.0,0.0,99.0,9.9,15,'Saba buenas noches','Saba',null,'Higiene','Toallas sanitarias'),
  ('FC-65054135','7501065054043',1,52.06,28.01,52.06,14.58,37.48,37.48,57,'Tums Extra surtido 750 mg C/24 (3 rollos x 8)','Tums','C/24','Gastro','Tableta masticable'),
  ('FC-56323066','7501056323066',1,27.0,0,27.0,0.0,27.0,27.0,41,'Vaseline FaseLine puro 42 g','Vaseline','42 G','Producto',null),
  ('FC-56323059','7501056323059',1,45.5,0,45.5,0.0,45.5,45.5,69,'Vaseline puro 85 g','Vaseline','85 G','Producto',null),
  ('FC-01246730','7501001246730',1,255.0,0,255.0,0.0,255.0,255.0,383,'Vicks Vaporub pomada 12 g C/12 latas','Vicks','12 G','Botiquín',null),
  ('FC-02012475','7590002012475',1,238.32,47.5,238.32,113.2,125.12,125.12,188,'Vicks Vaporub ungüento 100 g','Vicks','100 G','Botiquín','Ungüento'),
  ('FC-02012468','7590002012468',1,201.0,59.0,201.0,118.59,82.41,82.41,124,'Vicks Vaporub ungüento 50 g','Vicks','50 G','Botiquín','Balsamo');

update public.productos p set
  sku = t.sku,
  nombre = t.nombre,
  codigo_barras = t.codigo_barras,
  marca = t.marca,
  presentacion = t.presentacion,
  categoria = t.categoria,
  forma_farmaceutica = t.forma_farmaceutica,
  tipo = 'marca',
  costo = t.costo_unitario,
  precio = t.precio_venta,
  descripcion = t.nombre || ' — ticket 112558'
from _fc_tk112558 t
where p.sku = t.sku or p.codigo_barras = t.codigo_barras;

-- Productos sin lote activo: recibir mercancía
do $$
declare r record; v_lid bigint;
begin
  for r in
    select t.*, p.id as producto_id
    from _fc_tk112558 t
    join public.productos p on (p.sku = t.sku or p.codigo_barras = t.codigo_barras)
    where not exists (
      select 1 from public.lotes l
      where l.producto_id = p.id and coalesce(l.activo, true)
    )
  loop
    select lote_id into v_lid from public.receive_merchandise_lote(
      r.producto_id, r.qty, 'TK-112558-' || r.sku, null, r.costo_unitario, 'El Surtidor de su Farmacia', null
    );
  end loop;
end $$;

create temp table _fc_tk112558_lote as
select distinct on (p.id)
  p.id as producto_id, t.qty, t.costo_unitario, l.id as lote_id
from _fc_tk112558 t
join public.productos p on (p.sku = t.sku or p.codigo_barras = t.codigo_barras)
join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true)
order by p.id,
  case when l.numero_lote ilike 'TK-112558-%' then 0 when l.numero_lote ilike 'TK-%' then 1 else 2 end,
  l.created_at desc nulls last, l.id desc;

update public.lotes l set cantidad_actual = 0
from _fc_tk112558_lote pl
where l.producto_id = pl.producto_id and l.id <> pl.lote_id
  and coalesce(l.activo, true) and coalesce(l.cantidad_actual, 0) <> 0;

update public.lotes l set cantidad_actual = pl.qty, costo_unitario = pl.costo_unitario
from _fc_tk112558_lote pl where l.id = pl.lote_id;

update public.lotes l set costo_unitario = pl.costo_unitario
from _fc_tk112558_lote pl
where l.producto_id = pl.producto_id and coalesce(l.activo, true)
  and coalesce(l.costo_unitario, 0) is distinct from pl.costo_unitario;

update public.productos p set stock = coalesce((
  select sum(l.cantidad_actual) from public.lotes l
  where l.producto_id = p.id and coalesce(l.activo, true)
), 0)
from _fc_tk112558 t
where p.sku = t.sku or p.codigo_barras = t.codigo_barras;

select t.sku as sku_ticket, p.sku as sku_bd, t.codigo_barras, left(t.nombre, 32) as producto,
  t.qty as pzas_ticket, p.stock as stock_bd, t.costo_unitario as costo_neto, p.costo,
  case
    when p.id is null then 'SIN PRODUCTO'
    when p.sku is null or btrim(p.sku) = '' then 'REVISAR SKU'
    when abs(p.costo - t.costo_unitario) > 0.01 then 'REVISAR COSTO'
    when p.stock <> t.qty then 'REVISAR STOCK'
    else 'OK'
  end as estado
from _fc_tk112558 t
left join public.productos p on (p.sku = t.sku or p.codigo_barras = t.codigo_barras)
order by t.sku;

commit;
