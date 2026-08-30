import { render, screen } from "@testing-library/react";
import PrecioOferta from "./PrecioOferta";

test("sin oferta solo muestra el precio de lista", () => {
  render(<PrecioOferta prod={{ precio: 148, descuento_pct: 0 }} />);
  expect(screen.getByText("$148.00")).toBeInTheDocument();
  expect(screen.queryByText("Precio especial")).toBeNull();
});

test("con descuento muestra lista tachada, oferta y Precio especial", () => {
  render(<PrecioOferta prod={{ precio: 100, descuento_pct: 20 }} />);
  expect(screen.getByText("Precio especial")).toBeInTheDocument();
  expect(screen.getByText("−20%")).toBeInTheDocument();
  expect(screen.getByText("$100.00")).toBeInTheDocument();
  expect(screen.getByText("$80.00")).toBeInTheDocument();
  expect(screen.getByText(/Ahorras/)).toBeInTheDocument();
});
