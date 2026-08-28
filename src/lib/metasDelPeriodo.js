/**
 * Una sola definición de meta día / semana / mes para tarjetas y strip.
 * Día: metaDiaCompleto (ajustes por DOW/fecha).
 * Semana y mes en curso: prorrateo por días transcurridos (lun–dom / 1–fin de mes).
 */

import { metaDiaCompleto, mezclarCfgMetas } from "../utils/turnosMetas";

function addDaysLocal(d, n) {
  const x = new Date(d.getFullYear(), d.getMonth(), d.getDate());
  x.setDate(x.getDate() + n);
  return x;
}

function lunesDe(d) {
  const x = new Date(d.getFullYear(), d.getMonth(), d.getDate());
  const dow = x.getDay();
  x.setDate(x.getDate() + (dow === 0 ? -6 : 1 - dow));
  return x;
}

/** Índice 1..7 dentro de la semana lunes–domingo. */
export function diaEnSemanaLunDom(fecha) {
  const dow = fecha.getDay();
  return dow === 0 ? 7 : dow;
}

export function fraccionSemanaTranscurrida(fecha) {
  return diaEnSemanaLunDom(fecha) / 7;
}

export function fraccionMesTranscurrida(fecha) {
  const dia = fecha.getDate();
  const fin = new Date(fecha.getFullYear(), fecha.getMonth() + 1, 0).getDate();
  return Math.min(Math.max(dia / fin, 1 / fin), 1);
}

/** Suma de metaDiaCompleto lun→dom de la semana que contiene `fecha`. */
export function metaSemanaPorDias(fecha, cfg) {
  const lunes = lunesDe(fecha);
  let t = 0;
  for (let i = 0; i < 7; i += 1) t += metaDiaCompleto(addDaysLocal(lunes, i), cfg);
  return t;
}

/**
 * @param {Date|string|number} fecha
 * @param {object|array} cfg mapa o filas de configuracion
 * @returns {{ dia: number, semana: number, mes: number, fracSemana: number, fracMes: number }}
 */
export function metasDelPeriodo(fecha, cfg) {
  const d = fecha instanceof Date ? new Date(fecha.getFullYear(), fecha.getMonth(), fecha.getDate()) : new Date(fecha);
  if (Number.isNaN(d.getTime())) {
    return { dia: 0, semana: 0, mes: 0, fracSemana: 0, fracMes: 0 };
  }
  const map = mezclarCfgMetas(cfg);
  const dia = metaDiaCompleto(d, map);

  const metaSemanaFull =
    Math.round(parseFloat(map.meta_ventas_semana || 0) || 0) || metaSemanaPorDias(d, map);
  const fracSemana = fraccionSemanaTranscurrida(d);
  const semana = Math.round(metaSemanaFull * fracSemana);

  const metaMesFull = Math.round(parseFloat(map.meta_ventas_mes || 0) || 0);
  const fracMes = fraccionMesTranscurrida(d);
  const mes = Math.round(metaMesFull * fracMes);

  return { dia, semana, mes, fracSemana, fracMes };
}
