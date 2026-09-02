-- Pedido Nadro 20260901 (2026-09-01) — cola Recibir, borrador.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.
-- Idempotente. Pegar en Supabase → SQL Editor → Run.

begin;

do $$
declare
  v_id bigint;
  r record;
  v_pid bigint;
begin
  select id into v_id
  from public.recepciones
  where folio = '20260901' and coalesce(proveedor, '') ilike '%nadro%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Nadro 20260901 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('Nadro', '20260901', '2026-09-01', 848.05, 'borrador',
              'Pedido Nadro 20260901 · PDF 01-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 848.05, fecha = '2026-09-01', proveedor = 'Nadro', updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
        ('7503014279552', 'PARCHES ALFA MED ADH 2TAM BCO C', 1, 53.15::numeric, 'FC-14279552'),
        ('7506494600038', 'RUMOQUIN N.F. 30 TAB LGEN', 1, 46.94, 'FC-94600038'),
        ('7506309873701', 'SH ACOND PANT RIZOS DEF2EN1 100ML', 2, 17.56, 'FC-09873701'),
        ('7506306256026', 'ACOND DOVE DERMA CARE H-ALIV400MLN', 1, 56.91, 'FC-06256026'),
        ('7506306223134', 'ACOND SEDAL LISO PERFECTO 300 ML', 1, 38.48, 'FC-06223134'),
        ('7501022150818', 'JBN GRISI CONCHA NACAR 125G', 1, 22.92, 'FC-22150818'),
        ('7501056371159', 'JBN DOVE EXFOLIAC DIARIA135G', 1, 28.00, 'FC-56371159'),
        ('7501943489165', 'JBN LIQ ESCUDO BLANCO NEUT 225ML', 1, 28.27, 'FC-43489165'),
        ('7501022150092', 'JBN GRISI LECHE DE BURRA 125G', 1, 22.96, 'FC-22150092'),
        ('037836051227', 'JBN LIQ GRISI CONCHA NACAR 450ML', 1, 55.31, 'FC-36051227'),
        ('7501022105191', 'JBN GRISI NEUTRO 100G', 2, 16.24, 'FC-22105191'),
        ('037836050282', 'JBN LIQ GRISI NEUTRO 450ML', 1, 55.31, 'FC-36050282'),
        ('3337875917810', 'BLOQ ANTHE UVAIR 50+ FLU INV 40ML', 1, 372.20, 'FC-75917810')
      ) as t(ean, nombre, qty, costo, sku)
    loop
      v_pid := null;
      if r.ean is not null and btrim(r.ean) <> '' then
        v_pid := public.fc_buscar_producto_escaneo(r.ean);
      end if;
      if v_pid is null and r.sku is not null then
        v_pid := public.fc_buscar_producto_escaneo(r.sku);
      end if;

      insert into public.recepcion_items (
        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
        origen, confirmado, lote_distinto, lote_id
      ) values (
        v_id, v_pid, nullif(btrim(r.ean), ''), r.nombre, r.qty, null, null, r.costo,
        (v_pid is null), 'pdf', false,
        (v_pid is not null and exists (
          select 1 from public.lotes l
          where l.producto_id = v_pid and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
        )),
        null
      );
    end loop;

    raise notice 'Recepcion Nadro 20260901 lista id=% — escanear caja por caja', v_id;
  end if;
end $$;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '20260901' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
