# Tienda Accu-Chek · lancetas Softclix · 17-sep-2026

Compra en [tienda.accu-chek.com.mx](https://tienda.accu-chek.com.mx): 4 cajas de 25 + 2 cajas de 100. Envío a Chinampac de Juárez. Total **$626.40**.

| Piezas | EAN | SKU | Nombre mostrador | Costo | PVP | Recargo | Margen |
|---|---|---|---|---|---|---|---|
| 4 | `4015630018277` | `FC-30018277` | Accu-Chek Softclix lancetas 25 piezas | $75.40 | **$85** | +12.7% | 11.3% |
| 2 | `4015630018284` | `FC-30018284` | Accu-Chek Softclix lancetas 100 piezas | $162.40 | **$180** | +10.8% | 9.8% |

4 × 75.40 + 2 × 162.40 = **$626.40**.

## ¿Tiene sentido el PVP?

Sí como precio de mostrador frente a la competencia: Similares cobra **$86** las de 25. Quedás $1 abajo.

Está **abajo del piso de marca** (+25% al costo → $94 / $203). Compraste a **lista oficial Roche**, no a mayoreo. Ganancia si se venden las 6 cajas: **$73.60**.

Por lanceta: 25 → $3.40 · 100 → $1.80. La de 100 es la oferta.

## Qué pegar en Supabase

1. `sql/patch_carga_accuchek_softclix_20260917.sql` — altas (si no existen) + costo/PVP + cola Recibir borrador.
2. Tras merge/deploy de Vercel las fotos viven en `farmacapital.mx/catalogo-propia/`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja. No hay lote ni caducidad en el comprobante.

Fotos (packshot oficial Roche, no Fahorro):

- `public/catalogo-propia/accu-chek-softclix-25-4015630018277.jpg`
- `public/catalogo-propia/accu-chek-softclix-100-4015630018284.jpg`
