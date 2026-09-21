import React from "react";
import { render, screen } from "@testing-library/react";
import EstadoDisponibilidad from "./EstadoDisponibilidad";

test("pinta En sucursal con marca jade", () => {
  const { container } = render(<EstadoDisponibilidad producto={{ stock: 3 }} />);
  expect(screen.getByText("En sucursal")).toBeInTheDocument();
  expect(container.querySelector(".sq.on")).toBeTruthy();
});

test("por encargo usa el cuadrito azul", () => {
  const { container } = render(
    <EstadoDisponibilidad producto={{ stock: 0, bajo_pedido: true }} confirmarFecha />
  );
  expect(screen.getByText("Por encargo · te confirmamos la fecha")).toBeInTheDocument();
  expect(container.querySelector(".sq.order")).toBeTruthy();
});

test("sin producto muestra Cotización", () => {
  const { container } = render(<EstadoDisponibilidad producto={null} />);
  expect(screen.getByText("Cotización")).toBeInTheDocument();
  expect(container.querySelector(".sq.quote")).toBeTruthy();
});
