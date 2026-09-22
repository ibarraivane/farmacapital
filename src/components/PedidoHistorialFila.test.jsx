import React from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import PedidoHistorialFila from "./PedidoHistorialFila";

const pedido = {
  id: 335,
  total: 180,
  tipo: "online",
  tipo_entrega: "envio",
  estado: "listo",
  payment_status: "approved",
  created_at: "2026-09-20T18:00:00.000Z",
  clientes: { nombre: "Ivan ibarra", telefono: "525537275035" },
};

it("el historial entra en una línea con el nombre y el detalle sale al click", () => {
  render(
    <PedidoHistorialFila
      pedido={pedido}
      onCobrarBbva={() => {}}
      onMarcarRuta={() => {}}
    />
  );
  expect(screen.queryByText(/Marcar en ruta/)).not.toBeInTheDocument();
  const fila = screen.getByRole("button", { name: /Ivan ibarra/ });
  expect(fila).toHaveAttribute("aria-expanded", "false");
  expect(fila).toHaveTextContent("Pedido #335");
  expect(fila.style.gridTemplateColumns).toMatch(/minmax\(7\.5rem,\s*1fr\)/);
  fireEvent.click(fila);
  expect(fila).toHaveAttribute("aria-expanded", "true");
  expect(screen.getByText(/Marcar en ruta/)).toBeInTheDocument();
  expect(screen.getByText(/#FC-0335/)).toBeInTheDocument();
});

it("si no hay ficha, usa el nombre de invitado", () => {
  render(
    <PedidoHistorialFila
      pedido={{ ...pedido, id: 336, clientes: null, guest_nombre: "Ana López" }}
    />
  );
  expect(screen.getByRole("button", { name: /Ana López/ })).toBeInTheDocument();
});
