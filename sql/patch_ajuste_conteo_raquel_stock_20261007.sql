-- Conteo físico Raquel/Cyntia (WhatsApp) · 2026-10-07 lote 2
-- Stock vía lotes + barcodes de pistola + Debisor/Ceftriaxona sin lotes.
-- Idempotente. No inventa caducidad.
-- Ver LEERME_ajuste_conteo_raquel_20261007.md

begin;

-- Oxital-C: ficha de mostrador (efervescente 2 g)
update public.productos
   set concentracion = coalesce(nullif(btrim(concentracion), ''), '2 g'),
       presentacion = 'Tubo con 10 tabletas efervescentes',
       forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tabletas efervescentes'),
       marca = coalesce(nullif(btrim(marca), ''), 'Serral'),
       principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Ácido ascórbico'),
       codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7501258207010')
 where sku = 'FC-58207010';

-- Fenazopiridina: EAN de la caja (pistola)
update public.productos p
   set codigo_barras = null
 where p.codigo_barras = '7501563380637'
   and p.sku is distinct from 'EQ-RAD100';

update public.productos
   set codigo_barras = '7501563380637',
       marca = coalesce(nullif(btrim(marca), ''), 'Randall'),
       activo = true
 where sku = 'EQ-RAD100';

-- Hidropharm: EAN de la caja física (pistola fallaba)
update public.productos p
   set codigo_barras = null
 where p.codigo_barras = '7503003134664'
   and p.sku is distinct from 'EQ-ALP0120';

update public.productos
   set codigo_barras = '7503003134664',
       marca = coalesce(nullif(btrim(marca), ''), 'Hidropharm'),
       activo = true
 where sku = 'EQ-ALP0120';

-- Debisor 5 mg: EAN leído en caja (pistola). Ticket Equilibrio también 7501075711035.
update public.productos p
   set codigo_barras = null
 where p.codigo_barras in ('7501075727555', '7501075711035')
   and p.sku is distinct from 'EQ-NOV006';

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  select id into v_pid from public.productos
   where sku = 'EQ-NOV006' or codigo_barras in ('7501075727555', '7501075711035')
   limit 1;

  if v_pid is null then
    select f.producto_id into v_pid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Debisor sublingual 5 mg',
          'sku', 'EQ-NOV006',
          'codigo_barras', '7501075727555',
          'categoria', 'Medicamentos',
          'tipo', 'marca',
          'descripcion', 'Conteo Raquel 2026-10-07 · Novag · C/20 sublinguales · no se encontraba al escanear',
          'costo', 56.32,
          'precio', 71,
          'stock_minimo', 2,
          'activo', true,
          'requiere_receta', false
        ),
        2,
        'INV-CONTEO-20261007-R',
        null::date,
        56.32,
        null::bigint
      ) f;
  end if;

  update public.productos set
    sku = 'EQ-NOV006',
    codigo_barras = '7501075727555',
    nombre = coalesce(nullif(btrim(nombre), ''), 'Debisor sublingual 5 mg'),
    marca = 'Debisor',
    presentacion = 'Caja con 20 tabletas sublinguales',
    concentracion = '5 mg',
    principio_activo = 'Dinitrato de isosorbida',
    forma_farmaceutica = 'Tableta sublingual',
    subcategoria = 'Cardiovascular',
    tipo = coalesce(nullif(btrim(tipo), ''), 'marca'),
    activo = true
  where id = v_pid;

  -- Debisor 10 mg (mismo nombre, otro gramaje): asegurar ficha; sin conteo → stock 0
  if not exists (
    select 1 from public.productos
     where sku = 'EQ-NOV007' or codigo_barras = '7501075711011'
  ) then
    perform f.producto_id
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Debisor 10 mg',
          'sku', 'EQ-NOV007',
          'codigo_barras', '7501075711011',
          'categoria', 'Medicamentos',
          'tipo', 'marca',
          'descripcion', 'Conteo Raquel 2026-10-07 · Novag C/20 · gramaje distinto al 5 mg sublingual',
          'costo', 8.87,
          'precio', 12,
          'stock_minimo', 2,
          'activo', true,
          'requiere_receta', false
        ),
        0,
        null,
        null::date,
        8.87,
        null::bigint
      ) f;
    update public.productos set
      marca = 'Debisor',
      presentacion = 'Caja con 20 tabletas',
      concentracion = '10 mg',
      principio_activo = 'Dinitrato de isosorbida',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Cardiovascular'
    where sku = 'EQ-NOV007';
  end if;
end $$;

do $$
declare
  r record;
  v_pid bigint;
  v_lote bigint;
  v_sum integer;
  v_costo numeric;
  v_motivo text := 'Conteo físico Raquel/Cyntia WhatsApp 2026-10-07';
begin
  for r in
    select * from (values
      ('FC-58207010', 1),   -- Oxital-C
      ('FC-E6B50AC3', 2),   -- Celecoxib (Raquel confirma 2)
      ('FC-84335531', 2),   -- Cafiaspirina Forte (cerrada + abierta)
      ('EQ-MAV318',   2),   -- Cariden 6 mg
      ('FC-C636D8EA', 1),   -- Ceftriaxona IM (estaba sin lotes)
      ('EQ-NOV006',   2),   -- Debisor 5 mg sublingual
      ('FC-76040610', 3),   -- Desenfriol-ito PLUS
      ('FC-60403681', 2),   -- Desenfriol D
      ('FC-E535DE28', 8),   -- Diurmessel Furosemida
      ('EQ-RAD100',   6),   -- Fenazopiridina
      ('EQ-AMS075',   2),   -- Butilhioscina AMSA C/3
      ('EQ-AMS209',   4),   -- Hipromelosa (Luis −1 online)
      ('FC-89810021', 1),   -- Herklin 60 ml
      ('EQ-ACC092',   2)    -- HT-Bloc Ondansetrón
    ) as t(sku, nuevo_stock)
  loop
    select id, costo into v_pid, v_costo
      from public.productos
     where sku = r.sku
     limit 1;

    if v_pid is null then
      raise notice 'SKIP %: no está en productos', r.sku;
      continue;
    end if;

    select coalesce(sum(l.cantidad_actual), 0) into v_sum
      from public.lotes l
     where l.producto_id = v_pid
       and coalesce(l.activo, true);

    if v_sum = r.nuevo_stock then
      raise notice 'OK % ya en %', r.sku, r.nuevo_stock;
      continue;
    end if;

    select l.id into v_lote
      from public.lotes l
     where l.producto_id = v_pid
     order by coalesce(l.activo, true) desc,
              coalesce(l.cantidad_actual, 0) desc,
              l.id desc
     limit 1;

    if v_lote is null then
      insert into public.lotes (
        producto_id, numero_lote, cantidad_inicial, cantidad_actual,
        fecha_caducidad, costo_unitario, activo
      ) values (
        v_pid, 'INV-CONTEO-20261007-R', r.nuevo_stock, r.nuevo_stock,
        null, v_costo, true
      );
    else
      update public.lotes
         set cantidad_actual = 0, activo = false
       where producto_id = v_pid
         and id <> v_lote
         and coalesce(activo, true)
         and coalesce(cantidad_actual, 0) > 0;

      update public.lotes
         set cantidad_actual = r.nuevo_stock,
             activo = true,
             cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), r.nuevo_stock)
       where id = v_lote;
    end if;

    insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
    values (
      v_pid, 'ajuste', r.nuevo_stock,
      v_motivo || ' · ' || r.sku || ' → ' || r.nuevo_stock
    );

    raise notice 'AJUSTE %: % → %', r.sku, v_sum, r.nuevo_stock;
  end loop;
end $$;

commit;

select p.sku, p.nombre, p.stock, p.codigo_barras, p.presentacion
  from public.productos p
 where p.sku in (
   'FC-58207010','FC-E6B50AC3','FC-84335531','EQ-MAV318','FC-C636D8EA',
   'EQ-NOV006','EQ-NOV007','FC-76040610','FC-60403681','FC-E535DE28',
   'EQ-RAD100','EQ-ALP0120','EQ-AMS075','EQ-AMS209','FC-89810021','EQ-ACC092'
 )
 order by p.sku;
