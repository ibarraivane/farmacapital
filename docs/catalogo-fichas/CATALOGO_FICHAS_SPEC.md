# Fichas de producto enriquecidas · especificación para Cursor

**Proyecto:** Farmacapital (`ibarraivane/farmacapital`)
**Fecha:** 21 de septiembre de 2026 · **Autor:** Claude, con Iván
**Estado:** especificación aprobada para planeación. **No integrar a `main` sin PR aprobado por Iván.**

Archivos que acompañan a este documento (copiarlos a `docs/catalogo-fichas/`):

| Archivo | Qué es |
|---|---|
| `CATALOGO_FICHAS_SPEC.md` | Esta especificación. |
| `monografias_semilla.json` | 10 monografías de ejemplo por sustancia activa. Sirven como formato de referencia y set de control de calidad. Estado `borrador_ia`. |
| `cobertura_catalogo_20260816.csv` | Clasificación inicial de los 1,094 productos activos del snapshot `sql/generated/inventario_activos_20260816.json`: tipo de ficha y clave de monografía. Hay que regenerarlo desde la base viva (sección 9). |
| `prompt_investigacion.md` | Prompt y formato de salida para el agente que investiga en la web. |

---

## 1. Objetivo

1. Que **todos los productos** tengan una ficha detallada como la del prototipo v2 (`farmacapital-prototipo-v2.html`, pantallas "Ficha" y "Por encargo").
2. Que **cada producto nuevo** reciba automáticamente un **borrador** de descripción e imágenes investigado en la web, que una persona revisa y aprueba antes de publicarse.

## 2. Reglas no negociables

1. **Nada se publica sin revisión humana.** Todo texto generado o encontrado entra como `borrador`. Solo un usuario con rol autorizado (responsable sanitario o quien Iván designe) lo pasa a `publicado`.
2. **Medicamentos:** el texto debe coincidir con el **instructivo autorizado** (o la IPP) del producto concreto. Sin beneficios, comparaciones ni lenguaje promocional. En medicamentos con receta **no se muestran dosis específicas**; se escribe "La dosis y la duración las indica tu médico".
3. **Suplementos y dermocosmética:** solo lo que declara el fabricante en el empaque o en su ficha oficial. Nunca atribuir efectos terapéuticos a un suplemento.
4. **Cada dato guarda su fuente** (URL, tipo de fuente y fecha de consulta). Sin fuente, no se publica.
5. **Imágenes:** se descargan y se guardan en Supabase Storage; nunca se enlazan a sitios de terceros. Se registran su origen y su licencia. Se prefieren, en este orden: foto propia, fabricante o distribuidor con permiso, y fuentes abiertas con atribución (Open Food/Beauty/Products Facts es CC BY-SA y exige atribución). **Las fotos de otras farmacias o tiendas no se usan en producción sin permiso.**
6. **No se toca POS, inventario, lotes, precios ni pagos.** Esto solo agrega contenido.
7. **Datos sensibles:** el pipeline nunca envía a servicios externos costos, proveedores, datos de clientes ni recetas. Solo nombre, marca, presentación, sustancia y código de barras.

## 3. Modelo de datos (SQL propuesto, no ejecutado)

Idea central: **la información clínica es de la sustancia, no de la marca.** Un omeprazol de 20 mg en cápsulas tiene la misma sección clínica en todas sus marcas. Por eso hay dos niveles:

- `monografias`: una por **sustancia (o combinación) + vía**. Reutilizable. Con 298 claves distintas se cubren los ~470 medicamentos del snapshot.
- `producto_fichas`: una por producto. Guarda lo propio de ese producto (resumen, etiquetas rápidas, instructivo, datos del fabricante) y apunta a su monografía.

```sql
create table public.monografias (
  id              bigserial primary key,
  clave           text not null,            -- 'amoxicilina + acido clavulanico' (normalizada: minúsculas, sin acentos, ' + ' entre sustancias)
  via             text not null,            -- 'oral' | 'topica' | 'oftalmica' | 'otica' | 'nasal' | 'vaginal' | 'inyectable' | 'inhalada'
  contenido       jsonb not null,           -- ver esquema en §4
  fuentes         jsonb not null default '[]',
  estado          text not null default 'borrador'
                  check (estado in ('borrador','en_revision','publicado','rechazado')),
  revisado_por    text,
  revisado_en     timestamptz,
  version         int not null default 1,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (clave, via)
);

create table public.producto_fichas (
  producto_id     integer primary key references public.productos(id) on delete cascade,
  tipo_ficha      text not null check (tipo_ficha in ('medicamento','dermocosmetico','suplemento','cuidado_personal','material','equipo_medico')),
  monografia_id   bigint references public.monografias(id),
  contenido       jsonb not null default '{}',  -- resumen, chips, datos de fabricante, etc. (§4)
  instructivo_url text,                          -- PDF o foto del instructivo en Storage
  registro_sanitario text,
  fuentes         jsonb not null default '[]',
  estado          text not null default 'borrador'
                  check (estado in ('borrador','en_revision','publicado','rechazado')),
  revisado_por    text,
  revisado_en     timestamptz,
  updated_at      timestamptz not null default now()
);

create table public.enriquecimiento_jobs (
  id              bigserial primary key,
  producto_id     integer not null references public.productos(id) on delete cascade,
  tipo            text not null check (tipo in ('ficha','imagenes','ambos')),
  estado          text not null default 'pendiente'
                  check (estado in ('pendiente','procesando','listo_para_revision','error','descartado')),
  intentos        int not null default 0,
  error           text,
  resultado       jsonb,                         -- borrador completo + candidatos de imagen
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- producto_imagenes ya existe (sql/patch_producto_imagenes_20260826.sql).
-- Ampliar el check de `origen` y agregar trazabilidad:
alter table public.producto_imagenes
  add column if not exists fuente_url text,
  add column if not exists licencia  text,
  add column if not exists aprobada  boolean not null default false;
-- origen: agregar 'fabricante','openfacts','ia_busqueda' al check existente.
```

**RLS:**
- El público (anon) solo lee filas con `estado = 'publicado'`, y solo mediante una vista o RPC que no exponga `fuentes` internas ni `revisado_por`.
- Escritura solo con service role o con el rol de administración.
- `enriquecimiento_jobs` no es visible para anon.

La columna actual `productos.descripcion` **se conserva** y sigue funcionando como texto corto de respaldo mientras no haya ficha publicada.

## 4. Esquema del contenido (JSON)

### 4.1 `monografias.contenido` (medicamentos)
Ver ejemplos completos en `monografias_semilla.json`.
```json
{
  "resumen": "1–2 frases: qué es y para qué se usa.",
  "para_que_sirve": "Indicaciones autorizadas, en lenguaje claro.",
  "como_se_usa": ["..."],
  "no_usar_si": ["..."],
  "consulta_si": ["..."],
  "interacciones": "...",
  "efectos": ["..."],
  "alarma": "Cuándo suspender y buscar atención.",
  "conservacion": ["..."],
  "requiere_receta_habitual": true
}
```
`requiere_receta_habitual` solo sirve para detectar inconsistencias. La fuente de verdad para vender sigue siendo `productos.requiere_receta` y la política de dispensación (`src/config/politicaMedicamentos.js`).

### 4.2 `producto_fichas.contenido`
```json
{
  "resumen": "Si falta, se usa el de la monografía.",
  "chips": ["1 cápsula al día", "Antes del desayuno", "Sin receta"],
  "fabricante": {
    "descripcion": "Solo dermo/suplementos: texto del fabricante.",
    "para_quien": { "tipo_piel": "...", "zona": "...", "textura": "..." },
    "modo_de_uso": ["..."],
    "ingredientes_destacados": ["..."],
    "inci_completo": "Lista tal como aparece en el empaque",
    "precauciones": ["..."],
    "tabla_nutrimental": { "porcion": "30 g", "porciones": 30, "proteina_g": 24, "alergenos": ["leche"] }
  },
  "precio_por_unidad": { "unidad": "cápsula", "cantidad": 30 }
}
```
Los campos se muestran **solo si tienen valor**, como ya exige el plan maestro.

### 4.3 `fuentes` (en ambas tablas)
```json
[{ "url": "https://...", "tipo": "instructivo|fabricante|cofepris|openfacts|otra", "titulo": "...", "consultado": "2026-09-21", "campos": ["para_que_sirve","efectos"] }]
```

## 5. Cómo se muestra en la tienda (mapeo al prototipo v2)

| Bloque del prototipo | Dato |
|---|---|
| Resumen bajo el título | `producto_fichas.contenido.resumen` → `monografias.contenido.resumen` → `productos.descripcion` |
| Etiquetas rápidas | `contenido.chips` |
| ¿Para qué sirve? · ¿Cómo se toma? · Antes de tomarlo · Interacciones · Efectos · Cómo guardarlo | `monografias.contenido` (solo si está `publicado`) |
| Ficha técnica | Columnas existentes de `productos` (`principio_activo`, `concentracion`, `forma_farmaceutica`, `presentacion`, `marca`/laboratorio, `requiere_receta`, `codigo_barras`) + `registro_sanitario` |
| Instructivo completo | `instructivo_url` |
| Dermo: Descripción · Para quién · Cómo se usa · Ingredientes · Precauciones | `producto_fichas.contenido.fabricante` |

Reglas de UI:
- Acordeón con `<details>/<summary>`. "¿Para qué sirve?" abierto por defecto.
- Texto legal fijo bajo el título de la sección: "Tomada del instructivo autorizado del producto."
- Si la ficha no está publicada, se muestra solo la ficha técnica y el botón "¿Dudas? Pregunta por WhatsApp". No se muestran borradores.
- **Una sola ficha adaptable** a celular, tableta y escritorio (en escritorio, dos columnas: imagen y compra a la izquierda, información a la derecha).

## 6. Flujo para productos nuevos

```
Alta o recepción de producto (InventarioModule / RecepcionModule)
        │  trigger o llamada: insertar enriquecimiento_jobs (tipo='ambos')
        ▼
/api/catalog/enrich  (Vercel serverless o cron cada 10 min; procesa N jobs)
  1. ¿Ya existe monografía publicada para (clave, via)? → se liga, no se investiga de nuevo.
  2. Imágenes por EAN, con los buscadores que ya existen en scripts/:
     buscar_fotos_openfacts.py, buscar_farmatodo_ean_*, cargar_imagenes_dibar/levic (distribuidores).
     Portarlos a un módulo JS (api/_lib/catalog/imageSources.js).
  3. Investigación web con un agente (Claude API con la herramienta de búsqueda web),
     usando prompt_investigacion.md. Salida JSON validada contra §4.
  4. Guardar en job.resultado → estado 'listo_para_revision'.
        ▼
Admin › "Fichas por revisar" (pantalla nueva)
  - Lado izquierdo: borrador editable. Lado derecho: fuentes con enlace.
  - Candidatos de imagen con miniatura, origen y licencia; elegir principal.
  - Botones: Aprobar y publicar · Guardar borrador · Rechazar.
        ▼
Al aprobar: upsert en producto_fichas / monografias (estado 'publicado'),
            subir imágenes aprobadas a Storage → producto_imagenes (aprobada = true).
```

Detalles:
- **Idempotencia:** un solo job abierto por producto; reintentos hasta 3 con espera exponencial.
- **Costos:** registrar tokens y búsquedas por job; tope diario configurable (`ENRICH_DAILY_MAX`).
- **Claves** solo en variables de entorno del servidor (`ANTHROPIC_API_KEY`); nunca en el cliente.
- **Dominios preferidos** para medicamentos: sitios de fabricantes y laboratorios, COFEPRIS y documentos de IPP. **Excluidos:** foros, blogs, redes sociales y páginas de otras farmacias como fuente de texto.
- La herramienta de búsqueda y su versión cambian con el tiempo. Revisar la documentación vigente de la API antes de implementar.

## 7. Carga inicial del catálogo actual

1. Exportar el catálogo vivo con `scripts/exportar_catalogo_supabase.py`.
2. Regenerar la cobertura con la misma lógica de `cobertura_catalogo_20260816.csv`: normalizar `principio_activo`, clasificar `tipo_ficha` y derivar `clave_monografia` + `via` desde `forma_farmaceutica`.
3. **Primero las monografías:** crear un job por cada `(clave, via)` distinta, ordenadas por número de productos (las 10 primeras ya tienen borrador en `monografias_semilla.json`). Con ~300 monografías se cubren casi todos los medicamentos.
4. **Después las fichas por producto:** dermocosmética, suplementos y cuidado personal (fabricante), y los datos propios de cada medicamento (chips, instructivo, registro).
5. Resolver los **374 productos sin sustancia activa** (`revisar_clasificacion`): muchos son higiene, material de curación o cosmética. Clasificarlos antes de investigar.
6. **Revisión por lotes de 25**, empezando por lo que más se vende (`scripts/exportar_ventas_sku.py`).

## 8. Criterios de aceptación

- [ ] Migraciones con RLS; anon no puede leer borradores ni `enriquecimiento_jobs`.
- [ ] La ficha muestra solo contenido `publicado`; sin él, degrada a ficha técnica sin errores.
- [ ] Alta de producto crea job; el job produce borrador con al menos una fuente por sección, o termina en `error` con mensaje claro.
- [ ] Pantalla de revisión: editar, ver fuentes, elegir imagen, aprobar y rechazar. Queda bitácora de quién aprobó y cuándo.
- [ ] Las imágenes aprobadas quedan en Storage con `origen`, `fuente_url` y `licencia`.
- [ ] Pruebas: validación del JSON (§4), normalización de claves (acentos, "/" y "+"), mapeo de UI con y sin ficha, y RLS.
- [ ] Cero cambios en POS, inventario, lotes, precios y pagos.
- [ ] Todo por PR con vista previa de Vercel; nada directo a `main`.

## 9. Riesgos y pendientes

- **Snapshot viejo:** la cobertura sale de datos del 16 de agosto. El catálogo actual es distinto.
- **Costos en el repositorio:** `sql/generated/inventario_activos_20260816.json` contiene `costo`. Conviene sacarlo del repositorio (y de su historial) o, al menos, no volver a versionar exportaciones con costos.
- **Imágenes de terceros:** parte del catálogo actual usa fotos de Rappi o Farmatodo. Hay que revisar su licencia antes de la nueva tienda, o reemplazarlas por fotos propias (ya existe `scripts/blanquear_fondos_productos.py`).
- **Responsable de revisión:** falta definir quién aprueba las fichas de medicamentos.
