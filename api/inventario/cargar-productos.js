'use strict';

/**
 * POST /api/inventario/cargar-productos
 * Carga productos ya extraídos (JSON) sin usar Claude Vision.
 * Misma inserción atómica vía create_producto_con_oferta().
 */
const procesarPdfHandler = require('./procesar-pdf');

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

  // Reutiliza el handler principal (modo JSON, sin PDF).
  req.body = {
    ...body,
    archivo_base64: undefined,
  };

  return procesarPdfHandler(req, res);
};
