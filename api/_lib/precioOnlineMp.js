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

function esEntregaConServicio(entrega) {
  const t = String(entrega || '').trim().toLowerCase();
  return t === 'envio' || t === 'cdmx' || t === 'foraneo';
}

function cargoPlataformaOnline(entrega) {
  if (entrega !== undefined && !esEntregaConServicio(entrega)) return 0;
  if (entrega === undefined) return CARGO_SERVICIO_MXN;
  return CARGO_SERVICIO_MXN;
}

function cargoFijoMp(entrega) {
  return cargoPlataformaOnline(entrega);
}

function totalPedidoConPlataforma(subProductos, entrega) {
  const b = Number(subProductos);
  if (!Number.isFinite(b) || b <= 0) return null;
  return Math.round(b + cargoPlataformaOnline(entrega));
}

function totalConCargoMp(base, entrega) {
  return totalPedidoConPlataforma(base, entrega);
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
  esEntregaConServicio,
  cargoPlataformaOnline,
  cargoFijoMp,
  totalPedidoConPlataforma,
  totalConCargoMp,
};
