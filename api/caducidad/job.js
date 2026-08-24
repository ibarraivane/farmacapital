/**
 * Job diario: propone descuentos por lote próximo a caducar.
 * No escribe productos.precio. Auth: CRON_SECRET (igual que /api/backup).
 */
"use strict";

const { getSupabaseAdminConfig } = require("../_lib/supabaseAdmin");
const { runCaducidadJob } = require("../_lib/caducidadJob");

function isAuthorized(req) {
  const secret = (process.env.CRON_SECRET || "").trim();
  if (!secret) return { ok: false, reason: "cron_secret_not_configured" };
  const authHeader = req.headers.authorization || req.headers.Authorization || "";
  const provided = String(authHeader).replace(/^Bearer\s+/i, "").trim();
  if (!provided || provided !== secret) return { ok: false, reason: "invalid_or_missing_secret" };
  return { ok: true };
}

module.exports = async function handler(req, res) {
  if (req.method !== "POST" && req.method !== "GET") {
    res.status(405).json({ ok: false, error: "method_not_allowed" });
    return;
  }

  const auth = isAuthorized(req);
  if (!auth.ok) {
    res.status(401).json({ ok: false, error: "unauthorized" });
    return;
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    res.status(500).json({ ok: false, error: "supabase_not_configured" });
    return;
  }

  try {
    const result = await runCaducidadJob({ supabaseUrl, serviceKey });
    res.status(200).json(result);
  } catch (err) {
    const msg = (err && err.message) || String(err);
    res.status(500).json({ ok: false, error: msg.slice(0, 280) });
  }
};
