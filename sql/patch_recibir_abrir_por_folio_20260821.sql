-- Si Mary escribe un folio que ya es un borrador (Farmalive 11590),
-- abrir ESE ticket con sus renglones. No crear uno vacío.

begin;

create or replace function public.recepcion_abrir(
  p_session_token uuid,
  p_proveedor text default null,
  p_folio text default null,
  p_total_ticket numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_id bigint;
  v_folio text;
begin
  v_user := public.fn_require_empleado(p_session_token);
  v_folio := nullif(btrim(p_folio), '');

  if v_folio is not null then
    select r.id into v_id
    from public.recepciones r
    where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
      and btrim(coalesce(r.folio, '')) = v_folio
    order by (select count(*) from public.recepcion_items i where i.recepcion_id = r.id) desc, r.id
    limit 1;

    if v_id is not null then
      update public.recepciones
      set
        proveedor = coalesce(nullif(btrim(p_proveedor), ''), proveedor),
        total_ticket = coalesce(p_total_ticket, total_ticket),
        updated_at = now()
      where id = v_id;
      return public.fc_recepcion_json(v_id);
    end if;
  end if;

  insert into public.recepciones (proveedor, folio, total_ticket, capturado_por, estado)
  values (
    nullif(btrim(p_proveedor), ''),
    v_folio,
    p_total_ticket,
    v_user,
    'borrador'
  )
  returning id into v_id;

  return public.fc_recepcion_json(v_id);
end;
$$;

grant execute on function public.recepcion_abrir(uuid, text, text, numeric) to anon, authenticated;

-- Borrador vacío que se creó al reescribir FarmaLive 11590.
delete from public.recepcion_items where recepcion_id = 5;
delete from public.recepciones where id = 5 and folio = '11590'
  and not exists (select 1 from public.recepcion_items i where i.recepcion_id = 5);

commit;
