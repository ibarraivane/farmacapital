# Pegar YA — fotos del lote 19-sep (URLs vivas)

El SQL de ayer (`patch_fotos_faltantes_urls_20260919.sql`) ya se corrió y el deploy de Vercel también, **pero las fotos no se ven**. Motivo:

- Ese SQL apuntó a `https://www.farmacapital.mx/catalogo-propia/<archivo>.jpg`
- Esos JPG **no están en `main`**. El PR #288 sigue abierto (draft).
- Un archivo que no existe en producción lo responde Vercel como `index.html` (200). El navegador no pinta imagen → tarjeta vacía.

El deploy que viste es el **preview** de la rama, no farmacapital.mx. La base sigue pidiendo los archivos a producción.

## Qué hacer ahora (1 minuto)

1. Supabase → SQL Editor.
2. Pegar **todo** `sql/patch_fotos_faltantes_urls_vivas_20260920.sql` → Run.
3. Recargar la tienda (mejor hard refresh).

Ese parche pisa las URLs rotas con jsDelivr del commit `7576424` (los mismos packshots). Esas URLs ya responden `image/jpeg` hoy.

No esperes a mergear el PR para ver las fotos.

## Después

Cuando #288 entre a `main` y Vercel produzca de nuevo, `farmacapital.mx/catalogo-propia/…` también servirá los JPG. No hace falta volver a pegar nada: jsDelivr sigue funcionando.
