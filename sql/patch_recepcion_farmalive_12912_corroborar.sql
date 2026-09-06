-- Pedido Farmalive 12912 (2026-09-05) — cola Recibir, borrador.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.
-- Precio neto (Descto 2%). Bio Electro promo $0.01 consolidada en 4 pzas.
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
  where folio = '12912' and coalesce(proveedor, '') ilike '%farmalive%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Farmalive 12912 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('Farmalive', '12912', '2026-09-05', 3180.61, 'borrador',
              'Pedido Farmalive 12912 · Club Iztapalapa 1 · EAN del ticket · precio neto (−2%) · Bio Electro promo consolidada · cola Recibir; stock al confirmar pistola')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 3180.61, fecha = '2026-09-05', proveedor = 'Farmalive', updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
        ('7501019006692', 'TOA SANIT SABA BUENAS NOCHES C/24 | SCA', 1, 60.170::numeric, null),
        ('7501019036590', 'TOA SANIT SABA BUENAS NOCHES EXTRA C/12 | ESSITY', 1, 44.390, null),
        ('7501019006296', 'TOA SANIT SABA ULT INVISIBLE C/A C/10 | ESSITY', 1, 23.910, null),
        ('7501019031144', 'TOA SANIT SABA AMORE S/ALAS C/8 | SCA', 1, 9.900, null),
        ('7501019006104', 'TOA SANIT SABA INTIMA REG S/ALAS C/10 | SCA', 1, 13.520, null),
        ('7501019006418', 'TOA SANIT SABA INV BUENOS DIAS C/A C/14 | ESSITY', 1, 33.030, null),
        ('7503003406785', 'TORUNDA DE ALGODON QUIRMEX 75 GR | QUIRMEX', 2, 17.540, null),
        ('7509552828078', 'MASC CABELLO FRUCTIS BANANA 350 ML | FRABEL', 1, 56.940, null),
        ('7501048623006', 'PADS FACIAL PROTEC REDONDOS C/100 | DEGASA', 2, 21.265, null),
        ('7506552900247', 'ALMOHADILLAS RETANGULARES QUIRMEX C/100 | QUIRMEX', 1, 32.830, null),
        ('3614225108709', 'TINTE KOLESTON # 20 NEGRO | HFC PRESTI', 2, 53.900, null),
        ('3614225108747', 'TINTE KOLESTON # 40 CASTANO MEDIO | HFC PRESTI', 2, 53.900, null),
        ('3614225108761', 'TINTE KOLESTON # 466 BORGONA INTENSO | HFC PRESTI', 2, 53.900, null),
        ('3614225108877', 'TINTE KOLESTON # 70 RUBIO MEDIANO | HFC PRESTI', 2, 53.900, null),
        ('7506376000277', 'CRE VITACILINA FACIAL HUMECTANTE 100 GR | KSK', 2, 77.030, null),
        ('7506376000253', 'CRE VITACILINA FACIAL ANTIARRUGAS 100 GR | KSK', 2, 77.030, null),
        ('7502250343065', 'VITACILINA 16 GR 2X1 | KSK', 5, 24.304, null),
        ('7502250343072', 'VITACILINA 28 GR 2X1 | KSK', 4, 36.260, null),
        ('7501092793045', 'RIOPAN SOBRES C/20 | TAKEDA', 1, 268.720, null),
        ('650240070839', 'ALLIVIAX GARGANTA TAB C/6 | GENOMMA LAB', 2, 14.700, null),
        ('650240071775', 'JABON NORDIKO ORIGINAL 130 GR NVO | GENOMMA LAB', 1, 10.780, null),
        ('650240071799', 'JABON NORDIKO ICY BLAST 130 GR | GENOMMA LAB', 1, 15.580, null),
        ('650240052545', 'XL-3 TAB C/10 | GENOMMA LAB', 1, 30.380, null),
        ('7506376000260', 'CRE VITACILINA FACIAL ACLARADO 100 GR | KSK', 2, 77.030, null),
        ('7502250342570', 'VITACILINA SERUM FAC VITAMINA C 30ML | KSK', 1, 117.890, null),
        ('7502250342563', 'VITACILINA SERUM FAC COLAGENO 30ML | KSK', 1, 117.890, null),
        ('7502250343102', 'CRE VITACILINA FACIAL MELATONINA 100 GR | KSK', 1, 110.250, null),
        ('650240013805', 'ALLIVIAX 550 MG TAB C/10 | GENOMMA LAB', 3, 59.290, null),
        ('7501065628121', 'POMADA DE LA CAMPANA 19 GR | GENOMMA LAB', 2, 15.975, null),
        ('7501065628145', 'POMADA DE LA CAMPANA 35 GR | GENOMMA LAB', 2, 23.910, null),
        ('7501007532363', 'DRAMAMINE TAB C/24 | JOHNSON JOHNSON', 1, 154.840, null),
        ('7702018001071', 'RAST GILLETTE MACH3 C/1 | PG PERF', 1, 117.600, null),
        ('037836041389', 'CRE HINDS ALMENDRAS 90 ML | GRISI HNOS', 1, 17.640, null),
        ('037836041297', 'CRE HINDS INSPIR RESECA 90 ML | GRISI HNOS', 1, 17.640, null),
        ('037836041341', 'CRE HINDS NAT RESECA 90 ML | GRISI HNOS', 1, 17.640, null),
        ('7702018874781', 'RAST GILLETTE PRESTOBARBA3 MUJER 2PACK | PG PERF', 1, 41.940, null),
        ('7702018874729', 'RAST GILLETTE PRESTOBARBA3 HOMBRE 2PACK | PG PERF', 1, 65.170, null),
        ('7501125149221', 'ELECTROLIT FRESA-KIWI 625 ML | LAB PISA', 1, 20.090, null),
        ('7501125174797', 'ELECTROLIT MORA AZUL 625 ML | LAB PISA', 2, 20.090, null),
        ('7501125144851', 'ELECTROLIT UVA 625 ML | LAB PISA', 2, 20.090, null),
        ('7501125104268', 'ELECTROLIT FRESA 625 ML | LAB PISA', 1, 20.090, null),
        ('650240007651', 'BIO ELECTRO TAB C/24 | GENOMMA LAB', 4, 39.208, null)
      ) as t(ean, nombre, qty, costo, sku)
    loop
      v_pid := null;
      if r.ean is not null and btrim(r.ean) <> '' then
        v_pid := public.fc_buscar_producto_escaneo(r.ean);
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

    raise notice 'Recepcion Farmalive 12912 lista id=% — escanear caja por caja', v_id;
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
where r.folio = '12912' and coalesce(r.proveedor, '') ilike '%farmalive%'
order by i.id;
