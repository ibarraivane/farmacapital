'use strict';

/** Espejo de src/lib/precioOnlineMp.js y de public.fc_precio_online_mp(numeric). */
const TASA_MP_ONLINE = 0.040484;
const PRECIO_PLACEHOLDER_MAX = 0.01;

function precioAnclaUsable(precio) {
  const n = Number(precio);
  return Number.isFinite(n) && n > PRECIO_PLACEHOLDER_MAX;
}

function precioOnlineMp(precioLista) {
  if (!precioAnclaUsable(precioLista)) return null;
  const bruto = Number(precioLista) / (1 - TASA_MP_ONLINE);
  return Math.ceil(Math.round(bruto * 100) / 100);
}

module.exports = { TASA_MP_ONLINE, PRECIO_PLACEHOLDER_MAX, precioAnclaUsable, precioOnlineMp };
