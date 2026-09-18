import { render, screen } from "@testing-library/react";
import PagoServiciosPanel from "./PagoServiciosPanel";

jest.mock("../../../supabase", () => ({
  supabase: {
    from: () => ({ select: () => ({ in: async () => ({ data: [], error: null }) }) }),
    rpc: async () => ({ data: [], error: null }),
  },
}));

test("Servicios ofrece Efectivo y Tarjeta como métodos de cobro", async () => {
  render(<PagoServiciosPanel isNarrow />);
  expect(await screen.findByRole("button", { name: /Efectivo/ })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /^💳 Tarjeta$/ })).toBeInTheDocument();
  expect(screen.getByText(/CÓMO PAGÓ EL CLIENTE/)).toBeInTheDocument();
  expect(screen.getByText(/Tarjeta suma al corte de tarjeta/)).toBeInTheDocument();
});

test("si hay Point, también se puede cobrar ahí y queda como tarjeta", async () => {
  render(<PagoServiciosPanel isNarrow onCobrarPoint={() => {}} />);
  expect(await screen.findByRole("button", { name: /Cobrar en Point/ })).toBeInTheDocument();
});

test("Izzi suma $10 por default y el admin puede editar los recargos", async () => {
  render(<PagoServiciosPanel isNarrow usuario={{ rol: "admin", nombre: "Dueño" }} />);
  expect(await screen.findByRole("button", { name: /Izzi/ })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /Izzi/ }).textContent).toMatch(/\+\$10\.00/);
  expect(screen.getByText(/Recargos de recibos \(solo admin\)/)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /Guardar recargos/ })).toBeInTheDocument();
  const izzi = screen.getByLabelText(/Izzi/);
  expect(izzi).toHaveValue("10");
});

test("el piso no edita recargos", async () => {
  render(<PagoServiciosPanel isNarrow usuario={{ rol: "vendedor", nombre: "Cynthia" }} />);
  expect(await screen.findByRole("button", { name: /Efectivo/ })).toBeInTheDocument();
  expect(screen.queryByText(/Recargos de recibos/)).not.toBeInTheDocument();
});
