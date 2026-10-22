-- ============================================================================
-- Tena Pants Maxi Protect: pistola no pasa (Farmalive folio 310545)
--
-- Qué pasó (Cyntia, Team FarmaCap):
--   Essity relanzó Maxi → Maxi Protect Proskin con EAN nuevo en la caja.
--   El ticket / catálogo seguían con el EAN viejo. Recibir (lista PDF/CSV)
--   rechaza cualquier beep que no esté en el ticket → "no pasa".
--
-- Caja (fotos Cyntia)          Ticket / catálogo viejo
--   7501019064432  CH/M C/13     7501019051159 (o 12 dig 750101905115)
--   7501019064449  Grande C/13   7501019051166 (o 12 dig 750101905116)
--
-- Algodón EAN 7506233810544 (Super Precio): NO va en este folio.
--   Cortesía del proveedor; no forzar en el ticket.
--
-- Esto:
--   1) fc_match: pares viejo ↔ caja (cliente ya tiene EAN_PARES_CONOCIDOS).
--   2) Catálogo: codigo_barras = EAN de la caja; viejo queda en descripción.
--   3) Folio 310545: codigo_escaneado de los Tena grises → EAN de caja.
--
-- Idempotente. Pegar en Supabase → SQL Editor → Run.
-- Después: deploy del front (pares JS) o al menos este SQL para el match
-- en servidor / catálogo. Cyntia puede reescanear o tocar el gris + MMAA.
-- ============================================================================

begin;

create or replace function public.fc_match_codigo_barras(p_scan text, p_stored text)
returns boolean
language sql
immutable
parallel safe
as $$
  with n as (
    select
      regexp_replace(coalesce(p_scan, ''), '\D', '', 'g') as scan,
      regexp_replace(coalesce(p_stored, ''), '\D', '', 'g') as stored
  )
  select
    case
      when n.scan = '' or n.stored = '' then false
      when n.scan = n.stored then true
      when length(n.scan) >= 12 and length(n.stored) >= 12
        and right(n.scan, 12) = right(n.stored, 12) then true
      when length(n.scan) = 12 and length(n.stored) = 13
        and n.stored = '0' || n.scan then true
      when length(n.stored) = 12 and length(n.scan) = 13
        and n.scan = '0' || n.stored then true
      when length(n.scan) >= 8 and length(n.stored) = length(n.scan) + 1
        and n.stored like n.scan || '_' then true
      when length(n.stored) >= 8 and length(n.scan) = length(n.stored) + 1
        and n.scan like n.stored || '_' then true
      when length(n.scan) = 13 and length(n.stored) = 12
        and n.scan like '6502400%' and n.stored like '650240%'
        and substring(n.scan from 8) = substring(n.stored from 7) then true
      when length(n.stored) = 13 and length(n.scan) = 12
        and n.stored like '6502400%' and n.scan like '650240%'
        and substring(n.stored from 8) = substring(n.scan from 7) then true
      when n.scan in ('7501868900233', '7501868990023')
       and n.stored in ('7501868900233', '7501868990023') then true
      when n.scan in ('747589705123', '714706903205')
       and n.stored in ('747589705123', '714706903205') then true
      when n.scan in ('650240079009', '6502400079009', '6502400070009')
       and n.stored in ('650240079009', '6502400079009', '6502400070009') then true
      when n.scan in ('650240078996', '6502400078996')
       and n.stored in ('650240078996', '6502400078996') then true
      -- Tena Maxi (viejo) ↔ Maxi Protect Proskin (caja)
      when n.scan in ('7501019051159', '750101905115', '7501019064432')
       and n.stored in ('7501019051159', '750101905115', '7501019064432') then true
      when n.scan in ('7501019051166', '750101905116', '7501019064449')
       and n.stored in ('7501019051166', '750101905116', '7501019064449') then true
      else false
    end
  from n;
$$;

grant execute on function public.fc_match_codigo_barras(text, text) to anon, authenticated, service_role;

-- Catálogo: EAN de la caja como principal; anotar el viejo en descripción.
update public.productos
set
  codigo_barras = '7501019064432',
  marca = coalesce(nullif(btrim(marca), ''), 'Tena'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/13'),
  descripcion = case
    when descripcion ilike '%7501019064432%' and descripcion ilike '%750101905115%' then descripcion
    when coalesce(btrim(descripcion), '') = '' then
      'Tena Pants Maxi Protect Proskin CH/M C/13. EAN caja 7501019064432 · EAN ticket/viejo 7501019051159.'
    else
      btrim(descripcion) || ' EAN caja 7501019064432 · EAN ticket/viejo 7501019051159.'
  end
where coalesce(activo, true)
  and (
    codigo_barras in ('7501019051159', '750101905115', '7501019064432')
    or sku in ('FC-19051159', 'FC-10651959', 'FC-19064432')
    or (
      nombre ilike '%tena%pants%maxi%'
      and (
        nombre ilike '%ch/m%'
        or nombre ilike '%chico%/mediano%'
        or nombre ilike '%chico%mediano%'
      )
      and nombre not ilike '%grande%'
    )
  );

update public.productos
set
  codigo_barras = '7501019064449',
  marca = coalesce(nullif(btrim(marca), ''), 'Tena'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/13'),
  descripcion = case
    when descripcion ilike '%7501019064449%' and descripcion ilike '%750101905116%' then descripcion
    when coalesce(btrim(descripcion), '') = '' then
      'Tena Pants Maxi Protect Proskin Grande C/13. EAN caja 7501019064449 · EAN ticket/viejo 7501019051166.'
    else
      btrim(descripcion) || ' EAN caja 7501019064449 · EAN ticket/viejo 7501019051166.'
  end
where coalesce(activo, true)
  and (
    codigo_barras in ('7501019051166', '750101905116', '7501019064449')
    or sku in ('FC-19051166', 'FC-19851166', 'FC-19064449')
    or (
      nombre ilike '%tena%pants%maxi%'
      and nombre ilike '%grande%'
    )
  );

-- Folio 310545: que el beep de la caja abra el gris aunque el PDF traiga el viejo.
update public.recepcion_items i
set codigo_escaneado = '7501019064432'
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '310545'
  and coalesce(i.confirmado, false) = false
  and (
    i.codigo_escaneado in ('7501019051159', '750101905115', '7501019064432')
    or (
      i.nombre_snapshot ilike '%tena%pants%maxi%'
      and (
        i.nombre_snapshot ilike '%ch/m%'
        or i.nombre_snapshot ilike '%chico%/mediano%'
        or i.nombre_snapshot ilike '%chico%mediano%'
      )
      and i.nombre_snapshot not ilike '%grande%'
    )
  );

update public.recepcion_items i
set codigo_escaneado = '7501019064449'
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '310545'
  and coalesce(i.confirmado, false) = false
  and (
    i.codigo_escaneado in ('7501019051166', '750101905116', '7501019064449')
    or (
      i.nombre_snapshot ilike '%tena%pants%maxi%'
      and i.nombre_snapshot ilike '%grande%'
    )
  );

commit;

select p.sku, p.codigo_barras, p.nombre, p.marca, p.presentacion
  from public.productos p
 where p.codigo_barras in ('7501019064432', '7501019064449', '7501019051159', '7501019051166')
    or p.sku in ('FC-19051159', 'FC-19051166', 'FC-10651959', 'FC-19851166', 'FC-19064432', 'FC-19064449')
    or (p.nombre ilike '%tena%pants%maxi%' and p.nombre ilike '%protect%')
 order by p.sku;

select r.folio, i.codigo_escaneado, i.nombre_snapshot, i.cantidad, i.confirmado
  from public.recepcion_items i
  join public.recepciones r on r.id = i.recepcion_id
 where r.folio = '310545'
 order by i.id;
