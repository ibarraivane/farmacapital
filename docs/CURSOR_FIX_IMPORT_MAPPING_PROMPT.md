Quiero que corrijas el importador de CSV del inventario/productos de FARMAX porque, aunque el archivo ya trae datos para marca, presentación, principio activo, ubicación y rubro, después de importar esos campos siguen apareciendo vacíos en la tabla del sistema.

PROBLEMA REAL
- Ya se generaron CSVs enriquecidos correctamente.
- La tabla del inventario sigue mostrando vacíos en:
  - Marca
  - Presentación
  - Principio activo
  - Ubicación
  - Rubro
- Eso indica que el problema ya no es el archivo, sino el mapeo/importación dentro del sistema.

QUIERO QUE REVISES
- el flujo de importación de CSV de productos/inventario
- qué columnas toma realmente
- a qué campos de la base o del estado del frontend las está asignando
- por qué hoy ignora marca/presentación/principio activo/ubicación/rubro

OBJETIVO
Hacer que el importador de inventario/productos sí acepte y guarde correctamente estos campos si vienen en el CSV.

CAMPOS QUE QUIERO SOPORTAR
Debe aceptar razonablemente variantes como:
- Marca
- marca
- Marca_Comercial

- Presentación
- Presentacion
- presentacion
- Presentacion_Completada

- Principio activo
- Principio_Activo
- principio_activo
- Principio_Activo_Completado

- Ubicación
- Ubicacion
- ubicacion
- ubicacion_texto

- Rubro
- rubro
- Grupo_Articulos
- Linea_General
- Jerarquia (si se usa como fallback)

TAMBIÉN QUIERO
- que NO se pierdan:
  - precio
  - costo
  - margen
  - marca
  - presentación
- que no solo importe nombre/SKU/stock

ARCHIVOS PROBABLEMENTE IMPORTANTES
- src/InventarioModule.jsx
- src/Admin.jsx
- cualquier modal o helper de importación CSV
- src/utils/*
- cualquier parser de CSV
- cualquier lógica de upsert/insert de productos
- SQL o columnas relacionadas de productos si hace falta

QUÉ QUIERO QUE HAGAS
1. Audita el importador CSV real.
2. Detecta qué columnas sí está leyendo hoy.
3. Corrige el mapeo para soportar los campos anteriores.
4. Si el problema es que faltan columnas reales en la tabla/producto, crea el SQL mínimo y seguro en sql/.
5. No hagas refactor masivo.
6. Mantén compatibilidad con el flujo actual.
7. Corre build al final.

VALIDACIÓN FINAL
Después de aplicar cambios:
1. corre build
2. confirma que el importador ya guarda:
   - marca
   - presentación
   - principio activo
   - ubicación
   - rubro
3. deja un resumen claro de:
   - archivos modificados
   - causa del problema
   - si hubo SQL adicional
   - resultado de build

ENTREGABLE FINAL
Quiero:
1. Resumen ejecutivo corto
2. Causa exacta de por qué no se estaban llenando esos campos
3. Archivos modificados
4. Si hubo SQL adicional, nombre del archivo y cómo correrlo
5. Resultado de build

NO te quedes en recomendaciones.
Corrige el importador para que estos campos sí entren y se reflejen en la tabla.
