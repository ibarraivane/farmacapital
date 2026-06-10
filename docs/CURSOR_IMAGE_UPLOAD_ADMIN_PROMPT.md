Quiero que implementes en FARMACAPITAL una funcionalidad real de gestión de imágenes dentro del panel administrativo, específicamente para:

1. banners de la tienda
2. fotos de productos del catálogo

PROBLEMA ACTUAL
- En el módulo de banners y en catálogo/productos, hoy la UI parece depender de emojis/placeholders o no tiene una carga real de imágenes usable.
- Yo necesito poder entrar al admin y:
  - subir imágenes
  - reemplazarlas
  - eliminarlas
  - ver preview
  - y que esas imágenes se reflejen correctamente en la tienda online

OBJETIVO
Crear una solución segura, clara y funcional para administrar imágenes desde el panel admin, sin hacer un refactor masivo.

ALCANCE

A. BANNERS
Quiero que en el módulo de banners se pueda:
- subir imagen de banner
- cambiar imagen existente
- eliminar imagen
- ver preview
- mantener o editar:
  - título
  - subtítulo
  - CTA / texto del botón
  - link
  - orden
  - activo/inactivo

Si es viable y de bajo riesgo, dejar preparado soporte para:
- imagen desktop
- imagen mobile
Si no, al menos dejar una sola imagen bien gestionada.

B. PRODUCTOS / CATÁLOGO
Quiero que en el catálogo de productos o módulo de inventario se pueda:
- subir foto principal del producto
- cambiar foto
- eliminar foto
- ver preview
- guardar correctamente la referencia de la imagen
- que la tienda pública use esa imagen real del producto

MÍNIMO VIABLE:
- una imagen principal por producto

C. STORAGE
Prefiero usar Supabase Storage si ya está conectado el proyecto.
Si ya existe integración con Supabase, implementa buckets/rutas/uso seguros y coherentes.
Si hay helpers existentes, reutilízalos.

SUGERENCIA DE ESTRUCTURA
- bucket para banners
- bucket para productos
- guardar en BD algo como:
  - image_url
  - image_path
  - banner_image_url
  - banner_mobile_url (opcional si decides soportarlo)
Usa los nombres reales de tablas/columnas si ya existen; si no existen, documenta y aplica el cambio mínimo necesario y seguro.

UX QUE QUIERO
- botones claros:
  - Subir imagen
  - Cambiar imagen
  - Eliminar imagen
- preview antes y después de guardar
- mensajes de éxito/error claros
- comportamiento usable en móvil/tablet también
- no depender de emojis como representación principal

ARCHIVOS PROBABLEMENTE IMPORTANTES
- src/InventarioModule.jsx
- src/Tienda.jsx
- src/Admin.jsx
- src/Banners* o módulo equivalente
- src/supabase.js
- cualquier helper de storage/upload
- SQL o migraciones solo si son estrictamente necesarias y seguras

REGLAS
- No hagas refactor masivo.
- No rompas el flujo actual.
- Reutiliza Supabase si ya está montado.
- Si se necesita cambio mínimo en tabla/Storage, hazlo de forma clara y documentada.
- Si algo no puede quedar 100% cerrado sin aplicar SQL/Storage externo, deja el código listo y documenta el paso pendiente.

VALIDACIÓN FINAL
Después de aplicar cambios:
1. corre build
2. revisa imports rotos
3. confirma que se puede:
   - subir banner
   - cambiar banner
   - subir foto de producto
   - cambiar foto de producto
4. resume qué quedó funcionando
5. documenta cualquier paso externo pendiente en Supabase si aplica

ENTREGABLE FINAL
Quiero que me entregues:
1. Resumen ejecutivo corto
2. Archivos modificados
3. Qué cambiaste en cada archivo
4. Cómo quedó el flujo para banners
5. Cómo quedó el flujo para productos
6. Si hubo pasos pendientes en Supabase Storage / SQL
7. Resultado de build

NO te quedes en recomendaciones. Analiza el repo e implementa la funcionalidad real de carga y reemplazo de imágenes para banners y productos.
