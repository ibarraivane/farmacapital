-- Pedido Nadro 20260901 (2026-09-01) — altas + cola Recibir, una sola pasta.
-- Folio de trabajo 20260901 (PDF NADRO 01-09-26; si tienes el folio iNadro, avísame).
-- 10 altas stock 0. 3 ya estaban: solo costo. Ticket en borrador.
-- No suma stock: pistola + MMAA de la caja. No inventar 0000.
-- Idempotente. Pegar en Supabase → SQL Editor → Run.
-- No lo vuelvas a pegar después de escanear: borra el avance de la pistola.

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_sku text;
  v_id bigint;
  v_creados int := 0;
  v_existian int := 0;
begin
  for r in
    select * from (values
        ('7503014279552', 'FC-14279552', 'Parches adhesivos Alfa Med 2 tamaños blanco', 53.15::numeric, 71, 'marca', 'Botiquín', false),
        ('7506494600038', 'FC-94600038', 'Rumoquin NF 30 tabletas LGEN', 46.94, 118, 'generico', 'Medicamentos', false),
        ('7506309873701', 'FC-09873701', 'Pantene Rizos Definidos 2en1 100 ml', 17.56, 24, 'marca', 'Cuidado personal', false),
        ('7506306256026', 'FC-06256026', 'Dove Derma Care Hidratación + Alivio acondicionador 400 ml', 56.91, 76, 'marca', 'Cuidado personal', false),
        ('7506306223134', 'FC-06223134', 'Sedal Liso Perfecto acondicionador 300 ml', 38.48, 52, 'marca', 'Cuidado personal', false),
        ('7501022150818', 'FC-22150818', 'Jabón Grisi Concha Nácar 125 g', 22.92, 31, 'marca', 'Cuidado personal', false),
        ('7501056371159', 'FC-56371159', 'Jabón Dove Exfoliación diaria 135 g', 28.00, 38, 'marca', 'Cuidado personal', false),
        ('7501943489165', 'FC-43489165', 'Jabón líquido Escudo blanco neutro 225 ml', 28.27, 38, 'marca', 'Cuidado personal', false),
        ('7501022150092', 'FC-22150092', 'Jabón Grisi Leche de Burra 125 g', 22.96, 31, 'marca', 'Cuidado personal', false),
        ('037836051227', 'FC-36051227', 'Jabón líquido Grisi Concha Nácar 450 ml', 55.31, 74, 'marca', 'Cuidado personal', false),
        ('7501022105191', 'FC-22105191', 'Jabón Grisi Neutro 100 g', 16.24, 22, 'marca', 'Cuidado personal', false),
        ('037836050282', 'FC-36050282', 'Jabón líquido Grisi Neutro 450 ml', 55.31, 74, 'marca', 'Cuidado personal', false),
        ('3337875917810', 'FC-75917810', 'Anthelios UV Air fluido invisible 50+ 40 ml', 372.20, 497, 'marca', 'Cuidado personal', false)
    ) as t(ean, sku, nombre, costo, precio, tipo, categoria, receta)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    if v_pid is not null then
      v_existian := v_existian + 1;
      update public.productos
      set costo = r.costo, updated_at = now()
      where id = v_pid and (costo is distinct from r.costo);
    else
      v_sku := r.sku;
      if exists (
        select 1 from public.productos p
        where p.sku = v_sku
          and coalesce(p.codigo_barras, '') <> r.ean
      ) then
        v_sku := 'FC-ND-' || right(r.ean, 8);
      end if;
      insert into public.productos (
        nombre, sku, codigo_barras, categoria, tipo, descripcion,
        costo, precio, stock, stock_minimo, activo, requiere_receta
      ) values (
        r.nombre, v_sku, r.ean, r.categoria, r.tipo,
        'Alta Nadro 20260901 · 2026-09-01 · listo para pistola',
        r.costo, r.precio, 0, 1, true, r.receta
      );
      v_creados := v_creados + 1;
    end if;
  end loop;

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

    raise notice 'Nadro 20260901: altas=% ya=% recepcion id=% — escanear caja por caja',
      v_creados, v_existian, v_id;
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
