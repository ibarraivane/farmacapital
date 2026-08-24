'use strict';

const { inventarioProcesarPdfHandler } = require('../lib/inventarioProcesarPdfHandler');
const { buscarSimilaresHandler } = require('./_lib/buscarSimilaresHandler');
const { actualizarCompraHandler } = require('./_lib/actualizarCompraHandler');
const { pagoServicioAdminHandler } = require('./_lib/pagoServicioAdminHandler');
const { recepcionAbiertasHandler } = require('./_lib/recepcionAbiertasHandler');
const { ultimaCompraHandler } = require('./_lib/ultimaCompraHandler');

module.exports = async function handler(req, res) {
  const bodyType = (req.body && typeof req.body === 'object') ? req.body.type : '';
  const type = String(req.query?.type || bodyType || '').trim();
  if (type === 'buscar-similares') {
    return buscarSimilaresHandler(req, res);
  }
  if (type === 'actualizar-compra') {
    return actualizarCompraHandler(req, res);
  }
  if (type === 'pago-servicio') {
    return pagoServicioAdminHandler(req, res);
  }
  if (type === 'recepcion-abiertas') {
    return recepcionAbiertasHandler(req, res);
  }
  if (type === 'ultima-compra') {
    return ultimaCompraHandler(req, res);
  }
  if (req.method === 'GET') {
    return res.status(200).json({ ok: true, route: 'inventarioProcesarPdf' });
  }
  return inventarioProcesarPdfHandler(req, res);
};
