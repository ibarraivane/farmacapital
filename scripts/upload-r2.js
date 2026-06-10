#!/usr/bin/env node
/* eslint-disable */
/**
 * FARMACAPITAL — Upload a Cloudflare R2 (STUB)
 *
 * Status: NO ACTIVADO. Este archivo queda preparado para el día que
 * quieras añadir un segundo destino de backup en R2.
 *
 * Cómo activarlo (futuro):
 *   1. Crear bucket R2 en Cloudflare dashboard.
 *   2. Crear API token R2 (Account → R2 → Manage R2 API Tokens).
 *   3. Agregar a los Secrets de GitHub Actions:
 *        R2_ACCOUNT_ID
 *        R2_ACCESS_KEY_ID
 *        R2_SECRET_ACCESS_KEY
 *        R2_BUCKET_NAME
 *        R2_ENABLED=true
 *   4. Instalar dependencia:
 *        npm i -D @aws-sdk/client-s3
 *   5. Descomentar el bloque `doUpload()` más abajo.
 *   6. En .github/workflows/backup.yml, después del paso de pg_dump añadir:
 *        - name: Upload a R2
 *          if: env.R2_ENABLED == 'true'
 *          run: node scripts/upload-r2.js "$BACKUP_PATH"
 *
 * Uso (cuando esté activo):
 *   node scripts/upload-r2.js /tmp/backups/farmacapital-backup-YYYY-MM-DD.backup
 *
 * Exit codes:
 *   0  → subida correcta (o stub deshabilitado)
 *   1  → error
 *   2  → faltan envs
 *   3  → archivo no existe
 */

'use strict';

const fs = require('node:fs');
const path = require('node:path');

function log(msg) {
  console.log(`[upload-r2] ${new Date().toISOString()} ${msg}`);
}

function errlog(msg, extra) {
  const line = `[upload-r2] ${new Date().toISOString()} ERROR: ${msg}`;
  if (extra === undefined) console.error(line);
  else console.error(line, sanitize(extra));
}

function sanitize(v) {
  try {
    const s = typeof v === 'string' ? v : JSON.stringify(v);
    return s.replace(/(access[_-]?key|secret|token)=([^&\s"']+)/gi, '$1=***');
  } catch {
    return '[unserializable]';
  }
}

async function main() {
  if (process.env.R2_ENABLED !== 'true') {
    log('R2 no está habilitado (R2_ENABLED != "true"). Saltando upload.');
    process.exit(0);
  }

  const file = process.argv[2];
  if (!file) {
    errlog('Uso: node scripts/upload-r2.js <path-al-backup>');
    process.exit(1);
  }
  if (!fs.existsSync(file)) {
    errlog(`Archivo no existe: ${file}`);
    process.exit(3);
  }

  const required = ['R2_ACCOUNT_ID', 'R2_ACCESS_KEY_ID', 'R2_SECRET_ACCESS_KEY', 'R2_BUCKET_NAME'];
  for (const k of required) {
    if (!process.env[k] || !process.env[k].trim()) {
      errlog(`Falta variable ${k}`);
      process.exit(2);
    }
  }

  // -------------------------------------------------------------
  // BLOQUE A DESCOMENTAR CUANDO SE ACTIVE R2
  // -------------------------------------------------------------
  // const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
  //
  // const client = new S3Client({
  //   region: 'auto',
  //   endpoint: `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  //   credentials: {
  //     accessKeyId: process.env.R2_ACCESS_KEY_ID,
  //     secretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
  //   },
  // });
  //
  // const key = path.basename(file);
  // const body = fs.createReadStream(file);
  //
  // log(`Subiendo ${key} a R2 bucket ${process.env.R2_BUCKET_NAME}...`);
  //
  // await client.send(new PutObjectCommand({
  //   Bucket: process.env.R2_BUCKET_NAME,
  //   Key: key,
  //   Body: body,
  //   ContentType: 'application/octet-stream',
  // }));
  //
  // log('Upload a R2 completado');
  // -------------------------------------------------------------

  log('STUB: la lógica de upload a R2 está comentada. Sigue las instrucciones del header para activarla.');
  process.exit(0);
}

main().catch((err) => {
  errlog('Fallo inesperado', err && err.message);
  process.exit(1);
});
