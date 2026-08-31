-- Pedido Nadro 1658128647824-01 (2026-08-30) — cola Recibir, borrador.
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
  where folio = '1658128647824-01' and coalesce(proveedor, '') ilike '%nadro%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Nadro 1658128647824-01 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('Nadro', '1658128647824-01', '2026-08-30', 5617.17, 'borrador',
              'Pedido Nadro 1658128647824-01 · entrega 31-ago · EAN de iNadro · cola Recibir; stock al confirmar pistola')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 5617.17, fecha = '2026-08-30', proveedor = 'Nadro', updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
        ('7502216803800', 'OMEPRAZOL 20 MG FCO 60 CAPS LGEN', 2, 26.82::numeric, 'FC-16803800'),
        ('7502216792555', 'OMEPRAZOL 20 MG 14 CAPS LGEN', 2, 9.50, null),
        ('7502216792760', 'OMEPRAZOL 20MG 30 CAPS LGEN', 2, 16.13, null),
        ('7506442700629', 'IRBESARTAN 300 MG 28 TAB LGEN', 3, 59.66, null),
        ('7501349022454', 'IRBESARTAN 150MG 14 TAB LGEN', 2, 50.00, 'FC-262F2A30'),
        ('7502216804708', 'IRBESARTAN 150MG FCO 28 TAB LGEN', 2, 97.42, null),
        ('7501349022492', 'IRBESARTAN 150MG 28 TAB LGEN', 2, 92.36, null),
        ('7506442700643', 'Irbesartán + Hidroclorotiazida Camber 150 mg + 12.5 mg Caja Con 28 Tabletas Genérico', 1, 91.86, null),
        ('7501361124013', 'TCO ODOLEX FRESH 150G', 1, 15.82, 'FC-61124013'),
        ('7501493888302', 'DOXICICLIN 100MG 10CAPS KEN LGEN', 1, 23.86, null),
        ('7502227870259', 'Roxidolin Doxiciclina 100 mg Caja Con 10 Cápsulas', 1, 21.15, null),
        ('7502227879597', 'Oxitetraciclina Caja Con 16 Cápsulas De 500 mg', 2, 70.00, null),
        ('7502009740442', 'Klarix Claritromicina De 250 mg Caja Con 10 Tabletas', 2, 44.88, null),
        ('7501125195105', 'Cefuroxima Caja Con Frasco Ámpula Con Polvo De 750mg y Ampolleta De 5ml', 2, 42.56, null),
        ('7501349022768', 'CEFALOTINA 1G S INY FA 5ML LGEN', 2, 56.28, null),
        ('7502216796737', 'PIOGLITAZONA 15 MG 7 TAB LGEN', 3, 13.35, 'EQ-ULT146'),
        ('7501300450210', 'Bactrim F 800/160 Mg 15 Tabletas', 1, 331.87, null),
        ('7501349028234', 'OMEPRAZOL 40MG S.INY. AMP LGEN', 1, 29.06, null),
        ('7501300450227', 'Bactrim 200/40 Mg Suspensión 100 Ml', 1, 188.44, null),
        ('7501054507901', 'POM LAB LABELLO FRESA 4.8 G', 2, 54.87, 'FC-45079011'),
        ('7501054504870', 'POM LAB LABELLO CLAS 4.8G', 2, 54.87, 'FC-54504870'),
        ('3337875784054', 'GEL CERAVE LIMP CONTR IMPER 236ML', 1, 273.91, null),
        ('7502256729917', 'Oxímetro Inhala Care Pulso Dedo Pantalla Led FS10E', 1, 303.80, null),
        ('7501019050473', 'TAS HUM TENA PARA ADULTO EG C', 1, 55.00, null),
        ('7501054549796', 'CRA CORP NIV MILK N EX', 4, 25.86, 'FC-54549796'),
        ('7501054503637', 'POM LAB LABELLO MED PROT4.8G', 1, 54.87, null),
        ('4005900948670', 'POM LAB LABELLO CARING-B RED 4.8G', 1, 79.58, null),
        ('7501349013223', 'DEFLAZACORT 30 MG 10 TAB LGEN', 1, 110.89, null),
        ('75073114', 'DESOD REX MEN CLIN CLEAN STICK 46G', 7, 55.68, null),
        ('6502400323252', 'SUEROX 8IONES LIMA-LIMON 630ML', 1, 12.42, 'FC-40032325'),
        ('75073107', 'DESOD REX WOM CLIN CLASS STICK 46G', 3, 55.68, null),
        ('7502268541491', 'ELECTROLIFE ZERO UVA 625 ML', 2, 19.36, null),
        ('7501019032424', 'TAMPONES SABA COMPACTOS SUPER C', 1, 31.39, null),
        ('650240053634', 'Alli Triple 50/.25/50/50 Mg 6 Tabletas', 3, 79.87, null),
        ('4005800631702', 'POM LAB EUCERIN PHS P', 1, 85.20, null),
        ('7501349029613', 'COMP B', 1, 55.76, null),
        ('7501019039355', 'PARCHES SABA TERMICOS 3 PZ', 1, 57.41, null),
        ('7501058715913', 'PICOT-PLUS 9 SB PVO EFERV', 1, 46.12, null),
        ('7501019068911', 'PANTY PROT SABA LGO 28', 1, 27.28, null),
        ('7502216798878', 'PIOGLITAZONA 30MG 7 TAB ULT LGEN', 6, 17.76, null),
        ('7501349026377', 'Gentamicina 160 Mg Solución Inyectable 2 Ml Genérico Amsa', 1, 12.71, null),
        ('7501165011649', 'BUSCAPINA 10MG 24 GRAG', 2, 172.04, null),
        ('7502321440013', 'Buscapina Duo Sanofi Hioscina/Paracetamol 10 mg/500 mg Caja Con 10 Tabletas', 1, 122.36, null),
        ('354312225140', 'VITACILINA 16 G UNG', 2, 25.19, null),
        ('354312225133', 'VITACILINA 28 G UNG', 3, 37.57, null),
        ('7501070600709', 'Syncol 500/25/15 Mg 12 Comprimidos', 1, 97.12, null),
        ('7501008498866', 'FLANAX 550 MG 6 TAB', 1, 105.00, null),
        ('7502001166066', 'BARMICIL COMP 40 G CRA SON LGEN', 1, 21.08, 'FC-01166066'),
        ('7501008499092', 'Flanax Nocto 220/25 mg 20 Comprimidos', 1, 130.50, null),
        ('7501008499412', 'FLANAX-660 660 MG 8 TAB', 1, 230.00, null)
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

    raise notice 'Recepcion Nadro 1658128647824-01 lista id=% — escanear caja por caja', v_id;
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
where r.folio = '1658128647824-01' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
