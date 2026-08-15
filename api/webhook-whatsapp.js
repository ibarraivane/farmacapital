'use strict';

/** Alias plano para Vercel — la URL pública sigue siendo /api/webhooks/whatsapp vía rewrite. */
const handler = require('./webhooks/whatsapp');

module.exports = handler;
if (handler.config) {
  module.exports.config = handler.config;
}
