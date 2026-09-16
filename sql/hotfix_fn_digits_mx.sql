-- FarmaCapital — HOTFIX urgente checkout
-- Error: function public.fn_digits_mx(text) does not exist
--
-- Causa: cliente_crear_pedido_online (y otros RPCs de teléfono MX) llaman
-- public.fn_digits_mx, definida en patch_password_reset_self_service.sql,
-- pero esa función no está en la BD (parche de seguridad aplicado sin el helper).
--
-- Ejecutar YA en Supabase → SQL Editor → Run. Idempotente.

begin;

create or replace function public.fn_digits_mx(p_text text)
returns text
language sql
immutable
as $$
  select case
    when p_text is null then ''
    else right(regexp_replace(p_text, '\D', '', 'g'), 10)
  end;
$$;

comment on function public.fn_digits_mx(text) is
  'Normaliza teléfono MX a últimos 10 dígitos. Requerido por checkout guest y RPCs de clientes.';

-- Verificación rápida (debe devolver 5528516215)
-- select public.fn_digits_mx('52 55 2851 6215');

commit;
