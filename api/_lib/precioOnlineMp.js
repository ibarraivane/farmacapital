'use strict';

/** Espejo de src/lib/precioOnlineMp.js y de public.fc_precio_online_mp(numeric). */
const TASA_MP_ONLINE = 0.040484;
const FIJO_MP_MXN = 4;
const IVA_MP = 1.16;
const FIJO_MP_CON_IVA = FIJO_MP_MXN * IVA_MP;
const CARGO_SERVICIO_MXN = 5;
const PRECIO_PLACEHOLDER_MAX = 0.01;
const CONCEPTO_CARGO_PLATAFORMA = 'Servicio';

function precioAnclaUsable(precio) {
  const n = Number(precio);
  return Number.isFinite(n) && n > PRECIO_PLACEHOLDER_MAX;
}

function precioOnlineMp(precioLista) {
  if (!precioAnclaUsable(precioLista)) return null;
  const bruto = Number(precioLista) / (1 - TASA_MP_ONLINE);
  return Math.ceil(Math.round(bruto * 100) / 100);
}

function cargoPlataformaOnline() {
  return CARGO_SERVICIO_MXN;
}

function cargoFijoMp() {
  return cargoPlataformaOnline();
}

function totalPedidoConPlataforma(subProductos) {
  const b = Number(subProductos);
  if (!Number.isFinite(b) || b <= 0) return null;
  return Math.round(b + cargoPlataformaOnline());
}

function totalConCargoMp(base) {
  return totalPedidoConPlataforma(base);
}

module.exports = {
  TASA_MP_ONLINE,
  FIJO_MP_MXN,
  IVA_MP,
  FIJO_MP_CON_IVA,
  CARGO_SERVICIO_MXN,
  PRECIO_PLACEHOLDER_MAX,
  CONCEPTO_CARGO_PLATAFORMA,
  precioAnclaUsable,
  precioOnlineMp,
  cargoPlataformaOnline,
  cargoFijoMp,
  totalPedidoConPlataforma,
  totalConCargoMp,
};
