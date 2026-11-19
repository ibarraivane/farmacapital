# Farma Mayoreo V01000004500 → Recibir

| Proveedor | Folio | Fecha | Total | Renglones |
|---|---|---|---|---|
| Farma Mayoreo | **V01000004500** | 17-nov-2026 | $1,625.91 | 7 |

Este ticket iba en el lote 17-nov, **antes** de Cityfarma. Si solo se reintentó Cityfarma+Surtidor, aquí puede faltar.

## Pasos

1. Supabase → SQL Editor → New query
2. Pegar `sql/patch_recibir_farma_mayoreo_V01000004500_SOLO_pegar_esto.sql` → **Run**
3. VERIFICACION: folio `V01000004500`, `borrador`, 7 renglones
4. Tablet: Recibir → recargar → tarjeta **Farma Mayoreo**

## Renglones

| EAN | Producto | Qty | P.U. | Lote |
|---|---|---|---|---|
| `7501088575396` | Troferit 120 mL | 1 | $144.97 | BFG058 |
| `7501037907117` | Bisolvon adulto 120 mL | 2 | $146.98 | 23980029 |
| `7501159580182` | Sinuberase C/10 | 3 | $217.98 | B1175 |
| `7501089810526` | Picosend amoniaco 3.5% | 2 | $73.98 | — |
| `7501089810625` | Picosend Protect 120 mL | 2 | $81.98 | — |
| `75012571` | Picosend Protect travel 50 mL | 3 | $38.98 | — |
| `7501299368145` | Sensibit D NF 2x1 | 2 | $52.09 | 010484 |

Caducidad **null** (MMAA de la caja). Travel 50 mL: el ticket imprime EAN corto `75012571` (así lo publica el fabricante).
