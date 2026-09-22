import React from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import PedidoOnlineCard from "./PedidoOnlineCard";

const pedido = {
  id: 441,
  total: 302,
  tipo: "online",
  tipo_entrega: "envio",
  estado: "pendiente",
  payment_status: "pending",
  metodo_pago: "mercadopago",
  created_at: "2026-09-21T02:00:00.000Z",
  direccion: "Jose ignacio bartolache 1750, Del Valle Sur, 03104",
  guest_telefono: "525537275035",
  clientes: { nombre: "Ivan ibarra", telefono: "525537275035" },
  pedido_items: [
    { cantidad: 1, precio_unitario: 100, productos: { nombre: "Paracetamol" } },
  ],
  logistics_meta: { envio: { estado: "cotizado", costo_cotizado: 100, cobrado_en_checkout: true } },
};

it("entra cerrado en una línea y el detalle sale al hacer click", () => {
  render(
    <PedidoOnlineCard
      pedido={pedido}
      showToast={() => {}}
      setPedOn={() => {}}
      surtirOnline={() => {}}
      onCobrarBbva={() => {}}
      onCancelar={() => {}}
    />
  );
  expect(screen.queryByText(/bartolache/i)).not.toBeInTheDocument();
  expect(screen.queryByText(/WhatsApp cliente/)).not.toBeInTheDocument();
  const fila = screen.getByRole("button", { name: /Ivan ibarra/ });
  expect(fila).toHaveAttribute("aria-expanded", "false");
  expect(fila).toHaveTextContent("Pedido #441");
  expect(fila.style.gridTemplateColumns).toMatch(/minmax\(7\.5rem,\s*1fr\)/);
  fireEvent.click(fila);
  expect(fila).toHaveAttribute("aria-expanded", "true");
  expect(screen.getAllByText(/bartolache/i).length).toBeGreaterThan(0);
  expect(screen.getByText(/WhatsApp cliente/)).toBeInTheDocument();
});
