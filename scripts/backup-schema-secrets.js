#!/usr/bin/env node
/**
 * Gate de secretos para dumps --schema-only.
 *
 * Busca VALORES literales que parezcan credenciales embebidas en el SQL.
 * No marca identificadores como p_nueva_password o admin_reset_password.
 *
 * Uso:
 *   node scripts/backup-schema-secrets.js path/to/schema.sql
 * Exit 0 = limpio; 1 = hallazgos; 2 = uso/archivo.
 */

'use strict';

/** @type {{ name: string, re: RegExp }[]} */
const LITERAL_SECRET_PATTERNS = [
  {
    name: 'postgres_url_with_password',
    // postgres://user:pass@host — exige user y password no vacíos antes de @
    re: /postgres(?:ql)?:\/\/[^:\s/'"]+:[^@\s/'"]+@/gi,
  },
  {
    name: 'jwt_like',
    re: /\beyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\b/g,
  },
  {
    name: 'openai_sk',
    re: /\bsk-[A-Za-z0-9]{20,}\b/g,
  },
  {
    name: 'bearer_token',
    re: /\bBearer\s+[A-Za-z0-9._\-+=/]{20,}/gi,
  },
  {
    name: 'github_token',
    re: /\b(?:ghp_|github_pat_|gho_|ghs_|ghu_)[A-Za-z0-9_]{20,}\b/g,
  },
];

/**
 * Solo patrón + línea — no loguear fragmentos del match (pueden ser user/password).
 * @param {string} sql
 * @returns {{ name: string, line: number }[]}
 */
function findLiteralSecrets(sql) {
  const findings = [];
  const text = String(sql || '');
  for (const { name, re } of LITERAL_SECRET_PATTERNS) {
    re.lastIndex = 0;
    let m;
    while ((m = re.exec(text)) !== null) {
      const idx = m.index;
      const line = text.slice(0, idx).split(/\r?\n/).length;
      findings.push({ name, line });
      // Evitar loops infinitos si el regex no avanza
      if (m[0].length === 0) re.lastIndex += 1;
    }
  }
  return findings;
}

function main() {
  const file = process.argv[2];
  if (!file) {
    console.error('Uso: node scripts/backup-schema-secrets.js <schema.sql>');
    process.exit(2);
  }
  const fs = require('node:fs');
  if (!fs.existsSync(file)) {
    console.error(`No existe: ${file}`);
    process.exit(2);
  }
  const sql = fs.readFileSync(file, 'utf8');
  const findings = findLiteralSecrets(sql);
  if (!findings.length) {
    console.log('✓ schema.sql: sin secretos literales detectados');
    process.exit(0);
  }
  console.error(`✗ ${findings.length} posible(s) secreto(s) literal(es) en el schema dump:`);
  for (const f of findings) {
    console.error(`  línea ${f.line}: [${f.name}] ${f.sample}`);
  }
  console.error('No se pushea. Revisa a mano — hallazgo de seguridad aparte.');
  process.exit(1);
}

if (require.main === module) main();

module.exports = { findLiteralSecrets, LITERAL_SECRET_PATTERNS };
