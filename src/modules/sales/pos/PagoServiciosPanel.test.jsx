import { fireEvent, render, screen, waitFor } from "@testing-library/react";
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

test("el piso no edita recargos", async () => {
  render(<PagoServiciosPanel isNarrow usuario={{ rol: "vendedor", nombre: "Cynthia" }} />);
  expect(await screen.findByRole("button", { name: /Efectivo/ })).toBeInTheDocument();
  expect(screen.queryByText(/Recargos de recibos/)).not.toBeInTheDocument();
});

test("guardar recargos manda el nuevo monto y confirma en pantalla", async () => {
  sessionStorage.setItem("farmacapital_session_token", "tok");
  const fetchOriginal = global.fetch;
  global.fetch = jest.fn(async () => ({ ok: true, status: 200, json: async () => ({ ok: true }) }));
  try {
    render(<PagoServiciosPanel isNarrow usuario={{ rol: "admin", nombre: "Dueño" }} />);
    const telmex = await screen.findByLabelText(/Telmex/);
    fireEvent.change(telmex, { target: { value: "10" } });
    fireEvent.click(screen.getByRole("button", { name: /Guardar recargos/ }));
    await waitFor(() => expect(global.fetch).toHaveBeenCalled());
    const body = JSON.parse(global.fetch.mock.calls[0][1].body);
    expect(body.action).toBe("set_recargos");
    expect(body.recargos.telmex).toBe(10);
    expect(await screen.findByRole("status")).toHaveTextContent(/sigue con otro monto/);
    expect(screen.getByLabelText(/Telmex/)).toHaveValue("10");
  } finally {
    global.fetch = fetchOriginal;
  }
});

test("si ningún camino guarda, el admin ve por qué", async () => {
  sessionStorage.setItem("farmacapital_session_token", "tok");
  const fetchOriginal = global.fetch;
  global.fetch = jest.fn(async () => ({ ok: false, status: 403, json: async () => ({ ok: false, error: "requiere_admin" }) }));
  try {
    render(<PagoServiciosPanel isNarrow usuario={{ rol: "admin", nombre: "Dueño" }} />);
    fireEvent.change(await screen.findByLabelText(/Telmex/), { target: { value: "10" } });
    fireEvent.click(screen.getByRole("button", { name: /Guardar recargos/ }));
    expect(await screen.findByRole("status")).toHaveTextContent(/No se guardó.*requiere_admin/);
  } finally {
    global.fetch = fetchOriginal;
  }
});
