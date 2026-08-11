-- ============================================================
-- CORRECCIÓN COMPLETA: costos y precios vs tickets PDF
-- 181 productos · generado por auditar_precios_vs_tickets.py
-- Fuente costo: OCR crudo del PDF (primer precio antes de Subtotal)
-- Precio venta: costo × (1 + recargo% regla pricing)
--
-- Ejecutar UNA vez en Supabase SQL Editor.
-- ============================================================

begin;

-- [CRITICO_OCR] FC-48690909 ticket 77827 | $405.32 → $21.14 | precio → $32.00
update public.productos set costo = 21.14, precio = 32.00 where sku = 'FC-48690909';
update public.lotes set costo_unitario = 21.14 where producto_id = (select id from public.productos where sku = 'FC-48690909' limit 1);

-- [CRITICO_OCR] FC-40171550 ticket 77827 | $405.32 → $106.44 | precio → $150.00
update public.productos set costo = 106.44, precio = 150.00 where sku = 'FC-40171550';
update public.lotes set costo_unitario = 106.44 where producto_id = (select id from public.productos where sku = 'FC-40171550' limit 1);

-- [grave] FC-82176351 ticket FL-080826 | $819.71 → $273.42 | precio → $438.00
update public.productos set costo = 273.42, precio = 438.00 where sku = 'FC-82176351';
update public.lotes set costo_unitario = 273.42 where producto_id = (select id from public.productos where sku = 'FC-82176351' limit 1);

-- [grave] FC-76000277 ticket FL-080826 | $77.03 → $277.00 | precio → $374.00
update public.productos set costo = 277.00, precio = 374.00 where sku = 'FC-76000277';
update public.lotes set costo_unitario = 277.00 where producto_id = (select id from public.productos where sku = 'FC-76000277' limit 1);

-- [grave] FC-14121782 ticket 77827 | $167.69 → $17.78 | precio → $25.00
update public.productos set costo = 17.78, precio = 25.00 where sku = 'FC-14121782';
update public.lotes set costo_unitario = 17.78 where producto_id = (select id from public.productos where sku = 'FC-14121782' limit 1);

-- [grave] FC-48640751 ticket 77827 | $147.15 → $14.53 | precio → $22.00
update public.productos set costo = 14.53, precio = 22.00 where sku = 'FC-48640751';
update public.lotes set costo_unitario = 14.53 where producto_id = (select id from public.productos where sku = 'FC-48640751' limit 1);

-- [grave] FC-67905186 ticket 77827 | $128.57 → $16.70 | precio → $24.00
update public.productos set costo = 16.70, precio = 24.00 where sku = 'FC-67905186';
update public.lotes set costo_unitario = 16.70 where producto_id = (select id from public.productos where sku = 'FC-67905186' limit 1);

-- [grave] FC-54500216 ticket 77827 | $42.25 → $147.15 | precio → $207.00
update public.productos set costo = 147.15, precio = 207.00 where sku = 'FC-54500216';
update public.lotes set costo_unitario = 147.15 where producto_id = (select id from public.productos where sku = 'FC-54500216' limit 1);

-- [grave] FC-85103015 ticket 77827 | $106.44 → $13.32 | precio → $18.00
update public.productos set costo = 13.32, precio = 18.00 where sku = 'FC-85103015';
update public.lotes set costo_unitario = 13.32 where producto_id = (select id from public.productos where sku = 'FC-85103015' limit 1);

-- [grave] FC-42326414 ticket 77827 | $27.75 → $108.24 | precio → $152.00
update public.productos set costo = 108.24, precio = 152.00 where sku = 'FC-42326414';
update public.lotes set costo_unitario = 108.24 where producto_id = (select id from public.productos where sku = 'FC-42326414' limit 1);

-- [grave] FC-45307181 ticket FL-080826 | $149.35 → $74.68 | precio → $101.00
update public.productos set costo = 74.68, precio = 101.00 where sku = 'FC-45307181';
update public.lotes set costo_unitario = 74.68 where producto_id = (select id from public.productos where sku = 'FC-45307181' limit 1);

-- [grave] FC-25652716 ticket 77827 | $73.65 → $7.39 | precio → $11.00
update public.productos set costo = 7.39, precio = 11.00 where sku = 'FC-25652716';
update public.lotes set costo_unitario = 7.39 where producto_id = (select id from public.productos where sku = 'FC-25652716' limit 1);

-- [grave] FC-54558682 ticket 77827 | $22.30 → $85.87 | precio → $121.00
update public.productos set costo = 85.87, precio = 121.00 where sku = 'FC-54558682';
update public.lotes set costo_unitario = 85.87 where producto_id = (select id from public.productos where sku = 'FC-54558682' limit 1);

-- [grave] FC-56330378 ticket 77827 | $28.10 → $88.80 | precio → $125.00
update public.productos set costo = 88.80, precio = 125.00 where sku = 'FC-56330378';
update public.lotes set costo_unitario = 88.80 where producto_id = (select id from public.productos where sku = 'FC-56330378' limit 1);

-- [grave] FC-76000284 ticket 77827 | $21.08 → $81.47 | precio → $115.00
update public.productos set costo = 81.47, precio = 115.00 where sku = 'FC-76000284';
update public.lotes set costo_unitario = 81.47 where producto_id = (select id from public.productos where sku = 'FC-76000284' limit 1);

-- [grave] FC-72629012 ticket 77827 | $36.30 → $96.63 | precio → $136.00
update public.productos set costo = 96.63, precio = 136.00 where sku = 'FC-72629012';
update public.lotes set costo_unitario = 96.63 where producto_id = (select id from public.productos where sku = 'FC-72629012' limit 1);

-- [grave] FC-06249776 ticket 77827 | $75.70 → $16.88 | precio → $24.00
update public.productos set costo = 16.88, precio = 24.00 where sku = 'FC-06249776';
update public.lotes set costo_unitario = 16.88 where producto_id = (select id from public.productos where sku = 'FC-06249776' limit 1);

-- [grave] FC-61124013 ticket 77827 | $73.76 → $17.77 | precio → $25.00
update public.productos set costo = 17.77, precio = 25.00 where sku = 'FC-61124013';
update public.lotes set costo_unitario = 17.77 where producto_id = (select id from public.productos where sku = 'FC-61124013' limit 1);

-- [grave] FC-35908147 ticket 77827 | $13.32 → $69.19 | precio → $97.00
update public.productos set costo = 69.19, precio = 97.00 where sku = 'FC-35908147';
update public.lotes set costo_unitario = 69.19 where producto_id = (select id from public.productos where sku = 'FC-35908147' limit 1);

-- [grave] FC-26462061 ticket 77827 | $74.31 → $22.30 | precio → $29.00
update public.productos set costo = 22.30, precio = 29.00 where sku = 'FC-26462061';
update public.lotes set costo_unitario = 22.30 where producto_id = (select id from public.productos where sku = 'FC-26462061' limit 1);

-- [grave] FC-62746698 ticket FL-080826 | $7.45 → $58.90 | precio → $80.00
update public.productos set costo = 58.90, precio = 80.00 where sku = 'FC-62746698';
update public.lotes set costo_unitario = 58.90 where producto_id = (select id from public.productos where sku = 'FC-62746698' limit 1);

-- [grave] FC-41500096 ticket 77827 | $80.46 → $31.77 | precio → $48.00
update public.productos set costo = 31.77, precio = 48.00 where sku = 'FC-41500096';
update public.lotes set costo_unitario = 31.77 where producto_id = (select id from public.productos where sku = 'FC-41500096' limit 1);

-- [grave] FC-46073156 ticket 77827 | $75.70 → $29.31 | precio → $42.00
update public.productos set costo = 29.31, precio = 42.00 where sku = 'FC-46073156';
update public.lotes set costo_unitario = 29.31 where producto_id = (select id from public.productos where sku = 'FC-46073156' limit 1);

-- [grave] FC-40025839 ticket 77827 | $17.20 → $63.05 | precio → $89.00
update public.productos set costo = 63.05, precio = 89.00 where sku = 'FC-40025839';
update public.lotes set costo_unitario = 63.05 where producto_id = (select id from public.productos where sku = 'FC-40025839' limit 1);

-- [grave] FC-38891190 ticket 77827 | $60.54 → $15.10 | precio → $22.00
update public.productos set costo = 15.10, precio = 22.00 where sku = 'FC-38891190';
update public.lotes set costo_unitario = 15.10 where producto_id = (select id from public.productos where sku = 'FC-38891190' limit 1);

-- [grave] FC-09419324 ticket 77827 | $26.38 → $70.91 | precio → $100.00
update public.productos set costo = 70.91, precio = 100.00 where sku = 'FC-09419324';
update public.lotes set costo_unitario = 70.91 where producto_id = (select id from public.productos where sku = 'FC-09419324' limit 1);

-- [grave] FC-06247468 ticket 77827 | $62.04 → $17.54 | precio → $25.00
update public.productos set costo = 17.54, precio = 25.00 where sku = 'FC-06247468';
update public.lotes set costo_unitario = 17.54 where producto_id = (select id from public.productos where sku = 'FC-06247468' limit 1);

-- [grave] FC-36040450 ticket 77827 | $86.77 → $43.63 | precio → $62.00
update public.productos set costo = 43.63, precio = 62.00 where sku = 'FC-36040450';
update public.lotes set costo_unitario = 43.63 where producto_id = (select id from public.productos where sku = 'FC-36040450' limit 1);

-- [grave] FC-06226852 ticket 77827 | $88.80 → $45.83 | precio → $65.00
update public.productos set costo = 45.83, precio = 65.00 where sku = 'FC-06226852';
update public.lotes set costo_unitario = 45.83 where producto_id = (select id from public.productos where sku = 'FC-06226852' limit 1);

-- [grave] FC-10974329 ticket 77827 | $12.97 → $54.06 | precio → $76.00
update public.productos set costo = 54.06, precio = 76.00 where sku = 'FC-10974329';
update public.lotes set costo_unitario = 54.06 where producto_id = (select id from public.productos where sku = 'FC-10974329' limit 1);

-- [grave] FC-20500201 ticket 77827 | $64.12 → $23.99 | precio → $34.00
update public.productos set costo = 23.99, precio = 34.00 where sku = 'FC-20500201';
update public.lotes set costo_unitario = 23.99 where producto_id = (select id from public.productos where sku = 'FC-20500201' limit 1);

-- [grave] FC-22150221 ticket 77827 | $59.36 → $20.80 | precio → $30.00
update public.productos set costo = 20.80, precio = 30.00 where sku = 'FC-22150221';
update public.lotes set costo_unitario = 20.80 where producto_id = (select id from public.productos where sku = 'FC-22150221' limit 1);

-- [grave] FC-92503558 ticket 77827 | $56.61 → $18.39 | precio → $26.00
update public.productos set costo = 18.39, precio = 26.00 where sku = 'FC-92503558';
update public.lotes set costo_unitario = 18.39 where producto_id = (select id from public.productos where sku = 'FC-92503558' limit 1);

-- [grave] FC-43489004 ticket 77827 | $40.73 → $4.48 | precio → $7.00
update public.productos set costo = 4.48, precio = 7.00 where sku = 'FC-43489004';
update public.lotes set costo_unitario = 4.48 where producto_id = (select id from public.productos where sku = 'FC-43489004' limit 1);

-- [grave] FC-06257597 ticket 77827 | $75.70 → $40.24 | precio → $55.00
update public.productos set costo = 40.24, precio = 55.00 where sku = 'FC-06257597';
update public.lotes set costo_unitario = 40.24 where producto_id = (select id from public.productos where sku = 'FC-06257597' limit 1);

-- [grave] FC-52910971 ticket 77827 | $78.22 → $43.58 | precio → $62.00
update public.productos set costo = 43.58, precio = 62.00 where sku = 'FC-52910971';
update public.lotes set costo_unitario = 43.58 where producto_id = (select id from public.productos where sku = 'FC-52910971' limit 1);

-- [grave] FC-35155922 ticket 77827 | $15.70 → $50.07 | precio → $71.00
update public.productos set costo = 50.07, precio = 71.00 where sku = 'FC-35155922';
update public.lotes set costo_unitario = 50.07 where producto_id = (select id from public.productos where sku = 'FC-35155922' limit 1);

-- [grave] FC-06234062 ticket 77827 | $17.77 → $50.07 | precio → $71.00
update public.productos set costo = 50.07, precio = 71.00 where sku = 'FC-06234062';
update public.lotes set costo_unitario = 50.07 where producto_id = (select id from public.productos where sku = 'FC-06234062' limit 1);

-- [grave] FC-61111501 ticket 77827 | $50.07 → $17.77 | precio → $25.00
update public.productos set costo = 17.77, precio = 25.00 where sku = 'FC-61111501';
update public.lotes set costo_unitario = 17.77 where producto_id = (select id from public.productos where sku = 'FC-61111501' limit 1);

-- [grave] FC-56340025 ticket 77827 | $18.88 → $50.07 | precio → $71.00
update public.productos set costo = 50.07, precio = 71.00 where sku = 'FC-56340025';
update public.lotes set costo_unitario = 50.07 where producto_id = (select id from public.productos where sku = 'FC-56340025' limit 1);

-- [grave] FC-35908130 ticket 77827 | $69.19 → $38.18 | precio → $54.00
update public.productos set costo = 38.18, precio = 54.00 where sku = 'FC-35908130';
update public.lotes set costo_unitario = 38.18 where producto_id = (select id from public.productos where sku = 'FC-35908130' limit 1);

-- [grave] FC-56340131 ticket 77827 | $19.11 → $50.07 | precio → $71.00
update public.productos set costo = 50.07, precio = 71.00 where sku = 'FC-56340131';
update public.lotes set costo_unitario = 50.07 where producto_id = (select id from public.productos where sku = 'FC-56340131' limit 1);

-- [grave] FC-06249783 ticket 77827 | $50.07 → $19.11 | precio → $27.00
update public.productos set costo = 19.11, precio = 27.00 where sku = 'FC-06249783';
update public.lotes set costo_unitario = 19.11 where producto_id = (select id from public.productos where sku = 'FC-06249783' limit 1);

-- [grave] FC-46073040 ticket 77827 | $45.26 → $14.73 | precio → $21.00
update public.productos set costo = 14.73, precio = 21.00 where sku = 'FC-46073040';
update public.lotes set costo_unitario = 14.73 where producto_id = (select id from public.productos where sku = 'FC-46073040' limit 1);

-- [grave] FC-46073033 ticket 77827 | $45.26 → $14.73 | precio → $21.00
update public.productos set costo = 14.73, precio = 21.00 where sku = 'FC-46073033';
update public.lotes set costo_unitario = 14.73 where producto_id = (select id from public.productos where sku = 'FC-46073033' limit 1);

-- [grave] FC-46655055 ticket 77827 | $20.02 → $50.51 | precio → $71.00
update public.productos set costo = 50.51, precio = 71.00 where sku = 'FC-46655055';
update public.lotes set costo_unitario = 50.51 where producto_id = (select id from public.productos where sku = 'FC-46655055' limit 1);

-- [grave] FC-75064938 ticket 77827 | $42.24 → $11.95 | precio → $17.00
update public.productos set costo = 11.95, precio = 17.00 where sku = 'FC-75064938';
update public.lotes set costo_unitario = 11.95 where producto_id = (select id from public.productos where sku = 'FC-75064938' limit 1);

-- [grave] FC-82740011 ticket 77827 | $43.58 → $14.08 | precio → $20.00
update public.productos set costo = 14.08, precio = 20.00 where sku = 'FC-82740011';
update public.lotes set costo_unitario = 14.08 where producto_id = (select id from public.productos where sku = 'FC-82740011' limit 1);

-- [grave] FC-75001865 ticket 77827 | $17.54 → $46.64 | precio → $66.00
update public.productos set costo = 46.64, precio = 66.00 where sku = 'FC-75001865';
update public.lotes set costo_unitario = 46.64 where producto_id = (select id from public.productos where sku = 'FC-75001865' limit 1);

-- [grave] FC-06209862 ticket 77827 | $16.87 → $45.83 | precio → $65.00
update public.productos set costo = 45.83, precio = 65.00 where sku = 'FC-06209862';
update public.lotes set costo_unitario = 45.83 where producto_id = (select id from public.productos where sku = 'FC-06209862' limit 1);

-- [grave] FC-46650708 ticket 77827 | $53.99 → $26.30 | precio → $37.00
update public.productos set costo = 26.30, precio = 37.00 where sku = 'FC-46650708';
update public.lotes set costo_unitario = 26.30 where producto_id = (select id from public.productos where sku = 'FC-46650708' limit 1);

-- [grave] FC-43427754 ticket 77827 | $31.77 → $5.00 | precio → $7.00
update public.productos set costo = 5.00, precio = 7.00 where sku = 'FC-43427754';
update public.lotes set costo_unitario = 5.00 where producto_id = (select id from public.productos where sku = 'FC-43427754' limit 1);

-- [grave] FC-75069223 ticket 77827 | $16.70 → $42.82 | precio → $60.00
update public.productos set costo = 42.82, precio = 60.00 where sku = 'FC-75069223';
update public.lotes set costo_unitario = 42.82 where producto_id = (select id from public.productos where sku = 'FC-75069223' limit 1);

-- [grave] FC-46655727 ticket 77827 | $38.31 → $12.97 | precio → $19.00
update public.productos set costo = 12.97, precio = 19.00 where sku = 'FC-46655727';
update public.lotes set costo_unitario = 12.97 where producto_id = (select id from public.productos where sku = 'FC-46655727' limit 1);

-- [grave] FC-45720550 ticket 77827 | $41.84 → $17.20 | precio → $25.00
update public.productos set costo = 17.20, precio = 25.00 where sku = 'FC-45720550';
update public.lotes set costo_unitario = 17.20 where producto_id = (select id from public.productos where sku = 'FC-45720550' limit 1);

-- [grave] FC-00701992 ticket 77827 | $12.97 → $36.30 | precio → $51.00
update public.productos set costo = 36.30, precio = 51.00 where sku = 'FC-00701992';
update public.lotes set costo_unitario = 36.30 where producto_id = (select id from public.productos where sku = 'FC-00701992' limit 1);

-- [grave] FC-40036965 ticket 77827 | $14.45 → $37.68 | precio → $53.00
update public.productos set costo = 37.68, precio = 53.00 where sku = 'FC-40036965';
update public.lotes set costo_unitario = 37.68 where producto_id = (select id from public.productos where sku = 'FC-40036965' limit 1);

-- [grave] FC-48640799 ticket 77827 | $2.75 → $24.84 | precio → $38.00
update public.productos set costo = 24.84, precio = 38.00 where sku = 'FC-48640799';
update public.lotes set costo_unitario = 24.84 where producto_id = (select id from public.productos where sku = 'FC-48640799' limit 1);

-- [grave] FC-35911208 ticket 77827 | $45.83 → $23.79 | precio → $34.00
update public.productos set costo = 23.79, precio = 34.00 where sku = 'FC-35911208';
update public.lotes set costo_unitario = 23.79 where producto_id = (select id from public.productos where sku = 'FC-35911208' limit 1);

-- [grave] FC-46657035 ticket 77827 | $45.83 → $23.79 | precio → $34.00
update public.productos set costo = 23.79, precio = 34.00 where sku = 'FC-46657035';
update public.lotes set costo_unitario = 23.79 where producto_id = (select id from public.productos where sku = 'FC-46657035' limit 1);

-- [grave] FC-06241206 ticket 77827 | $54.12 → $32.14 | precio → $45.00
update public.productos set costo = 32.14, precio = 45.00 where sku = 'FC-06241206';
update public.lotes set costo_unitario = 32.14 where producto_id = (select id from public.productos where sku = 'FC-06241206' limit 1);

-- [grave] FC-86472048 ticket 77827 | $35.45 → $13.50 | precio → $19.00
update public.productos set costo = 13.50, precio = 19.00 where sku = 'FC-86472048';
update public.lotes set costo_unitario = 13.50 where producto_id = (select id from public.productos where sku = 'FC-86472048' limit 1);

-- [grave] FC-34062421 ticket FL-080826 | $5.29 → $27.00 | precio → $44.00
update public.productos set costo = 27.00, precio = 44.00 where sku = 'FC-34062421';
update public.lotes set costo_unitario = 27.00 where producto_id = (select id from public.productos where sku = 'FC-34062421' limit 1);

-- [grave] FC-52876406 ticket 77827 | $45.83 → $24.71 | precio → $35.00
update public.productos set costo = 24.71, precio = 35.00 where sku = 'FC-52876406';
update public.lotes set costo_unitario = 24.71 where producto_id = (select id from public.productos where sku = 'FC-52876406' limit 1);

-- [grave] FC-22150092 ticket 77827 | $42.82 → $21.88 | precio → $31.00
update public.productos set costo = 21.88, precio = 31.00 where sku = 'FC-22150092';
update public.lotes set costo_unitario = 21.88 where producto_id = (select id from public.productos where sku = 'FC-22150092' limit 1);

-- [grave] FC-43489165 ticket 77827 | $45.83 → $25.08 | precio → $36.00
update public.productos set costo = 25.08, precio = 36.00 where sku = 'FC-43489165';
update public.lotes set costo_unitario = 25.08 where producto_id = (select id from public.productos where sku = 'FC-43489165' limit 1);

-- [grave] FC-35020077 ticket 77827 | $45.23 → $24.91 | precio → $35.00
update public.productos set costo = 24.91, precio = 35.00 where sku = 'FC-35020077';
update public.lotes set costo_unitario = 24.91 where producto_id = (select id from public.productos where sku = 'FC-35020077' limit 1);

-- [grave] FC-08837311 ticket 77827 | $12.54 → $32.37 | precio → $46.00
update public.productos set costo = 32.37, precio = 46.00 where sku = 'FC-08837311';
update public.lotes set costo_unitario = 32.37 where producto_id = (select id from public.productos where sku = 'FC-08837311' limit 1);

-- [grave] FC-25605514 ticket 77827 | $26.75 → $7.22 | precio → $11.00
update public.productos set costo = 7.22, precio = 11.00 where sku = 'FC-25605514';
update public.lotes set costo_unitario = 7.22 where producto_id = (select id from public.productos where sku = 'FC-25605514' limit 1);

-- [grave] FC-82790016 ticket 77827 | $39.90 → $20.65 | precio → $29.00
update public.productos set costo = 20.65, precio = 29.00 where sku = 'FC-82790016';
update public.lotes set costo_unitario = 20.65 where producto_id = (select id from public.productos where sku = 'FC-82790016' limit 1);

-- [grave] FC-20500171 ticket 77827 | $25.04 → $7.40 | precio → $11.00
update public.productos set costo = 7.40, precio = 11.00 where sku = 'FC-20500171';
update public.lotes set costo_unitario = 7.40 where producto_id = (select id from public.productos where sku = 'FC-20500171' limit 1);

-- [grave] FC-92504539 ticket 77827 | $36.73 → $19.28 | precio → $27.00
update public.productos set costo = 19.28, precio = 27.00 where sku = 'FC-92504539';
update public.lotes set costo_unitario = 19.28 where producto_id = (select id from public.productos where sku = 'FC-92504539' limit 1);

-- [grave] FC-84437151 ticket 77827 | $2.75 → $19.77 | precio → $28.00
update public.productos set costo = 19.77, precio = 28.00 where sku = 'FC-84437151';
update public.lotes set costo_unitario = 19.77 where producto_id = (select id from public.productos where sku = 'FC-84437151' limit 1);

-- [grave] FC-45722547 ticket 77827 | $37.72 → $21.08 | precio → $30.00
update public.productos set costo = 21.08, precio = 30.00 where sku = 'FC-45722547';
update public.lotes set costo_unitario = 21.08 where producto_id = (select id from public.productos where sku = 'FC-45722547' limit 1);

-- [grave] FC-48640775 ticket 77827 | $2.75 → $18.05 | precio → $28.00
update public.productos set costo = 18.05, precio = 28.00 where sku = 'FC-48640775';
update public.lotes set costo_unitario = 18.05 where producto_id = (select id from public.productos where sku = 'FC-48640775' limit 1);

-- [grave] FC-14119032 ticket 77827 | $30.21 → $15.02 | precio → $22.00
update public.productos set costo = 15.02, precio = 22.00 where sku = 'FC-14119032';
update public.lotes set costo_unitario = 15.02 where producto_id = (select id from public.productos where sku = 'FC-14119032' limit 1);

-- [grave] FC-45720567 ticket 77827 | $2.75 → $17.20 | precio → $25.00
update public.productos set costo = 17.20, precio = 25.00 where sku = 'FC-45720567';
update public.lotes set costo_unitario = 17.20 where producto_id = (select id from public.productos where sku = 'FC-45720567' limit 1);

-- [grave] FC-22105207 ticket 77827 | $20.14 → $6.96 | precio → $10.00
update public.productos set costo = 6.96, precio = 10.00 where sku = 'FC-22105207';
update public.lotes set costo_unitario = 6.96 where producto_id = (select id from public.productos where sku = 'FC-22105207' limit 1);

-- [grave] FC-46655079 ticket 77827 | $19.95 → $7.49 | precio → $11.00
update public.productos set costo = 7.49, precio = 11.00 where sku = 'FC-46655079';
update public.lotes set costo_unitario = 7.49 where producto_id = (select id from public.productos where sku = 'FC-46655079' limit 1);

-- [grave] FC-34063651 ticket FL-080826 | $2.34 → $11.70 | precio → $19.00
update public.productos set costo = 11.70, precio = 19.00 where sku = 'FC-34063651';
update public.lotes set costo_unitario = 11.70 where producto_id = (select id from public.productos where sku = 'FC-34063651' limit 1);

-- [grave] FC-84431050 ticket 77827 | $19.77 → $11.53 | precio → $17.00
update public.productos set costo = 11.53, precio = 17.00 where sku = 'FC-84431050';
update public.lotes set costo_unitario = 11.53 where producto_id = (select id from public.productos where sku = 'FC-84431050' limit 1);

-- [grave] FC-08895196 ticket FL-080826 | $1.90 → $9.50 | precio → $13.00
update public.productos set costo = 9.50, precio = 13.00 where sku = 'FC-08895196';
update public.lotes set costo_unitario = 9.50 where producto_id = (select id from public.productos where sku = 'FC-08895196' limit 1);

-- [grave] FC-68910041 ticket FL-080826 | $0.58 → $6.90 | precio → $10.00
update public.productos set costo = 6.90, precio = 10.00 where sku = 'FC-68910041';
update public.lotes set costo_unitario = 6.90 where producto_id = (select id from public.productos where sku = 'FC-68910041' limit 1);

-- [grave] FC-34067301 ticket FL-080826 | $0.57 → $6.80 | precio → $10.00
update public.productos set costo = 6.80, precio = 10.00 where sku = 'FC-34067301';
update public.lotes set costo_unitario = 6.80 where producto_id = (select id from public.productos where sku = 'FC-34067301' limit 1);

-- [moderado] FC-51444145 ticket FL-080826 | $135.73 → $277.00 | precio → $388.00
update public.productos set costo = 277.00, precio = 388.00 where sku = 'FC-51444145';
update public.lotes set costo_unitario = 277.00 where producto_id = (select id from public.productos where sku = 'FC-51444145' limit 1);

-- [moderado] FC-70612368 ticket FL-080826 | $76.00 → $152.00 | precio → $198.00
update public.productos set costo = 152.00, precio = 198.00 where sku = 'FC-70612368';
update public.lotes set costo_unitario = 152.00 where producto_id = (select id from public.productos where sku = 'FC-70612368' limit 1);

-- [moderado] FC-76040610 ticket FL-080826 | $46.90 → $93.80 | precio → $122.00
update public.productos set costo = 93.80, precio = 122.00 where sku = 'FC-76040610';
update public.lotes set costo_unitario = 93.80 where producto_id = (select id from public.productos where sku = 'FC-76040610' limit 1);

-- [moderado] FC-36032776 ticket 77827 | $29.96 → $74.31 | precio → $105.00
update public.productos set costo = 74.31, precio = 105.00 where sku = 'FC-36032776';
update public.lotes set costo_unitario = 74.31 where producto_id = (select id from public.productos where sku = 'FC-36032776' limit 1);

-- [moderado] FC-00942760 ticket 77827 | $62.25 → $105.35 | precio → $148.00
update public.productos set costo = 105.35, precio = 148.00 where sku = 'FC-00942760';
update public.lotes set costo_unitario = 105.35 where producto_id = (select id from public.productos where sku = 'FC-00942760' limit 1);

-- [moderado] FC-08802838 ticket 77827 | $43.63 → $84.49 | precio → $119.00
update public.productos set costo = 84.49, precio = 119.00 where sku = 'FC-08802838';
update public.lotes set costo_unitario = 84.49 where producto_id = (select id from public.productos where sku = 'FC-08802838' limit 1);

-- [moderado] FC-31887928 ticket 77827 | $26.20 → $63.53 | precio → $89.00
update public.productos set costo = 63.53, precio = 89.00 where sku = 'FC-31887928';
update public.lotes set costo_unitario = 63.53 where producto_id = (select id from public.productos where sku = 'FC-31887928' limit 1);

-- [moderado] FC-35231237 ticket 77827 | $36.73 → $73.76 | precio → $104.00
update public.productos set costo = 73.76, precio = 104.00 where sku = 'FC-35231237';
update public.lotes set costo_unitario = 73.76 where producto_id = (select id from public.productos where sku = 'FC-35231237' limit 1);

-- [moderado] FC-72300171 ticket 77827 | $43.58 → $80.46 | precio → $113.00
update public.productos set costo = 80.46, precio = 113.00 where sku = 'FC-72300171';
update public.lotes set costo_unitario = 80.46 where producto_id = (select id from public.productos where sku = 'FC-72300171' limit 1);

-- [moderado] FC-54503095 ticket 77827 | $96.63 → $60.75 | precio → $86.00
update public.productos set costo = 60.75, precio = 86.00 where sku = 'FC-54503095';
update public.lotes set costo_unitario = 60.75 where producto_id = (select id from public.productos where sku = 'FC-54503095' limit 1);

-- [moderado] FC-56360429 ticket 77827 | $36.33 → $71.80 | precio → $101.00
update public.productos set costo = 71.80, precio = 101.00 where sku = 'FC-56360429';
update public.lotes set costo_unitario = 71.80 where producto_id = (select id from public.productos where sku = 'FC-56360429' limit 1);

-- [moderado] FC-01303454 ticket 77827 | $40.66 → $75.70 | precio → $106.00
update public.productos set costo = 75.70, precio = 106.00 where sku = 'FC-01303454';
update public.lotes set costo_unitario = 75.70 where producto_id = (select id from public.productos where sku = 'FC-01303454' limit 1);

-- [moderado] FC-35155847 ticket 77827 | $40.66 → $75.70 | precio → $106.00
update public.productos set costo = 75.70, precio = 106.00 where sku = 'FC-35155847';
update public.lotes set costo_unitario = 75.70 where producto_id = (select id from public.productos where sku = 'FC-35155847' limit 1);

-- [moderado] FC-35168991 ticket 77827 | $32.34 → $67.00 | precio → $94.00
update public.productos set costo = 67.00, precio = 94.00 where sku = 'FC-35168991';
update public.lotes set costo_unitario = 67.00 where producto_id = (select id from public.productos where sku = 'FC-35168991' limit 1);

-- [moderado] FC-31976394 ticket 77827 | $30.02 → $63.53 | precio → $89.00
update public.productos set costo = 63.53, precio = 89.00 where sku = 'FC-31976394';
update public.lotes set costo_unitario = 63.53 where producto_id = (select id from public.productos where sku = 'FC-31976394' limit 1);

-- [moderado] FC-56330309 ticket 77827 | $105.35 → $72.30 | precio → $102.00
update public.productos set costo = 72.30, precio = 102.00 where sku = 'FC-56330309';
update public.lotes set costo_unitario = 72.30 where producto_id = (select id from public.productos where sku = 'FC-56330309' limit 1);

-- [moderado] FC-56326142 ticket 77827 | $26.48 → $59.36 | precio → $84.00
update public.productos set costo = 59.36, precio = 84.00 where sku = 'FC-56326142';
update public.lotes set costo_unitario = 59.36 where producto_id = (select id from public.productos where sku = 'FC-56326142' limit 1);

-- [moderado] FC-40030338 ticket 77827 | $41.84 → $70.92 | precio → $100.00
update public.productos set costo = 70.92, precio = 100.00 where sku = 'FC-40030338';
update public.lotes set costo_unitario = 70.92 where producto_id = (select id from public.productos where sku = 'FC-40030338' limit 1);

-- [moderado] FC-76040436 ticket 77827 | $49.29 → $78.22 | precio → $110.00
update public.productos set costo = 78.22, precio = 110.00 where sku = 'FC-76040436';
update public.lotes set costo_unitario = 78.22 where producto_id = (select id from public.productos where sku = 'FC-76040436' limit 1);

-- [moderado] FC-40030963 ticket 77827 | $34.41 → $62.25 | precio → $88.00
update public.productos set costo = 62.25, precio = 88.00 where sku = 'FC-40030963';
update public.lotes set costo_unitario = 62.25 where producto_id = (select id from public.productos where sku = 'FC-40030963' limit 1);

-- [moderado] FC-24511629 ticket 77827 | $18.17 → $44.76 | precio → $63.00
update public.productos set costo = 44.76, precio = 63.00 where sku = 'FC-24511629';
update public.lotes set costo_unitario = 44.76 where producto_id = (select id from public.productos where sku = 'FC-24511629' limit 1);

-- [moderado] FC-36033735 ticket 77827 | $66.93 → $42.34 | precio → $60.00
update public.productos set costo = 42.34, precio = 60.00 where sku = 'FC-36033735';
update public.lotes set costo_unitario = 42.34 where producto_id = (select id from public.productos where sku = 'FC-36033735' limit 1);

-- [moderado] FC-46074504 ticket 77827 | $66.93 → $43.59 | precio → $62.00
update public.productos set costo = 43.59, precio = 62.00 where sku = 'FC-46074504';
update public.lotes set costo_unitario = 43.59 where producto_id = (select id from public.productos where sku = 'FC-46074504' limit 1);

-- [moderado] FC-75062927 ticket 77827 | $30.21 → $53.50 | precio → $75.00
update public.productos set costo = 53.50, precio = 75.00 where sku = 'FC-75062927';
update public.lotes set costo_unitario = 53.50 where producto_id = (select id from public.productos where sku = 'FC-75062927' limit 1);

-- [moderado] FC-88915491 ticket FL-080826 | $80.90 → $58.50 | precio → $77.00
update public.productos set costo = 58.50, precio = 77.00 where sku = 'FC-88915491';
update public.lotes set costo_unitario = 58.50 where producto_id = (select id from public.productos where sku = 'FC-88915491' limit 1);

-- [moderado] FC-09498091 ticket 77827 | $48.58 → $70.91 | precio → $107.00
update public.productos set costo = 70.91, precio = 107.00 where sku = 'FC-09498091';
update public.lotes set costo_unitario = 70.91 where producto_id = (select id from public.productos where sku = 'FC-09498091' limit 1);

-- [moderado] FC-46640629 ticket 77827 | $61.02 → $40.28 | precio → $61.00
update public.productos set costo = 40.28, precio = 61.00 where sku = 'FC-46640629';
update public.lotes set costo_unitario = 40.28 where producto_id = (select id from public.productos where sku = 'FC-46640629' limit 1);

-- [moderado] FC-06217461 ticket 77827 | $43.58 → $64.12 | precio → $90.00
update public.productos set costo = 64.12, precio = 90.00 where sku = 'FC-06217461';
update public.lotes set costo_unitario = 64.12 where producto_id = (select id from public.productos where sku = 'FC-06217461' limit 1);

-- [moderado] FC-06213906 ticket 77827 | $25.83 → $45.83 | precio → $65.00
update public.productos set costo = 45.83, precio = 65.00 where sku = 'FC-06213906';
update public.lotes set costo_unitario = 45.83 where producto_id = (select id from public.productos where sku = 'FC-06213906' limit 1);

-- [moderado] FC-52816297 ticket 77827 | $63.05 → $43.58 | precio → $62.00
update public.productos set costo = 43.58, precio = 62.00 where sku = 'FC-52816297';
update public.lotes set costo_unitario = 43.58 where producto_id = (select id from public.productos where sku = 'FC-52816297' limit 1);

-- [moderado] FC-35469151 ticket 77827 | $15.51 → $34.41 | precio → $49.00
update public.productos set costo = 34.41, precio = 49.00 where sku = 'FC-35469151';
update public.lotes set costo_unitario = 34.41 where producto_id = (select id from public.productos where sku = 'FC-35469151' limit 1);

-- [moderado] FC-20501765 ticket 77827 | $26.48 → $45.15 | precio → $64.00
update public.productos set costo = 45.15, precio = 64.00 where sku = 'FC-20501765';
update public.lotes set costo_unitario = 45.15 where producto_id = (select id from public.productos where sku = 'FC-20501765' limit 1);

-- [moderado] FC-07528939 ticket 77827 | $49.97 → $31.59 | precio → $45.00
update public.productos set costo = 31.59, precio = 45.00 where sku = 'FC-07528939';
update public.lotes set costo_unitario = 31.59 where producto_id = (select id from public.productos where sku = 'FC-07528939' limit 1);

-- [moderado] FC-42417644 ticket 77827 | $30.36 → $48.58 | precio → $69.00
update public.productos set costo = 48.58, precio = 69.00 where sku = 'FC-42417644';
update public.lotes set costo_unitario = 48.58 where producto_id = (select id from public.productos where sku = 'FC-42417644' limit 1);

-- [moderado] FC-95129166 ticket 77827 | $70.91 → $53.19 | precio → $75.00
update public.productos set costo = 53.19, precio = 75.00 where sku = 'FC-95129166';
update public.lotes set costo_unitario = 53.19 where producto_id = (select id from public.productos where sku = 'FC-95129166' limit 1);

-- [moderado] FC-89100101 ticket FL-080826 | $17.65 → $35.30 | precio → $53.00
update public.productos set costo = 35.30, precio = 53.00 where sku = 'FC-89100101';
update public.lotes set costo_unitario = 35.30 where producto_id = (select id from public.productos where sku = 'FC-89100101' limit 1);

-- [moderado] FC-49824911 ticket FL-080826 | $31.03 → $48.60 | precio → $69.00
update public.productos set costo = 48.60, precio = 69.00 where sku = 'FC-49824911';
update public.lotes set costo_unitario = 48.60 where producto_id = (select id from public.productos where sku = 'FC-49824911' limit 1);

-- [moderado] FC-20501673 ticket 77827 | $59.81 → $42.25 | precio → $60.00
update public.productos set costo = 42.25, precio = 60.00 where sku = 'FC-20501673';
update public.lotes set costo_unitario = 42.25 where producto_id = (select id from public.productos where sku = 'FC-20501673' limit 1);

-- [moderado] FC-93025919 ticket 77827 | $45.83 → $62.83 | precio → $88.00
update public.productos set costo = 62.83, precio = 88.00 where sku = 'FC-93025919';
update public.lotes set costo_unitario = 62.83 where producto_id = (select id from public.productos where sku = 'FC-93025919' limit 1);

-- [moderado] FC-46059556 ticket 77827 | $52.29 → $35.61 | precio → $50.00
update public.productos set costo = 35.61, precio = 50.00 where sku = 'FC-46059556';
update public.lotes set costo_unitario = 35.61 where producto_id = (select id from public.productos where sku = 'FC-46059556' limit 1);

-- [moderado] FC-27286017 ticket 77827 | $45.83 → $29.55 | precio → $42.00
update public.productos set costo = 29.55, precio = 42.00 where sku = 'FC-27286017';
update public.lotes set costo_unitario = 29.55 where producto_id = (select id from public.productos where sku = 'FC-27286017' limit 1);

-- [moderado] FC-35020008 ticket 77827 | $57.90 → $73.76 | precio → $104.00
update public.productos set costo = 73.76, precio = 104.00 where sku = 'FC-35020008';
update public.lotes set costo_unitario = 73.76 where producto_id = (select id from public.productos where sku = 'FC-35020008' limit 1);

-- [moderado] FC-35169035 ticket 77827 | $73.76 → $57.90 | precio → $82.00
update public.productos set costo = 57.90, precio = 82.00 where sku = 'FC-35169035';
update public.lotes set costo_unitario = 57.90 where producto_id = (select id from public.productos where sku = 'FC-35169035' limit 1);

-- [moderado] FC-58792792 ticket FL-080826 | $45.60 → $59.90 | precio → $96.00
update public.productos set costo = 59.90, precio = 96.00 where sku = 'FC-58792792';
update public.lotes set costo_unitario = 59.90 where producto_id = (select id from public.productos where sku = 'FC-58792792' limit 1);

-- [moderado] FC-26462078 ticket 77827 | $47.79 → $61.02 | precio → $83.00
update public.productos set costo = 61.02, precio = 83.00 where sku = 'FC-26462078';
update public.lotes set costo_unitario = 61.02 where producto_id = (select id from public.productos where sku = 'FC-26462078' limit 1);

-- [moderado] FC-92511261 ticket 77827 | $29.31 → $41.84 | precio → $59.00
update public.productos set costo = 41.84, precio = 59.00 where sku = 'FC-92511261';
update public.lotes set costo_unitario = 41.84 where producto_id = (select id from public.productos where sku = 'FC-92511261' limit 1);

-- [moderado] FC-31244486 ticket 77827 | $43.59 → $31.59 | precio → $45.00
update public.productos set costo = 31.59, precio = 45.00 where sku = 'FC-31244486';
update public.lotes set costo_unitario = 31.59 where producto_id = (select id from public.productos where sku = 'FC-31244486' limit 1);

-- [moderado] FC-82790504 ticket 77827 | $16.70 → $27.75 | precio → $39.00
update public.productos set costo = 27.75, precio = 39.00 where sku = 'FC-82790504';
update public.lotes set costo_unitario = 27.75 where producto_id = (select id from public.productos where sku = 'FC-82790504' limit 1);

-- [moderado] FC-85800198 ticket 77827 | $36.30 → $26.20 | precio → $35.00
update public.productos set costo = 26.20, precio = 35.00 where sku = 'FC-85800198';
update public.lotes set costo_unitario = 26.20 where producto_id = (select id from public.productos where sku = 'FC-85800198' limit 1);

-- [moderado] FC-06249226 ticket 77827 | $50.07 → $40.66 | precio → $57.00
update public.productos set costo = 40.66, precio = 57.00 where sku = 'FC-06249226';
update public.lotes set costo_unitario = 40.66 where producto_id = (select id from public.productos where sku = 'FC-06249226' limit 1);

-- [moderado] FC-36041402 ticket 77827 | $31.59 → $39.90 | precio → $56.00
update public.productos set costo = 39.90, precio = 56.00 where sku = 'FC-36041402';
update public.lotes set costo_unitario = 39.90 where producto_id = (select id from public.productos where sku = 'FC-36041402' limit 1);

-- [moderado] FC-38312374 ticket 77827 | $24.91 → $32.34 | precio → $46.00
update public.productos set costo = 32.34, precio = 46.00 where sku = 'FC-38312374';
update public.lotes set costo_unitario = 32.34 where producto_id = (select id from public.productos where sku = 'FC-38312374' limit 1);

-- [moderado] FC-84900280 ticket 77827 | $23.79 → $16.87 | precio → $24.00
update public.productos set costo = 16.87, precio = 24.00 where sku = 'FC-84900280';
update public.lotes set costo_unitario = 16.87 where producto_id = (select id from public.productos where sku = 'FC-84900280' limit 1);

-- [moderado] FC-86494262 ticket 77827 | $8.60 → $15.51 | precio → $22.00
update public.productos set costo = 15.51, precio = 22.00 where sku = 'FC-86494262';
update public.lotes set costo_unitario = 15.51 where producto_id = (select id from public.productos where sku = 'FC-86494262' limit 1);

-- [moderado] FC-99428024 ticket 77827 | $7.37 → $14.15 | precio → $20.00
update public.productos set costo = 14.15, precio = 20.00 where sku = 'FC-99428024';
update public.lotes set costo_unitario = 14.15 where producto_id = (select id from public.productos where sku = 'FC-99428024' limit 1);

-- [moderado] FC-48690800 ticket 77827 | $21.14 → $14.42 | precio → $22.00
update public.productos set costo = 14.42, precio = 22.00 where sku = 'FC-48690800';
update public.lotes set costo_unitario = 14.42 where producto_id = (select id from public.productos where sku = 'FC-48690800' limit 1);

-- [moderado] FC-22150801 ticket 77827 | $15.02 → $21.72 | precio → $31.00
update public.productos set costo = 21.72, precio = 31.00 where sku = 'FC-22150801';
update public.lotes set costo_unitario = 21.72 where producto_id = (select id from public.productos where sku = 'FC-22150801' limit 1);

-- [moderado] FC-35231244 ticket 77827 | $18.39 → $24.91 | precio → $35.00
update public.productos set costo = 24.91, precio = 35.00 where sku = 'FC-35231244';
update public.lotes set costo_unitario = 24.91 where producto_id = (select id from public.productos where sku = 'FC-35231244' limit 1);

-- [moderado] FC-48691005 ticket 77827 | $20.02 → $26.48 | precio → $40.00
update public.productos set costo = 26.48, precio = 40.00 where sku = 'FC-48691005';
update public.lotes set costo_unitario = 26.48 where producto_id = (select id from public.productos where sku = 'FC-48691005' limit 1);

-- [moderado] FC-46072050 ticket 77827 | $20.80 → $26.30 | precio → $37.00
update public.productos set costo = 26.30, precio = 37.00 where sku = 'FC-46072050';
update public.lotes set costo_unitario = 26.30 where producto_id = (select id from public.productos where sku = 'FC-46072050' limit 1);

-- [moderado] FC-21012303 ticket 77827 | $14.78 → $9.43 | precio → $14.00
update public.productos set costo = 9.43, precio = 14.00 where sku = 'FC-21012303';
update public.lotes set costo_unitario = 9.43 where producto_id = (select id from public.productos where sku = 'FC-21012303' limit 1);

-- [moderado] FC-07502441 ticket 77827 | $20.65 → $15.51 | precio → $22.00
update public.productos set costo = 15.51, precio = 22.00 where sku = 'FC-07502441';
update public.lotes set costo_unitario = 15.51 where producto_id = (select id from public.productos where sku = 'FC-07502441' limit 1);

-- [moderado] FC-46683133 ticket 77827 | $8.96 → $13.07 | precio → $19.00
update public.productos set costo = 13.07, precio = 19.00 where sku = 'FC-46683133';
update public.lotes set costo_unitario = 13.07 where producto_id = (select id from public.productos where sku = 'FC-46683133' limit 1);

-- [moderado] FC-99425580 ticket 77827 | $7.37 → $11.31 | precio → $16.00
update public.productos set costo = 11.31, precio = 16.00 where sku = 'FC-99425580';
update public.lotes set costo_unitario = 11.31 where producto_id = (select id from public.productos where sku = 'FC-99425580' limit 1);

-- [moderado] FC-19006371 ticket 77827 | $7.21 → $10.17 | precio → $15.00
update public.productos set costo = 10.17, precio = 15.00 where sku = 'FC-19006371';
update public.lotes set costo_unitario = 10.17 where producto_id = (select id from public.productos where sku = 'FC-19006371' limit 1);

-- [menor] FC-06248052 ticket 77827 | $147.30 → $167.69 | precio → $235.00
update public.productos set costo = 167.69, precio = 235.00 where sku = 'FC-06248052';
update public.lotes set costo_unitario = 167.69 where producto_id = (select id from public.productos where sku = 'FC-06248052' limit 1);

-- [menor] FC-06248045 ticket 77827 | $129.46 → $147.30 | precio → $207.00
update public.productos set costo = 147.30, precio = 207.00 where sku = 'FC-06248045';
update public.lotes set costo_unitario = 147.30 where producto_id = (select id from public.productos where sku = 'FC-06248045' limit 1);

-- [menor] FC-06244795 ticket 77827 | $54.68 → $45.83 | precio → $65.00
update public.productos set costo = 45.83, precio = 65.00 where sku = 'FC-06244795';
update public.lotes set costo_unitario = 45.83 where producto_id = (select id from public.productos where sku = 'FC-06244795' limit 1);

-- [menor] FC-93038223 ticket 77827 | $45.83 → $54.68 | precio → $77.00
update public.productos set costo = 54.68, precio = 77.00 where sku = 'FC-93038223';
update public.lotes set costo_unitario = 54.68 where producto_id = (select id from public.productos where sku = 'FC-93038223' limit 1);

-- [menor] FC-93037806 ticket 77827 | $62.83 → $54.68 | precio → $77.00
update public.productos set costo = 54.68, precio = 77.00 where sku = 'FC-93037806';
update public.lotes set costo_unitario = 54.68 where producto_id = (select id from public.productos where sku = 'FC-93037806' limit 1);

-- [menor] FC-56340124 ticket 77827 | $57.90 → $50.07 | precio → $71.00
update public.productos set costo = 50.07, precio = 71.00 where sku = 'FC-56340124';
update public.lotes set costo_unitario = 50.07 where producto_id = (select id from public.productos where sku = 'FC-56340124' limit 1);

-- [menor] FC-93025797 ticket 77827 | $53.50 → $45.83 | precio → $65.00
update public.productos set costo = 45.83, precio = 65.00 where sku = 'FC-93025797';
update public.lotes set costo_unitario = 45.83 where producto_id = (select id from public.productos where sku = 'FC-93025797' limit 1);

-- [menor] FC-75062897 ticket 77827 | $45.83 → $53.50 | precio → $75.00
update public.productos set costo = 53.50, precio = 75.00 where sku = 'FC-75062897';
update public.lotes set costo_unitario = 53.50 where producto_id = (select id from public.productos where sku = 'FC-75062897' limit 1);

-- [menor] FC-49824391 ticket FL-080826 | $48.60 → $41.31 | precio → $56.00
update public.productos set costo = 41.31, precio = 56.00 where sku = 'FC-49824391';
update public.lotes set costo_unitario = 41.31 where producto_id = (select id from public.productos where sku = 'FC-49824391' limit 1);

-- [menor] FC-60101378 ticket FL-080826 | $96.35 → $102.50 | precio → $164.00
update public.productos set costo = 102.50, precio = 164.00 where sku = 'FC-60101378';
update public.lotes set costo_unitario = 102.50 where producto_id = (select id from public.productos where sku = 'FC-60101378' limit 1);

-- [menor] FC-24511636 ticket 77827 | $50.51 → $44.76 | precio → $63.00
update public.productos set costo = 44.76, precio = 63.00 where sku = 'FC-24511636';
update public.lotes set costo_unitario = 44.76 where producto_id = (select id from public.productos where sku = 'FC-24511636' limit 1);

-- [menor] FC-01015141 ticket FL-080826 | $78.49 → $83.50 | precio → $134.00
update public.productos set costo = 83.50, precio = 134.00 where sku = 'FC-01015141';
update public.lotes set costo_unitario = 83.50 where producto_id = (select id from public.productos where sku = 'FC-01015141' limit 1);

-- [menor] FC-52844825 ticket 77827 | $29.55 → $24.95 | precio → $35.00
update public.productos set costo = 24.95, precio = 35.00 where sku = 'FC-52844825';
update public.lotes set costo_unitario = 24.95 where producto_id = (select id from public.productos where sku = 'FC-52844825' limit 1);

-- [menor] FC-14704163 ticket FL-080826 | $58.96 → $63.40 | precio → $102.00
update public.productos set costo = 63.40, precio = 102.00 where sku = 'FC-14704163';
update public.lotes set costo_unitario = 63.40 where producto_id = (select id from public.productos where sku = 'FC-14704163' limit 1);

-- [menor] FC-14985805 ticket FL-080826 | $44.23 → $48.60 | precio → $69.00
update public.productos set costo = 48.60, precio = 69.00 where sku = 'FC-14985805';
update public.lotes set costo_unitario = 48.60 where producto_id = (select id from public.productos where sku = 'FC-14985805' limit 1);

-- [menor] FC-23272151 ticket FL-080826 | $212.86 → $217.20 | precio → $326.00
update public.productos set costo = 217.20, precio = 326.00 where sku = 'FC-23272151';
update public.lotes set costo_unitario = 217.20 where producto_id = (select id from public.productos where sku = 'FC-23272151' limit 1);

-- [menor] FC-22111352 ticket 77827 | $35.61 → $39.94 | precio → $56.00
update public.productos set costo = 39.94, precio = 56.00 where sku = 'FC-22111352';
update public.lotes set costo_unitario = 39.94 where producto_id = (select id from public.productos where sku = 'FC-22111352' limit 1);

-- [menor] FC-61123009 ticket 77827 | $23.99 → $28.10 | precio → $38.00
update public.productos set costo = 28.10, precio = 38.00 where sku = 'FC-61123009';
update public.lotes set costo_unitario = 28.10 where producto_id = (select id from public.productos where sku = 'FC-61123009' limit 1);

-- [menor] FC-06249240 ticket 77827 | $44.76 → $40.66 | precio → $57.00
update public.productos set costo = 40.66, precio = 57.00 where sku = 'FC-06249240';
update public.lotes set costo_unitario = 40.66 where producto_id = (select id from public.productos where sku = 'FC-06249240' limit 1);

-- [menor] FC-49853867 ticket FL-080826 | $41.31 → $45.40 | precio → $64.00
update public.productos set costo = 45.40, precio = 64.00 where sku = 'FC-49853867';
update public.lotes set costo_unitario = 45.40 where producto_id = (select id from public.productos where sku = 'FC-49853867' limit 1);

-- [menor] FC-40013898 ticket 77827 | $26.30 → $30.36 | precio → $43.00
update public.productos set costo = 30.36, precio = 43.00 where sku = 'FC-40013898';
update public.lotes set costo_unitario = 30.36 where producto_id = (select id from public.productos where sku = 'FC-40013898' limit 1);

-- [menor] FC-22133286 ticket 77827 | $70.91 → $66.93 | precio → $94.00
update public.productos set costo = 66.93, precio = 94.00 where sku = 'FC-22133286';
update public.lotes set costo_unitario = 66.93 where producto_id = (select id from public.productos where sku = 'FC-22133286' limit 1);

-- [menor] FC-01165321 ticket 77827 | $71.80 → $75.70 | precio → $103.00
update public.productos set costo = 75.70, precio = 103.00 where sku = 'FC-01165321';
update public.lotes set costo_unitario = 75.70 where producto_id = (select id from public.productos where sku = 'FC-01165321' limit 1);

-- [menor] FC-61113000 ticket 77827 | $31.77 → $28.10 | precio → $40.00
update public.productos set costo = 28.10, precio = 40.00 where sku = 'FC-61113000';
update public.lotes set costo_unitario = 28.10 where producto_id = (select id from public.productos where sku = 'FC-61113000' limit 1);

-- [menor] FC-93022567 ticket 77827 | $51.50 → $54.68 | precio → $77.00
update public.productos set costo = 54.68, precio = 77.00 where sku = 'FC-93022567';
update public.lotes set costo_unitario = 54.68 where producto_id = (select id from public.productos where sku = 'FC-93022567' limit 1);

-- [menor] FC-49824771 ticket FL-080826 | $31.03 → $34.10 | precio → $47.00
update public.productos set costo = 34.10, precio = 47.00 where sku = 'FC-49824771';
update public.lotes set costo_unitario = 34.10 where producto_id = (select id from public.productos where sku = 'FC-49824771' limit 1);

-- [menor] FC-08427330 ticket FL-080826 | $131.81 → $134.50 | precio → $216.00
update public.productos set costo = 134.50, precio = 216.00 where sku = 'FC-08427330';
update public.lotes set costo_unitario = 134.50 where producto_id = (select id from public.productos where sku = 'FC-08427330' limit 1);

-- [menor] FC-08491074 ticket FL-080826 | $122.30 → $124.80 | precio → $163.00
update public.productos set costo = 124.80, precio = 163.00 where sku = 'FC-08491074';
update public.lotes set costo_unitario = 124.80 where producto_id = (select id from public.productos where sku = 'FC-08491074' limit 1);

-- [menor] FC-52933307 ticket 77827 | $24.71 → $27.19 | precio → $39.00
update public.productos set costo = 27.19, precio = 39.00 where sku = 'FC-52933307';
update public.lotes set costo_unitario = 27.19 where producto_id = (select id from public.productos where sku = 'FC-52933307' limit 1);

-- [menor] FC-48691104 ticket 77827 | $40.68 → $38.31 | precio → $58.00
update public.productos set costo = 38.31, precio = 58.00 where sku = 'FC-48691104';
update public.lotes set costo_unitario = 38.31 where producto_id = (select id from public.productos where sku = 'FC-48691104' limit 1);

-- [menor] FC-92506601 ticket 77827 | $17.98 → $20.02 | precio → $29.00
update public.productos set costo = 20.02, precio = 29.00 where sku = 'FC-92506601';
update public.lotes set costo_unitario = 20.02 where producto_id = (select id from public.productos where sku = 'FC-92506601' limit 1);

-- [menor] FC-56342227 ticket 77827 | $8.24 → $9.08 | precio → $13.00
update public.productos set costo = 9.08, precio = 13.00 where sku = 'FC-56342227';
update public.lotes set costo_unitario = 9.08 where producto_id = (select id from public.productos where sku = 'FC-56342227' limit 1);

commit;

-- Verificación rápida
select sku, left(nombre, 36) as nombre, costo, precio
from public.productos
where sku in ('FC-48690800','FC-48690909','FC-48691005','FC-48691104','FC-40171550')
order by sku;

select count(*) as aun_mal from public.productos
where costo in (405.32, 7271.27, 8405.32);