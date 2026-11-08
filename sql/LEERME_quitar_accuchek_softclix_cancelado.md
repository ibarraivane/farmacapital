# Quitar Accu-Chek Softclix de Recibir

Pedido **Tienda Accu-Chek** folio **20260917** ($626.40 · Softclix 25/100) — **cancelado, nunca llegará** (08-nov-2026).

## Qué correr

Pegar **todo** `sql/patch_quitar_accuchek_softclix_cancelado_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.

## Efecto

- Borra los renglones de la recepción abierta.
- Marca el encabezado `estado = confirmada` con nota de cancelación (no suma stock).
- La tarjeta desaparece de Recibir al recargar.

Catálogo / fotos Softclix se quedan (productos útiles); solo sale de la cola.
