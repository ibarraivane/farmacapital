-- Faltantes Nadro 1658128647824-01 — cola Recibir, borrador nuevo.
-- La recepción folio 1658128647824-01 ya está en descuadre (46/50 confirmados):
-- NO se reabre ni se toca. El stock de esas 46 ya entró.
-- Este patch abre folio 1658128647824-01-FALT solo con los EAN que faltan.
-- SIN do $$. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el FALT siga en borrador.
-- Pegar TODO en Supabase → SQL Editor → Run.

begin;

create temp table _fc_rx_nadro165812864782401 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_rx_nadro165812864782401 (linea, ean, sku, nombre, qty, costo) values
  (1, '7502216803800', 'FC-16803800', 'OMEPRAZOL 20 MG FCO 60 CAPS LGEN', 2, 26.82),
  (2, '7502216792555', null, 'OMEPRAZOL 20 MG 14 CAPS LGEN', 2, 9.50),
  (3, '7502216792760', null, 'OMEPRAZOL 20MG 30 CAPS LGEN', 2, 16.13),
  (4, '7506442700629', null, 'IRBESARTAN 300 MG 28 TAB LGEN', 3, 59.66),
  (5, '7501349022454', 'FC-262F2A30', 'IRBESARTAN 150MG 14 TAB LGEN', 2, 50.00),
  (6, '7502216804708', null, 'IRBESARTAN 150MG FCO 28 TAB LGEN', 2, 97.42),
  (7, '7501349022492', null, 'IRBESARTAN 150MG 28 TAB LGEN', 2, 92.36),
  (8, '7506442700643', null, 'Irbesartán + Hidroclorotiazida Camber 150 mg + 12.5 mg Caja Con 28 Tabletas Genérico', 1, 91.86),
  (9, '7501361124013', 'FC-61124013', 'TCO ODOLEX FRESH 150G', 1, 15.82),
  (10, '7501493888302', null, 'DOXICICLIN 100MG 10CAPS KEN LGEN', 1, 23.86),
  (11, '7502227870259', null, 'Roxidolin Doxiciclina 100 mg Caja Con 10 Cápsulas', 1, 21.15),
  (12, '7502227879597', null, 'Oxitetraciclina Caja Con 16 Cápsulas De 500 mg', 2, 70.00),
  (13, '7502009740442', null, 'Klarix Claritromicina De 250 mg Caja Con 10 Tabletas', 2, 44.88),
  (14, '7501125195105', null, 'Cefuroxima Caja Con Frasco Ámpula Con Polvo De 750mg y Ampolleta De 5ml', 2, 42.56),
  (15, '7501349022768', null, 'CEFALOTINA 1G S INY FA 5ML LGEN', 2, 56.28),
  (16, '7502216796737', 'EQ-ULT146', 'PIOGLITAZONA 15 MG 7 TAB LGEN', 3, 13.35),
  (17, '7501300450210', null, 'Bactrim F 800/160 Mg 15 Tabletas', 1, 331.87),
  (18, '7501349028234', null, 'OMEPRAZOL 40MG S.INY. AMP LGEN', 1, 29.06),
  (19, '7501300450227', null, 'Bactrim 200/40 Mg Suspensión 100 Ml', 1, 188.44),
  (20, '7501054507901', 'FC-45079011', 'POM LAB LABELLO FRESA 4.8 G', 2, 54.87),
  (21, '7501054504870', 'FC-54504870', 'POM LAB LABELLO CLAS 4.8G', 2, 54.87),
  (22, '3337875784054', null, 'GEL CERAVE LIMP CONTR IMPER 236ML', 1, 273.91),
  (23, '7502256729917', null, 'Oxímetro Inhala Care Pulso Dedo Pantalla Led FS10E', 1, 303.80),
  (24, '7501019050473', null, 'TAS HUM TENA PARA ADULTO EG C', 1, 55.00),
  (25, '7501054549796', 'FC-54549796', 'CRA CORP NIV MILK N EX', 4, 25.86),
  (26, '7501054503637', null, 'POM LAB LABELLO MED PROT4.8G', 1, 54.87),
  (27, '4005900948670', null, 'POM LAB LABELLO CARING-B RED 4.8G', 1, 79.58),
  (28, '7501349013223', null, 'DEFLAZACORT 30 MG 10 TAB LGEN', 1, 110.89),
  (29, '75073114', null, 'DESOD REX MEN CLIN CLEAN STICK 46G', 7, 55.68),
  (30, '6502400323252', 'FC-40032325', 'SUEROX 8IONES LIMA-LIMON 630ML', 1, 12.42),
  (31, '75073107', null, 'DESOD REX WOM CLIN CLASS STICK 46G', 3, 55.68),
  (32, '7502268541491', null, 'ELECTROLIFE ZERO UVA 625 ML', 2, 19.36),
  (33, '7501019032424', null, 'TAMPONES SABA COMPACTOS SUPER C', 1, 31.39),
  (34, '650240053634', null, 'Alli Triple 50/.25/50/50 Mg 6 Tabletas', 3, 79.87),
  (35, '4005800631702', null, 'POM LAB EUCERIN PHS P', 1, 85.20),
  (36, '7501349029613', null, 'COMP B', 1, 55.76),
  (37, '7501019039355', null, 'PARCHES SABA TERMICOS 3 PZ', 1, 57.41),
  (38, '7501058715913', null, 'PICOT-PLUS 9 SB PVO EFERV', 1, 46.12),
  (39, '7501019068911', null, 'PANTY PROT SABA LGO 28', 1, 27.28),
  (40, '7502216798878', null, 'PIOGLITAZONA 30MG 7 TAB ULT LGEN', 6, 17.76),
  (41, '7501349026377', null, 'Gentamicina 160 Mg Solución Inyectable 2 Ml Genérico Amsa', 1, 12.71),
  (42, '7501165011649', null, 'BUSCAPINA 10MG 24 GRAG', 2, 172.04),
  (43, '7502321440013', null, 'Buscapina Duo Sanofi Hioscina/Paracetamol 10 mg/500 mg Caja Con 10 Tabletas', 1, 122.36),
  (44, '354312225140', null, 'VITACILINA 16 G UNG', 2, 25.19),
  (45, '354312225133', null, 'VITACILINA 28 G UNG', 3, 37.57),
  (46, '7501070600709', null, 'Syncol 500/25/15 Mg 12 Comprimidos', 1, 97.12),
  (47, '7501008498866', null, 'FLANAX 550 MG 6 TAB', 1, 105.00),
  (48, '7502001166066', 'FC-01166066', 'BARMICIL COMP 40 G CRA SON LGEN', 1, 21.08),
  (49, '7501008499092', null, 'Flanax Nocto 220/25 mg 20 Comprimidos', 1, 130.50),
  (50, '7501008499412', null, 'FLANAX-660 660 MG 8 TAB', 1, 230.00);

-- EAN del pedido que NO están en el folio original (descuadre).
create temp table _fc_falt on commit drop as
select t.*
from _fc_rx_nadro165812864782401 t
where nullif(btrim(t.ean), '') is not null
  and not exists (
    select 1
    from public.recepcion_items i
    join public.recepciones r on r.id = i.recepcion_id
    where r.folio = '1658128647824-01'
      and coalesce(r.proveedor, '') ilike '%nadro%'
      and i.codigo_escaneado = t.ean
  );

-- Abrir borrador FALT solo si hay faltantes y aún no existe ese folio.
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '1658128647824-01-FALT',
  '2026-08-30',
  (select coalesce(sum(f.qty * f.costo), 0) from _fc_falt f),
  'borrador',
  'Faltantes Nadro 1658128647824-01 · no reabre el descuadre · stock al escanear + MMAA de la caja'
where exists (select 1 from _fc_falt)
  and not exists (
    select 1 from public.recepciones
    where folio = '1658128647824-01-FALT'
      and coalesce(proveedor, '') ilike '%nadro%'
  );

update public.recepciones
set
  total_ticket = (select coalesce(sum(f.qty * f.costo), 0) from _fc_falt f),
  fecha = '2026-08-30',
  proveedor = 'Nadro',
  notas = 'Faltantes Nadro 1658128647824-01 · no reabre el descuadre · stock al escanear + MMAA de la caja',
  updated_at = now()
where folio = '1658128647824-01-FALT'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '1658128647824-01-FALT'
  and coalesce(r.proveedor, '') ilike '%nadro%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(btrim(t.ean), ''),
  t.nombre,
  t.qty,
  null,
  null,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_falt t
join public.recepciones r
  on r.folio = '1658128647824-01-FALT'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), ''))
      else null end
  ) as pid
) v on true
order by t.linea;

-- Si no había faltantes, quita un FALT vacío en borrador.
delete from public.recepciones r
where r.folio = '1658128647824-01-FALT'
  and coalesce(r.proveedor, '') ilike '%nadro%'
  and r.estado = 'borrador'
  and not exists (
    select 1 from public.recepcion_items i where i.recepcion_id = r.id
  );

commit;

select
  r.id as recepcion_id,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%nadro%'
  and r.folio in ('1658128647824-01', '1658128647824-01-FALT')
group by r.id, r.folio, r.estado, r.total_ticket
order by r.id;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '1658128647824-01-FALT'
  and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
