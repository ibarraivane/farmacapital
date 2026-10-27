#!/usr/bin/env node
/**
 * Carga inicial de miniaturas (bucket `productos` → _miniaturas/480/).
 * Corre el mismo job del cron en bucle hasta que no quede nada pendiente.
 *
 * Uso (necesita la service role; no la subas a git):
 *   node --env-file=.env.local scripts/generar-miniaturas.js
 *
 * Variables: SUPABASE_URL (o REACT_APP_SUPABASE_URL) y SUPABASE_SERVICE_ROLE_KEY.
 * Requiere la migración supabase/migrations/20261027120000_miniaturas_pendientes.sql.
 * Es seguro cortarlo y volver a correrlo: solo hace lo que falta.
 */

'use strict';

const { getSupabaseAdminConfig } = require('../api/_lib/supabaseAdmin');
const { runMiniaturasJob } = require('../api/_lib/miniaturasJob');

async function main() {
  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    console.error('Faltan SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY.');
    process.exit(1);
  }

  let total = 0;
  let errores = 0;
  for (let vuelta = 1; ; vuelta += 1) {
    const r = await runMiniaturasJob({
      supabaseUrl,
      serviceKey,
      limite: 300,
      presupuestoMs: 10 * 60 * 1000,
      concurrencia: 6,
    });
    total += r.hechas;
    errores += r.con_error;
    console.log(
      `Vuelta ${vuelta}: ${r.hechas} hechas, ${r.con_error} con error ` +
        `(${r.kb_originales} KB → ${r.kb_miniaturas} KB)`
    );
    r.errores.forEach((e) => console.log(`  ! ${e.nombre}: ${e.error}`));
    // Sin avance: o terminó, o solo quedan fotos que fallan siempre.
    if (!r.quedan_mas || r.hechas === 0) break;
  }
  console.log(`Listo: ${total} miniaturas, ${errores} errores.`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
