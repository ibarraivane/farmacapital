import { margenSobreVentaPct, markupSobreCostoPct } from "./margenMarkup";

function costoClave(costo) {
  const n = Number(costo);
  if (!Number.isFinite(n) || n <= 0) return null;
  return n.toFixed(4);
}

/** Capas vivas: piezas del anaquel agrupadas por costo de compra. */
export function capasCostoVivas(lotes, precio) {
  const grupos = new Map();
  for (const lote of lotes || []) {
    if (lote?.activo === false) continue;
    const piezas = Number(lote?.cantidad_actual) || 0;
    if (piezas <= 0) continue;
    const clave = costoClave(lote?.costo_unitario);
    if (!clave) continue;
    const prev = grupos.get(clave) || {
      costo: Number(clave),
      piezas: 0,
      estimado: false,
    };
    prev.piezas += piezas;
    prev.estimado = prev.estimado || Boolean(lote.costo_es_estimado);
    grupos.set(clave, prev);
  }
  return [...grupos.values()]
    .map((g) => ({
      ...g,
      margenPct: margenSobreVentaPct(precio, g.costo),
      recargoPct: markupSobreCostoPct(precio, g.costo),
    }))
    .sort((a, b) => a.costo - b.costo);
}

export function textoCapaCosto(capa) {
  const margen = capa.margenPct == null ? "—" : `${capa.margenPct.toFixed(1)}%`;
  const costo = `$${Number(capa.costo).toFixed(2)}`;
  return `${capa.piezas} pzas a ${costo} · margen ${margen}`;
}
