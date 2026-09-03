/**
 * Precios por tamaño (botellas ml/g): el PVP tiene que subir (o igualar) con el tamaño.
 * No tiene sentido vender 480 ml más barato que 100 ml de la misma línea.
 */

const TOL_VOL = 0.05;

const LINEAS_POR_NOMBRE = [
  [/agua\s+oxigenada|peroxido\s+de\s+hidrogeno/, "agua oxigenada"],
  [/alcohol\s+(etilico|antiseptico|desnaturalizado)|alcohol\s+rojo|alcohol\s+96/, "alcohol"],
  [/agua\s+micelar/, "agua micelar"],
  [/gel\s+antibacterial|alcohol\s+gel/, "gel antibacterial"],
];

function normTxt(s) {
  return String(s || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/\p{M}/gu, "")
    .replace(/\s+/g, " ")
    .trim();
}

/** ml o g desde presentación + nombre. Litros → ml. */
export function extraerTamanoConsumo(texto) {
  const t = normTxt(texto).replace(/,/g, ".");
  const ml = t.match(/(\d+(?:\.\d+)?)\s*m(?:l|ls)\b/);
  if (ml) {
    const n = Number(ml[1]);
    return Number.isFinite(n) && n > 0 ? { cantidad: n, unidad: "ml" } : null;
  }
  const lit = t.match(/(\d+(?:\.\d+)?)\s*(?:litros?|l)\b/);
  if (lit) {
    const n = Number(lit[1]) * 1000;
    return Number.isFinite(n) && n > 0 ? { cantidad: n, unidad: "ml" } : null;
  }
  const g = t.match(/(\d+(?:\.\d+)?)\s*(?:gramos|gr|g)\b/);
  if (g) {
    const n = Number(g[1]);
    if (!Number.isFinite(n) || n <= 0 || n >= 20000) return null;
    if (/\d\s*m(?:g|cg)\b/.test(t) && !/\d\s*(?:kg|g|gr|gramos)\b/.test(t)) return null;
    return { cantidad: n, unidad: "g" };
  }
  return null;
}

export function textoProductoTamano(p) {
  return [p?.presentacion, p?.nombre, p?.nombre_fuente, p?.forma_farmaceutica]
    .filter(Boolean)
    .join(" ");
}

export function tamanosComparables(a, b, tolerancia = TOL_VOL) {
  if (!a || !b || a.unidad !== b.unidad) return false;
  if (!(a.cantidad > 0) || !(b.cantidad > 0)) return false;
  const mayor = Math.max(a.cantidad, b.cantidad);
  return Math.abs(a.cantidad - b.cantidad) / mayor <= tolerancia;
}

function lineaDesdeNombre(p) {
  const blob = normTxt(`${p?.forma_farmaceutica || ""} ${p?.nombre || ""}`);
  for (const [re, linea] of LINEAS_POR_NOMBRE) {
    if (re.test(blob)) return linea;
  }
  return null;
}

/**
 * Familia comparable por tamaño.
 * Agua oxigenada / alcohol: agrupa por línea aunque la marca OCR diga Degasa vs Dermocleen.
 * Resto: forma + marca.
 */
export function claveFamiliaTamano(p) {
  const tam = extraerTamanoConsumo(textoProductoTamano(p));
  if (!tam) return null;

  const linea = lineaDesdeNombre(p);
  if (linea) return `${linea}|${tam.unidad}`;

  const forma = normTxt(p?.forma_farmaceutica);
  const marca = normTxt(p?.marca);
  if (!forma || !marca) return null;
  return `${forma}|${marca}|${tam.unidad}`;
}

function agruparPorFamilia(productos, precioDe) {
  const grupos = new Map();
  for (const p of productos || []) {
    const clave = claveFamiliaTamano(p);
    const tam = extraerTamanoConsumo(textoProductoTamano(p));
    const precio = precioDe(p);
    if (!clave || !tam) continue;
    if (!grupos.has(clave)) grupos.set(clave, []);
    grupos.get(clave).push({ producto: p, tam, precio });
  }
  return grupos;
}

/**
 * Inversiones: presentación más grande con PVP menor que una más chica.
 * @returns {{ chico: object, grande: object, precioChico: number, precioGrande: number }[]}
 */
export function detectarInversionesPrecioPorTamano(productos, precioDe = (p) => parseFloat(p?.precio)) {
  const out = [];
  for (const filas of agruparPorFamilia(productos, precioDe).values()) {
    if (filas.length < 2) continue;
    const orden = filas
      .filter((f) => Number.isFinite(f.precio) && f.precio > 0)
      .sort((a, b) => a.tam.cantidad - b.tam.cantidad);
    for (let i = 0; i < orden.length; i++) {
      for (let j = i + 1; j < orden.length; j++) {
        if (orden[j].tam.cantidad <= orden[i].tam.cantidad * (1 + TOL_VOL)) continue;
        if (orden[j].precio + 0.01 < orden[i].precio) {
          out.push({
            chico: orden[i].producto,
            grande: orden[j].producto,
            precioChico: orden[i].precio,
            precioGrande: orden[j].precio,
          });
        }
      }
    }
  }
  return out;
}

/**
 * Sube el sugerido de botellas grandes para que no queden bajo el de una más chica.
 * No baja precios.
 */
export function coherenciaSugeridosPorTamano(filas) {
  const items = (filas || []).map((f) => ({ ...f }));
  const grupos = new Map();
  for (let i = 0; i < items.length; i++) {
    const p = items[i].producto;
    const clave = claveFamiliaTamano(p);
    const tam = extraerTamanoConsumo(textoProductoTamano(p));
    if (!clave || !tam) continue;
    if (!grupos.has(clave)) grupos.set(clave, []);
    grupos.get(clave).push({ idx: i, tam });
  }

  for (const miembros of grupos.values()) {
    if (miembros.length < 2) continue;
    miembros.sort((a, b) => a.tam.cantidad - b.tam.cantidad);
    let piso = 0;
    for (const m of miembros) {
      const s = items[m.idx].sugerido;
      const n = Number.isFinite(s) && s > 0 ? s : 0;
      const adj = Math.max(n, piso);
      if (adj > 0 && (s == null || adj > s)) {
        items[m.idx] = {
          ...items[m.idx],
          sugerido: adj,
          coherenciaTamano: true,
        };
      }
      if (adj > piso) piso = adj;
    }
  }
  return items;
}

/**
 * Corrige PVP actuales: en cada familia, el precio no puede bajar al subir de tamaño.
 * Respeta un piso por producto (costo×margen) si se pasa `pisoDe`.
 * @returns {{ producto: object, de: number, a: number, motivo: string }[]}
 */
export function proponerPreciosVentaPorTamano(productos, opts = {}) {
  const precioDe = opts.precioDe || ((p) => parseFloat(p?.precio));
  const pisoDe = opts.pisoDe || (() => 0);
  const redondear = opts.redondear || ((n) => Math.ceil(n));

  const out = [];
  for (const filas of agruparPorFamilia(productos, precioDe).values()) {
    if (filas.length < 2) continue;
    const orden = filas.slice().sort((a, b) => a.tam.cantidad - b.tam.cantidad);
    let pisoFamilia = 0;
    for (const f of orden) {
      const actual = Number.isFinite(f.precio) && f.precio > 0 ? f.precio : 0;
      const pisoProd = Number(pisoDe(f.producto)) || 0;
      const objetivo = redondear(Math.max(actual, pisoFamilia, pisoProd));
      if (objetivo > 0 && objetivo > actual + 0.01) {
        out.push({
          producto: f.producto,
          de: actual,
          a: objetivo,
          motivo: `Tamaño ${f.tam.cantidad} ${f.tam.unidad}: no puede venderse bajo una presentación menor`,
        });
      }
      const vigente = Math.max(actual, objetivo, pisoFamilia);
      if (vigente > pisoFamilia) pisoFamilia = vigente;
    }
  }
  return out;
}
