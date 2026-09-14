-- Desactiva fichas pobres sin EAN que ya existen con código de barras.
-- NO suma stock (salvo Cintapore: el de EAN tiene 0).
-- Revisar anaquel antes de correr. Idempotente: solo toca si sigue activo y sin EAN.
begin;

-- FC-A0D320D1 (Amoxicilina 500 mg 12 cápsulas, stk 5) → FC-49021570 / 7501349021570
-- Misma caja AMSA. La ficha pobre es solo el genérico.
update public.productos
   set activo = false
 where sku = 'FC-A0D320D1'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FC-022543CD (Valclan 500/125 mg 10 tabletas, stk 3) → FC-01007199 / 7503001007199
-- Misma presentación 500/125. No confundir con Valclan 875.
update public.productos
   set activo = false
 where sku = 'FC-022543CD'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FC-7D1D9857 (Acetilsalicilico 100 mg 30 tabletas, stk 5) → FC-42803524 / 7501342803524
-- Es AAS 100 mg, no Aspirina 500. El EAN de Aspirina ya se le había quitado.
update public.productos
   set activo = false
 where sku = 'FC-7D1D9857'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FC-95779436 (Ácido acetilsalicílico efervescente 300 mg C/20, stk 5) → EQ-ALP0300 / 7501384504908
-- Misma caja Psicofarma 300 mg × 20.
update public.productos
   set activo = false
 where sku = 'FC-95779436'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FC-B25B4654 (Cina (Ciprofloxacino) 750 mg 7 tabletas, stk 2) → FC-52200809 / 7502225092486
-- Cina es levofloxacino; la ficha pobre puso ciprofloxacino.
update public.productos
   set activo = false
 where sku = 'FC-B25B4654'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FC-6C2878CF (Budenova budesonida 0.125 mg/ml 5 amp × 2 ml, stk 1) → EQ-NOV165 / 7501075726251
-- Misma Budenova Novag.
update public.productos
   set activo = false
 where sku = 'FC-6C2878CF'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FC-26EA40A4 (Raamcinet cetirizina 10 mg C/10, stk 6) → FC-27872123 / 7502227872123
-- Misma caja C/10. Stocks 6 y 4: probable doble conteo.
update public.productos
   set activo = false
 where sku = 'FC-26EA40A4'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FC-44B6751A (LAÜR Adulto solución inyectable C/3, stk 1) → EQ-SON264 / 7502001166981
-- Adulto. El infantil (7502001167001) es otro SKU.
update public.productos
   set activo = false
 where sku = 'FC-44B6751A'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FC-1321B34F (Hidroxin hidroxizina 10 mg C/30, stk 1) → EQ-MAI099 / 785120754681
-- Misma Hidroxin Mavi 10 mg C/30.
update public.productos
   set activo = false
 where sku = 'FC-1321B34F'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FC-AA7B0686 (Drosequim Adulto jarabe 300/160 mg 200 ml, stk 1) → EQ-QUM070 / 7502223111400
-- Mismo jarabe adulto Quimpharma.
update public.productos
   set activo = false
 where sku = 'FC-AA7B0686'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FC-926099D3 (Merthiolate Rojo Kohn 20 ml, stk 5) → FC-46601138 / 7506346601138
-- Mismo nombre. Stocks 5 y 5: probable doble conteo.
update public.productos
   set activo = false
 where sku = 'FC-926099D3'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- EQ-MAV401 (Dexpantenol 1 Cma 5% 30 G, stk 2) → FC-09749421 / 7502009749421
-- Misma crema Maver 5% 30 g. Pamedan es otra marca.
update public.productos
   set activo = false
 where sku = 'EQ-MAV401'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- EQ-BRL072-1 (Lo Bruquin 2 Tab 150/200 Mg, stk 10) → EQ-BRL072 / 7502208894915
-- SKU -1 sin EAN. Ambos con stock 10: el mismo lote contado dos veces.
update public.productos
   set activo = false
 where sku = 'EQ-BRL072-1'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FMX-501619 (Eucalin-Miel Jarabe C/120 Ml, stk 1) → FC-08100013 / 714908100013
-- Carga Farma MX vs ficha completa.
update public.productos
   set activo = false
 where sku = 'FMX-501619'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FMX-502465 (Colageno-Naturex Tabletas C/60, stk 1) → FC-9741524 / 7502009741524
-- Carga Farma MX vs ficha Naturex.
update public.productos
   set activo = false
 where sku = 'FMX-502465'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FMX-301136 (Cintapore cinta microporosa piel 2.5 cm x 5 m, stk 2) → FC-84500546 / 7506484500546
-- El de EAN tiene stock 0: pasar las 2 piezas a ese SKU.
update public.productos p
   set stock = coalesce(p.stock, 0) + (
     select coalesce(stock, 0) from public.productos
      where sku = 'FMX-301136' and activo = true
       and (codigo_barras is null or btrim(codigo_barras) = '')
   )
 where p.sku = 'FC-84500546';
update public.productos
   set activo = false
 where sku = 'FMX-301136'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FMX-501000 (Gelcavit-Colors Capsulas C/30, stk 1) → FC-30713547 / 7501130713547
-- Misma variante Colors.
update public.productos
   set activo = false
 where sku = 'FMX-501000'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FMX-500998 (Gelcavit-Platinum Capsulas C/30, stk 1) → FC-30713851 / 7501130713851
-- Misma variante Platinum.
update public.productos
   set activo = false
 where sku = 'FMX-500998'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FMX-501003 (Gelcavit-Q-10 Capsulas C/30, stk 1) → FC-13071164 / 7501130711642
-- Misma variante Q-10.
update public.productos
   set activo = false
 where sku = 'FMX-501003'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FMX-505937 (Pleniform-40 Tabletas C/30, stk 1) → FC-1041884 / 7503181041884
-- Mismo Pleniform 40.
update public.productos
   set activo = false
 where sku = 'FMX-505937'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FMX-302947 (Citrato Magnesio/Lecitina Soya-Naturex Capsulas C/30, stk 1) → FC-9892403 / 7502259892403
-- Misma Naturex citrato + lecitina.
update public.productos
   set activo = false
 where sku = 'FMX-302947'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FMX-506935 (Normogotero-Sensimedical Piezas C/1 S/Aguja, stk 5) → FC-22322395 / 7506022322395
-- Mismo gotero. Stocks 5 y 5: probable doble conteo.
update public.productos
   set activo = false
 where sku = 'FMX-506935'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

-- FC-89F00320 (Mercurio Arnica C/25, stk 5) → FC-00003920 / 3311000003944
-- Árnica Mercurio en glóbulos C/25.
update public.productos
   set activo = false
 where sku = 'FC-89F00320'
   and activo = true
   and (codigo_barras is null or btrim(codigo_barras) = '');

commit;
