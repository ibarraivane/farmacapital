# Tickets Recibir · 24-oct-2026

Fotos Farmalive + Farma Mayoreo. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Farmalive 15586 | `patch_carga_farmalive_15586.sql` | 13 | $2,078.50 |
| Farma Mayoreo 241026 | `patch_carga_farmamayoreo_241026.sql` | 16 | $737.34 |

## Todo-en-uno

`patch_carga_tickets_20261024_TODOS.sql`

## Notas

1. **Farma Mayoreo folio 241026:** la foto no trae el encabezado con el ID VENTA. Usé fecha `ddmmyy`. Cajero Alfredo Luciano Salazar · caja 3 (mismo POS que ticket 303033). Si el papel dice otro folio, avisar y lo renombramos.
2. **Farmalive:** costo = P.U. neto (2%). Brillantina EAN-8 `75001865` (ticket truncado igual). Suma SQL $2,078.50 (papel $2,078.48; 1¢ en Mickey).
3. **Farma Mayoreo:** P.U. con IVA; suma renglones = TOTAL. GUM Barbie ticket `70942004428` → canónico `070942004428`.
4. **Materfol:** lote de fábrica `2610990` del papel; caducidad = MMAA de la caja (no usar 29/06/2028 del ticket como FEFO sin escanear).
5. **Stock:** 0 hasta pistola + MMAA. No poner `0000`.
6. **Fotos pendientes (altas nuevas):** NAN 2-pack, Suavelastic E1, Huggies Pure/Supreme, Oral-B Kids ×3, Absorsec Ultra E3/E4/E5, GUM Stranger/Barbie/Bob, Jaloma chupón. Fixodent ya tiene packshot.
7. Regenerar: `python3 scripts/generar_carga_tickets_20261024.py`

## Después del SQL

1. Recargar Recibir en la tablet.
2. Debe haber **2 botones** de tickets vivos (no se pisan con los anteriores).
3. Escanear → MMAA → Guardar renglón.
