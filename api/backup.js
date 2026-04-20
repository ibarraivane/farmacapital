/**
 * FARMAX — Trigger de backup
 *
 * Invocado por Vercel Cron (0 6 * * *). Dispara el workflow
 * .github/workflows/backup.yml en el repo principal vía la API
 * repository_dispatch de GitHub. El runner (ubuntu-latest) es
 * quien realmente ejecuta pg_dump y commitea al repo de backups.
 *
 * POR QUÉ NO corremos pg_dump aquí:
 *   - Vercel serverless no tiene pg_dump instalado.
 *   - Timeout máx 60s (Hobby) — insuficiente para DBs de >50MB.
 *   - /tmp limitado a 512MB.
 *   - Sin git binario ni SSH.
 *
 * Variables de entorno (Vercel):
 *   DISPATCH_GITHUB_REPO    owner/repo donde vive el workflow (ej: "ibarra/farmax")
 *   DISPATCH_GITHUB_TOKEN   PAT con scope "repo" (fine-grained: Actions=write)
 *   CRON_SECRET             secreto compartido para autenticar invocaciones manuales
 *
 * Vercel Cron añade automáticamente el header Authorization: Bearer <CRON_SECRET>
 * si lo definiste en el proyecto. Esto evita que cualquiera con la URL pública
 * dispare backups y consuma tu cuota de GitHub Actions.
 *
 * Uso manual (para testeo):
 *   curl -X POST https://tu-app.vercel.app/api/backup \
 *     -H "Authorization: Bearer $CRON_SECRET"
 */

'use strict';

function sanitize(s) {
  if (!s) return '';
  return String(s).replace(/(ghp_|github_pat_|token=|bearer\s+)[^\s"']+/gi, '$1***');
}

function isAuthorized(req) {
  const secret = process.env.CRON_SECRET;
  if (!secret) {
    // Sin CRON_SECRET configurado en Vercel, cualquiera puede disparar.
    // Lo bloqueamos por seguridad.
    return { ok: false, reason: 'cron_secret_not_configured' };
  }
  const authHeader = req.headers.authorization || req.headers.Authorization || '';
  const provided = authHeader.replace(/^Bearer\s+/i, '').trim();
  if (!provided || provided !== secret) {
    return { ok: false, reason: 'invalid_or_missing_secret' };
  }
  return { ok: true };
}

module.exports = async function handler(req, res) {
  const startedAt = Date.now();

  // Solo POST (o GET desde Vercel Cron que envía GET por default).
  if (req.method !== 'POST' && req.method !== 'GET') {
    res.status(405).json({ ok: false, error: 'method_not_allowed' });
    return;
  }

  const auth = isAuthorized(req);
  if (!auth.ok) {
    // No damos pistas sobre qué falla exactamente.
    console.warn('[api/backup] unauthorized request:', auth.reason);
    res.status(401).json({ ok: false, error: 'unauthorized' });
    return;
  }

  const repo = process.env.DISPATCH_GITHUB_REPO;
  const token = process.env.DISPATCH_GITHUB_TOKEN;

  if (!repo || !token) {
    console.error('[api/backup] missing DISPATCH_GITHUB_REPO or DISPATCH_GITHUB_TOKEN');
    res.status(500).json({ ok: false, error: 'not_configured' });
    return;
  }

  try {
    const ghUrl = `https://api.github.com/repos/${repo}/dispatches`;
    const ghResp = await fetch(ghUrl, {
      method: 'POST',
      headers: {
        Accept: 'application/vnd.github+json',
        Authorization: `Bearer ${token}`,
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json',
        'User-Agent': 'farmax-backup-trigger',
      },
      body: JSON.stringify({
        event_type: 'farmax-backup',
        client_payload: {
          source: 'vercel-cron',
          triggered_at: new Date().toISOString(),
        },
      }),
    });

    if (ghResp.status !== 204) {
      const text = await ghResp.text().catch(() => '');
      console.error('[api/backup] github dispatch failed:', ghResp.status, sanitize(text).slice(0, 200));
      res.status(502).json({
        ok: false,
        error: 'github_dispatch_failed',
        status: ghResp.status,
      });
      return;
    }

    console.log('[api/backup] dispatch ok, event=farmax-backup');
    res.status(202).json({
      ok: true,
      dispatched: true,
      ms: Date.now() - startedAt,
      ts: new Date().toISOString(),
      message: 'Workflow disparado. Revisa GitHub Actions para el resultado.',
    });
  } catch (err) {
    const msg = sanitize((err && err.message) || String(err));
    console.error('[api/backup] unexpected error:', msg.slice(0, 200));
    res.status(500).json({ ok: false, error: 'unexpected' });
  }
};
