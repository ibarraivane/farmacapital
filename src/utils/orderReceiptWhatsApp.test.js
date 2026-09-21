import { lineasReciboPedidoOnline } from "./orderReceiptWhatsApp";

test("el recibo del pedido incluye el transporte cotizado", () => {
  const lineas = lineasReciboPedidoOnline({
    tipo_entrega: "envio",
    costo_envio: 60,
    logistics_meta: { envio: { estado: "cotizado", costo_cotizado: 60 } },
    pedido_items: [
      { cantidad: 1, precio_unitario: 120, productos: { nombre: "Charyn 3 Tab" } },
    ],
  });
  expect(lineas).toEqual([
    { nombre: "Charyn 3 Tab", qty: 1, precio: 120 },
    { nombre: "Envío a domicilio", qty: 1, precio: 60 },
  ]);
});

test("sin cotización el recibo no inventa envío", () => {
  const lineas = lineasReciboPedidoOnline({
    tipo_entrega: "envio",
    logistics_meta: { envio: { estado: "pendiente_cotizacion" } },
    pedido_items: [{ cantidad: 2, precio_unitario: 10, productos: { nombre: "Algo" } }],
  });
  expect(lineas).toHaveLength(1);
});
