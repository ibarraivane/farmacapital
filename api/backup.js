/**
 * FARMAX — Trigger de backup
 *
 * Invocado por Vercel Cron (0 6 * * *). Dispara el workflow
 * .github/workflows/backup.yml en el repo principal vía la API
 * repository_dispatch de GitHub. El runner (ubuntu-latest) es
 * quien realmente ejecuta pg_dump y commitea al repo de backups.
 *
 * Variables de entorno (Vercel → Production):
 *   DISPATCH_GITHUB_REPO    owner/repo (ej. "ibarraivane/farmax") — sin https://github.com/
 *   DISPATCH_GITHUB_TOKEN   PAT con permiso para disparar Actions en ese repo
 *   CRON_SECRET             Vercel lo envía como Authorization: Bearer … en cada cron
 *
 * Diagnóstico (misma auth que el cron):
 *   curl -s "https://TU-DOMINIO/api/backup?ping=1" -H "Authorization: Bearer $CRON_SECRET"
 *
 * Manual (dispara workflow):
 *   curl -X POST https://TU-DOMINIO/api/backup -H "Authorization: Bearer $CRON_SECRET"
 */

'use strict';

function sanitize(s) {
  if (!s) return '';
  return String(s).replace(/(ghp_|github_pat_|token=|bearer\s+)[^\s"']+/gi, '$1***');
}

/** owner/repo sin URL completa ni .git (errores típicos al pegar desde el navegador). */
function normalizeDispatchRepo(raw) {
  if (!raw || typeof raw !== 'string') return '';
  let s = raw.trim();
  if (!s) return '';
  s = s.replace(/^https?:\/\/github\.com\//i, '');
  s = s.replace(/\.git$/i, '');
  s = s.replace(/^\/+|\/+$/g, '');
  return s;
}

function isPingRequest(req) {
  try {
    const full = req.url || '';
    const q = full.includes('?') ? full.split('?')[1] : '';
    return new URLSearchParams(q).get('ping') === '1';
  } catch {
    return false;
  }
}

function isAuthorized(req) {
  const secret = (process.env.CRON_SECRET || '').trim();
  if (!secret) {
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

  if (req.method !== 'POST' && req.method !== 'GET') {
    res.status(405).json({ ok: false, error: 'method_not_allowed' });
    return;
  }

  const auth = isAuthorized(req);
  if (!auth.ok) {
    console.warn('[api/backup] unauthorized request:', auth.reason);
    const body = { ok: false, error: 'unauthorized' };
    if (auth.reason === 'cron_secret_not_configured') {
      body.hint =
        'Agregá CRON_SECRET en Vercel (scope Production), redeploy, y confirmá que el cron use el deployment de producción.';
    }
    res.status(401).json(body);
    return;
  }

  const repo = normalizeDispatchRepo(process.env.DISPATCH_GITHUB_REPO || '');
  const token = (process.env.DISPATCH_GITHUB_TOKEN || '').trim();

  if (isPingRequest(req)) {
    res.status(200).json({
      ok: true,
      ping: true,
      dispatch_repo: repo || null,
      has_dispatch_repo: !!repo,
      has_dispatch_token: !!token,
      repo_looks_valid: /^[^/]+\/[^/]+$/.test(repo),
      ms: Date.now() - startedAt,
      ts: new Date().toISOString(),
    });
    return;
  }

  if (!repo || !token) {
    console.error('[api/backup] missing DISPATCH_GITHUB_REPO or DISPATCH_GITHUB_TOKEN');
    res.status(500).json({
      ok: false,
      error: 'not_configured',
      hint:
        'En Vercel (Production): DISPATCH_GITHUB_REPO=owner/repo del repo donde está .github/workflows/backup.yml (ej. ibarraivane/farmax) y DISPATCH_GITHUB_TOKEN con permiso de Actions en ese repo.',
    });
    return;
  }

  if (!/^[^/]+\/[^/]+$/.test(repo)) {
    console.error('[api/backup] invalid DISPATCH_GITHUB_REPO shape:', sanitize(repo));
    res.status(500).json({
      ok: false,
      error: 'invalid_repo',
      hint:
        'DISPATCH_GITHUB_REPO debe ser solo owner/repo (ej. ibarraivane/farmax), sin https:// ni .git',
    });
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
      let hint;
      try {
        const j = JSON.parse(text);
        if (j.message) hint = sanitize(String(j.message)).slice(0, 240);
      } catch (_) {
        hint = sanitize(text).slice(0, 240);
      }
      res.status(502).json({
        ok: false,
        error: 'github_dispatch_failed',
        status: ghResp.status,
        hint:
          hint ||
          'Revisá que DISPATCH_GITHUB_TOKEN tenga acceso al repo y permiso Actions (fine-grained: Actions read/write). 404 = owner/repo incorrecto.',
      });
      return;
    }

    console.log('[api/backup] dispatch ok, event=farmax-backup');
    res.status(202).json({
      ok: true,
      dispatched: true,
      ms: Date.now() - startedAt,
      ts: new Date().toISOString(),
      message: 'Workflow disparado. En GitHub → Actions → FARMAX DB Backup debe aparecer una corrida.',
    });
  } catch (err) {
    const msg = sanitize((err && err.message) || String(err));
    console.error('[api/backup] unexpected error:', msg.slice(0, 200));
    res.status(500).json({ ok: false, error: 'unexpected' });
  }
};
