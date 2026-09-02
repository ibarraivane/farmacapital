/**
 * Precios por tamaño (botellas ml/g): no vender más barato la presentación más grande.
 * El match de referencias ya exige tamaño comparable; esto corrige PVP/sugeridos
 * dentro de la misma familia (p. ej. agua oxigenada 100 / 230 / 480 ml).
 */

const TOL_VOL = 0.05;

/** ml o g desde presentación + nombre. Litros → ml. */
export function extraerTamanoConsumo(texto) {
  const t = String(texto || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/\p{M}/gu, "")
    .replace(/,/g, ".");
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
    // Evitar mg / mcg ya filtrados por el patrón; descartar pesos absurdo de OCR.
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

/** Clave de familia líquida/tópica comparable por tamaño (misma forma + marca). */
export function claveFamiliaTamano(p) {
  const forma = String(p?.forma_farmaceutica || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/\p{M}/gu, "")
    .trim();
  const marca = String(p?.marca || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/\p{M}/gu, "")
    .trim();
  const tam = extraerTamanoConsumo(textoProductoTamano(p));
  if (!tam || (!forma && !marca)) return null;

  // Agua oxigenada / alcohol: la forma basta aunque la marca OCR diga Degasa vs Dermocleen.
  if (forma && /agua oxigenada|alcohol|peroxido/.test(forma)) {
    return `${forma}|${tam.unidad}`;
  }
  if (!forma || !marca) return null;
  return `${forma}|${marca}|${tam.unidad}`;
}

/**
 * Inversiones: presentación más grande con PVP menor que una más chica de la familia.
 * @returns {{ chico: object, grande: object, precioChico: number, precioGrande: number }[]}
 */
export function detectarInversionesPrecioPorTamano(productos, precioDe = (p) => parseFloat(p?.precio)) {
  const grupos = new Map();
  for (const p of productos || []) {
    const clave = claveFamiliaTamano(p);
    const tam = extraerTamanoConsumo(textoProductoTamano(p));
    const precio = precioDe(p);
    if (!clave || !tam || !Number.isFinite(precio) || precio <= 0) continue;
    if (!grupos.has(clave)) grupos.set(clave, []);
    grupos.get(clave).push({ producto: p, tam, precio });
  }

  const out = [];
  for (const filas of grupos.values()) {
    if (filas.length < 2) continue;
    const orden = filas.slice().sort((a, b) => a.tam.cantidad - b.tam.cantidad);
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
 * No baja precios: solo corrige el absurdo "480 ml más barata que 230 ml".
 */
export function coherenciaSugeridosPorTamano(filas) {
  /** @type {{ producto: object, sugerido: number|null, [k: string]: any }[]} */
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
