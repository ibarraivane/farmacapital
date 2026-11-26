import { fireEvent, render, screen } from "@testing-library/react";
import PagoServiciosPanel from "./PagoServiciosPanel";

jest.mock("../../../supabase", () => ({
  supabase: {
    from: () => ({ select: () => ({ in: async () => ({ data: [], error: null }) }) }),
    rpc: async () => ({ data: [], error: null }),
  },
}));

test("Servicios ofrece Efectivo, Tarjeta y Mixto como métodos de cobro", async () => {
  render(<PagoServiciosPanel isNarrow />);
  expect(await screen.findByRole("button", { name: /Efectivo/ })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /^💳 Tarjeta$/ })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /Mixto/ })).toBeInTheDocument();
  expect(screen.getByText(/CÓMO PAGÓ EL CLIENTE/)).toBeInTheDocument();
  expect(screen.getByText(/Mixto parte cada monto/)).toBeInTheDocument();
});

test("si hay Point, también se puede cobrar ahí y queda como tarjeta", async () => {
  render(<PagoServiciosPanel isNarrow onCobrarPoint={() => {}} />);
  expect(await screen.findByRole("button", { name: /^💳 Tarjeta$/ })).toBeInTheDocument();
  fireEvent.click(screen.getByRole("button", { name: /^💳 Tarjeta$/ }));
  expect(screen.getByRole("button", { name: /Cobrar en Point/ })).toBeInTheDocument();
});

test("Mixto pide desglose de efectivo antes de registrar", async () => {
  render(<PagoServiciosPanel isNarrow />);
  fireEvent.click(await screen.findByRole("button", { name: /Mixto/ }));
  expect(screen.getByText(/¿Cuánto va en efectivo/)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /Registrar mixto/ })).toBeDisabled();
});

test("la parte de tarjeta del mixto se puede cobrar en la terminal BBVA", async () => {
  render(<PagoServiciosPanel isNarrow onCobrarBbva={() => {}} />);
  fireEvent.click(await screen.findByRole("button", { name: /Mixto/ }));
  expect(screen.getByRole("button", { name: /terminal BBVA/ })).toBeDisabled();
  fireEvent.click(screen.getByRole("button", { name: /^💳 Tarjeta$/ }));
  expect(screen.getByRole("button", { name: /Cobrar en terminal BBVA/ })).toBeEnabled();
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

test("en un recibo el vendedor cambia la comisión de este cobro", async () => {
  render(<PagoServiciosPanel isNarrow usuario={{ rol: "vendedor", nombre: "Cynthia" }} />);
  fireEvent.click(await screen.findByRole("button", { name: /Izzi/ }));
  const comision = screen.getByLabelText(/Comisión de este cobro/);
  expect(comision).toHaveValue("10");
  fireEvent.change(screen.getByPlaceholderText("100"), { target: { value: "100" } });
  expect(screen.getByText("$110.00")).toBeInTheDocument();
  fireEvent.change(comision, { target: { value: "15" } });
  expect(screen.getByText("$115.00")).toBeInTheDocument();
  expect(screen.queryByText("$110.00")).not.toBeInTheDocument();
});

test("el piso no edita los recargos sugeridos", async () => {
  render(<PagoServiciosPanel isNarrow usuario={{ rol: "vendedor", nombre: "Cynthia" }} />);
  expect(await screen.findByRole("button", { name: /Efectivo/ })).toBeInTheDocument();
  expect(screen.queryByText(/Recargos de recibos/)).not.toBeInTheDocument();
});
