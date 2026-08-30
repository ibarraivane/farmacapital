/**
 * Cajas grandes que en piso se abren y se venden por pieza
 * (Aspirina C/40–C/80, Alka C/50, etc.). No van a la tienda en línea:
 * el cliente pediría la caja cerrada y en mostrador ya no se vende así.
 *
 * Umbral 40: deja en web C/12 y C/24 (Tabcin, Syncol, Aspirina Forte).
 * No toca gasa, cubrebocas, curitas, pañales, Tena, Saba ni frascos Mercurio.
 */

const UMBRAL_CAJA_GRANEL = 40;

function textoFicha(p) {
  return `${p?.nombre || ""} ${p?.presentacion || ""} ${p?.forma_farmaceutica || ""} ${p?.categoria || ""}`
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
}

function esPackHigieneOCuracion(p) {
  const t = textoFicha(p);
  const cat = String(p?.categoria || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
  if (/\b(higiene|dispositivo|cuidado personal)\b/.test(cat)) return true;
  return /\b(gasa|cubre|curita|guante|tegaderm|panal|tena|naturella|saba|protector|algodon|venda|jeringa|aguja)\b/.test(t);
}

function esFrascoOPote(p) {
  const t = textoFicha(p);
  if (/\b(oxido|mercurio)\b/.test(t)) return true;
  if (/\b(frasco|pote|tarro)\b/.test(t)) return true;
  return false;
}

/** Piezas por caja: columna o C/40 / 80 tabletas en el nombre. */
export function cuentaPiezasCajaMostrador(p) {
  const n = Number(p?.unidades_por_caja);
  if (Number.isFinite(n) && n > 0) return n;
  const t = textoFicha(p);
  const m =
    t.match(/\b(?:c\/\s*|caja\s+con\s+|caja\s+c\/\s*)(\d{2,3})\b/) ||
    t.match(/\b(\d{2,3})\s+(tabletas?|tabs?|capsulas?|caps)\b/);
  return m ? Number(m[1]) : 0;
}

function esFamiliaVentaPieza(t) {
  return /\b(aspirina|cafiaspirina|alka[-\s]?seltzer|sedalmerck|melox|sal de uvas|bicarbonato)\b/.test(t);
}

function esFormaOralSuelta(t, categoria) {
  if (/\b(tableta|tab\b|capsula|efervescente|sobres?|comprimido|pastilla)\b/.test(t)) return true;
  const cat = String(categoria || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
  return /\b(analgesico|gastro)\b/.test(cat);
}

/**
 * True si la caja no debe listarse ni venderse en farmacapital.mx.
 * El POS sigue cobrando la pieza.
 */
export function productoEsCajaAbiertaMostrador(p) {
  if (!p) return false;
  if (esPackHigieneOCuracion(p) || esFrascoOPote(p)) return false;
  const n = cuentaPiezasCajaMostrador(p);
  if (n < UMBRAL_CAJA_GRANEL) return false;
  const t = textoFicha(p);
  if (/\b(aspirina|cafiaspirina)\b/.test(t)) return true;
  if (!(p.venta_unidad || esFamiliaVentaPieza(t))) return false;
  return esFormaOralSuelta(t, p.categoria);
}

/** Notas de ticket / proveedor: no se muestran al cliente. */
export function descripcionPublicaTienda(p) {
  const d = String(p?.descripcion || "").trim();
  if (!d) return "";
  const low = d
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
  if (/^ticket\b/.test(low)) return "";
  if (/^factura\b/.test(low)) return "";
  if (low.includes("falta codigo de barras")) return "";
  if (low.includes("codigo de proveedor") || low.includes("clave de proveedor")) return "";
  const nombre = String(p?.nombre || "")
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
  if (nombre && low === nombre) return "";
  return d;
}
