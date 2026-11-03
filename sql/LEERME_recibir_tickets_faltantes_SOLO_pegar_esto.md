# Por que no salen Tenorio / Fanasa / Nadro 6091110421

El merge a GitHub **no** crea la cola. Hay que **Run** el SQL en Supabase.

Lo que ya ves (Nadro 8 cajas + Accu-Chek) ya esta en la base. Lo demas falta pegar.

## Pasos

1. Supabase → SQL Editor → New query
2. Raw: https://raw.githubusercontent.com/ibarraivane/farmacapital/main/sql/patch_recibir_tickets_faltantes_SOLO_pegar_esto.sql
3. Selecciona TODO → copiar → pegar → **Run**
4. Abajo: VERIFICACION con folios `3838940`, `B49445264`, `6091110421` en `borrador`
5. Tablet: Recibir → recargar (cerrar pestana / Actualizar)

Deben aparecer tarjetas nuevas: **Tenorio**, **Fanasa**, **Nadro** (6091110421).

## No uses la entrada manual con 440393

Ese folio es un Equilibrio viejo. Tenorio es **3838940** ($1,148.52). Si Run marca rojo, manda el texto completo.
