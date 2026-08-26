/** Ventas vs meta del dashboard. Fechas en calendario de la farmacia (CDMX). */

import { metaDiaCompleto } from "../utils/turnosMetas";

export const TZ_FARMACIA = "America/Mexico_City";

function pad2(n) {
  return String(n).padStart(2, "0");
}

export function ymdMexico(value = new Date()) {
  return new Date(value).toLocaleDateString("en-CA", { timeZone: TZ_FARMACIA });
}

/**
 * Minutos que la zona de la farmacia va por delante de UTC en ese instante.
 * Se calcula con Intl en vez de fijar -6 para que un cambio de horario en
 * México no rompa los cortes de día.
 */
function offsetMinutosFarmacia(date) {
  const dtf = new Intl.DateTimeFormat("en-US", {
    timeZone: TZ_FARMACIA,
    hour12: false,
    year: "numeric", month: "2-digit", day: "2-digit",
    hour: "2-digit", minute: "2-digit", second: "2-digit",
  });
  const p = {};
  for (const part of dtf.formatToParts(date)) p[part.type] = part.value;
  const comoUTC = Date.UTC(+p.year, +p.month - 1, +p.day, +p.hour % 24, +p.minute, +p.second);
  return (comoUTC - Math.floor(date.getTime() / 1000) * 1000) / 60000;
}

/**
 * Instante exacto en que empieza ese día del calendario de la farmacia.
 * Es la pieza que hace que "hoy" signifique lo mismo para las tarjetas de KPI
 * y para la gráfica, sin importar desde qué país se abra el dashboard.
 */
export function inicioDiaFarmacia(ymd) {
  const [y, m, d] = String(ymd || "").split("-").map(Number);
  if (!y || !m || !d) return null;
  const tentativo = Date.UTC(y, m - 1, d, 0, 0, 0);
  let ts = tentativo - offsetMinutosFarmacia(new Date(tentativo)) * 60000;
  ts = tentativo - offsetMinutosFarmacia(new Date(ts)) * 60000; // 2ª pasada: cambios de horario
  return new Date(ts);
}

/** Día del calendario de la farmacia desplazado n días (n negativo = atrás). */
export function ymdFarmaciaMas(dias, base = new Date()) {
  const inicio = inicioDiaFarmacia(ymdMexico(base));
  if (!inicio) return ymdMexico(base);
  return ymdMexico(new Date(inicio.getTime() + dias * 86400000 + 12 * 3600000));
}

/** Rango ISO [00:00, 23:59:59.999] de ese día en la farmacia. */
export function rangoDiaFarmacia(ymd) {
  const start = inicioDiaFarmacia(ymd);
  if (!start) return null;
  const siguiente = inicioDiaFarmacia(ymdFarmaciaMas(1, start));
  return { start: start.toISOString(), end: new Date(siguiente.getTime() - 1).toISOString() };
}

/** Primer día del mes en curso según el calendario de la farmacia. */
export function inicioMesFarmaciaYmd(base = new Date()) {
  return `${ymdMexico(base).slice(0, 8)}01`;
}

/** Fracción del mes ya transcurrida (0..1) según el calendario de la farmacia. */
export function fraccionMesFarmacia(base = new Date()) {
  const [y, m, d] = ymdMexico(base).split("-").map(Number);
  const diasDelMes = new Date(Date.UTC(y, m, 0)).getUTCDate();
  return Math.min(Math.max(d / diasDelMes, 0.01), 1);
}

/** Fecha larga de mostrador (CDMX), para encabezados. */
export function fmtDateMexico(value = new Date()) {
  return new Date(value).toLocaleDateString("es-MX", {
    timeZone: TZ_FARMACIA, weekday: "long", day: "2-digit", month: "long", year: "numeric",
  });
}

/** Fecha/hora de mostrador (CDMX). Evita que desde Europa el ticket salte al día siguiente. */
export function fmtDateTimeMexico(s) {
  if (!s) return "—";
  const d = s instanceof Date ? s : new Date(s);
  if (Number.isNaN(d.getTime())) return "—";
  const fecha = d.toLocaleDateString("es-MX", { timeZone: TZ_FARMACIA, day: "2-digit", month: "short" });
  const hora = d.toLocaleTimeString("es-MX", { timeZone: TZ_FARMACIA, hour: "2-digit", minute: "2-digit" });
  return `${fecha} ${hora}`;
}

export function parseYmdLocal(ymd) {
  const [y, m, d] = String(ymd || "").split("-").map(Number);
  if (!y || !m || !d) return null;
  return new Date(y, m - 1, d);
}

export function ymdFromLocalDate(d) {
  return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`;
}

export function agruparVentasPorDia(pedidos) {
  const out = {};
  for (const p of pedidos || []) {
    if (!p?.created_at) continue;
    const dia = ymdMexico(p.created_at);
    out[dia] = (out[dia] || 0) + (parseFloat(p.total) || 0);
  }
  return out;
}

export function porDiaDesdeSerieRpc(raw) {
  const rows = Array.isArray(raw) ? raw : [];
  const out = {};
  for (const r of rows) {
    const dia = String(r.dia || r.fecha || "").slice(0, 10);
    if (!dia) continue;
    out[dia] = (out[dia] || 0) + (parseFloat(r.total) || 0);
  }
  return out;
}

function lunesDe(d) {
  const x = new Date(d.getFullYear(), d.getMonth(), d.getDate());
  const dow = x.getDay();
  x.setDate(x.getDate() + (dow === 0 ? -6 : 1 - dow));
  return x;
}

function addDays(d, n) {
  const x = new Date(d.getFullYear(), d.getMonth(), d.getDate());
  x.setDate(x.getDate() + n);
  return x;
}

const DIAS_CORTOS = ["dom", "lun", "mar", "mié", "jue", "vie", "sáb"];
const MES_CORTOS = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"];

export function metaSemana(lunes, cfg) {
  let t = 0;
  for (let i = 0; i < 7; i += 1) t += metaDiaCompleto(addDays(lunes, i), cfg);
  return t;
}

export function construirSerie({ porDia, cfg, grano, hoyYmd }) {
  const hoy = parseYmdLocal(hoyYmd) || new Date();
  const map = porDia || {};
  const points = [];

  if (grano === "semana") {
    const esteLunes = lunesDe(hoy);
    for (let w = 7; w >= 0; w -= 1) {
      const lunes = addDays(esteLunes, -7 * w);
      const domingo = addDays(lunes, 6);
      let actual = 0;
      for (let i = 0; i < 7; i += 1) actual += map[ymdFromLocalDate(addDays(lunes, i))] || 0;
      const meta = metaSemana(lunes, cfg);
      points.push({
        key: ymdFromLocalDate(lunes),
        label: `${lunes.getDate()} ${MES_CORTOS[lunes.getMonth()]}`,
        detalle: `${lunes.getDate()}–${domingo.getDate()} ${MES_CORTOS[domingo.getMonth()]}`,
        actual,
        meta,
        esActual: ymdFromLocalDate(lunes) === ymdFromLocalDate(esteLunes),
      });
    }
    return points;
  }

  if (grano === "mes") {
    const metaMes = Math.round(parseFloat(cfg?.meta_ventas_mes || 0) || 0);
    for (let i = 5; i >= 0; i -= 1) {
      const d = new Date(hoy.getFullYear(), hoy.getMonth() - i, 1);
      const y = d.getFullYear();
      const m = d.getMonth();
      const prefix = `${y}-${pad2(m + 1)}-`;
      let actual = 0;
      for (const [dia, tot] of Object.entries(map)) {
        if (dia.startsWith(prefix)) actual += tot;
      }
      points.push({
        key: prefix.slice(0, 7),
        label: `${MES_CORTOS[m]} ${String(y).slice(2)}`,
        detalle: `${MES_CORTOS[m]} ${y}`,
        actual,
        meta: metaMes,
        esActual: y === hoy.getFullYear() && m === hoy.getMonth(),
      });
    }
    return points;
  }

  for (let i = 20; i >= 0; i -= 1) {
    const d = addDays(hoy, -i);
    const ymd = ymdFromLocalDate(d);
    points.push({
      key: ymd,
      label: DIAS_CORTOS[d.getDay()],
      detalle: `${DIAS_CORTOS[d.getDay()]} ${d.getDate()} ${MES_CORTOS[d.getMonth()]}`,
      actual: map[ymd] || 0,
      meta: metaDiaCompleto(d, cfg),
      esActual: ymd === hoyYmd,
    });
  }
  return points;
}

export function resumenPunto(p) {
  if (!p) return { pct: 0, falta: 0, ok: false };
  const meta = p.meta || 0;
  const actual = p.actual || 0;
  const pct = meta > 0 ? (actual / meta) * 100 : 0;
  return { pct, falta: Math.max(0, meta - actual), ok: meta > 0 && actual >= meta };
}

/** Hoy / semana en curso / mes en curso, para las fichas de Transacciones. */
export function resumenMetasActuales({ porDia, cfg, hoyYmd }) {
  const hoy = hoyYmd || ymdMexico();
  const pick = (grano) => construirSerie({ porDia, cfg, grano, hoyYmd: hoy }).find((p) => p.esActual) || null;
  return {
    dia: pick("dia"),
    semana: pick("semana"),
    mes: pick("mes"),
  };
}
