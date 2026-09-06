/**
 * Precio de mostrador: dinero especial de caducidad aprobado manda.
 * No se apila con descuento_pct ni con promoción.
 */

import { pesoPublico, cobroLinea } from "../utils/pesoPublico";
import {
  DIAS_CADUCIDAD_ALERTA,
  DIAS_CADUCIDAD_CRITICO,
  diasRestantesCaducidad,
  etiquetaCaducidadIso,
} from "./caducidad";

export function ymd(value) {
  if (!value) return null;
  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    const y = value.getFullYear();
    const m = String(value.getMonth() + 1).padStart(2, "0");
    const d = String(value.getDate()).padStart(2, "0");
    return `${y}-${m}-${d}`;
  }
  return String(value).slice(0, 10) || null;
}

export function propuestaVigente(propuesta, hoy) {
  if (!propuesta || propuesta.estado !== "APROBADA") return false;
  const dia = ymd(hoy);
  const desde = ymd(propuesta.vigencia_desde);
  const hasta = ymd(propuesta.vigencia_hasta);
  if (desde && dia < desde) return false;
  if (hasta && dia > hasta) return false;
  const precio = parseFloat(propuesta.precio_propuesto);
  return Number.isFinite(precio) && precio > 0;
}

export function ordenarLotesFefo(lotes, hoy) {
  const dia = ymd(hoy);
  return (lotes || [])
    .filter((l) => {
      if (l?.activo === false) return false;
      const qty = Number(l.cantidad_actual ?? l.cantidad_disponible ?? 0);
      if (!(qty > 0)) return false;
      const cad = ymd(l.fecha_caducidad);
      if (cad && dia && cad < dia) return false;
      return true;
    })
    .slice()
    .sort((a, b) => {
      const ca = ymd(a.fecha_caducidad);
      const cb = ymd(b.fecha_caducidad);
      if (!ca && cb) return -1;
      if (ca && !cb) return 1;
      if (ca && cb && ca !== cb) return ca < cb ? -1 : 1;
      return Number(a.id || 0) - Number(b.id || 0);
    });
}

/** Precio de UNA caja de un lote. Caducidad vigente pisa descuento y promo. */
export function precioUnitarioCaja({ pvp, descuento_pct, propuesta, hoy }) {
  if (propuestaVigente(propuesta, hoy)) {
    return {
      precio: pesoPublico(propuesta.precio_propuesto),
      fuente: "caducidad",
      apilar: false,
    };
  }
  return {
    precio: cobroLinea(pvp, 1, descuento_pct),
    fuente: "catalogo",
    apilar: true,
  };
}

/**
 * Reparte qty FEFO. Cada caja toma el precio de su lote.
 * Si un lote tiene especial, esa caja no usa promo ni descuento_pct.
 */
export function importeCajasFefo({
  lotes,
  propuestasByLote,
  qty,
  pvp,
  descuento_pct,
  hoy,
}) {
  const n = parseInt(qty, 10) || 0;
  const map = propuestasByLote || {};
  const ordered = ordenarLotesFefo(lotes, hoy);
  let restante = n;
  let total = 0;
  let usaCaducidad = false;
  const detalle = [];

  const cobrar = (propuesta, piezas) => {
    const u = precioUnitarioCaja({ pvp, descuento_pct, propuesta, hoy });
    if (u.fuente === "caducidad") usaCaducidad = true;
    total += u.precio * piezas;
    detalle.push({ piezas, ...u });
    return u;
  };

  for (const lote of ordered) {
    if (restante <= 0) break;
    const disp = Number(lote.cantidad_actual ?? lote.cantidad_disponible ?? 0);
    const take = Math.min(restante, disp);
    if (take <= 0) continue;
    const prop = map[lote.id] || map[String(lote.id)];
    cobrar(prop, take);
    restante -= take;
  }

  if (restante > 0) cobrar(null, restante);

  return {
    total,
    unitario: n > 0 ? total / n : 0,
    usaCaducidad,
    fuente: usaCaducidad ? "caducidad" : "catalogo",
    detalle,
  };
}

export function precioLineaCajaPos(producto, qty, propuestasByLote, hoy) {
  const r = importeCajasFefo({
    lotes: producto?.lotes || [],
    propuestasByLote,
    qty,
    pvp: producto?.precio,
    descuento_pct: producto?.descuento_pct,
    hoy,
  });
  if (r.usaCaducidad) {
    return { precio: r.unitario, descuento_pct: 0, fuentePrecio: "caducidad" };
  }
  return {
    precio: pesoPublico(producto?.precio),
    descuento_pct: Number(producto?.descuento_pct) || 0,
    fuentePrecio: "catalogo",
  };
}

function qtyLote(lote) {
  const n = Number(lote?.cantidad_actual ?? lote?.cantidad_disponible ?? 0);
  return Number.isFinite(n) && n > 0 ? n : 0;
}

/**
 * Qué lote FEFO tomará el POS al escanear (solo lectura; no elige el vendedor).
 * Misma orden que cobro: sin fecha primero, luego la más próxima a caducar.
 */
export function resumenFefoMostrador(producto, propuestasByLote, hoy) {
  const dia = ymd(hoy);
  const ordered = ordenarLotesFefo(producto?.lotes || [], dia);
  if (!ordered.length) {
    return {
      ok: false,
      sinVendible: true,
      titulo: null,
      secundaria: null,
      especial: null,
      nivel: null,
      dias: null,
      etiquetaCad: null,
      cantidad: 0,
      totalLotes: 0,
    };
  }

  const head = ordered[0];
  const cantidad = qtyLote(head);
  const cad = ymd(head.fecha_caducidad);
  const etiquetaCad = cad ? etiquetaCaducidadIso(cad) : null;
  const dias = cad ? diasRestantesCaducidad(cad, dia) : null;
  const prop = (propuestasByLote || {})[head.id] || (propuestasByLote || {})[String(head.id)];
  const especial = propuestaVigente(prop, dia)
    ? pesoPublico(prop.precio_propuesto)
    : null;

  let nivel = null;
  if (cad == null) nivel = "sin_fecha";
  else if (typeof dias === "number" && dias <= DIAS_CADUCIDAD_CRITICO) nivel = "critico";
  else if (typeof dias === "number" && dias <= DIAS_CADUCIDAD_ALERTA) nivel = "alerta";

  const cajasTxt = cantidad === 1 ? "1 caja" : `${cantidad} cajas`;
  const titulo = cad
    ? `Se vende primero: cad. ${etiquetaCad} · ${cajasTxt}`
    : `Se vende primero: sin MMAA · ${cajasTxt}`;

  let secundaria = null;
  if (ordered.length > 1) {
    const next = ordered[1];
    const nextCad = ymd(next.fecha_caducidad);
    const nextEt = nextCad ? etiquetaCaducidadIso(nextCad) : "sin MMAA";
    const nextQty = qtyLote(next);
    const extra = ordered.length - 2;
    secundaria =
      extra > 0
        ? `También: ${nextEt} · ${nextQty}` + (extra === 1 ? " y 1 lote más" : ` y ${extra} lotes más`)
        : `También: ${nextEt} · ${nextQty}`;
  }

  return {
    ok: true,
    sinVendible: false,
    titulo,
    secundaria,
    especial,
    nivel,
    dias,
    etiquetaCad,
    cantidad,
    totalLotes: ordered.length,
    loteId: head.id,
  };
}
