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
 * Solo filtra la tienda web. Nunca pone activo=false:
 * el POS, el inventario y el cobro por pieza siguen igual.
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

function normalizarTextoPublico(s) {
  return String(s || "")
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
}

/**
 * Notas de compra / ticket / proveedor / cruce de precios: el cliente no debe ver
 * dónde se compró, folios internos ni referencias de competencia (Fahorro…).
 */
export function esNotaInternaCompra(texto) {
  const low = normalizarTextoPublico(texto);
  if (!low) return false;
  if (/^(ticket|factura|alta)\b/.test(low)) return true;
  if (/^nota\s+t\d/.test(low)) return true;
  if (/\bticket\b/.test(low)) return true;
  if (low.includes("ean pendiente")) return true;
  if (low.includes("pendiente de caja")) return true;
  if (low.includes("falta codigo de barras")) return true;
  if (low.includes("codigo de proveedor") || low.includes("clave de proveedor")) return true;
  if (low.includes("listo para pistola")) return true;
  if (low.includes("foto pendiente")) return true;
  if (low.includes("no se inventa")) return true;
  if (low.includes("nombre viene cortado") || low.includes("nombre cortado")) return true;
  if (low.includes("falta ean")) return true;
  if (low.includes("por definir") && /costo|pvp|precio/.test(low)) return true;
  // Nota de alta: "recargo marca +25%" / "P.U. $30.90 ya con IVA"
  if (/\brecargo\b/.test(low) && /\b(marca|generico|patente)\b/.test(low)) return true;
  if (/\bp\.?\s*u\.?\b/.test(low) && /\b(iva|costo)\b/.test(low)) return true;
  if (/\bya con iva\b/.test(low)) return true;
  // Cruce de precios / import: "Fahorro SKU=EAN … · precio lista $801"
  if (/\bsku\s*=\s*ean\b/.test(low)) return true;
  if (/\bprecio\s+lista\b/.test(low) && /\b(ean|sku|\$)\b/.test(low)) return true;
  if (
    /\b(fahorro|farmacias?\s+del\s+ahorro|guadalajara|similares|benavides|san\s+pablo)\b/.test(low) &&
    /\b(sku|ean|precio\s+lista|ref|lista)\b/.test(low)
  ) {
    return true;
  }
  if (
    /\b(nadro|levic|visoti|exprezo|scorpion|farmalive|farma city|farma mx|farma mayoreo|farma centre|ifc|equilibrio|cityfarma|dulceria|la victoria|la famosa)\b/.test(low) &&
    /\b(alta|factura|nota|proveedor|ean|folio|t\d{6,})\b/.test(low)
  ) {
    return true;
  }
  return false;
}

const ABREV_TICKET_PUBLICO = [
  [/\bEferv\b/gi, "Efervescente"],
  [/\bTabs\b/gi, "tabletas"],
  [/\bTab\b/gi, "tabletas"],
];

/** Quita EAN / código de barras: el cliente no lo necesita en la ficha. */
export function quitarCodigoBarrasPublico(texto) {
  let out = String(texto || "").trim();
  if (!out) return "";
  const before = out;
  out = out.replace(
    /\b(?:ean|upc|gtin|c[oó]digo(?:\s+de)?\s+barras|c[oó]d\.?\s*barras?)\s*[:#.]?\s*\d{8,14}\b/gi,
    "",
  );
  out = out.replace(/\b\d{8,14}\b/g, "");
  if (out !== before) {
    out = out.replace(/\s*[—–\-·]+\s*$/g, "");
    out = out.replace(/^\s*[—–\-·]+\s*/g, "");
  }
  return out.replace(/\s+/g, " ").trim();
}

/**
 * Expande abreviaciones de ticket (Eferv, C/12, Tab) para la tienda.
 * No cambia el valor en BD; el POS sigue viendo el nombre corto.
 */
export function expandirTextoPublicoTienda(texto) {
  let out = String(texto || "").trim();
  if (!out) return "";
  for (const [re, repl] of ABREV_TICKET_PUBLICO) {
    out = out.replace(re, repl);
  }
  out = out.replace(/\bC\/\s*(\d+)\b/gi, "caja con $1");
  if (/^caja con \d+/i.test(out)) {
    out = out.replace(/^caja con/i, "Caja con");
  }
  return out.replace(/\s+/g, " ").trim();
}

/** Nombre de mostrador para el cliente: sin corte de ticket. */
export function nombrePublicoTienda(p) {
  return expandirTextoPublicoTienda(p?.nombre || "");
}

/** Notas de ticket / proveedor: no se muestran al cliente. */
export function descripcionPublicaTienda(p) {
  const d = String(p?.descripcion || "").trim();
  if (!d || esNotaInternaCompra(d)) return "";
  const limpia = quitarCodigoBarrasPublico(d);
  if (!limpia || esNotaInternaCompra(limpia)) return "";
  const nombrePub = normalizarTextoPublico(nombrePublicoTienda(p));
  const nombreCrudo = normalizarTextoPublico(p?.nombre);
  const low = normalizarTextoPublico(limpia);
  if (nombrePub && low === nombrePub) return "";
  if (nombreCrudo && low === nombreCrudo) return "";
  return expandirTextoPublicoTienda(limpia);
}

/** Presentación comercial; oculta si el campo se usó como nota de ticket. */
export function presentacionPublicaTienda(p) {
  const d = String(p?.presentacion || "").trim();
  if (!d || esNotaInternaCompra(d)) return "";
  return expandirTextoPublicoTienda(d);
}

/** Subtítulo de tarjeta: ficha pública o presentación, nunca la nota de compra. */
export function subtituloPublicoTienda(p) {
  return descripcionPublicaTienda(p) || presentacionPublicaTienda(p);
}
