-- FarmaCapital — Solicitudes de la tienda web en «Lo que buscan».
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.
--
-- La tienda (farmacapital.mx/conseguir) anota pedidos que no están en
-- catálogo. Misma tabla que el piso: solicitudes_mostrador.
-- origen = 'tienda' | 'mostrador'. anotado_por puede ser null en web.

begin;

alter table public.solicitudes_mostrador
  alter column anotado_por drop not null;

alter table public.solicitudes_mostrador
  add column if not exists origen text not null default 'mostrador',
  add column if not exists cliente_email text,
  add column if not exists direccion text;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'solicitudes_mostrador_origen_chk'
  ) then
    alter table public.solicitudes_mostrador
      add constraint solicitudes_mostrador_origen_chk
      check (origen in ('mostrador', 'tienda'));
  end if;
end $$;

create index if not exists solicitudes_mostrador_origen_idx
  on public.solicitudes_mostrador (origen, created_at desc);

comment on column public.solicitudes_mostrador.origen is
  'mostrador = anotó el piso; tienda = formulario «te lo conseguimos».';

create or replace function public._solicitud_mostrador_json(p_id bigint)
returns jsonb
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select jsonb_build_object(
    'id', s.id,
    'texto', s.texto,
    'producto_id', s.producto_id,
    'producto_nombre', p.nombre,
    'producto_stock', coalesce(p.stock, 0),
    'cantidad', s.cantidad,
    'urgencia', s.urgencia,
    'tipo', s.tipo,
    'estado', s.estado,
    'origen', coalesce(s.origen, 'mostrador'),
    'notas', s.notas,
    'cliente_nombre', s.cliente_nombre,
    'cliente_telefono', s.cliente_telefono,
    'cliente_email', s.cliente_email,
    'direccion', s.direccion,
    'pago_tipo', s.pago_tipo,
    'pago_monto', s.pago_monto,
    'anotado_por', s.anotado_por,
    'anotado_por_nombre', u.nombre,
    'resuelto_por', s.resuelto_por,
    'resuelto_por_nombre', ur.nombre,
    'resuelto_at', s.resuelto_at,
    'created_at', s.created_at,
    'updated_at', s.updated_at
  )
  from public.solicitudes_mostrador s
  left join public.productos p on p.id = s.producto_id
  left join public.usuarios u on u.id = s.anotado_por
  left join public.usuarios ur on ur.id = s.resuelto_por
  where s.id = p_id;
$$;

commit;
