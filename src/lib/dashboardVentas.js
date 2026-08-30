/** Totales del Dashboard: un solo calendario (día civil CDMX) y ventas netas. */

import { addDaysISO, hoyISOMexico, lunesISODe, rangoDiaMexico } from "./fecha";

/** Último instante inclusive de un rango [start, end) para RPCs que usan `<= fin`. */
export function finInclusivoIso(endExclusiveIso) {
  const ms = new Date(endExclusiveIso).getTime();
  if (!Number.isFinite(ms)) return endExclusiveIso;
  return new Date(ms - 1).toISOString();
}

export function rangosDashboardMexico(now = new Date()) {
  const hoy = hoyISOMexico(now);
  const ayer = addDaysISO(hoy, -1);
  const today = rangoDiaMexico(hoy);
  const yesterday = rangoDiaMexico(ayer);
  const lunes = lunesISODe(hoy);
  const lunesAnt = addDaysISO(lunes, -7);
  const inicioMes = `${hoy.slice(0, 7)}-01`;
  const finMesAnt = addDaysISO(inicioMes, -1);
  const inicioMesAnt = `${finMesAnt.slice(0, 7)}-01`;
  return {
    hoy,
    ayer,
    lunes,
    lunesAnt,
    inicioMes,
    finMesAnt,
    inicioMesAnt,
    today,
    yesterday,
    week: { start: rangoDiaMexico(lunes).start, end: today.end },
    weekPrev: {
      start: rangoDiaMexico(lunesAnt).start,
      end: rangoDiaMexico(addDaysISO(lunes, -1)).end,
    },
    month: { start: rangoDiaMexico(inicioMes).start, end: today.end },
    monthPrev: {
      start: rangoDiaMexico(inicioMesAnt).start,
      end: rangoDiaMexico(finMesAnt).end,
    },
  };
}

/**
 * Resumen / margen: mismas ventanas que Operación.
 * Antes "Hoy" era las últimas 24 h (metía la tarde de ayer) y "mes" eran 30 días rodantes.
 */
export function rangoReporteMexico(periodo, now = new Date()) {
  const r = rangosDashboardMexico(now);
  if (periodo === "dia") {
    return { desde: r.today.start, hasta: r.today.end, desdeFecha: r.hoy, hastaFecha: r.hoy };
  }
  if (periodo === "semana") {
    return { desde: r.week.start, hasta: r.today.end, desdeFecha: r.lunes, hastaFecha: r.hoy };
  }
  return { desde: r.month.start, hasta: r.today.end, desdeFecha: r.inicioMes, hastaFecha: r.hoy };
}

export function sumPorDiaYmd(porDia, desdeYmd, hastaYmd) {
  let t = 0;
  for (const [dia, tot] of Object.entries(porDia || {})) {
    if (dia >= desdeYmd && dia <= hastaYmd) t += Number(tot) || 0;
  }
  return t;
}

export function sumPedidosTotal(pedidos) {
  return (pedidos || []).reduce((a, p) => a + (parseFloat(p.total || p.suma || 0) || 0), 0);
}

/**
 * Serie RPC → totales por día civil.
 * `porDia` es neto (bruto − devoluciones del mismo día) si el RPC manda `devoluciones`.
 */
export function serieVentasDesdeRpc(raw) {
  const rows = Array.isArray(raw) ? raw : [];
  const porDia = {};
  const tickets = {};
  const brutas = {};
  const devoluciones = {};
  for (const r of rows) {
    const dia = String(r?.dia || r?.fecha || "").slice(0, 10);
    if (!dia) continue;
    const bruto = parseFloat(r.total) || 0;
    const dev = parseFloat(r.devoluciones ?? r.devs ?? 0) || 0;
    brutas[dia] = (brutas[dia] || 0) + bruto;
    devoluciones[dia] = (devoluciones[dia] || 0) + dev;
    porDia[dia] = (porDia[dia] || 0) + bruto - dev;
    tickets[dia] = (tickets[dia] || 0) + (parseInt(r.tickets, 10) || 0);
  }
  return { porDia, tickets, brutas, devoluciones };
}
