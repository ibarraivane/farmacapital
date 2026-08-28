/** Costo vs ganancia por día de mostrador (CDMX). */

import { costoLineaVenta, ingresoLineaVenta } from "../utils/margenVenta";
import { ymdMexico } from "./ventasVsMeta";

const DIAS_CORTOS = ["dom", "lun", "mar", "mié", "jue", "vie", "sáb"];
const MES_CORTOS = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"];

function money(n) {
  return Math.round((Number(n) || 0) * 100) / 100;
}

function partesYmd(ymd) {
  const [y, m, d] = String(ymd || "").split("-").map(Number);
  if (!y || !m || !d) return null;
  return { y, m, d, date: new Date(y, m - 1, d) };
}

function ymdMasUno(ymd) {
  const p = partesYmd(ymd);
  if (!p) return ymd;
  const next = new Date(p.y, p.m - 1, p.d + 1);
  const mm = String(next.getMonth() + 1).padStart(2, "0");
  const dd = String(next.getDate()).padStart(2, "0");
  return `${next.getFullYear()}-${mm}-${dd}`;
}

/** El bundle trae fecha en `peds` y renglones en `peds_cat`, mismo orden. */
export function adjuntarFechaPedidos(pedsCat, peds) {
  return (pedsCat || []).map((ped, i) => ({
    ...ped,
    created_at: ped.created_at || peds?.[i]?.created_at || null,
  }));
}

export function agruparCostoGananciaPorDia(pedsCat, peds) {
  const byDay = {};
  for (const ped of adjuntarFechaPedidos(pedsCat, peds)) {
    if (!ped.created_at) continue;
    const dia = ymdMexico(ped.created_at);
    if (!byDay[dia]) byDay[dia] = { ymd: dia, ingreso: 0, costo: 0, ganancia: 0 };
    for (const item of ped.productos || []) {
      const ingreso = ingresoLineaVenta(item);
      const costo = costoLineaVenta(item);
      byDay[dia].ingreso += ingreso;
      byDay[dia].costo += costo;
      byDay[dia].ganancia += ingreso - costo;
    }
  }
  for (const d of Object.values(byDay)) {
    d.ingreso = money(d.ingreso);
    d.costo = money(d.costo);
    d.ganancia = money(d.ganancia);
  }
  return byDay;
}

export function totalesCostoGanancia(porDia) {
  let ingreso = 0;
  let costo = 0;
  for (const d of Object.values(porDia || {})) {
    ingreso += d.ingreso || 0;
    costo += d.costo || 0;
  }
  const ganancia = ingreso - costo;
  return {
    ingreso: money(ingreso),
    costo: money(costo),
    ganancia: money(ganancia),
    margenPct: ingreso > 0 ? money((ganancia / ingreso) * 100) : 0,
  };
}

/** Rellena días vacíos del filtro (hoy / 7 / 30) en calendario de farmacia. */
export function serieCostoGanancia({ porDia, dias = 30, hoyYmd }) {
  const hoy = hoyYmd || ymdMexico();
  const n = Math.max(1, Math.min(90, Number(dias) || 30));
  let ymd = hoy;
  for (let i = 1; i < n; i += 1) {
    const p = partesYmd(ymd);
    if (!p) break;
    const prev = new Date(p.y, p.m - 1, p.d - 1);
    const mm = String(prev.getMonth() + 1).padStart(2, "0");
    const dd = String(prev.getDate()).padStart(2, "0");
    ymd = `${prev.getFullYear()}-${mm}-${dd}`;
  }
  const points = [];
  let cursor = ymd;
  while (cursor <= hoy) {
    const p = partesYmd(cursor);
    const src = porDia?.[cursor] || {};
    const ingreso = money(src.ingreso);
    const costo = money(src.costo);
    const ganancia = money(src.ganancia ?? ingreso - costo);
    points.push({
      key: cursor,
      label: n > 10 ? String(p?.d || "") : `${DIAS_CORTOS[p?.date.getDay() || 0]} ${p?.d || ""}`.trim(),
      detalle: p
        ? `${DIAS_CORTOS[p.date.getDay()]} ${p.d} ${MES_CORTOS[p.m - 1]}`
        : cursor,
      ingreso,
      costo,
      ganancia,
      esActual: cursor === hoy,
    });
    cursor = ymdMasUno(cursor);
  }
  return points;
}
