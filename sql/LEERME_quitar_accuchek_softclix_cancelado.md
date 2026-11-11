# Quitar Accu-Chek Softclix de Recibir

Pedido **Tienda Accu-Chek** folio **20260917** ($626.40 · Softclix 25/100) — **cancelado, nunca llegará** (08-nov-2026).

## Qué correr

Pegar **todo** `sql/patch_quitar_accuchek_softclix_cancelado_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.

Si el Run viejo no lo sacó: vuelve a pegar **este mismo archivo** (ya es el match amplio). Mira el primer result set (`tickets_a_cerrar`): si es `0`, la tarjeta de pantalla no es este Accu (anota proveedor/folio del result set “cola viva” y avísame).

## Efecto

- Borra los renglones de la recepción abierta.
- Marca el encabezado `estado = confirmada` con nota de cancelación (no suma stock).
- También cierra borradores vacíos Accu (Recibir los sigue listando si quedan en `borrador` sin renglones).
- La tarjeta desaparece de Recibir al recargar.

Catálogo / fotos Softclix se quedan (productos útiles); solo sale de la cola. No toca Cityfarma ni Nadro.
