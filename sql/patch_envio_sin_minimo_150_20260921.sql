-- FarmaCapital — domicilio sin mínimo de $150 en productos.
-- El envío se cotiza después (DiDi/Uber) y el cliente liquida en Mi cuenta.
-- Quita el raise de cualquier firma viva de cliente_crear_pedido_online.
-- Idempotente: si la función ya no trae el texto, no la toca.

do $patch$
declare
  r record;
  def text;
  nueva text;
  n int := 0;
begin
  for r in
    select p.oid, p.oid::regprocedure as firma
    from pg_proc p
    join pg_namespace nsp on nsp.oid = p.pronamespace
    where nsp.nspname = 'public'
      and p.proname = 'cliente_crear_pedido_online'
  loop
    def := pg_get_functiondef(r.oid);
    nueva := regexp_replace(
      def,
      $re$if not v_es_pickup and v_(subtotal|total) < 150 then[[:space:]]*raise exception 'El pedido a domicilio tiene un mínimo de \$150[^']*';[[:space:]]*end if;$re$,
      '',
      'n'
    );
    if nueva is distinct from def then
      execute nueva;
      n := n + 1;
      raise notice 'Quitado mínimo $150 de %', r.firma;
    end if;
  end loop;

  if n = 0 then
    raise notice 'Ninguna firma de cliente_crear_pedido_online traía el mínimo de $150.';
  end if;
end
$patch$;
