"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const path = require("path");
const { pathToFileURL } = require("url");

describe("pedidoOnlineTimer", async () => {
  const mod = await import(pathToFileURL(path.join(__dirname, "pedidoOnlineTimer.js")).href);
  const { formatDuracionCorta, cronometroPedidoOnline } = mod;

  it("formatea días, horas y minutos", () => {
    assert.equal(formatDuracionCorta(90 * 1000), "1 min");
    assert.equal(formatDuracionCorta(90 * 60 * 1000), "1h 30m");
    assert.equal(formatDuracionCorta((3 * 86400 + 5 * 3600) * 1000), "3d 5h");
  });

  it("cuenta espera desde created_at si no se ha enviado", () => {
    const now = Date.parse("2026-09-18T05:33:00Z");
    const t = cronometroPedidoOnline(
      { created_at: "2026-09-15T15:33:00Z", tipo_entrega: "envio", estado: "pendiente" },
      now
    );
    assert.equal(t.enviado, false);
    assert.equal(t.running, true);
    assert.equal(t.tone, "late");
    assert.match(t.label, /en espera/);
    assert.equal(t.label.startsWith("2d ") || t.label.startsWith("3d "), true);
  });

  it("se detiene al marcar en ruta", () => {
    const t = cronometroPedidoOnline({
      created_at: "2026-09-18T10:00:00Z",
      tipo_entrega: "envio",
      delivery_status: "in_route",
      logistics_meta: { envio: { estado: "en_ruta", en_ruta_at: "2026-09-18T11:15:00Z" } },
    }, Date.parse("2026-09-18T18:00:00Z"));
    assert.equal(t.enviado, true);
    assert.equal(t.running, false);
    assert.equal(t.label, "Enviado en 1h 15m");
  });
});
