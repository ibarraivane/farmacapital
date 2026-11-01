# Fotos SVR + Sun Secure Teinté (2026-11-01)

## Qué corrige

1. Packshots oficiales de `mx.svr.com` para el stock SVR (antes casi todos sin foto).
2. Distinción clara Blur **sin color** vs Blur **Teinté (con color)** en nombre + presentación.

| EAN | SKU | Nombre en POS | Stock típico |
|---|---|---|---|
| `3662361002597` | `FC-61002597` | SVR Sun Secure Blur SPF50+ · *50 ml · sin color* | 20 |
| `3662361003167` | `FC-61003167` | SVR Sun Secure Blur Teinté SPF50+ · *50 ml · con color* | 10 |

## Por qué no salían las fotos

El SQL anterior apuntó a `https://www.farmacapital.mx/catalogo-propia/svr-….jpg`,
pero esas JPGs solo viven en el PR hasta el merge a `main`. En producción
responden el HTML del SPA → el POS hace `onError` y muestra la caja amarilla «SVR».

## Cómo aplicar (YA, sin esperar merge)

1. Pegar en Supabase → Run: **`sql/patch_fotos_svr_cdn_inmediato_20261101.sql`**
   (usa CDN oficial de SVR / Shopify; responde 200 hoy).
2. Recargar el POS (Ctrl+Shift+R). Ampoule Flash, Topialyse y los dos Blur deben
   traer foto; Teinté debe decir **Teinté** / con color.

Las JPGs en `public/catalogo-propia/` siguen en el PR para cuando se mergee;
después se puede volver a URLs propias si se quiere.
