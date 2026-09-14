-- Sábado y domingo: la vendedora que trabaja se queda en SU turno.
-- El medio hueco (el de quien descansa) lo cubren Luis e Iván.
-- Lun–vie sigue igual: si una descansa, la otra cubre ambos.
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.

begin;

comment on column public.usuarios.dia_descanso is
  'Día libre semanal: 0=lun … 6=dom. Lun–vie la compañera cubre ambos. Sáb–dom el medio turno lo cubren los dueños.';

create or replace function public.fn_cubre_ambos_hoy(p_user_id bigint)
returns boolean
language sql
stable
set search_path = public, pg_temp
as $$
  select
    public.fn_dia_idx_cdmx() not in (5, 6)
    and exists (
      select 1
      from public.usuarios yo
      where yo.id = p_user_id
        and yo.activo is true
        and yo.eliminado_at is null
        and (yo.dia_descanso is distinct from public.fn_dia_idx_cdmx())
        and exists (
          select 1
          from public.usuarios otra
          where otra.id <> yo.id
            and otra.activo is true
            and otra.eliminado_at is null
            and otra.rol in ('vendedor', 'gerente')
            and otra.dia_descanso = public.fn_dia_idx_cdmx()
        )
    )
$$;

notify pgrst, 'reload schema';

commit;
