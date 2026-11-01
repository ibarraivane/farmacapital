# Fotos SVR + Sun Secure Teinté (2026-11-01)

## Qué corrige

1. Packshots oficiales de `mx.svr.com` para el stock SVR (antes casi todos sin foto).
2. Distinción clara Blur **sin color** vs Blur **Teinté (con color)** en nombre + presentación.

| EAN | SKU | Nombre en POS | Stock típico |
|---|---|---|---|
| `3662361002597` | `FC-61002597` | SVR Sun Secure Blur SPF50+ · *50 ml · sin color* | 20 |
| `3662361003167` | `FC-61003167` | SVR Sun Secure Blur Teinté SPF50+ · *50 ml · con color* | 10 |

## Cómo aplicar

1. Merge/deploy de este PR.
2. Pegar `sql/patch_fotos_svr_teinte_20261101.sql` en Supabase → Run.
3. En POS buscar «SVR»: Ampoule Flash, Topialyse y los dos Blur deben traer foto; Teinté debe decir **Teinté** / con color.
