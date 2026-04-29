Quiero aplicar un cambio quirúrgico en el catálogo móvil de FARMAX porque el scroll todavía se atora al intentar subir o bajar sobre las product cards.

SÍNTOMA REAL
En la vista catálogo móvil, al poner el dedo sobre la card del producto (especialmente en la parte blanca con el nombre), el scroll sigue atorándose o rebotando.
Ya hubo intentos con touch guards, pointer capture y touchAction, pero el problema persiste.

DIAGNÓSTICO
La product card sigue compitiendo con el gesto vertical porque demasiadas zonas siguen siendo clickeables o interpretables como tap:
- imagen
- nombre
- bloque blanco
- wrappers internos

OBJETIVO
En móvil, priorizar scroll fluido sobre card completamente clickeable.

SOLUCIÓN QUE QUIERO
En móvil (max-width: 768px o la condición equivalente que ya usa el componente):
1. La product card NO debe ser clickeable en toda su superficie.
2. La imagen NO debe abrir detalle.
3. El nombre NO debe abrir detalle.
4. El bloque blanco del contenido NO debe abrir detalle.
5. Solo deben quedar clickeables:
   - botón "Ver detalle"
   - botón "+ Carrito"
6. Mantener desktop igual si hoy funciona bien.
7. Mantener el estilo visual de la card.
8. El objetivo es que al deslizar sobre cualquier parte de la card en móvil, el scroll funcione de inmediato y sin rebote.

ARCHIVO PRINCIPAL
- src/Tienda.jsx

ZONA A MODIFICAR
- ProductCard

QUÉ QUIERO QUE HAGAS
1. Detecta el comportamiento actual de ProductCard en móvil.
2. Implementa un “modo seguro móvil”:
   - quitar onClick de imagen/nombre/bloque blanco/raíz si esos disparan detalle
   - dejar interacción solo en botones explícitos
3. Simplifica el manejo táctil en móvil:
   - si el guard táctil ya no hace falta en zonas no clickeables, elimínalo o redúcelo
   - no uses pointer capture donde ya no sea necesario
4. Mantén:
   - botón "Ver detalle"
   - botón "+ Carrito"
5. No hagas refactor masivo.
6. Corre npm run build al final.

IMPORTANTE
- Quiero priorizar experiencia táctil fluida en catálogo móvil.
- Prefiero perder click en superficie completa de la card, antes que seguir con scroll atorado.
- Desktop puede conservar el comportamiento más rico si hace sentido.
- No quiero que el usuario tenga que intentar dos veces para bajar.

VALIDACIÓN FINAL
Después de aplicar cambios:
1. corre build
2. resume:
   - qué zonas dejaste no clickeables en móvil
   - qué zonas siguen siendo clickeables
   - qué simplificaste en el manejo táctil
   - resultado de build

ENTREGABLE FINAL
Quiero:
1. Resumen ejecutivo corto
2. Qué causaba la competencia con el scroll
3. Archivos modificados
4. Qué cambiaste en ProductCard
5. Resultado de build
