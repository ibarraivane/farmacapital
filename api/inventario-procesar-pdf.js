'use strict';

/** Ping mínimo — confirma que la ruta existe en Vercel. */
module.exports = async function handler(req, res) {
  if (req.method === 'GET') {
    return res.status(200).json({ ok: true, route: 'inventario-procesar-pdf', v: '250fe9e' });
  }
  return require('./_lib/inventarioProcesarPdfHandler').inventarioProcesarPdfHandler(req, res);
};
