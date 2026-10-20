# Tickets Recibir · 19–20-oct-2026

Fotos Cityfarma + Sahuayo + Equilibrio + Farmalive + Nadro + compra Huggies. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| Cityfarma S333074 | `patch_carga_cityfarma_s333074.sql` | 21 | $2,545.99 |
| Sahuayo 428641 | `patch_carga_sahuayo_428641.sql` | 2 | $43.30 |
| Equilibrio 448644 | `patch_carga_equilibrio_448644.sql` | 29 | $1,059.65 |
| Farmalive 14814 | `patch_carga_farmalive_14814.sql` | 42 | $1,664.96 |
| Nadro 6091278111 | `patch_carga_nadro_6091278111.sql` | 13 | $1,008.73 |
| Nadro 6091329944 | `patch_carga_nadro_6091329944.sql` | 13 | $1,615.56 |
| Compra directa Huggies E4 | `patch_carga_compra_huggies_e4_250.sql` | 1 | $250.00 |
| Levic 9012489145 | `patch_carga_levic_9012489145.sql` | 2 | $558.72 |

## Todo-en-uno

`patch_carga_tickets_20261019_TODOS.sql`

## Notas

- Equilibrio / Levic traen **lote de fábrica**; caducidad = MMAA de la caja al escanear.
- Equilibrio: renglón ácido ascórbico cortado en la foto → AMSA 6 amp EAN `7501349022119` (confirmar caja). AMS365 Zolmitriptano → EAN Ultra/AMSA `7502216805446`.
- Farmalive: costo = neto del renglón. Papel $1,664.99; suma SQL $1,664.96.
- Cityfarma: total = suma de renglones $2,545.99 (nebulizador Omron lleva el IVA 16% $80).
- Nadro 6091278111: Timolol Exakta EAN corto `75049612` (mismo estilo que otros Exakta en Farmacity).
- Nadro 6091329944: Tena con IVA en costo (Pants $117.47 · Predoblado $88.01). Total factura $1,615.56.
- Huggies Supreme Etapa 4 · EAN `7501943441767` · costo $250 · foto `catalogo-propia/panales-huggies-supreme-etapa-4-36-7501943441767.jpg` (tras deploy).
- Levic 9012489145: Dexal susp EAN `7502009747335` ($166.22) + Fossin 12 caps EAN `7501300450012` ($392.50). Total $558.72.
- Sahuayo: Nuvel Aclarado Ideal roll-on 50 mL EAN `7501082730258`.
- Regenerar: `python3 scripts/generar_carga_tickets_20261019.py`
