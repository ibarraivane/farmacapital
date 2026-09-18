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
    esPedidoEnvioPorCotizar,
    pedidoEnColaOnline,
    fusionarColaOnline,
    hidratarPagoDesdeTransacciones,
    fetchPedidosOnlineMostrador,
    esErrorColumnaCostoEnvio,
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

  it("envio pendiente sin pago entra a la cola para cotizar", () => {
    const p = {
      estado: "pendiente",
      tipo: "online",
      metodo_pago: "mercadopago",
      payment_status: null,
      tipo_entrega: "envio",
    };
    assert.equal(esPedidoTiendaWebPendiente(p), false);
    assert.equal(esPedidoEnvioPorCotizar(p), true);
    assert.equal(pedidoEnColaOnline(p), true);
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

    const histSinStatus = etiquetaPagoPedidoOnline({
      estado: "completado",
      tipo: "online",
      metodo_pago: "mercadopago",
      tipo_entrega: "recoger",
    });
    assert.equal(histSinStatus.kind, "approved_mp");
    assert.match(histSinStatus.label, /Pagado/i);
  });

  it("fusiona domicilio sin pago que el RPC viejo omite", () => {
    const escalante = {
      id: 333,
      estado: "pendiente",
      tipo: "online",
      metodo_pago: "mercadopago",
      payment_status: null,
      tipo_entrega: "envio",
      created_at: "2026-09-15T15:33:00Z",
    };
    const merged = fusionarColaOnline([], [escalante]);
    assert.equal(merged.length, 1);
    assert.equal(merged[0].id, 333);
  });

  it("hidrata payment_status del historial desde transacciones", () => {
    const hist = [{ id: 335, estado: "completado", metodo_pago: "mercadopago", total: 10 }];
    const tx = [{ id: 335, payment_status: "approved", payment_provider: "mercadopago", paid_at: "2026-09-15T18:00:00Z" }];
    const [row] = hidratarPagoDesdeTransacciones(hist, tx);
    assert.equal(row.payment_status, "approved");
    assert.equal(etiquetaPagoPedidoOnline(row).kind, "approved_mp");
  });

  it("mostrador rescata domicilio omitido y pago del historial", async () => {
    const supabase = {
      async rpc(name) {
        if (name === "empleado_listar_pedidos_tienda_web_pendientes") {
          return { data: [], error: { message: "pago no confirmado" } };
        }
        if (name === "empleado_listar_pedidos_online_historial") {
          return { data: [{ id: 335, estado: "completado", metodo_pago: "mercadopago" }], error: null };
        }
        if (name === "empleado_listar_pedidos_transacciones") {
          return {
            data: [
              {
                id: 333,
                estado: "pendiente",
                tipo: "online",
                metodo_pago: "mercadopago",
                tipo_entrega: "envio",
                payment_status: null,
                created_at: "2026-09-15T15:33:00Z",
              },
              { id: 335, payment_status: "approved", payment_provider: "mercadopago" },
            ],
            error: null,
          };
        }
        return { data: [], error: null };
      },
    };
    const { cola, hist } = await fetchPedidosOnlineMostrador(supabase, "tok");
    assert.equal(cola.length, 1);
    assert.equal(cola[0].id, 333);
    assert.equal(hist[0].payment_status, "approved");
    assert.equal(etiquetaPagoPedidoOnline(hist[0]).kind, "approved_mp");
  });

  it("detecta el error de POS cuando falta pedidos.costo_envio", () => {
    assert.equal(
      esErrorColumnaCostoEnvio({ message: "column p.costo_envio does not exist" }),
      true
    );
    assert.equal(esErrorColumnaCostoEnvio({ message: "Stock insuficiente" }), false);
  });
});
