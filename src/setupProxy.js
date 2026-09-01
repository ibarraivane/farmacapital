/**
 * En `npm start` CRA no ejecuta las funciones de /api.
 * Este proxy monta Uber Direct y el buscador de destino para probar en local.
 */
"use strict";

const uberDirectHandler = require("../api/_lib/uberDirectHttp");
const addressSuggestHandler = require("../api/_lib/addressSuggestHttp");
const logisticsWebhook = require("../api/logistics/webhook");
const authRouter = require("../api/auth/password-reset-request");

function readJsonBody(req) {
  return new Promise((resolve) => {
    if (req.body && typeof req.body === "object" && !Buffer.isBuffer(req.body)) {
      resolve();
      return;
    }
    const chunks = [];
    req.on("data", (c) => chunks.push(c));
    req.on("end", () => {
      const raw = Buffer.concat(chunks).toString("utf8");
      try {
        req.body = raw ? JSON.parse(raw) : {};
      } catch {
        req.body = {};
      }
      resolve();
    });
  });
}

function mount(app, path, handler) {
  app.use(path, (req, res) => {
    readJsonBody(req)
      .then(() => handler(req, res))
      .catch((err) => {
        if (!res.headersSent) {
          res.status(500).json({ ok: false, error: "proxy_error", message: err?.message || "unknown" });
        }
      });
  });
}

module.exports = function setupProxy(app) {
  mount(app, "/api/address/suggest", addressSuggestHandler);
  mount(app, "/api/logistics/webhook", logisticsWebhook);
  mount(app, "/api/logistics/uber-direct", uberDirectHandler);
  mount(app, "/api/auth/oauth-bridge", (req, res) => {
    req.query = { ...(req.query || {}), type: "oauth-bridge" };
    return authRouter(req, res);
  });
  mount(app, "/api/auth/password-reset-request", authRouter);
};
