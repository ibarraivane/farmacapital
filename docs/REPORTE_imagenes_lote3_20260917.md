# FarmaCapital — SKUs sin imagen, lote 3 (17-sep-2026)

Partí de los cuatro archivos del lote 2 (revisión visual). No volví a
aceptar lo que ya se había mirado y rechazado. Busqué de nuevo los 51
pendientes y bajé los candidatos del lote 2 que sí se pueden copiar.

## Resultado

| | Lote 2 (lista) | Lote 3 (este PR) |
|---|---|---|
| Nuevas fotos en `catalogo-propia/` | 0 (solo CSV) | **13** |
| SQL que cablea foto ya existente | — | **2** (Ferro-4, Baby Einstein) |
| Siguen sin imagen usable | 51 | **41** |

SQL: `sql/patch_fotos_lote3_restantes_20260917.sql`
después del deploy de Vercel.

## Lo que sí entra

| ID | Producto | Fuente | Nota |
|---|---|---|---|
| 243 | Pantene Control Caída 400 ml | Farmatodo | El EAN del catálogo es `7501001303454`. El packshot oficial / Farmatodo es `…3464` (un dígito). Misma presentación. Confirmar contra la caja. |
| 339 | Alcohol Dibar 96° 250 ml | Promexsa | Ficha del fabricante/distribuidor, botella blanca tapa roja. |
| 1270 | Xiomara Pomada Black 60 g | Chedraui | EAN exacto. El registro decía «Pomada B»; la ficha es Cera Black. El SQL corrige el nombre. |
| 1633 | Jaloma Mertodol atomizador | Almacenes Farah | Ya pasaba la revisión visual del lote 2. |
| 1760 | Zagapsol 5 mg C/10 | Phemedica | Lote 2, packshot limpio. |
| 1762 | Clorofil Jahvs 500 ml | Sanorim | Lote 2. |
| 1801 | Cloropiramina Schoen 25 mg | Sanorim | Lote 2. |
| 1720 | Pinza Lady Curtis mini 58LC | curtis.com.mx | EAN `7501370204584` en DISA / ficha oficial. |
| 1721 | Pinza Lady Curtis maxi 57LC | curtis.com.mx | EAN `7501370204577`. |
| 1315–1319 | Gerber Etapa 2 res / pollo / durazno / mango | Nestlé FamilyNes | Packshot oficial México. Nestlé ya publica **113 g**; el registro sigue en 100 g. Misma línea, gramaje actualizado. |
| 1771 | Ferro-4 | ya en repo | El JPG existía; faltaba pegar el SQL. |
| 1719 | Baby Einstein Busy Bubbles | ya en repo | Igual. |

## Lo que miré y no usé (otra vez)

| Producto | Por qué no |
|---|---|
| Droguería Mercurio (12) | Siguen midiendo ~100 px. Inútiles en catálogo. |
| Esencia de clavo Herbotec | Farmasuper entrega 113×231. |
| Perilla N3 Dr. Ahorro | 4 KB, caja dibujada. |
| Copa lavaojos Herrera | Es el producto, pero es la bolsa. |
| Vaso recolector Dibar Promexsa | 225 px. |
| Sico C/3 | La foto oficial es Safety. El registro no dice qué línea. |
| Gillette Prestobarba 3 ×1 | La ficha oficial es 2/4/16/20; no hay packshot de pieza suelta. |
| Jaloma agua de rosas 130 ml | jaloma.com.mx solo tiene 250 ml. |
| Algodón Dibar 200 g | Promexsa tiene 75 / 300 / 500 g, no 200. |
| Quitaesmaltes SKN | Los registros siguen en «variante · confirmar». |
| Cintas Cintapore | DISA lista el EAN y no pone foto. Las genéricas de retail no coinciden en ancho. |
| Gerber superdtodo / surtace | Rechazadas en lote 2 (recorte, precio $11). No las toqué. |

## Por qué quedan 41

No cambió el diagnóstico del lote 2:

1. **Códigos internos `2008…`** — Gillette suelto, cubrebocas, peines, Tinkle, dona, perilla N1, tijera. No existen fuera de la farmacia.
2. **Sin EAN y nombre incompleto** — Ursodesoxicólico, Eferox, Gentamicina, Tratidri, «Mercurio», «FC producto botiquín», perillas N2/N4/N6, brocha.
3. **Genéricos o registro ambiguo** — cintas, SKN, Sico sin línea, Protect aerosol 12.80 G, Piojitos, Sanax, Riegel, Termo Fifa, Velázquez alcanfor, Bicarbonato 200 g (la foto de teléfono del otro agente no está en este árbol).

Esos van a foto propia o a arreglar el registro. Seguir buscando por EAN no los va a resolver.

## Orden

1. Merge / deploy (los JPG viven en `public/catalogo-propia/`).
2. Pegar `sql/patch_fotos_lote3_restantes_20260917.sql` en Supabase.
3. El parche de portada vacía del 15-sep (`patch_imagen_principal_faltante_20260915.sql`) sigue vigente.

## Archivos

| Archivo | Qué es |
|---|---|
| `sql/patch_fotos_lote3_restantes_20260917.sql` | Carga de las 15 |
| `sql/generated/siguen_sin_imagen_lote3_20260917.csv` | Los 41 que quedan |
| `sql/generated/candidatos_imagenes_v2_20260917.csv` | Lote 2 (revisión visual) |
| `docs/REPORTE_imagenes_v2_20260917.md` | Informe del lote 2 |

## Fuentes nuevas de este lote

[Nestlé FamilyNes](https://www.nestlefamilynes.com.mx/) · [Curtis](https://curtis.com.mx/) · [Promexsa](https://www.promexsa.com.mx/) · [Farmatodo](https://www.farmatodo.com.mx/) · [Chedraui](https://www.chedraui.com.mx/) · Sanorim · Phemedica · Almacenes Farah
