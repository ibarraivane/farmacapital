-- Quitar mínimo $150 de envío a domicilio.
-- El cliente ya paga el envío; no hay piso de productos.
-- Pegar en Supabase → SQL Editor → Run.
--
-- No reescribe toda cliente_crear_pedido_online: solo recorta el gate
-- si la función viva aún lo tiene (fases c/d). Si ya no está (precio_mp),
-- este script no cambia el cuerpo.

begin;

do $$
declare
  r record;
  def text;
  cleaned text;
  changed int := 0;
begin
  for r in
    select p.oid
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'cliente_crear_pedido_online'
  loop
    def := pg_get_functiondef(r.oid);
    cleaned := def;

    cleaned := regexp_replace(
      cleaned,
      '--[[:space:]]*MONTO_MINIMO[^' || chr(10) || ']*' || chr(10),
      '',
      'g'
    );

    cleaned := regexp_replace(
      cleaned,
      'if not v_es_pickup and v_(subtotal|total) < 150 then[[:space:]]+raise exception ''El pedido a domicilio tiene un mínimo de \$150[^'']+'';[[:space:]]+end if;',
      '',
      'gi'
    );

    if cleaned is distinct from def then
      execute cleaned;
      changed := changed + 1;
    end if;
  end loop;

  raise notice 'quitar_minimo_envio: % firma(s) actualizada(s)', changed;
end;
$$;

comment on function public.cliente_crear_pedido_online(uuid, jsonb, text, text, text, text, text, text, text, boolean) is
  'Checkout online. Envío a domicilio sin mínimo de productos: el cliente paga el envío.';

commit;
