# Venda Dibar pieza + toallitas KleenBebé Absorsec · 27-sep-2026

## Vendas de colores — ¿tienen el EAN de la foto?

**No exactamente.** El alta de mostrador (25-sep, PR #371) pegó el EAN del **paquete C/24**:

| | Código |
|---|---|
| Registrado (caja C/24) | `7501868950207` → `FC-IFC-83733` / `FC-68950207` · pieza **$20** |
| Foto de hoy (rollo suelto) | `7501868902527` · «VENDA DEPORTIVA / 1 PIEZA» |

Son el mismo producto (Dibar elástica/deportiva colores): caja vs etiqueta del rollo. Este patch enlaza ambos para que la pistola del rollo abra el SKU.

## Toallitas KleenBebé Absorsec

| Presentación | EAN | SKU | Clave bolsa | PVP dueño |
|---|---|---|---|---|
| **140** (grandes) | `7506425662388` | `FC-25662388` | 96992 | **$30** |
| **90** (chicas) | `7501943471337` | `FC-43471337` | 96678 | **$22** |

Sin costo de compra (foto, no ticket). Stock 0 hasta Recibir. Distinto del Absorsec C/120 ya en catálogo (`7501943471900` / `FC-43471900`).

## Qué pegar en Supabase

1. `sql/patch_dibar_venda_pieza_ean_y_kleenbebe_toallitas_20260927.sql` — enlace EAN pieza + altas toallitas.
2. Tras merge/deploy: `sql/patch_fotos_kleenbebe_toallitas_20260927.sql`.

Fotos en `public/catalogo-propia/`:

- `kleenbebe-absorsec-140-7506425662388.jpg`
- `kleenbebe-absorsec-90-7501943471337.jpg`
- `dibar-venda-deportiva-pieza-7501868902527.jpg` (referencia; el SKU de caja sigue con su packshot)
