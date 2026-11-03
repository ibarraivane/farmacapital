# Alta BPOllen 5% / 2.5% · Recibir sin registrar

Nadro **6091723171** mostraba 2 renglones amarillos:

| EAN | Producto | Costo ticket |
|---|---|---|
| `7502002461306` | BPOllen gel 5% tubo 60 g | $185.63 |
| `7502002461290` | BPOllen gel 2.5% tubo 60 g | $170.78 |

## Qué pegar

- Solo BPOllen: `sql/patch_alta_bpollen_recibir_20261102.sql`
- Ticket completo + BPOllen: `sql/patch_recibir_nadro_6091723171_y_bpollen_TODOS.sql`

**Sin `do $$`** (Supabase lo corta). Stock 0 hasta pistola + MMAA.

Ver también: `sql/LEERME_arreglar_recibir_20261103.md`.
