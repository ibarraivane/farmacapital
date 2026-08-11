-- ============================================================================
-- CARGAR faltantes — FarmaLive + barcode (EJECUTAR 3 y 4)
-- 149 bloques · Aspirina, Bepanthen, Desenfriol, etc.
-- Lote 1/6 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;


do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501065054135' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501065054135';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'TB 3 SURT',
      'sku', 'FC-65054135',
      'codigo_barras', '7501065054135',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'TB 3 SURT — Ticket 112558',
      'costo', 37.48,
      'precio', 50.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-27',
      NULL::date,
      37.48,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501065054135', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501056323066' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501056323066';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'FASELINE PURO 42G',
      'sku', 'FC-56323066',
      'codigo_barras', '7501056323066',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'FASELINE PURO 42G — Ticket 112558',
      'costo', 15.5,
      'precio', 20.93,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-28',
      NULL::date,
      15.5,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501056323066', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501056323059' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501056323059';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'VASELINE PURO 85G',
      'sku', 'FC-56323059',
      'codigo_barras', '7501056323059',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'VASELINE PURO 85G — Ticket 112558',
      'costo', 45.5,
      'precio', 61.43,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-29',
      NULL::date,
      45.5,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501056323059', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501001246730' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501001246730';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'VAPORUB POM 12G C12 LATAS',
      'sku', 'FC-01246730',
      'codigo_barras', '7501001246730',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'VAPORUB POM 12G C12 LATAS — Ticket 112558',
      'costo', 255.0,
      'precio', 344.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-30',
      NULL::date,
      255.0,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501001246730', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7590002012475' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7590002012475';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'VICK NAPORUB UNG 100G',
      'sku', 'FC-02012475',
      'codigo_barras', '7590002012475',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'VICK NAPORUB UNG 100G — Ticket 112558',
      'costo', 113.2,
      'precio', 152.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-31',
      NULL::date,
      113.2,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7590002012475', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7590002012468' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7590002012468';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'VICK VAPORUB UNG 50G',
      'sku', 'FC-02012468',
      'codigo_barras', '7590002012468',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'VICK VAPORUB UNG 50G — Ticket 112558',
      'costo', 82.41,
      'precio', 111.26,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-32',
      NULL::date,
      82.41,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7590002012468', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502276040610' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502276040610';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Desenfriolito Tab C/24 2 Pack Bayer Otc $ 93.80 Desenfriolito Tab C/24 2 Pack',
      'sku', 'FC-76040610',
      'codigo_barras', '7502276040610',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Desenfriolito Tab C/24 2 Pack Bayer Otc $ 93.80 Desenfriolito Tab C/24 2 Pack — Ticket FL-080826',
      'costo', 46.9,
      'precio', 63.32,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-1',
      NULL::date,
      46.9,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502276040610', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506460101231' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506460101231';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Noche Tab C/12 Descto: 6.0K Tempra , Xt Noche Tab C/12 Tempra',
      'sku', 'FC-60101231',
      'codigo_barras', '7506460101231',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Noche Tab C/12 Descto: 6.0K Tempra , Xt Noche Tab C/12 Tempra — Ticket FL-080826',
      'costo', 59.69,
      'precio', 80.59,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-2',
      NULL::date,
      59.69,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506460101231', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010587154871' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010587154871';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Graneodin E Naranja Tab C/16 Rb Health 135.10 Graneodin E Naranja Tab C/16',
      'sku', 'FC-87154871',
      'codigo_barras', '75010587154871',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Graneodin E Naranja Tab C/16 Rb Health 135.10 Graneodin E Naranja Tab C/16 — Ticket FL-080826',
      'costo', 132.4,
      'precio', 178.74,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      7,
      'TK-FL-080826-3',
      NULL::date,
      132.4,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010587154871', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506460101521' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506460101521';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Lubricante Soft Lub Pleasüre 56.7 Gr Health 1 $ 100.80 Soft Lub Pleasüre Er 222503430721 Vitacilina 28 | Ksk',
      'sku', 'FC-60101521',
      'codigo_barras', '7506460101521',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lubricante Soft Lub Pleasüre 56.7 Gr Health 1 $ 100.80 Soft Lub Pleasüre Er 222503430721 Vitacilina 28 | Ksk — Ticket FL-080826',
      'costo', 100.8,
      'precio', 136.09,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-4',
      NULL::date,
      100.8,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506460101521', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010506134531' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010506134531';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Dtc (Rojo) 20 Descto: 2.0% Afrin Spray (Rojo) Afrin Spray Ml | Bayer',
      'sku', 'FC-06134531',
      'codigo_barras', '75010506134531',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Dtc (Rojo) 20 Descto: 2.0% Afrin Spray (Rojo) Afrin Spray Ml | Bayer — Ticket FL-080826',
      'costo', 75.46,
      'precio', 101.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      20,
      'TK-FL-080826-5',
      NULL::date,
      75.46,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010506134531', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008427330' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008427330';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Pomada 100 Gr Descto: 2.0% Bepanthen Pomada Bepanthen',
      'sku', 'FC-08427330',
      'codigo_barras', '7501008427330',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Pomada 100 Gr Descto: 2.0% Bepanthen Pomada Bepanthen — Ticket FL-080826',
      'costo', 131.81,
      'precio', 177.95,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      3,
      'TK-FL-080826-6',
      NULL::date,
      131.81,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008427330', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501058792792' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501058792792';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tempra 24 Hrs Cab C/12 Rb Health $ Tempra 24 Hrs Cab C/12 1354312225027] Derman Crema 50',
      'sku', 'FC-58792792',
      'codigo_barras', '7501058792792',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tempra 24 Hrs Cab C/12 Rb Health $ Tempra 24 Hrs Cab C/12 1354312225027] Derman Crema 50 — Ticket FL-080826',
      'costo', 45.6,
      'precio', 61.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-7',
      NULL::date,
      45.6,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501058792792', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75011650002301' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75011650002301';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Eomelubrina Tab C/10 | Opella $ 73.70 Descto: 2.0% $ 72.23 Eomelubrina Tab C/10 | Opella',
      'sku', 'FC-50002301',
      'codigo_barras', '75011650002301',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Eomelubrina Tab C/10 | Opella $ 73.70 Descto: 2.0% $ 72.23 Eomelubrina Tab C/10 | Opella — Ticket FL-080826',
      'costo', 72.23,
      'precio', 97.52,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-8',
      NULL::date,
      72.23,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75011650002301', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501328979502' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501328979502';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Histiacil Ne Jar Adto 150 Mi | Opella $ 124.40 $ 124.40 Descto: 2.0% $ 121.91 $ 121.91 Jar Adto 150 Mi | Opella',
      'sku', 'FC-28979502',
      'codigo_barras', '7501328979502',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Histiacil Ne Jar Adto 150 Mi | Opella $ 124.40 $ 124.40 Descto: 2.0% $ 121.91 $ 121.91 Jar Adto 150 Mi | Opella — Ticket FL-080826',
      'costo', 124.4,
      'precio', 167.95,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-9',
      NULL::date,
      124.4,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501328979502', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75013289794961' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75013289794961';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Histiacil Ne Jar Ine 150 Ml | Opella 1 $ 125.80 $ 125.80 Descto: 2.0% G 123.28 Jar Ine 150 Ml | Opella G 123.28',
      'sku', 'FC-89794961',
      'codigo_barras', '75013289794961',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Histiacil Ne Jar Ine 150 Ml | Opella 1 $ 125.80 $ 125.80 Descto: 2.0% G 123.28 Jar Ine 150 Ml | Opella G 123.28 — Ticket FL-080826',
      'costo', 125.8,
      'precio', 169.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-10',
      NULL::date,
      125.8,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75013289794961', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010379071241' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010379071241';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Bisolvon Jbe Ine 120 Ml | Lăb Hormona $ 147.90 Descto: 2.0% $ 144.94 $ 147.90 Ine 120 Ml | Lăb Hormona',
      'sku', 'FC-79071241',
      'codigo_barras', '75010379071241',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Bisolvon Jbe Ine 120 Ml | Lăb Hormona $ 147.90 Descto: 2.0% $ 144.94 $ 147.90 Ine 120 Ml | Lăb Hormona — Ticket FL-080826',
      'costo', 147.9,
      'precio', 199.67,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      12,
      'TK-FL-080826-11',
      NULL::date,
      147.9,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010379071241', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022347624171' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022347624171';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Nailex Desenterrador Unas 12 Ml Nailex Desenterrador Unas',
      'sku', 'FC-47624171',
      'codigo_barras', '75022347624171',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Nailex Desenterrador Unas 12 Ml Nailex Desenterrador Unas — Ticket FL-080826',
      'costo', 54.49,
      'precio', 73.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      12,
      'TK-FL-080826-12',
      NULL::date,
      54.49,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022347624171', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501080950139' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501080950139';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '"Lasico Enz C/. Dwightnd Descto: 15.0% "Lasico Dwightnd Cond Tro Jan',
      'sku', 'FC-80950139',
      'codigo_barras', '7501080950139',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '"Lasico Enz C/. Dwightnd Descto: 15.0% "Lasico Dwightnd Cond Tro Jan — Ticket FL-080826',
      'costo', 42.5,
      'precio', 57.38,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-13',
      NULL::date,
      42.5,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501080950139', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022088947797' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022088947797';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tribedoce Tab /30 Nvo Bruluart 5 $ 18.00 Tribedoce Tab /30 Nvo Bruluart',
      'sku', 'FC-88947797',
      'codigo_barras', '75022088947797',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tribedoce Tab /30 Nvo Bruluart 5 $ 18.00 Tribedoce Tab /30 Nvo Bruluart — Ticket FL-080826',
      'costo', 18.0,
      'precio', 24.3,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      5,
      'TK-FL-080826-14',
      NULL::date,
      18.0,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022088947797', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010650959781' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010650959781';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Performance Tab Descto: 2.0% Centrum C/30 Pg Pere Performance Tab Centrum C/30',
      'sku', 'FC-50959781',
      'codigo_barras', '75010650959781',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Performance Tab Descto: 2.0% Centrum C/30 Pg Pere Performance Tab Centrum C/30 — Ticket FL-080826',
      'costo', 164.0,
      'precio', 221.4,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      7,
      'TK-FL-080826-15',
      NULL::date,
      164.0,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010650959781', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501080953017' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501080953017';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'È Tre & Ice C/3 Dwightnd Descto: 15.0% Cond Trojan È Tre & Ice C/3 Dwightnd',
      'sku', 'FC-80953017',
      'codigo_barras', '7501080953017',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'È Tre & Ice C/3 Dwightnd Descto: 15.0% Cond Trojan È Tre & Ice C/3 Dwightnd — Ticket FL-080826',
      'costo', 49.0,
      'precio', 66.16,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-16',
      NULL::date,
      49.0,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501080953017', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010954521161' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010954521161';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tempra 500 Mg Lab C/10 Rb Health $ 48.80 Descto: 6.0% Tempra 500 Mg {8 022503405381 Vitacilina Ung I Ksk',
      'sku', 'FC-54521161',
      'codigo_barras', '75010954521161',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tempra 500 Mg Lab C/10 Rb Health $ 48.80 Descto: 6.0% Tempra 500 Mg {8 022503405381 Vitacilina Ung I Ksk — Ticket FL-080826',
      'costo', 48.8,
      'precio', 65.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-17',
      NULL::date,
      48.8,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010954521161', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75012895201021' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75012895201021';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Hipoglos Pac Turo 45 Gr | Andromaco 1 $ 71.00 Descto: 2.0% $ 69.58 Turo 45 Gr | Andromaco',
      'sku', 'FC-95201021',
      'codigo_barras', '75012895201021',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Hipoglos Pac Turo 45 Gr | Andromaco 1 $ 71.00 Descto: 2.0% $ 69.58 Turo 45 Gr | Andromaco — Ticket FL-080826',
      'costo', 71.0,
      'precio', 95.85,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-18',
      NULL::date,
      71.0,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75012895201021', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008485316' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008485316';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tabcin Eferv Tab C/12 | Bayer Ot C Descto: 2.0% 38.50 $ 37.73 Tab C/12 | Bayer Ot C',
      'sku', 'FC-08485316',
      'codigo_barras', '7501008485316',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tabcin Eferv Tab C/12 | Bayer Ot C Descto: 2.0% 38.50 $ 37.73 Tab C/12 | Bayer Ot C — Ticket FL-080826',
      'costo', 37.73,
      'precio', 50.94,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-19',
      NULL::date,
      37.73,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008485316', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

commit;

select 1 as lote_ok, 6 as lotes_total;

-- ============================================================================
-- CARGAR faltantes — FarmaLive + barcode (EJECUTAR 3 y 4)
-- 149 bloques · Aspirina, Bepanthen, Desenfriol, etc.
-- Lote 2/6 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;


do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501065095947' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501065095947';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Centrum Silver Tab C/30 Pg Pere 1 Centrum Silver Tab C/30 Pere',
      'sku', 'FC-65095947',
      'codigo_barras', '7501065095947',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Centrum Silver Tab C/30 Pg Pere 1 Centrum Silver Tab C/30 Pere — Ticket FL-080826',
      'costo', 178.46,
      'precio', 240.93,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-20',
      NULL::date,
      178.46,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501065095947', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501095451096' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501095451096';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '/10 | Rb Healte Sal De Uvas $ 37.90 Descto: 2.0% $ 37.14 /10 | Rb Healte Sal De Uvas Fazolin E Gotas',
      'sku', 'FC-95451096',
      'codigo_barras', '7501095451096',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '/10 | Rb Healte Sal De Uvas $ 37.90 Descto: 2.0% $ 37.14 /10 | Rb Healte Sal De Uvas Fazolin E Gotas — Ticket FL-080826',
      'costo', 37.9,
      'precio', 51.17,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-21',
      NULL::date,
      37.9,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501095451096', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501079400556' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501079400556';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sanfer Descto: 8.04 Syncol Tab $ 107.40 $ 107.40 8 98.81 Sanfer Syncol Tab 871210734092301 Syncol Max Tab',
      'sku', 'FC-79400556',
      'codigo_barras', '7501079400556',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Sanfer Descto: 8.04 Syncol Tab $ 107.40 $ 107.40 8 98.81 Sanfer Syncol Tab 871210734092301 Syncol Max Tab — Ticket FL-080826',
      'costo', 107.4,
      'precio', 144.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-22',
      NULL::date,
      107.4,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501079400556', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501058793249' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501058793249';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Lubricante Sico Sens Calor 50 Ml | Rb Health 1 $ 101.90 Lubricante Sico Sens Calor 50 Ml | Rb',
      'sku', 'FC-58793249',
      'codigo_barras', '7501058793249',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lubricante Sico Sens Calor 50 Ml | Rb Health 1 $ 101.90 Lubricante Sico Sens Calor 50 Ml | Rb — Ticket FL-080826',
      'costo', 101.9,
      'precio', 137.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-23',
      NULL::date,
      101.9,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501058793249', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501095467264' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501095467264';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sal De Uvas Ixh C/50 | Rb Healti 1 $ 163.50 Descto: 2.0% $ 160.23 Sal De Uvas Ixh C/50 | Rb Healti',
      'sku', 'FC-95467264',
      'codigo_barras', '7501095467264',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sal De Uvas Ixh C/50 | Rb Healti 1 $ 163.50 Descto: 2.0% $ 160.23 Sal De Uvas Ixh C/50 | Rb Healti — Ticket FL-080826',
      'costo', 163.5,
      'precio', 220.73,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-24',
      NULL::date,
      163.5,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501095467264', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010587932321' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010587932321';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Lubricante Ico Cereza 50 Ml Rb Health 1 $ 101.90 Ico Cereza 50 Microdacyn',
      'sku', 'FC-87932321',
      'codigo_barras', '75010587932321',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lubricante Ico Cereza 50 Ml Rb Health 1 $ 101.90 Ico Cereza 50 Microdacyn — Ticket FL-080826',
      'costo', 101.9,
      'precio', 137.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-25',
      NULL::date,
      101.9,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010587932321', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008443026' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008443026';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tab C/100 Descto: 2.0% Alka-Seltzer Bayer C/100 Alka-Seltzer Ğel Rojo',
      'sku', 'FC-08443026',
      'codigo_barras', '7501008443026',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tab C/100 Descto: 2.0% Alka-Seltzer Bayer C/100 Alka-Seltzer Ğel Rojo — Ticket FL-080826',
      'costo', 262.0,
      'precio', 353.71,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      35,
      'TK-FL-080826-26',
      NULL::date,
      262.0,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008443026', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010075354321' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010075354321';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tylenol Tab Kenvue 1 $ 50.00 Descto: 2.0% $ 49.00 $ Kenvue',
      'sku', 'FC-75354321',
      'codigo_barras', '75010075354321',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tylenol Tab Kenvue 1 $ 50.00 Descto: 2.0% $ 49.00 $ Kenvue — Ticket FL-080826',
      'costo', 50.0,
      'precio', 67.5,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-27',
      NULL::date,
      50.0,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010075354321', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008491074' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008491074';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Aspirina Tab 80 2 Paci Bayer Onc 1 $ 124.80 Aspirina Tab 80 2 Paci [7360852785071 Manzaniila',
      'sku', 'FC-08491074',
      'codigo_barras', '7501008491074',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Aspirina Tab 80 2 Paci Bayer Onc 1 $ 124.80 Aspirina Tab 80 2 Paci [7360852785071 Manzaniila — Ticket FL-080826',
      'costo', 122.3,
      'precio', 165.11,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      16,
      'TK-FL-080826-28',
      NULL::date,
      122.3,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008491074', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501070612368' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501070612368';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '(A) Treda Tab €/20 Sanfer 2 $ 152.00 $ 304.00 Descto: 8.0% Sanfer Brunadol Tab Desato: 2.0%',
      'sku', 'FC-70612368',
      'codigo_barras', '7501070612368',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', '(A) Treda Tab €/20 Sanfer 2 $ 152.00 $ 304.00 Descto: 8.0% Sanfer Brunadol Tab Desato: 2.0% — Ticket FL-080826',
      'costo', 76.0,
      'precio', 102.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-29',
      NULL::date,
      76.0,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501070612368', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501088508929' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501088508929';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Anara Tab C/20 Chinoin 1 $ 162.60 Descto: 2.0% $ 159.35 Chinoin',
      'sku', 'FC-88508929',
      'codigo_barras', '7501088508929',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Anara Tab C/20 Chinoin 1 $ 162.60 Descto: 2.0% $ 159.35 Chinoin — Ticket FL-080826',
      'costo', 162.6,
      'precio', 219.52,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-30',
      NULL::date,
      162.6,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501088508929', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010084335531' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010084335531';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Forte Tab C/24 Descto: 2.0% Caf Iaspirina Forte C/24 Caf Iaspirina',
      'sku', 'FC-84335531',
      'codigo_barras', '75010084335531',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Forte Tab C/24 Descto: 2.0% Caf Iaspirina Forte C/24 Caf Iaspirina — Ticket FL-080826',
      'costo', 71.79,
      'precio', 96.92,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-31',
      NULL::date,
      71.79,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010084335531', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010723001331' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010723001331';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sr I Lab Ting Crema 28 Hormona $ 73.60 Sr I Ting Crema 28 Hormona',
      'sku', 'FC-23001331',
      'codigo_barras', '75010723001331',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sr I Lab Ting Crema 28 Hormona $ 73.60 Sr I Ting Crema 28 Hormona — Ticket FL-080826',
      'costo', 73.6,
      'precio', 99.36,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-32',
      NULL::date,
      73.6,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010723001331', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010885592111' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010885592111';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Scabisan Crema Er I Chinoin 1 $ 194.60 Descto: 2.0% $ 190.71 Scabisan Crema Er I Chinoin',
      'sku', 'FC-85592111',
      'codigo_barras', '75010885592111',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Scabisan Crema Er I Chinoin 1 $ 194.60 Descto: 2.0% $ 190.71 Scabisan Crema Er I Chinoin — Ticket FL-080826',
      'costo', 194.6,
      'precio', 262.72,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-33',
      NULL::date,
      194.6,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010885592111', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010084999001' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010084999001';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Boost Tar C/50 Descto: 2.0% Alka-Seltzer Bayer Boost Tar C/50 Alka-Seltzer',
      'sku', 'FC-84999001',
      'codigo_barras', '75010084999001',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Boost Tar C/50 Descto: 2.0% Alka-Seltzer Bayer Boost Tar C/50 Alka-Seltzer — Ticket FL-080826',
      'costo', 174.0,
      'precio', 234.9,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-34',
      NULL::date,
      174.0,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010084999001', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008498798' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008498798';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Bepanthen Multiusos Pomada Otc 30 Bepanthen Multiusos Pomada',
      'sku', 'FC-08498798',
      'codigo_barras', '7501008498798',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Bepanthen Multiusos Pomada Otc 30 Bepanthen Multiusos Pomada — Ticket FL-080826',
      'costo', 63.25,
      'precio', 85.39,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      30,
      'TK-FL-080826-35',
      NULL::date,
      63.25,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008498798', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008491096' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008491096';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cafiaspirina Tar C/100 2 Pace Bayer Otc 221.90 Descto: 2.0% Cafiaspirina Tar C/100 2 Pace Corega Ultra',
      'sku', 'FC-08491096',
      'codigo_barras', '7501008491096',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cafiaspirina Tar C/100 2 Pace Bayer Otc 221.90 Descto: 2.0% Cafiaspirina Tar C/100 2 Pace Corega Ultra — Ticket FL-080826',
      'costo', 217.46,
      'precio', 293.58,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      40,
      'TK-FL-080826-36',
      NULL::date,
      217.46,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008491096', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75011650003151' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75011650003151';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Iv Neomelubrina Jbe 100 Ml I Opella 121.00 Neomelubrina Jbe 100 Ml I Opella',
      'sku', 'FC-50003151',
      'codigo_barras', '75011650003151',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Iv Neomelubrina Jbe 100 Ml I Opella 121.00 Neomelubrina Jbe 100 Ml I Opella — Ticket FL-080826',
      'costo', 118.58,
      'precio', 160.09,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-37',
      NULL::date,
      118.58,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75011650003151', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502224227339' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502224227339';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '(A) Loxcel Adto Tab C/1 | Lab Hormona 2 $ 78.00 Descto: 6.0% $ 73.32 Adto Tab C/1 | Lab Hormona 2',
      'sku', 'FC-24227339',
      'codigo_barras', '7502224227339',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', '(A) Loxcel Adto Tab C/1 | Lab Hormona 2 $ 78.00 Descto: 6.0% $ 73.32 Adto Tab C/1 | Lab Hormona 2 — Ticket FL-080826',
      'costo', 78.0,
      'precio', 105.31,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-38',
      NULL::date,
      78.0,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502224227339', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010898100381' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010898100381';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Herklin Shai 20 Ml Armstroni 1 $ 128.80 Descto: 2.0% $ 126.22 $ 128.80 20 Ml Armstroni 265024 Genomma Alli-Triple',
      'sku', 'FC-98100381',
      'codigo_barras', '75010898100381',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Herklin Shai 20 Ml Armstroni 1 $ 128.80 Descto: 2.0% $ 126.22 $ 128.80 20 Ml Armstroni 265024 Genomma Alli-Triple — Ticket FL-080826',
      'costo', 128.8,
      'precio', 173.89,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-39',
      NULL::date,
      128.8,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010898100381', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501314704156' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501314704156';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Supos Adto C/10 Otc Descto: 7.0% Senosiain Senosiain Supos Adto C/10 Senosiain Senosiain',
      'sku', 'FC-14704156',
      'codigo_barras', '7501314704156',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Supos Adto C/10 Otc Descto: 7.0% Senosiain Senosiain Supos Adto C/10 Senosiain Senosiain — Ticket FL-080826',
      'costo', 58.96,
      'precio', 79.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-40',
      NULL::date,
      58.96,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501314704156', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501314704163' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501314704163';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Supos Ine C/10 Descto: 7.0% Senosiain Supos C/10 Senosiain',
      'sku', 'FC-14704163',
      'codigo_barras', '7501314704163',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Supos Ine C/10 Descto: 7.0% Senosiain Supos C/10 Senosiain — Ticket FL-080826',
      'costo', 58.96,
      'precio', 79.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-41',
      NULL::date,
      58.96,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501314704163', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7503008344488' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7503008344488';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Lactopram 430 Mg Cap C/20 Progela 29.30 Descto: Lactopram 430 Mg Cap C/20 Progela',
      'sku', 'FC-08344488',
      'codigo_barras', '7503008344488',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lactopram 430 Mg Cap C/20 Progela 29.30 Descto: Lactopram 430 Mg Cap C/20 Progela — Ticket FL-080826',
      'costo', 28.71,
      'precio', 38.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-42',
      NULL::date,
      28.71,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7503008344488', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501065095718' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501065095718';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '/ 30 | Pg Pere Descto: 2.0% Centrum Tab $ 152.20 Pg Pere Centrum Tab',
      'sku', 'FC-65095718',
      'codigo_barras', '7501065095718',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', '/ 30 | Pg Pere Descto: 2.0% Centrum Tab $ 152.20 Pg Pere Centrum Tab — Ticket FL-080826',
      'costo', 152.2,
      'precio', 205.47,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-43',
      NULL::date,
      152.2,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501065095718', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75064601015141' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75064601015141';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Soft Lub Lubricante Original 56.7 Soft Lubricante Original',
      'sku', 'FC-01015141',
      'codigo_barras', '75064601015141',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Soft Lub Lubricante Original 56.7 Soft Lubricante Original — Ticket FL-080826',
      'costo', 78.49,
      'precio', 105.97,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-44',
      NULL::date,
      78.49,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75064601015141', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

commit;

select 2 as lote_ok, 6 as lotes_total;

-- ============================================================================
-- CARGAR faltantes — FarmaLive + barcode (EJECUTAR 3 y 4)
-- 149 bloques · Aspirina, Bepanthen, Desenfriol, etc.
-- Lote 3/6 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;


do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008496701' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008496701';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Aspirina Eferv Tab C/12 Bayer Otc Aspirina Eferv C/12',
      'sku', 'FC-08496701',
      'codigo_barras', '7501008496701',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Aspirina Eferv Tab C/12 Bayer Otc Aspirina Eferv C/12 — Ticket FL-080826',
      'costo', 35.18,
      'precio', 47.5,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-45',
      NULL::date,
      35.18,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008496701', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022088915491' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022088915491';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tarmin 2 Mg /12 Tab Bruluagsa Descto: 2.05 6. Tarmin 2 Mg /12 Tab Bruluagsa',
      'sku', 'FC-88915491',
      'codigo_barras', '75022088915491',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tarmin 2 Mg /12 Tab Bruluagsa Descto: 2.05 6. Tarmin 2 Mg /12 Tab Bruluagsa — Ticket FL-080826',
      'costo', 80.9,
      'precio', 109.22,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      50,
      'TK-FL-080826-46',
      NULL::date,
      80.9,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022088915491', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7503008344747' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7503008344747';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Descto: 2.0% Afrodit 400 Ui 46.00 $ $ 45.08 Afrodit 400 Ui',
      'sku', 'FC-08344747',
      'codigo_barras', '7503008344747',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Descto: 2.0% Afrodit 400 Ui 46.00 $ $ 45.08 Afrodit 400 Ui — Ticket FL-080826',
      'costo', 45.08,
      'precio', 60.86,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      5,
      'TK-FL-080826-47',
      NULL::date,
      45.08,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7503008344747', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502208895196' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502208895196';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ky6 Tab C/10 Bruluart 5 $ 9.50 $ 9.31 $ 47.50 Bruluart E74011 Bayer 67 Aspirina Tab',
      'sku', 'FC-08895196',
      'codigo_barras', '7502208895196',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Ky6 Tab C/10 Bruluart 5 $ 9.50 $ 9.31 $ 47.50 Bruluart E74011 Bayer 67 Aspirina Tab — Ticket FL-080826',
      'costo', 1.9,
      'precio', 2.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      5,
      'TK-FL-080826-48',
      NULL::date,
      1.9,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502208895196', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501089810021' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501089810021';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Herklin Ne Sham 60 Ml | Armstrong 1 $ 81.00 Herklin Ne Sham 60 Ml | Armstrong',
      'sku', 'FC-89810021',
      'codigo_barras', '7501089810021',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Herklin Ne Sham 60 Ml | Armstrong 1 $ 81.00 Herklin Ne Sham 60 Ml | Armstrong — Ticket FL-080826',
      'costo', 79.38,
      'precio', 107.17,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-49',
      NULL::date,
      79.38,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501089810021', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506460101378' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506460101378';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Lubricante Piel Con Piel 50 Mi Health 1 $ 102.50 Lubricante Piel Con Piel 50 Mi Lotrimin Uno',
      'sku', 'FC-60101378',
      'codigo_barras', '7506460101378',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lubricante Piel Con Piel 50 Mi Health 1 $ 102.50 Lubricante Piel Con Piel 50 Mi Lotrimin Uno — Ticket FL-080826',
      'costo', 96.35,
      'precio', 130.08,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-50',
      NULL::date,
      96.35,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506460101378', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022760403681' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022760403681';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Desenfriol D Dab C/30 | Bayer Otc $ 63.00 Descto: 2.0% Desenfriol D Dab C/30 | Bayer 5022274264491 Nesajar Cap',
      'sku', 'FC-60403681',
      'codigo_barras', '75022760403681',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desenfriol D Dab C/30 | Bayer Otc $ 63.00 Descto: 2.0% Desenfriol D Dab C/30 | Bayer 5022274264491 Nesajar Cap — Ticket FL-080826',
      'costo', 63.0,
      'precio', 85.06,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-51',
      NULL::date,
      63.0,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022760403681', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022088923551' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022088923551';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Iv Cilocid 5 Mg Tab C/20 | Bruluari 7.40 Descto: 2.0% $ 7.25 Iv Cilocid 5 Mg Tab C/20 | Bruluari Senosiain',
      'sku', 'FC-88923551',
      'codigo_barras', '75022088923551',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Iv Cilocid 5 Mg Tab C/20 | Bruluari 7.40 Descto: 2.0% $ 7.25 Iv Cilocid 5 Mg Tab C/20 | Bruluari Senosiain — Ticket FL-080826',
      'costo', 7.25,
      'precio', 9.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      16,
      'TK-FL-080826-52',
      NULL::date,
      7.25,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022088923551', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501125116810' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501125116810';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ab Pis. Descto: 2.0% Agrifen Tab 5. $ 19.50 Ab Pis. Agrifen Tab',
      'sku', 'FC-25116810',
      'codigo_barras', '7501125116810',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Ab Pis. Descto: 2.0% Agrifen Tab 5. $ 19.50 Ab Pis. Agrifen Tab — Ticket FL-080826',
      'costo', 19.5,
      'precio', 26.33,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-53',
      NULL::date,
      19.5,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501125116810', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500435246309' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500435246309';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Vick Drops Tengibre Pastillas C/20 Vick Drops Tengibre',
      'sku', 'FC-35246309',
      'codigo_barras', '7500435246309',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Vick Drops Tengibre Pastillas C/20 Vick Drops Tengibre — Ticket FL-080826',
      'costo', 37.53,
      'precio', 50.67,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-54',
      NULL::date,
      37.53,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500435246309', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022347640531' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022347640531';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ecuperador Una Lab Pisa Descto: 2.0% Aile Marilla 15 M Ecuperador Una Aile Marilla 15 M',
      'sku', 'FC-47640531',
      'codigo_barras', '75022347640531',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Ecuperador Una Lab Pisa Descto: 2.0% Aile Marilla 15 M Ecuperador Una Aile Marilla 15 M — Ticket FL-080826',
      'costo', 55.6,
      'precio', 75.06,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-55',
      NULL::date,
      55.6,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022347640531', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010084095411' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010084095411';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Saridon Tab 120 Bayer Oto $ 64.75 Saridon Tab',
      'sku', 'FC-84095411',
      'codigo_barras', '75010084095411',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Saridon Tab 120 Bayer Oto $ 64.75 Saridon Tab — Ticket FL-080826',
      'costo', 64.75,
      'precio', 87.42,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-56',
      NULL::date,
      64.75,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010084095411', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010885097661' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010885097661';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Jr. Jbe Ine 60 Mant Chinotes Chinoin Jr. Jbe Mant Chinotes Chinoin',
      'sku', 'FC-85097661',
      'codigo_barras', '75010885097661',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jr. Jbe Ine 60 Mant Chinotes Chinoin Jr. Jbe Mant Chinotes Chinoin — Ticket FL-080826',
      'costo', 127.9,
      'precio', 172.67,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-57',
      NULL::date,
      127.9,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010885097661', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010506247327' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010506247327';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Afrin Spray No Drip Extra Humectante Afrin Spray Drip Extra',
      'sku', 'FC-06247327',
      'codigo_barras', '75010506247327',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Afrin Spray No Drip Extra Humectante Afrin Spray Drip Extra — Ticket FL-080826',
      'costo', 109.76,
      'precio', 148.18,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-58',
      NULL::date,
      109.76,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010506247327', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010084973401' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010084973401';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Flanax 550 Mc Tab C/12 | Bayér Otc 203.00 Descto: 10.0% $ 182.70 Tab C/12 | Chinoin',
      'sku', 'FC-84973401',
      'codigo_barras', '75010084973401',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Flanax 550 Mc Tab C/12 | Bayér Otc 203.00 Descto: 10.0% $ 182.70 Tab C/12 | Chinoin — Ticket FL-080826',
      'costo', 182.7,
      'precio', 246.65,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-59',
      NULL::date,
      182.7,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010084973401', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008426944' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008426944';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Gr 5.58 Bayer Descto: 2.0% Flanax Gel 40 Otc Gr 5.58 Flanax Gel 40',
      'sku', 'FC-08426944',
      'codigo_barras', '7501008426944',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Gr 5.58 Bayer Descto: 2.0% Flanax Gel 40 Otc Gr 5.58 Flanax Gel 40 — Ticket FL-080826',
      'costo', 117.11,
      'precio', 158.1,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-60',
      NULL::date,
      117.11,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008426944', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75012982176351' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75012982176351';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Iv Sot.O-Neurobion Dc Ete Jga Sot.O-Neurobion Prell C/1 | Pg Health9.20',
      'sku', 'FC-82176351',
      'codigo_barras', '75012982176351',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Iv Sot.O-Neurobion Dc Ete Jga Sot.O-Neurobion Prell C/1 | Pg Health9.20 — Ticket FL-080826',
      'costo', 819.71,
      'precio', 1106.61,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-61',
      NULL::date,
      819.71,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75012982176351', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75011230133021' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75011230133021';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Iri Amp 50.000 Mexico Descto: Mexico Iv Bedoyecta Bausch',
      'sku', 'FC-30133021',
      'codigo_barras', '75011230133021',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Iri Amp 50.000 Mexico Descto: Mexico Iv Bedoyecta Bausch — Ticket FL-080826',
      'costo', 273.42,
      'precio', 369.12,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      17,
      'TK-FL-080826-62',
      NULL::date,
      273.42,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75011230133021', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501298217659' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501298217659';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Iv Dolo-Neurobion Dc Jga Preli C/3 3 Ml | Pg Health 23.25 Descto: 17.0% Dolo-Neurobion Dc Jga Preli C/3 3 Ml | Pg Health',
      'sku', 'FC-98217659',
      'codigo_barras', '7501298217659',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Iv Dolo-Neurobion Dc Jga Preli C/3 3 Ml | Pg Health 23.25 Descto: 17.0% Dolo-Neurobion Dc Jga Preli C/3 3 Ml | Pg Health — Ticket FL-080826',
      'costo', 434.3,
      'precio', 586.31,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-63',
      NULL::date,
      434.3,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501298217659', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75095466888171' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75095466888171';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Crema Dent Colgate Max Clean 120 Ml Colgate Palmolive $ 25.50 Descto: 2.0% $ 24.99 Crema Dent Colgate Max Clean 120 Ml C',
      'sku', 'FC-66888171',
      'codigo_barras', '75095466888171',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Crema Dent Colgate Max Clean 120 Ml Colgate Palmolive $ 25.50 Descto: 2.0% $ 24.99 Crema Dent Colgate Max Clean 120 Ml C — Ticket FL-080826',
      'costo', 25.5,
      'precio', 34.43,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-64',
      NULL::date,
      25.5,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75095466888171', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75095466873531' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75095466873531';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '90 Crema Dent Aot.Cate Me P Crema Dent Aot.Cate',
      'sku', 'FC-66873531',
      'codigo_barras', '75095466873531',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '90 Crema Dent Aot.Cate Me P Crema Dent Aot.Cate — Ticket FL-080826',
      'costo', 32.44,
      'precio', 43.8,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-65',
      NULL::date,
      32.44,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75095466873531', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010486708021' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010486708021';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sigital Protec Desato: 2.0% Termometro Degasa 42.10 Sigital Protec Desato: 2.0% Termometro',
      'sku', 'FC-86708021',
      'codigo_barras', '75010486708021',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sigital Protec Desato: 2.0% Termometro Degasa 42.10 Sigital Protec Desato: 2.0% Termometro — Ticket FL-080826',
      'costo', 41.26,
      'precio', 55.71,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-66',
      NULL::date,
      41.26,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010486708021', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7503003406600' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7503003406600';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tela Adhesiva Quirmex 2.5Cmxsm | Quirmex Descto: 2.0% 29.90 29.30 $ 89.70 Quirmex 2.5Cmxsm | Quirmex',
      'sku', 'FC-03406600',
      'codigo_barras', '7503003406600',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tela Adhesiva Quirmex 2.5Cmxsm | Quirmex Descto: 2.0% 29.90 29.30 $ 89.70 Quirmex 2.5Cmxsm | Quirmex — Ticket FL-080826',
      'costo', 89.7,
      'precio', 121.1,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      45,
      'TK-FL-080826-67',
      NULL::date,
      89.7,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7503003406600', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7503003406501' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7503003406501';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tela Adhesiva Quirmex 1.25Cmx5M | Quirmex 19.00 Descto: 2.0% $ 18.62 $ Quirmex 1.25Cmx5M | Quirmex',
      'sku', 'FC-03406501',
      'codigo_barras', '7503003406501',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tela Adhesiva Quirmex 1.25Cmx5M | Quirmex 19.00 Descto: 2.0% $ 18.62 $ Quirmex 1.25Cmx5M | Quirmex — Ticket FL-080826',
      'costo', 18.62,
      'precio', 25.14,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      5,
      'TK-FL-080826-68',
      NULL::date,
      18.62,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7503003406501', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75030034063651' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75030034063651';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tela Adhesiva Quirmex 2.5Cmxi̇m | Quirmex 5 $ 11.70 Descto: 2.0% $ 11.47 | Tela Adhesiva Quirmex 2.5Cmxi̇m | Quirmex',
      'sku', 'FC-34063651',
      'codigo_barras', '75030034063651',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tela Adhesiva Quirmex 2.5Cmxi̇m | Quirmex 5 $ 11.70 Descto: 2.0% $ 11.47 | Tela Adhesiva Quirmex 2.5Cmxi̇m | Quirmex — Ticket FL-080826',
      'costo', 2.34,
      'precio', 3.16,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      5,
      'TK-FL-080826-69',
      NULL::date,
      2.34,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75030034063651', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

commit;

select 3 as lote_ok, 6 as lotes_total;

-- ============================================================================
-- CARGAR faltantes — FarmaLive + barcode (EJECUTAR 3 y 4)
-- 149 bloques · Aspirina, Bepanthen, Desenfriol, etc.
-- Lote 4/6 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;


do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75030034062421' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75030034062421';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tela Adhesiva Quirmex 1.25Cmx1M | Quirmex 5 5.40 $ Tela Adhesiva Quirmex 1.25Cmx1M | Quirmex',
      'sku', 'FC-34062421',
      'codigo_barras', '75030034062421',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tela Adhesiva Quirmex 1.25Cmx1M | Quirmex 5 5.40 $ Tela Adhesiva Quirmex 1.25Cmx1M | Quirmex — Ticket FL-080826',
      'costo', 5.29,
      'precio', 7.15,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      5,
      'TK-FL-080826-70',
      NULL::date,
      5.29,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75030034062421', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75095460689091' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75095460689091';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Crema Deni Colgate Trip Xtra B 50 Ml 1 Colgate Paimolive 14.00 Descto: 2.04 Colgate Trip Xtra B 50 Ml',
      'sku', 'FC-60689091',
      'codigo_barras', '75095460689091',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Crema Deni Colgate Trip Xtra B 50 Ml 1 Colgate Paimolive 14.00 Descto: 2.04 Colgate Trip Xtra B 50 Ml — Ticket FL-080826',
      'costo', 13.72,
      'precio', 18.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-71',
      NULL::date,
      13.72,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75095460689091', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010173629981' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010173629981';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Panuelos Kleenex Pack C/8 1 Kimberly Clark $ 33.30 Descto: 2.04 Panuelos Kleenex Pack C/8 1 Kimberly Clark',
      'sku', 'FC-73629981',
      'codigo_barras', '75010173629981',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Panuelos Kleenex Pack C/8 1 Kimberly Clark $ 33.30 Descto: 2.04 Panuelos Kleenex Pack C/8 1 Kimberly Clark — Ticket FL-080826',
      'costo', 33.3,
      'precio', 44.96,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-72',
      NULL::date,
      33.3,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010173629981', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75064256131681' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75064256131681';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Panuelos Leenex C/90 | Kimberly Clark 25. $ Descto: 2.0% Leenex C/90 | Kimberly Clark Bib Evenelo',
      'sku', 'FC-56131681',
      'codigo_barras', '75064256131681',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Panuelos Leenex C/90 | Kimberly Clark 25. $ Descto: 2.0% Leenex C/90 | Kimberly Clark Bib Evenelo — Ticket FL-080826',
      'costo', 24.89,
      'precio', 33.61,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      14,
      'TK-FL-080826-73',
      NULL::date,
      24.89,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75064256131681', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75095460009851' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75095460009851';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cremi Dent Colgate Triple Acc 75 Ml Colgate Paimolive $ 19.20 Descto: 2.0K $ 18.82 Dent Colgate Triple Acc 75 Ml Colgate',
      'sku', 'FC-60009851',
      'codigo_barras', '75095460009851',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cremi Dent Colgate Triple Acc 75 Ml Colgate Paimolive $ 19.20 Descto: 2.0K $ 18.82 Dent Colgate Triple Acc 75 Ml Colgate — Ticket FL-080826',
      'costo', 19.2,
      'precio', 25.92,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-74',
      NULL::date,
      19.2,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75095460009851', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75060223273451' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75060223273451';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Jeringa Sens Imedicai Insul 0.5 Ml C/100 | Jayor 1 $ 217.20 Jeringa Sens Imedicai Insul 0.5 Ml',
      'sku', 'FC-23273451',
      'codigo_barras', '75060223273451',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Jeringa Sens Imedicai Insul 0.5 Ml C/100 | Jayor 1 $ 217.20 Jeringa Sens Imedicai Insul 0.5 Ml — Ticket FL-080826',
      'costo', 217.2,
      'precio', 293.23,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-75',
      NULL::date,
      217.2,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75060223273451', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010275163051' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010275163051';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Bib Evenelo Ensueno Azul 802 | Kimberly Clark 1 $ 15.80 Descto: 2.0K Bib Evenelo Ensueno Azul 802 | Kimberly Clark',
      'sku', 'FC-75163051',
      'codigo_barras', '75010275163051',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Bib Evenelo Ensueno Azul 802 | Kimberly Clark 1 $ 15.80 Descto: 2.0K Bib Evenelo Ensueno Azul 802 | Kimberly Clark — Ticket FL-080826',
      'costo', 15.8,
      'precio', 21.33,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      24,
      'TK-FL-080826-76',
      NULL::date,
      15.8,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010275163051', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501027512574' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501027512574';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Bib Evenelo Colors 8 02 | Kimberly Clark $ 15.80 Descto: 2.0% $ 15.48 $ 47.40 Colors 8 02 | Kimberly Clark',
      'sku', 'FC-27512574',
      'codigo_barras', '7501027512574',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Bib Evenelo Colors 8 02 | Kimberly Clark $ 15.80 Descto: 2.0% $ 15.48 $ 47.40 Colors 8 02 | Kimberly Clark — Ticket FL-080826',
      'costo', 15.8,
      'precio', 21.33,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-77',
      NULL::date,
      15.8,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501027512574', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010275125811' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010275125811';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Bib Evenelo Colors 4 02 Kimberly Clark $ 13.40 Descto: 2.0* $ 13.13 40.20 Colors 4 02 Kimberly Clark Cepillo 17702010631',
      'sku', 'FC-75125811',
      'codigo_barras', '75010275125811',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Bib Evenelo Colors 4 02 Kimberly Clark $ 13.40 Descto: 2.0* $ 13.13 40.20 Colors 4 02 Kimberly Clark Cepillo 17702010631 — Ticket FL-080826',
      'costo', 13.4,
      'precio', 18.1,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-78',
      NULL::date,
      13.4,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010275125811', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75030034067851' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75030034067851';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Algodon Quirmex Quirmex Descto: 2.0% Torunda De 76 Algodon Quirmex Quirmex Torunda De',
      'sku', 'FC-34067851',
      'codigo_barras', '75030034067851',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Algodon Quirmex Quirmex Descto: 2.0% Torunda De 76 Algodon Quirmex Quirmex Torunda De — Ticket FL-080826',
      'costo', 17.54,
      'precio', 23.68,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-79',
      NULL::date,
      17.54,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75030034067851', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501048623006' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501048623006';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Pads Facial Protec Redondos C/100 | Degasa 2 $ 21.70 Pads Facial Protec Redondos C/100 | Degasa',
      'sku', 'FC-48623006',
      'codigo_barras', '7501048623006',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Pads Facial Protec Redondos C/100 | Degasa 2 $ 21.70 Pads Facial Protec Redondos C/100 | Degasa — Ticket FL-080826',
      'costo', 21.7,
      'precio', 29.3,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-80',
      NULL::date,
      21.7,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501048623006', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75060223272151' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75060223272151';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Jeringa Sensimedical Insul 0.3 Ml C/100 | Jayor 1 $ Jeringa Sensimedical Insul 0.3 Ml',
      'sku', 'FC-23272151',
      'codigo_barras', '75060223272151',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Jeringa Sensimedical Insul 0.3 Ml C/100 | Jayor 1 $ Jeringa Sensimedical Insul 0.3 Ml — Ticket FL-080826',
      'costo', 212.86,
      'precio', 287.37,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      12,
      'TK-FL-080826-81',
      NULL::date,
      212.86,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75060223272151', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501868910041' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501868910041';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Algodon Dibar 5 Gr Dibar 12 $ 6.90 Descto: 2.0% $ 6.76 $ 82.80 5 Gr Dibar',
      'sku', 'FC-68910041',
      'codigo_barras', '7501868910041',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Algodon Dibar 5 Gr Dibar 12 $ 6.90 Descto: 2.0% $ 6.76 $ 82.80 5 Gr Dibar — Ticket FL-080826',
      'costo', 0.58,
      'precio', 0.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      12,
      'TK-FL-080826-82',
      NULL::date,
      0.58,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501868910041', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75018689100101' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75018689100101';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Algodon Dibar 200 Gr Dibak 2 $ 35.30 Descto: 2.0% $ 34.59 70.60 200 Gr Dibak',
      'sku', 'FC-89100101',
      'codigo_barras', '75018689100101',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Algodon Dibar 200 Gr Dibak 2 $ 35.30 Descto: 2.0% $ 34.59 70.60 200 Gr Dibak — Ticket FL-080826',
      'costo', 17.65,
      'precio', 23.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-83',
      NULL::date,
      17.65,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75018689100101', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75030034067301' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75030034067301';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Venda Quirmex 7.5 Cm | Quirmex 12 $ 6.80 Descto: 2.0% $ 6.66 7.5 Cm | Quirmex 5 50300340R7231 Venda Quirmex Cm | Quirmex',
      'sku', 'FC-34067301',
      'codigo_barras', '75030034067301',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Venda Quirmex 7.5 Cm | Quirmex 12 $ 6.80 Descto: 2.0% $ 6.66 7.5 Cm | Quirmex 5 50300340R7231 Venda Quirmex Cm | Quirmex — Ticket FL-080826',
      'costo', 0.57,
      'precio', 0.77,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      12,
      'TK-FL-080826-84',
      NULL::date,
      0.57,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75030034067301', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75030034067471' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75030034067471';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Venda Quirme) Lo Cm Quirmex 8.90 Descto: 2.0% $ 8.72 Lo Cm Quirmex',
      'sku', 'FC-34067471',
      'codigo_barras', '75030034067471',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Venda Quirme) Lo Cm Quirmex 8.90 Descto: 2.0% $ 8.72 Lo Cm Quirmex — Ticket FL-080826',
      'costo', 8.72,
      'precio', 11.78,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-85',
      NULL::date,
      8.72,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75030034067471', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75030034067781' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75030034067781';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Venda Quirmex 30 Cm | Quirmex 24.20 Descto: 2.0% $ 23.72 96.80 30 Cm | Quirmex Dibar Algodon Dibar',
      'sku', 'FC-34067781',
      'codigo_barras', '75030034067781',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Venda Quirmex 30 Cm | Quirmex 24.20 Descto: 2.0% $ 23.72 96.80 30 Cm | Quirmex Dibar Algodon Dibar — Ticket FL-080826',
      'costo', 23.72,
      'precio', 32.03,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-86',
      NULL::date,
      23.72,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75030034067781', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501868910034' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501868910034';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '60 Gr | Dibar Descto: 2.0% Algodon Dibar $ 10.10 60 Gr | Dibar Algodon Dibar',
      'sku', 'FC-68910034',
      'codigo_barras', '7501868910034',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '60 Gr | Dibar Descto: 2.0% Algodon Dibar $ 10.10 60 Gr | Dibar Algodon Dibar — Ticket FL-080826',
      'costo', 10.1,
      'precio', 13.64,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-87',
      NULL::date,
      10.1,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501868910034', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75095466534951' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75095466534951';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Crema Dent Colgate Total Colgate Palmolive $ Colgate Total Colgate',
      'sku', 'FC-66534951',
      'codigo_barras', '75095466534951',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Crema Dent Colgate Total Colgate Palmolive $ Colgate Total Colgate — Ticket FL-080826',
      'costo', 22.93,
      'precio', 30.96,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-88',
      NULL::date,
      22.93,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75095466534951', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010483510531' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010483510531';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Gel Antibacterial Protec 250 Ml Degasa 22.40 Antibacterial Protec 250 Ml Degasa',
      'sku', 'FC-83510531',
      'codigo_barras', '75010483510531',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Gel Antibacterial Protec 250 Ml Degasa 22.40 Antibacterial Protec 250 Ml Degasa — Ticket FL-080826',
      'costo', 123.58,
      'precio', 166.84,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-89',
      NULL::date,
      123.58,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010483510531', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501868900127' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501868900127';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Gasa Dibar 10X10 Paq 10 Cajitas/10 126.10 Dibar Gasa Dibar 10X10 Paq 10 Cajitas/10',
      'sku', 'FC-68900127',
      'codigo_barras', '7501868900127',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Gasa Dibar 10X10 Paq 10 Cajitas/10 126.10 Dibar Gasa Dibar 10X10 Paq 10 Cajitas/10 — Ticket FL-080826',
      'costo', 123.58,
      'precio', 166.84,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-90',
      NULL::date,
      123.58,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501868900127', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501868900134' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501868900134';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Lox10 Exh C/100 Descto: 2.0% Gasa Dibar Dibar 111.10 Lox10 Exh C/100 Gasa Dibar Dibar',
      'sku', 'FC-68900134',
      'codigo_barras', '7501868900134',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lox10 Exh C/100 Descto: 2.0% Gasa Dibar Dibar 111.10 Lox10 Exh C/100 Gasa Dibar Dibar — Ticket FL-080826',
      'costo', 108.88,
      'precio', 146.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      3,
      'TK-FL-080826-91',
      NULL::date,
      108.88,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501868900134', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501250882017' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501250882017';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Espuma 120 Mi Descto: 2.0% Dermodine Degasa Espuma 120 Mi Dermodine',
      'sku', 'FC-50882017',
      'codigo_barras', '7501250882017',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Espuma 120 Mi Descto: 2.0% Dermodine Degasa Espuma 120 Mi Dermodine — Ticket FL-080826',
      'costo', 75.2,
      'precio', 101.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-92',
      NULL::date,
      75.2,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501250882017', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75012508820243' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75012508820243';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '0 Dermod Ine M 1 Degasa 37.60 Dermod Ine Degasa',
      'sku', 'FC-08820243',
      'codigo_barras', '75012508820243',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '0 Dermod Ine M 1 Degasa 37.60 Dermod Ine Degasa — Ticket FL-080826',
      'costo', 36.85,
      'precio', 49.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-93',
      NULL::date,
      36.85,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75012508820243', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506376000277' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506376000277';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cre Vitacilina Humectante 100 Gr Vitacilina Humectante',
      'sku', 'FC-76000277',
      'codigo_barras', '7506376000277',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cre Vitacilina Humectante 100 Gr Vitacilina Humectante — Ticket FL-080826',
      'costo', 77.03,
      'precio', 104.0,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-94',
      NULL::date,
      77.03,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506376000277', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

commit;

select 4 as lote_ok, 6 as lotes_total;

-- ============================================================================
-- CARGAR faltantes — FarmaLive + barcode (EJECUTAR 3 y 4)
-- 149 bloques · Aspirina, Bepanthen, Desenfriol, etc.
-- Lote 5/6 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;


do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75004351444145' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75004351444145';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '0 Stick Tripack Des Old Spice Gr Pg Pere Descto: 2.0% Stick Tripack Des Old Spice Pg Pere',
      'sku', 'FC-51444145',
      'codigo_barras', '75004351444145',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '0 Stick Tripack Des Old Spice Gr Pg Pere Descto: 2.0% Stick Tripack Des Old Spice Pg Pere — Ticket FL-080826',
      'costo', 135.73,
      'precio', 183.24,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-95',
      NULL::date,
      135.73,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75004351444145', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010483351691' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010483351691';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Jermocleen Agua Oxigenada 230Ml Degasa Jermocleen Agua Oxigenada',
      'sku', 'FC-83351691',
      'codigo_barras', '75010483351691',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jermocleen Agua Oxigenada 230Ml Degasa Jermocleen Agua Oxigenada — Ticket FL-080826',
      'costo', 10.19,
      'precio', 13.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-96',
      NULL::date,
      10.19,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010483351691', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010483351381' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010483351381';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Dermocleen Agua Oxigenada 100Ml | Degasa $ Dermocleen Agua Oxigenada 100Ml',
      'sku', 'FC-83351381',
      'codigo_barras', '75010483351381',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Dermocleen Agua Oxigenada 100Ml | Degasa $ Dermocleen Agua Oxigenada 100Ml — Ticket FL-080826',
      'costo', 7.64,
      'precio', 10.32,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-97',
      NULL::date,
      7.64,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010483351381', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501033956775' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501033956775';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Pedialyte Sr60 Uva 500 Mi Abbott $ 24.30 Pedialyte Sr60 Uva 500 Mi',
      'sku', 'FC-33956775',
      'codigo_barras', '7501033956775',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Pedialyte Sr60 Uva 500 Mi Abbott $ 24.30 Pedialyte Sr60 Uva 500 Mi — Ticket FL-080826',
      'costo', 24.3,
      'precio', 32.81,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-98',
      NULL::date,
      24.3,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501033956775', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501033961373' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501033961373';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Fresa 500 Pedialyte Sr60 Ml Abbott $ Fresa 500 Pedialyte Sr60 Abbott',
      'sku', 'FC-33961373',
      'codigo_barras', '7501033961373',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Fresa 500 Pedialyte Sr60 Ml Abbott $ Fresa 500 Pedialyte Sr60 Abbott — Ticket FL-080826',
      'costo', 23.81,
      'precio', 32.15,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-99',
      NULL::date,
      23.81,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501033961373', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501048335305' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501048335305';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Agua Oxigenada Dermocleen 480Ml | Degasa 15.00 Agua Oxigenada Dermocleen 480Ml',
      'sku', 'FC-48335305',
      'codigo_barras', '7501048335305',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Agua Oxigenada Dermocleen 480Ml | Degasa 15.00 Agua Oxigenada Dermocleen 480Ml — Ticket FL-080826',
      'costo', 14.7,
      'precio', 19.85,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-100',
      NULL::date,
      14.7,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501048335305', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501033954740' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501033954740';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Manzana 500 Ml Descto: 2.0% Pedialyte Manzana 500 Ml Pedialyte',
      'sku', 'FC-33954740',
      'codigo_barras', '7501033954740',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Manzana 500 Ml Descto: 2.0% Pedialyte Manzana 500 Ml Pedialyte — Ticket FL-080826',
      'costo', 23.81,
      'precio', 32.15,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-101',
      NULL::date,
      23.81,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501033954740', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501059225411' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501059225411';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Inder 360 Gf Descto: 2.0% Leche Nido Marcas Nestle Inder 360 Gf Leche Nido Marcas',
      'sku', 'FC-59225411',
      'codigo_barras', '7501059225411',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Inder 360 Gf Descto: 2.0% Leche Nido Marcas Nestle Inder 360 Gf Leche Nido Marcas — Ticket FL-080826',
      'costo', 74.19,
      'precio', 100.16,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-102',
      NULL::date,
      74.19,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501059225411', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75064751067711' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75064751067711';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '360 Gr | Marcas Descto: 2.0% Leche Nidal 1 Nestle $ 112.70 360 Gr | Marcas Leche Nidal 1 Nestle',
      'sku', 'FC-51067711',
      'codigo_barras', '75064751067711',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '360 Gr | Marcas Descto: 2.0% Leche Nidal 1 Nestle $ 112.70 360 Gr | Marcas Leche Nidal 1 Nestle — Ticket FL-080826',
      'costo', 112.7,
      'precio', 152.15,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-103',
      NULL::date,
      112.7,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75064751067711', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010586167151' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010586167151';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Nestum Probioticos Marcas Nestle Avena 270 Nestum Probioticos Marcas Nestle',
      'sku', 'FC-86167151',
      'codigo_barras', '75010586167151',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Nestum Probioticos Marcas Nestle Avena 270 Nestum Probioticos Marcas Nestle — Ticket FL-080826',
      'costo', 52.43,
      'precio', 70.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-104',
      NULL::date,
      52.43,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010586167151', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010592821171' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010592821171';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Nutri Rindes Leche Nido Marcas Nestle Bolsa 240 Gr Nutri Rindes Leche Nido Marcas Nestle',
      'sku', 'FC-92821171',
      'codigo_barras', '75010592821171',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Nutri Rindes Leche Nido Marcas Nestle Bolsa 240 Gr Nutri Rindes Leche Nido Marcas Nestle — Ticket FL-080826',
      'costo', 30.67,
      'precio', 41.41,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-105',
      NULL::date,
      30.67,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010592821171', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501058611420' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501058611420';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Nutri Rindes Leche Nido Marcas Nestle Bolsa Nutri Rindes Leche Nido',
      'sku', 'FC-58611420',
      'codigo_barras', '7501058611420',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Nutri Rindes Leche Nido Marcas Nestle Bolsa Nutri Rindes Leche Nido — Ticket FL-080826',
      'costo', 53.7,
      'precio', 72.5,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-106',
      NULL::date,
      53.7,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501058611420', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75064751078461' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75064751078461';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Öpt Imal Leche Nan 1 Marcas Pro Öpt Imal Leche Nan 1',
      'sku', 'FC-51078461',
      'codigo_barras', '75064751078461',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Öpt Imal Leche Nan 1 Marcas Pro Öpt Imal Leche Nan 1 — Ticket FL-080826',
      'costo', 129.4,
      'precio', 174.7,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-107',
      NULL::date,
      129.4,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75064751078461', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75064751078531' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75064751078531';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Öptimal Marcas Nestle Bolsa Leche Nan 2 Gr Öptimal Marcas Nestle Bolsa',
      'sku', 'FC-51078531',
      'codigo_barras', '75064751078531',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Öptimal Marcas Nestle Bolsa Leche Nan 2 Gr Öptimal Marcas Nestle Bolsa — Ticket FL-080826',
      'costo', 58.7,
      'precio', 79.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-108',
      NULL::date,
      58.7,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75064751078531', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75065529003221' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75065529003221';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Vaso Recolector I Quirmex Quirmex Descto: 2.0% $ 3.70 Recolector I Quirmex Quirmex',
      'sku', 'FC-29003221',
      'codigo_barras', '75065529003221',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Vaso Recolector I Quirmex Quirmex Descto: 2.0% $ 3.70 Recolector I Quirmex Quirmex — Ticket FL-080826',
      'costo', 3.7,
      'precio', 5.0,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-109',
      NULL::date,
      3.7,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75065529003221', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75011251448511' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75011251448511';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '525 Ml | Lab Pisa Electrolit Uva $ 20,50 Descto: 2.0% $ 20.09 525 Ml | Lab Pisa Electrolit Uva',
      'sku', 'FC-51448511',
      'codigo_barras', '75011251448511',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '525 Ml | Lab Pisa Electrolit Uva $ 20,50 Descto: 2.0% $ 20.09 525 Ml | Lab Pisa Electrolit Uva — Ticket FL-080826',
      'costo', 20.5,
      'precio', 27.68,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-110',
      NULL::date,
      20.5,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75011251448511', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501125104411' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501125104411';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Electrolit Coco 625 Ml Lab Pisa 20.50 Descto: 2.0% Electrolit Coco 625 Ml Pisa',
      'sku', 'FC-25104411',
      'codigo_barras', '7501125104411',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Electrolit Coco 625 Ml Lab Pisa 20.50 Descto: 2.0% Electrolit Coco 625 Ml Pisa — Ticket FL-080826',
      'costo', 20.09,
      'precio', 27.13,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-111',
      NULL::date,
      20.09,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501125104411', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501125149221' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501125149221';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Electrolit Eresa-Kiwi 625 Ml | Lab Pisa 2 20.50 Electrolit Eresa-Kiwi 625 Ml | Lab Pisa',
      'sku', 'FC-25149221',
      'codigo_barras', '7501125149221',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Electrolit Eresa-Kiwi 625 Ml | Lab Pisa 2 20.50 Electrolit Eresa-Kiwi 625 Ml | Lab Pisa — Ticket FL-080826',
      'costo', 20.09,
      'precio', 27.13,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-112',
      NULL::date,
      20.09,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501125149221', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501125104268' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501125104268';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Electrolit Èresa 625 Mi | Lab Pisa $ 20.50 Descto: 2.0K $ 20.09 [75011251747971 Electrolid Èresa 625 Mi | Lab Pisa',
      'sku', 'FC-25104268',
      'codigo_barras', '7501125104268',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Electrolit Èresa 625 Mi | Lab Pisa $ 20.50 Descto: 2.0K $ 20.09 [75011251747971 Electrolid Èresa 625 Mi | Lab Pisa — Ticket FL-080826',
      'costo', 20.5,
      'precio', 27.68,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-113',
      NULL::date,
      20.5,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501125104268', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75011251747971' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75011251747971';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Electrolid Mora Azul 625 Ml | Lab Pisa 2 $ 20.50 Descto: 2.0K $ 20.09 Mora Azul 625 Ml | Lab Pisa',
      'sku', 'FC-51747971',
      'codigo_barras', '75011251747971',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Electrolid Mora Azul 625 Ml | Lab Pisa 2 $ 20.50 Descto: 2.0K $ 20.09 Mora Azul 625 Ml | Lab Pisa — Ticket FL-080826',
      'costo', 20.5,
      'precio', 27.68,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-114',
      NULL::date,
      20.5,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75011251747971', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501943471900' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501943471900';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Absorsec C/120 Clark Descto: 2.0% Toa Hum Kimberly Absorsec C/120 Clark Toa Hum',
      'sku', 'FC-43471900',
      'codigo_barras', '7501943471900',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Absorsec C/120 Clark Descto: 2.0% Toa Hum Kimberly Absorsec C/120 Clark Toa Hum — Ticket FL-080826',
      'costo', 21.46,
      'precio', 28.98,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-115',
      NULL::date,
      21.46,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501943471900', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75030034064021' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75030034064021';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cotonetes Quirmex Tarro C/100 1 Quirmex 2 12.00 Cotonetes Quirmex Tarro C/100 1 Quirmex',
      'sku', 'FC-34064021',
      'codigo_barras', '75030034064021',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cotonetes Quirmex Tarro C/100 1 Quirmex 2 12.00 Cotonetes Quirmex Tarro C/100 1 Quirmex — Ticket FL-080826',
      'costo', 11.76,
      'precio', 15.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-116',
      NULL::date,
      11.76,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75030034064021', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502214983153' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502214983153';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Lubricante Prudence Grosella 75 Ml | Dkt Mexico $ 68.20 Lubricante Prudence Grosella 75 Ml | Dkt',
      'sku', 'FC-14983153',
      'codigo_barras', '7502214983153',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lubricante Prudence Grosella 75 Ml | Dkt Mexico $ 68.20 Lubricante Prudence Grosella 75 Ml | Dkt — Ticket FL-080826',
      'costo', 68.2,
      'precio', 92.07,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-117',
      NULL::date,
      68.2,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502214983153', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501943454811' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501943454811';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Toa -Hum Huggies Cuidado Puro C/80 | Kimberly Clark $ 39.60 Descto: 2.0K 9 Huggies Cuidado Puro C/80 | Kimberly Clark',
      'sku', 'FC-43454811',
      'codigo_barras', '7501943454811',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Toa -Hum Huggies Cuidado Puro C/80 | Kimberly Clark $ 39.60 Descto: 2.0K 9 Huggies Cuidado Puro C/80 | Kimberly Clark — Ticket FL-080826',
      'costo', 39.6,
      'precio', 53.47,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      9,
      'TK-FL-080826-118',
      NULL::date,
      39.6,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501943454811', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022149824391' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022149824391';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Retardante C/3 Descto: 9.0% [7502214985348] Cond Prudence ''Ull Retardante C/3',
      'sku', 'FC-49824391',
      'codigo_barras', '75022149824391',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Retardante C/3 Descto: 9.0% [7502214985348] Cond Prudence ''Ull Retardante C/3 — Ticket FL-080826',
      'costo', 48.6,
      'precio', 65.61,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-119',
      NULL::date,
      48.6,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022149824391', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

commit;

select 5 as lote_ok, 6 as lotes_total;

-- ============================================================================
-- CARGAR faltantes — FarmaLive + barcode (EJECUTAR 3 y 4)
-- 149 bloques · Aspirina, Bepanthen, Desenfriol, etc.
-- Lote 6/6 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;


do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502214985348' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502214985348';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cond Prudence ''Ull Sensitive C/3 Dkt Cond Prudence ''Ull Sensitive',
      'sku', 'FC-14985348',
      'codigo_barras', '7502214985348',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cond Prudence ''Ull Sensitive C/3 Dkt Cond Prudence ''Ull Sensitive — Ticket FL-080826',
      'costo', 41.31,
      'precio', 55.77,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-120',
      NULL::date,
      41.31,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502214985348', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022149853867' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022149853867';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cond Prudence Extra Pleasure C/3 Dkt Cond Prudence Extra Pleasure',
      'sku', 'FC-49853867',
      'codigo_barras', '75022149853867',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cond Prudence Extra Pleasure C/3 Dkt Cond Prudence Extra Pleasure — Ticket FL-080826',
      'costo', 41.31,
      'precio', 55.77,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-121',
      NULL::date,
      41.31,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022149853867', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022149824911' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022149824911';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cond Prudence Iva C/3 Dki Mexico S Cond Prudence Iva C/3 Mexico',
      'sku', 'FC-49824911',
      'codigo_barras', '75022149824911',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cond Prudence Iva C/3 Dki Mexico S Cond Prudence Iva C/3 Mexico — Ticket FL-080826',
      'costo', 31.03,
      'precio', 41.9,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-122',
      NULL::date,
      31.03,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022149824911', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502214985805' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502214985805';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cond Prudence Chicle C/E Idkt Cond Prudence Chicle',
      'sku', 'FC-14985805',
      'codigo_barras', '7502214985805',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cond Prudence Chicle C/E Idkt Cond Prudence Chicle — Ticket FL-080826',
      'costo', 44.23,
      'precio', 59.72,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-123',
      NULL::date,
      44.23,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502214985805', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502214983726' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502214983726';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Lubricante Prudence Natural 75 Ml Lubricante Prudence Natural',
      'sku', 'FC-14983726',
      'codigo_barras', '7502214983726',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lubricante Prudence Natural 75 Ml Lubricante Prudence Natural — Ticket FL-080826',
      'costo', 62.06,
      'precio', 83.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-124',
      NULL::date,
      62.06,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502214983726', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022149824771' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022149824771';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Fresa C/3 I Dkt Descto: 9.0% Cond Prudence Fresa I Dkt Cond Prudence',
      'sku', 'FC-49824771',
      'codigo_barras', '75022149824771',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Fresa C/3 I Dkt Descto: 9.0% Cond Prudence Fresa I Dkt Cond Prudence — Ticket FL-080826',
      'costo', 31.03,
      'precio', 41.9,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-125',
      NULL::date,
      31.03,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022149824771', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022358203691' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022358203691';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '0.9 Mt Hilo Dental Ğum Expanding Sunstar Americasi $ 18.90 Descto: 2.0% Hilo Dental Ğum Expanding Sunstar Americasi',
      'sku', 'FC-58203691',
      'codigo_barras', '75022358203691',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '0.9 Mt Hilo Dental Ğum Expanding Sunstar Americasi $ 18.90 Descto: 2.0% Hilo Dental Ğum Expanding Sunstar Americasi — Ticket FL-080826',
      'costo', 18.9,
      'precio', 25.52,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      22,
      'TK-FL-080826-126',
      NULL::date,
      18.9,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022358203691', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502214982514' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502214982514';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Chocolate C/3 Descto: 9.0% Cond Prudence Dkt Mexico $ 34.10 Chocolate C/3 Cond Prudence Dkt Mexico',
      'sku', 'FC-14982514',
      'codigo_barras', '7502214982514',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Chocolate C/3 Descto: 9.0% Cond Prudence Dkt Mexico $ 34.10 Chocolate C/3 Cond Prudence Dkt Mexico — Ticket FL-080826',
      'costo', 34.1,
      'precio', 46.04,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-127',
      NULL::date,
      34.1,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502214982514', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010545079011' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010545079011';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Eresa Pomada Labello Bde Merico $ 56.50 Descto: 2.0% Eresa Pomada Labello Bde Merico',
      'sku', 'FC-45079011',
      'codigo_barras', '75010545079011',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Eresa Pomada Labello Bde Merico $ 56.50 Descto: 2.0% Eresa Pomada Labello Bde Merico — Ticket FL-080826',
      'costo', 56.5,
      'precio', 76.28,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-128',
      NULL::date,
      56.5,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010545079011', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502214980596' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502214980596';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Mora C/3 Dkt Cond Prudence Mexico 34.10 Mora C/3 Cond Prudence Mexico',
      'sku', 'FC-14980596',
      'codigo_barras', '7502214980596',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Mora C/3 Dkt Cond Prudence Mexico 34.10 Mora C/3 Cond Prudence Mexico — Ticket FL-080826',
      'costo', 31.03,
      'precio', 41.9,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-129',
      NULL::date,
      31.03,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502214980596', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022149800151' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022149800151';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cond Prudence Clasico C/3 I Dkt Mexico 32.20 Descto: 9.0% Cond Prudence Clasico C/3 I Dkt Mexico',
      'sku', 'FC-49800151',
      'codigo_barras', '75022149800151',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cond Prudence Clasico C/3 I Dkt Mexico 32.20 Descto: 9.0% Cond Prudence Clasico C/3 I Dkt Mexico — Ticket FL-080826',
      'costo', 29.3,
      'precio', 39.56,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-130',
      NULL::date,
      29.3,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022149800151', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500462746605' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500462746605';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Jarabe 250 Ml 1 Nat Descto: 2.0% Ajolotius Bioal Imentos Jarabe 250 Ml 1 Ajolotius Bioal Imentos',
      'sku', 'FC-62746605',
      'codigo_barras', '7500462746605',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Jarabe 250 Ml 1 Nat Descto: 2.0% Ajolotius Bioal Imentos Jarabe 250 Ml 1 Ajolotius Bioal Imentos — Ticket FL-080826',
      'costo', 28.0,
      'precio', 37.81,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-131',
      NULL::date,
      28.0,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500462746605', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010545045281' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010545045281';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Pomada Labello Hydro-C I Bde Mexico $ 56.50 Descto: 2.0% $ 55.37 Pomada Labello Hydro-C I Bde Mexico',
      'sku', 'FC-45045281',
      'codigo_barras', '75010545045281',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Pomada Labello Hydro-C I Bde Mexico $ 56.50 Descto: 2.0% $ 55.37 Pomada Labello Hydro-C I Bde Mexico — Ticket FL-080826',
      'costo', 56.5,
      'precio', 76.28,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-132',
      NULL::date,
      56.5,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010545045281', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501054504870' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501054504870';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Pomada I.Abeili.C Lasico | Rde Mexic( 56.50 Descto: 2.0% $ 55.37 56.50 Lasico | Rde Mexic(',
      'sku', 'FC-54504870',
      'codigo_barras', '7501054504870',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Pomada I.Abeili.C Lasico | Rde Mexic( 56.50 Descto: 2.0% $ 55.37 56.50 Lasico | Rde Mexic( — Ticket FL-080826',
      'costo', 55.37,
      'precio', 74.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-133',
      NULL::date,
      55.37,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501054504870', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506452400212' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506452400212';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ajolotius Jengibre Tab C/10 Bioalimentos Nati Jengibre C/10 Bioalimentos',
      'sku', 'FC-52400212',
      'codigo_barras', '7506452400212',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Ajolotius Jengibre Tab C/10 Bioalimentos Nati Jengibre C/10 Bioalimentos — Ticket FL-080826',
      'costo', 20.5,
      'precio', 27.68,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-134',
      NULL::date,
      20.5,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506452400212', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75064524004581' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75064524004581';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ajolotius Pastillas Elderberry Past Bioalimentos Nat $ 21.00 Descto: 2.0% Ajolotius Pastillas Elderberry Past',
      'sku', 'FC-24004581',
      'codigo_barras', '75064524004581',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Ajolotius Pastillas Elderberry Past Bioalimentos Nat $ 21.00 Descto: 2.0% Ajolotius Pastillas Elderberry Past — Ticket FL-080826',
      'costo', 21.0,
      'precio', 28.35,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-135',
      NULL::date,
      21.0,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75064524004581', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75064256034041' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75064256034041';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Toa Hum Escudo Intbacterial C/50 $ Besbfrzy Clark 15.60 Toa Hum Escudo Intbacterial C/50 Besbfrzy Clark',
      'sku', 'FC-56034041',
      'codigo_barras', '75064256034041',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Toa Hum Escudo Intbacterial C/50 $ Besbfrzy Clark 15.60 Toa Hum Escudo Intbacterial C/50 Besbfrzy Clark — Ticket FL-080826',
      'costo', 15.29,
      'precio', 20.65,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-136',
      NULL::date,
      15.29,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75064256034041', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010221042481' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010221042481';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '1083 Oro Manzanilla Ml Hnos 31.40 Descto: 2.0% Oro Manzanilla Hnos',
      'sku', 'FC-21042481',
      'codigo_barras', '75010221042481',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '1083 Oro Manzanilla Ml Hnos 31.40 Descto: 2.0% Oro Manzanilla Hnos — Ticket FL-080826',
      'costo', 30.77,
      'precio', 41.54,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-137',
      NULL::date,
      30.77,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010221042481', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506452400267' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506452400267';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', ', Ajolotius Jbe Elderberry 2501 Bioalimentos Nati 74.70 $ $ 73.21 Elderberry 2501 Bioalimentos Nati',
      'sku', 'FC-52400267',
      'codigo_barras', '7506452400267',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', ', Ajolotius Jbe Elderberry 2501 Bioalimentos Nati 74.70 $ $ 73.21 Elderberry 2501 Bioalimentos Nati — Ticket FL-080826',
      'costo', 73.21,
      'precio', 98.84,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-138',
      NULL::date,
      73.21,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506452400267', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500462746612' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500462746612';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ajolotius Jarabe S/Azucar 250 Ml. I Bioalimentos Nati $ 89.20 $ 87.42 Ajolotius Jarabe S/Azucar 250 Ml. I Bioalimentos N',
      'sku', 'FC-62746612',
      'codigo_barras', '7500462746612',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Ajolotius Jarabe S/Azucar 250 Ml. I Bioalimentos Nati $ 89.20 $ 87.42 Ajolotius Jarabe S/Azucar 250 Ml. I Bioalimentos N — Ticket FL-080826',
      'costo', 89.2,
      'precio', 120.43,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-139',
      NULL::date,
      89.2,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500462746612', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506452400038' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506452400038';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ajolotius Menta Eucal S/Azucar Past Ajolotius Menta Eucal',
      'sku', 'FC-52400038',
      'codigo_barras', '7506452400038',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Ajolotius Menta Eucal S/Azucar Past Ajolotius Menta Eucal — Ticket FL-080826',
      'costo', 21.36,
      'precio', 28.84,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      8,
      'TK-FL-080826-140',
      NULL::date,
      21.36,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506452400038', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500462746698' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500462746698';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ajolotius Jarabe Reforzado 250 Ml Bioalimentos Nat: Ajolotius Jarabe Reforzado',
      'sku', 'FC-62746698',
      'codigo_barras', '7500462746698',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Ajolotius Jarabe Reforzado 250 Ml Bioalimentos Nat: Ajolotius Jarabe Reforzado — Ticket FL-080826',
      'costo', 7.45,
      'precio', 10.06,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      8,
      'TK-FL-080826-141',
      NULL::date,
      7.45,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500462746698', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010545307181' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010545307181';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Poroso Arnica Parche Leon Bde Poroso Arnica Parche',
      'sku', 'FC-45307181',
      'codigo_barras', '75010545307181',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Poroso Arnica Parche Leon Bde Poroso Arnica Parche — Ticket FL-080826',
      'costo', 149.35,
      'precio', 201.63,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-142',
      NULL::date,
      149.35,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010545307181', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500462746643' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500462746643';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ajolotius Menta Fucal C/10 Bioalimentos Ajolotius Menta Fucal',
      'sku', 'FC-62746643',
      'codigo_barras', '7500462746643',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Ajolotius Menta Fucal C/10 Bioalimentos Ajolotius Menta Fucal — Ticket FL-080826',
      'costo', 19.5,
      'precio', 26.33,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-143',
      NULL::date,
      19.5,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500462746643', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

commit;

select 6 as lote_ok, 6 as lotes_total;

-- Al terminar todos los lotes de este archivo:
select count(*) as productos_fc from public.productos where sku like 'FC-%';
