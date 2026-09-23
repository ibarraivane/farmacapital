#!/usr/bin/env node
"use strict";

/**
 * Chequeos estáticos del módulo admin «Cotizaciones».
 * Corre sin React: node scripts/check-cotizaciones.js
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

const sql = read("sql/patch_cotizaciones_20260921.sql");
const lib = read("src/lib/cotizaciones.js");
const ui = read("src/CotizacionesModule.jsx");
const mostrador = [
  read("src/PedidosMostradorModule.jsx"),
  read("src/components/FilaSolicitudMostrador.jsx"),
].join("\n");
const constants = read("src/constants.js");
const permissions = read("src/utils/permissions.js");
const admin = read("src/Admin.jsx");
const routes = read("src/shared/adminRoutes.js");
const manual = read("src/lib/manualContenido.js");

mustInclude(sql, "create table if not exists public.cotizaciones", "SQL debe crear cotizaciones");
mustInclude(sql, "create table if not exists public.cotizacion_items", "SQL debe crear cotizacion_items");
mustInclude(sql, "create table if not exists public.cotizacion_fuentes", "SQL debe crear cotizacion_fuentes");
mustInclude(sql, "fn_require_admin", "RPCs de cotización deben exigir admin");
mustInclude(sql, "admin_crear_cotizacion", "SQL debe crear RPC de alta");
mustInclude(sql, "admin_listar_cotizaciones", "SQL debe crear RPC de listado");
mustInclude(sql, "admin_obtener_cotizacion", "SQL debe crear RPC de ficha");
mustInclude(sql, "admin_agregar_cotizacion_fuente", "SQL debe crear RPC de fuentes");
mustInclude(sql, "admin_elegir_cotizacion_fuente", "SQL debe crear RPC de elegir fuente");
mustInclude(sql, "admin_promover_solicitud_a_cotizacion", "SQL debe promover desde Lo que buscan");
mustInclude(sql, "solicitud_id", "SQL debe ligar opcionalmente a solicitudes_mostrador");
mustInclude(sql, "check (origen in ('admin', 'tienda', 'mostrador', 'whatsapp', 'telefono', 'otro'))", "SQL debe restringir origen");
mustInclude(sql, "check (tipo_margen in ('marca', 'generico'))", "SQL debe restringir tipo_margen");

mustInclude(lib, "precioSugeridoCotizacion", "lib debe sugerir precio con recargo Recibir");
mustInclude(lib, "numerosLineaCotizacion", "lib debe separar recargo y margen");
mustInclude(lib, "payloadPromoverDesdeSolicitud", "lib debe mapear una solicitud a cotización");
mustInclude(lib, "COTIZ_OPEN_STORAGE_KEY", "lib debe pasar la ficha entre módulos");

mustInclude(ui, "farmacapital-field-input", "UI debe usar inputs de fondo blanco");
mustInclude(ui, "farmacapital-field-select", "UI debe usar selects claros");
mustInclude(ui, "colorScheme", "UI debe forzar color-scheme light");
mustInclude(ui, "Recargo", "UI debe etiquetar recargo, no venderlo como margen");
mustInclude(ui, "Margen", "UI debe mostrar margen sobre venta");
mustInclude(ui, "admin_listar_cotizaciones", "UI debe listar cotizaciones");
mustInclude(ui, "admin_elegir_cotizacion_fuente", "UI debe elegir fuente");

mustInclude(mostrador, "Abrir cotización", "Lo que buscan debe promover a Cotizaciones");
mustInclude(mostrador, "admin_promover_solicitud_a_cotizacion", "Lo que buscan debe llamar promover");
mustInclude(mostrador, "stashCotizacionAbierta", "Lo que buscan debe abrir la ficha");

mustInclude(constants, '"cotiz"', "constants debe registrar cotiz");
mustInclude(constants, "Cotizaciones", "constants debe etiquetar el módulo");
mustInclude(permissions, '"cotiz"', "permissions debe bloquear cotiz al vendedor");
mustInclude(admin, "CotizacionesModule", "Admin debe lazy-cargar el módulo");
mustInclude(admin, 'case "cotiz"', "Admin debe enrutar cotiz");
mustInclude(routes, "cotizaciones", "adminRoutes debe tener slug cotizaciones");
mustInclude(manual, 'moduloId: "cotiz"', "Manual debe documentar Cotizaciones");

const uiRpcs = [...ui.matchAll(/supabase\.rpc\("([^"]+)"/g)].map((m) => m[1]);
const sqlFuncs = new Set(
  [...sql.matchAll(/function public\.(admin_\w+)/g)].map((m) => m[1]),
);
for (const rpc of uiRpcs) {
  if (!sqlFuncs.has(rpc)) fail(`UI llama ${rpc} pero no está en el patch SQL`);
}

function runUnitTests() {
  const unit = spawnSync(
    process.execPath,
    ["--test", path.join(root, "src/lib/cotizaciones.node.test.js")],
    { encoding: "utf8" },
  );
  if (unit.status !== 0) {
    fail("Falló cotizaciones.node.test.js:\n" + (unit.stdout || "") + (unit.stderr || ""));
  }
}

async function extraLibChecks() {
  const libUrl = pathToFileURL(path.join(root, "src/lib/cotizaciones.js")).href;
  const { puedeGuardarCotizacion, precioSugeridoCotizacion, numerosLineaCotizacion } = await import(libUrl);
  if (!puedeGuardarCotizacion({ clienteNombre: "María", items: [{ texto: "Anthelios", cantidad: 1 }] })) {
    fail("puedeGuardarCotizacion debería aceptar María + Anthelios");
  }
  if (precioSugeridoCotizacion(250, "marca") !== 313) {
    fail("marca $250 debe sugerir $313 (+25% al costo, techo)");
  }
  const n = numerosLineaCotizacion({ costo: 100, precioVenta: 160, cantidad: 1, tipoMargen: "generico" });
  if (n.recargoPct !== 60 || n.margenPct !== 37.5) {
    fail("genérico $100 → $160 es recargo 60% y margen 37.5%");
  }
}

runUnitTests();
extraLibChecks()
  .then(() => {
    if (errors.length) {
      console.error("check-cotizaciones FALLÓ:\n- " + errors.join("\n- "));
      process.exit(1);
    }
    console.log("check-cotizaciones OK (SQL + UI + cableado + unit)");
  })
  .catch((err) => {
    console.error("check-cotizaciones error:", err);
    process.exit(1);
  });
