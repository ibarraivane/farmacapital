# Ticket Farmalive 12127 · 28-sep-2026

Club Iztapalapa 1 · Club de Precios · ticket **12127** · 28/09/2026 16:24.

## Cómo pegar en Supabase (si sale «Load failed»)

Ver pasos cortos con links raw: [`LEERME_farmalive_12127_PASOS.md`](LEERME_farmalive_12127_PASOS.md).

Si A1+A2 ya corrieron: `B1_01` … `B1_08` (altas de a 8) → `B1_costos` → `B2_recibir` → `B3_fotos`.
No uses `B1_catalogo.sql` (obsoleto; provoca Load failed).

| Artículos | Piezas | Subtotal ticket | Descuento | **Total** |
|-----------|--------|-----------------|-----------|-----------|
| 109 | 238 | $12,642.62 | −$945.82 | **$11,696.80** |

**Altas nuevas (63 SKUs):** stock 0 hasta Recibir.

**Ya en catálogo (46 renglones):** solo costo / ficha vacía; no pisa PVP.

## Notas

- Costo = P.U. neto del ticket (después de Descto 2–15%).
- Recargo marca +25% / genérico +60% solo si PVP estaba en 0.
- Sin lote ni caducidad: MMAA de la caja al escanear. No inventar `0000`.
- Suerox: ticket imprime 12 dígitos; SQL usa EAN canónico del catálogo (`6502400721541`, `6502400744481`, `6502400323252`).
- Rexona roll-on: códigos cortos del catálogo (`78924345`, `78924338`, `78926523`).
- Cloranfenicol Exakta: ticket truncó a `75049638` (se conserva; pistola puede traer EAN completo de la caja).
- Alliviax C/20 y 1× Sico Mutual vienen a $0.01 (promo ticket).
- Centavos: NIDO Kinder bolsa 8×$29.36 imprime $234.84; suma renglones $11,696.97 vs total ticket $11,696.80 (±$0.17).
- Altas sin packshot local (42): conseguir foto o SQL de foto después del deploy. No usar placeholder Fahorro.
- Regenerar: `python3 scripts/generar_carga_farmalive_12127.py`

## Altas (nombre mostrador)

- `7501017372751` Absorsec Grande · SIN FOTO
- `7501943471337` Absorsec toallitas · SIN FOTO
- `7501537103545` Adinol solución infantil · SIN FOTO
- `7502227425022` Algidol 400 mg · SIN FOTO
- `6502400503982` Alliviax 550 mg · SIN FOTO
- `7502211789918` Bromuro de pinaverio · SIN FOTO
- `7851187543278` Ciclox 200 mg · SIN FOTO
- `7803510003409` Ciruelax Forte · foto
- `7502222840349` Cloranfenicol gotas oftálmicas · SIN FOTO
- `75049638` Cloranfenicol ungüento oftálmico · SIN FOTO
- `780083148645` Cobedina NS · SIN FOTO
- `7501109762446` Colchiquim 1 mg · SIN FOTO
- `7501125139543` Combesteral · SIN FOTO
- `7501385491139` Deflamox Plus · SIN FOTO
- `7501033962530` Ensure Advance café · foto
- `7501033958717` Ensure Advance vainilla · foto
- `7502009744129` Erispan Compuesto · SIN FOTO
- `7502216808430` Esomeprazol 40 mg · SIN FOTO
- `7501590211201` Flextrin 25/200/300 mg · SIN FOTO
- `7500435162241` Head & Shoulders 2 en 1 Suave y Manejable · foto
- `7500435162265` Head & Shoulders Limpieza Renovadora · SIN FOTO
- `7500435169004` Herbal Essences Ondas Perfectas mousse · SIN FOTO
- `7501349028654` Hipromelosa oftálmica · SIN FOTO
- `759684431234` Jaloma manzanilla toallitas · SIN FOTO
- `7501007501031` Johnson's Baby jabón neutro · SIN FOTO
- `7506425601790` Kimbies Durazno Aloe toallitas · SIN FOTO
- `7501008491041` Lotrimin Power spray · foto
- `7502276040566` Lotrimin Uno crema · foto
- `7501059225350` Nido Kinder · foto
- `7800005082024` Oral-B Essential hilo dental · SIN FOTO
- `7500435127363` Oral-B Kids Mickey pasta dental · SIN FOTO
- `7500435137737` Oral-B Kids Princess pasta dental · SIN FOTO
- `7501289511438` Pasta Lassar · SIN FOTO
- `7502240450711` Punab 100 mg · SIN FOTO
- `7502208894946` Puribel 300 mg · SIN FOTO
- `7501019031137` Saba Amore con alas · SIN FOTO
- `7501058799685` Sico Mutual Climax · foto
- `6502400368802` Silka Medic spray · foto
- `7501080911185` Sterimar Alergias spray · foto
- `7501080912274` Sterimar Bebé spray · foto
- `7501080911178` Sterimar Cobre spray · foto
- `7501080954212` Sterimar Infantil spray · foto
- `7501943434622` Suavelastic Chico · SIN FOTO
- `7501943447615` Suavelastic Extra Jumbo · foto
- `7501943444966` Suavelastic Jumbo · foto
- `7501943444928` Suavelastic Mediano · SIN FOTO
- `7501943498815` Suavelastic Recién nacido · foto
- `7506425618200` Suavelastic Vitta E toallitas · SIN FOTO
- `6502400801668` Suerox Mineral fresa kiwi · SIN FOTO
- `6502400801590` Suerox Mineral mora azul · SIN FOTO
- `7147061009016` Sukrol · SIN FOTO
- `6758730020570` Sukrol Hombre · foto
- `6758730020716` Sukrol Mujer · foto
- `7506295369363` Tampax Pearl Regular · SIN FOTO
- `6502400331318` Vanart Hierbas shampoo · SIN FOTO
- `6502400331554` Vanart Rosa enjuague · SIN FOTO
- `7501048640034` Vaso recolector Degasa · SIN FOTO
- `7501573900221` Vexotil 10 mg · SIN FOTO
- `7501258205863` Visertral 10 mg · SIN FOTO
- `7502250340255` Vitacilina Bebé · foto
- `7502250342556` Vitacilina serum facial retinol · SIN FOTO
- `7502250340521` Vitacilina ungüento · foto
