-- ============================================================================
-- FARMA CAPITAL — Dejar el Anthelios UV Air listo para Recibir (sin inventar lote)
--
-- «Sin lotes» en POS = ficha sí, piezas no. El stock de este renglón NO entra
-- al pegar el alta: entra al escanear la caja y teclear el MMAA de la tapa.
-- 0000 es inválido. Si no hay fecha en la caja, el renglón se queda gris.
--
-- Este script:
--   1) Diagnostica producto / lotes / renglón del ticket Nadro 20260901.
--   2) Enlaza el EAN 3337875917810 a la ficha (ya no «pendiente de alta»).
--   3) Si el pedido ya se cerró sin esta caja, abre un borrador vivo
--      folio 20260901-UVAIR para terminar con la pistola.
--
-- NO suma stock. NO inventa caducidad ni número de lote.
-- Requiere haber corrido sql/patch_alta_anthelios_uvair_nadro_20260901.sql
-- Pegar en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

do $$
declare
  v_ean text := '3337875917810';
  v_pid bigint;
  v_rid bigint;
  v_estado text;
  v_item bigint;
  v_confirmado boolean;
  v_lote_ok boolean;
  v_nuevo boolean := false;
begin
  v_pid := public.fc_buscar_producto_escaneo(v_ean);
  if v_pid is null then
    raise exception 'Falta la ficha. Corre antes sql/patch_alta_anthelios_uvair_nadro_20260901.sql';
  end if;

  select exists (
    select 1 from public.lotes l
     where l.producto_id = v_pid
       and coalesce(l.activo, true)
       and coalesce(l.cantidad_actual, 0) > 0
  ) into v_lote_ok;

  if v_lote_ok then
    raise notice 'Ya hay lote con piezas en producto %. POS no debería decir Sin lotes.', v_pid;
    return;
  end if;

  select r.id, r.estado into v_rid, v_estado
    from public.recepciones r
   where r.folio = '20260901'
     and coalesce(r.proveedor, '') ilike '%nadro%'
   order by case when r.estado in ('borrador', 'pendiente_alta', 'parcial') then 0 else 1 end, r.id desc
   limit 1;

  if v_rid is not null then
    select i.id, i.confirmado into v_item, v_confirmado
      from public.recepcion_items i
     where i.recepcion_id = v_rid
       and (
             i.codigo_escaneado in (v_ean, 'FC-75917810')
          or i.producto_id = v_pid
          or i.nombre_snapshot ilike '%BLOQ ANTHE UVAIR%'
          or i.nombre_snapshot ilike '%Anthelios UV Air%'
           )
     order by i.id
     limit 1;
  end if;

  -- Pedido ya cerrado: no se reabre. Si esta caja no entró, otro folio vivo.
  if v_rid is not null
     and v_estado not in ('borrador', 'pendiente_alta', 'parcial') then
    if coalesce(v_confirmado, false) then
      raise notice 'Nadro 20260901 ya cerrado y este renglón salió confirmado (item %). Revisar lotes; no se toca el pedido.', v_item;
      return;
    end if;
    v_rid := null;
    v_item := null;
  end if;

  if v_rid is null then
    select r.id, r.estado into v_rid, v_estado
      from public.recepciones r
     where r.folio = '20260901-UVAIR'
       and coalesce(r.proveedor, '') ilike '%nadro%'
     order by r.id desc
     limit 1;

    if v_rid is not null and v_estado not in ('borrador', 'pendiente_alta', 'parcial') then
      v_rid := null;
    end if;

    if v_rid is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values (
        'Nadro',
        '20260901-UVAIR',
        '2026-09-01',
        372.20,
        'borrador',
        'Faltante Nadro 20260901 · BLOQ ANTHE UVAIR · 1 caja · stock al escanear + MMAA de la tapa'
      )
      returning id into v_rid;
      v_nuevo := true;
      v_estado := 'borrador';
    end if;
  end if;

  if v_item is null then
    select i.id, i.confirmado into v_item, v_confirmado
      from public.recepcion_items i
     where i.recepcion_id = v_rid
       and (
             i.codigo_escaneado in (v_ean, 'FC-75917810')
          or i.producto_id = v_pid
           )
     order by i.id
     limit 1;
  end if;

  if v_item is null then
    insert into public.recepcion_items (
      recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
      cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
      origen, confirmado, lote_distinto, lote_id
    ) values (
      v_rid,
      v_pid,
      v_ean,
      'La Roche-Posay Anthelios UV Air FPS 50+ Protector Solar Ligero 40 ml',
      1,
      null,
      null,
      372.20,
      false,
      'pdf',
      false,
      false,
      null
    )
    returning id into v_item;
  else
    update public.recepcion_items
       set producto_id = v_pid,
           codigo_escaneado = v_ean,
           pendiente_alta = false,
           nombre_snapshot = coalesce(
             nullif(nombre_snapshot, ''),
             'La Roche-Posay Anthelios UV Air FPS 50+ Protector Solar Ligero 40 ml'
           )
     where id = v_item
       and coalesce(confirmado, false) = false;
  end if;

  raise notice 'Anthelios listo para pistola recepcion=% item=% nuevo_folio=%',
    v_rid, v_item, v_nuevo;
end
$$;

commit;

-- Diagnóstico: por qué el POS dice «Sin lotes»
select
  'producto' as tipo,
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.activo,
  p.stock,
  (select coalesce(sum(l.cantidad_actual), 0)
     from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)) as piezas_lote,
  (select count(*) from public.lotes l where l.producto_id = p.id) as filas_lote
from public.productos p
where p.codigo_barras = '3337875917810'
   or p.sku in ('FC-75917810', 'FC-ND-75917810')
   or p.nombre ilike '%BLOQ ANTHE UVAIR%'
   or p.nombre ilike '%Anthelios UV Air%';

select
  'ticket' as tipo,
  r.id as recepcion_id,
  r.folio,
  r.estado as estado_pedido,
  i.id as item_id,
  i.codigo_escaneado as ean,
  i.confirmado,
  i.pendiente_alta,
  i.fecha_caducidad,
  i.lote_id,
  i.cantidad
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
where i.codigo_escaneado in ('3337875917810', 'FC-75917810')
   or i.nombre_snapshot ilike '%BLOQ ANTHE UVAIR%'
   or i.nombre_snapshot ilike '%Anthelios UV Air%'
   or i.nombre_snapshot ilike '%ANTHELIOS%'
order by r.id, i.id;
