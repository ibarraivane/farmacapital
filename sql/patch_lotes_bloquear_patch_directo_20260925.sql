-- ============================================================================
-- Stock fantasma: bloquear PATCH directo a lotes + auditar de verdad
-- 2026-09-25. Idempotente. Pegar entero en Supabase → SQL Editor → Run.
--
-- Qué pasaba
--   Recibir crea el lote bien (cantidad_inicial correcta). Después un
--   cliente PostgREST con la llave service_role hace:
--
--     UPDATE lotes SET cantidad_actual = $body
--      WHERE id = $2 AND producto_id = $3 AND cantidad_actual = $4
--
--   Eso es supabase.from('lotes').update({ cantidad_actual }).eq('id')
--   .eq('producto_id').eq('cantidad_actual') — compare-and-swap.
--   No pasa por ninguna función, no escribe movimientos_inventario, y
--   fn_audit_trigger se traga el error. El anaquel queda en 0.
--
--   Ese .update() no está en el repo (ni en main ni en las ramas de
--   agotados/stock). El intento anterior (patch_agotados_resync) solo
--   copia lotes → productos.stock, al revés, y no detiene esto.
--
-- Qué hace este archivo
--   1) BEFORE UPDATE: service_role / anon / authenticated no pueden
--      cambiar cantidad_actual ni activo. Recibir, POS, Rappi y el
--      ajuste corren como SECURITY DEFINER (postgres) y siguen igual.
--      El SQL Editor (postgres) también puede: el arreglo de abajo pasa.
--   2) fn_audit_trigger llena `accion` (NOT NULL desde el esquema F1).
--      Sin eso el INSERT a audit_log_detallado fallaba siempre y el
--      EXCEPTION WHEN OTHERS lo ocultaba. Ahora avisa con RAISE WARNING
--      si vuelve a fallar, y escribe accion + antes/despues + columnas F6d.
--   3) Restaura los 7 lotes confirmados el 2026-09-25 (cantidad_inicial
--      intacta, sin venta en movimientos). Deja un ajuste en el kardex
--      para que la próxima revisión lo vea.
-- ============================================================================

begin;

-- ── 1) Auditoría: columnas F1 y F6d conviven ────────────────────────────────
alter table public.audit_log_detallado
  add column if not exists accion text,
  add column if not exists antes jsonb,
  add column if not exists despues jsonb,
  add column if not exists operacion text,
  add column if not exists actor_id bigint,
  add column if not exists actor_tipo text,
  add column if not exists actor_ip text,
  add column if not exists valores_antes jsonb,
  add column if not exists valores_despues jsonb,
  add column if not exists campos_cambiados text[];

alter table public.audit_log_detallado
  alter column accion drop not null;

-- registro_id nació integer (F1). Un id grande no debe tumbar la auditoría.
do $$
declare
  v_tipo text;
begin
  select data_type into v_tipo
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'audit_log_detallado'
    and column_name = 'registro_id';
  if v_tipo in ('integer', 'bigint', 'smallint') then
    execute 'alter table public.audit_log_detallado
             alter column registro_id type text using registro_id::text';
  end if;
end $$;

create or replace function public.fn_audit_trigger()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id   bigint;
  v_actor_tipo text;
  v_actor_ip   text;
  v_old        jsonb;
  v_new        jsonb;
  v_pk         text;
  v_changed    text[];
  v_sens_cols  text[] := array['password_hash','salt','token','session_token','password'];
  v_col        text;
begin
  begin
    v_actor_id := nullif(current_setting('app.actor_id', true), '')::bigint;
  exception when others then v_actor_id := null; end;

  v_actor_tipo := nullif(current_setting('app.actor_tipo', true), '');
  v_actor_ip   := nullif(current_setting('app.actor_ip',   true), '');

  if (TG_OP = 'DELETE') then
    v_old := to_jsonb(OLD);
    v_new := null;
  elsif (TG_OP = 'INSERT') then
    v_old := null;
    v_new := to_jsonb(NEW);
  else
    v_old := to_jsonb(OLD);
    v_new := to_jsonb(NEW);
  end if;

  foreach v_col in array v_sens_cols
  loop
    if v_old is not null and v_old ? v_col then v_old := v_old - v_col; end if;
    if v_new is not null and v_new ? v_col then v_new := v_new - v_col; end if;
  end loop;

  if TG_OP = 'UPDATE' then
    select array_agg(key)
      into v_changed
    from (
      select key
      from jsonb_each(coalesce(v_new, '{}'::jsonb))
      where (v_new->key) is distinct from (v_old->key)
    ) t;

    if v_changed is null or array_length(v_changed, 1) is null then
      return coalesce(NEW, OLD);
    end if;
  end if;

  if TG_OP = 'DELETE' then
    v_pk := coalesce(v_old->>'id', null);
  else
    v_pk := coalesce(v_new->>'id', v_old->>'id');
  end if;

  -- accion / antes / despues: esquema F1 (accion era NOT NULL y el
  -- trigger F6d no la llenaba → cero filas de lotes).
  insert into public.audit_log_detallado (
    tabla, operacion, accion, registro_id,
    actor_id, actor_tipo, actor_ip,
    valores_antes, valores_despues, campos_cambiados,
    antes, despues
  ) values (
    TG_TABLE_NAME, TG_OP, TG_OP, v_pk,
    v_actor_id, v_actor_tipo, v_actor_ip,
    v_old, v_new, v_changed,
    v_old, v_new
  );

  return coalesce(NEW, OLD);
exception when others then
  raise warning 'fn_audit_trigger fallo en %.% id=%: %',
    TG_TABLE_NAME, TG_OP, coalesce(v_pk, ''), SQLERRM;
  return coalesce(NEW, OLD);
end;
$$;

comment on function public.fn_audit_trigger() is
  'Audita INSERT/UPDATE/DELETE. Llena accion (F1) y operacion/valores_* (F6d). Si falla, RAISE WARNING y no aborta la operación de negocio.';

revoke execute on function public.fn_audit_trigger() from public, anon, authenticated;

-- ── 2) Nadie con la llave de la API cambia piezas del lote a mano ───────────
create or replace function public.fn_lotes_bloquear_patch_directo()
returns trigger
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
begin
  -- SECURITY DEFINER (Recibir, venta, ajuste, Rappi) corre como postgres
  -- y no entra aquí. El PATCH de PostgREST con service_role sí.
  if current_user in ('service_role', 'anon', 'authenticated', 'authenticator')
     and coalesce(current_setting('app.lote_escritura', true), '') is distinct from 'permitido'
     and (
       new.cantidad_actual is distinct from old.cantidad_actual
       or new.activo is distinct from old.activo
     )
  then
    raise exception
      using
        errcode = '42501',
        message = format(
          'lotes: el rol %s no puede cambiar cantidad_actual ni activo. Usa Recibir, la venta o adjust_stock_secure.',
          current_user
        );
  end if;
  return new;
end;
$$;

comment on function public.fn_lotes_bloquear_patch_directo() is
  'Rechaza PATCH/UPDATE directo de cantidad_actual y activo desde service_role. Las funciones SECURITY DEFINER siguen escribiendo el lote.';

revoke all on function public.fn_lotes_bloquear_patch_directo() from public, anon, authenticated;

drop trigger if exists trg_lotes_bloquear_patch_directo on public.lotes;
create trigger trg_lotes_bloquear_patch_directo
  before update of cantidad_actual, activo on public.lotes
  for each row
  execute function public.fn_lotes_bloquear_patch_directo();

commit;

-- ── 3) Restaurar los lotes comidos (verificado 2026-09-25, sin salida) ──────
-- 255 Mousse Herbal Essences · 19670 Curitas · 19690 Cubrebocas · 19700 Protec
begin;

with restored as (
  update public.lotes l
  set cantidad_actual = l.cantidad_inicial,
      activo = true
  where l.id in (1782, 391, 255, 2313, 2374, 2388, 2365)
    and l.cantidad_actual = 0
    and l.activo = false
    and coalesce(l.cantidad_inicial, 0) > 0
    and not exists (
      select 1
      from public.movimientos_inventario m
      where m.producto_id = l.producto_id
        and m.tipo = 'salida'
        and m.created_at >= l.created_at
    )
  returning l.id, l.producto_id, l.cantidad_inicial, l.numero_lote
)
insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
select
  r.producto_id,
  'ajuste',
  r.cantidad_inicial,
  'Restauracion stock fantasma 2026-09-25 lote ' || r.id || ' ' || coalesce(r.numero_lote, '')
from restored r;

-- El trigger trg_sync_productos_stock ya recalculó productos.stock.
select p.id, p.nombre, p.stock,
       (select coalesce(sum(l.cantidad_actual), 0)
          from public.lotes l
         where l.producto_id = p.id
           and coalesce(l.activo, true)) as suma_lotes
from public.productos p
where p.id in (255, 19670, 19690, 19700);

commit;
