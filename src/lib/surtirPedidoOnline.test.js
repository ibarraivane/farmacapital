import {
  telefonoClientePedido,
  payloadMarcarPedidoListo,
  mensajeErrorSurtirPedido,
  toastsTrasSurtirOk,
} from "./surtirPedidoOnline";

describe("surtirPedidoOnline", () => {
  test("lee teléfono de cliente objeto, array o guest", () => {
    expect(telefonoClientePedido({ clientes: { telefono: "5512345678" } })).toBe("5512345678");
    expect(telefonoClientePedido({ clientes: [{ telefono: "5598765432" }] })).toBe("5598765432");
    expect(telefonoClientePedido({ guest_telefono: "5500000000" })).toBe("5500000000");
    expect(telefonoClientePedido({})).toBe("");
  });

  test("payloadMarcarPedidoListo acepta objeto, string jsonb y array", () => {
    expect(payloadMarcarPedidoListo({ success: true, items_consumidos: 1 })).toEqual({
      success: true,
      items_consumidos: 1,
    });
    expect(payloadMarcarPedidoListo('{"success":true,"ya_listo":true}')).toEqual({
      success: true,
      ya_listo: true,
    });
    expect(payloadMarcarPedidoListo([{ success: true }]).success).toBe(true);
    expect(payloadMarcarPedidoListo(null).success).toBeUndefined();
  });

  test("mensajeErrorSurtirPedido traduce stock, pago y estado", () => {
    expect(
      mensajeErrorSurtirPedido({
        message: "Error al consumir stock de producto 88: stock insuficiente para producto 88 (disponible 0, solicitado 1)",
      }),
    ).toMatch(/lotes/i);
    expect(
      mensajeErrorSurtirPedido({ message: "Pago no confirmado. Espera la aprobación de Mercado Pago antes de surtir." }),
    ).toMatch(/Mercado Pago/);
    expect(
      mensajeErrorSurtirPedido({ message: "No se puede marcar listo un pedido en estado: completado" }),
    ).toMatch(/ya no se puede surtir/);
    expect(mensajeErrorSurtirPedido({ message: "Pedido 335 no encontrado" })).toMatch(/no se encontró/i);
  });

  test("WhatsApp fallido no esconde que el pedido ya quedó listo", () => {
    const toasts = toastsTrasSurtirOk({
      tipoEntrega: "recoger",
      telefono: "5511111111",
      wa: { sent: false, reason: "http_500" },
    });
    expect(toasts).toHaveLength(2);
    expect(toasts[0]).toEqual({ tipo: "success", msg: "Pedido marcado como listo" });
    expect(toasts[1].tipo).toBe("warning");
    expect(toasts[1].msg).toMatch(/WhatsApp|servidor|deploy/i);
  });

  test("WhatsApp ok en pick-up es un solo success", () => {
    expect(
      toastsTrasSurtirOk({
        tipoEntrega: "recoger",
        telefono: "5511111111",
        wa: { sent: true },
      }),
    ).toEqual([
      { tipo: "success", msg: "Pedido listo · pase de recogida enviado por WhatsApp" },
    ]);
  });

  test("envío añade la pista del mensajero", () => {
    const ok = toastsTrasSurtirOk({
      tipoEntrega: "envio",
      telefono: "5511111111",
      wa: { sent: true },
    });
    expect(ok[0].msg).toMatch(/mensajero/);
    const fail = toastsTrasSurtirOk({
      tipoEntrega: "envio",
      telefono: "5511111111",
      wa: { sent: false, reason: "network_error" },
    });
    expect(fail[0].msg).toMatch(/mensajero/);
    expect(fail[1].tipo).toBe("warning");
  });
});
