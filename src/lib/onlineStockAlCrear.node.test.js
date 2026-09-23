/**
 * Contrato: compras online comprometen stock al crear el pedido
 * (misma tubería FEFO que Recibir / Rappi), no al surtir.
 */
const { readFileSync } = require("fs");
const { join } = require("path");
const { describe, it } = require("node:test");
const assert = require("node:assert/strict");

const patch = readFileSync(
  join(__dirname, "../../sql/patch_online_stock_al_crear_20260923.sql"),
  "utf8"
);

describe("patch_online_stock_al_crear_20260923", () => {
  it("compromete stock FEFO al crear el pedido online", () => {
    assert.match(patch, /fn_pedido_online_comprometer_stock/);
    assert.match(patch, /stock_consumido_at/);
    assert.match(patch, /consume_stock_via_lotes/);
    assert.match(patch, /fn_pedido_online_comprometer_stock\(v_pedido_id\)/);
  });

  it("al surtir no vuelve a bajar si ya estaba comprometido", () => {
    assert.match(patch, /v_ya_consumido/);
    assert.match(patch, /stock_ya_comprometido/);
    assert.match(patch, /if not v_ya_consumido/);
  });

  it("cancelar\/eliminar solo restockea si hubo consumo real", () => {
    assert.match(patch, /fn_pedido_online_debe_restock/);
    assert.match(patch, /fn_pedido_online_liberar_stock/);
    assert.match(
      patch,
      /return v_pedido\.estado in \('listo', 'completado'\)/
    );
  });

  it("el check de stock ignora lotes caducados", () => {
    assert.match(
      patch,
      /fecha_caducidad is null or l\.fecha_caducidad >= current_date/
    );
  });
});
