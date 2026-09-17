# Fotos faltantes — URLs del usuario (17-sep-2026)

Packshots conseguidos de las fichas que pasaron. SQL:
`sql/patch_fotos_faltantes_urls_usuario_20260917.sql`.

| Producto | EAN / SKU | Fuente | Archivo propia |
|---|---|---|---|
| Clorofil Jahvs solución 500 mL | `6358975544000` | Sanorim / Shopify | `clorofil-jahvs-500ml-6358975544000.jpg` |
| A-Derma Exomega Control crema de noche | `3282770397666` | aderma.mx (Pierre Fabre) | `exomega-control-crema-noche-3282770397666.jpg` |
| Acarbosa 50 mg C/30 Alpharma | `7503004908875` | Farmatodo `_01` | `acarbosa-50mg-30tab-7503004908875.jpg` |
| Ácido alendrónico AMSA 10 mg C/30 | `7501349014190` | Farmatodo `_01` | `alendronico-10-7501349014190.jpg` |
| Savilé roll-on bicarbonato y limón 45 mL | `75068622` / `FC-75068622` | savilemexico.com | `savile-rollon-bicarbonato-limon-75068622.jpg` |
| Bicarbonato Velázquez 200 g | `7503022640153` / `FC-08DB70CB` | Foto mostrador + fondo blanco | `bicarbonato-velazquez-200g-7503022640153.jpg` |

## Cómo aplicar

1. Pegar el SQL de las 5 URLs vivas (Clorofil → Savilé + alendrónico) ya; se ven al instante.
2. Merge / deploy de `public/catalogo-propia/` (sobre todo el bicarbonato).
3. Si el bicarbonato no entró en el primer pegado (CDN 404), volver a pegar el SQL completo tras el deploy.

Exomega solo actualiza filas con ese EAN; si el producto aún no está en catálogo, el `update` no hace nada hasta el alta.
