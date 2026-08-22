/** Match de pistola en Recibir. Sin React ni utils: el build lo audita con Node. */

export function normalizeScanRaw(raw) {
  let t = String(raw ?? "").trim();
  t = t.replace(/^[\]C1\][\x00-\x1f]*/i, "");
  t = t.replace(/\s/g, "");
  return t;
}

export function looksLikeBarcodeInput(raw) {
  const t = normalizeScanRaw(raw);
  return t.length >= 8 && /^\d+$/.test(t);
}

export function looksLikeInternalSku(raw) {
  return /^(FC|EQ|FMX)[-_]/i.test(String(raw || "").trim());
}

export function barcodeDigitsMatch(scanRaw, storedRaw) {
  const scan = normalizeScanRaw(scanRaw);
  const stored = normalizeScanRaw(storedRaw);
  if (!scan || !stored) return false;
  if (scan === stored) return true;
  if (stored.startsWith(scan) && stored.length - scan.length <= 1) return true;
  if (scan.startsWith(stored) && scan.length - stored.length <= 1) return true;
  if (scan.length === 12 && stored.length === 13 && stored === `0${scan}`) return true;
  if (stored.length === 12 && scan.length === 13 && scan === `0${stored}`) return true;
  return false;
}

export function splitBarcodeCandidates(raw) {
  const t = normalizeScanRaw(raw);
  if (!t) return [];
  const out = [];
  const push = (v) => {
    if (v && !out.includes(v)) out.push(v);
  };
  push(t);
  for (const len of [13, 12, 8]) {
    if (t.length === len * 2) {
      push(t.slice(0, len));
      push(t.slice(len));
    }
    if (t.length > len) {
      push(t.slice(0, len));
      push(t.slice(-len));
    }
  }
  return out;
}

export function skuSoloDigitos(sku) {
  const d = String(sku || "").replace(/\D/g, "");
  return d.length >= 7 ? d : "";
}

/** El renglón gris de Recibir coincide con lo que acaba de leer la pistola. */
export function itemMatchScan(it, codigo) {
  if (!it || !codigo) return false;
  const cands = splitBarcodeCandidates(codigo);
  for (const c of cands) {
    if (it.codigo_escaneado && barcodeDigitsMatch(c, it.codigo_escaneado)) return true;
    if (it.sku && String(it.sku).toUpperCase() === String(c).toUpperCase()) return true;
    const sd = skuSoloDigitos(it.sku);
    const cd = String(c).replace(/\D/g, "");
    if (sd && cd && (cd.includes(sd) || sd.includes(cd))) return true;
  }
  return false;
}

export function pedidoEsperaEntrada(t) {
  const renglones = Number(t?.renglones || 0);
  const falta = Number(t?.sin_confirmar || 0) + Number(t?.sin_caducidad_anaquel || 0);
  return renglones > 0 && (falta > 0 || t?.estado === "borrador" || t?.estado === "pendiente_caducidad");
}

/** Código completo de pistola: no hay que esperar Enter. */
export function eanPistolaListo(raw) {
  const codigo = normalizeScanRaw(raw);
  if (looksLikeInternalSku(codigo)) return true;
  return looksLikeBarcodeInput(codigo) && [8, 12, 13, 14].includes(codigo.length);
}

export const MSG_SCAN_FUERA_TICKET = "No corresponde a ninguno de los ítems de este ticket.";
export const MSG_SCAN_YA_EN_TICKET = "Ya está en este ticket.";

/** Lista gris/verde de un PDF o CSV: la pistola no puede inventar renglones. */
export function recepcionEsTicket(doc) {
  const items = Array.isArray(doc?.items) ? doc.items : [];
  return items.some((it) => it?.origen === "pdf" || it?.origen === "csv");
}

export function matchScanEnTicket(items, codigo) {
  const hits = (Array.isArray(items) ? items : []).filter((it) => itemMatchScan(it, codigo));
  return {
    gris: hits.find((it) => !it.confirmado) || null,
    yaConfirmado: hits.find((it) => it.confirmado) || null,
  };
}
