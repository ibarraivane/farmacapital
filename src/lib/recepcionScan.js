/**
 * Match de pistola en Recibir.
 * Un ticket PDF/CSV solo acepta códigos de esa lista.
 * El EAN de la caja puede ser distinto al SKU interno del renglón:
 * se cruza con el catálogo (producto_id / sku → codigo_barras).
 *
 * Sin imports a React ni a utils/: el build lo audita con Node (check-recibir-tablet).
 */

export function normalizeBarcodeRaw(raw) {
  let t = String(raw ?? "").trim();
  t = t.replace(/^[\]C1\][\x00-\x1f]*/i, "");
  t = t.replace(/\s/g, "");
  return t;
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
  return false;
}

function productMatchesCodigo(product, codigo) {
  if (!product || !codigo) return false;
  const cb = product.codigo_barras ? String(product.codigo_barras).trim() : "";
  if (cb && barcodeDigitsMatch(codigo, cb)) return true;
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

export function itemMatchScan(it, codigo, productos = []) {
  if (!it || !codigo) return false;
  if (it.codigo_escaneado && barcodeDigitsMatch(codigo, it.codigo_escaneado)) return true;
  if (it.sku && String(it.sku).toUpperCase() === String(codigo).toUpperCase()) return true;

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

/**
 * @returns {{ tipo: 'vacio'|'gris'|'ya_confirmado'|'fuera'|'nuevo', item?: object, codigo?: string }}
 */
export function resolverEscaneoRecepcion({ items, codigo, productos, esTicketDocumento }) {
  const code = normalizeBarcodeRaw(codigo) || String(codigo || "").trim();
  if (!code) return { tipo: "vacio" };

  const lista = Array.isArray(items) ? items : [];
  const catalogo = Array.isArray(productos) ? productos : [];

  const ya = lista.find((it) => it.confirmado && itemMatchScan(it, code, catalogo));
  if (ya) return { tipo: "ya_confirmado", item: ya, codigo: code };

  const gris = lista.find((it) => !it.confirmado && itemMatchScan(it, code, catalogo));
  if (gris) return { tipo: "gris", item: gris, codigo: code };

  if (esTicketDocumento) return { tipo: "fuera", codigo: code };

  return { tipo: "nuevo", codigo: code };
}

/** EAN-8/12/13/14 listo: dispara sin Enter (pistola / tablet). */
export function eanPistolaListo(raw) {
  const t = normalizeBarcodeRaw(raw);
  return /^\d{8}$|^\d{12,14}$/.test(t);
}

export function pedidoEsperaEntrada(t) {
  if (!t) return false;
  const sin = Number(t.sin_confirmar ?? t.pendientes ?? 0);
  const estado = String(t.estado || "").toLowerCase();
  if (sin > 0) return true;
  return estado === "borrador" || estado === "parcial" || estado === "abierto";
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
