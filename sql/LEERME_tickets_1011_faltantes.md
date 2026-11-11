# Faltantes 10-nov (pegar en Supabase)

Benavides `7993605` ya está. Faltan 5.

## Opción A (recomendada): un solo archivo

1. Abre en el **navegador** (Chrome/Safari):
   https://raw.githubusercontent.com/ibarraivane/farmacapital/main/sql/patch_recibir_tickets_1011_SOLO_pegar_esto.sql
2. Cmd/Ctrl+A → Copiar → Supabase SQL Editor → Run.
3. (Re-corre Benavides: es idempotente.)

## Opción B: solo faltantes (2 pegadas)

1. Parte 1: `sql/patch_recibir_tickets_1011_FALTANTES_parte1.sql` (Cityfarma + Equilibrio)
2. Parte 2: `sql/patch_recibir_tickets_1011_FALTANTES_parte2.sql` (Farmalive + F-42 + FESA + VERIFICACION)

Raw parte 1 / parte 2 tras merge a main.
