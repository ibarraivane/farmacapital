# Arreglar Recibir · 03-nov-2026

## Qué fallaba

1. **Nadro 6091723171** (29-oct): en Recibir salían **2 amarillos** — BPOllen 5% y 2.5% sin registrar. El SQL del ticket quedó en PR #505 sin merge; el alta BPOllen (#519) usaba bloques dollar-quote y Supabase lo corta.
2. **Tickets “no aparecen”**: el merge a GitHub **no** crea la cola. Hay que pegar el SQL en Supabase. Tenorio / Fanasa / Nadro 6091110421 ya están en `main`; falta Run.

## Pegar en este orden (Supabase → SQL Editor → Run)

### A) Arregla el Nadro que ves ahora (BPOllen)

`sql/patch_bpollen_SOLO_pegar_esto.sql` (Raw en GitHub → copiar TODO → Run)

- Alta `FC-02461306` / `FC-02461290`
- Enlaza los renglones `pendiente_alta`
- Costos del ticket: $185.63 (5%) / $170.78 (2.5%) → PVP $233 / $214 (+25%)
- Sin temp tables ni dollar-quote (eso tumba el SQL Editor)

### B) Si el ticket Nadro 6091723171 no está completo o no existe

`sql/patch_carga_nadro_6091723171.sql`

8 renglones / $1,119.31. Idempotente en borrador.

### C) Tickets recientes en main (si aún no salen en Recibir)

| Archivo | Folio | Total |
|---|---|---|
| `sql/patch_carga_tenorio_3838940.sql` | Tenorio **3838940** | $1,148.52 |
| `sql/patch_carga_fanasa_b49445264.sql` | Fanasa **B49445264** | $667.19 |
| `sql/patch_carga_nadro_6091110421.sql` | Nadro **6091110421** | $644.52 |

### D) Diagnóstico

`sql/diag_recepciones_recientes_20261103.sql`

## Después

1. Recargar Recibir en la tablet.
2. Nadro 6091723171: BPOllen ya no pide alta → MMAA de la caja → Guardar.
3. Telmisartán 40 mg: si ves cad **03/2008**, corrige a **03/2028** (typo al teclear).
4. Fotos BPOllen / Asepxia / Contour viven en `catalogo-propia/` tras el deploy de este PR.
