/**
 * Misma sustancia + misma forma + mismo conteo, distinta dosis (mg).
 * No pueden compartir PVP: el de más mg no puede costar igual o menos.
 */

function norm(s) {
  return String(s || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/\p{M}/gu, "")
    .replace(/[^a-z0-9./]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

const RUIDO_PA = new Set([
  "clorhidrato", "hidrocloruro", "maleato", "sulfato", "sodico", "sodio",
  "tableta", "tabletas", "capsula", "capsulas", "mg", "ml",
]);

export function extraerMgConcentracion(...textos) {
  const t = norm(textos.filter(Boolean).join(" "));
  const m = t.match(/(\d+(?:[.,]\d+)?)\s*mg\b/);
  if (!m) return null;
  const n = Number(String(m[1]).replace(",", "."));
  return Number.isFinite(n) && n > 0 ? n : null;
}

export function extraerConteoPiezas(...textos) {
  const t = norm(textos.filter(Boolean).join(" "));
  const m = t.match(/\b(\d+)\s*(tabletas?|tabs?|capsulas?|caps?|comprimidos?|grageas?)\b/);
  if (m) return Number(m[1]);
  return null;
}

export function claveSustanciaDosis(p) {
  const crudo = norm(p?.principio_activo || p?.denominacion_generica || "");
  const sinDosis = crudo
    .replace(/\b\d+([.,]\d+)?\s*(mg|mcg|g|ml|l)\b/g, " ")
    .replace(/\b\d+([.,]\d+)?\b/g, " ");
  const palabras = sinDosis.split(" ").filter((w) => w.length > 2 && !RUIDO_PA.has(w));
  if (!palabras.length) return "";
  return [...new Set(palabras)].sort().join("+");
}

function formaSimple(p) {
  const s = norm(`${p?.forma_farmaceutica || ""} ${p?.presentacion || ""} ${p?.nombre || ""}`);
  if (/\b(tableta|tabletas|tab|comprimido|gragea)\b/.test(s)) return "tabletas";
  if (/\b(capsula|capsulas|cap)\b/.test(s)) return "capsulas";
  return norm(p?.forma_farmaceutica) || "otra";
}

function precioNum(p) {
  const n = parseFloat(p?.precio);
  return Number.isFinite(n) && n > 0 ? n : null;
}

function filaDosis(p) {
  const clave = claveSustanciaDosis(p);
  if (!clave) return null;
  const mg = extraerMgConcentracion(p?.concentracion, p?.nombre, p?.principio_activo);
  if (mg == null) return null;
  const piezas =
    extraerConteoPiezas(p?.presentacion, p?.nombre, p?.contenido) ||
    (Number(p?.unidades_por_caja) > 0 ? Number(p.unidades_por_caja) : null);
  const precio = precioNum(p);
  if (precio == null) return null;
  return {
    producto: p,
    clave,
    forma: formaSimple(p),
    mg,
    piezas,
    precio,
  };
}

/**
 * Pares de la misma familia (PA + forma + piezas) con distinta mg
 * y PVP igual o invertido (el de más mg no es más caro).
 */
export function detectarPrecioIgualDistintaDosis(productos) {
  const filas = (productos || []).map(filaDosis).filter(Boolean);
  const grupos = new Map();
  for (const f of filas) {
    const k = `${f.clave}|${f.forma}|${f.piezas ?? "?"}`;
    if (!grupos.has(k)) grupos.set(k, []);
    grupos.get(k).push(f);
  }
  const out = [];
  for (const miembros of grupos.values()) {
    if (miembros.length < 2) continue;
    const orden = miembros.slice().sort((a, b) => a.mg - b.mg);
    for (let i = 0; i < orden.length; i++) {
      for (let j = i + 1; j < orden.length; j++) {
        if (orden[j].mg <= orden[i].mg * 1.05) continue;
        if (orden[j].precio + 0.01 < orden[i].precio || Math.abs(orden[j].precio - orden[i].precio) < 0.51) {
          out.push({
            bajo: orden[i].producto,
            alto: orden[j].producto,
            mgBajo: orden[i].mg,
            mgAlto: orden[j].mg,
            precioBajo: orden[i].precio,
            precioAlto: orden[j].precio,
            clave: orden[i].clave,
          });
        }
      }
    }
  }
  return out;
}

/**
 * Piso del SKU más fuerte: no puede quedar al mismo PVP que uno de menos mg.
 * Usa recargo 60% sobre costo si hay costo; si no, escala por mg.
 */
export function precioPisoDosisMayor(precioMenor, mgMenor, mgMayor, costoMayor) {
  const p = Number(precioMenor);
  const a = Number(mgMenor);
  const b = Number(mgMayor);
  if (!(p > 0) || !(a > 0) || !(b > a)) return null;
  const porMg = Math.ceil(p * (b / a));
  const c = Number(costoMayor);
  const porCosto = c > 0 ? Math.ceil(c * 1.6) : 0;
  return Math.max(porMg, porCosto, Math.ceil(p) + 1);
}
