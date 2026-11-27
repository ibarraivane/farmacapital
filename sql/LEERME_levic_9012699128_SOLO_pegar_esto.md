# Levic A 9012699128 → Recibir

El merge a GitHub **no** crea la cola. Hay que **Run** el SQL en Supabase.

| Proveedor | Folio | Fecha | Total | Renglones | Pzas |
|---|---|---|---|---|---|
| Levic | **9012699128** | 16-nov-2026 | $582.13 (hoja 1) | 5 | 11 |

**Hoja 1 de 2:** solo llegó la foto de la primera hoja. El total es la suma de esos 5 renglones (IVA 0%). Si mandas la hoja 2, se actualiza el ticket.

## Pasos

1. Supabase → SQL Editor → New query
2. Raw: https://raw.githubusercontent.com/ibarraivane/farmacapital/main/sql/patch_levic_9012699128_SOLO_pegar_esto.sql
3. Selecciona TODO → copiar → pegar → **Run**
4. Abajo: VERIFICACION con folio `9012699128` en `borrador` (5 renglones, 11 pzas)
5. Tablet: Recibir → recargar → tarjeta **Levic** $582.13

## Renglones (hoja 1)

| Clave | EAN | SKU | Mostrador | Qty | Neto | Lote |
|---|---|---|---|---|---|---|
| BIO108 | 7501573903260 | `FC-73903260` | Bromhexina Adulto 160 mg/100 mL | 2 | $16.98 | LF2604 |
| GEP030 | 7502227426982 | `FC-27427392` | ML-PRIM metocarbamol/ibuprofeno 375/200 mg | 3 | $47.93 | 261550 |
| LOE135 | 7502211783954 | `EQ-LOE135` | Rosanil nitazoxanida 500 mg | 2 | $53.15 | R2604375 |
| MAV300 | 7502009746321 | `EQ-MAV300` | Nisolver prednisolona 1 mg/mL | 3 | $73.74 | 263224 |
| MAV414 | 7502009749698 | `FC-09749698` | Bromhexina/oxeladina | 1 | $76.86 | 265229 |

## Notas

- CFDI `6E1D1BA1-7C86-4E90-8787-8B08E8B45856` · PUE efectivo · agente Yair Ramirez.
- Caducidad del papel **no** se carga: MMAA de la caja en Recibir.
- Productos ya venían en catálogo; el SQL solo abre la cola y actualiza costo si hace falta.
- Fotos ya en `catalogo-propia/` para Nisolver y Verxolin (MAV414).
