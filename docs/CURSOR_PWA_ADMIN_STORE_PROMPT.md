Quiero corregir el flujo de instalación PWA de FARMAX porque actualmente la app instalada abre la Tienda (/) y no el panel Admin (/admin), que es lo que necesito en este momento.

OBJETIVO
Implementa una solución clara y segura para que FARMAX pueda ofrecer instalación de:
1. Tienda
2. Admin

PROBLEMA ACTUAL
- En la sección “Instalar app”, al seguir las instrucciones desde el entorno administrativo, la app que se instala termina abriendo la Tienda (/).
- Esto indica que el manifest/start_url actual está apuntando a la raíz o que no existe una separación clara entre la instalación de Tienda y Admin.

QUIERO
1. Revisar cómo está configurado hoy el manifest / start_url / instalación PWA.
2. Implementar una solución para distinguir claramente:
   - Farmax Tienda
   - Farmax Admin
3. En la UI de “Instalar app” mostrar ambas opciones de forma clara:
   - Instalar Tienda
   - Instalar Admin
4. Explicar en esa pantalla, de forma breve y clara, cómo instalar cada una.
5. Mantener compatibilidad funcional y no romper la PWA existente.

SOLUCIÓN PREFERIDA
- Crear dos manifests lógicos si es viable:
  - uno para tienda
  - uno para admin
- Cada uno con:
  - name
  - short_name
  - start_url
  - scope
  - id
  correctos y diferenciados.
- Si el proyecto actual permite cambiar dinámicamente el manifest según la ruta, impleméntalo de forma segura.
- Si detectas que en iPhone/Safari la solución ideal depende de abrir la ruta correcta antes de “Agregar a pantalla de inicio”, deja eso claramente explicado en la pantalla de instalación.

QUÉ QUIERO EN LA UX
En la pantalla Instalar app quiero algo como:
- Instalar Tienda
- Instalar Admin

Y que quede claro:
- Tienda abre /
- Admin abre /admin

IMPORTANTE
- No hagas un refactor masivo.
- No toques lógica de negocio.
- No rompas la instalación actual.
- Si hay limitaciones del navegador para instalar dos PWAs desde el mismo dominio, documéntalas claramente.
- Si hace falta elegir una solución pragmática y segura, hazlo.

ARCHIVOS PROBABLEMENTE IMPORTANTES
- src/InstalarPWA.jsx
- src/pwa.jsx
- public/manifest.json
- public/*
- src/index.js
- cualquier helper relacionado con instalación o service worker

QUÉ QUIERO QUE HAGAS
1. Analiza cómo está funcionando hoy la PWA.
2. Identifica por qué se instala la Tienda en vez del Admin.
3. Aplica cambios seguros para soportar ambas instalaciones o, si el navegador no lo permite de forma automática, una UX clara y correcta para ambas.
4. Si hace falta crear manifests separados, hazlo.
5. Si hace falta cambiar la forma en que se enlaza el manifest o se presenta la instalación, hazlo.
6. Ajusta la pantalla “Instalar app” para que sea clara y profesional.
7. Corre build al final.
8. Déjame un resumen claro de:
   - causa del problema
   - archivos modificados
   - solución aplicada
   - limitaciones de Safari/iPhone si existen
   - resultado de build

VALIDACIÓN FINAL
Después de aplicar cambios:
- corre npm run build
- confirma que no se rompió la tienda
- confirma que admin y tienda tienen rutas claras para instalación
- explica exactamente cómo instalar:
  - Tienda
  - Admin
en Android/Chrome y en iPhone/Safari si difiere

ENTREGABLE FINAL
Quiero que me entregues:
1. Resumen ejecutivo corto
2. Qué estaba causando que se instalara la Tienda y no Admin
3. Qué cambiaste
4. Archivos modificados
5. Cómo queda el flujo final de instalación para Tienda y Admin
6. Limitaciones o notas importantes por navegador
7. Resultado de build

NO te quedes en recomendaciones. Analiza el repo e implementa la solución segura y pragmática.
