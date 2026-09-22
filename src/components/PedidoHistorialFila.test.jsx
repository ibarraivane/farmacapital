import React from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import PedidoHistorialFila from "./PedidoHistorialFila";

const pedido = {
  id: 453,
  total: 395,
  tipo: "online",
  tipo_entrega: "envio",
  estado: "listo",
  payment_status: "approved",
  created_at: "2026-09-21T17:42:00.000Z",
  direccion: "Calle Río Grijalva 37, Cuauhtemoc, 06500",
  clientes: { nombre: "Alejandro Escalante", telefono: "5522179572" },
  pedido_items: [
    { cantidad: 1, precio_unitario: 56, productos: { nombre: "Roxidolin Doxiciclina 100 mg" } },
    { cantidad: 1, precio_unitario: 42, productos: { nombre: "Charyn 3 Tab 500 Mg" } },
  ],
};

it("el historial abre al click y muestra los productos", () => {
  render(
    <PedidoHistorialFila
      pedido={pedido}
      onCobrarBbva={() => {}}
      onMarcarRuta={() => {}}
    />
  );
  expect(screen.queryByText(/Roxidolin/)).not.toBeInTheDocument();
  const fila = screen.getByRole("button", { name: /Alejandro Escalante/ });
  expect(fila).toHaveAttribute("aria-expanded", "false");
  fireEvent.click(fila);
  expect(fila).toHaveAttribute("aria-expanded", "true");
  expect(screen.getByText(/Roxidolin/)).toBeInTheDocument();
  expect(screen.getByText(/Charyn/)).toBeInTheDocument();
  expect(screen.getByText(/Marcar en ruta/)).toBeInTheDocument();
  expect(screen.getByText(/#FC-0453/)).toBeInTheDocument();
});
