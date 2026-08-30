import React from "react";
import { render, screen } from "@testing-library/react";
import { C_LIGHT } from "../../../constants";
import { PosAvisoLotesCarrito, PosAvisoLotesFicha, PosAvisoLotesTarjeta } from "./PosAvisoLotes";

const C = C_LIGHT;
const hoy = "2026-08-30";
const dosLotes = {
  id: 1,
  lotes: [
    { id: 1, cantidad_actual: 2, fecha_caducidad: "2029-06-30", activo: true },
    { id: 2, cantidad_actual: 5, fecha_caducidad: "2030-12-31", activo: true },
  ],
};

it("ficha lista las dos fechas y cuál tomar", () => {
  render(<PosAvisoLotesFicha producto={dosLotes} hoy={hoy} C={C} />);
  expect(screen.getByTestId("pos-aviso-lotes-ficha")).toHaveTextContent("Toma el de jun 2029 · 2 cajas");
  expect(screen.getByTestId("pos-aviso-lotes-ficha")).toHaveTextContent("También hay dic 2030 · 5 cajas");
});

it("tarjeta solo avisa si hay más de una fecha", () => {
  const { rerender } = render(<PosAvisoLotesTarjeta producto={dosLotes} hoy={hoy} C={C} />);
  expect(screen.getByTestId("pos-aviso-lotes-tarjeta")).toHaveTextContent("Toma jun 2029");
  rerender(<PosAvisoLotesTarjeta producto={{ lotes: [{ id: 1, cantidad_actual: 2, fecha_caducidad: "2029-06-30", activo: true }] }} hoy={hoy} C={C} />);
  expect(screen.queryByTestId("pos-aviso-lotes-tarjeta")).not.toBeInTheDocument();
});

it("carrito dice la fecha del anaquel", () => {
  render(<PosAvisoLotesCarrito producto={dosLotes} hoy={hoy} C={C} />);
  expect(screen.getByTestId("pos-aviso-lotes-carrito")).toHaveTextContent("Del anaquel: jun 2029");
});
