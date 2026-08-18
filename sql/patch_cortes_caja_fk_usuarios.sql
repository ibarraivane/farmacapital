-- FarmaCapital — El corte guarda usuarios.id en cortes_caja.empleado_id,
-- pero la FK apuntaba a empleados. Por eso el vendedor no podía guardar:
--   insert or update on table "cortes_caja" violates foreign key
--   constraint "cortes_caja_empleado_id_fkey"
--
-- También anula la apertura de caja de prueba de hoy, como si no hubiera pasado.
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run.

-- ── 1) Apertura de prueba: borrar sesiones abiertas / sin corte de hoy ──────
begin;

delete from public.caja_sesiones
 where estado = 'abierta'
    or (
      corte_id is null
      and fecha = (timezone('America/Mexico_City', now()))::date
    );

commit;


-- ── 2) FK: cortes_caja.empleado_id = perfil de acceso (usuarios), no RH ─────
begin;

do $$
begin
  if exists (
    select 1 from information_schema.columns
     where table_schema = 'public'
       and table_name = 'empleados'
       and column_name = 'usuario_id'
  ) then
    update public.cortes_caja c
       set empleado_id = e.usuario_id
      from public.empleados e
     where e.id = c.empleado_id
       and e.usuario_id is not null
       and not exists (select 1 from public.usuarios u where u.id = c.empleado_id);
  end if;
end $$;

alter table public.cortes_caja
  drop constraint if exists cortes_caja_empleado_id_fkey;

alter table public.cortes_caja
  add constraint cortes_caja_empleado_id_fkey
  foreign key (empleado_id) references public.usuarios(id)
  on delete restrict
  not valid;

comment on column public.cortes_caja.empleado_id is
  'Id del perfil en public.usuarios (quien abrió/cerró caja). No es empleados.id de RH.';

commit;

-- Valida filas viejas si se puede. Si alguna no mapea a usuarios, se deja NOT VALID:
-- los cortes NUEVOS (Mary, etc.) sí quedan protegidos y se pueden guardar.
do $$
begin
  alter table public.cortes_caja validate constraint cortes_caja_empleado_id_fkey;
exception when others then
  raise notice 'FK dejada NOT VALID: hay cortes viejos con empleado_id que no es un usuario. Los cortes nuevos sí se guardan.';
end $$;
