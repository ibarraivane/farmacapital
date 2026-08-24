/**
 * Job semanal del monitor de precios + import admin (action=import).
 * Auth cron: Authorization Bearer CRON_SECRET
 * Auth import: x-session-token admin
 */
"use strict";

const { getSupabaseAdminConfig, validateAdminSession, validateEmployeeSession } = require("../_lib/supabaseAdmin");
const { runMonitorPreciosJob } = require("../_lib/monitorPreciosJob");

function getQuery(req) {
  try {
    const full = req.url || "";
    const q = full.includes("?") ? full.split("?")[1] : "";
    return new URLSearchParams(q);
  } catch {
    return new URLSearchParams();
  }
}

function isAuthorizedCron(req) {
  const secret = (process.env.CRON_SECRET || "").trim();
  if (!secret) return { ok: false, reason: "cron_secret_not_configured" };
  const authHeader = req.headers.authorization || req.headers.Authorization || "";
  const provided = String(authHeader).replace(/^Bearer\s+/i, "").trim();
  if (!provided || provided !== secret) return { ok: false, reason: "invalid_or_missing_secret" };
  return { ok: true };
}

function readJsonBody(req) {
  if (req.body && typeof req.body === "object" && !Buffer.isBuffer(req.body)) return req.body;
  if (typeof req.body === "string") {
    try { return JSON.parse(req.body); } catch { return {}; }
  }
  return {};
}

module.exports = async function handler(req, res) {
  if (req.method !== "POST" && req.method !== "GET") {
    res.status(405).json({ ok: false, error: "method_not_allowed" });
    return;
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    res.status(500).json({ ok: false, error: "supabase_not_configured" });
    return;
  }

  const action = getQuery(req).get("action") || (req.method === "POST" && readJsonBody(req).action) || "job";

  try {
    if (action === "import") {
      const sessionToken = String(
        req.headers["x-session-token"] || readJsonBody(req).session_token || ""
      ).trim();
      const isAdmin = await validateAdminSession(supabaseUrl, serviceKey, sessionToken);
      if (!isAdmin) {
        res.status(403).json({ ok: false, error: "requiere_admin" });
        return;
      }
      const body = readJsonBody(req);
      if (!body.csvText) {
        res.status(400).json({ ok: false, error: "falta_csv" });
        return;
      }
      const result = await runMonitorPreciosJob({
        supabaseUrl,
        serviceKey,
        opts: {
          csvText: body.csvText,
          fuente: body.fuente || "lista_distribuidor",
          archivo: body.archivo || "upload.csv",
          url_origen: body.url_origen || `archivo:${body.archivo || "upload.csv"}`,
          ciudad: body.ciudad,
        },
      });
      res.status(200).json(result);
      return;
    }

    if (action === "rastrear") {
      const sessionToken = String(
        req.headers["x-session-token"] || readJsonBody(req).session_token || ""
      ).trim();
      const sessionOk = await validateEmployeeSession(supabaseUrl, serviceKey, sessionToken);
      if (!sessionOk) {
        res.status(401).json({ ok: false, error: "unauthorized" });
        return;
      }
      const result = await runMonitorPreciosJob({ supabaseUrl, serviceKey, opts: {} });
      res.status(200).json(result);
      return;
    }

    const auth = isAuthorizedCron(req);
    if (!auth.ok) {
      res.status(401).json({ ok: false, error: "unauthorized" });
      return;
    }

    const result = await runMonitorPreciosJob({ supabaseUrl, serviceKey, opts: {} });
    res.status(200).json(result);
  } catch (err) {
    const msg = (err && err.message) || String(err);
    res.status(500).json({ ok: false, error: msg.slice(0, 280) });
  }
};
