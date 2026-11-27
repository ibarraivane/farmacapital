# Equilibrio 452985 — pegar en Supabase

Equilibrio 452985 · pedido online Iztapalapa 2 · 25-nov-2026 11:34

- 1 renglón(es) · **4 pzas** · total guardado en Recibir **$67.33**
- Papel: Subtotal $58.04 + IVA $9.29 = Total $67.33 (pagado de caja, Miriam)

## Pegar ahora

1. Pegar **todo** `sql/patch_recibir_equilibrio_452985_SOLO_pegar_esto.sql` en Supabase → SQL Editor → **Run**.
2. Verificación al final: folio `452985`, estado `borrador`, 1 renglón(es), 4 piezas.
3. Tablet: Recibir → recargar → tarjeta **Equilibrio · 452985**.
4. Escanear cada caja. MMAA de la caja (no inventar `0000`). Lote: el del papel si viene, si no, el de la caja.

## Altas nuevas (stock 0)

- Ninguna. Todo ya estaba en catálogo.

## Ya en catálogo (solo costo nuevo)

- EQ-JAY253 · 7506022331038 · Cánula nasal para oxígeno pediátrica

## Revisar antes de publicar

- Caducidad impresa en el papel: 23/10/2030. El ticket de Recibir se carga con caducidad null (MMAA de la caja), como en los demás tickets de Equilibrio. Confirmar con la caja.
- Lote impreso 2510950005: se carga en el renglón. Confirmar contra la caja al escanear.
- Pagado de caja por Miriam ($67, según nota manuscrita en el papel).
