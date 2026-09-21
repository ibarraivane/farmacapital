import {
  calcularCostoEnvio,
  checkoutPuedePedirEnvio,
  clientePuedePagarPedidoEnvio,
  cargoServicioPedido,
  desgloseEnvioCheckout,
  estimarEnvioDesdeCoords,
  etiquetaEstadoEnvioCliente,
  feeEnvioEnCheckout,
  getEnvioConfigCliente,
  haversineKm,
  minutosRestantesCotizacion,
  pedidosConEnvioPorPagar,
  proveedorSugerido,
  textoClienteEnvioEnCheckout,
  mensajeCorreoEnvioCotizado,
} from "./envioDomicilio";

describe("envioDomicilio cliente", () => {
  test("tabla inicial 0-2 / 2-4 / 4-5 y radio 5", () => {
    expect(calcularCostoEnvio({ distanciaKm: 1.2, subtotal: 50 }).costo).toBe(30);
    expect(calcularCostoEnvio({ distanciaKm: 3, subtotal: 230 }).costo).toBe(0);
    expect(calcularCostoEnvio({ distanciaKm: 4.5, subtotal: 100 }).costo).toBe(65);
    expect(calcularCostoEnvio({ distanciaKm: 5.01, radioMaximoKm: 5 }).ok).toBe(false);
    expect(calcularCostoEnvio({ distanciaKm: 8, radioMaximoKm: 0 }).ok).toBe(true);
  });

  test("checkout de domicilio solo pide dirección; el vendedor cotiza después", () => {
    expect(checkoutPuedePedirEnvio({ entrega: "pickup", direccionOk: true })).toBe(true);
    expect(checkoutPuedePedirEnvio({ entrega: "cdmx", direccionOk: true })).toBe(true);
    expect(checkoutPuedePedirEnvio({ entrega: "cdmx", direccionOk: false })).toBe(false);
  });

  test("sucursal a sí misma es 0 km", () => {
    const cfg = getEnvioConfigCliente();
    expect(haversineKm(cfg.sucursalLat, cfg.sucursalLng, cfg.sucursalLat, cfg.sucursalLng)).toBe(0);
    const est = estimarEnvioDesdeCoords({
      lat: cfg.sucursalLat,
      lng: cfg.sucursalLng,
      subtotal: 50,
      config: cfg,
    });
    expect(est.ok).toBe(true);
  });

  test("SLA restante no es negativo", () => {
    const past = new Date(Date.now() - 60_000).toISOString();
    expect(minutosRestantesCotizacion(past)).toBe(0);
    expect(proveedorSugerido("Roma")).toBe("didi");
  });

  test("etiqueta de cuenta: cobrado en checkout, no segundo link", () => {
    expect(etiquetaEstadoEnvioCliente({ estado: "cotizado", cobrado_en_checkout: true }, "approved")).toBe("Envío pagado");
    expect(etiquetaEstadoEnvioCliente({ estado: "cotizado", cobrado_en_checkout: true }, "pending")).toBe("Envío en el total");
    expect(etiquetaEstadoEnvioCliente({ estado: "link_enviado" }, "approved")).toBe("Listo para pagar envío");
    expect(etiquetaEstadoEnvioCliente({ estado: "en_ruta" })).toBe("En ruta");
  });

  test("el transporte cotizado se suma al checkout del cliente", () => {
    const pedido = {
      id: 333,
      tipo_entrega: "envio",
      total: 540,
      costo_envio: 60,
      logistics_meta: { envio: { estado: "cotizado", costo_cotizado: 60, cobrado_en_checkout: true } },
    };
    expect(feeEnvioEnCheckout(pedido)).toBe(60);
    expect(clientePuedePagarPedidoEnvio(pedido)).toBe(true);
    expect(clientePuedePagarPedidoEnvio({
      tipo_entrega: "envio",
      logistics_meta: { envio: { estado: "pendiente_cotizacion" } },
    })).toBe(false);
    expect(desgloseEnvioCheckout(540, 60)).toEqual({ productos: 480, servicio: 0, envio: 60, total: 540 });
    // Servicio $5 ya incluido en pedidos.total por el trigger
    expect(desgloseEnvioCheckout(307, 100, 5)).toEqual({ productos: 202, servicio: 5, envio: 100, total: 307 });
    expect(cargoServicioPedido({ logistics_meta: { cargo_plataforma_mxn: 5 } })).toBe(5);
    expect(cargoServicioPedido({ logistics_meta: { cargo_plataforma_mxn: 0 } })).toBe(0);
    expect(textoClienteEnvioEnCheckout({ pedidoId: 441, costo: 100, itemsTotal: 202, cargo: 5, total: 307 }))
      .toMatch(/Productos \$202\.00 \+ servicio \$5\.00 \+ envío \$100\.00 = \$307\.00/);
    const texto = textoClienteEnvioEnCheckout({
      pedidoId: 333,
      costo: 60,
      itemsTotal: 480,
      total: 540,
    });
    expect(texto).toContain("https://www.farmacapital.mx/carrito");
    expect(texto).toContain("Pagar ahora");
    expect(texto).not.toMatch(/\/pagar\?/);
    expect(pedidosConEnvioPorPagar([
      pedido,
      { id: 1, tipo_entrega: "envio", estado: "pendiente", payment_status: "pending", logistics_meta: { envio: { estado: "pendiente_cotizacion" } } },
      { id: 2, tipo_entrega: "recoger", total: 80 },
    ]).map((p) => p.id)).toEqual([333]);
  });

  test("el toast dice por qué no salió el correo", () => {
    expect(mensajeCorreoEnvioCotizado({
      sent: false,
      reason: "missing_email",
      costo: 100,
    })).toMatch(/no tiene correo/);
    expect(mensajeCorreoEnvioCotizado({
      sent: false,
      reason: "email_provider_error",
      costo: 100,
      detail: { message: "The farmacapital.mx domain is not verified." },
    })).toMatch(/verifica el dominio/);
    expect(mensajeCorreoEnvioCotizado({ sent: true, costo: 100 })).toMatch(/contacto@farmacapital\.mx/);
  });
});
