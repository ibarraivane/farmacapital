'use strict';

const { inventarioProcesarPdfHandler } = require('../lib/inventarioProcesarPdfHandler');

module.exports = async function handler(req, res) {
  if (req.method === 'GET') {
    return res.status(200).json({ ok: true, route: 'inventarioProcesarPdf' });
  }
  return inventarioProcesarPdfHandler(req, res);
};
