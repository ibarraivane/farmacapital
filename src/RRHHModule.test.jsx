import { render, screen, waitFor } from "@testing-library/react";
import RRHHModule from "./RRHHModule";

jest.mock("./supabase", () => ({
  supabase: { rpc: jest.fn() },
}));
jest.mock("./modules/rh/EmpleadoDocumentos", () => () => null);
jest.mock("./utils/turnosMetas", () => ({
  cargarConfigMetas: () => Promise.resolve({}),
  bonosActivos: () => false,
}));

const { supabase } = require("./supabase");

beforeEach(() => {
  sessionStorage.setItem("farmacapital_session_token", "tok");
  supabase.rpc.mockImplementation((name) => {
    if (name === "admin_listar_empleados") {
      return Promise.resolve({
        data: [{
          id: 1, nombre: "Erika", telefono: "5511111111", rol: "vendedor",
          turno: "matutino", estado: true, salario_semanal: 1133.32, salario_quincenal: 0,
        }],
        error: null,
      });
    }
    if (name === "admin_listar_usuarios") {
      return Promise.resolve({
        data: [
          { id: 10, nombre: "Cynthia Nayeli Mendoza Flores", rol: "vendedor", turno: "vespertino", dia_descanso: 6, activo: true },
          { id: 11, nombre: "Rosa Raquel Lucas Galindo", rol: "vendedor", turno: "matutino", dia_descanso: 5, activo: true },
        ],
        error: null,
      });
    }
    if (name === "rh_semana_empleado") {
      return Promise.resolve({ data: { dias: [], pago: null, salario_semanal: 1133.32 }, error: null });
    }
    return Promise.resolve({ data: null, error: null });
  });
});

test("RH muestra salario semanal de viernes y ya no habla de quincena", async () => {
  render(<RRHHModule />);
  expect(await screen.findByText(/Nómina semanal \(viernes\)/)).toBeInTheDocument();
  expect(screen.getByText(/Nómina semanal · se paga el viernes/)).toBeInTheDocument();
  expect(screen.getByLabelText(/Salario semanal \(viernes\)/)).toBeInTheDocument();
  await waitFor(() => {
    expect(screen.getAllByText("$1,133.32").length).toBeGreaterThan(0);
  });
  expect(document.body.textContent).not.toMatch(/quincenal/i);
});

test("sábado y domingo no marcan ambos turnos: Luis e Iván cubren el medio", async () => {
  render(<RRHHModule />);
  expect(await screen.findByText("Luis / Iván")).toBeInTheDocument();
  expect(screen.getByText(/Luis e Iván toman el medio turno/)).toBeInTheDocument();
  const visible = document.body.textContent;
  expect(visible).not.toMatch(/El día que una descansa, la otra aparece en ambos turnos/);
});
