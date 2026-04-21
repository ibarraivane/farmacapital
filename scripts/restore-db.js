#!/usr/bin/env node
/* eslint-disable */
/**
 * FARMAX — Restauración segura desde backups en GitHub
 *
 * Uso:
 *   node scripts/restore-db.js --list
 *   node scripts/restore-db.js
 *   node scripts/restore-db.js --file=farmax-backup-2026-04-15.backup
 *   node scripts/restore-db.js --file=... --dry-run
 *   node scripts/restore-db.js --file=... --yes   # sin prompts (CI/automatización)
 *
 * Variables de entorno:
 *   BACKUP_GITHUB_REPO   owner/repo del repo privado de backups
 *   BACKUP_GITHUB_TOKEN  PAT con lectura del repo de backups
 *   BACKUP_GITHUB_REF    rama (default: main)
 *   RESTORE_DB_URL       destino preferido (recomendado: DB de prueba)
 *   SUPABASE_DB_URL      fallback si no hay RESTORE_DB_URL (pide confirmación extra)
 *   RESTORE_TIMEOUT_SEC  timeout pg_restore (default: 1800)
 *
 * Requiere en PATH: pg_restore (y opcionalmente psql para resumen post-restore)
 */

'use strict';

const fs = require('node:fs');
const fsp = require('node:fs/promises');
const path = require('node:path');
const os = require('node:os');
const crypto = require('node:crypto');
const readline = require('node:readline/promises');
const { spawn, execSync, execFileSync } = require('node:child_process');

const GITHUB_API = 'https://api.github.com';
const BACKUP_SUBDIR = 'backups';

function encodeRepoContentPath(relPath) {
  return relPath
    .split('/')
    .filter(Boolean)
    .map(encodeURIComponent)
    .join('/');
}

function logLine(stream, msg) {
  const line = `[restore-db] ${new Date().toISOString()} ${msg}\n`;
  stream.write(line);
}

function sanitizeForLog(value) {
  try {
    const s = typeof value === 'string' ? value : JSON.stringify(value);
    return s
      .replace(/postgres(?:ql)?:\/\/[^\s"']+/gi, 'postgres://***redacted***')
      .replace(/https?:\/\/[^:\s]+:[^@\s]+@/gi, 'https://***:***@')
      .replace(/(ghp_|github_pat_|gho_|ghs_|ghu_)[A-Za-z0-9_]+/g, '$1***')
      .replace(/(password|pwd|token|secret|authorization|apikey)[=:]\s*[^\s"',]+/gi, '$1=***');
  } catch {
    return '[unserializable]';
  }
}

function redactDbUrlForDisplay(dbUrl) {
  if (!dbUrl) return '(no definida)';
  try {
    const m = dbUrl.match(/^postgres(?:ql)?:\/\/([^:@]+)(?::([^@]*))?@([^:\/?#]+)(?::(\d+))?\/([^?]*)/i);
    if (m) {
      const [, user] = m;
      const host = m[3];
      const port = m[4] || '5432';
      const db = m[5] || 'postgres';
      return `postgres://${user ? '***' : ''}:***@${host}:${port}/${db}`;
    }
  } catch { /* ignore */ }
  return 'postgres://***:***@*** (URL oculta)';
}

function parseArgs(argv) {
  const out = {
    list: false,
    yes: false,
    dryRun: false,
    file: null,
  };
  for (const a of argv.slice(2)) {
    if (a === '--list') out.list = true;
    else if (a === '--yes') out.yes = true;
    else if (a === '--dry-run') out.dryRun = true;
    else if (a.startsWith('--file=')) out.file = a.slice('--file='.length).trim();
  }
  return out;
}

function requireEnv(name) {
  const v = process.env[name];
  if (!v || !v.trim()) {
    console.error(`[restore-db] ERROR: falta ${name}`);
    process.exit(2);
  }
  return v.trim();
}

function optionalEnv(name, defaultVal) {
  const v = process.env[name];
  if (v == null || v === '') return defaultVal;
  return v.trim();
}

function ensureBinary(cmd, hint) {
  try {
    execSync(`${cmd} --version`, { stdio: 'pipe', timeout: 8000 });
  } catch {
    console.error(`[restore-db] ERROR: "${cmd}" no está en PATH. ${hint || ''}`);
    process.exit(3);
  }
}

function parseBackupDate(name) {
  const m = name.match(/^farmax-backup-(\d{4}-\d{2}-\d{2})\.backup$/i);
  return m ? m[1] : null;
}

function sortBackupsDesc(items) {
  return items.slice().sort((a, b) => {
    const da = parseBackupDate(a.name) || '';
    const db = parseBackupDate(b.name) || '';
    if (da !== db) return db.localeCompare(da);
    return b.name.localeCompare(a.name);
  });
}

async function githubFetchRaw(owner, repo, ref, filePath, token) {
  const url = `${GITHUB_API}/repos/${owner}/${repo}/contents/${encodeRepoContentPath(filePath)}?ref=${encodeURIComponent(ref)}`;
  const res = await fetch(url, {
    headers: {
      Accept: 'application/vnd.github.raw',
      Authorization: `Bearer ${token}`,
      'X-GitHub-Api-Version': '2022-11-28',
      'User-Agent': 'farmax-restore-db',
    },
  });
  if (!res.ok) {
    const t = await res.text().catch(() => '');
    throw new Error(`GitHub ${res.status} al descargar ${filePath}: ${sanitizeForLog(t).slice(0, 200)}`);
  }
  const buf = Buffer.from(await res.arrayBuffer());
  return buf;
}

async function githubListBackups(owner, repo, ref, token) {
  const url = `${GITHUB_API}/repos/${owner}/${repo}/contents/${encodeRepoContentPath(BACKUP_SUBDIR)}?ref=${encodeURIComponent(ref)}`;
  const res = await fetch(url, {
    headers: {
      Accept: 'application/vnd.github+json',
      Authorization: `Bearer ${token}`,
      'X-GitHub-Api-Version': '2022-11-28',
      'User-Agent': 'farmax-restore-db',
    },
  });
  if (!res.ok) {
    const t = await res.text().catch(() => '');
    throw new Error(`GitHub ${res.status} al listar ${BACKUP_SUBDIR}: ${sanitizeForLog(t).slice(0, 200)}`);
  }
  const data = await res.json();
  if (!Array.isArray(data)) {
    throw new Error(`Respuesta inesperada: se esperaba un directorio en ${BACKUP_SUBDIR}`);
  }
  const backups = data.filter(
    (e) => e.type === 'file' && /\.backup$/i.test(e.name)
  );
  return sortBackupsDesc(backups);
}

function formatBytes(n) {
  if (n == null) return '?';
  if (n < 1024) return `${n} B`;
  if (n < 1024 * 1024) return `${(n / 1024).toFixed(1)} KB`;
  return `${(n / (1024 * 1024)).toFixed(2)} MB`;
}

function printBackupTable(items) {
  console.log('');
  console.log('  #  Fecha        Nombre                                      Tamaño');
  console.log('  -  ----------  ------------------------------------------  ----------');
  items.forEach((e, i) => {
    const d = parseBackupDate(e.name) || '—';
    const namePad = e.name.padEnd(42);
    console.log(`  ${String(i + 1).padStart(2)}  ${d}  ${namePad}  ${formatBytes(e.size)}`);
  });
  console.log('');
}

async function verifySha256IfPresent(localBackupPath, owner, repo, ref, token, log) {
  const base = path.basename(localBackupPath);
  const shaPath = `${BACKUP_SUBDIR}/${base}.sha256`;
  let shaExpected;
  try {
    const url = `${GITHUB_API}/repos/${owner}/${repo}/contents/${encodeRepoContentPath(shaPath)}?ref=${encodeURIComponent(ref)}`;
    const res = await fetch(url, {
      headers: {
        Accept: 'application/vnd.github.raw',
        Authorization: `Bearer ${token}`,
        'X-GitHub-Api-Version': '2022-11-28',
        'User-Agent': 'farmax-restore-db',
      },
    });
    if (!res.ok) {
      log(`No hay ${base}.sha256 en el repo (omitido).`);
      return;
    }
    shaExpected = (await res.text()).trim().split(/\s+/)[0];
  } catch (e) {
    log(`SHA256 opcional omitido: ${e.message}`);
    return;
  }
  const hash = crypto.createHash('sha256');
  const rs = fs.createReadStream(localBackupPath);
  await new Promise((resolve, reject) => {
    rs.on('data', (c) => hash.update(c));
    rs.on('end', resolve);
    rs.on('error', reject);
  });
  const digest = hash.digest('hex');
  if (digest.toLowerCase() !== shaExpected.toLowerCase()) {
    throw new Error(
      `SHA-256 no coincide. Esperado ${shaExpected.slice(0, 12)}… obtenido ${digest.slice(0, 12)}…`
    );
  }
  log('SHA-256 verificado correctamente.');
}

function runPgRestoreList(backupPath, logStream) {
  return new Promise((resolve, reject) => {
    const child = spawn('pg_restore', ['--list', backupPath], {
      stdio: ['ignore', 'pipe', 'pipe'],
    });
    let err = '';
    let out = '';
    child.stdout.on('data', (c) => { out += c.toString(); });
    child.stderr.on('data', (c) => { err += c.toString(); });
    child.on('error', reject);
    child.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(`pg_restore --list falló (código ${code}): ${sanitizeForLog(err.slice(-500))}`));
        return;
      }
      const lines = out.split('\n').filter(Boolean);
      logLine(logStream, `pg_restore --list OK (${lines.length} entradas en TOC)`);
      resolve({ tocLines: lines, tocText: out });
    });
  });
}

function summarizeToc(tocText) {
  const lines = tocText.split('\n');
  let tableData = 0;
  let tableSchema = 0;
  for (const line of lines) {
    if (/; TABLE DATA /.test(line)) tableData += 1;
    if (/; TABLE /.test(line) && !/; TABLE DATA /.test(line)) tableSchema += 1;
  }
  return { tableData, tableSchema, lineCount: lines.filter(Boolean).length };
}

function runPgRestore(dbUrl, backupPath, timeoutSec, logStream) {
  return new Promise((resolve, reject) => {
    const args = [
      '--clean',
      '--if-exists',
      '--no-owner',
      '--no-acl',
      '--verbose',
      `--dbname=${dbUrl}`,
      backupPath,
    ];
    logLine(logStream, `Iniciando pg_restore (timeout ${timeoutSec}s)…`);
    const child = spawn('pg_restore', args, {
      stdio: ['ignore', 'pipe', 'pipe'],
      env: { ...process.env, PGCLIENTENCODING: 'UTF8' },
    });
    let stderrBuf = '';
    let killed = false;
    const timer = setTimeout(() => {
      killed = true;
      logLine(logStream, `TIMEOUT: matando pg_restore a los ${timeoutSec}s`);
      try { child.kill('SIGTERM'); } catch { /* ignore */ }
      setTimeout(() => {
        try { child.kill('SIGKILL'); } catch { /* ignore */ }
      }, 8000);
    }, timeoutSec * 1000);

    child.stderr.on('data', (c) => {
      const t = c.toString();
      stderrBuf += t;
      process.stderr.write(sanitizeForLog(t));
    });
    child.stdout.on('data', (c) => process.stdout.write(sanitizeForLog(c.toString())));
    child.on('error', (err) => {
      clearTimeout(timer);
      reject(err);
    });
    child.on('close', (code) => {
      clearTimeout(timer);
      if (killed) {
        reject(new Error(`pg_restore excedió timeout (${timeoutSec}s)`));
        return;
      }
      if (code !== 0) {
        reject(
          new Error(
            `pg_restore terminó con código ${code}. Últimas líneas: ${sanitizeForLog(stderrBuf.slice(-800))}`
          )
        );
        return;
      }
      logLine(logStream, 'pg_restore completó con código 0.');
      resolve();
    });
  });
}

function runPsqlSummary(dbUrl, logStream) {
  try {
    const sql =
      "SELECT (SELECT count(*)::bigint FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE'), " +
      '(SELECT coalesce(sum(n_live_tup), 0)::bigint FROM pg_stat_user_tables);';
    const out = execFileSync(
      'psql',
      [dbUrl, '-v', 'ON_ERROR_STOP=1', '-t', '-A', '-F', '|', '-c', sql],
      {
        encoding: 'utf8',
        stdio: ['ignore', 'pipe', 'pipe'],
        timeout: 120000,
        maxBuffer: 1024 * 1024,
      }
    );
    const parts = out.trim().split('|');
    if (parts.length >= 2) {
      logLine(logStream, `Resumen post-restore: tablas en public ≈ ${parts[0]}, filas estimadas (pg_stat) ≈ ${parts[1]}`);
      console.log('');
      console.log('  Resumen post-restore:');
      console.log(`    Tablas (public):     ${parts[0]}`);
      console.log(`    Filas aproximadas:   ${parts[1]}  (estimación pg_stat_user_tables; ejecuta ANALYZE para refinar)`);
      console.log('');
    }
  } catch (e) {
    logLine(
      logStream,
      `No se pudo obtener resumen vía psql (¿instalado?): ${sanitizeForLog(e.message || e)}`
    );
  }
}

async function prompt(rl, question) {
  const ans = await rl.question(question);
  return (ans || '').trim();
}

async function ensureLogFile() {
  const logsDir = path.join(process.cwd(), 'logs');
  await fsp.mkdir(logsDir, { recursive: true });
  const day = new Date().toISOString().slice(0, 10);
  return path.join(logsDir, `restore-${day}.log`);
}

async function openLogStream(logPath) {
  return fs.createWriteStream(logPath, { flags: 'a' });
}

function resolveTargetDbUrl() {
  const restoreUrl = optionalEnv('RESTORE_DB_URL', '');
  const supaUrl = optionalEnv('SUPABASE_DB_URL', '');
  if (restoreUrl) return { url: restoreUrl, source: 'RESTORE_DB_URL' };
  if (supaUrl) return { url: supaUrl, source: 'SUPABASE_DB_URL' };
  throw new Error('Define RESTORE_DB_URL o SUPABASE_DB_URL antes de restaurar.');
}

async function main() {
  const args = parseArgs(process.argv);
  const token = optionalEnv('BACKUP_GITHUB_TOKEN', '');
  const repoFull = optionalEnv('BACKUP_GITHUB_REPO', '');
  const ref = optionalEnv('BACKUP_GITHUB_REF', 'main');

  if (args.list) {
    if (!repoFull || !token) {
      console.error('[restore-db] ERROR: para --list necesitas BACKUP_GITHUB_REPO y BACKUP_GITHUB_TOKEN');
      process.exit(2);
    }
    const [owner, repo] = repoFull.split('/');
    if (!owner || !repo) {
      console.error('[restore-db] ERROR: BACKUP_GITHUB_REPO debe ser owner/repo');
      process.exit(2);
    }
    console.log(`[restore-db] Listando backups en ${repoFull} (rama ${ref})…`);
    const items = await githubListBackups(owner, repo, ref, token);
    if (items.length === 0) {
      console.log('No hay archivos .backup en backups/');
      process.exit(0);
    }
    printBackupTable(items);
    process.exit(0);
  }

  ensureBinary('pg_restore', 'Instala postgresql-client (brew install libpq / apt install postgresql-client).');

  const logPath = await ensureLogFile();
  const logStream = await openLogStream(logPath);
  const log = (msg) => {
    const s = sanitizeForLog(msg);
    console.log(`[restore-db] ${s}`);
    logLine(logStream, s);
  };

  log(`Log: ${logPath}`);

  if (!repoFull || !token) {
    log('ERROR: BACKUP_GITHUB_REPO y BACKUP_GITHUB_TOKEN son obligatorios');
    logStream.end();
    process.exit(2);
  }
  const [owner, repo] = repoFull.split('/');
  if (!owner || !repo) {
    log('ERROR: BACKUP_GITHUB_REPO debe ser owner/repo');
    logStream.end();
    process.exit(2);
  }

  let filename = args.file;
  /** @type {import('node:readline/promises').Interface | null} */
  let rl = null;
  const skipPrompts = Boolean(args.yes || args.dryRun);
  /** @type {string | null} */
  let tmpRoot = null;

  const shutdown = (code) => {
    try {
      if (rl) rl.close();
    } catch { /* ignore */ }
    rl = null;
    try {
      if (logStream && !logStream.writableEnded) logStream.end();
    } catch { /* ignore */ }
    process.exit(code);
  };

  try {
    const items = await githubListBackups(owner, repo, ref, token);
    if (items.length === 0) {
      log('No hay backups .backup en el repo.');
      shutdown(1);
    }

    if (!filename) {
      if (!process.stdin.isTTY) {
        log('ERROR: modo no interactivo sin TTY: usa --file=nombre.backup');
        shutdown(2);
      }
      rl = readline.createInterface({ input: process.stdin, output: process.stdout });
      printBackupTable(items);
      const choice = await prompt(rl, 'Selecciona número (1-' + items.length + ') o fecha YYYY-MM-DD: ');
      const n = parseInt(choice, 10);
      if (!Number.isNaN(n) && n >= 1 && n <= items.length) {
        filename = items[n - 1].name;
      } else if (/^\d{4}-\d{2}-\d{2}$/.test(choice)) {
        const found = items.find((e) => e.name === `farmax-backup-${choice}.backup`);
        if (!found) {
          log(`No existe farmax-backup-${choice}.backup`);
          shutdown(1);
        }
        filename = found.name;
      } else {
        log('Selección inválida.');
        shutdown(1);
      }
    }

    const meta = items.find((e) => e.name === filename);
    const sizeStr = meta ? formatBytes(meta.size) : '(tamaño desconocido)';
    const dateStr = parseBackupDate(filename) || '—';

    tmpRoot = await fsp.mkdtemp(path.join(os.tmpdir(), 'farmax-restore-'));
    const localPath = path.join(tmpRoot, filename);
    log(`Descargando ${filename}…`);
    const body = await githubFetchRaw(owner, repo, ref, `${BACKUP_SUBDIR}/${filename}`, token);
    await fsp.writeFile(localPath, body);
    log(`Descargado: ${formatBytes(body.length)} → ${localPath}`);

    await verifySha256IfPresent(localPath, owner, repo, ref, token, log);

    const { tocText } = await runPgRestoreList(localPath, logStream);
    const tocSummary = summarizeToc(tocText);
    log(
      `TOC: ${tocSummary.lineCount} líneas; ~${tocSummary.tableData} TABLE DATA; ~${tocSummary.tableSchema} TABLE (schema)`
    );

    if (args.dryRun) {
      log('Modo --dry-run: no se ejecuta pg_restore contra la base.');
      log('Validaciones previas OK.');
      await fsp.rm(tmpRoot, { recursive: true, force: true });
      tmpRoot = null;
      console.log(`\n[restore-db] Dry-run completado. Log: ${logPath}\n`);
      shutdown(0);
    }

    let dbUrl;
    let dbSource;
    try {
      const resolved = resolveTargetDbUrl();
      dbUrl = resolved.url;
      dbSource = resolved.source;
    } catch (e) {
      await fsp.rm(tmpRoot, { recursive: true, force: true });
      throw e;
    }
    const displayUrl = redactDbUrlForDisplay(dbUrl);

    if (!skipPrompts) {
      if (!process.stdin.isTTY) {
        await fsp.rm(tmpRoot, { recursive: true, force: true });
        tmpRoot = null;
        log('ERROR: sin TTY debes usar --yes para confirmar restauración destructiva.');
        shutdown(2);
      }
      if (!rl) {
        rl = readline.createInterface({ input: process.stdin, output: process.stdout });
      }
      console.log('');
      console.log('⚠️  ATENCIÓN: Esto REEMPLAZARÁ todos los datos actuales en la base destino.');
      console.log(`    Backup a restaurar: ${filename} (${sizeStr})  fecha en nombre: ${dateStr}`);
      console.log(`    pg_restore --list: OK (${tocSummary.lineCount} entradas TOC)`);
      console.log(`    Base de datos destino: ${displayUrl}`);
      console.log(`    Variable usada: ${dbSource}`);
      console.log('');
      const c1 = await prompt(
        rl,
        "¿Continuar? (escribe 'RESTORE' para confirmar): "
      );
      if (c1 !== 'RESTORE') {
        log('Cancelado por el usuario (confirmación 1).');
        await fsp.rm(tmpRoot, { recursive: true, force: true });
        tmpRoot = null;
        shutdown(0);
      }
      if (dbSource === 'SUPABASE_DB_URL') {
        console.log('');
        console.log('⚠️  Estás usando SUPABASE_DB_URL (no hay RESTORE_DB_URL).');
        console.log('    Suele ser producción. Segunda confirmación obligatoria.');
        console.log('');
        const c2 = await prompt(
          rl,
          "Escribe 'USE_PRODUCTION_DB' para confirmar restauración en esta URL: "
        );
        if (c2 !== 'USE_PRODUCTION_DB') {
          log('Cancelado por el usuario (confirmación producción).');
          await fsp.rm(tmpRoot, { recursive: true, force: true });
          tmpRoot = null;
          shutdown(0);
        }
      }
    } else {
      log(
        `Sin prompts interactivos (--yes). Destino: ${displayUrl} (${dbSource})`
      );
    }

    const timeoutSec = parseInt(optionalEnv('RESTORE_TIMEOUT_SEC', '1800'), 10) || 1800;
    await runPgRestore(dbUrl, localPath, timeoutSec, logStream);

    try {
      execSync('psql --version', { stdio: 'pipe', timeout: 5000 });
      runPsqlSummary(dbUrl, logStream);
    } catch {
      log('psql no disponible; omitiendo resumen de filas/tablas.');
    }

    await fsp.rm(tmpRoot, { recursive: true, force: true });
    tmpRoot = null;
    log('Restore finalizado.');
    console.log(`\n[restore-db] OK. Log completo: ${logPath}\n`);
    shutdown(0);
  } catch (err) {
    if (tmpRoot) {
      await fsp.rm(tmpRoot, { recursive: true, force: true }).catch(() => {});
    }
    const msg = sanitizeForLog(err.message || String(err));
    log(`ERROR: ${msg}`);
    console.error(`\n[restore-db] FATAL: ${msg}\n`);
    shutdown(1);
  }
}

main();
