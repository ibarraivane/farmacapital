/**
 * Match de pistola en Recibir.
 * Un ticket PDF/CSV solo acepta códigos de esa lista.
 * El EAN de la caja puede ser distinto al SKU interno del renglón:
 * se cruza con el catálogo (producto_id / sku → codigo_barras).
 */
import {
  barcodeDigitsMatch,
  findProductExactScan,
  normalizeBarcodeRaw,
} from "../utils/barcodeProductLookup";

export function recepcionEsTicketDocumento(items) {
  return (items || []).some((i) => i?.origen === "pdf" || i?.origen === "csv");
}

export function itemMatchScan(it, codigo, productos = []) {
  if (!it || !codigo) return false;
  if (it.codigo_escaneado && barcodeDigitsMatch(codigo, it.codigo_escaneado)) return true;
  if (it.sku && String(it.sku).toUpperCase() === String(codigo).toUpperCase()) return true;

  const porId = it.producto_id != null
    ? productos.find((p) => p?.id === it.producto_id)
    : null;
  if (porId && findProductExactScan([porId], codigo, { activeOnly: false })) return true;

  if (it.sku) {
    const porSku = productos.find(
      (p) => p?.sku && String(p.sku).toUpperCase() === String(it.sku).toUpperCase(),
    );
    if (porSku && findProductExactScan([porSku], codigo, { activeOnly: false })) return true;
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
