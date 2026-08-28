'use strict';

const { inventarioProcesarPdfHandler } = require('../lib/inventarioProcesarPdfHandler');
const { pagoServicioAdminHandler } = require('./_lib/pagoServicioAdminHandler');
const { ultimaCompraHandler } = require('./_lib/ultimaCompraHandler');
const { buscarRappiHandler } = require('./_lib/buscarRappiHandler');
const { buscarSimilaresHandler } = require('./_lib/buscarSimilaresHandler');
const { actualizarCompraHandler } = require('./_lib/actualizarCompraHandler');
const { nadroSyncHandler } = require('./_lib/nadroSyncHandler');

module.exports = async function handler(req, res) {
  const type = String(req.query?.type || '').trim();
  if (type === 'pago-servicio') {
    return pagoServicioAdminHandler(req, res);
  }
  if (type === 'ultima-compra') {
    return ultimaCompraHandler(req, res);
  }
  if (type === 'buscar-rappi') {
    return buscarRappiHandler(req, res);
  }
  if (type === 'buscar-similares') {
    return buscarSimilaresHandler(req, res);
  }
  if (type === 'actualizar-compra') {
    return actualizarCompraHandler(req, res);
  }
  if (type === 'nadro-sync') {
    return nadroSyncHandler(req, res);
  }
  if (req.method === 'GET') {
    return res.status(200).json({ ok: true, route: 'inventarioProcesarPdf' });
  }
  return inventarioProcesarPdfHandler(req, res);
};
