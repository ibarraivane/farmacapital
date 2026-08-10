'use strict';

/** Deploy probe — sin dependencias externas. */
module.exports = async function handler(req, res) {
  if (req.method === 'GET') {
    return res.status(200).json({ ok: true, route: 'inventario-procesar-pdf', v: '81da8b9-probe' });
  }
  return res.status(503).json({
    error: 'Endpoint en redeploy. Intenta en 2 minutos.',
    hint: 'Si ves este JSON, el deploy de Vercel ya funciona.',
  });
};
