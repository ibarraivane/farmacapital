import React from "react";
import { render, screen } from "@testing-library/react";
import EstadoDisponibilidad from "./EstadoDisponibilidad";

test("pinta el estado verde de sucursal", () => {
  const { container } = render(
    <EstadoDisponibilidad producto={{ stock: 3, bajo_pedido: false }} />
  );
  expect(screen.getByText("Disponible en sucursal")).toBeInTheDocument();
  expect(container.querySelector(".fc-in-stock")).toBeTruthy();
});

test("sin existencia no renderiza", () => {
  const { container } = render(
    <EstadoDisponibilidad producto={{ stock: 0, bajo_pedido: false }} />
  );
  expect(container).toBeEmptyDOMElement();
});
