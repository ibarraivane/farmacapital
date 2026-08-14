#!/usr/bin/env node
/** POST /api/admin/bootstrap-referencias en producción (requiere CRON_SECRET en .env). */
'use strict';

const fs = require('fs');
const path = require('path');

function loadEnv() {
  for (const f of ['.env.local', '.env']) {
    const p = path.join(__dirname, '..', f);
    if (!fs.existsSync(p)) continue;
    for (const line of fs.readFileSync(p, 'utf8').split('\n')) {
      const t = line.trim();
      if (!t || t.startsWith('#') || !t.includes('=')) continue;
      const i = t.indexOf('=');
      const k = t.slice(0, i).trim();
      let v = t.slice(i + 1).trim();
      if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) v = v.slice(1, -1);
      if (!process.env[k]) process.env[k] = v;
    }
  }
}

async function main() {
  loadEnv();
  const secret = process.env.CRON_SECRET || '';
  if (!secret || secret.includes('SENSITIVE') || secret.length < 8) {
    console.error('Falta CRON_SECRET en .env (mismo valor que en Vercel)');
    process.exit(1);
  }
  const base = process.env.BOOTSTRAP_URL || 'https://www.farmacapital.mx';
  const r = await fetch(`${base}/api/admin/bootstrap-referencias?force=1`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${secret}` },
  });
  const body = await r.text();
  console.log(r.status, body);
  if (!r.ok) process.exit(1);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
