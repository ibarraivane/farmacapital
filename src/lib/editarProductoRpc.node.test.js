"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("fs");
const path = require("path");
const { pathToFileURL } = require("url");

describe("editar producto", async () => {
  const mod = await import(pathToFileURL(path.join(__dirname, "editarProductoRpc.js")).href);
  const { esTimeoutEditarProducto, mensajeErrorEditarProducto, rpcAdminEditarProducto } = mod;

  it("reconoce el corte de Postgres al guardar el nombre", () => {
    assert.equal(esTimeoutEditarProducto("canceling statement due to statement timeout"), true);
    assert.match(
      mensajeErrorEditarProducto({ message: "canceling statement due to statement timeout" }),
      /tardó demasiado/,
    );
    assert.equal(
      mensajeErrorEditarProducto({ message: "El nombre no puede quedar vacío." }),
      "El nombre no puede quedar vacío.",
    );
  });

  it("reintenta si Postgres cancela por timeout y el segundo intento queda", async () => {
    const esperas = [];
    const rpc = async () => {
      rpc.calls += 1;
      if (rpc.calls === 1) {
        return { data: null, error: { message: "canceling statement due to statement timeout" } };
      }
      return { data: { success: true }, error: null };
    };
    rpc.calls = 0;

    const res = await rpcAdminEditarProducto(
      { rpc },
      { p_session_token: "t", p_producto_id: 1, p_patch: { nombre: "Fexofenadina 180 mg C/10" } },
      {
        esperar: (ms) => {
          esperas.push(ms);
          return Promise.resolve();
        },
      },
    );

    assert.equal(res.error, null);
    assert.equal(res.data.success, true);
    assert.equal(rpc.calls, 2);
    assert.deepEqual(esperas, [300]);
  });

  it("no reintenta un error que no es timeout", async () => {
    let calls = 0;
    const res = await rpcAdminEditarProducto(
      {
        rpc: async () => {
          calls += 1;
          return { data: null, error: { message: "Producto 9 no encontrado" } };
        },
      },
      { p_patch: { nombre: "x" } },
      { esperar: () => Promise.resolve() },
    );
    assert.match(res.error.message, /no encontrado/);
    assert.equal(calls, 1);
  });

  it("la celda de nombre no manda dos guardados ni deja el input en negro", () => {
    const src = fs.readFileSync(path.join(__dirname, "../InventarioModule.jsx"), "utf8");
    assert.match(src, /rpcAdminEditarProducto\(supabase/);
    assert.match(src, /inlineCommitLock/);
    assert.doesNotMatch(src, /disabled:\s*inlineSaving/);
    assert.match(src, /farmacapital-field-input/);
    assert.match(src, /background: "#ffffff"/);
    assert.match(src, /colorScheme: "light"/);
  });

  it("el SQL de guardado no consulta information_schema", () => {
    const sql = fs.readFileSync(
      path.join(__dirname, "../../sql/patch_admin_editar_producto_sin_timeout_20260926.sql"),
      "utf8",
    );
    const fn = sql
      .slice(sql.indexOf("create or replace function public.admin_editar_producto"))
      .replace(/--[^\n]*/g, "");
    assert.match(fn, /from pg_attribute/);
    assert.doesNotMatch(fn, /information_schema/);
    assert.match(fn, /'nombre'/);
    assert.match(fn, /lock_timeout', '2s'/);
  });
});
