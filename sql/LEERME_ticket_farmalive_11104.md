# Ticket Farmalive 11104 → Recibir

**Farmalive Club Iztapalapa 1** · 30-oct-2026 15:24 · folio **11104** · total **$496.47** (subtotal $506.60 − descto 2% $10.13).
Cliente FARMACAPITAL · tarjeta crédito · 14 unidades.

Pegar **todo** `sql/patch_carga_farmalive_11104.sql` en Supabase → SQL Editor → Run.

## Renglones (costo = P.U. neto con descuento 2%)

| Cant | EAN | Nombre mostrador | Costo | PVP sugerido |
|---|---|---|---|---|
| 1 | `7502250343232` | Vitacilina Facial PDRN | $97.90 | $123 |
| 1 | `7502250343249` | Vitacilina Facial Exosomas | $97.90 | $123 |
| 2 | `7501033956126` | Glucerna líquido vainilla | $52.33 | $66 (catálogo ya ~$72) |
| 2 | `7501125144851` | Electrolit Uva | $19.60 | $25 |
| 2 | `7501125187179` | Electrolit Guayaba | $19.60 | $25 |
| 2 | `7503046131224` | Electrolit Ponche de frutas | $19.60 | $25 |
| 2 | `7501125103582` | Electrolit Piña | $19.60 | $25 |
| 2 | `7501125104688` | Electrolit Naranja-Mandarina | $19.60 | $25 |

## Notas

1. Altas nuevas: **Vitacilina Facial PDRN** y **Exosomas** (no estaban en iNadro; ficha oficial vitacilina.mx).
2. Glucerna / Electrolit Uva / Naranja-Mandarina ya en catálogo: actualiza costo; **no baja** PVP bueno.
3. Stock **0** hasta pistola + MMAA. No inventar `0000`.
4. Marca real Vitacilina / Glucerna / Electrolit — no «KSK» ni «LAB PISA» como marca (laboratorio sí).

## Fotos (`public/catalogo-propia/`)

Tras merge/deploy:

- `vitacilina-facial-pdrn-100g-7502250343232.jpg`
- `vitacilina-facial-exosomas-100g-7502250343249.jpg`
- `glucerna-liquido-vainilla-237ml-7501033956126.jpg`
- `electrolit-uva-625ml-7501125144851.jpg`
- `electrolit-guayaba-625ml-7501125187179.jpg`
- `electrolit-ponche-frutas-625ml-7503046131224.jpg`
- `electrolit-pina-625ml-7501125103582.jpg`
- `electrolit-naranja-mandarina-625ml-7501125104688.jpg`

## Después del SQL

1. Recargar Recibir en la tablet.
2. Botón **Farmalive 11104** (no pisa Nadro u otros vivos).
3. Escanear → MMAA → Guardar.
