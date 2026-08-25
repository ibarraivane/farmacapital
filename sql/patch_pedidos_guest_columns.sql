-- FARMAX — Columnas guest en pedidos (checkout online)
-- Ejecutar en Supabase SQL Editor si falla:
--   column "guest_nombre" of relation "pedidos" does not exist
--
-- El RPC cliente_crear_pedido_online (patch_seguridad_accesos / whatsapp_recibo)
-- guarda datos de invitado en pedidos; estas columnas debían existir antes del RPC.

begin;

alter table public.pedidos
  add column if not exists guest_nombre text,
  add column if not exists guest_telefono text,
  add column if not exists guest_email text;

comment on column public.pedidos.guest_nombre is
  'Nombre capturado en checkout sin cuenta (invitado).';
comment on column public.pedidos.guest_telefono is
  'Teléfono capturado en checkout sin cuenta (invitado).';
comment on column public.pedidos.guest_email is
  'Email capturado en checkout sin cuenta (invitado).';

-- Por si faltan de patches anteriores:
alter table public.pedidos
  add column if not exists whatsapp_recibo boolean not null default false;

alter table public.pedidos
  add column if not exists puntos_acreditados boolean not null default false;

commit;
