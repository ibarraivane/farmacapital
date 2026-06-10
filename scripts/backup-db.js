#!/usr/bin/env node
/* eslint-disable */
/**
 * FARMACAPITAL — Backup end-to-end de PostgreSQL (Supabase)
 *
 * Flujo completo:
 *   1. Ejecuta pg_dump --format=custom de la base Supabase
 *   2. Valida tamaño (no vacío, no excede límite)
 *   3. Clona el repo de backups con token HTTPS
 *   4. Copia el dump dentro y hace git add/commit/push
 *   5. Rotación opcional (> N días)
 *
 * Uso:
 *   node scripts/backup-db.js
 *
 * Destino pensado:
 *   - GitHub Actions runner (ubuntu-latest) donde pg_dump y git ya
 *     vienen preinstalados.
 *   - También sirve en cualquier VM/CI con `pg_dump` y `git` en PATH.
 *   - NO corre en Vercel serverless (sin pg_dump/git binaries).
 *
 * ============================================================
 * Variables de entorno REQUERIDAS:
 * ============================================================
 *   SUPABASE_DB_URL
 *       Connection string de Supabase con password.
 *       Ejemplo: postgres://postgres.xxxx:pass@host:5432/postgres
 *
 *   BACKUP_GITHUB_REPO
 *       "owner/repo" del repo privado de backups.
 *       Ejemplo: "ibarra/farmacapital-backups"
 *
 *   BACKUP_GITHUB_TOKEN
 *       PAT fine-grained con Contents: Read and write
 *       sobre BACKUP_GITHUB_REPO.
 *
 * ============================================================
 * Variables de entorno OPCIONALES:
 * ============================================================
 *   BACKUP_OUTPUT_DIR       (default: /tmp/backups)
 *   BACKUP_MAX_SIZE_MB      (default: 500)
 *   BACKUP_MIN_SIZE_KB      (default: 10)
 *   BACKUP_TIMEOUT_SEC      (default: 900)  timeout para pg_dump
 *   BACKUP_FILENAME         (default: farmacapital-backup-YYYY-MM-DD.backup)
 *   BACKUP_SUBDIR           (default: backups)  carpeta dentro del repo
 *   BACKUP_RETENTION_DAYS   (default: 30)  borrar más viejos que esto; 0 desactiva
 *   BACKUP_SKIP_GIT         (default: false)  si true, solo hace el dump
 *   BACKUP_COMMIT_EMAIL     (default: backup-bot@farmacapital.local)
 *   BACKUP_COMMIT_NAME      (default: farmacapital-backup-bot)
 *
 * ============================================================
 * Exit codes:
 * ============================================================
 *   0  → backup subido correctamente
 *   1  → error genérico
 *   2  → faltan variables de entorno
 *   3  → pg_dump o git no disponibles
 *   4  → dump vacío o muy pequeño
 *   5  → dump excede tamaño máximo
 *   6  → timeout en pg_dump
 *   7  → error de git (clone/commit/push)
 *
 * ============================================================
 * Seguridad:
 * ============================================================
 *   - La connection string JAMÁS se imprime completa.
 *   - El token de GitHub JAMÁS se imprime.
 *   - Todos los logs pasan por sanitize() antes de emitirse.
 *   - El token se pasa a git vía URL embebida en una URL temporal
 *     dentro del remote, no como argumento visible en ps.
 */

'use strict';

const { spawn, spawnSync, execSync } = require('node:child_process');
const dns = require('node:dns').promises;
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');

const MB = 1024 * 1024;
const KB = 1024;

// ============================================================
// Logging sanitizado
// ============================================================

function log(msg, extra) {
  const line = `[backup-db] ${new Date().toISOString()} ${msg}`;
  if (extra === undefined) console.log(line);
  else console.log(line, typeof extra === 'string' ? sanitize(extra) : sanitize(extra));
}

function errlog(msg, extra) {
  const line = `[backup-db] ${new Date().toISOString()} ERROR: ${msg}`;
  if (extra === undefined) console.error(line);
  else console.error(line, typeof extra === 'string' ? sanitize(extra) : sanitize(extra));
}

function sanitize(value) {
  try {
    const s = typeof value === 'string' ? value : JSON.stringify(value);
    return s
      // redact postgres URLs with password
      .replace(/postgres(?:ql)?:\/\/[^\s"']+/gi, 'postgres://***redacted***')
      // redact https URLs with embedded token (https://x-access-token:TOKEN@...)
      .replace(/https?:\/\/[^:\s]+:[^@\s]+@/gi, 'https://***:***@')
      // redact github tokens
      .replace(/(ghp_|github_pat_|gho_|ghs_|ghu_)[A-Za-z0-9_]+/g, '$1***')
      // redact password=, token=, secret=, authorization:
      .replace(/(password|pwd|token|secret|authorization|apikey)[=:]\s*[^\s"',]+/gi, '$1=***');
  } catch {
    return '[unserializable]';
  }
}

// ============================================================
// Env + checks de binarios
// ============================================================

function requireEnv(name) {
  const v = process.env[name];
  if (!v || !v.trim()) {
    errlog(`Falta variable de entorno requerida: ${name}`);
    process.exit(2);
  }
  return v.trim();
}

function binaryAvailable(cmd) {
  try {
    execSync(`${cmd} --version`, { stdio: 'pipe', timeout: 5000 });
    return true;
  } catch {
    return false;
  }
}

function ensureBinaries(skipGit) {
  if (!binaryAvailable('pg_dump')) {
    errlog('pg_dump no está en el PATH. En ubuntu-latest instalar con: apt-get install -y postgresql-client');
    process.exit(3);
  }
  if (!skipGit && !binaryAvailable('git')) {
    errlog('git no está en el PATH.');
    process.exit(3);
  }
}

// ============================================================
// Utilidades
// ============================================================

function todayIso() {
  return new Date().toISOString().slice(0, 10);
}

function resolveFilename() {
  const custom = process.env.BACKUP_FILENAME;
  if (custom && custom.trim()) return custom.trim();
  return `farmacapital-backup-${todayIso()}.backup`;
}

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function rmrf(dir) {
  try {
    fs.rmSync(dir, { recursive: true, force: true });
  } catch (e) {
    errlog(`No se pudo limpiar ${dir}`, e.message);
  }
}

// ============================================================
// pg_dump
// ============================================================

function runPgDumpOnce({ dbUrl, outPath, timeoutSec, extraEnv = {} }) {
  return new Promise((resolve, reject) => {
    const args = [
      '--format=c',
      '--no-owner',
      '--no-privileges',
      '--verbose',
      `--file=${outPath}`,
      dbUrl, // último argumento posicional
    ];

    log(`Ejecutando pg_dump → ${outPath} (timeout ${timeoutSec}s)`);

    const child = spawn('pg_dump', args, {
      stdio: ['ignore', 'pipe', 'pipe'],
      env: { ...process.env, PGCLIENTENCODING: 'UTF8', ...extraEnv },
    });

    let stderrTail = '';
    let timedOut = false;

    const killer = setTimeout(() => {
      timedOut = true;
      errlog(`Timeout de ${timeoutSec}s excedido; matando pg_dump`);
      try { child.kill('SIGTERM'); } catch {}
      setTimeout(() => { try { child.kill('SIGKILL'); } catch {} }, 5000);
    }, timeoutSec * 1000);

    child.stdout.on('data', (c) => process.stdout.write(sanitize(c.toString())));
    child.stderr.on('data', (c) => {
      const t = c.toString();
      stderrTail = (stderrTail + t).slice(-2048);
      process.stderr.write(sanitize(t));
    });

    child.on('error', (err) => {
      clearTimeout(killer);
      reject(err);
    });

    child.on('close', (code) => {
      clearTimeout(killer);
      if (timedOut) return reject(Object.assign(new Error('timeout'), { code: 6 }));
      if (code !== 0) return reject(new Error(`pg_dump exit=${code}. Tail: ${sanitize(stderrTail.slice(-400))}`));
      resolve();
    });
  });
}

async function tryResolveIPv4FromDbUrl(dbUrl) {
  try {
    const u = new URL(String(dbUrl));
    const host = String(u.hostname || '').trim();
    if (!host) return null;
    const addrs = await dns.resolve4(host);
    if (!addrs || !addrs.length) return null;
    return addrs[0];
  } catch {
    return null;
  }
}

async function runPgDump({ dbUrl, outPath, timeoutSec }) {
  try {
    await runPgDumpOnce({ dbUrl, outPath, timeoutSec });
    return;
  } catch (err) {
    const forceIPv4 = String(process.env.BACKUP_FORCE_IPV4 || 'true').toLowerCase() !== 'false';
    const msg = String(err && err.message ? err.message : err || '');
    const looksNetworkIssue =
      msg.includes('Network is unreachable') ||
      msg.includes('could not translate host name') ||
      msg.includes('Name or service not known');
    if (!forceIPv4 || !looksNetworkIssue) throw err;

    const hostaddr = await tryResolveIPv4FromDbUrl(dbUrl);
    if (!hostaddr) throw err;

    log(`Reintentando pg_dump forzando IPv4 (PGHOSTADDR=${hostaddr})`);
    try { if (fs.existsSync(outPath)) fs.unlinkSync(outPath); } catch {}
    await runPgDumpOnce({
      dbUrl,
      outPath,
      timeoutSec,
      extraEnv: { PGHOSTADDR: hostaddr },
    });
  }
}

function validateDump({ outPath, minKB, maxMB }) {
  if (!fs.existsSync(outPath)) {
    errlog(`Archivo no creado: ${outPath}`);
    process.exit(4);
  }
  const { size } = fs.statSync(outPath);
  const sizeKB = Math.round(size / KB);
  const sizeMB = size / MB;

  log(`Dump creado. Tamaño: ${sizeKB} KB (${sizeMB.toFixed(2)} MB)`);

  if (sizeKB < minKB) {
    errlog(`Dump muy pequeño (${sizeKB} KB < ${minKB} KB). Posible fallo silencioso.`);
    process.exit(4);
  }
  if (sizeMB > maxMB) {
    errlog(`Dump excede tamaño máximo (${sizeMB.toFixed(2)} MB > ${maxMB} MB).`);
    process.exit(5);
  }
  return { size, sizeKB, sizeMB };
}

// ============================================================
// Git clone + commit + push
// ============================================================

function runGit(args, cwd, extraEnv) {
  // No mostramos args si llevan la URL con token embebido.
  const safeArgs = args.map((a) =>
    /https?:\/\/[^:\s]+:[^@\s]+@/.test(a) ? '<remote-url-sanitized>' : a
  );
  log(`git ${safeArgs.join(' ')}  (cwd=${cwd || process.cwd()})`);

  const res = spawnSync('git', args, {
    cwd: cwd || process.cwd(),
    stdio: ['ignore', 'pipe', 'pipe'],
    env: { ...process.env, ...(extraEnv || {}) },
    timeout: 5 * 60 * 1000, // 5 min por comando de git
  });

  if (res.stdout) process.stdout.write(sanitize(res.stdout.toString()));
  if (res.stderr) process.stderr.write(sanitize(res.stderr.toString()));

  if (res.status !== 0) {
    const tail = sanitize((res.stderr || Buffer.from('')).toString().slice(-400));
    throw Object.assign(new Error(`git ${safeArgs[0]} exit=${res.status}. Tail: ${tail}`), { code: 7 });
  }
  return res;
}

function cloneBackupRepo({ repo, token, workdir }) {
  const remote = `https://x-access-token:${token}@github.com/${repo}.git`;
  log(`Clonando ${repo} (shallow)…`);

  runGit(['clone', '--depth=1', '--quiet', remote, workdir]);
  runGit(['config', 'user.email', process.env.BACKUP_COMMIT_EMAIL || 'backup-bot@farmacapital.local'], workdir);
  runGit(['config', 'user.name', process.env.BACKUP_COMMIT_NAME || 'farmacapital-backup-bot'], workdir);
  // Nunca loguear credenciales en la salida de git
  runGit(['config', 'credential.helper', ''], workdir);
}

function commitAndPush({ workdir, subdir, srcFile, filename, sizeBytes }) {
  const dstDir = path.join(workdir, subdir);
  fs.mkdirSync(dstDir, { recursive: true });
  const dstFile = path.join(dstDir, filename);
  fs.copyFileSync(srcFile, dstFile);

  runGit(['add', path.join(subdir, filename)], workdir);

  // Si no hay cambios (backup idéntico al anterior del mismo día), no commiteamos.
  const diff = spawnSync('git', ['diff', '--cached', '--quiet'], { cwd: workdir });
  if (diff.status === 0) {
    log('No hay cambios nuevos que commitear (dump idéntico al existente).');
    return { committed: false };
  }

  runGit(['commit', '-m', `backup: ${filename} (${sizeBytes} bytes)`], workdir);
  runGit(['push', '--quiet'], workdir);
  log(`Push a ${process.env.BACKUP_GITHUB_REPO} completado.`);
  return { committed: true };
}

function rotateOldBackups({ workdir, subdir, retentionDays }) {
  if (!retentionDays || retentionDays <= 0) {
    log('Rotación desactivada (BACKUP_RETENTION_DAYS=0)');
    return { rotated: 0 };
  }
  const dir = path.join(workdir, subdir);
  if (!fs.existsSync(dir)) return { rotated: 0 };

  const now = Date.now();
  const cutoff = now - retentionDays * 86400 * 1000;
  const files = fs.readdirSync(dir).filter((f) => /^farmacapital-backup-\d{4}-\d{2}-\d{2}\.backup$/.test(f));
  const toDelete = [];
  for (const f of files) {
    const full = path.join(dir, f);
    const st = fs.statSync(full);
    // Usamos mtime; si prefieres la fecha del nombre, parsea el YYYY-MM-DD.
    if (st.mtimeMs < cutoff) {
      fs.unlinkSync(full);
      toDelete.push(f);
    }
  }
  if (toDelete.length === 0) {
    log(`Rotación: nada que borrar (retención ${retentionDays}d).`);
    return { rotated: 0 };
  }
  log(`Rotación: borrados ${toDelete.length} archivos > ${retentionDays}d.`);
  runGit(['add', '-A', subdir], workdir);

  const diff = spawnSync('git', ['diff', '--cached', '--quiet'], { cwd: workdir });
  if (diff.status === 0) return { rotated: 0 };

  runGit(['commit', '-m', `chore(backup): rotar >${retentionDays}d (${toDelete.length} archivos)`], workdir);
  runGit(['push', '--quiet'], workdir);
  return { rotated: toDelete.length };
}

// ============================================================
// Main
// ============================================================

async function main() {
  const startedAt = Date.now();

  const skipGit = String(process.env.BACKUP_SKIP_GIT || '').toLowerCase() === 'true';

  const dbUrl = requireEnv('SUPABASE_DB_URL');
  let repo, token;
  if (!skipGit) {
    repo = requireEnv('BACKUP_GITHUB_REPO');
    token = requireEnv('BACKUP_GITHUB_TOKEN');
  }

  ensureBinaries(skipGit);

  const outputDir = process.env.BACKUP_OUTPUT_DIR || '/tmp/backups';
  const maxMB = Number(process.env.BACKUP_MAX_SIZE_MB || '500');
  const minKB = Number(process.env.BACKUP_MIN_SIZE_KB || '10');
  const timeoutSec = Number(process.env.BACKUP_TIMEOUT_SEC || '900');
  const subdir = process.env.BACKUP_SUBDIR || 'backups';
  const retentionDays = Number(process.env.BACKUP_RETENTION_DAYS || '30');
  const filename = resolveFilename();

  ensureDir(outputDir);
  const outPath = path.join(outputDir, filename);

  log('=== FARMACAPITAL DB BACKUP ===');
  log(`Archivo destino: ${outPath}`);
  log(`Formato: custom (pg_restore)`);
  log(`Timeout pg_dump: ${timeoutSec}s`);
  log(`Tamaño esperado: ${minKB} KB .. ${maxMB} MB`);
  log(`Retención: ${retentionDays}d`);
  log(`Git push: ${skipGit ? 'NO' : `SÍ → ${repo}`}`);
  log('');

  // -------- 1. Dump --------
  try {
    log('--- Paso 1/3: pg_dump ---');
    await runPgDump({ dbUrl, outPath, timeoutSec });
  } catch (err) {
    errlog('pg_dump falló', err.message);
    process.exit(err.code === 6 ? 6 : 1);
  }

  // -------- 2. Validación --------
  log('--- Paso 2/3: validación ---');
  const meta = validateDump({ outPath, minKB, maxMB });

  if (skipGit) {
    log('BACKUP_SKIP_GIT=true → saltando git push.');
    log(`::backup-path::${outPath}`);
    log(`::backup-size-bytes::${meta.size}`);
    log(`::backup-filename::${filename}`);
    log(`Duración total: ${Math.round((Date.now() - startedAt) / 1000)}s`);
    return;
  }

  // -------- 3. Git clone + copy + commit + push --------
  log('--- Paso 3/3: git clone + commit + push ---');
  const workdir = fs.mkdtempSync(path.join(os.tmpdir(), 'farmacapital-backup-repo-'));
  let committed = false;
  let rotated = 0;
  try {
    cloneBackupRepo({ repo, token, workdir });
    const r1 = commitAndPush({
      workdir, subdir, srcFile: outPath, filename, sizeBytes: meta.size,
    });
    committed = r1.committed;

    const r2 = rotateOldBackups({ workdir, subdir, retentionDays });
    rotated = r2.rotated;
  } catch (err) {
    errlog('git falló', err.message);
    rmrf(workdir);
    process.exit(err.code || 7);
  } finally {
    rmrf(workdir);
  }

  // -------- Resumen machine-readable --------
  log('');
  log('=== BACKUP OK ===');
  log(`::backup-path::${outPath}`);
  log(`::backup-size-bytes::${meta.size}`);
  log(`::backup-filename::${filename}`);
  log(`::backup-committed::${committed}`);
  log(`::backup-rotated::${rotated}`);
  log(`Duración total: ${Math.round((Date.now() - startedAt) / 1000)}s`);
}

main().catch((err) => {
  errlog('Fallo inesperado', (err && err.message) || String(err));
  process.exit(1);
});
