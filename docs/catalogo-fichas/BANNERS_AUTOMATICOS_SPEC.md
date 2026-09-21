# Banners automáticos y animación de entrada · especificación para Cursor

**Fecha:** 21 de septiembre de 2026 · **Referencia visual:** `farmacapital-prototipo-v3.html`, pantallas "Inicio" y "7 · Crear banner (admin)", y el botón "Ver animación de entrada".
**Regla:** nada a `main` sin PR aprobado por Iván.

## 1. Problema actual
- La tabla `banners` (`sql/banners.sql`) guarda título, subtítulo, emoji, color y `slot` (hero/strip/tile), más imágenes y video subidos a mano.
- Cada banner se diseña fuera (imagen de escritorio + imagen de celular), se sube y se mantiene a mano. Si cambia el precio o se agota el producto, el banner queda desactualizado.

## 2. Propuesta: banners por plantilla
El administrador **no diseña imágenes**. Elige una plantilla, llena datos y el banner se dibuja con componentes de la tienda, en los tamaños de celular, tableta y escritorio.

| Plantilla | Datos | De dónde sale lo demás |
|---|---|---|
| `producto` | producto, % de descuento, vigencia | Nombre, presentación, foto principal y precio "antes/ahora" se leen del catálogo y de `promociones` / `promocion_productos` (ya existen). |
| `servicio` | título, texto, botón, destino (cotizar, consultorio) | Icono y colores fijos de marca. |
| `categoria` | título, texto, categoría, hasta 3 productos | Fotos de los productos elegidos. |
| `imagen_propia` | imagen de escritorio y de celular | Solo para campañas especiales; se conserva el flujo actual. |

**Reglas automáticas:**
- Ocultar el banner si el producto se agota.
- Apagarlo al terminar la vigencia.
- **No permitir promociones de medicamentos con receta** (bloqueado por defecto, en línea con la política de dispensación).

### Modelo (propuesto, no ejecutado)
```sql
alter table public.banners
  add column if not exists plantilla text not null default 'imagen_propia'
    check (plantilla in ('producto','servicio','categoria','imagen_propia')),
  add column if not exists producto_ids integer[] default '{}',
  add column if not exists descuento_pct numeric,
  add column if not exists destino text,              -- 'cotizar' | 'consultorio' | 'categoria:<nombre>' | url interna
  add column if not exists vigente_desde date,
  add column if not exists vigente_hasta date,
  add column if not exists ocultar_sin_stock boolean not null default true;
```
- El precio "ahora" **no se guarda en el banner**: se calcula con la misma función de precio que usa la ficha (`precio_oferta_publico` / `precioOnlineMp`), para que banner, ficha y carrito coincidan.
- La emoji deja de usarse en la nueva tienda.

### UI
- Inicio: una fila "Esta semana" con 1–5 banners, desplazable a mano y sin avance automático (en escritorio, rejilla de 3). **Sin carrusel automático.**
- Admin: pantalla "Nuevo banner" con plantillas, formulario, vista previa en vivo en tres tamaños y las reglas anteriores.

## 3. Animación de entrada
- **Qué hace:** la cruz del logo se arma (barra vertical, barra horizontal y trazo verde) y aparece el nombre "FarmaCapital". Después la cortina sube y la página entra en cascada. Duración total: unos 2 segundos, con botón "Saltar".
- **Cuándo:** solo la **primera visita de la sesión** (usar `sessionStorage` con try/catch). Nunca en cada navegación interna.
- **Rendimiento:** la página carga debajo mientras corre la animación; no puede retrasar el contenido principal. Usar solo CSS, sin librerías.
- **Accesibilidad:** con `prefers-reduced-motion` no se muestra. La cortina es decorativa (`role="presentation"`) y "Saltar" es un botón real.
- **Recurso:** construir la cruz en SVG con las formas de `public/favicon.svg` (dos barras redondeadas y el arco verde) y usar el logotipo oficial para el nombre.

## 4. Criterios de aceptación
- [ ] Un banner de `producto` muestra precio y foto vigentes sin volver a subir nada; se oculta solo al agotarse o vencer.
- [ ] No se puede crear un banner de `producto` con un medicamento que requiere receta.
- [ ] Los banners anteriores (`imagen_propia`) siguen funcionando.
- [ ] La animación sale una vez por sesión, se puede saltar, respeta el movimiento reducido y no empeora el tiempo de carga de la página en celular.
- [ ] PR con vista previa de Vercel; nada directo a `main`.
