-- Zona del banner en el home: hero (carrusel), strip (franja bajo badges), tile (mosaico).
alter table public.banners add column if not exists slot text default 'hero';

comment on column public.banners.slot is 'hero=carrusel superior | strip=franja horizontal | tile=rejilla';

-- Valores existentes quedan como hero por el default.
