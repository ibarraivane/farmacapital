# Tickets Recibir · 16-oct-2026

Fotos La Hacienda Pets + El Surtidor + Equilibrio + Bodega F-42. Pegar **cada** SQL en Supabase → SQL Editor → Run.

| Pedido | Archivo | Piezas | Total |
|--------|---------|--------|-------|
| La Hacienda Pets | `patch_carga_hacienda_143865.sql` | 2 | $290.00 |
| El Surtidor | `patch_carga_surtidor_146002.sql` | 16 | $1,276.88 |
| Equilibrio | `patch_carga_equilibrio_448303.sql` | 10 | $181.10 |
| Bodega F-42 | `patch_carga_bodega_f42_86064.sql` | 46 | $1,812.74 |

## Todo-en-uno

`patch_carga_tickets_20261016_TODOS.sql`

## Notas

- Equilibrio 448303 trae **lote 7230526**. El papel dice caducidad 31/05/2029; no se guarda. MMAA de la caja. Clave ALPO608 = Alpharma `7501384541163`.
- Surtidor: costo = total neto del renglón. Jardianz queda en $991.87, no en la lista de $2,717.46. El agua cierra $285.01 en el papel y $285.00 en el SQL (15 × $19.00).
- La Hacienda Pets no trae código. En Recibir se toca el renglón gris. El EAN de la botella se anota después en la ficha.
- Bodega F-42: costo = P.U. a 2 decimales. El total pagado con tarjeta es $1,812.74. La suma de renglones a 2 decimales queda en $1,812.73 (el papel trae milésimas).
- Ricitos de Oro: el renglón dice «C 12» y la cantidad impresa es 1 pieza de 500 ml.
- Precio de alta = recargo sobre ese costo (marca +25%, genérico +60%). Si el producto ya tenía precio, no se pisa.
- Foto pendiente (el alta queda sin imagen hasta conseguir packshot): BIC Flex 5, BIC Flex 3, Secret Cherry Blossom, Secret Berry, Secret Orange Blossom, Grisi algas rojas, Axe Dark Temptation, Ricitos de Oro lavanda y lechuga, Lactacyd Pro-Bio, Silkhair manzana / uva / coco, Pantene rizos definidos 200 ml, Head & Shoulders romero, Head & Shoulders anti comezón, T.Taio Bathtime, esponja redonda, Evenflo Basic, Gillette gel aloe, Gillette Sport Triumph, Gillette Cool Wave 45 g, Pantene cuidado clásico 2 en 1 100 ml, agua destilada La Flor.
- Regenerar: `python3 scripts/generar_carga_tickets_20261016.py`
