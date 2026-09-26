const { readFileSync } = require("fs");
const { join } = require("path");
const { describe, it } = require("node:test");
const assert = require("node:assert/strict");

const sql = readFileSync(
  join(__dirname, "../../sql/patch_lotes_bloquear_patch_directo_20260925.sql"),
  "utf8"
);

describe("patch lotes sin PATCH directo", () => {
  it("el rol service_role no puede cambiar piezas ni activo", () => {
    assert.match(sql, /fn_lotes_bloquear_patch_directo/);
    assert.match(sql, /security invoker/);
    assert.match(sql, /'service_role', 'anon', 'authenticated', 'authenticator'/);
    assert.match(sql, /new\.cantidad_actual is distinct from old\.cantidad_actual/);
    assert.match(sql, /new\.activo is distinct from old\.activo/);
    assert.match(sql, /before update of cantidad_actual, activo on public\.lotes/);
    assert.match(sql, /errcode = '42501'/);
  });

  it("la auditoría llena accion del esquema viejo y avisa si falla", () => {
    assert.match(sql, /alter column accion drop not null/);
    assert.match(sql, /accion, registro_id/);
    assert.match(sql, /TG_TABLE_NAME, TG_OP, TG_OP, v_pk/);
    assert.match(sql, /raise warning 'fn_audit_trigger fallo/);
    assert.doesNotMatch(sql, /exception when others then\s+return coalesce\(NEW, OLD\)/);
  });

  it("la restauración solo revive lotes en cero sin salida posterior", () => {
    assert.match(sql, /1782, 391, 255, 2313, 2374, 2388, 2365/);
    assert.match(sql, /l\.cantidad_actual = 0/);
    assert.match(sql, /l\.activo = false/);
    assert.match(sql, /m\.tipo = 'salida'/);
    assert.match(sql, /Restauracion stock fantasma 2026-09-25/);
  });
});
