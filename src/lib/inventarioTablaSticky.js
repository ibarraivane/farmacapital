/** Columnas que se quedan fijas al hacer scroll horizontal en Inventario. */
export const INV_STICKY_COL_IDS = ["foto", "acciones", "skuFarmaCapital", "nombre"];

export const INV_CHECKBOX_COL_WIDTH = 38;

export const INV_COL_WIDTHS_DEFAULT = {
  acciones: 104,
  codigoBarras: 128,
  nombre: 272,
  marca: 130,
  presentacion: 160,
  principio: 200,
  ubicacion: 180,
  categoria: 120,
  proveedor: 140,
};

const INV_COL_WIDTH_FLOOR = {
  foto: 44,
  skuFarmaCapital: 118,
};

/**
 * Ancho en px de una columna. Las sticky usan este valor para `left`;
 * tiene que coincidir con el ancho real de la celda (table-layout:fixed + colgroup).
 */
export function invColumnPixelWidth(colId, colWidths) {
  if (colId === "foto") return INV_COL_WIDTH_FLOOR.foto;
  if (colId === "skuFarmaCapital") return INV_COL_WIDTH_FLOOR.skuFarmaCapital;
  const floors = {
    acciones: 88,
    codigoBarras: 100,
    nombre: 200,
    marca: 90,
    presentacion: 110,
    principio: 130,
    ubicacion: 120,
    categoria: 100,
    proveedor: 100,
  };
  if (floors[colId] != null) {
    return Math.max(floors[colId], Number(colWidths?.[colId]) || INV_COL_WIDTHS_DEFAULT[colId]);
  }
  return 96;
}

export function invTablePixelWidth(colOrder, colWidths, { hasCheckbox = true } = {}) {
  let total = hasCheckbox ? INV_CHECKBOX_COL_WIDTH : 0;
  for (const id of colOrder) total += invColumnPixelWidth(id, colWidths);
  return total;
}

/**
 * `left` de cada columna sticky (y del checkbox) según el orden visible.
 * Las columnas no-sticky que quedan en medio no suman: al scrollear se meten debajo.
 */
export function inventarioStickyLefts(colOrder, colWidths, { hasCheckbox = true, measuredWidths } = {}) {
  const widthOf = (id) => {
    const measured = Number(measuredWidths?.[id]);
    if (Number.isFinite(measured) && measured > 0) return measured;
    if (id === "checkbox") return INV_CHECKBOX_COL_WIDTH;
    return invColumnPixelWidth(id, colWidths);
  };

  const lefts = {};
  let left = 0;
  if (hasCheckbox) {
    lefts.checkbox = 0;
    left = widthOf("checkbox");
  }
  for (const id of colOrder) {
    if (!INV_STICKY_COL_IDS.includes(id)) continue;
    lefts[id] = left;
    left += widthOf(id);
  }
  return lefts;
}

export function stickyWidthsEqual(a, b) {
  if (a === b) return true;
  if (!a || !b) return false;
  const keys = new Set([...Object.keys(a), ...Object.keys(b)]);
  for (const k of keys) {
    if (Math.abs((Number(a[k]) || 0) - (Number(b[k]) || 0)) > 0.6) return false;
  }
  return true;
}

/**
 * Estilo sticky para th/td. El z-index baja hacia la derecha: si hay 1 px de
 * desfase, Foto/SKU tapan a Nombre — nunca al revés (el bug del scroll).
 */
export function inventarioStickyStyle(colId, colOrder, colWidths, {
  header,
  bg,
  hasCheckbox = true,
  measuredWidths,
} = {}) {
  if (!INV_STICKY_COL_IDS.includes(colId)) return {};
  const myIndex = colOrder.indexOf(colId);
  if (myIndex < 0) return {};

  const lefts = inventarioStickyLefts(colOrder, colWidths, { hasCheckbox, measuredWidths });
  const left = lefts[colId];
  if (left == null) return {};

  const w = measuredWidths?.[colId] > 0
    ? measuredWidths[colId]
    : invColumnPixelWidth(colId, colWidths);
  const stickyBefore = colOrder.slice(0, myIndex).filter((id) => INV_STICKY_COL_IDS.includes(id)).length;
  const stickyTotal = 1 + (hasCheckbox ? 1 : 0) + colOrder.filter((id) => INV_STICKY_COL_IDS.includes(id)).length;
  const hasStickyAfter = colOrder.slice(myIndex + 1).some((id) => INV_STICKY_COL_IDS.includes(id));
  const stackFromLeft = (hasCheckbox ? 1 : 0) + stickyBefore;

  return {
    position: "sticky",
    left,
    width: w,
    minWidth: w,
    maxWidth: w,
    boxSizing: "border-box",
    overflow: "hidden",
    isolation: "isolate",
    zIndex: (header ? 20 : 8) + (stickyTotal - stackFromLeft),
    background: bg,
    backgroundClip: "padding-box",
    // overflow:hidden recorta box-shadow; el borde marca el corte del scroll.
    borderRight: !hasStickyAfter ? "1px solid #cbd5e1" : undefined,
  };
}
