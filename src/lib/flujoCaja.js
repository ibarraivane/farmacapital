/** Flujo de caja v1 — helpers de pantalla. Las sumas viven en admin_flujo_caja_bundle. */

import { parseRpcJsonArray, parseRpcJsonObject } from "../utils/rpcJson";

/** Parte 8.7: primera sesión con fondo_contado > 0. Antes, total_general cuenta el cambio como venta. */
export const PISO_FONDO_FLUJO = "2026-08-18";

export const CLAVES_FINANZAS = Object.freeze({
  fechaInicio: "finanzas_fecha_inicio",
  saldoInicial: "finanzas_saldo_inicial",
  sinCompraMeses: "finanzas_sin_compra_meses",
});

export const MENSAJE_FLUJO_SIN_CONFIG =
  "No hay ninguna apertura de caja con fondo contado. El flujo usa esa primera apertura como semilla (no el fondo de hoy). Abre caja contando el cambio; no hace falta teclear un saldo en Ajustes.";

export function textoOrigenPiso(bundle) {
  const b = bundle || {};
  const fecha = b.piso_aplicado || b.fecha_inicio || b.piso_fondo || PISO_FONDO_FLUJO;
  const saldo = Number(b.saldo_inicial);
  const semilla = Number.isFinite(saldo)
    ? saldo.toLocaleString("es-MX", { style: "currency", currency: "MXN" })
    : "";
  if (b.origen_piso === "config") {
    return `Piso ${fecha}${semilla ? ` · semilla ${semilla}` : ""} (override en Metas y Precios). Entró = cortes. Nómina se teclea.`;
  }
  return `Piso ${fecha}${semilla ? ` · semilla ${semilla}` : ""} (primera apertura con fondo). Entró = cortes. Nómina se teclea: RRHH no tiene filas.`;
}

export function parseFlujoBundle(raw) {
  const b = parseRpcJsonObject(raw);
  const alertas = parseRpcJsonArray(b.alertas);
  const semanas = parseRpcJsonArray(b.semanas);
  const gastos = parseRpcJsonArray(b.gastos);
  const faltan = parseRpcJsonArray(b.faltan).map(String);
  const completitud = parseRpcJsonObject(b.completitud);
  const cubetas = parseRpcJsonObject(b.cubetas);
  const salio = parseRpcJsonObject(b.salio);
  return {
    ...b,
    configurado: b.configurado === true,
    alertas,
    semanas,
    gastos,
    faltan,
    completitud,
    cubetas,
    salio,
  };
}

export function flujoEstaConfigurado(bundle) {
  return bundle?.configurado === true;
}

export function mesesSinCompraDesdeValor(valor) {
  return String(valor || "")
    .split(",")
    .map((s) => s.trim())
    .filter((s) => /^\d{4}-\d{2}$/.test(s));
}

export function toggleMesSinCompra(valor, anioMes, marcar) {
  const set = new Set(mesesSinCompraDesdeValor(valor));
  const key = String(anioMes || "").slice(0, 7);
  if (!/^\d{4}-\d{2}$/.test(key)) return [...set].sort().join(",");
  if (marcar) set.add(key);
  else set.delete(key);
  return [...set].sort().join(",");
}

export function anioMesDe(iso) {
  return String(iso || "").slice(0, 7);
}

const MESES_ES = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"];

function partesYmd(iso) {
  const [y, m, d] = String(iso || "").slice(0, 10).split("-").map(Number);
  if (!y || !m || !d) return null;
  return { y, m, d };
}

export function labelSemana(lunesIso) {
  const a = partesYmd(lunesIso);
  if (!a) return String(lunesIso || "—");
  const fin = new Date(Date.UTC(a.y, a.m - 1, a.d + 6));
  const b = { y: fin.getUTCFullYear(), m: fin.getUTCMonth() + 1, d: fin.getUTCDate() };
  const ma = MESES_ES[a.m - 1];
  const mb = MESES_ES[b.m - 1];
  if (a.m === b.m) return `${a.d}–${b.d} ${ma}`;
  return `${a.d} ${ma} – ${b.d} ${mb}`;
}

export function textoCompletitud(completitud) {
  const c = completitud || {};
  if (c.incompleta === false) {
    return "Captura del período completa: hay nómina, renta y pago a proveedor (o marcaste “sin compra”).";
  }
  const faltan = [];
  if (!c.tiene_nomina) faltan.push("nómina");
  if (!c.tiene_renta) faltan.push("renta");
  if (!c.tiene_proveedor && !c.sin_compra) faltan.push("pago a proveedor");
  if (!faltan.length) {
    return "Captura incompleta — no es que hayas gastado $0.";
  }
  return `Captura incompleta (${faltan.join(", ")}) — no es que hayas gastado $0.`;
}

export function maxAbsSemanas(semanas, keys = ["entro", "medicamento", "nomina", "gastos"]) {
  let m = 0;
  for (const row of semanas || []) {
    for (const k of keys) {
      const n = Math.abs(Number(row?.[k]) || 0);
      if (n > m) m = n;
    }
  }
  return m;
}

export function pctBarra(valor, max) {
  const n = Math.abs(Number(valor) || 0);
  const top = Number(max) || 0;
  if (top <= 0) return 0;
  return Math.min(100, Math.round((n / top) * 1000) / 10);
}
