#!/usr/bin/env node
/**
 * Falla el build si el front llama a un RPC que no está definido en sql/.
 *
 * Existe porque en agosto 2026 había 11 RPCs invocados desde src/ que solo
 * vivían en Supabase, aplicados a mano: dos pestañas de Inventario (Aprobar PVP
 * y Precio por caducar) no funcionaban en un entorno nuevo y nadie lo sabía.
 *
 * Uso: node scripts/check-rpcs-existen.js
 */
const fs = require("fs");
const path = require("path");

function listar(dir, acc = []) {
  if (!fs.existsSync(dir)) return acc;
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) listar(p, acc);
    else acc.push(p);
  }
  return acc;
}

const llamados = new Map();
for (const f of listar("src")) {
  if (!/\.jsx?$/.test(f) || f.includes(".test.")) continue;
  const src = fs.readFileSync(f, "utf8");
  for (const m of src.matchAll(/\.rpc\(\s*["']([\w]+)["']/g)) {
    if (!llamados.has(m[1])) llamados.set(m[1], f);
  }
}

const definidos = new Set();
for (const f of listar("sql")) {
  if (!f.endsWith(".sql")) continue;
  const src = fs.readFileSync(f, "utf8");
  for (const m of src.matchAll(/function\s+(?:public\.)?"?(\w+)"?\s*\(/gi)) {
    definidos.add(m[1].toLowerCase());
  }
}

const faltan = [...llamados].filter(([n]) => !definidos.has(n.toLowerCase()));

if (faltan.length) {
  console.error(`\n✗ ${faltan.length} RPC(s) llamados desde src/ sin definición en sql/:\n`);
  for (const [n, f] of faltan) console.error(`    ${n}\n        ← ${f}`);
  console.error(
    "\n  Expórtalos de Supabase con pg_get_functiondef y comitéalos en sql/migrations/.",
    "\n  Sin esto el repo no reconstruye la base.\n"
  );
  process.exit(1);
}

console.log(`✓ ${llamados.size} RPCs llamados, todos definidos en sql/.`);
