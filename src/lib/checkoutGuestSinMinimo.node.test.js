/**
 * Contrato: checkout domicilio de invitado no se rompe por guest_* ni por $150.
 */
const { readFileSync } = require("fs");
const { join } = require("path");
const { describe, it } = require("node:test");
const assert = require("node:assert/strict");

const patch = readFileSync(
  join(__dirname, "../../sql/patch_checkout_guest_sin_minimo_20261005.sql"),
  "utf8"
);

describe("patch_checkout_guest_sin_minimo_20261005", () => {
  it("guarda guest_nombre, guest_telefono y guest_email en el INSERT", () => {
    assert.match(patch, /guest_nombre,\s*guest_telefono,\s*guest_email/);
    assert.match(patch, /case when p_session_token is null then v_telefono_norm else null end/);
  });

  it("no vuelve a exigir mínimo de \$150 en domicilio", () => {
    assert.doesNotMatch(patch, /v_subtotal\s*<\s*150/);
    assert.doesNotMatch(patch, /mínimo de \$150/);
  });

  it("sigue comprometiendo stock FEFO al crear", () => {
    assert.match(patch, /fn_pedido_online_comprometer_stock\(v_pedido_id\)/);
  });
});
