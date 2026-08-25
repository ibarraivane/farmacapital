-- ============================================================================
-- FARMA CAPITAL — Carga completa del lote 4 (fotos del 15-ago-2026)
--
-- ARCHIVO GENERADO. No lo edites a mano: se produce con
--   python3 scripts/generar_carga_lote4_completa.py
--
-- Este es el único script que hay que correr. Hace todo de corrido:
--
--   1. Guarda en public.carga_fotos_lote4 lo que se leyó de las fotos, para
--      que quede el registro de de dónde salió cada dato.
--   2. Respalda los productos que va a tocar.
--   3. Crea en public.productos todo lo que no exista, con su lote,
--      caducidad, costo y la cantidad que dice el ticket Equilibrio 440393.
--   4. A lo que ya exista sólo le completa el costo si venía en cero y le
--      agrega el lote si le faltaba. Nunca pisa un costo o precio capturado.
--   5. Recalcula el stock a partir de los lotes.
--
-- Los códigos de barras se decodificaron del código con OpenCV, no a ojo.
-- El costo, lote, caducidad y cantidad vienen del ticket de Equilibrio.
--
-- Se puede correr más de una vez: no duplica nada.
--
-- A propósito NO va dentro de una transacción: si algo falla a la mitad, lo
-- que ya se cargó se queda cargado y el error apunta al renglón exacto. Como
-- el script es idempotente, se vuelve a correr y continúa donde se quedó.
--
-- Al terminar, correr sql/pricing/004_apply_pricing_idempotente.sql para que
-- el motor de precios fije el precio de venta definitivo.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1) Lo que se leyó de las fotos
-- ---------------------------------------------------------------------------
create table if not exists public.carga_fotos_lote4 (
  ean           text primary key,
  nombre        text not null,
  presentacion  text,
  laboratorio   text,
  codigo_prov   text,
  lote          text,
  caducidad     date,
  costo         numeric(12,4),
  pmp_etiqueta  numeric(12,2),
  cantidad      integer not null default 1,
  confianza     text not null default 'alta',
  notas         text
);

truncate public.carga_fotos_lote4;

insert into public.carga_fotos_lote4
  (ean, nombre, presentacion, laboratorio, codigo_prov, lote, caducidad,
   costo, pmp_etiqueta, cantidad, confianza, notas)
values
{{RENGLONES}};

-- ---------------------------------------------------------------------------
-- 2) Respaldo de lo que este script podría modificar
-- ---------------------------------------------------------------------------
create table if not exists public.productos_backup_lote4_20260815 (
  backup_at     timestamptz not null default now(),
  producto_id   bigint primary key,
  sku           text,
  nombre        text,
  codigo_barras text,
  costo         numeric(10,2),
  precio        numeric(10,2),
  stock         integer
);

insert into public.productos_backup_lote4_20260815
  (producto_id, sku, nombre, codigo_barras, costo, precio, stock)
select p.id, p.sku, p.nombre, p.codigo_barras, p.costo, p.precio, p.stock
from public.productos p
join public.carga_fotos_lote4 c on c.ean = p.codigo_barras
on conflict (producto_id) do nothing;

-- ---------------------------------------------------------------------------
-- 3) Alta y actualización
-- ---------------------------------------------------------------------------
do $carga$
declare
  r             record;
  v_pid         bigint;
  v_sku         text;
  v_sufijo      integer;
  v_categoria   text;
  v_tipo        text;
  v_forma       text;
  v_pa          text;
  v_precio      numeric;
  v_activo      boolean;
  v_set         text;
  v_cols        text;
  v_vals        text;
  n_altas       integer := 0;
  n_costos      integer := 0;
  n_lotes       integer := 0;
  n_sin_precio  integer := 0;
begin
  for r in select * from public.carga_fotos_lote4 order by nombre loop
    -- Si algo truena, este aviso dice en qué producto fue.
    raise debug 'procesando % (%)', r.nombre, r.ean;

    -- --- Clasificación, para que el motor de precios sepa qué recargo usar ---
    v_categoria := case
      when r.nombre ~* '(playboy|jaloma|hisopo|sedal|vaselina|off!|barra labial|ricitos)' then 'Higiene'
      when r.nombre ~* '(voldratol|pedialyte|electrolito|suero)'                          then 'Hidratación'
      when r.nombre ~* '(ajolotius|omega|caltrón|caltron|redbelgy|vitamina|hemoger)'      then 'Suplemento'
      else 'Medicamentos'
    end;

    v_tipo := case when v_categoria = 'Medicamentos' then 'marca' else 'otro' end;

    v_forma := case
      when coalesce(r.presentacion, r.nombre) ~* 'crema'                       then 'Crema'
      when coalesce(r.presentacion, r.nombre) ~* '(ungüento|unguento|pomada)'  then 'Ungüento'
      when coalesce(r.presentacion, r.nombre) ~* 'gel'                         then 'Gel'
      when coalesce(r.presentacion, r.nombre) ~* 'gotas'                       then 'Gotas'
      when coalesce(r.presentacion, r.nombre) ~* 'jarabe'                      then 'Jarabe'
      when coalesce(r.presentacion, r.nombre) ~* '(suspensión|suspension)'     then 'Suspensión'
      when coalesce(r.presentacion, r.nombre) ~* '(solución|solucion)'         then 'Solución'
      when coalesce(r.presentacion, r.nombre) ~* '(cápsula|capsula)'           then 'Cápsula'
      when coalesce(r.presentacion, r.nombre) ~* '(tableta|gragea|comprimido)' then 'Tableta'
      when coalesce(r.presentacion, r.nombre) ~* 'supositorio'                 then 'Supositorio'
      when coalesce(r.presentacion, r.nombre) ~* '(aerosol|atomizador|spray)'  then 'Aerosol'
      when coalesce(r.presentacion, r.nombre) ~* '(polvo|sobre)'               then 'Polvo'
      when coalesce(r.presentacion, r.nombre) ~* 'parche'                      then 'Parche'
      when coalesce(r.presentacion, r.nombre) ~* 'condón|condon|preservativo'  then 'Condón'
      else null
    end;

    -- El principio activo casi siempre viene entre paréntesis en el nombre:
    -- "Sarox (Omeprazol) 20 mg".
    v_pa := nullif(btrim(substring(r.nombre from '\(([^)]+)\)')), '');

    -- --- Precio provisional ---
    -- La columna precio no acepta nulos. Si hay costo, se pone ceil(costo*1.6),
    -- que es justo el valor que el motor de precios reconoce como "todavía no
    -- lo ha tocado nadie a mano" y luego reemplaza por el de la regla.
    -- Si no hay costo no se puede calcular nada: entra en 0 y desactivado,
    -- para que aparezca en el inventario pero no se pueda vender por error.
    if coalesce(r.costo, 0) > 0 then
      v_precio := ceil(r.costo * 1.6);
      v_activo := true;
    else
      v_precio := 0;
      v_activo := false;
      n_sin_precio := n_sin_precio + 1;
    end if;

    -- --- ¿Ya existe con ese código de barras? ---
    select p.id into v_pid
    from public.productos p
    where p.codigo_barras = r.ean
    limit 1;

    if v_pid is not null then
      update public.productos
         set costo = r.costo
       where id = v_pid
         and r.costo is not null
         and coalesce(costo, 0) = 0;
      if found then
        n_costos := n_costos + 1;
      end if;
    else
      -- SKU derivado del código de barras, con sufijo si ya estuviera ocupado.
      v_sku := 'FC-' || right(r.ean, 8);
      v_sufijo := 0;
      while exists (select 1 from public.productos where sku = v_sku) loop
        v_sufijo := v_sufijo + 1;
        v_sku := 'FC-' || right(r.ean, 8) || '-' || v_sufijo;
      end loop;

      insert into public.productos
        (nombre, sku, codigo_barras, categoria, tipo, descripcion,
         costo, precio, stock, stock_minimo, activo, requiere_receta)
      values
        (r.nombre, v_sku, r.ean, v_categoria, v_tipo,
         concat_ws(' · ', r.nombre, r.presentacion, r.laboratorio, 'EAN ' || r.ean),
         r.costo, v_precio, 0, 1, v_activo, false)
      returning id into v_pid;

      n_altas := n_altas + 1;
    end if;

    -- --- Columnas que no todos los ambientes tienen: se arman en dinámico ---
    v_set := 'marca = coalesce(marca, ' || quote_nullable(r.laboratorio) || ')';
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'productos'
                 and column_name = 'presentacion') then
      v_set := v_set || ', presentacion = coalesce(presentacion, '
                     || quote_nullable(r.presentacion) || ')';
    end if;
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'productos'
                 and column_name = 'forma_farmaceutica') then
      v_set := v_set || ', forma_farmaceutica = coalesce(forma_farmaceutica, '
                     || quote_nullable(v_forma) || ')';
    end if;
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'productos'
                 and column_name = 'principio_activo') then
      v_set := v_set || ', principio_activo = coalesce(principio_activo, '
                     || quote_nullable(v_pa) || ')';
    end if;
    if r.codigo_prov is not null
       and exists (select 1 from information_schema.columns
                   where table_schema = 'public' and table_name = 'productos'
                     and column_name = 'proveedor') then
      v_set := v_set || ', proveedor = ' || quote_literal('EQUILIBRIO FARMACEUTICO');
    end if;
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'productos'
                 and column_name = 'price_needs_review') then
      -- Sin costo, o emparejamiento de fotos que quedó en duda: que el motor
      -- de precios no le ponga precio solo.
      v_set := v_set || ', price_needs_review = '
                     || case when coalesce(r.costo, 0) = 0 or r.confianza = 'media'
                             then 'true' else 'price_needs_review' end;
    end if;

    execute format('update public.productos set %s where id = %s', v_set, v_pid);

    -- --- Lote ---
    -- La tabla lotes no es igual en todos los ambientes (cantidad_inicial y
    -- activo existen en unos y en otros no), así que el insert se arma con las
    -- columnas que realmente estén.
    if r.lote is not null and not exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid and l.numero_lote = r.lote
    ) then
      v_cols := 'producto_id, numero_lote, cantidad_actual, fecha_caducidad, costo_unitario';
      v_vals := v_pid || ', ' || quote_literal(r.lote) || ', '
                || greatest(r.cantidad, 1) || ', '
                || coalesce(quote_literal(r.caducidad::text) || '::date', 'null') || ', '
                || coalesce(r.costo::text, 'null');

      if exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'lotes'
                   and column_name = 'cantidad_inicial') then
        v_cols := v_cols || ', cantidad_inicial';
        v_vals := v_vals || ', ' || greatest(r.cantidad, 1);
      end if;
      if exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'lotes'
                   and column_name = 'activo') then
        v_cols := v_cols || ', activo';
        v_vals := v_vals || ', true';
      end if;

      execute format('insert into public.lotes (%s) values (%s)', v_cols, v_vals);
      n_lotes := n_lotes + 1;
    end if;

  end loop;

  raise notice 'Productos nuevos creados: %', n_altas;
  raise notice 'Costos completados en productos que ya existían: %', n_costos;
  raise notice 'Lotes registrados: %', n_lotes;
  raise notice 'Sin costo en el ticket, quedaron desactivados: %', n_sin_precio;
end
$carga$;

-- ---------------------------------------------------------------------------
-- 4) Reactivar lo que se apagó por no tener costo y ahora sí lo tiene
--
-- En la primera versión de este script varios productos entraron sin costo
-- porque su línea del ticket no se había encontrado, y se quedaron apagados.
-- Al recuperar esos costos hay que volver a prenderlos.
-- ---------------------------------------------------------------------------
update public.productos p
set
  activo = true,
  precio = case when coalesce(p.precio, 0) = 0
                then ceil(p.costo * 1.6) else p.precio end
from public.carga_fotos_lote4 c
where p.codigo_barras = c.ean
  and p.activo is false
  and coalesce(p.costo, 0) > 0;

-- ---------------------------------------------------------------------------
-- 5) Stock = suma de los lotes activos
-- ---------------------------------------------------------------------------
update public.productos p
set stock = coalesce(t.total, 0)
from (
  select l.producto_id, sum(l.cantidad_actual) as total
  from public.lotes l
  where coalesce(l.activo, true)
  group by l.producto_id
) t
where p.id = t.producto_id
  and p.codigo_barras in (select ean from public.carga_fotos_lote4)
  and p.stock is distinct from coalesce(t.total, 0);

-- ---------------------------------------------------------------------------
-- 6) Verificación
-- ---------------------------------------------------------------------------
select
  count(*)                                            as renglones_del_lote,
  count(p.id)                                         as en_inventario,
  count(*) filter (where p.id is null)                as no_se_crearon,
  count(*) filter (where coalesce(p.costo, 0) > 0)    as con_costo,
  count(*) filter (where p.activo is false)           as desactivados_sin_costo
from public.carga_fotos_lote4 c
left join public.productos p on p.codigo_barras = c.ean;

-- Detalle producto por producto
select
  c.ean,
  p.sku,
  p.nombre,
  p.costo,
  p.precio,
  p.stock,
  p.activo,
  l.numero_lote,
  l.fecha_caducidad
from public.carga_fotos_lote4 c
left join public.productos p on p.codigo_barras = c.ean
left join public.lotes l     on l.producto_id = p.id and l.numero_lote = c.lote
order by p.activo nulls first, p.nombre;

-- Los que quedaron sin costo: captura el costo aquí y vuelve a activarlos
select
  c.ean,
  c.nombre,
  c.laboratorio,
  c.pmp_etiqueta as precio_impreso_en_el_empaque,
  'update public.productos set costo = ?, activo = true where codigo_barras = '''
    || c.ean || ''';' as sql_para_completar
from public.carga_fotos_lote4 c
where coalesce(c.costo, 0) = 0
order by c.nombre;
