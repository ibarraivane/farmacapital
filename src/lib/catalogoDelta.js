/**
 * Refresco de catálogo por cambios (Tienda e Inventario).
 *
 * Idea: en vez de volver a bajar TODO el catálogo cada vez que Realtime avisa
 * de un cambio (cada venta toca lotes → productos), se piden solo las filas con
 * `updated_at` posterior a la última marca y se mezclan con lo que ya hay.
 * Cada cierto tiempo se hace un refresco completo de seguridad (bajas, filas
 * que RLS ya no deja ver, relojes raros).
 *
 * La marca sale del servidor (máximo `updated_at` recibido), no del reloj del
 * navegador, para que una PC con la hora mal no se salte cambios.
 */

/** Margen hacia atrás: cubre transacciones que confirman tarde (now() = inicio de la transacción). */
export const CATALOGO_DELTA_MARGEN_MS = 30 * 1000;

/**
 * ISO de la marca para la siguiente consulta delta: el `updated_at` más reciente
 * de `rows` menos el margen. Si no hay fechas válidas devuelve `anterior`.
 */
export function marcaDeltaDesde(rows, anterior = null, margenMs = CATALOGO_DELTA_MARGEN_MS) {
  let max = null;
  for (const r of rows || []) {
    const t = r?.updated_at ? Date.parse(r.updated_at) : NaN;
    if (Number.isFinite(t) && (max == null || t > max)) max = t;
  }
  if (max == null) return anterior;
  const nueva = new Date(max - margenMs).toISOString();
  // Nunca retroceder respecto a la marca anterior (evita re-bajar lo mismo).
  if (anterior && Date.parse(anterior) > Date.parse(nueva)) return anterior;
  return nueva;
}

/**
 * Mezcla `delta` sobre `prev` por id: reemplaza, agrega nuevos al final y
 * (salvo `conservarInactivos`) quita los que llegaron con `activo === false`.
 * Sin cambios devuelve el mismo arreglo.
 */
export function mezclarCatalogoDelta(prev, delta, { conservarInactivos = false } = {}) {
  if (!Array.isArray(delta) || !delta.length) return prev;
  const base = Array.isArray(prev) ? prev : [];
  const visible = (d) => conservarInactivos || d?.activo !== false;
  const porId = new Map();
  for (const d of delta) porId.set(String(d.id), d);
  const vistos = new Set();
  const out = [];
  for (const p of base) {
    const k = String(p.id);
    const d = porId.get(k);
    if (d) {
      vistos.add(k);
      if (visible(d)) out.push(d);
    } else {
      out.push(p);
    }
  }
  for (const d of delta) {
    const k = String(d.id);
    if (!vistos.has(k) && visible(d)) {
      vistos.add(k);
      out.push(d);
    }
  }
  return out;
}

/** ¿Toca refresco completo? (primera carga, sin marca o pasó `cadaMs`). */
export function requiereRefrescoCompleto({ desde, fullAt }, cadaMs, ahora = Date.now()) {
  return !desde || !fullAt || ahora - fullAt > cadaMs;
}
