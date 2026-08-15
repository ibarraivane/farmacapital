# Auditoría — lista usuario vs catálogo (FarmaLive FL-080826)

Ticket OCR: `.tmp_ocr_vision/FarmaLive.txt` (#9861, 08/08/2026)

| Producto | Barcode | Estado | SKU | Detalle |
|----------|---------|--------|-----|---------|
| xl-3 | `650240017100` | ✅ Registrado | FC-40017100 | Xl-3 Vr |
| xl-3 tab | `6502400170941` | ✅ Registrado | FC-00170941 | XL-3 Xtra C/12 |
| xl-3 tab c/10 | `6502400525451` | ✅ Registrado | FC-00525451 | XL-3 C/10 |
| vitacilina bebe | `354312225164` | ✅ Registrado | FC-12225164 | Vitacilina Bebé Pomada |
| vitacilina 28 | `750222503430721` | ✅ Registrado | FC-03430721 | Vitacilina 28 Crema |
| vitacilina ung | `750022503405381` | ✅ Registrado | FC-03405381 | Vitacilina Ungüento |
| afrin spray | `75010506134531` | ✅ Registrado | FC-06134531 | Afrin DTC rojo spray |
| derma crema | `7501354312225027` | ✅ Registrado | FC-12225027 | Derman Crema |
| tribedoce | `75022088947797` | ✅ Registrado | FC-88947797 | Tribedoce Tabletas |
| nasalub sol | `650240015366` | ✅ Registrado | FC-40015366 | Nasalub Sol |
| next tac c/10 | `650240010538` | ✅ Registrado | FC-40010538 | Next Tab |
| silka medic gel | `65024000740024` | ✅ Registrado | FC-00740024 | Silka Medic Gel |
| contact ultra | `75029650608272` | ✅ Registrado | FC-50608272 | Contac Ultra |
| deeflamox plus | `7503854221482` | ✅ Registrado | FC-54221482 | Deeflamox Plus |
| tribedoce 5000 | `75015015371829601` | ✅ Registrado | FC-71829601 | Tribedoce |
| riopan sobres | `7507201092730451` | ✅ Registrado | FC-92730451 | Riopan Sobres |
| aderogyl amp | `36647980596011` | ✅ Registrado | FC-80596011 | Aderogyl Amp |
| tempra forte | `75010954525051` | ✅ Registrado | FC-54525051 | Tempra Forte C/24 |
| tukol-d inf | `6502400315021` | ✅ Registrado | FC-00315021 | Tukol-D jarabe infantil |
| tukol-d adto | `650240010712` | ✅ Registrado | FC-40010712 | Tukol-D jarabe |
| rocainol ung | `7501312250181` | ✅ Registrado | FC-12250181 | Rocainol Ung |
| genoprasol tab | `650240036354` | ✅ Registrado | FC-40036354 | Genoprazol Tab |
| cond sico invisible | `7501685171118` | ✅ Registrado | FC-85171118 | Condón Sico |
| cond sico negro feel | `7501058367129` | ✅ Registrado | FC-58367129 | Condón Sico Negro Feel |
| condon sico rojo feel | `75010583683367` | ✅ Registrado | FC-83683367 | Condón Sico Rojo Feel |
| tabcin eferb | `7501008485316` | ✅ Registrado | FC-08485316 | Tabcin Eferv |
| fazolin f gotas | `780083146207` | ✅ Registrado | FC-83146207 | Fazolin F (nafazolina) |
| syncolmax | `7501210734092301` | ✅ Registrado | FC-34092301 | Syncol Max tabletas |
| graneodin b | `7501058715517` | ✅ Registrado | FC-58715517 | Graneodin B (benzocaína) |
| bepanthen | `7501008427330` | ✅ Registrado | FC-08427330 | Bepanthen Pomada Protectora Contra Rozaduras |
| antifludes | `750525301508201` | ✅ Registrado | FC-01508201 | Antiflu-Des |
| theraflu td | `7503050071598` | ✅ Registrado | FC-50071598 | Theraflu TD |
| splash tears | `7509854054221` | ✅ Registrado | FC-54054221 | Splash Tears Sol oftálmica |
| alka-seltzer boost tab | `75010084999001` | ✅ Registrado | FC-84999001 | Alka-Seltzer |
| tempra jbe | `75012501050724298` | ✅ Registrado | FC-50724298 | Tempra jarabe |
| iodex cristal | `7501064560163` | ✅ Registrado | FC-64560163 | Iodex Cristal |
| estomaquil | — | ❓ No en ticket OCR | — | Cotización/ticket distinto |
| pharmaton complete | — | ❓ No en ticket OCR | — | Cotización/ticket distinto |
| posacaina | — | ❓ No en ticket OCR | — | Cotización/ticket distinto |
| redoxon | — | ❓ No en ticket OCR | — | Cotización/ticket distinto |
| eucaliptine | — | ❓ No en ticket OCR | — | Cotización/ticket distinto |

## Resumen
- **Registrados en catálogo:** 36
- **Faltan cargar:** 0
- **No encontrados en ticket OCR:** 5

## Causa raíz
El parser FarmaLive solo reconocía barcodes `750…`/`354…`. Los productos **Genomma Lab** (`65024…`) y varios OCR truncados **nunca entraron** al SQL de carga; otros quedaron con nombres mezclados (ej. Vitacilina 28 dentro del lubricante).

## SQL generado
Ejecutar en Supabase **después** de `sql/patch_cargar_faltantes_0_fix_rpcs.sql`:

`sql/patch_cargar_faltantes_1b_farmalive_corregido.sql` (0 productos)
