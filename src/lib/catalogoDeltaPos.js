/**
 * Aplica sobre el catálogo del POS los productos que cambiaron (RPC delta):
 * reemplaza por id, agrega los nuevos al final y quita los que quedaron inactivos.
 * Si no hay cambios devuelve el mismo arreglo (sin re-render).
 */
/**
 * La vitrina no entra al POS: si cambió, se trata como baja.
 * Excepto si ya tiene stock: piezas físicas deben venderse en mostrador
 * (aunque el flag bajo_pedido no se haya apagado aún).
 */
export function filasDeltaAnaquel(delta) {
  return (Array.isArray(delta) ? delta : []).map((p) => {
    if (p?.bajo_pedido === true && !(Number(p?.stock) > 0)) {
      return { ...p, activo: false };
    }
    return p;
  });
}

export function mergeCatalogoDelta(prev, delta) {
  if (!Array.isArray(delta) || !delta.length) return prev;
  const porId = new Map();
  for (const d of delta) porId.set(String(d.id), d);
  const vistos = new Set();
  const out = [];
  for (const p of prev) {
    const k = String(p.id);
    const d = porId.get(k);
    if (d) {
      vistos.add(k);
      if (d.activo !== false) out.push(d);
    } else {
      out.push(p);
    }
  }
  for (const d of delta) {
    const k = String(d.id);
    if (!vistos.has(k) && d.activo !== false) out.push(d);
  }
  return out;
}
