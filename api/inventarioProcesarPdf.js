'use strict';

const { inventarioProcesarPdfHandler } = require('../lib/inventarioProcesarPdfHandler');
const { buscarSimilaresHandler } = require('./_lib/buscarSimilaresHandler');
const { actualizarCompraHandler } = require('./_lib/actualizarCompraHandler');
const { pagoServicioAdminHandler } = require('./_lib/pagoServicioAdminHandler');

module.exports = async function handler(req, res) {
  const type = String(req.query?.type || '').trim();
  if (type === 'buscar-similares') {
    return buscarSimilaresHandler(req, res);
  }
  if (type === 'actualizar-compra') {
    return actualizarCompraHandler(req, res);
  }
  if (type === 'pago-servicio') {
    return pagoServicioAdminHandler(req, res);
  }
  if (req.method === 'GET') {
    return res.status(200).json({ ok: true, route: 'inventarioProcesarPdf' });
  }
  return inventarioProcesarPdfHandler(req, res);
};
