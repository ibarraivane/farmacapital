/**
 * Rellena las columnas de Referencias que el dueño ve.
 * Compra: Abarrotero / Scorpion / MayoreoTotal (públicos).
 * Venta: Similares (VTEX), Del Ahorro si responde, Otros = promedio de lo extra.
 * Exprezo no se rastrea: no hay catálogo público.
 */

"use strict";

const {
  recolectarCompraPublica,
  buscarVentaCadena,
  terminoBusqueda,
} = require("./catalogosPublicos");
const { matchOferta, matchMejorCandidato, precioOtrosMercado } = require("./matchCatalogo");

const DIAS_STALE = 7;
const LOTE_VENTA = 6;
const PRESUPUESTO_MS = 8000;

function esStale(fecha, ahora, dias) {
  if (!fecha) return true;
  const t = new Date(fecha).getTime();
  if (!Number.isFinite(t)) return true;
  return ahora.getTime() - t > dias * 86400000;
}

function productosParaVenta(catalogo, refsByProduct, ahora) {
  return (catalogo || [])
    .filter((p) => p && p.id)
    .map((p) => {
      const refs = refsByProduct[p.id] || {};
      const sim = refs.similares;
      const stale = esStale(sim?.fecha, ahora, DIAS_STALE);
      return { p, stale, id: p.id };
    })
    .sort((a, b) => Number(b.stale) - Number(a.stale) || a.id - b.id)
    .map((x) => x.p);
}

function filaRef(productoId, fuente, tipo, precio, nombre, confianza) {
  return {
    producto_id: productoId,
    fuente,
    tipo,
    precio: Math.round(Number(precio) * 100) / 100,
    nombre_fuente: nombre || null,
    confianza: Math.round((confianza || 0.8) * 100),
    origen: "job_api",
    notas: "rastreo_automatico",
  };
}

async function rastrearReferencias(input) {
  const fetchImpl = input.fetchImpl || fetch;
  const catalogo = input.catalogo || [];
  const refsByProduct = input.refsByProduct || {};
  const ahora = input.ahora || new Date();
  const presupuesto = input.presupuestoMs || PRESUPUESTO_MS;
  const lote = input.loteVenta || LOTE_VENTA;
  const t0 = Date.now();
  const filas = [];
  const errores = [];

  let ofertasCompra = [];
  try {
    ofertasCompra = await recolectarCompraPublica(fetchImpl);
  } catch (err) {
    errores.push({ fuente: "compra", error: (err && err.message) || String(err) });
  }

  const uniqCompra = new Map();
  for (const ofe of ofertasCompra) {
    const hit = matchOferta(ofe, catalogo);
    if (!hit) continue;
    const k = `${hit.producto.id}:${ofe.fuente}`;
    const prev = uniqCompra.get(k);
    if (!prev || ofe.precio < prev.precio) {
      uniqCompra.set(k, filaRef(
        hit.producto.id, ofe.fuente, "compra", ofe.precio, ofe.nombre, hit.confianza
      ));
    }
  }
  filas.push(...uniqCompra.values());

  const cola = productosParaVenta(catalogo, refsByProduct, ahora).slice(0, lote);
  let busquedasVenta = 0;
  for (const p of cola) {
    if (Date.now() - t0 > presupuesto) break;
    const q = terminoBusqueda(p);
    if (!q) continue;
    const porFuente = {};
    const existentes = refsByProduct[p.id] || {};
    if (Number(existentes.fahorro?.precio) > 0) porFuente.fahorro = Number(existentes.fahorro.precio);
    if (Number(existentes.similares?.precio) > 0) porFuente.similares = Number(existentes.similares.precio);

    for (const cadena of ["similares", "fahorro"]) {
      if (Date.now() - t0 > presupuesto) break;
      try {
        const cands = await buscarVentaCadena(fetchImpl, cadena, q);
        busquedasVenta += 1;
        const best = matchMejorCandidato(p, cands);
        if (!best) continue;
        porFuente[cadena] = best.precio;
        filas.push(filaRef(p.id, cadena, "venta", best.precio, best.nombre, best.confianza));
      } catch (err) {
        errores.push({ fuente: cadena, sku: p.sku, error: (err && err.message) || String(err) });
      }
    }

    const otros = precioOtrosMercado(porFuente);
    if (otros != null) {
      filas.push(filaRef(p.id, "otros_venta", "venta", otros, "promedio mercado", 0.85));
    }
  }

  return {
    filas,
    ofertas_compra: ofertasCompra.length,
    matches_compra: uniqCompra.size,
    busquedas_venta: busquedasVenta,
    errores,
    ms: Date.now() - t0,
  };
}

module.exports = {
  DIAS_STALE,
  LOTE_VENTA,
  esStale,
  productosParaVenta,
  rastrearReferencias,
};
