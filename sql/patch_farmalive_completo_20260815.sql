-- ═══════════════════════════════════════════════════════════════════
-- FARMA LIVE FL-080826 — CARGA COMPLETA (UN SOLO PEGADO EN SUPABASE)
-- Idempotente: si el producto ya existe, no duplica.
-- Generado: scripts/generar_patch_farmalive_completo.py
-- ═══════════════════════════════════════════════════════════════════

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;

-- ── 1) Corregir barcodes OCR en productos que ya existían ──

-- FIX FC-00740024 → 650240007408 · Silka Medic Gel
UPDATE public.productos SET
  codigo_barras = '650240007408',
  nombre = 'Silka Medic Gel',
  marca = 'Silka',
  presentacion = 'Tubo 15 g',
  principio_activo = 'Terbinafina',
  forma_farmaceutica = 'GEL',
  descripcion = coalesce(nullif(btrim(descripcion), ''), 'OCR ticket: 65024000740024 → patch erróneo 6502400074024')
WHERE sku = 'FC-00740024'
  AND NOT EXISTS (
    SELECT 1 FROM public.productos o
    WHERE o.codigo_barras = '650240007408' AND o.id <> public.productos.id
  );

-- FIX FC-58715517 → 7501095409004 · Graneodin B Frambuesa
UPDATE public.productos SET
  codigo_barras = '7501095409004',
  nombre = 'Graneodin B Frambuesa',
  marca = 'Graneodin',
  presentacion = 'C/24 pastillas',
  principio_activo = 'Benzocaina',
  forma_farmaceutica = 'PASTILLAS',
  stock = 2,
  stock_unidades = 2,
  descripcion = coalesce(nullif(btrim(descripcion), ''), 'Ticket tenía 7501058715517 (otro sabor); físico frambuesa')
WHERE sku = 'FC-58715517'
  AND NOT EXISTS (
    SELECT 1 FROM public.productos o
    WHERE o.codigo_barras = '7501095409004' AND o.id <> public.productos.id
  );

-- FIX FC-08485316 → 7501008485316 · Tabcin efervescente C/12
UPDATE public.productos SET
  codigo_barras = '7501008485316',
  nombre = 'Tabcin efervescente C/12',
  marca = 'Tabcin',
  presentacion = 'C/12 tabletas efervescentes',
  principio_activo = 'Acido acetilsalicilico + Fenilefrina + Clorfenamina',
  forma_farmaceutica = 'Tabletas efervescentes',
  descripcion = coalesce(nullif(btrim(descripcion), ''), 'EAN caja azul; distinto de Noche/500/Active')
WHERE sku = 'FC-08485316'
  AND NOT EXISTS (
    SELECT 1 FROM public.productos o
    WHERE o.codigo_barras = '7501008485316' AND o.id <> public.productos.id
  );

-- FIX FC-01508201 → 7501088509773 · Antiflu-Des C/24
UPDATE public.productos SET
  codigo_barras = '7501088509773',
  nombre = 'Antiflu-Des C/24',
  marca = 'Antiflu-Des',
  presentacion = 'C/24 capsulas',
  principio_activo = 'Amantadina + Clorfenamina + Paracetamol',
  forma_farmaceutica = 'Capsulas',
  descripcion = coalesce(nullif(btrim(descripcion), ''), 'OCR ticket 525301508201 / 7505253015021; EAN Chinoin 7501088509773')
WHERE sku = 'FC-01508201'
  AND NOT EXISTS (
    SELECT 1 FROM public.productos o
    WHERE o.codigo_barras = '7501088509773' AND o.id <> public.productos.id
  );

-- ── 2) Productos del ticket (Genomma 65024…, OCR truncado, etc.) ──

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;


-- FL-080826 · xl-3 · 650240017100
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '650240017100' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '650240017100';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'XL-3 VR C/24',
      'sku', 'FC-40017100',
      'codigo_barras', '650240017100',
      'categoria', 'Producto',
      'tipo', 'GENERICO',
      'descripcion', 'XL-3 VR C/24 — Ticket FL-080826',
      'costo', 88.20,
      'precio', 119.07,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-1',
      NULL::date,
      88.20,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('650240017100', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · vitacilina bebe · 354312225164
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '354312225164' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '354312225164';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Vitacilina Bebé Pomada',
      'sku', 'FC-12225164',
      'codigo_barras', '354312225164',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Vitacilina Bebé Pomada — Ticket FL-080826',
      'costo', 53.70,
      'precio', 72.50,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-2',
      NULL::date,
      53.70,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('354312225164', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · vitacilina ung · 750022503405381
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '750022503405381' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '750022503405381';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Vitacilina Ungüento',
      'sku', 'FC-03405381',
      'codigo_barras', '750022503405381',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Vitacilina Ungüento — Ticket FL-080826',
      'costo', 23.06,
      'precio', 31.14,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-3',
      NULL::date,
      23.06,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('750022503405381', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · afrin spray · 75010506134531
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
      'nombre', 'Afrin Spray 20 ML',
      'sku', 'FC-06134531',
      'codigo_barras', '75010506134531',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Afrin Spray 20 ML — Ticket FL-080826',
      'costo', 75.46,
      'precio', 101.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-4',
      NULL::date,
      75.46,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010506134531', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · derma crema · 3543122250276
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '3543122250276' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '3543122250276';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Derman Crema 50 g 50 G',
      'sku', 'FC-22250276',
      'codigo_barras', '3543122250276',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Derman Crema 50 g 50 G — Ticket FL-080826',
      'costo', 44.69,
      'precio', 60.34,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-5',
      NULL::date,
      44.69,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('3543122250276', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · tribedoce · 75022088947797
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
      'nombre', 'Tribedoce C/30',
      'sku', 'FC-88947797',
      'codigo_barras', '75022088947797',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tribedoce C/30 — Ticket FL-080826',
      'costo', 17.64,
      'precio', 23.82,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      5,
      'TK-FL-080826-6',
      NULL::date,
      17.64,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022088947797', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · nasalub sol · 650240015366
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '650240015366' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '650240015366';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Nasalub Sol 30 ML',
      'sku', 'FC-40015366',
      'codigo_barras', '650240015366',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Nasalub Sol 30 ML — Ticket FL-080826',
      'costo', 83.32,
      'precio', 112.49,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-7',
      NULL::date,
      83.32,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('650240015366', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · next tac c/10 · 650240010538
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '650240010538' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '650240010538';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Next Tab C/10',
      'sku', 'FC-40010538',
      'codigo_barras', '650240010538',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Next Tab C/10 — Ticket FL-080826',
      'costo', 23.52,
      'precio', 31.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      4,
      'TK-FL-080826-8',
      NULL::date,
      23.52,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('650240010538', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · silka medic gel · 650240007408
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '650240007408' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '650240007408';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Silka Medic Gel Tubo 15 g',
      'sku', 'FC-40007408',
      'codigo_barras', '650240007408',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Silka Medic Gel Tubo 15 g — Ticket FL-080826',
      'costo', 80.56,
      'precio', 108.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-9',
      NULL::date,
      80.56,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('650240007408', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · tribedoce 5000 · 75015015371829601
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75015015371829601' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75015015371829601';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tribedoce 50000 Amp C/5',
      'sku', 'FC-71829601',
      'codigo_barras', '75015015371829601',
      'categoria', 'Medicamento',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tribedoce 50000 Amp C/5 — Ticket FL-080826',
      'costo', 73.11,
      'precio', 98.70,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-10',
      NULL::date,
      73.11,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75015015371829601', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · riopan sobres · 7507201092730451
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7507201092730451' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7507201092730451';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Riopan Sobres',
      'sku', 'FC-92730451',
      'codigo_barras', '7507201092730451',
      'categoria', 'Otro',
      'tipo', 'GENERICO',
      'descripcion', 'Riopan Sobres — Ticket FL-080826',
      'costo', 268.72,
      'precio', 362.78,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-11',
      NULL::date,
      268.72,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7507201092730451', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · aderogyl amp · 36647980596011
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '36647980596011' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '36647980596011';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Aderogyl Amp C/4',
      'sku', 'FC-80596011',
      'codigo_barras', '36647980596011',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Aderogyl Amp C/4 — Ticket FL-080826',
      'costo', 96.92,
      'precio', 130.85,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-12',
      NULL::date,
      96.92,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('36647980596011', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · tempra forte · 75010954525051
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010954525051' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010954525051';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tempra Forte 50 MG C/24',
      'sku', 'FC-54525051',
      'codigo_barras', '75010954525051',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tempra Forte 50 MG C/24 — Ticket FL-080826',
      'costo', 113.93,
      'precio', 153.81,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-13',
      NULL::date,
      113.93,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010954525051', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · tukol-d adto · 650240010712
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '650240010712' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '650240010712';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tukol-D Jbe 125 ML',
      'sku', 'FC-40010712',
      'codigo_barras', '650240010712',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tukol-D Jbe 125 ML — Ticket FL-080826',
      'costo', 117.42,
      'precio', 158.52,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-14',
      NULL::date,
      117.42,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('650240010712', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · genoprasol tab · 650240036354
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '650240036354' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '650240036354';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Genoprazol Tab',
      'sku', 'FC-40036354',
      'codigo_barras', '650240036354',
      'categoria', 'Otro',
      'tipo', 'GENERICO',
      'descripcion', 'Genoprazol Tab — Ticket FL-080826',
      'costo', 24.50,
      'precio', 33.08,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-15',
      NULL::date,
      24.50,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('650240036354', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · condon sico rojo feel · 75010583683367
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010583683367' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010583683367';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Condón Sico Rojo Feel C/3',
      'sku', 'FC-83683367',
      'codigo_barras', '75010583683367',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Condón Sico Rojo Feel C/3 — Ticket FL-080826',
      'costo', 54.71,
      'precio', 73.86,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-16',
      NULL::date,
      54.71,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010583683367', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · tabcin 500 · 7501008485408
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008485408' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008485408';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tabcin 500 C/12 C/12 caps',
      'sku', 'FC-08485408',
      'codigo_barras', '7501008485408',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tabcin 500 C/12 C/12 caps — Ticket FL-080826',
      'costo', 46.06,
      'precio', 62.19,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-17',
      NULL::date,
      46.06,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008485408', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · tabcin active · 7501008499689
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008499689' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008499689';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tabcin Active C/12 C/12 caps',
      'sku', 'FC-08499689',
      'codigo_barras', '7501008499689',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tabcin Active C/12 C/12 caps — Ticket FL-080826',
      'costo', 70.60,
      'precio', 95.31,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-18',
      NULL::date,
      70.60,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008499689', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · fazolin f gotas · 780083146207
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '780083146207' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '780083146207';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Fazolin F Gotas 15 ML',
      'sku', 'FC-83146207',
      'codigo_barras', '780083146207',
      'categoria', 'Medicamento',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Fazolin F Gotas 15 ML — Ticket FL-080826',
      'costo', 26.85,
      'precio', 36.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-19',
      NULL::date,
      26.85,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('780083146207', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · syncolmax · 7501210734092301
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501210734092301' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501210734092301';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Syncol Max Tab',
      'sku', 'FC-34092301',
      'codigo_barras', '7501210734092301',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Syncol Max Tab — Ticket FL-080826',
      'costo', 88.69,
      'precio', 119.74,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-20',
      NULL::date,
      88.69,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501210734092301', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · graneodin b frambuesa · 7501095409004
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501095409004' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501095409004';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Graneodin B Frambuesa C/24',
      'sku', 'FC-95409004',
      'codigo_barras', '7501095409004',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Graneodin B Frambuesa C/24 — Ticket FL-080826',
      'costo', 42.64,
      'precio', 57.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-21',
      NULL::date,
      42.64,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501095409004', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · alka-seltzer boost 10 · 7501008497593
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008497593' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008497593';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Alka-Seltzer Boost C/10 C/10',
      'sku', 'FC-08497593',
      'codigo_barras', '7501008497593',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Alka-Seltzer Boost C/10 C/10 — Ticket FL-080826',
      'costo', 42.00,
      'precio', 56.70,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-22',
      NULL::date,
      42.00,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008497593', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · antifludes · 7501088509773
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501088509773' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501088509773';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Antiflu-Des C/24 caps',
      'sku', 'FC-88509773',
      'codigo_barras', '7501088509773',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Antiflu-Des C/24 caps — Ticket FL-080826',
      'costo', 149.35,
      'precio', 201.63,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-23',
      NULL::date,
      149.35,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501088509773', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · alka-seltzer boost tab · 75010084999001
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
      'nombre', 'Alka-Seltzer Boost C/50',
      'sku', 'FC-84999001',
      'codigo_barras', '75010084999001',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Alka-Seltzer Boost C/50 — Ticket FL-080826',
      'costo', 170.52,
      'precio', 230.21,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-24',
      NULL::date,
      170.52,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010084999001', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · tempra jbe · 75012501050724298
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75012501050724298' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75012501050724298';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tempra Jbe 120 ML',
      'sku', 'FC-50724298',
      'codigo_barras', '75012501050724298',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tempra Jbe 120 ML — Ticket FL-080826',
      'costo', 166.19,
      'precio', 224.36,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-25',
      NULL::date,
      166.19,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75012501050724298', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · pharmaton complete · 3664798062229
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '3664798062229' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '3664798062229';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Pharmaton Complete C/30',
      'sku', 'FC-98062229',
      'codigo_barras', '3664798062229',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Pharmaton Complete C/30 — Ticket FL-080826',
      'costo', 118.00,
      'precio', 159.31,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-26',
      NULL::date,
      118.00,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('3664798062229', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · pisacaina · 7501125112881
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501125112881' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501125112881';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Pisacaina 2% Sol 50 ml 50 ml',
      'sku', 'FC-25112881',
      'codigo_barras', '7501125112881',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Pisacaina 2% Sol 50 ml 50 ml — Ticket FL-080826',
      'costo', 85.00,
      'precio', 114.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-27',
      NULL::date,
      85.00,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501125112881', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · redoxon 2pack · 7501008421321
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008421321' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008421321';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Redoxon 1g 2-pack 2x10 tab',
      'sku', 'FC-08421321',
      'codigo_barras', '7501008421321',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Redoxon 1g 2-pack 2x10 tab — Ticket FL-080826',
      'costo', 130.00,
      'precio', 175.50,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-28',
      NULL::date,
      130.00,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008421321', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · eucaliptine · 7501159525015
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501159525015' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501159525015';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Eucaliptine Jarabe 140 ml',
      'sku', 'FC-59525015',
      'codigo_barras', '7501159525015',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Eucaliptine Jarabe 140 ml — Ticket FL-080826',
      'costo', 107.00,
      'precio', 144.46,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-29',
      NULL::date,
      107.00,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501159525015', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · tabcin noche · 7501008499702
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008499702' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008499702';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tabcin Noche C/12 caps',
      'sku', 'FC-08499702',
      'codigo_barras', '7501008499702',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tabcin Noche C/12 caps — Ticket FL-080826',
      'costo', 71.21,
      'precio', 96.14,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-30',
      NULL::date,
      71.21,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008499702', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · motrin infantil · 7501007535494
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501007535494' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501007535494';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Motrin Infantil Susp 120 ml 120 ml frutas',
      'sku', 'FC-07535494',
      'codigo_barras', '7501007535494',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Motrin Infantil Susp 120 ml 120 ml frutas — Ticket FL-080826',
      'costo', 186.40,
      'precio', 251.64,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-31',
      NULL::date,
      186.40,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501007535494', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · sedalmerck max · 7501298215099
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501298215099' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501298215099';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sedalmerck Max C/24 tab',
      'sku', 'FC-98215099',
      'codigo_barras', '7501298215099',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sedalmerck Max C/24 tab — Ticket FL-080826',
      'costo', 122.06,
      'precio', 164.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-32',
      NULL::date,
      122.06,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501298215099', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · topron · 7501088579615
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501088579615' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501088579615';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Topron C/16 400 mg C/16 caps',
      'sku', 'FC-88579615',
      'codigo_barras', '7501088579615',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Topron C/16 400 mg C/16 caps — Ticket FL-080826',
      'costo', 153.47,
      'precio', 207.19,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-33',
      NULL::date,
      153.47,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501088579615', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · brunadol · 7501537103521
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501537103521' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501537103521';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Brunadol C/10 C/10 tab',
      'sku', 'FC-37103521',
      'codigo_barras', '7501537103521',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Brunadol C/10 C/10 tab — Ticket FL-080826',
      'costo', 19.31,
      'precio', 26.07,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      4,
      'TK-FL-080826-34',
      NULL::date,
      19.31,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501537103521', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;

-- FL-080826 · veridex · 7502209747366
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502209747366' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502209747366';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Veridex C/4 6 mg C/4 tab',
      'sku', 'FC-09747366',
      'codigo_barras', '7502209747366',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Veridex C/4 6 mg C/4 tab — Ticket FL-080826',
      'costo', 75.46,
      'precio', 101.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-35',
      NULL::date,
      75.46,
      null::bigint,
      null::text) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502209747366', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  end if;
end $$;
-- ── 3) Altas verificadas en empaque (Topron, Brunadol, Veridex) ──

-- Altas Farmalive FL-080826 que el OCR no cargó bien (barcodes truncados / líneas mezcladas)
-- Ejecutar UNA vez en Supabase SQL Editor (Cmd+A del archivo completo)
--
-- 1) Topron C/16      · 7501088579615 · Chinoin
-- 2) Brunadol C/10    · 7501537103521 · Bruluart
-- 3) Veridex C/4 6 mg · 7502209747366 · Maver

-- ── 1) Topron ──
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08579615' OR codigo_barras = '7501088579615' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Topron C/16 400 mg',
        'sku', 'FC-08579615',
        'codigo_barras', '7501088579615',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Topron Nifuroxazida 400 mg 16 caps — Chinoin EAN 7501088579615',
        'costo', 153.47,
        'precio', 251.40,
        'stock_minimo', 2,
        'activo', true,
        'requiere_receta', false
      ),
      1, '8FB077', '2028-02-28'::date, 153.47, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Topron',
      presentacion = 'C/16 capsulas 400 mg',
      principio_activo = 'Nifuroxazida 400 mg',
      forma_farmaceutica = 'Capsulas',
      subcategoria = 'Antidiarreico',
      proveedor = 'Chinoin'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501088579615',
      nombre = 'Topron C/16 400 mg',
      marca = 'Topron',
      presentacion = 'C/16 capsulas 400 mg',
      principio_activo = 'Nifuroxazida 400 mg',
      forma_farmaceutica = 'Capsulas',
      categoria = 'Medicamentos',
      costo = 153.47,
      precio = 251.40,
      stock = greatest(coalesce(stock, 0), 1),
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- ── 2) Brunadol ──
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-103521' OR codigo_barras = '7501537103521' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Brunadol C/10',
        'sku', 'FC-103521',
        'codigo_barras', '7501537103521',
        'categoria', 'Medicamentos',
        'tipo', 'generico',
        'descripcion', 'Brunadol Paracetamol 300 mg + Naproxeno 275 mg 10 tab — Bruluart',
        'costo', 19.31,
        'precio', 72.00,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      4, '604188', '2028-04-06'::date, 19.31, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Brunadol',
      presentacion = 'C/10 tabletas',
      principio_activo = 'Paracetamol 300 mg + Naproxeno 275 mg',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Analgesico / antipiretico / antinflamatorio',
      proveedor = 'Bruluart'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501537103521',
      nombre = 'Brunadol C/10',
      marca = 'Brunadol',
      presentacion = 'C/10 tabletas',
      principio_activo = 'Paracetamol 300 mg + Naproxeno 275 mg',
      forma_farmaceutica = 'Tabletas',
      categoria = 'Medicamentos',
      tipo = 'generico',
      costo = 19.31,
      precio = 72.00,
      stock = greatest(coalesce(stock, 0), 4),
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- ── 3) Veridex ──
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-9747366' OR codigo_barras = '7502209747366' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Veridex C/4 6 mg',
        'sku', 'FC-9747366',
        'codigo_barras', '7502209747366',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Veridex Ivermectina 6 mg 4 tab — Maver EAN 7502209747366',
        'costo', 75.46,
        'precio', 360.00,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', true
      ),
      1, '261181', '2028-02-28'::date, 75.46, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Veridex',
      presentacion = 'C/4 tabletas 6 mg',
      principio_activo = 'Ivermectina 6 mg',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Antiparasitario',
      proveedor = 'Maver',
      requiere_receta = true
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7502209747366',
      nombre = 'Veridex C/4 6 mg',
      marca = 'Veridex',
      presentacion = 'C/4 tabletas 6 mg',
      principio_activo = 'Ivermectina 6 mg',
      forma_farmaceutica = 'Tabletas',
      categoria = 'Medicamentos',
      costo = 75.46,
      precio = 360.00,
      requiere_receta = true,
      stock = greatest(coalesce(stock, 0), 1),
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- Verificación: deben ser 3 filas
SELECT p.sku, p.nombre, p.codigo_barras, p.costo, p.precio, p.stock,
       p.requiere_receta, l.numero_lote, l.fecha_caducidad, l.cantidad_actual
FROM public.productos p
LEFT JOIN public.lotes l ON l.producto_id = p.id AND coalesce(l.activo, true) = true
WHERE p.codigo_barras IN (
  '7501088579615',
  '7501537103521',
  '7502209747366'
)
ORDER BY p.nombre;
-- ── 4) Línea Tabcin (4 EAN distintos) ──

-- Línea Tabcin Bayer: 4 variantes con EAN distintos
-- Ejecutar en Supabase SQL Editor (copiar archivo completo, Cmd+A)
--
-- Ya existía: FC-08485316 eferv (7501008485316), posible FC-08499702 noche
-- Altas: Tabcin 500 (7501008485408), Tabcin Active (7501008499689)

-- 1) Corregir Tabcin efervescente (existía con nombre/presentación OCR)
UPDATE public.productos SET
  codigo_barras = '7501008485316',
  nombre = 'Tabcin efervescente C/12',
  marca = 'Tabcin',
  presentacion = 'C/12 tabletas efervescentes',
  principio_activo = 'Acido acetilsalicilico + Fenilefrina + Clorfenamina',
  forma_farmaceutica = 'Tabletas efervescentes',
  categoria = 'Medicamentos',
  tipo = 'marca',
  subcategoria = 'Antigripal',
  costo = 37.73,
  precio = 49.05,
  activo = true
WHERE sku = 'FC-08485316';

-- 2) Tabcin Noche · 7501008499702
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08499702' OR codigo_barras = '7501008499702' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Tabcin Noche C/12',
        'sku', 'FC-08499702',
        'codigo_barras', '7501008499702',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Tabcin Noche C/12 — EAN 7501008499702',
        'costo', 71.21,
        'precio', 96.14,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0, NULL, NULL, 71.21, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Tabcin',
      presentacion = 'C/12 capsulas',
      principio_activo = 'Paracetamol + Fenilefrina + Dextrometorfano + Doxilamina',
      forma_farmaceutica = 'Capsulas',
      subcategoria = 'Antigripal / noche'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008499702',
      nombre = 'Tabcin Noche C/12',
      marca = 'Tabcin',
      presentacion = 'C/12 capsulas',
      principio_activo = 'Paracetamol + Fenilefrina + Dextrometorfano + Doxilamina',
      forma_farmaceutica = 'Capsulas',
      categoria = 'Medicamentos',
      costo = 71.21,
      precio = 96.14,
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- 3) Tabcin 500 · 7501008485408 · ticket $46.06/caja
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08485408' OR codigo_barras = '7501008485408' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Tabcin 500 C/12',
        'sku', 'FC-08485408',
        'codigo_barras', '7501008485408',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Tabcin 500 C/12 — EAN 7501008485408',
        'costo', 46.06,
        'precio', 62.19,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0, NULL, NULL, 46.06, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Tabcin',
      presentacion = 'C/12 capsulas',
      principio_activo = 'Paracetamol + Amantadina + Clorfenamina + Fenilefrina',
      forma_farmaceutica = 'Capsulas',
      subcategoria = 'Antigripal'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008485408',
      nombre = 'Tabcin 500 C/12',
      costo = 46.06,
      precio = 62.19,
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- 4) Tabcin Active · 7501008499689 · Exprezo $70.60
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08499689' OR codigo_barras = '7501008499689' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Tabcin Active C/12',
        'sku', 'FC-08499689',
        'codigo_barras', '7501008499689',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Tabcin Active C/12 — EAN 7501008499689',
        'costo', 70.60,
        'precio', 95.31,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      0, NULL, NULL, 70.60, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Tabcin',
      presentacion = 'C/12 capsulas',
      principio_activo = 'Paracetamol + Fenilefrina + Dextrometorfano + Guaifenesina',
      forma_farmaceutica = 'Capsulas',
      subcategoria = 'Antigripal / tos'
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008499689',
      nombre = 'Tabcin Active C/12',
      costo = 70.60,
      precio = 95.31,
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- Verificación (deben ser 4 filas, barcodes distintos)
SELECT sku, nombre, codigo_barras, costo, precio, stock, activo
FROM public.productos
WHERE codigo_barras IN (
  '7501008485316',
  '7501008499702',
  '7501008485408',
  '7501008499689'
)
ORDER BY nombre;
-- ── 5) Otros del anaquel no listados en ticket OCR ──

-- INSERT FC-85278507 · 0736085278507 · Manzanilla Sophia Solucion 15 ml
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-85278507' OR codigo_barras = '0736085278507' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Manzanilla Sophia Solucion 15 ml',
        'sku', 'FC-85278507',
        'codigo_barras', '0736085278507',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Manzanilla Sophia Solucion 15 ml — alta canonica EAN 0736085278507',
        'costo', 63.41,
        'precio', 85.61,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      1, NULL, NULL, 63.41, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Sophia',
      presentacion = 'Frasco 15 ml',
      principio_activo = 'Manzanilla (Matricaria chamomilla)',
      forma_farmaceutica = 'Solucion oral',
      subcategoria = 'Digestivo / calmante',
      stock = 1,
      stock_unidades = 1
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '0736085278507',
      nombre = 'Manzanilla Sophia Solucion 15 ml',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-08499818 · 7501008499818 · Aspirina 500 mg C/80
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08499818' OR codigo_barras = '7501008499818' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Aspirina 500 mg C/80',
        'sku', 'FC-08499818',
        'codigo_barras', '7501008499818',
        'categoria', 'Medicamentos',
        'tipo', 'marca',
        'descripcion', 'Aspirina 500 mg C/80 — alta canonica EAN 7501008499818',
        'costo', 61.15,
        'precio', 82.56,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      2, NULL, NULL, 61.15, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Aspirina',
      presentacion = 'C/80 tabletas 500 mg',
      principio_activo = 'Acido acetilsalicilico 500 mg',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Analgesico / antipiretico',
      stock = 2,
      stock_unidades = 2
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008499818',
      nombre = 'Aspirina 500 mg C/80',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-08443033 · 7501008443033 · Alka-Seltzer C/12 alivio rapido
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-08443033' OR codigo_barras = '7501008443033' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Alka-Seltzer C/12 alivio rapido',
        'sku', 'FC-08443033',
        'codigo_barras', '7501008443033',
        'categoria', 'Otro',
        'tipo', 'marca',
        'descripcion', 'Alka-Seltzer C/12 alivio rapido — alta canonica EAN 7501008443033',
        'costo', 39.00,
        'precio', 52.65,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      2, NULL, NULL, 39.00, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Alka-Seltzer',
      presentacion = 'C/12 tabletas efervescentes',
      principio_activo = 'Acido acetilsalicilico + Bicarbonato + Citrico',
      forma_farmaceutica = 'Tabletas efervescentes',
      subcategoria = 'Antiacido / analgesico',
      stock = 2,
      stock_unidades = 2
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7501008443033',
      nombre = 'Alka-Seltzer C/12 alivio rapido',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

-- INSERT FC-46642073 · 7502246642073 · Microdacyn Solucion 60 ml
DO $$
DECLARE v_pid bigint; v_lid bigint;
BEGIN
  SELECT id INTO v_pid FROM public.productos
  WHERE sku = 'FC-46642073' OR codigo_barras = '7502246642073' LIMIT 1;
  IF v_pid IS NULL THEN
    SELECT f.producto_id, f.lote_id INTO v_pid, v_lid
    FROM public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Microdacyn Solucion 60 ml',
        'sku', 'FC-46642073',
        'codigo_barras', '7502246642073',
        'categoria', 'Botiquín',
        'tipo', 'marca',
        'descripcion', 'Microdacyn Solucion 60 ml — alta canonica EAN 7502246642073',
        'costo', 114.66,
        'precio', 154.80,
        'stock_minimo', 3,
        'activo', true,
        'requiere_receta', false
      ),
      1, NULL, NULL, 114.66, NULL
    ) f;
    UPDATE public.productos SET
      marca = 'Microdacyn',
      presentacion = 'Frasco 60 ml',
      principio_activo = 'Acido hipocloroso / solucion antiseptica',
      forma_farmaceutica = 'Solucion topica',
      subcategoria = 'Antiseptico / curacion de heridas',
      stock = 1,
      stock_unidades = 1
    WHERE id = v_pid;
  ELSE
    UPDATE public.productos SET
      codigo_barras = '7502246642073',
      nombre = 'Microdacyn Solucion 60 ml',
      activo = true
    WHERE id = v_pid;
  END IF;
END $$;

commit;

-- Verificación: cuenta por barcode clave del ticket + fotos
SELECT p.sku, p.nombre, p.codigo_barras, p.stock, p.precio, p.activo
FROM public.productos p
WHERE p.codigo_barras IN (
  '0736085278507',
  '3543122250276',
  '354312225164',
  '36647980596011',
  '3664798062229',
  '650240007408',
  '650240010538',
  '650240010712',
  '650240015366',
  '6502400170941',
  '650240017100',
  '6502400315021',
  '650240036354',
  '6502400525451',
  '750022503405381',
  '7501007535494',
  '7501008421321',
  '7501008427330',
  '7501008443033',
  '7501008485316',
  '7501008485408',
  '7501008497593',
  '7501008499689',
  '7501008499702',
  '7501008499818',
  '75010084999001',
  '75010506134531',
  '7501058367129',
  '75010583683367',
  '7501064560163',
  '7501088509773',
  '7501088579615',
  '7501095409004',
  '75010954525051',
  '7501125112881',
  '7501159525015',
  '7501210734092301',
  '75012501050724298',
  '7501298215099',
  '7501312250181',
  '7501369200016',
  '75015015371829601',
  '7501537103521',
  '7501685171118',
  '75022088947797',
  '7502209747366',
  '7502246642073',
  '7502250343072',
  '75029650608272',
  '7503050071598',
  '7503854221482',
  '7507201092730451',
  '7509854054221',
  '780083146207'
)
ORDER BY p.nombre;

