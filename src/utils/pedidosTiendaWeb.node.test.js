"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const path = require("path");
const { pathToFileURL } = require("url");

describe("pedidosTiendaWeb gate pickup", async () => {
  const mod = await import(
    pathToFileURL(path.join(__dirname, "pedidosTiendaWeb.js")).href
  );
  const {
    esPedidoPickupPendienteCobro,
    esPedidoTiendaWebPendiente,
    etiquetaPagoPedidoOnline,
    METODO_PENDIENTE_TIENDA,
    PAYMENT_STATUS_PENDING_STORE,
    pedidoOnlinePagoConfirmado,
  } = mod;

  it("pickup pendiente_tienda entra a cola sin approved", () => {
    assert.equal(
      pedidoOnlinePagoConfirmado({
        tipo: "online",
        metodo_pago: METODO_PENDIENTE_TIENDA,
        payment_status: PAYMENT_STATUS_PENDING_STORE,
      }),
      true
    );
  });

  it("envio mercadopago sin approved no entra", () => {
    assert.equal(
      pedidoOnlinePagoConfirmado({
        tipo: "online",
        metodo_pago: "mercadopago",
        payment_status: "pending",
        tipo_entrega: "envio",
      }),
      false
    );
  });

  it("envio mercadopago approved sí entra", () => {
    assert.equal(
      pedidoOnlinePagoConfirmado({
        tipo: "online",
        metodo_pago: "mercadopago",
        payment_status: "approved",
      }),
      true
    );
  });

  it("tarjeta sin approved no entra", () => {
    assert.equal(
      pedidoOnlinePagoConfirmado({
        tipo: "online",
        metodo_pago: "tarjeta",
        payment_status: "pending_store",
      }),
      false
    );
  });

  it("detecta pickup pendiente cobro", () => {
    assert.equal(
      esPedidoPickupPendienteCobro({
        tipo_entrega: "recoger",
        metodo_pago: METODO_PENDIENTE_TIENDA,
        payment_status: PAYMENT_STATUS_PENDING_STORE,
      }),
      true
    );
    assert.equal(
      esPedidoPickupPendienteCobro({
        tipo_entrega: "envio",
        metodo_pago: METODO_PENDIENTE_TIENDA,
      }),
      false
    );
  });

  it("esPedidoTiendaWebPendiente pickup ok", () => {
    assert.equal(
      esPedidoTiendaWebPendiente({
        estado: "pendiente",
        tipo: "online",
        metodo_pago: METODO_PENDIENTE_TIENDA,
        payment_status: PAYMENT_STATUS_PENDING_STORE,
      }),
      true
    );
    assert.equal(
      esPedidoTiendaWebPendiente({
        estado: "listo",
        tipo: "online",
        metodo_pago: METODO_PENDIENTE_TIENDA,
      }),
      false
    );
  });

  it("etiquetas de pago", () => {
    const pending = etiquetaPagoPedidoOnline({
      tipo_entrega: "recoger",
      metodo_pago: METODO_PENDIENTE_TIENDA,
      payment_status: PAYMENT_STATUS_PENDING_STORE,
    });
    assert.equal(pending.kind, "pending_store");
    assert.match(pending.label, /Pendiente cobro/i);

    const bbva = etiquetaPagoPedidoOnline({
      metodo_pago: "tarjeta",
      payment_provider: "bbva",
      payment_status: "approved",
    });
    assert.equal(bbva.kind, "approved_bbva");

    const mp = etiquetaPagoPedidoOnline({
      metodo_pago: "mercadopago",
      payment_provider: "mercadopago",
      payment_status: "approved",
    });
    assert.equal(mp.kind, "approved_mp");

    const quote = etiquetaPagoPedidoOnline({
      tipo_entrega: "envio",
      metodo_pago: "mercadopago",
      logistics_meta: { envio: { estado: "pendiente_cotizacion" } },
    });
    assert.equal(quote.kind, "pending_quote");

    const ready = etiquetaPagoPedidoOnline({
      tipo_entrega: "envio",
      metodo_pago: "mercadopago",
      logistics_meta: { envio: { estado: "cotizado" } },
    });
    assert.equal(ready.kind, "ready_to_pay");
  });
});
