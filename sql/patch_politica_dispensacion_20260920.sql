-- FarmaCapital — Política de dispensación en servidor (Sprint 0)
-- Fecha: 2026-09-20 · Rama: cursor/sprint0-politica-medicamentos-8808
--
-- ⚠️ NO EJECUTADO. Requiere aprobación de Iván antes de correr en Supabase.
--
-- Qué hace:
--   * Tabla de una fila: fc_politica_dispensacion (espejo de src/config/politicaMedicamentos.js).
--   * Antibiótico con canal 'suspendido'  → rechaza el pedido en línea.
--   * Antibiótico con envío no permitido  → rechaza tipo_entrega = 'envio' (recoger sigue igual).
--   * Controlados: sin cambio (ya los rechaza cliente_crear_pedido_online).
--   * Trigger en pedido_items: valida al insertar/cambiar ítems de pedidos tipo online.
--     Así no se reemplaza cliente_crear_pedido_online (evita pisar pickup, recargo, guest, FOR UPDATE).
--   * No toca POS, lotes, precios, pagos ni cliente_crear_pedido_bajo_pedido.
--
-- Defaults alineados al frontend:
--   antibioticos_canal_en_linea = 'habilitado'
--   antibioticos_envio_domicilio = false
--
-- Revertir: drop trigger trg_fc_pedido_items_dispensacion; o poner
--   antibioticos_canal_en_linea = 'habilitado' y antibioticos_envio_domicilio = true.

begin;

create table if not exists public.fc_politica_dispensacion (
  id                            boolean primary key default true check (id),
  antibioticos_canal_en_linea   text    not null default 'habilitado'
                                check (antibioticos_canal_en_linea in ('habilitado','suspendido')),
  antibioticos_envio_domicilio  boolean not null default false,
  actualizado_en                timestamptz not null default now(),
  actualizado_por               text
);

comment on table public.fc_politica_dispensacion is
  'Switch único de política de antibióticos para la tienda web. Espejo: src/config/politicaMedicamentos.js. El canal cambia; la receta se exige siempre.';

insert into public.fc_politica_dispensacion (id) values (true)
  on conflict (id) do nothing;

alter table public.fc_politica_dispensacion enable row level security;
-- Sin políticas para anon/authenticated: solo lectura vía la función security definer.

create table if not exists public.fc_politica_dispensacion_log (
  id           bigserial primary key,
  cambiado_en  timestamptz not null default now(),
  cambiado_por text,
  antes        jsonb,
  despues      jsonb
);
alter table public.fc_politica_dispensacion_log enable row level security;

create or replace function public.fc_politica_dispensacion_audit()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  new.actualizado_en := now();
  insert into public.fc_politica_dispensacion_log (cambiado_por, antes, despues)
  values (coalesce(new.actualizado_por, current_user), to_jsonb(old), to_jsonb(new));
  return new;
end;
$$;

drop trigger if exists trg_fc_politica_dispensacion_audit on public.fc_politica_dispensacion;
create trigger trg_fc_politica_dispensacion_audit
  before update on public.fc_politica_dispensacion
  for each row execute function public.fc_politica_dispensacion_audit();

-- ¿La categoría es antibiótico? (mismo criterio que categoriaCanon: sin acentos, singular/plural)
create or replace function public.fc_es_categoria_antibiotico(p_categoria text)
returns boolean
language sql
immutable
set search_path = public, pg_temp
as $$
  select lower(translate(trim(coalesce(p_categoria, '')), 'ÁÉÍÓÚáéíóú', 'AEIOUaeiou'))
         in ('antibiotico', 'antibioticos');
$$;

create or replace function public.fc_validar_dispensacion_online(
  p_nombre       text,
  p_categoria    text,
  p_tipo_entrega text
)
returns void
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_pol public.fc_politica_dispensacion%rowtype;
begin
  if not public.fc_es_categoria_antibiotico(p_categoria) then
    return;
  end if;

  select * into v_pol from public.fc_politica_dispensacion where id;
  if not found then
    return; -- sin configuración = comportamiento anterior
  end if;

  if v_pol.antibioticos_canal_en_linea = 'suspendido' then
    raise exception 'El antibiótico "%" se surte solo en farmacia, con receta médica vigente', p_nombre;
  end if;

  if p_tipo_entrega = 'envio' and not v_pol.antibioticos_envio_domicilio then
    raise exception 'El antibiótico "%" está disponible solo para recoger en farmacia, con receta médica vigente', p_nombre;
  end if;
end;
$$;

revoke all on function public.fc_validar_dispensacion_online(text, text, text) from public, anon, authenticated;

-- Valida ítems de pedidos online al insertar/cambiar, sin redefinir cliente_crear_pedido_online.
create or replace function public.fc_trg_pedido_items_dispensacion()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_pedido record;
  v_prod   record;
begin
  select tipo, tipo_entrega
    into v_pedido
    from public.pedidos
   where id = new.pedido_id;

  if not found then
    return new;
  end if;

  -- POS / mostrador / consulta no pasan por esta política.
  if lower(trim(coalesce(v_pedido.tipo, ''))) is distinct from 'online' then
    return new;
  end if;

  select nombre, categoria
    into v_prod
    from public.productos
   where id = new.producto_id;

  if not found then
    return new;
  end if;

  perform public.fc_validar_dispensacion_online(
    v_prod.nombre,
    v_prod.categoria,
    coalesce(v_pedido.tipo_entrega, 'recoger')
  );
  return new;
end;
$$;

drop trigger if exists trg_fc_pedido_items_dispensacion on public.pedido_items;
create trigger trg_fc_pedido_items_dispensacion
  before insert or update of producto_id, pedido_id
  on public.pedido_items
  for each row execute function public.fc_trg_pedido_items_dispensacion();

comment on function public.fc_validar_dispensacion_online(text, text, text) is
  'Rechaza antibióticos en línea según fc_politica_dispensacion. La receta se exige siempre; el switch solo cambia el canal.';

commit;
