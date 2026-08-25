-- ============================================================================
-- FARMA CAPITAL — Carga del ticket Equilibrio 440393 completo
--
-- ARCHIVO GENERADO. Se produce con
--   python3 scripts/generar_carga_ticket_equilibrio.py
--
-- Mete al inventario las 481 líneas del ticket con su nombre, costo, lote,
-- caducidad y cantidad. Sin código de barras: eso se completa después con las
-- fotos, y el código de proveedor queda guardado para poder empatarlas.
--
-- Para cada línea decide sola entre tres caminos:
--
--   · Ya la cubrió el lote 4 (mismo código de proveedor y lote)  -> no la toca.
--   · Hay un único producto en el catálogo cuyo nombre empieza igual
--     -> le agrega el lote y le completa el costo si venía en cero.
--   · No hay ninguno                                             -> lo crea.
--   · Hay varios candidatos                                      -> no toca
--     nada y lo reporta al final, para decidirlo a mano.
--
-- Ese último caso es a propósito: si en el catálogo hay un BACTIVER en
-- tabletas y otro en suspensión, adivinar cuál es sería peor que dejarlo.
--
-- No va dentro de una transacción, para que un error a la mitad no deshaga lo
-- que ya se cargó. Es idempotente: se puede correr varias veces.
--
-- Al terminar, correr sql/pricing/004_apply_pricing_idempotente.sql.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 0) El orden importa: primero el lote 4
--
-- Las 88 líneas que ya trajeron foto y código de barras tienen que estar
-- cargadas antes, o este script las volvería a crear sin código y quedarían
-- duplicadas.
-- ---------------------------------------------------------------------------
do $pre$
begin
  if to_regclass('public.carga_fotos_lote4') is null then
    raise exception
      'Corre primero sql/CARGA_LOTE4_COMPLETA.sql. Sin esa tabla no puedo saber qué líneas ya tienen código de barras y se crearían productos duplicados.';
  end if;
end
$pre$;

-- ---------------------------------------------------------------------------
-- 1) El ticket tal como viene
-- ---------------------------------------------------------------------------
create table if not exists public.ticket_equilibrio_440393 (
  id             bigserial primary key,
  pagina         integer,
  codigo_prov    text not null,
  descripcion    text not null,
  lote           text,
  caducidad      date,
  cantidad       integer not null default 1,
  precio_lista   numeric(12,2),
  costo_unitario numeric(12,4),
  subtotal       numeric(12,2),
  total          numeric(12,2)
);

create index if not exists ticket_equilibrio_440393_prov_idx
  on public.ticket_equilibrio_440393 (codigo_prov, lote);

truncate public.ticket_equilibrio_440393 restart identity;

insert into public.ticket_equilibrio_440393
  (pagina, codigo_prov, descripcion, lote, caducidad, cantidad,
   precio_lista, costo_unitario, subtotal, total)
values
{{RENGLONES}};

-- ---------------------------------------------------------------------------
-- 2) Respaldo de lo que se pueda modificar
-- ---------------------------------------------------------------------------
create table if not exists public.productos_backup_ticket440393 (
  backup_at     timestamptz not null default now(),
  producto_id   bigint primary key,
  sku           text,
  nombre        text,
  costo         numeric(10,2),
  precio        numeric(10,2),
  stock         integer
);

-- ---------------------------------------------------------------------------
-- 3) Carga
-- ---------------------------------------------------------------------------
do $carga$
declare
  r              record;
  v_pid          bigint;
  v_marca        text;
  v_nombre       text;
  v_sku          text;
  v_sufijo       integer;
  v_cand         bigint[];
  v_cols         text;
  v_vals         text;
  v_set          text;
  v_hay_lote4    boolean;
  n_saltadas     integer := 0;
  n_altas        integer := 0;
  n_ligadas      integer := 0;
  n_lotes        integer := 0;
  n_ambiguas     integer := 0;
begin
  v_hay_lote4 := to_regclass('public.carga_fotos_lote4') is not null;

  for r in select * from public.ticket_equilibrio_440393 order by pagina, id loop

    -- --- ¿Ya la trajo el lote 4, con foto y código de barras? ---
    if v_hay_lote4 and exists (
      select 1 from public.carga_fotos_lote4 c
      where c.codigo_prov = r.codigo_prov
        and coalesce(c.lote, '') = coalesce(r.lote, '')
    ) then
      n_saltadas := n_saltadas + 1;
      continue;
    end if;

    -- --- Marca: la primera palabra larga de la descripción ---
    v_marca := (
      select p from unnest(string_to_array(
               upper(translate(r.descripcion,
                               'ÁÉÍÓÚÜÑáéíóúüñ', 'AEIOUUNAEIOUUN')), ' ')) p
      where length(p) >= 4 and p ~ '^[A-Z]'
      limit 1
    );

    -- --- ¿Existe ya en el catálogo? ---
    v_cand := '{}';
    if v_marca is not null then
      select array_agg(p.id) into v_cand
      from public.productos p
      where upper(translate(p.nombre, 'ÁÉÍÓÚÜÑáéíóúüñ', 'AEIOUUNAEIOUUN'))
            like v_marca || '%';
    end if;

    if coalesce(array_length(v_cand, 1), 0) > 1 then
      -- Varios candidatos: no adivinar. Sale en el reporte final.
      n_ambiguas := n_ambiguas + 1;
      continue;
    end if;

    if coalesce(array_length(v_cand, 1), 0) = 1 then
      v_pid := v_cand[1];

      insert into public.productos_backup_ticket440393
        (producto_id, sku, nombre, costo, precio, stock)
      select p.id, p.sku, p.nombre, p.costo, p.precio, p.stock
      from public.productos p where p.id = v_pid
      on conflict (producto_id) do nothing;

      update public.productos
         set costo  = r.costo_unitario,
             precio = case when coalesce(precio, 0) = 0
                           then ceil(r.costo_unitario * 1.6) else precio end
       where id = v_pid
         and coalesce(costo, 0) = 0;
      if found then
        n_ligadas := n_ligadas + 1;
      end if;
    else
      -- --- Alta nueva, sin código de barras ---
      v_nombre := initcap(lower(r.descripcion));

      v_sku := 'EQ-' || r.codigo_prov;
      v_sufijo := 0;
      while exists (select 1 from public.productos where sku = v_sku) loop
        v_sufijo := v_sufijo + 1;
        v_sku := 'EQ-' || r.codigo_prov || '-' || v_sufijo;
      end loop;

      insert into public.productos
        (nombre, sku, categoria, tipo, descripcion, costo, precio,
         stock, stock_minimo, activo, requiere_receta)
      values
        (v_nombre, v_sku, 'Medicamentos', 'generico',
         'Ticket Equilibrio 440393 · código de proveedor ' || r.codigo_prov
           || ' · ' || r.descripcion || ' · falta código de barras',
         r.costo_unitario, ceil(r.costo_unitario * 1.6),
         0, 1, true, false)
      returning id into v_pid;

      n_altas := n_altas + 1;
    end if;

    -- --- Columnas opcionales: sólo las que existan en este ambiente ---
    v_set := null;
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'productos'
                 and column_name = 'proveedor') then
      v_set := 'proveedor = ' || quote_literal('EQUILIBRIO FARMACEUTICO');
    end if;
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'productos'
                 and column_name = 'notas') then
      v_set := concat_ws(', ', v_set,
        'notas = coalesce(nullif(notas, ''''), '
        || quote_literal('Código proveedor Equilibrio: ' || r.codigo_prov) || ')');
    end if;
    if v_set is not null then
      execute format('update public.productos set %s where id = %s', v_set, v_pid);
    end if;

    -- --- Lote ---
    if r.lote is not null and not exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid and l.numero_lote = r.lote
    ) then
      v_cols := 'producto_id, numero_lote, cantidad_actual, fecha_caducidad, costo_unitario';
      v_vals := v_pid || ', ' || quote_literal(r.lote) || ', '
                || greatest(r.cantidad, 1) || ', '
                || coalesce(quote_literal(r.caducidad::text) || '::date', 'null') || ', '
                || coalesce(r.costo_unitario::text, 'null');

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

  raise notice 'Líneas que ya traía el lote 4, no se tocaron: %', n_saltadas;
  raise notice 'Productos nuevos creados: %', n_altas;
  raise notice 'Productos existentes a los que se les completó el costo: %', n_ligadas;
  raise notice 'Lotes registrados: %', n_lotes;
  raise notice 'Líneas con varios candidatos, pendientes de decidir: %', n_ambiguas;
end
$carga$;

-- ---------------------------------------------------------------------------
-- 4) Stock = suma de los lotes
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
  and p.stock is distinct from coalesce(t.total, 0);

-- ---------------------------------------------------------------------------
-- 5) Las líneas que no se pudieron resolver solas
-- ---------------------------------------------------------------------------
with marca as (
  select
    t.*,
    (select p from unnest(string_to_array(
              upper(translate(t.descripcion,
                              'ÁÉÍÓÚÜÑáéíóúüñ', 'AEIOUUNAEIOUUN')), ' ')) p
     where length(p) >= 4 and p ~ '^[A-Z]' limit 1) as primera_palabra
  from public.ticket_equilibrio_440393 t
)
select
  m.codigo_prov,
  m.descripcion,
  m.lote,
  m.costo_unitario,
  count(p.id)                       as candidatos_en_catalogo,
  string_agg(p.sku || ' · ' || p.nombre, ' | ' order by p.nombre) as cuales
from marca m
join public.productos p
  on upper(translate(p.nombre, 'ÁÉÍÓÚÜÑáéíóúüñ', 'AEIOUUNAEIOUUN'))
     like m.primera_palabra || '%'
group by m.codigo_prov, m.descripcion, m.lote, m.costo_unitario
having count(p.id) > 1
order by m.descripcion;

-- ---------------------------------------------------------------------------
-- 6) Resumen
-- ---------------------------------------------------------------------------
select
  (select count(*) from public.ticket_equilibrio_440393)               as lineas_del_ticket,
  (select count(*) from public.productos where sku like 'EQ-%')        as altas_desde_el_ticket,
  (select count(*) from public.productos
    where sku like 'EQ-%' and codigo_barras is null)                   as sin_codigo_de_barras,
  (select count(*) from public.productos)                              as productos_en_total;
