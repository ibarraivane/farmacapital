# Cuatro tickets 21-oct-2026 → Recibir

Fotos de mostrador. Pegar **todo** `sql/patch_recepciones_cuatro_tickets_20261021.sql` en Supabase → Run.

## Tickets

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
| Sahuayo | **310545** | $1,160.20 | Tena Pants Maxi CH/M + GDE · Affective Predoblado · Huggies Supreme E4/E5 |
| Farmalive (Club Iztapalapa 1) | **14979** | $1,928.16 | Saba · Bixen · Vick inhalador · Dolo-Neurobion · Glucerna ×3 · Ensure · XL-3 / VR / Xtra · Alli-Triple |
| IFC F8 Tienda | **129846** | $255.00 | Saniclip C/12 · Venda Stick azul · Cinta kinesiológica |
| Equilibrio | **211026** | $781.65 | Voydol · Lorotec · Lorotec F · Tarmin · Geldako · Amifarin 12/20 · Namifen · Cipro · Quitadol |

## Notas

1. **Equilibrio folio 211026:** la foto no trae el encabezado con el número de factura. Usé fecha `ddmmyy`. Si el papel dice otro folio, avisar y lo renombramos.
2. **Farmalive promos $0.01:** XL-3 VR (5), XL-3 Xtra (6) y Alli-Triple (2) van consolidados con costo promedio; el catálogo no se pisa con $0.01.
3. **Genomma 12↔13:** ticket trae `650240052545` / `017100` / `017094`; catálogo a veces lleva dígito extra — `fc_match` ya los pega.
4. **IFC sin EAN GS1:** al escanear la caja, ligar el código real al SKU (`FC-IFC-81676`, `FC-IFC-82912A`, `FC-IFC-KINESIO`).
5. **Stock:** 0 hasta pistola + MMAA de la caja. No poner `0000`.
6. **Sahuayo Tena EAN:** ancla Walmart `750101905115` / `…116` + dígito de control. Si la caja lee otro, mandar foto del código.

## Después del SQL

1. Recargar Recibir en la tablet.
2. Debe haber **4 botones** de tickets vivos (no se pisan).
3. Escanear → MMAA → Guardar renglón.
