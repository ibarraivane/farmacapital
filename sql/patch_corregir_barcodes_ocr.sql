-- ============================================================================
-- Corregir códigos de barras corruptos por OCR
-- 127 productos · EAN-13 válido · sin colisión
-- NO modifica precio, costo, stock ni lotes
-- Generado por scripts/generar_patch_corregir_barcodes_ocr.py
-- ============================================================================

begin;

-- FC-00740024 · Silka Medic Gel
update public.productos p
set codigo_barras = '650240007408'
where p.sku = 'FC-00740024'
  and p.codigo_barras in ('65024000740024', '6502400074024')
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '650240007408'
      and o.id <> p.id
  );

-- FC-30133021 · Iri (Inmunoglobulina)
update public.productos p
set codigo_barras = '7501123013302'
where p.sku = 'FC-30133021'
  and p.codigo_barras = '75011230133021'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501123013302'
      and o.id <> p.id
  );

-- FC-12225027 · Derman Crema
update public.productos p
set codigo_barras = '7501354312250'
where p.sku = 'FC-12225027'
  and p.codigo_barras = '7501354312225027'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501354312250'
      and o.id <> p.id
  );

-- FC-85103015 · Toallitas Humedas Bebin Super
update public.productos p
set codigo_barras = '6195851030154'
where p.sku = 'FC-85103015'
  and p.codigo_barras = '619585103015'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6195851030154'
      and o.id <> p.id
  );

-- FC-54525051 · Tempra Forte C/24
update public.productos p
set codigo_barras = '7501095452505'
where p.sku = 'FC-54525051'
  and p.codigo_barras = '75010954525051'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501095452505'
      and o.id <> p.id
  );

-- FC-71829601 · Tribedoce
update public.productos p
set codigo_barras = '7501501537161'
where p.sku = 'FC-71829601'
  and p.codigo_barras = '75015015371829601'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501501537161'
      and o.id <> p.id
  );

-- FC-40010712 · Tukol-D jarabe
update public.productos p
set codigo_barras = '6502400107128'
where p.sku = 'FC-40010712'
  and p.codigo_barras = '650240010712'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400107128'
      and o.id <> p.id
  );

-- FC-51078461 · Nan 1 Pro 1
update public.productos p
set codigo_barras = '7506475107846'
where p.sku = 'FC-51078461'
  and p.codigo_barras = '75064751078461'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7506475107846'
      and o.id <> p.id
  );

-- FC-51078531 · Nan Nestle Bolsa Nestle Bolsa
update public.productos p
set codigo_barras = '7506475107853'
where p.sku = 'FC-51078531'
  and p.codigo_barras = '75064751078531'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7506475107853'
      and o.id <> p.id
  );

-- FC-40036354 · Genoprazol Tab
update public.productos p
set codigo_barras = '6502400363548'
where p.sku = 'FC-40036354'
  and p.codigo_barras = '650240036354'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400363548'
      and o.id <> p.id
  );

-- FC-51448511 · Electrolit Uva
update public.productos p
set codigo_barras = '7501125144851'
where p.sku = 'FC-51448511'
  and p.codigo_barras = '75011251448511'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501125144851'
      and o.id <> p.id
  );

-- FC-95201021 · Pomada Hipoglos Pac
update public.productos p
set codigo_barras = '7501289520102'
where p.sku = 'FC-95201021'
  and p.codigo_barras = '75012895201021'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501289520102'
      and o.id <> p.id
  );

-- FC-01508201 · Antiflu-Des
update public.productos p
set codigo_barras = '7505253015021'
where p.sku = 'FC-01508201'
  and p.codigo_barras = '750525301508201'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7505253015021'
      and o.id <> p.id
  );

-- FC-06134531 · Afrin DTC rojo spray
update public.productos p
set codigo_barras = '7501050613453'
where p.sku = 'FC-06134531'
  and p.codigo_barras = '75010506134531'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501050613453'
      and o.id <> p.id
  );

-- FC-47624171 · Nailex Desenterrador Unas Desenterrador Unas
update public.productos p
set codigo_barras = '7502234762417'
where p.sku = 'FC-47624171'
  and p.codigo_barras = '75022347624171'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502234762417'
      and o.id <> p.id
  );

-- FC-50002301 · Neo-Melubrina metamizol tabletas C/10
update public.productos p
set codigo_barras = '7501165000230'
where p.sku = 'FC-50002301'
  and p.codigo_barras = '75011650002301'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501165000230'
      and o.id <> p.id
  );

-- FC-34092301 · Syncol Max tabletas
update public.productos p
set codigo_barras = '7501210734301'
where p.sku = 'FC-34092301'
  and p.codigo_barras = '7501210734092301'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501210734301'
      and o.id <> p.id
  );

-- FC-50724298 · Tempra jarabe
update public.productos p
set codigo_barras = '7501250105079'
where p.sku = 'FC-50724298'
  and p.codigo_barras = '75012501050724298'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501250105079'
      and o.id <> p.id
  );

-- FC-54521161 · Tempra 500 mg
update public.productos p
set codigo_barras = '7501095452116'
where p.sku = 'FC-54521161'
  and p.codigo_barras = '75010954521161'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501095452116'
      and o.id <> p.id
  );

-- FC-58203691 · Hilo dental expanding
update public.productos p
set codigo_barras = '7502235820369'
where p.sku = 'FC-58203691'
  and p.codigo_barras = '75022358203691'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502235820369'
      and o.id <> p.id
  );

-- FC-40006647 · Ultra Bengue Gel
update public.productos p
set codigo_barras = '6502400066470'
where p.sku = 'FC-40006647'
  and p.codigo_barras = '650240006647'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400066470'
      and o.id <> p.id
  );

-- FC-40032264 · Suerox 8 Iones Eresa-Kiwi 630 ML
update public.productos p
set codigo_barras = '6502400322644'
where p.sku = 'FC-40032264'
  and p.codigo_barras = '650240032264'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400322644'
      and o.id <> p.id
  );

-- FC-40032271 · Suerox 8 Iones Uva 630 ML
update public.productos p
set codigo_barras = '6502400322712'
where p.sku = 'FC-40032271'
  and p.codigo_barras = '650240032271'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400322712'
      and o.id <> p.id
  );

-- FC-50959781 · Centrum Performance
update public.productos p
set codigo_barras = '7501065095978'
where p.sku = 'FC-50959781'
  and p.codigo_barras = '75010650959781'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501065095978'
      and o.id <> p.id
  );

-- FC-40032295 · Suerox 8 Iones Mora Azul 630 ML
update public.productos p
set codigo_barras = '6502400322958'
where p.sku = 'FC-40032295'
  and p.codigo_barras = '650240032295'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400322958'
      and o.id <> p.id
  );

-- FC-40066306 · Suerox 8 Iones Fresa 630 ML
update public.productos p
set codigo_barras = '6502400663068'
where p.sku = 'FC-40066306'
  and p.codigo_barras = '650240066306'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400663068'
      and o.id <> p.id
  );

-- FC-40074455 · Suerox 8 Iones Uva Mora Azul 630 ML
update public.productos p
set codigo_barras = '6502400744552'
where p.sku = 'FC-40074455'
  and p.codigo_barras = '650240074455'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400744552'
      and o.id <> p.id
  );

-- FC-03405381 · Vitacilina Ungüento
update public.productos p
set codigo_barras = '7500225034031'
where p.sku = 'FC-03405381'
  and p.codigo_barras = '750022503405381'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7500225034031'
      and o.id <> p.id
  );

-- FC-06247327 · Afrin No Drip extra humectante spray
update public.productos p
set codigo_barras = '7501050624732'
where p.sku = 'FC-06247327'
  and p.codigo_barras = '75010506247327'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501050624732'
      and o.id <> p.id
  );

-- FC-12225164 · Vitacilina Bebé Pomada
update public.productos p
set codigo_barras = '3543122251648'
where p.sku = 'FC-12225164'
  and p.codigo_barras = '354312225164'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '3543122251648'
      and o.id <> p.id
  );

-- FC-47640531 · Nailex El Recuperador
update public.productos p
set codigo_barras = '7502234764053'
where p.sku = 'FC-47640531'
  and p.codigo_barras = '75022347640531'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502234764053'
      and o.id <> p.id
  );

-- FC-60403681 · Desenfriol
update public.productos p
set codigo_barras = '7502276040368'
where p.sku = 'FC-60403681'
  and p.codigo_barras = '75022760403681'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502276040368'
      and o.id <> p.id
  );

-- FC-03430721 · Vitacilina 28 Crema
update public.productos p
set codigo_barras = '7502250343072'
where p.sku = 'FC-03430721'
  and p.codigo_barras = '750222503430721'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502250343072'
      and o.id <> p.id
  );

-- FC-40010538 · Next Tab
update public.productos p
set codigo_barras = '6502400105384'
where p.sku = 'FC-40010538'
  and p.codigo_barras = '650240010538'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400105384'
      and o.id <> p.id
  );

-- FC-40015366 · Nasalub Sol
update public.productos p
set codigo_barras = '6502400153668'
where p.sku = 'FC-40015366'
  and p.codigo_barras = '650240015366'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400153668'
      and o.id <> p.id
  );

-- FC-40017100 · Xl-3 Vr
update public.productos p
set codigo_barras = '6502400171006'
where p.sku = 'FC-40017100'
  and p.codigo_barras = '650240017100'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400171006'
      and o.id <> p.id
  );

-- FC-40032325 · Suerox 8 Iones Lima Limón 630 ML
update public.productos p
set codigo_barras = '6502400323252'
where p.sku = 'FC-40032325'
  and p.codigo_barras = '650240032325'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400323252'
      and o.id <> p.id
  );

-- FC-40035395 · Suerox 8 Iones Coco 630 ML
update public.productos p
set codigo_barras = '6502400353952'
where p.sku = 'FC-40035395'
  and p.codigo_barras = '650240035395'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400353952'
      and o.id <> p.id
  );

-- FC-51747971 · Electrolit Mora Azul
update public.productos p
set codigo_barras = '7501125174797'
where p.sku = 'FC-51747971'
  and p.codigo_barras = '75011251747971'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501125174797'
      and o.id <> p.id
  );

-- FC-80596011 · Aderogyl Amp
update public.productos p
set codigo_barras = '3664798059601'
where p.sku = 'FC-80596011'
  and p.codigo_barras = '36647980596011'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '3664798059601'
      and o.id <> p.id
  );

-- FC-83683367 · Condón Sico Rojo Feel
update public.productos p
set codigo_barras = '7501058363367'
where p.sku = 'FC-83683367'
  and p.codigo_barras = '75010583683367'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501058363367'
      and o.id <> p.id
  );

-- FC-92730451 · Riopan Sobres
update public.productos p
set codigo_barras = '7507201092351'
where p.sku = 'FC-92730451'
  and p.codigo_barras = '7507201092730451'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7507201092351'
      and o.id <> p.id
  );

-- FC-83146207 · Fazolin F (nafazolina)
update public.productos p
set codigo_barras = '7800831462076'
where p.sku = 'FC-83146207'
  and p.codigo_barras = '780083146207'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7800831462076'
      and o.id <> p.id
  );

-- FC-75354321 · Tylenol
update public.productos p
set codigo_barras = '7501007535432'
where p.sku = 'FC-75354321'
  and p.codigo_barras = '75010075354321'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501007535432'
      and o.id <> p.id
  );

-- FC-75125811 · Evenflo Colors
update public.productos p
set codigo_barras = '7501027512581'
where p.sku = 'FC-75125811'
  and p.codigo_barras = '75010275125811'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501027512581'
      and o.id <> p.id
  );

-- FC-75163051 · Evenflo Ensueno Azul
update public.productos p
set codigo_barras = '7501027516305'
where p.sku = 'FC-75163051'
  and p.codigo_barras = '75010275163051'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501027516305'
      and o.id <> p.id
  );

-- FC-23001331 · Sr. Ting pomada (ácido bórico)
update public.productos p
set codigo_barras = '7501072300133'
where p.sku = 'FC-23001331'
  and p.codigo_barras = '75010723001331'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501072300133'
      and o.id <> p.id
  );

-- FC-79071241 · Bisolvon Infantil
update public.productos p
set codigo_barras = '7501037907124'
where p.sku = 'FC-79071241'
  and p.codigo_barras = '75010379071241'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501037907124'
      and o.id <> p.id
  );

-- FC-23273451 · Jeringa insulina 0.5 ml
update public.productos p
set codigo_barras = '7506022327345'
where p.sku = 'FC-23273451'
  and p.codigo_barras = '75060223273451'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7506022327345'
      and o.id <> p.id
  );

-- FC-84335531 · Aspirina Forte C/24 Caf Iaspirina
update public.productos p
set codigo_barras = '7501008433553'
where p.sku = 'FC-84335531'
  and p.codigo_barras = '75010084335531'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501008433553'
      and o.id <> p.id
  );

-- FC-29003221 · Quirmex
update public.productos p
set codigo_barras = '7506552900322'
where p.sku = 'FC-29003221'
  and p.codigo_barras = '75065529003221'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7506552900322'
      and o.id <> p.id
  );

-- FC-84999001 · Alka-Seltzer
update public.productos p
set codigo_barras = '7501008499900'
where p.sku = 'FC-84999001'
  and p.codigo_barras = '75010084999001'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501008499900'
      and o.id <> p.id
  );

-- FC-84431050 · Acetona Jaloma chico
update public.productos p
set codigo_barras = '7596844310502'
where p.sku = 'FC-84431050'
  and p.codigo_barras = '759684431050'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7596844310502'
      and o.id <> p.id
  );

-- FC-84437151 · Acetona Jaloma mediano
update public.productos p
set codigo_barras = '7596844371510'
where p.sku = 'FC-84437151'
  and p.codigo_barras = '759684437151'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7596844371510'
      and o.id <> p.id
  );

-- FC-85097661 · Chinoin Junior jarabe infantil
update public.productos p
set codigo_barras = '7501088509766'
where p.sku = 'FC-85097661'
  and p.codigo_barras = '75010885097661'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501088509766'
      and o.id <> p.id
  );

-- FC-82176351 · Neurobión inyectable prellenado
update public.productos p
set codigo_barras = '7501298217635'
where p.sku = 'FC-82176351'
  and p.codigo_barras = '75012982176351'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501298217635'
      and o.id <> p.id
  );

-- FC-84095411 · Saridon
update public.productos p
set codigo_barras = '7501008409541'
where p.sku = 'FC-84095411'
  and p.codigo_barras = '75010084095411'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501008409541'
      and o.id <> p.id
  );

-- FC-84973401 · Flanax
update public.productos p
set codigo_barras = '7501008497340'
where p.sku = 'FC-84973401'
  and p.codigo_barras = '75010084973401'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501008497340'
      and o.id <> p.id
  );

-- FC-36041273 · Crema Hinds Clasica Rosa
update public.productos p
set codigo_barras = '0378360412734'
where p.sku = 'FC-36041273'
  and p.codigo_barras = '037836041273'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '0378360412734'
      and o.id <> p.id
  );

-- FC-40013850 · Crema Teatrical Lanolina
update public.productos p
set codigo_barras = '6502400138504'
where p.sku = 'FC-40013850'
  and p.codigo_barras = '650240013850'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400138504'
      and o.id <> p.id
  );

-- FC-45079011 · Labello
update public.productos p
set codigo_barras = '7501054507901'
where p.sku = 'FC-45079011'
  and p.codigo_barras = '75010545079011'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501054507901'
      and o.id <> p.id
  );

-- FC-85592111 · Scabisan
update public.productos p
set codigo_barras = '7501088559211'
where p.sku = 'FC-85592111'
  and p.codigo_barras = '75010885592111'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501088559211'
      and o.id <> p.id
  );

-- FC-86167151 · Nestum Probioticos Avena 270 Probioticos
update public.productos p
set codigo_barras = '7501058616715'
where p.sku = 'FC-86167151'
  and p.codigo_barras = '75010586167151'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501058616715'
      and o.id <> p.id
  );

-- FC-88923551 · Cilocid Iv
update public.productos p
set codigo_barras = '7502208892355'
where p.sku = 'FC-88923551'
  and p.codigo_barras = '75022088923551'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502208892355'
      and o.id <> p.id
  );

-- FC-87154871 · Graneodin F (flurbiprofeno)
update public.productos p
set codigo_barras = '7501058715487'
where p.sku = 'FC-87154871'
  and p.codigo_barras = '75010587154871'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501058715487'
      and o.id <> p.id
  );

-- FC-87932321 · Microdacyn lubricante cereza 50 ml
update public.productos p
set codigo_barras = '7501058793232'
where p.sku = 'FC-87932321'
  and p.codigo_barras = '75010587932321'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501058793232'
      and o.id <> p.id
  );

-- FC-51067711 · Nido leche en polvo (grande)
update public.productos p
set codigo_barras = '7506475106771'
where p.sku = 'FC-51067711'
  and p.codigo_barras = '75064751067711'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7506475106771'
      and o.id <> p.id
  );

-- FC-50003151 · Neo-Melubrina jarabe
update public.productos p
set codigo_barras = '7501165000315'
where p.sku = 'FC-50003151'
  and p.codigo_barras = '75011650003151'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501165000315'
      and o.id <> p.id
  );

-- FC-86708021 · Protec termómetro digital
update public.productos p
set codigo_barras = '7501048670802'
where p.sku = 'FC-86708021'
  and p.codigo_barras = '75010486708021'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501048670802'
      and o.id <> p.id
  );

-- FC-89794961 · Histiacil NF Infantil (Jarabe)
update public.productos p
set codigo_barras = '7501328979496'
where p.sku = 'FC-89794961'
  and p.codigo_barras = '75013289794961'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501328979496'
      and o.id <> p.id
  );

-- FC-88947797 · Tribedoce Tabletas
update public.productos p
set codigo_barras = '7502208894779'
where p.sku = 'FC-88947797'
  and p.codigo_barras = '75022088947797'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502208894779'
      and o.id <> p.id
  );

-- FC-56131681 · Evenflo
update public.productos p
set codigo_barras = '7506425613168'
where p.sku = 'FC-56131681'
  and p.codigo_barras = '75064256131681'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7506425613168'
      and o.id <> p.id
  );

-- FC-66534951 · Colgate Total
update public.productos p
set codigo_barras = '7509546653495'
where p.sku = 'FC-66534951'
  and p.codigo_barras = '75095466534951'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7509546653495'
      and o.id <> p.id
  );

-- FC-73629981 · Kleenex Panuelos Pack C/8 1
update public.productos p
set codigo_barras = '7501017362998'
where p.sku = 'FC-73629981'
  and p.codigo_barras = '75010173629981'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501017362998'
      and o.id <> p.id
  );

-- FC-83351381 · Agua oxigenada
update public.productos p
set codigo_barras = '7501048335138'
where p.sku = 'FC-83351381'
  and p.codigo_barras = '75010483351381'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501048335138'
      and o.id <> p.id
  );

-- FC-83351691 · Degasa Agua Oxigenada
update public.productos p
set codigo_barras = '7501048335169'
where p.sku = 'FC-83351691'
  and p.codigo_barras = '75010483351691'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501048335169'
      and o.id <> p.id
  );

-- FC-83510531 · Protec Antibacterial 22.40 Antibacterial
update public.productos p
set codigo_barras = '7501048351053'
where p.sku = 'FC-83510531'
  and p.codigo_barras = '75010483510531'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501048351053'
      and o.id <> p.id
  );

-- FC-92821171 · Nido Nido Nestle Bolsa Nestle
update public.productos p
set codigo_barras = '7501059282117'
where p.sku = 'FC-92821171'
  and p.codigo_barras = '75010592821171'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501059282117'
      and o.id <> p.id
  );

-- FC-98100381 · Shampoo Herklin
update public.productos p
set codigo_barras = '7501089810038'
where p.sku = 'FC-98100381'
  and p.codigo_barras = '75010898100381'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501089810038'
      and o.id <> p.id
  );

-- FC-45307181 · Arnica Bde Parche
update public.productos p
set codigo_barras = '7501054530718'
where p.sku = 'FC-45307181'
  and p.codigo_barras = '75010545307181'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501054530718'
      and o.id <> p.id
  );

-- FC-36040450 · Crema Grisi concha nácar para manos
update public.productos p
set codigo_barras = '0378360404500'
where p.sku = 'FC-36040450'
  and p.codigo_barras = '037836040450'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '0378360404500'
      and o.id <> p.id
  );

-- FC-AA905BF7 · Perludil
update public.productos p
set codigo_barras = '7800831412262'
where p.sku = 'FC-AA905BF7'
  and p.codigo_barras = '780083141226'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7800831412262'
      and o.id <> p.id
  );

-- FC-34062421 · Tela adhesiva
update public.productos p
set codigo_barras = '7503003406242'
where p.sku = 'FC-34062421'
  and p.codigo_barras = '75030034062421'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7503003406242'
      and o.id <> p.id
  );

-- FC-20500171 · Crema para peinar Pert aceite oliva aguacate
update public.productos p
set codigo_barras = '8101205001716'
where p.sku = 'FC-20500171'
  and p.codigo_barras = '810120500171'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '8101205001716'
      and o.id <> p.id
  );

-- FC-34063651 · Quirmex
update public.productos p
set codigo_barras = '7503003406365'
where p.sku = 'FC-34063651'
  and p.codigo_barras = '75030034063651'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7503003406365'
      and o.id <> p.id
  );

-- FC-5D9DFA3D · Norquinol
update public.productos p
set codigo_barras = '7851207554970'
where p.sku = 'FC-5D9DFA3D'
  and p.codigo_barras = '785120755497'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7851207554970'
      and o.id <> p.id
  );

-- FC-974EE5FD · Gimalxina
update public.productos p
set codigo_barras = '7800831418752'
where p.sku = 'FC-974EE5FD'
  and p.codigo_barras = '780083141875'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7800831418752'
      and o.id <> p.id
  );

-- FC-51444145 · Old Spice
update public.productos p
set codigo_barras = '7500435144414'
where p.sku = 'FC-51444145'
  and p.codigo_barras = '75004351444145'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7500435144414'
      and o.id <> p.id
  );

-- FC-E4BE37BE · Atorvastatina
update public.productos p
set codigo_barras = '7851207548580'
where p.sku = 'FC-E4BE37BE'
  and p.codigo_barras = '785120754858'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7851207548580'
      and o.id <> p.id
  );

-- FC-34067301 · Quirmex
update public.productos p
set codigo_barras = '7503003406730'
where p.sku = 'FC-34067301'
  and p.codigo_barras = '75030034067301'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7503003406730'
      and o.id <> p.id
  );

-- FC-20500201 · Shampoo Pert  Ac-Oliva
update public.productos p
set codigo_barras = '8101205002010'
where p.sku = 'FC-20500201'
  and p.codigo_barras = '810120500201'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '8101205002010'
      and o.id <> p.id
  );

-- FC-36033735 · Shampoo Ricitos de Oro Oro Agua De Coco
update public.productos p
set codigo_barras = '0378360337358'
where p.sku = 'FC-36033735'
  and p.codigo_barras = '037836033735'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '0378360337358'
      and o.id <> p.id
  );

-- FC-40030338 · Jabon Intimo Lomecan V Aclar
update public.productos p
set codigo_barras = '6502400303384'
where p.sku = 'FC-40030338'
  and p.codigo_barras = '650240030338'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400303384'
      and o.id <> p.id
  );

-- FC-20501765 · Crema Grisi aloe vera para manos
update public.productos p
set codigo_barras = '8101205017656'
where p.sku = 'FC-20501765'
  and p.codigo_barras = '810120501765'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '8101205017656'
      and o.id <> p.id
  );

-- FC-40030963 · Crema Teatrical Cel-Ma Nutrit
update public.productos p
set codigo_barras = '6502400309638'
where p.sku = 'FC-40030963'
  and p.codigo_barras = '650240030963'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400309638'
      and o.id <> p.id
  );

-- FC-88915491 · Tarmin 2 Mg /12
update public.productos p
set codigo_barras = '7502208891549'
where p.sku = 'FC-88915491'
  and p.codigo_barras = '75022088915491'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502208891549'
      and o.id <> p.id
  );

-- FC-36032776 · Shampoo Ricitos de Oro Oro Biopure
update public.productos p
set codigo_barras = '0378360327762'
where p.sku = 'FC-36032776'
  and p.codigo_barras = '037836032776'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '0378360327762'
      and o.id <> p.id
  );

-- FC-40025839 · Jabon Intimo Lomecan V
update public.productos p
set codigo_barras = '6502400258394'
where p.sku = 'FC-40025839'
  and p.codigo_barras = '650240025839'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400258394'
      and o.id <> p.id
  );

-- FC-36041402 · Crema Hinds hidratación extra almendras
update public.productos p
set codigo_barras = '0378360414028'
where p.sku = 'FC-36041402'
  and p.codigo_barras = '037836041402'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '0378360414028'
      and o.id <> p.id
  );

-- FC-20501673 · Crema Hinds líquida agave azul
update public.productos p
set codigo_barras = '8101205016734'
where p.sku = 'FC-20501673'
  and p.codigo_barras = '810120501673'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '8101205016734'
      and o.id <> p.id
  );

-- FC-85800198 · Toallitas Bebin Super
update public.productos p
set codigo_barras = '6195858001980'
where p.sku = 'FC-85800198'
  and p.codigo_barras = '619585800198'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6195858001980'
      and o.id <> p.id
  );

-- FC-49824911 · Prudence condones C/3
update public.productos p
set codigo_barras = '7502214982491'
where p.sku = 'FC-49824911'
  and p.codigo_barras = '75022149824911'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502214982491'
      and o.id <> p.id
  );

-- FC-89100101 · Algodón 200 g
update public.productos p
set codigo_barras = '7501868910010'
where p.sku = 'FC-89100101'
  and p.codigo_barras = '75018689100101'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501868910010'
      and o.id <> p.id
  );

-- FC-84900280 · Jaloma Agua de Rosas
update public.productos p
set codigo_barras = '7596849002808'
where p.sku = 'FC-84900280'
  and p.codigo_barras = '759684900280'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7596849002808'
      and o.id <> p.id
  );

-- FC-01015141 · Lubricante Sico Softlube Origin
update public.productos p
set codigo_barras = '7506460101514'
where p.sku = 'FC-01015141'
  and p.codigo_barras = '75064601015141'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7506460101514'
      and o.id <> p.id
  );

-- FC-49824391 · Prudence 'Ull Retardante C/3
update public.productos p
set codigo_barras = '7502214982439'
where p.sku = 'FC-49824391'
  and p.codigo_barras = '75022149824391'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502214982439'
      and o.id <> p.id
  );

-- FC-49853867 · Softlub Extra condones C/3
update public.productos p
set codigo_barras = '7502214985386'
where p.sku = 'FC-49853867'
  and p.codigo_barras = '75022149853867'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502214985386'
      and o.id <> p.id
  );

-- FC-23272151 · Jeringa insulina 0.3 ml
update public.productos p
set codigo_barras = '7506022327215'
where p.sku = 'FC-23272151'
  and p.codigo_barras = '75060223272151'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7506022327215'
      and o.id <> p.id
  );

-- FC-49824771 · Prudence Fresa
update public.productos p
set codigo_barras = '7502214982477'
where p.sku = 'FC-49824771'
  and p.codigo_barras = '75022149824771'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502214982477'
      and o.id <> p.id
  );

-- FC-40013898 · Crema Teatrical Lanol/Ros
update public.productos p
set codigo_barras = '6502400138986'
where p.sku = 'FC-40013898'
  and p.codigo_barras = '650240013898'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400138986'
      and o.id <> p.id
  );

-- FC-08820243 · Dermodine infantil
update public.productos p
set codigo_barras = '7501250882024'
where p.sku = 'FC-08820243'
  and p.codigo_barras = '75012508820243'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501250882024'
      and o.id <> p.id
  );

-- FC-34067471 · Quirmex
update public.productos p
set codigo_barras = '7503003406747'
where p.sku = 'FC-34067471'
  and p.codigo_barras = '75030034067471'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7503003406747'
      and o.id <> p.id
  );

-- FC-34064021 · Quirmex Tarro 1 2 12.00 Cotonetes Tarro 1
update public.productos p
set codigo_barras = '7503003406402'
where p.sku = 'FC-34064021'
  and p.codigo_barras = '75030034064021'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7503003406402'
      and o.id <> p.id
  );

-- FC-34067781 · Quirmex
update public.productos p
set codigo_barras = '7503003406778'
where p.sku = 'FC-34067781'
  and p.codigo_barras = '75030034067781'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7503003406778'
      and o.id <> p.id
  );

-- FC-34067851 · Quirmex
update public.productos p
set codigo_barras = '7503003406785'
where p.sku = 'FC-34067851'
  and p.codigo_barras = '75030034067851'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7503003406785'
      and o.id <> p.id
  );

-- FC-60009851 · Colgate Triple Acc
update public.productos p
set codigo_barras = '7509546000985'
where p.sku = 'FC-60009851'
  and p.codigo_barras = '75095460009851'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7509546000985'
      and o.id <> p.id
  );

-- FC-60689091 · Colgate Trip Xtra
update public.productos p
set codigo_barras = '7509546068909'
where p.sku = 'FC-60689091'
  and p.codigo_barras = '75095460689091'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7509546068909'
      and o.id <> p.id
  );

-- FC-66888171 · Colgate Max Clean
update public.productos p
set codigo_barras = '7509546688817'
where p.sku = 'FC-66888171'
  and p.codigo_barras = '75095466888171'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7509546688817'
      and o.id <> p.id
  );

-- FC-66873531 · Crema dental anticaries
update public.productos p
set codigo_barras = '7509546687353'
where p.sku = 'FC-66873531'
  and p.codigo_barras = '75095466873531'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7509546687353'
      and o.id <> p.id
  );

-- FC-38891190 · Jabon Dove Original
update public.productos p
set codigo_barras = '0672388911904'
where p.sku = 'FC-38891190'
  and p.codigo_barras = '067238891190'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '0672388911904'
      and o.id <> p.id
  );

-- FC-40004643 · Jabon Asepxia Exfoliante
update public.productos p
set codigo_barras = '6502400046434'
where p.sku = 'FC-40004643'
  and p.codigo_barras = '650240004643'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400046434'
      and o.id <> p.id
  );

-- FC-40036965 · Jabon Asepxia Bicarbon
update public.productos p
set codigo_barras = '6502400369656'
where p.sku = 'FC-40036965'
  and p.codigo_barras = '650240036965'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '6502400369656'
      and o.id <> p.id
  );

-- FC-21042481 · Manzanilla Ml Hnos 31.40 Hnos
update public.productos p
set codigo_barras = '7501022104248'
where p.sku = 'FC-21042481'
  and p.codigo_barras = '75010221042481'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501022104248'
      and o.id <> p.id
  );

-- FC-24004581 · Ajolotius Pastillas Elderberry Past
update public.productos p
set codigo_barras = '7506452400458'
where p.sku = 'FC-24004581'
  and p.codigo_barras = '75064524004581'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7506452400458'
      and o.id <> p.id
  );

-- FC-45045281 · Labello Hydro-C
update public.productos p
set codigo_barras = '7501054504528'
where p.sku = 'FC-45045281'
  and p.codigo_barras = '75010545045281'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501054504528'
      and o.id <> p.id
  );

-- FC-49800151 · Prudence Clasico C/3
update public.productos p
set codigo_barras = '7502214980015'
where p.sku = 'FC-49800151'
  and p.codigo_barras = '75022149800151'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7502214980015'
      and o.id <> p.id
  );

-- FC-56034041 · Toallitas húmedas antibacterial
update public.productos p
set codigo_barras = '7506425603404'
where p.sku = 'FC-56034041'
  and p.codigo_barras = '75064256034041'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7506425603404'
      and o.id <> p.id
  );

-- Renombre · FC-60101521
update public.productos
set nombre = 'Soft Lub Pleasure 56.7 g',
    descripcion = coalesce(nullif(btrim(descripcion), ''), 'Soft Lub Pleasure 56.7 g — catálogo')
where sku = 'FC-60101521'
  and nombre = 'Vitacilina';

commit;

-- Verificación (muestra)
select sku, codigo_barras, length(regexp_replace(codigo_barras, '\\D', '', 'g')) as digits, nombre
from public.productos
where sku in ('FC-03430721', 'FC-03405381', 'FC-60101521')
   or codigo_barras = '7502250343072'
order by sku;