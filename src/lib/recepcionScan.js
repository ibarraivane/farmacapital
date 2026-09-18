/**
 * Match de pistola en Recibir.
 * Un ticket PDF/CSV solo acepta códigos de esa lista.
 * El EAN de la caja puede ser distinto al SKU interno del renglón:
 * se cruza con el catálogo (producto_id / sku → codigo_barras).
 *
 * Sin imports a React ni a utils/: el build lo audita con Node (check-recibir-tablet).
 */

import { EAN_PARES_CONOCIDOS } from "./eanParesConocidos.js";

/** Prefijo AIM de pistola: ]C1 Code 128, ]d2 DataMatrix, ]e0 GS1 DataBar, ]Q1 QR. */
function stripAimSymbology(t) {
  return String(t || "").replace(/^\][A-Za-z][0-9]/, "");
}

export function normalizeBarcodeRaw(raw) {
  let t = String(raw ?? "").trim();
  t = stripAimSymbology(t);
  // FNC1 / Group Separator en DataMatrix GS1 (lote/cad tras el GTIN).
  t = t.replace(/\x1d/g, "");
  t = t.replace(/\s/g, "");
  return t;
}

/**
 * GTIN/EAN embebido en DataMatrix GS1 (cajas de medicamento).
 * Formatos: (01)GTIN, 01+GTIN-14, o EAN embebido en un beep largo.
 */
export function extractGs1Gtin(raw) {
  const t = normalizeBarcodeRaw(raw);
  if (!t) return null;

  const paren = t.match(/\(01\)(\d{13,14})/);
  if (paren) {
    const g = paren[1];
    return g.length === 14 && g.startsWith("0") ? g.slice(1) : g;
  }

  // AI 01 + GTIN-14 (a veces con FNC1 / GS como separador ya strippeado)
  const ai01 = t.match(/(?:^|[^0-9])01(\d{14})/);
  if (ai01) {
    const g = ai01[1];
    return g.startsWith("0") ? g.slice(1) : g;
  }

  const digits = t.replace(/\D/g, "");
  if (digits.length <= 14) return null;

  if (digits.startsWith("01") && digits.length >= 16) {
    const g = digits.slice(2, 16);
    return g.startsWith("0") ? g.slice(1) : g;
  }

  const embebido = digits.match(/750\d{10}|650240\d{6,7}|360\d{10}|361\d{10}|400\d{10}|333\d{10}|366\d{10}|020\d{9}/);
  return embebido ? embebido[0] : null;
}

/** Lote de fábrica (AI 10) en DataMatrix GS1. */
export function extractGs1Lot(raw) {
  const t = normalizeBarcodeRaw(raw);
  if (!t) return null;
  const paren = t.match(/\(10\)([^\(\x1d]{2,20})/);
  if (paren) return paren[1].replace(/\s/g, "");
  const after17 = t.match(/17\d{6}10([A-Za-z0-9\-]{2,20})/);
  if (after17) return after17[1];
  return null;
}

/** Serial / etiqueta de terminal Point Smart — no es producto. */
export function esSerialTerminalPoint(raw) {
  const t = normalizeBarcodeRaw(raw).toUpperCase();
  if (!t) return false;
  if (/^N950/i.test(t)) return true;
  if (/^NCCC\d{8,}$/i.test(t)) return true;
  if (/NEWLAND_N950/i.test(t)) return true;
  return false;
}

/** Códigos candidatos a matchear: crudo + GTIN GS1 si viene en beep largo. */
export function scanCodigoCandidates(raw) {
  const code = normalizeBarcodeRaw(raw) || String(raw || "").trim();
  if (!code) return [];
  const out = [code];
  const gtin = extractGs1Gtin(code);
  if (gtin && !out.some((c) => barcodeDigitsMatch(c, gtin))) out.push(gtin);
  return out;
}

/** Genomma 650240: ticket 12 dígitos se come un 0; la caja trae 13 (6502400…). */
export function genommaTicketVsCaja(a, b) {
  const norm = (d) => {
    const t = String(d || "").replace(/\D/g, "");
    if (/^6502400\d{6}$/.test(t)) return `650240${t.slice(7)}`;
    if (/^650240\d{6}$/.test(t)) return t;
    return null;
  };
  const na = norm(a);
  const nb = norm(b);
  return !!(na && nb && na === nb);
}

export function barcodeDigitsMatch(scanRaw, storedRaw) {
  const scan = normalizeBarcodeRaw(scanRaw).replace(/\D/g, "");
  const stored = normalizeBarcodeRaw(storedRaw).replace(/\D/g, "");
  if (!scan || !stored) return false;
  if (scan === stored) return true;
  if (scan.length >= 12 && stored.length >= 12) {
    if (scan.slice(-12) === stored.slice(-12)) return true;
    if (scan.length === 13 && stored.length === 12 && scan.slice(1) === stored) return true;
    if (stored.length === 13 && scan.length === 12 && stored.slice(1) === scan) return true;
  }
  // Dígito verificador al final: ticket 650240013850 ↔ catálogo 6502400138504
  if (scan.length >= 8 && stored.length === scan.length + 1 && stored.startsWith(scan)) return true;
  if (stored.length >= 8 && scan.length === stored.length + 1 && scan.startsWith(stored)) return true;
  if (genommaTicketVsCaja(scan, stored)) return true;
  return false;
}

/** El DataMatrix a veces no parsea AI 01; el EAN del ticket va embebido en el beep. */
export function beepContieneCodigo(raw, storedRaw) {
  const digits = normalizeBarcodeRaw(raw).replace(/\D/g, "");
  const stored = normalizeBarcodeRaw(storedRaw).replace(/\D/g, "");
  if (!stored || stored.length < 8 || digits.length <= stored.length) return false;
  if (digits.includes(stored)) return true;
  if (stored.length >= 12 && digits.includes(stored.slice(0, 12))) return true;
  if (/^650240\d{6}$/.test(stored) && digits.includes(`6502400${stored.slice(6)}`)) return true;
  if (/^6502400\d{6}$/.test(stored) && digits.includes(`650240${stored.slice(7)}`)) return true;
  return false;
}

function eansAliasDe(ean) {
  const d = String(ean || "").replace(/\D/g, "");
  if (!d) return [];
  const extra = [];
  for (const par of EAN_PARES_CONOCIDOS) {
    if (par.some((p) => barcodeDigitsMatch(d, p))) {
      for (const p of par) {
        if (!extra.some((x) => barcodeDigitsMatch(x, p))) extra.push(p);
      }
    }
  }
  return extra;
}

function codigoEsAlias(scan, stored) {
  if (!scan || !stored) return false;
  if (barcodeDigitsMatch(scan, stored)) return true;
  return eansAliasDe(stored).some((a) => barcodeDigitsMatch(scan, a));
}

/** EAN principal, alias en descripción (pieza vs exhibidor) y SKU. */
function productMatchesCodigo(product, codigo) {
  if (!product || !codigo) return false;
  const cb = product.codigo_barras ? String(product.codigo_barras).trim() : "";
  if (cb && codigoEsAlias(codigo, cb)) return true;
  // EANs del otro empaque anotados en la ficha (ej. bote Broncolin / pack Optims).
  const desc = String(product.descripcion || "");
  for (const m of desc.match(/\d{12,14}/g) || []) {
    if (codigoEsAlias(codigo, m)) return true;
  }
  if (product.sku && String(product.sku).toUpperCase() === String(codigo).toUpperCase()) return true;
  return false;
}

export function recepcionEsTicketDocumento(items) {
  return (items || []).some((i) => i?.origen === "pdf" || i?.origen === "csv");
}

/** Alias legacy del gate / tests antiguos. */
export function recepcionEsTicket(doc) {
  return recepcionEsTicketDocumento(doc?.items || doc || []);
}

function itemMatchScanOne(it, codigo, productos = []) {
  if (!it || !codigo) return false;
  if (it.codigo_escaneado && codigoEsAlias(codigo, it.codigo_escaneado)) return true;
  if (it.codigo_barras && codigoEsAlias(codigo, it.codigo_barras)) return true;
  if (it.sku && String(it.sku).toUpperCase() === String(codigo).toUpperCase()) return true;
  if (it.codigo_escaneado && beepContieneCodigo(codigo, it.codigo_escaneado)) return true;
  if (it.codigo_barras && beepContieneCodigo(codigo, it.codigo_barras)) return true;

  const porId = it.producto_id != null
    ? productos.find((p) => p?.id === it.producto_id)
    : null;
  if (porId && productMatchesCodigo(porId, codigo)) return true;

  if (it.sku) {
    const porSku = productos.find(
      (p) => p?.sku && String(p.sku).toUpperCase() === String(it.sku).toUpperCase(),
    );
    if (porSku && productMatchesCodigo(porSku, codigo)) return true;
  }
  return false;
}

function loteTicketMatch(it, raw) {
  const stored = String(it?.numero_lote || "").trim();
  if (!stored || stored.length < 4) return false;
  const lot = extractGs1Lot(raw);
  if (lot && lot.toUpperCase() === stored.toUpperCase()) return true;
  const code = normalizeBarcodeRaw(raw);
  if (code && code.toUpperCase() === stored.toUpperCase()) return true;
  const rawU = normalizeBarcodeRaw(raw).toUpperCase();
  if (stored.length >= 5 && rawU.includes(stored.toUpperCase())) return true;
  return false;
}

export function itemMatchScan(it, codigo, productos = []) {
  if (!it || !codigo) return false;
  if (scanCodigoCandidates(codigo).some((c) => itemMatchScanOne(it, c, productos))) return true;
  return loteTicketMatch(it, codigo);
}

/**
 * @returns {{ tipo: 'vacio'|'gris'|'ya_confirmado'|'fuera'|'nuevo', item?: object, codigo?: string }}
 */
export function resolverEscaneoRecepcion({ items, codigo, productos, esTicketDocumento }) {
  const code = normalizeBarcodeRaw(codigo) || String(codigo || "").trim();
  if (!code) return { tipo: "vacio" };

  const lista = Array.isArray(items) ? items : [];
  const catalogo = Array.isArray(productos) ? productos : [];
  const matchCode = extractGs1Gtin(code) || code;

  const ya = lista.find((it) => it.confirmado && itemMatchScan(it, code, catalogo));
  if (ya) return { tipo: "ya_confirmado", item: ya, codigo: matchCode };

  const gris = lista.find((it) => !it.confirmado && itemMatchScan(it, code, catalogo));
  if (gris) return { tipo: "gris", item: gris, codigo: matchCode };

  if (esSerialTerminalPoint(code)) {
    return { tipo: "fuera", codigo: code, motivo: "serial_point" };
  }

  if (esTicketDocumento) return { tipo: "fuera", codigo: code };

  return { tipo: "nuevo", codigo: matchCode };
}

/** EAN-8/12/13/14 listo: dispara sin Enter (pistola / tablet). */
export function eanPistolaListo(raw) {
  const t = normalizeBarcodeRaw(raw);
  if (/^\d{8}$|^\d{12,14}$/.test(t)) return true;
  // DataMatrix GS1: beep largo con GTIN embebido — disparar sin Enter.
  const gtin = extractGs1Gtin(t);
  return !!(gtin && /^\d{8}$|^\d{12,14}$/.test(gtin));
}

export function pedidoEsperaEntrada(t) {
  if (!t) return false;
  const renglones = Number(t.renglones || 0);
  const sin = Number(t.sin_confirmar ?? t.pendientes ?? 0);
  const sinCad = Number(t.sin_caducidad_anaquel || 0);
  // Cola Recibir = cajas pendientes (gris o MMAA de anaquel). Un ticket
  // ya recibido (todo verde, sin caducidad de anaquel) no vuelve a la lista
  // solo porque el estado quedó en borrador.
  if (sin > 0 || sinCad > 0) return true;
  if (renglones === 0) {
    const estado = String(t.estado || "").toLowerCase();
    return estado === "borrador" || estado === "parcial" || estado === "abierto";
  }
  return false;
}

export function matchScanEnTicket(items, codigo) {
  const lista = Array.isArray(items) ? items : [];
  const code = normalizeBarcodeRaw(codigo) || String(codigo || "").trim();
  const yaConfirmado = lista.find((it) => it.confirmado && itemMatchScan(it, code, []));
  const gris = lista.find((it) => !it.confirmado && itemMatchScan(it, code, []));
  return { yaConfirmado: !!yaConfirmado, gris: !!gris, item: yaConfirmado || gris || null };
}

/**
 * Verde real = confirmado + MMAA + lote en anaquel.
 * Si está confirmado con caducidad pero sin lote_id y no es pendiente de alta,
 * el renglón "se ve verde" pero NO está en Inventario/POS (bug histórico).
 */
export function recepcionItemEnAnaquel(it) {
  if (!it) return false;
  return !!(it.confirmado && it.fecha_caducidad && it.lote_id && !it.pendiente_alta);
}

/** Confirmado en pantalla pero sin stock en anaquel. */
export function recepcionItemVerdeSinStock(it) {
  if (!it) return false;
  return !!(it.confirmado && it.fecha_caducidad && !it.lote_id && !it.pendiente_alta);
}

export function recepcionItemsVerdeSinStock(items) {
  return (Array.isArray(items) ? items : []).filter(recepcionItemVerdeSinStock);
}
