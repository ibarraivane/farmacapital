# Tickets 09-nov-2026 → Recibir

Cuatro tickets de mostrador (fotos). Pegar **todo** `sql/patch_recibir_tickets_0911_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.

## Tickets

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
| Equilibrio (Iztapalapa 2) | **451146** | $283.36 | Nisolver prednisolona 100 ml ×4 @ $70.84 |
| Bodega F-48 (Murillo / Pasillo EF) | **157665** | $1,186.00 | Ensure Singles choco/fresa/vainilla ×8 c/u · Tampax Super Plus ×4 |
| Bodega F-42 / Citymark | **8716** | $611.15 | GUM hilo+enhebrador · Colgate Total 150 · GUM hilo cera · Oral-B cera · Oral-B ESS 2pk · Colgate Total12 65 ml · Mertodol 40 ml |
| IFC F8 Tienda | **132888** | $118.00 | Mercurio aceite romero ×10 · Jaloma mertiolate blanco ×2 |

## Notas

1. **Equilibrio 451146:** pedido online · costo neto tras descuento. Ticket imprime lote `260451` / cad `01/01/2028` — **no** se guarda; MMAA de la caja con pistola. EAN `7502009746321`.
2. **Ensure:** ticket F-48 imprime EAN 236 ml (`…0100` / `…0063` / `…0070`); pistola usa 237 ml (`7501033954061` / `…4078` / `…4085`).
3. **Citymark 8716:** encabezado doblado en la foto — folio leído como **8716** (Caja 4). Si el papel dice otro, avisar y lo renombramos. P.U. ya con IVA.
4. **IFC sin EAN GS1:** al escanear la caja, ligar el código real al SKU (`FC-38CAFE6B`, `FC-IFC-83217`).
5. **Stock:** 0 hasta pistola + MMAA. No poner `0000`.
6. **Fotos pendientes:** Ensure vainilla, Colgate Total 150/65, GUM hilo cera, Oral-B ESS, Mertodol 40 ml, Jaloma mertiolate IFC.

## Después del SQL

1. Recargar Recibir en la tablet.
2. Deben aparecer **4 botones** nuevos (no se pisan).
3. Escanear → MMAA → Guardar renglón.
