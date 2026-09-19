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

/** Notas de ticket / proveedor: no se muestran al cliente. */
export function descripcionPublicaTienda(p) {
  const d = String(p?.descripcion || "").trim();
  if (!d || esNotaInternaCompra(d)) return "";
  const low = normalizarTextoPublico(d);
  const nombre = normalizarTextoPublico(p?.nombre);
  if (nombre && low === nombre) return "";
  return d;
}

/** Presentación comercial; oculta si el campo se usó como nota de ticket. */
export function presentacionPublicaTienda(p) {
  const d = String(p?.presentacion || "").trim();
  if (!d || esNotaInternaCompra(d)) return "";
  return d;
}

/** Subtítulo de tarjeta: marca · presentación · concentración · forma. Nunca la nota de compra. */
export function subtituloPublicoTienda(p) {
  if (!p) return "";
  const titulo = String(p.nombre || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
  const partes = [];
  const marca = String(p.marca || "").trim();
  const pres = presentacionPublicaTienda(p);
  const conc = String(p.concentracion || "").trim();
  const forma = String(p.forma_farmaceutica || "").trim();

  if (marca && !/gen[eé]rico/i.test(marca) && !titulo.includes(marca.toLowerCase())) {
    partes.push(marca);
  }
  if (pres) partes.push(pres);
  if (conc && !titulo.includes(conc.toLowerCase())) partes.push(conc);
  if (forma && !partes.some((x) => x.toLowerCase() === forma.toLowerCase())) {
    partes.push(forma);
  }
  if (partes.length) return partes.join(" · ");
  return "";
}
