-- Pedido Levic 1020554215 (2026-08-25) — lo deja en la cola de Recibir, en borrador.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido surtido no trae lote; se queda en null hasta que llegue la factura.
-- Idempotente. Pegar en Supabase.

begin;

do $$
declare
  v_id bigint;
  r record;
  v_pid bigint;
begin
  select id into v_id
  from public.recepciones
  where folio = '1020554215' and coalesce(proveedor, '') ilike '%levic%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Levic 1020554215 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('Levic', '1020554215', '2026-08-25', 1377.28, 'borrador',
              'Pedido Levic 1020554215 · cola Recibir; stock al confirmar pistola')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 1377.28, fecha = '2026-08-25', updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
        ('7501349012943', 'FLUCONAZOL 1 CAPS 150 MG', 4, 13.61::numeric, 'FC-5BC5F234'),
        ('7501349027329', 'DEXAMETASONA 1 FA 8MG/2 ML', 4, 9.28, 'EQ-AMS253'),
        ('7501349020139', 'FLUCONAZOL 10 CAP 100 MG', 1, 18.29, null),
        ('7502209857032', 'FLUCONAZOL 10 CAPS 100 MG', 1, 17.35, null),
        ('7501088505126', 'NEURALIN INY 2 AMP 200MG/100MG/5GM', 1, 148.89, 'FC-8505126'),
        ('650240029165', 'LOMECAN DUO 3 OVULOS Y CREMA 200 MG', 2, 176.10, null),
        ('7501058714312', 'TEMPRA GOTAS UVA 10 G 30 ML', 1, 168.72, null),
        ('7502227879610', 'DUET FLEXENOL NF 16 TAB 275/300 MG', 5, 30.06, null),
        ('7501300407047', 'FEBRAX 15 TAB 275/300 MG', 1, 204.38, null),
        ('7501300407054', 'FEBRAX SUPOSITORIOS 1CJA C/5 100/200 MG', 1, 128.75, null),
        ('7501482200016', 'OMEPRAZOL (AKTYZAR) 120 CAPS 20MG', 2, 48.42, 'FC-82200016')
      ) as t(ean, nombre, qty, costo, sku)
    loop
      v_pid := public.fc_buscar_producto_escaneo(r.ean);
      if v_pid is null and r.sku is not null then
        v_pid := public.fc_buscar_producto_escaneo(r.sku);
      end if;

      insert into public.recepcion_items (
        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
        origen, confirmado, lote_distinto, lote_id
      ) values (
        v_id, v_pid, r.ean, r.nombre, r.qty, null, null, r.costo,
        (v_pid is null), 'pdf', false,
        (v_pid is not null and exists (
          select 1 from public.lotes l
          where l.producto_id = v_pid and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
        )),
        null
      );
    end loop;

    raise notice 'Recepcion Levic 1020554215 lista id=% — escanear caja por caja', v_id;
  end if;
end $$;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 42) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '1020554215' and coalesce(r.proveedor, '') ilike '%levic%'
order by i.id;
