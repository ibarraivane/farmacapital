/** Ventas vs meta del dashboard. Fechas en calendario de la farmacia (CDMX). */

import { metaDiaCompleto } from "../utils/turnosMetas";
import {
  TZ_FARMACIA,
  addDaysISO,
  rangoDiaMexico,
  ymdLocalDate,
  ymdMexico as ymdMexicoFecha,
} from "./fecha";
import { serieVentasDesdeRpc } from "./dashboardVentas";
import { metasDelPeriodo } from "./metasDelPeriodo";

export { TZ_FARMACIA };
export function ymdMexico(value = new Date()) {
  return ymdMexicoFecha(value);
}

/** Instante de inicio del día civil de farmacia (para Admin / KPIs). */
export function inicioDiaFarmacia(ymd) {
  const r = rangoDiaMexico(ymd);
  return r?.start ? new Date(r.start) : null;
}

/** Día del calendario de la farmacia desplazado n días. */
export function ymdFarmaciaMas(dias, base = new Date()) {
  return addDaysISO(ymdMexico(base), Number(dias) || 0);
}

/**
 * Rango ISO del día en farmacia.
 * Admin espera end inclusivo (último ms); fecha.rangoDiaMexico usa [start, end).
 */
export function rangoDiaFarmacia(ymd) {
  const r = rangoDiaMexico(ymd);
  if (!r?.start || !r?.end) return null;
  return { start: r.start, end: new Date(new Date(r.end).getTime() - 1).toISOString() };
}

export function inicioMesFarmaciaYmd(base = new Date()) {
  return `${ymdMexico(base).slice(0, 8)}01`;
}

export function fraccionMesFarmacia(base = new Date()) {
  const [y, m, d] = ymdMexico(base).split("-").map(Number);
  const diasDelMes = new Date(Date.UTC(y, m, 0)).getUTCDate();
  return Math.min(Math.max(d / diasDelMes, 0.01), 1);
}

export function fmtDateMexico(value = new Date()) {
  return new Date(value).toLocaleDateString("es-MX", {
    timeZone: TZ_FARMACIA,
    weekday: "long",
    day: "2-digit",
    month: "long",
    year: "numeric",
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
  return ymdLocalDate(d);
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
  return serieVentasDesdeRpc(raw).porDia;
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

function pad2(n) {
  return String(n).padStart(2, "0");
}

const DIAS_CORTOS = ["dom", "lun", "mar", "mié", "jue", "vie", "sáb"];
const MES_CORTOS = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"];

export function metaSemana(lunes, cfg) {
  let t = 0;
  for (let i = 0; i < 7; i += 1) t += metaDiaCompleto(addDays(lunes, i), cfg);
  return t;
}

export function fmtMiles(n) {
  const v = parseFloat(n || 0);
  const sign = v < 0 ? "-" : "";
  const a = Math.abs(v);
  if (a >= 1000) return `${sign}$${(a / 1000).toFixed(1)}k`;
  return `${sign}$${Math.round(a).toLocaleString("es-MX")}`;
}

function sumarMapa(map, pred) {
  if (!map) return null;
  let t = 0;
  for (const [dia, tot] of Object.entries(map)) {
    if (!pred(dia)) continue;
    const n = Number(tot);
    if (Number.isFinite(n)) t += n;
  }
  return t;
}

function gananciaDia(map, ymd) {
  if (!map) return null;
  const n = Number(map[ymd]);
  return Number.isFinite(n) ? n : 0;
}

export function construirSerie({ porDia, gananciaPorDia, cfg, grano, hoyYmd, ventana }) {
  const hoy = parseYmdLocal(hoyYmd) || new Date();
  const map = porDia || {};
  const gan = gananciaPorDia || null;
  const points = [];

  if (grano === "semana") {
    const esteLunes = lunesDe(hoy);
    for (let w = 7; w >= 0; w -= 1) {
      const lunes = addDays(esteLunes, -7 * w);
      const domingo = addDays(lunes, 6);
      const claves = [];
      let actual = 0;
      for (let i = 0; i < 7; i += 1) {
        const ymd = ymdFromLocalDate(addDays(lunes, i));
        claves.push(ymd);
        actual += map[ymd] || 0;
      }
      const metaFija = Math.round(parseFloat(cfg?.meta_ventas_semana || 0) || 0);
      const meta = metaFija > 0 ? metaFija : metaSemana(lunes, cfg);
      points.push({
        key: ymdFromLocalDate(lunes),
        label: `${lunes.getDate()} ${MES_CORTOS[lunes.getMonth()]}`,
        detalle: `${lunes.getDate()}–${domingo.getDate()} ${MES_CORTOS[domingo.getMonth()]}`,
        actual,
        ganancia: gan ? sumarMapa(gan, (dia) => claves.includes(dia)) : null,
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
        ganancia: gan ? sumarMapa(gan, (dia) => dia.startsWith(prefix)) : null,
        meta: metaMes,
        esActual: y === hoy.getFullYear() && m === hoy.getMonth(),
      });
    }
    return points;
  }

  const dias = Number.isFinite(ventana) && ventana > 0 ? Math.round(ventana) : 21;
  for (let i = dias - 1; i >= 0; i -= 1) {
    const d = addDays(hoy, -i);
    const ymd = ymdFromLocalDate(d);
    points.push({
      key: ymd,
      label: DIAS_CORTOS[d.getDay()],
      labelDia: String(d.getDate()),
      detalle: `${DIAS_CORTOS[d.getDay()]} ${d.getDate()} ${MES_CORTOS[d.getMonth()]}`,
      actual: map[ymd] || 0,
      ganancia: gananciaDia(gan, ymd),
      meta: metaDiaCompleto(d, cfg),
      esActual: ymd === hoyYmd,
    });
  }
  return points;
}

/**
 * La tarjeta prorratea. Un domingo de los primeros días del mes muestra la
 * semana completa y solo una rebanada del mes, así que el número semanal
 * queda arriba aunque la meta del mes configurada sea mayor.
 */
export function notaCruceSemanaMes({ semana, mes, hoyYmd }) {
  if (!semana || !mes) return "";
  const metaSem = Number(semana.meta) || 0;
  const metaMes = Number(mes.meta) || 0;
  const ventaSem = Number(semana.actual) || 0;
  const ventaMes = Number(mes.actual) || 0;
  const mesFull = Number(mes.metaCompleta) || 0;
  const semFull = Number(semana.metaCompleta) || metaSem;
  if (metaSem <= metaMes && ventaSem <= ventaMes) return "";

  const d = parseYmdLocal(hoyYmd);
  const dia = d ? d.getDate() : null;
  const dias = d ? new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate() : null;
  const partes = [];
  if (ventaSem > ventaMes) {
    partes.push("La semana (lunes a domingo) incluye días del mes anterior, por eso su venta puede ser más alta que la del mes.");
  }
  if (metaSem > metaMes && mesFull > metaSem) {
    const ritmo = dia && dias
      ? `Los ${fmtMiles(metaMes)} de «Este mes» son el ritmo al día ${dia} de ${dias}`
      : `Los ${fmtMiles(metaMes)} de «Este mes» son el ritmo de los días que ya van`;
    partes.push(`${ritmo}, no la meta. La meta del mes es ${fmtMiles(mesFull)} y la de la semana es ${fmtMiles(semFull)}.`);
  } else if (metaSem > metaMes) {
    partes.push("El número de la tarjeta es lo que toca a la fecha, no la meta completa del periodo.");
  }
  return partes.join(" ");
}

export function resumenPunto(p) {
  if (!p) return { pct: 0, falta: 0, ok: false };
  const meta = p.meta || 0;
  const actual = p.actual || 0;
  const pct = meta > 0 ? (actual / meta) * 100 : 0;
  return { pct, falta: Math.max(0, meta - actual), ok: meta > 0 && actual >= meta };
}

/** Hoy / semana en curso / mes en curso — mismas metas que InsightCard (prorrateadas). */
export function resumenMetasActuales({ porDia, gananciaPorDia, cfg, hoyYmd }) {
  const hoy = hoyYmd || ymdMexico();
  const d = parseYmdLocal(hoy) || new Date();
  const metas = metasDelPeriodo(d, cfg);
  const pick = (grano) => construirSerie({
    porDia,
    gananciaPorDia,
    cfg,
    grano,
    hoyYmd: hoy,
  }).find((p) => p.esActual) || null;
  const dia = pick("dia");
  const semana = pick("semana");
  const mes = pick("mes");
  return {
    dia: dia ? { ...dia, meta: metas.dia, metaCompleta: metas.dia, fraccion: 1 } : null,
    semana: semana ? {
      ...semana,
      meta: metas.semana,
      metaCompleta: metas.semanaCompleta,
      fraccion: metas.fracSemana,
    } : null,
    mes: mes ? {
      ...mes,
      meta: metas.mes,
      metaCompleta: metas.mesCompleto,
      fraccion: metas.fracMes,
    } : null,
  };
}
