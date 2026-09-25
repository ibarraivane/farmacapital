# Vendas físicas mostrador (25-sep-2026)

SQL: `patch_alta_vendas_mostrador_20260925.sql`

| Producto | EAN | Acción |
|---|---|---|
| **Venda-stick** rojo 7.5 cm × 4.5 m | `7506484500140` | Alta nueva `FC-84500140` (el IFC 83552 es 2"/5 cm, otro SKU) |
| **Venda-stick** piel 7.5 cm × 4.5 m | `7506484500157` | Enlaza EAN a `FC-IFC-82912P` |
| **Venda-stick** azul 7.5 cm × 4.5 m | `7506484500164` | Enlaza EAN a `FC-IFC-82912A` |
| **Quirmex** premium 7.5 cm × 5 m | `7503003406730` | Ya existía `FC-34067301` — corrige nombre/presentación (no era 5 cm) |
| **Dibar** elástica 7.5 cm colores C/24 | `7501868950207` | Enlaza EAN a `FC-IFC-83733` · lote `5C025C02` · cad 2030-03 · venta por pieza **$20** |

## Precios

- Venda-stick: costo ancla IFC (~$45–47.50) · PVP $72 / $76 (línea ya cargada).
- Dibar paquete: costo ticket **$318** · PVP caja **$398** · pieza **$20**.
- Quirmex: no cambia precio (ya en inventario ~$10).

## Cómo correr

Supabase → SQL Editor → pegar el patch completo → Run.  
Fotos en `public/catalogo-propia/` (URL viva tras deploy).
