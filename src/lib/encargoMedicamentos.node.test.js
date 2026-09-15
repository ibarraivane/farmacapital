"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const path = require("path");
const { pathToFileURL } = require("url");

describe("encargoMedicamentos", async () => {
  // CRA resolves extensionless imports; for node we load via a tiny loader shim
  // by evaluating through babel-free duplicate of pure functions is overkill —
  // instead import the ESM with a custom resolver stub.
  const { createRequire } = require("module");
  const requireFrom = createRequire(__filename);

  // Use dynamic import with rewritten relative path via data URL? Simpler: spawn jest via local.
  // Fallback: read and Function-eval is bad. Use node --experimental-vm-modules with alias.
  const fs = require("fs");
  const configSrc = fs.readFileSync(path.join(__dirname, "../config/encargo.js"), "utf8");
  const libSrc = fs.readFileSync(path.join(__dirname, "encargoMedicamentos.js"), "utf8");
  const fechaSrc = fs.readFileSync(path.join(__dirname, "fecha.js"), "utf8");

  const fechaUrl = pathToFileURL(path.join(__dirname, "fecha.js")).href;
  const configUrl = pathToFileURL(path.join(__dirname, "../config/encargo.js")).href;
  const libUrl = pathToFileURL(path.join(__dirname, "encargoMedicamentos.js")).href;

  // Write temp copies with .js extensions in imports
  const os = require("os");
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "encargo-"));
  const rewrite = (src, map) => {
    let out = src;
    for (const [from, to] of Object.entries(map)) {
      out = out.split(from).join(to);
    }
    return out;
  };
  fs.writeFileSync(path.join(tmp, "fecha.js"), fechaSrc);
  fs.writeFileSync(
    path.join(tmp, "encargo-config.js"),
    rewrite(configSrc, { '"../lib/fecha"': '"./fecha.js"' }),
  );
  fs.writeFileSync(
    path.join(tmp, "encargoMedicamentos.js"),
    rewrite(libSrc, { '"../config/encargo"': '"./encargo-config.js"' }),
  );

  const mod = await import(pathToFileURL(path.join(tmp, "encargoMedicamentos.js")).href);

  it("vigencia default 3 días", () => {
    assert.equal(mod.TIEMPO_VIGENCIA_COTIZACION_DIAS_DEFAULT, 3);
    assert.equal(mod.tiempoVigenciaCotizacionDiasFromEnv({}), 3);
    assert.equal(mod.tiempoVigenciaCotizacionDiasFromEnv({ TIEMPO_VIGENCIA_COTIZACION_DIAS: "5" }), 5);
    const from = new Date("2026-09-15T12:00:00.000Z");
    assert.equal(mod.calcularVigenciaHasta(from, 3).toISOString(), "2026-09-18T12:00:00.000Z");
  });

  it("cadena fría bloquea domicilio", () => {
    assert.equal(mod.metodoEntregaPermitido({ requiere_cadena_fria: true, metodo_entrega: "domicilio" }).ok, false);
    assert.equal(mod.metodoEntregaPermitido({ requiere_cadena_fria: true, metodo_entrega: "entrega_personalizada" }).ok, true);
  });

  it("aviso y encargo validan teléfono/receta", () => {
    assert.equal(mod.validarAvisoDisponibilidad({ producto_id: 1, telefono: "123" }).ok, false);
    assert.equal(
      mod.validarAvisoDisponibilidad({ producto_id: 42, nombre: "Ana", telefono: "55-1234-5678" }).value
        .cliente_telefono,
      "5512345678",
    );
    assert.equal(
      mod.validarEncargoPublico({
        nombre: "Luis",
        telefono: "5512345678",
        nombre_medicamento: "Exkutera",
        cantidad: 1,
        requiere_receta: true,
      }).ok,
      false,
    );
    assert.equal(
      mod.validarEncargoPublico({
        nombre: "Luis",
        telefono: "5512345678",
        nombre_medicamento: "Exkutera",
        cantidad: 2,
        requiere_receta: true,
        receta_url: "https://x/r.jpg",
      }).ok,
      true,
    );
  });

  it("cotización y aceptación", () => {
    assert.deepEqual(mod.COTIZACION_DISPONIBILIDAD, [
      "disponible",
      "sujeto_a_confirmacion",
      "no_disponible",
    ]);
    const ok = mod.validarCotizacionAdmin({
      precio_unitario: 100.5,
      cantidad: 2,
      tiempo_estimado_dias: 3,
      disponibilidad: "sujeto_a_confirmacion",
    });
    assert.equal(ok.ok, true);
    assert.equal(ok.value.precio_total, 201);
    assert.equal(mod.puedeMarcarEncargoAceptado({ cotizacion_estado: "enviada" }), false);
    assert.equal(mod.puedeMarcarEncargoAceptado({ cotizacion_estado: "aceptada" }), true);
  });

  it("wa.me builders", () => {
    const a = mod.buildAvisoDisponibilidadWhatsApp({
      telefono: "5512345678",
      nombre: "Ana",
      producto_nombre: "Paracetamol",
    });
    assert.match(a, /^https:\/\/wa\.me\/525512345678\?text=/);
    assert.match(decodeURIComponent(a), /Paracetamol/);
  });

  it("estados operativos vendedor", () => {
    assert.deepEqual(mod.ENCARGO_ESTADOS_OPERATIVOS_VENDEDOR, [
      "consiguiendo",
      "listo_para_entrega",
      "entregado",
    ]);
  });
});
