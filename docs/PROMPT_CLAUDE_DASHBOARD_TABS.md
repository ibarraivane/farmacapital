# Prompt para Claude — FarmaCapital · pestañas del Dashboard admin

Copia este archivo entero a Claude. Es el handoff de un trabajo ya hecho en código (PR abierto). No reinventes el sistema de iconos de la tienda. No mezcles esto con el job de backup que falla en `main`.

---

## Quién / producto

- App: **FarmaCapital** — farmacia + consultorio + tienda online.
- Repo: `ibarraivane/farmacapital`
- Admin: `/admin` (CRA + Supabase). Tienda: `www.farmacapital.mx`.
- Dueño / operador: Ivan. Habla en español. Quiere UI **muy profesional**, no “chafa”, no emoji.
- Base branch: `main`.
- PR de este trabajo: **https://github.com/ibarraivane/farmacapital/pull/120**
- Branch: `cursor/dashboard-tabs-lucide-50b5`

---

## Qué pidió Ivan (en orden)

1. Habían hablado de cambiar **todos los iconos del sistema**. El pase Lucide de la **tienda** (PR #78, mergeado) **no tocó el admin**.
2. En Dashboard y reportes, **Flujo de caja** se veía con una **gota de agua** (emoji `💧`) y **solo en la segunda fila**. Se veía mal.
3. Pidió algo **muy profesional** y una **propuesta mejor**.
4. Le gustó el primer pase Lucide (sin emoji, una fila), pero lo encontró **demasiado simple** (solo subrayado).
5. Pidió **ver ejemplos en línea** (SaaS serio) y proponer con base en eso.
6. Luego: “dame todo esto de alguna manera que Claude lo pueda leer” → este documento.

---

## Contexto que ya está en `main` (no rehacer)

- Sidebar admin **ya usa Lucide** (`src/constants.js`: `LayoutDashboard`, `Wallet` para Corte de Caja, etc.).
- InventarioHub ya tiene tabs Lucide con **subrayado** (`src/InventarioHub.jsx`).
- Tienda: wells `TiendaIconWell` / `IconLabel` en `src/Tienda.jsx` (stroke ~1.75).
- Docs viejos (`docs/CURSOR_FINAL_BATCH_PROMPT.md` Bloque D/E) ya pedían:
  - Proyecto Farma como **contexto**, no como tab gemelo de Operación.
  - Tabs en una fila; scroll horizontal si hace falta; sin chips huérfanos.
  - Manijas de reordenar ocultas en móvil.
  - Iconos consistentes, labels cortos, active state claro.

---

## Cómo se veía ANTES (producción / main)

En `src/DashboardModule.jsx` las labels eran **strings con emoji**:

```
proyecto:       💼 Proyecto Farma · inversión
operacion:      📊 Operación — farmacia
resumen:        📈 Resumen por período
transacciones:  🔄 Transacciones
margen:         💹 Margen por categoría
flujo:          💧 Flujo de caja
```

Layout: `flexWrap: wrap` en desktop + manijas `⋮⋮` + labels largos → **Flujo caía solo a la segunda fila**, con borde azul y la gota. Eso es lo que Ivan fotografió.

---

## Referencias profesionales que se usaron

| Fuente | URL | Qué aporta | Qué NO copiar |
|---|---|---|---|
| **shadcn Tabs** | https://ui.shadcn.com/docs/components/tabs | Riel muted + pastilla blanca activa. El look de Stripe / Linear / Clerk. | No hace falta instalar shadcn. |
| **Vercel Geist Tabs** | https://vercel.com/geist/tabs | Icono + label, 1–2 palabras, max 5–7 tabs. Variante `secondary`. | El **subrayado solo** (Ivan lo rechazó como “muy simple”). |
| **Segmented control iOS** | https://www.eleken.co/blog-posts/segmented-control-ui | Track gris, thumb que se mueve. | Pastilla verde chillona; no es la marca. |
| **Shopify Polaris Tabs** | https://polaris.shopify.com/components/navigation/tabs | Nunca wrap a 2 filas. Labels de 1 palabra. Proyecto ≠ filtro. | — |

**Decisión de diseño (ya implementada):** shadcn + iOS segmented, **no** Geist underline.

- Track: `#eef2f7`, borde `#e2e8f0`, radius 12, padding 4.
- Activa: pastilla **blanca**, sombra `0 1px 2px rgba(15,23,42,.08)`.
- Icono en **well** 28×28, radius 8. Activo: `BRAND.primary` (`#1E3ABA`) al 16%. Inactivo: `#e8eef6`.
- **Proyecto Farma** FUERA del riel: chip blanco con borde (contexto CAPEX).
- Una sola fila, `overflow-x: auto`, sin wrap.
- Manijas `⋮⋮` solo al hover, ocultas bajo 900px.

Ivan dijo que si lo quiere más “banco” se puede subir a pastilla azul llena (estilo iOS). Si lo quiere más quieto, se baja el well. **No cambies eso sin que él lo pida.**

---

## Iconos Lucide (definitivos)

| Tab | Componente Lucide | Label desktop | Label móvil |
|---|---|---|---|
| Proyecto Farma | `Building2` | Proyecto Farma | igual |
| Operación | `Activity` | Operación | igual |
| Resumen | `CalendarRange` | Resumen | igual |
| Transacciones | `ArrowLeftRight` | Transacciones | igual |
| Margen | `PieChart` | Margen | igual |
| **Flujo de caja** | **`Banknote`** | Flujo de caja | Flujo |

**Prohibido:** `Droplet`, emoji `💧`, `Wallet` en esta pestaña.

Por qué no Wallet: a 15px se leía como gota (el sidebar SÍ usa `Wallet` para Corte de Caja; no lo toques). `Banknote` = rectángulo + círculo (marca de moneda).

Subnav dentro de Flujo (`src/FlujoCajaTab.jsx`):

| Sub | Icono | Estado |
|---|---|---|
| Flujo | `Banknote` | activo |
| Resultados · pronto | `BarChart3` | **disabled** (falta consulta 4 / P&L) |
| Gastos | `Receipt` | ok |

---

## Archivos tocados (PR #120)

```
src/DashboardModule.jsx          — DASHBOARD_TAB_META, DashboardNavTab, DashboardTabsRail
src/components/SegmentedNav.jsx  — NUEVO: IconWell + SegmentedNav
src/FlujoCajaTab.jsx             — SubNav usa SegmentedNav
src/index.css                    — .fc-dash-seg, .fc-dash-seg-tab, hover manijas
src/index.js                     — solo DEV: ?preview=dash-tabs
src/DashboardTabsPreview.jsx     — preview local (no va a producción; NODE_ENV development)
src/DashboardNavTab.test.jsx     — test: Banknote, no 💧, labels cortos
```

Preview local (dev only): `http://localhost:3000/?preview=dash-tabs`

Test:

```
CI=true npx react-scripts test --watchAll=false --testPathPattern=DashboardNavTab.test
```

Commits en la branch:

1. `feat(dashboard): pestañas Lucide en una sola fila`
2. `test(dashboard): Wallet en Flujo de caja y preview local` (histórico; el icono final ya no es Wallet)
3. `fix(dashboard): Flujo de caja usa billete, no cartera`
4. `feat(dashboard): riel tipo Vercel/shadcn en las pestañas`

---

## Qué NO está en este PR (no lo metas sin pedirlo)

- KPIs del dashboard (números partidos, metas, emoji en alertas 📦⏰💰).
- Sidebar / POS / Recibir / pistola / caducidad.
- Iconos de Config consultorio (`💧 Finanzas` todavía existe en `src/modules/clinical/ConfigConsultorioModule.jsx`).
- Merge a `main` / deploy. Ivan no ha dicho “mergea” en este hilo.
- El job **FARMAX DB Backup** (ver abajo). Es ruido de CI, no de este PR.

---

## CI rojo en `main` que NO es este trabajo

Workflow: **FARMAX DB Backup** (schedule diario). Falla desde ~29 ago 2026.

- `pg_dump` **sí funciona** (~2.4 MB).
- Falla al `git clone` del repo de backups:
  `Invalid username or token. Password authentication is not supported for Git operations.`
- Hay que renovar el PAT / secret del workflow en GitHub → Settings → Secrets.
- **No es un bug de las pestañas ni de la tienda.**

---

## Reglas de producto (FarmaCapital)

- No inventar caducidades. `0000` es inválido.
- Recibir / pistola / tablet: ver `.cursor/rules/recibir-tablet-auditoria.mdc` si tocas eso.
- No force push a main.
- No commitear `.env` ni dumps.
- Hablar en español con Ivan. Propuestas concretas, no ensayos.

---

## Si Ivan te pide continuar

Pregúntale qué quiere, no asumas:

A. **Mergear PR #120** a main (y deploy si lo pide).
B. Subir el contraste: pastilla activa **azul llena** (más iOS / “banco”).
C. Bajar el contraste: quitar wells, dejar solo el riel.
D. Extender el mismo `SegmentedNav` a Inventario / Consultorio / Metas (Bloque E).
E. Arreglar el token del backup (solo secrets; no hay fix de código).

Si tocas las tabs otra vez: una fila, Lucide, Flujo = `Banknote`, Proyecto fuera del riel, no emoji.

---

## Fin del prompt

Lee el PR #120 y los archivos de arriba. Si Ivan pega una captura, compárala con este spec. No “mejorees” el diseño por tu cuenta: él ya eligió el riel shadcn y el billete.
