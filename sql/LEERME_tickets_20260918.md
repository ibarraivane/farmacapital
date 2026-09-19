NO PEGAR ESTE ARCHIVO EN SUPABASE. Es una nota. Si la primera línea empieza con `#`, el editor responde `syntax error at or near "#"`.

Hay que pegar el contenido de cada `patch_carga_….sql` (empiezan con `--`) en SQL Editor → Run.

# Tickets Recibir · 18-sep-2026

Cinco compras del mismo día en Central de Abasto. Pegar **cada** SQL (en cualquier orden). No suman stock: entran al escanear y poner el MMAA de la caja. No poner `0000`.

| Pedido | Archivo | Renglones | Piezas | Total |
|--------|---------|-----------|--------|-------|
| Equilibrio 444836 | `patch_carga_equilibrio_444836.sql` | 20 | 57 | $1,303.20 |
| Equilibrio 444871 | `patch_carga_equilibrio_444871.sql` | 2 | 12 | $220.94 |
| PerfuMax 550937 | `patch_carga_abasto_f48_550937.sql` | 15 | 23 | $1,466.50 |
| Cityfarma S323594 | `patch_carga_cityfarma_s323594.sql` | 1 | 3 | $546.54 pendiente |
| Farmalive 12949 | `patch_carga_farmalive_12949.sql` | 13 | 40 | $1,730.09 |
| Dulcería La Victoria T270040861 | `patch_carga_dulceria_victoria_T270040861.sql` | 2 | 26 | $445.34 |

Regenerar: `python3 scripts/generar_carga_tickets_20260918.py`

## Cómo escanear

- **Equilibrio 444871** (12:33, $220.94): mismo cliente. Pistola `75050764` (ungüento oftálmico Exakta) y `7502240450070` (Punab C/30). Lote del papel; caducidad de la caja.
- **Equilibrio 444836:** lote de fábrica sí (el del papel). Caducidad no: MMAA de la caja. Aktyzar C/14 (`EQ-SOF066`), cánula pediátrica (`EQ-JAY253`) y puntas adulto (`EQ-JAY267`) no traen EAN confirmado: toca el renglón gris, no esperes el beep.
- **PerfuMax:** el local es pasillo F48 A (RFC PMM211209B57, tel 55 7261-7572). En Recibir sale **PerfuMax**. Si ya se cargó como F-48 Abasto, el mismo SQL le cambia el nombre. Hinds 90 ml y Rexona Efficient 100 g sí pegan con pistola. El resto se toca.
- **Cityfarma:** orden S323594, pendiente de pago. El EAN `7501058715555` es Tempra Fen infantil (ibuprofeno), no el Tempra de paracetamol.
- **Farmalive:** el papel no trae lote. Costo = precio ya con descuento.
- **Victoria:** el papel dice Dulcería La Famosa; el negocio es La Victoria F-20. Turin son 4 conejos de 600 g. KitKat son 22 packs. Sin EAN: toca el renglón.

## No mezclar

- Betahistina AMSA `7501349029965` ≠ Bitenver `7502009747373`.
- Laritol C/20 `7502009742828` ≠ Laritol C/10 `7502009740435`.
- Aktyzar C/14 ≠ frasco C/120 `7501482200016`.
- Pañal Diapro predoblado `7501943474895` ≠ Diapro Med `7501943474994`.
- Ampigrin PFC cápsulas `780083148676` ≠ jarabe `780083148577`.
- Rosel solución pediátrica 30 ml `7502240451015` ≠ Rosel 60 ml `7502240450230`.
- Wernicros oseltamivir 75 mg EAN `7502240450902` (Sufarmed).
- Tempra Fen infantil 100 ml `7501058715555` ≠ Tempra paracetamol 80 mg `7501095452178` ≠ TempraFen 400 mg `7506460101002`.

## Fotos pendientes

Las altas nuevas no traen packshot en este SQL. No usar logo ni “imagen no disponible” de otra farmacia. Cuando haya foto real, va a `public/catalogo-propia/` y el `imagen_url` después del deploy.

Equilibrio sin foto: Dolver 800 mg, Doflatem, Laritol C/20, betahistina AMSA, Soltrim, ketorolaco SL AMSA, Doselmin, Aktyzar C/14, cánula pediátrica, puntas adulto.

Farmalive sin foto: Diapro predoblado, Tempra infantil C/30, Rosel sol 30 ml, Ampigrin PFC cápsulas, Lakesia, Vylkor, Wernicros.

PerfuMax sin foto: Lubriderm 750 y Aqua 400, Grisi avena y neutro, spray pie de atleta, Mexsana 160 g, Lactovit 250 y 400, Tampax Regular, Dove Men, Rexona Xtracool gel, Olorex 70 ml.

Cityfarma sin foto: Tempra Fen infantil 100 ml.

Victoria sin foto: Turin Conejo 600 g y KitKat Extra Milk & Cocoa.
