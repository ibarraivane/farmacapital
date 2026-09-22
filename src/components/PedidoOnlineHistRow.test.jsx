import React from "react";
import { fireEvent, render, screen, within } from "@testing-library/react";
import PedidoOnlineHistRow, { etiquetaEstadoSurtidoHist } from "./PedidoOnlineHistRow";

const baseEnvio = {
  tipo: "online",
  tipo_entrega: "envio",
  payment_status: "approved",
  metodo_pago: "mercadopago",
  payment_provider: "mercadopago",
  created_at: "2026-09-21T17:42:45.000Z",
};

const listoRuta = {
  ...baseEnvio,
  id: 453,
  total: 395,
  estado: "listo",
  delivery_status: "ready_for_pickup",
  clientes: { nombre: "Alejandro Escalante" },
};

const entregado = {
  ...baseEnvio,
  id: 335,
  total: 10,
  estado: "completado",
  delivery_status: "delivered",
  created_at: "2026-09-15T18:46:36.000Z",
  clientes: { nombre: "Ivan Ibarra" },
};

it("etiqueta Listo vs Entregado según estado", () => {
  expect(etiquetaEstadoSurtidoHist(listoRuta)).toBe("Listo");
  expect(etiquetaEstadoSurtidoHist(entregado)).toBe("Entregado");
  expect(etiquetaEstadoSurtidoHist({ estado: "listo" })).toBe("Listo");
});

it("reserva las mismas columnas con o sin botón de ruta", () => {
  const onMarcarRuta = jest.fn();
  const { container } = render(
    <div>
      <PedidoOnlineHistRow pedido={listoRuta} onMarcarRuta={onMarcarRuta} />
      <PedidoOnlineHistRow pedido={entregado} />
    </div>
  );

  const rows = container.querySelectorAll(".farmacapital-pedido-hist-row");
  expect(rows).toHaveLength(2);
  rows.forEach((row) => {
    expect(row.querySelector(".farmacapital-pedido-hist-row__estado")).toBeTruthy();
    expect(row.querySelector(".farmacapital-pedido-hist-row__pago")).toBeTruthy();
    expect(row.querySelector(".farmacapital-pedido-hist-row__tiempo")).toBeTruthy();
    expect(row.querySelector(".farmacapital-pedido-hist-row__precio")).toBeTruthy();
    expect(row.querySelector(".farmacapital-pedido-hist-row__accion")).toBeTruthy();
  });

  const rowListo = screen.getByTestId("pedido-hist-row-453");
  const rowEntregado = screen.getByTestId("pedido-hist-row-335");
  expect(within(rowListo).getByText("Listo")).toBeInTheDocument();
  expect(within(rowEntregado).getByText("Entregado")).toBeInTheDocument();
  expect(within(rowListo).getByText("$395.00")).toBeInTheDocument();
  expect(within(rowEntregado).getByText("$10.00")).toBeInTheDocument();
  expect(within(rowListo).getByRole("button", { name: /Marcar en ruta/ })).toBeInTheDocument();
  expect(within(rowEntregado).queryByRole("button", { name: /Marcar en ruta/ })).not.toBeInTheDocument();
  expect(within(rowEntregado).getByText(/Pagado/i)).toBeInTheDocument();

  fireEvent.click(within(rowListo).getByRole("button", { name: /Marcar en ruta/ }));
  expect(onMarcarRuta).toHaveBeenCalledWith(listoRuta);
});
