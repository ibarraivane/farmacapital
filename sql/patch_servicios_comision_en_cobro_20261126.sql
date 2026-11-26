-- Comisión del cobro: si el vendedor manda un monto > 0 y <= 200, ese se guarda.
-- Si no manda nada (o manda 0), sigue la sugerida del catálogo / configuracion.
-- Recargas siguen en 0.
-- Pegar en Supabase SQL Editor y Run. registrar_pago_servicio_pos ya llama esta función.

begin;

create or replace function public.fn_recargo_catalogo_servicio(
  p_proveedor text,
  p_categoria text,
  p_comision  numeric default null
)
returns numeric
language plpgsql
stable
set search_path = public, pg_temp
as $$
declare
  v_cat text := lower(btrim(coalesce(p_categoria, '')));
  v_prov text := lower(btrim(coalesce(p_proveedor, '')));
  v_id text;
  v_cfg jsonb;
  v_val numeric;
  v_typed numeric;
begin
  if v_cat = 'recarga' then
    return 0;
  end if;

  if p_comision is not null then
    v_typed := round(p_comision::numeric, 2);
    if v_typed > 200 then
      raise exception 'La comisión no puede pasar de $200.';
    end if;
    if v_typed > 0 then
      return v_typed;
    end if;
  end if;

  v_id := case
    when v_prov in ('cfe','telmex','totalplay','izzi','sky','agua','gas','otro') then v_prov
    when v_prov like '%izzi%' then 'izzi'
    when v_prov like '%cfe%' then 'cfe'
    when v_prov like '%telmex%' then 'telmex'
    when v_prov like '%totalplay%' then 'totalplay'
    when v_prov like '%sky%' then 'sky'
    when v_prov like '%agua%' then 'agua'
    when v_prov like '%gas%' then 'gas'
    else 'otro'
  end;

  select valor::jsonb into v_cfg
  from public.configuracion
  where clave = 'servicios_recargos'
  limit 1;

  begin
    v_val := round((v_cfg ->> v_id)::numeric, 2);
  exception when others then
    v_val := null;
  end;

  if v_val is null or v_val <= 0 then
    v_val := case v_id
      when 'izzi' then 10
      when 'sky' then 10
      when 'otro' then 10
      else 8
    end;
  end if;

  if v_val > 200 then
    v_val := 200;
  end if;
  return v_val;
end;
$$;

grant execute on function public.fn_recargo_catalogo_servicio(text, text, numeric)
  to anon, authenticated;

commit;

select
  public.fn_recargo_catalogo_servicio('Izzi', 'telefonia', 15) as con_quince,
  public.fn_recargo_catalogo_servicio('Izzi', 'telefonia', null) as sugerida,
  public.fn_recargo_catalogo_servicio('Telcel', 'recarga', 10) as recarga;
