'use strict';

module.exports = async function handler(req, res) {
  return res.status(503).json({ error: 'cargar-productos en redeploy' });
};
