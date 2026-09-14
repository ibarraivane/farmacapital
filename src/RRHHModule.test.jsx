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
      return Promise.resolve({ data: [], error: null });
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
