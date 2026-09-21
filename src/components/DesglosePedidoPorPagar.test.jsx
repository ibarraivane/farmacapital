import React from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import DesglosePedidoPorPagar from "./DesglosePedidoPorPagar";

const pedido = {
  id: 441,
  total: 302,
  tipo_entrega: "envio",
  costo_envio: 100,
  payment_status: "pending",
  logistics_meta: { envio: { estado: "cotizado", costo_cotizado: 100, cobrado_en_checkout: true } },
  pedido_items: [
    { producto_id: 1, cantidad: 1, precio_unitario: 120, productos: { nombre: "Paracetamol 500 mg" } },
    { producto_id: 2, cantidad: 2, precio_unitario: 41, productos: { nombre: "Gasas estériles" } },
  ],
};

it("muestra cada producto, el envío y el total antes de Mercado Pago", () => {
  const onPagar = jest.fn();
  render(<DesglosePedidoPorPagar pedido={pedido} onPagar={onPagar} />);
  expect(screen.getByText("Pedido #441")).toBeInTheDocument();
  expect(screen.getByText("Paracetamol 500 mg")).toBeInTheDocument();
  expect(screen.getByText("Gasas estériles")).toBeInTheDocument();
  expect(screen.getByText("Envío a domicilio")).toBeInTheDocument();
  expect(screen.getByText("$100.00")).toBeInTheDocument();
  expect(screen.getByText("$302.00")).toBeInTheDocument();
  fireEvent.click(screen.getByRole("button", { name: /Pagar ahora/ }));
  expect(onPagar).toHaveBeenCalledWith(pedido);
});
