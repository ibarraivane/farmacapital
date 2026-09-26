"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const path = require("path");
const { pathToFileURL } = require("url");

const store = new Map();
globalThis.sessionStorage = {
  getItem: (k) => (store.has(k) ? store.get(k) : null),
  setItem: (k, v) => store.set(k, String(v)),
  removeItem: (k) => store.delete(k),
};

describe("cotizaciones", async () => {
  const mod = await import(pathToFileURL(path.join(__dirname, "cotizaciones.js")).href);
  const {
    ESTADOS_COTIZACION,
    ESTADOS_COTIZACION_ABIERTAS,
    ESTADOS_ITEM_COTIZACION,
    ORIGENES_COTIZACION,
    URGENCIAS_COTIZACION,
    FILTROS_COTIZACION,
    folioCotizacion,
    etiquetaEstadoCotizacion,
    etiquetaEstadoItemCotizacion,
    etiquetaOrigenCotizacion,
    etiquetaLugarCotizacion,
    siguientesEstadosCotizacion,
    siguientesEstadosItemCotizacion,
    esEstadoCotizacionAbierto,
    normalizarTextoItemCotizacion,
    normalizarEanCotizacion,
    itemCotizacionValido,
    puedeGuardarCotizacion,
    payloadPromoverDesdeSolicitud,
    precioSugeridoCotizacion,
    numerosLineaCotizacion,
    totalesCotizacion,
    escaparHtmlCotizacion,
    itemConfirmadoDocumento,
    vigenciaDefaultTexto,
    importeDocumentoCliente,
    totalDocumentoCliente,
    resumenItemsCotizacion,
    fmtDineroCotiz,
    haceCuanto,
    stashCotizacionAbierta,
    takeCotizacionAbierta,
    COTIZ_OPEN_STORAGE_KEY,
  } = mod;

  it("folio y etiquetas del contrato", () => {
    assert.equal(folioCotizacion(142), "C-142");
    assert.equal(folioCotizacion(null), "C-—");
    assert.deepEqual(
      ESTADOS_COTIZACION.map((e) => e.id),
      ["nueva", "buscando", "lista", "pedida", "cerrada", "perdida"],
    );
    assert.ok(ESTADOS_ITEM_COTIZACION.map((e) => e.id).includes("no_se_consigue"));
    assert.ok(ORIGENES_COTIZACION.map((o) => o.id).includes("whatsapp"));
    assert.deepEqual(
      URGENCIAS_COTIZACION.map((u) => u.id),
      ["hoy", "manana", "sin_prisa"],
    );
    assert.ok(FILTROS_COTIZACION.some((f) => f.id === "abiertas"));
    assert.equal(etiquetaEstadoCotizacion("lista"), "Lista");
    assert.equal(etiquetaEstadoItemCotizacion("pedir"), "Pedir");
    assert.equal(etiquetaOrigenCotizacion("tienda"), "Tienda web");
    assert.equal(etiquetaLugarCotizacion("nadro"), "Nadro");
    assert.equal(etiquetaLugarCotizacion("Farmacia del pueblo"), "Farmacia del pueblo");
  });

  it("siguientes estados de proyecto y de línea", () => {
    assert.deepEqual(siguientesEstadosCotizacion("nueva"), ["buscando", "lista", "perdida"]);
    assert.ok(siguientesEstadosCotizacion("pedida").includes("cerrada"));
    assert.ok(siguientesEstadosCotizacion("perdida").includes("nueva"));
    assert.ok(siguientesEstadosItemCotizacion("pendiente").includes("buscando"));
    assert.ok(siguientesEstadosItemCotizacion("elegido").includes("pedir"));
    assert.ok(siguientesEstadosItemCotizacion("pedido").includes("llego"));
    assert.equal(esEstadoCotizacionAbierto("buscando"), true);
    assert.equal(esEstadoCotizacionAbierto("cerrada"), false);
    assert.deepEqual(ESTADOS_COTIZACION_ABIERTAS, ["nueva", "buscando", "lista", "pedida"]);
  });

  it("valida alta: cliente + al menos un producto", () => {
    assert.equal(normalizarTextoItemCotizacion("  anthelios   40ml  "), "anthelios 40ml");
    assert.equal(normalizarTextoItemCotizacion("x".repeat(250)).length, 200);
    assert.equal(normalizarEanCotizacion("3337875917810"), "3337875917810");
    assert.equal(normalizarEanCotizacion("12"), "");
    assert.equal(itemCotizacionValido({ texto: "a", cantidad: 1 }), false);
    assert.equal(itemCotizacionValido({ texto: "Anthelios", cantidad: 2 }), true);
    assert.equal(
      puedeGuardarCotizacion({
        clienteNombre: "María",
        items: [{ texto: "Anthelios", cantidad: 1 }],
      }),
      true,
    );
    assert.equal(
      puedeGuardarCotizacion({
        clienteNombre: "",
        clienteTelefono: "5512345678",
        items: [{ texto: "Anthelios", cantidad: 1 }],
      }),
      true,
    );
    assert.equal(
      puedeGuardarCotizacion({
        clienteNombre: "",
        clienteTelefono: "55",
        items: [{ texto: "Anthelios", cantidad: 1 }],
      }),
      false,
    );
    assert.equal(
      puedeGuardarCotizacion({
        clienteNombre: "María",
        items: [{ texto: "x", cantidad: 1 }],
      }),
      false,
    );
  });

  it("promover desde solicitud copia cliente, origen y el renglón", () => {
    const p = payloadPromoverDesdeSolicitud({
      id: 88,
      texto: "BLOQ ANTHE UVAIR",
      cantidad: 2,
      urgencia: "hoy",
      origen: "tienda",
      cliente_nombre: "María López",
      cliente_telefono: "55 1234 5678",
      cliente_email: "maria@test.com",
      direccion: "Roma Norte",
      producto_id: 9,
    });
    assert.equal(p.solicitud_id, 88);
    assert.equal(p.origen, "tienda");
    assert.equal(p.urgencia, "hoy");
    assert.equal(p.cliente_telefono, "5512345678");
    assert.deepEqual(p.items[0], {
      texto: "BLOQ ANTHE UVAIR",
      cantidad: 2,
      producto_id: 9,
      ean: "",
      tipo_margen: "marca",
    });
    assert.equal(payloadPromoverDesdeSolicitud({ texto: "x", origen: "mostrador" }).origen, "mostrador");
  });

  it("marca +25% y genérico +60% sobre costo; muestra recargo y margen", () => {
    assert.equal(precioSugeridoCotizacion(250, "marca"), 313);
    assert.equal(precioSugeridoCotizacion(250, "generico"), 400);
    const marca = numerosLineaCotizacion({
      costo: 250,
      cantidad: 2,
      tipoMargen: "marca",
    });
    assert.equal(marca.sugerido, 313);
    assert.equal(marca.venta, 313);
    assert.equal(marca.recargoPct, 25.2);
    assert.equal(marca.margenPct, 20.1);
    assert.equal(marca.gananciaUnit, 63);
    assert.equal(marca.gananciaTotal, 126);
    assert.equal(marca.usaSugerido, true);

    const gen = numerosLineaCotizacion({
      costo: 100,
      precioVenta: 160,
      cantidad: 1,
      tipoMargen: "generico",
    });
    assert.equal(gen.sugerido, 160);
    assert.equal(gen.recargoPct, 60);
    assert.equal(gen.margenPct, 37.5);
    assert.equal(gen.usaSugerido, false);
  });

  it("totales del proyecto solo suman líneas con costo y venta", () => {
    const t = totalesCotizacion([
      { texto: "A", cantidad: 2, costo_elegido: 389, precio_venta: 486, tipo_margen: "marca" },
      { texto: "B", cantidad: 1, costo_elegido: null, precio_venta: null, tipo_margen: "marca" },
    ]);
    assert.equal(t.lineas, 1);
    assert.equal(t.costo, 778);
    assert.equal(t.venta, 972);
    assert.equal(t.ganancia, 194);
    assert.equal(totalesCotizacion([]).ganancia, null);
    assert.match(
      resumenItemsCotizacion([
        { texto: "Anthelios", cantidad: 2 },
        { texto: "CeraVe", cantidad: 1 },
        { texto: "Extra", cantidad: 1 },
      ]),
      /Anthelios ×2/,
    );
    assert.equal(resumenItemsCotizacion([]), "Sin productos");
  });

  it("documento del cliente suma precio de venta sin pedir el costo", () => {
    const viernes = new Date(2026, 8, 25);
    assert.equal(vigenciaDefaultTexto(1, viernes), "28 de septiembre de 2026");
    assert.equal(vigenciaDefaultTexto(5, viernes), "2 de octubre de 2026");
    assert.equal(escaparHtmlCotizacion("A & B <C>"), "A &amp; B &lt;C&gt;");
    assert.equal(itemConfirmadoDocumento({ estado: "elegido", precio_venta: 120 }), true);
    assert.equal(itemConfirmadoDocumento({ estado: "buscando", precio_venta: 120 }), false);
    assert.equal(itemConfirmadoDocumento({ estado: "elegido", precio_venta: null }), false);

    const items = [
      { estado: "buscando", precio_venta: 80, cantidad: 2, costo_elegido: null },
      { estado: "elegido", precio_venta: 50, cantidad: 1, costo_elegido: 40 },
      { estado: "pendiente", precio_venta: null, cantidad: 1, costo_elegido: 100, tipo_margen: "marca" },
    ];
    assert.equal(importeDocumentoCliente(items[0]), 160);
    assert.equal(importeDocumentoCliente(items[2]), null);
    assert.equal(totalDocumentoCliente(items), 210);
    assert.equal(totalDocumentoCliente([]), null);
    assert.equal(totalesCotizacion(items).venta, 175);
  });

  it("dinero y hace cuanto", () => {
    assert.equal(fmtDineroCotiz(null), "—");
    assert.match(fmtDineroCotiz(389), /389/);
    const now = Date.parse("2026-09-21T12:00:00Z");
    assert.equal(haceCuanto("2026-09-21T11:30:00Z", now), "hace 30 min");
    assert.equal(haceCuanto("2026-09-20T12:00:00Z", now), "hace 1 día");
    assert.equal(haceCuanto("2026-09-11T12:00:00Z", now), "hace 10 días");
  });

  it("sessionStorage abre la ficha promovida", () => {
    store.delete(COTIZ_OPEN_STORAGE_KEY);
    assert.equal(stashCotizacionAbierta(142), true);
    assert.equal(store.get(COTIZ_OPEN_STORAGE_KEY), "142");
    assert.equal(takeCotizacionAbierta(), 142);
    assert.equal(takeCotizacionAbierta(), null);
    assert.equal(stashCotizacionAbierta(0), false);
  });
});
