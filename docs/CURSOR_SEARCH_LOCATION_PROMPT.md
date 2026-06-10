Quiero que implementes una mejora funcional importante en FARMACAPITAL sobre la búsqueda de medicamentos/productos y la ubicación física en farmacia.

CONTEXTO
FARMACAPITAL es una farmacia. La lógica actual de búsqueda no es suficiente para la operación real.
En una farmacia, un medicamento se debe poder encontrar por:
- ingrediente activo / principio activo
- denominación genérica
- marca / patente / denominación distintiva
- presentación / concentración / forma farmacéutica cuando aplique

Además, en el POS y en la operación de mostrador, cuando la vendedora encuentra un producto en el sistema, debe ver claramente DÓNDE está ubicado físicamente en la farmacia para surtirlo más rápido.

NO quiero un refactor masivo.
Quiero cambios seguros, prácticos y bien pensados.

OBJETIVOS

A. BÚSQUEDA FARMACÉUTICA CORRECTA
Quiero que la búsqueda en:
1. tienda pública
2. panel admin / catálogo
3. POS

permita encontrar productos por:
- nombre actual
- principio activo
- denominación genérica
- marca / patente / denominación distintiva
- concentración
- presentación
- forma farmacéutica si ya existe o es razonable añadirla

CASOS REALES QUE DEBE SOPORTAR
- Si alguien busca “ibuprofeno”, debe encontrar productos relacionados aunque la marca sea distinta.
- Si alguien busca una marca/patente, debe encontrar ese producto y, si es razonable, mostrar equivalentes relacionados por ingrediente activo.
- Si alguien busca una combinación o genérico, también debe encontrar coincidencias útiles.

IMPORTANTE
- No me interesa solo coincidencia exacta de nombre comercial.
- Quiero una búsqueda farmacéutica más inteligente y útil.

B. POS / UBICACIÓN FÍSICA DEL PRODUCTO
Cuando en POS o en el admin se encuentre un producto, quiero que el sistema muestre claramente su ubicación física dentro de la farmacia.

Debe poder soportar algo como:
- anaquel / estante / cajón / zona
- ejemplo:
  - Anaquel A-03
  - Cajón B-02
  - Refrigerador 1
  - Controlados
  - Mostrador
  - Bodega
  - Consultorio

Si hoy no existe estructura formal para eso, implementa la solución mínima viable y segura.

PREFERENCIA
Si es viable sin complicar mucho, deja preparado algo como:
- ubicacion_texto
o
- zona / anaquel / nivel / cajon
según lo que mejor encaje con el repo actual

MÍNIMO VIABLE
- que el producto tenga una ubicación visible y editable
- que el POS la muestre claramente en resultados o detalle
- que la vendedora pueda usarlo para encontrar rápido el producto

C. DIFERENCIA POR MÓDULO

1. TIENDA PÚBLICA
La búsqueda debe ser más amigable para cliente:
- buscar por marca
- buscar por genérico
- buscar por ingrediente activo
- tolerar variaciones razonables
- si es viable, sugerir equivalentes o relacionados

2. ADMIN / INVENTARIO
La búsqueda debe servir para gestión:
- nombre
- SKU
- ingrediente activo
- marca
- presentación
- proveedor si ya existe

3. POS
La búsqueda debe ser rápida y operativa:
- nombre
- ingrediente activo
- marca
- SKU
- y debe mostrar:
  - ubicación física
  - stock
  - si requiere receta / si es controlado / si es antibiótico / OTC, si ya existe esa lógica o está cerca

D. DATOS / MODELO
Revisa cómo está modelado hoy el producto.
Quiero que detectes si ya existen campos similares o si hay que preparar algo mínimo para:
- principio_activo
- denominacion_generica
- denominacion_distintiva / marca
- concentracion
- presentacion
- forma_farmaceutica
- ubicacion / ubicacion_texto / anaquel / zona

NO inventes backend enorme si no hace falta.
Si algo no existe, haz el cambio mínimo y claro.
Si necesitas SQL adicional, créalo de forma segura en un archivo dentro de sql/ y documéntalo.

E. EXPERIENCIA VISUAL
Quiero que en el POS, cuando aparezca el resultado de un producto, se vea algo como:
- nombre
- presentación / concentración
- stock
- ubicación
- badges/reglas si aplica

Ejemplo visual deseado:
Ibuprofeno 400 mg · Caja 10 tabs
Stock: 24
Ubicación: Anaquel B-02
OTC

F. RESTRICCIONES
- No quiero refactor masivo.
- No quiero romper tienda, admin ni POS.
- No quiero tocar seguridad SQL salvo que sea estrictamente necesario.
- No quiero una “búsqueda con IA”; quiero una búsqueda farmacéutica práctica, útil y mantenible.
- Si se necesitan cambios pequeños en tablas/columnas, documenta y crea SQL seguro.

ARCHIVOS PROBABLEMENTE IMPORTANTES
- src/Tienda.jsx
- src/Admin.jsx
- src/InventarioModule.jsx
- src/modules/sales/pos/POS.jsx
- src/constants.js
- src/utils/*
- src/shared/*
- cualquier módulo real de búsqueda o catálogo
- SQL/migraciones relacionadas con productos

VALIDACIÓN FINAL
Después de aplicar cambios:
1. corre build
2. revisa imports rotos
3. confirma que:
   - tienda busca por marca / activo / genérico
   - admin busca por campos más útiles
   - POS muestra ubicación del producto
4. deja un resumen claro de:
   - archivos modificados
   - qué campos usaste o agregaste
   - si hubo SQL adicional
   - qué quedó pendiente

ENTREGABLE FINAL
Quiero:
1. Resumen ejecutivo corto
2. Qué cambiaste
3. Archivos modificados
4. Si hubo SQL adicional, nombre del archivo y cómo correrlo
5. Cómo quedó la búsqueda en:
   - tienda
   - admin
   - POS
6. Cómo quedó la ubicación del producto
7. Resultado de build

NO te quedes en recomendaciones.
Analiza el repo e implementa estas mejoras de forma segura y coherente.
