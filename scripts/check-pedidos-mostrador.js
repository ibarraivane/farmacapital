#!/usr/bin/env node
"use strict";

/**
 * Chequeos estáticos del módulo «Lo que buscan».
 * Corre sin React: node scripts/check-pedidos-mostrador.js
 */
const fs = require("fs");
const path = require("path");
const { pathToFileURL } = require("url");
const { spawnSync } = require("child_process");

const root = path.resolve(__dirname, "..");
const errors = [];

function read(rel) {
  return fs.readFileSync(path.join(root, rel), "utf8");
}

function fail(msg) {
  errors.push(msg);
}

function mustInclude(haystack, needle, msg) {
  if (!haystack.includes(needle)) fail(msg);
}

const sql = read("sql/patch_pedidos_mostrador_20260904.sql");
const ui = read("src/PedidosMostradorModule.jsx");
const constants = read("src/constants.js");
const permissions = read("src/utils/permissions.js");
const admin = read("src/Admin.jsx");
const routes = read("src/shared/adminRoutes.js");
const badges = read("src/hooks/useSidebarBadges.js");
const manual = read("src/lib/manualContenido.js");

// ── SQL: campos de negocio pedididos por el usuario ─────────
for (const col of [
  "cliente_nombre",
  "cliente_telefono",
  "pago_tipo",
  "pago_monto",
  "anotado_por",
]) {
  mustInclude(sql, col, `SQL debe tener columna/campo ${col}`);
}
mustInclude(sql, "check (pago_tipo in ('nada', 'deposito', 'completo'))", "SQL debe restringir pago_tipo");
mustInclude(sql, "empleado_crear_solicitud_mostrador", "SQL debe crear RPC de alta");
mustInclude(sql, "empleado_listar_solicitudes_mostrador", "SQL debe crear RPC de listado");
mustInclude(sql, "empleado_actualizar_estado_solicitud_mostrador", "SQL debe crear RPC de estado");
mustInclude(sql, "empleado_contar_solicitudes_mostrador_abiertas", "SQL debe crear RPC de conteo/badge");
mustInclude(sql, "empleado_ranking_solicitudes_mostrador", "SQL debe crear RPC de ranking");

// ── UI: formulario + lista ───────────────────────────────────
mustInclude(ui, "clienteNombre", "UI debe capturar nombre del cliente");
mustInclude(ui, "clienteTel", "UI debe capturar teléfono");
mustInclude(ui, "pagoTipo", "UI debe capturar tipo de pago/depósito");
mustInclude(ui, "PAGOS", "UI debe usar catálogo PAGOS (nada/deposito/completo)");
mustInclude(ui, "Vendedor:", "UI debe mostrar vendedor en la lista");
mustInclude(ui, "Cliente:", "UI debe mostrar cliente en la lista");
mustInclude(ui, "p_cliente_nombre", "UI debe enviar cliente al RPC");
mustInclude(ui, "p_cliente_telefono", "UI debe enviar teléfono al RPC");
mustInclude(ui, "p_pago_tipo", "UI debe enviar pago_tipo al RPC");
mustInclude(ui, "p_pago_monto", "UI debe enviar pago_monto al RPC");
mustInclude(ui, "empleado_crear_solicitud_mostrador", "UI debe llamar RPC de crear");
mustInclude(ui, "farmacapital_session_token", "UI debe usar el token de sesión del admin");
mustInclude(ui, "anotado_por_nombre", "UI debe mostrar el vendedor que anotó");

// ── Cableado menú / permisos / rutas ─────────────────────────
mustInclude(constants, "ped_mostrador", "constants debe registrar ped_mostrador");
mustInclude(constants, "Lo que buscan", "constants debe etiquetar el módulo");
mustInclude(permissions, "ped_mostrador", "permissions debe incluir ped_mostrador para vendedor");
mustInclude(admin, "PedidosMostradorModule", "Admin debe lazy-cargar el módulo");
mustInclude(admin, 'case "ped_mostrador"', "Admin debe enrutar ped_mostrador");
mustInclude(routes, "lo-que-buscan", "adminRoutes debe tener slug lo-que-buscan");
mustInclude(badges, "empleado_contar_solicitudes_mostrador_abiertas", "badge debe contar abiertas");
mustInclude(manual, "lo-que-buscan", "Manual debe documentar el módulo");

// RPCs UI ⊆ SQL (salvo búsqueda de productos, que vive en otro patch)
const uiRpcs = [...ui.matchAll(/supabase\.rpc\("([^"]+)"/g)].map((m) => m[1]);
const sqlFuncs = new Set(
  [...sql.matchAll(/function public\.(empleado_\w+)/g)].map((m) => m[1]),
);
for (const rpc of uiRpcs) {
  if (rpc === "empleado_buscar_productos_venta") continue;
  if (!sqlFuncs.has(rpc)) fail(`UI llama ${rpc} pero no está en el patch SQL`);
}

async function runUnitTests() {
  const unit = spawnSync(
    process.execPath,
    ["--test", path.join(root, "src/lib/pedidosMostrador.node.test.js")],
    { encoding: "utf8" },
  );
  if (unit.status !== 0) {
    fail("Falló pedidosMostrador.node.test.js:\n" + (unit.stdout || "") + (unit.stderr || ""));
  }

  const libUrl = pathToFileURL(path.join(root, "src/lib/pedidosMostrador.js")).href;
  const {
    PAGOS,
    ESTADOS_SOLICITUD,
    puedeGuardarSolicitud,
    etiquetaPago,
  } = await import(libUrl);

  if (!PAGOS.some((p) => p.id === "deposito") || !PAGOS.some((p) => p.id === "completo")) {
    fail("PAGOS debe incluir deposito y completo");
  }
  if (!ESTADOS_SOLICITUD.some((e) => e.id === "pendiente")) {
    fail("ESTADOS_SOLICITUD incompleto");
  }
  if (!puedeGuardarSolicitud({ texto: "Bumetadina", cantidad: 1 })) {
    fail("puedeGuardarSolicitud debería aceptar Bumetadina x1");
  }
  if (!/Depósito/.test(etiquetaPago("deposito", 100))) {
    fail("etiquetaPago(deposito, 100) debe mencionar Depósito");
  }
}

runUnitTests()
  .then(() => {
    if (errors.length) {
      console.error("check-pedidos-mostrador FALLÓ:\n- " + errors.join("\n- "));
      process.exit(1);
    }
    console.log("check-pedidos-mostrador OK (SQL + UI + cableado + unit)");
  })
  .catch((err) => {
    console.error("check-pedidos-mostrador error:", err);
    process.exit(1);
  });
