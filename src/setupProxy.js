/**
 * En `npm start` CRA no ejecuta las funciones de /api.
 * Este proxy invoca el handler de Uber Direct para cotizar en local.
 */
"use strict";

const uberDirectHandler = require("../api/logistics/uber-direct");

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

module.exports = function setupProxy(app) {
  app.use("/api/logistics/uber-direct", (req, res) => {
    readJsonBody(req)
      .then(() => uberDirectHandler(req, res))
      .catch((err) => {
        if (!res.headersSent) {
          res.status(500).json({ ok: false, error: "proxy_error", message: err?.message || "unknown" });
        }
      });
  });
};
