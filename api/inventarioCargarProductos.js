'use strict';

const { inventarioProcesarPdfHandler } = require('../lib/inventarioProcesarPdfHandler');

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  let body = req.body;
  if (typeof body === 'string') {
    try {
      body = JSON.parse(body);
    } catch {
      body = {};
    }
  }
  if (!body || typeof body !== 'object') body = {};

  if (!Array.isArray(body.productos) || !body.productos.length) {
    return res.status(400).json({
      error: 'Se requiere arreglo productos con al menos un elemento',
    });
  }

  req.body = { ...body, archivo_base64: undefined };
  return inventarioProcesarPdfHandler(req, res);
};
