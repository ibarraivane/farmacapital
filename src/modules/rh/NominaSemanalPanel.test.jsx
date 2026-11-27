import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { diasLaboralesSemana, hoyISOMexico, sabadoDeSemana, viernesDeSemana } from "../../lib/rhSemana";
import NominaSemanalPanel from "./NominaSemanalPanel";

jest.mock("../../supabase", () => ({
  supabase: { rpc: jest.fn() },
}));

const { supabase } = require("../../supabase");

const C = {
  text: "#111", textMid: "#666", textDim: "#999",
  blue: "#2563eb", blueDim: "#dbeafe", green: "#16a34a",
  red: "#dc2626", amber: "#d97706", bg: "#f8fafc", border: "#e2e8f0",
};
const S = {
  section: {},
  h2: {},
  label: {},
  input: {},
  select: {},
  btnBlue: {},
  btnGreen: {},
};

const EMPS = [
  { id: 1, nombre: "Erika", rol: "vendedor", turno: "matutino", estado: true, salario_semanal: 1133.32 },
];

const HOY = hoyISOMexico();
const SEMANA = {
  empleado_id: 1,
  nombre: "Erika",
  salario_semanal: 1133.32,
  diario: 161.9,
  semana_inicio: sabadoDeSemana(HOY),
  semana_fin: viernesDeSemana(HOY),
  dias: diasLaboralesSemana(HOY).map((fecha) => ({
    fecha, estado: "trabajo", origen: "caja", abrio_caja: true,
  })),
  dias_trabajo: 7,
  bruto: 1133.32,
  pago: null,
};

beforeEach(() => {
  sessionStorage.setItem("farmacapital_session_token", "tok");
  supabase.rpc.mockReset();
});

test("el panel es semanal de viernes, sábado a viernes, no quincenal ni ISR automático", () => {
  render(<NominaSemanalPanel empleados={EMPS} S={S} C={C} />);
  expect(screen.getByText(/Nómina semanal/i)).toBeInTheDocument();
  expect(screen.getByText(/se paga el viernes/i)).toBeInTheDocument();
  expect(screen.getByText(/sábado a viernes/i)).toBeInTheDocument();
  expect(screen.getByText(/abrir o cerrar caja siguen en su lugar/i)).toBeInTheDocument();
  expect(screen.queryByText(/quincenal/i)).not.toBeInTheDocument();
  expect(screen.queryByText(/ISR estimado/i)).not.toBeInTheDocument();
});

test("al elegir empleado carga la semana sábado–viernes", async () => {
  supabase.rpc.mockResolvedValue({ data: SEMANA, error: null });
  render(<NominaSemanalPanel empleados={EMPS} S={S} C={C} />);
  await userEvent.selectOptions(screen.getByLabelText("Empleado"), "1");
  await waitFor(() => {
    expect(supabase.rpc).toHaveBeenCalledWith(
      "rh_semana_empleado",
      expect.objectContaining({ p_empleado_id: 1 }),
    );
  });
  expect(await screen.findByText(/Neto a pagar el viernes/)).toBeInTheDocument();
  expect(screen.getAllByText("$1,133.32").length).toBeGreaterThan(0);
  expect(screen.getByRole("button", { name: "Registrar pago del viernes" })).toBeEnabled();
  expect(screen.getAllByText(/sábado/i).length).toBeGreaterThan(0);
});

test("si la base sigue empezando en martes, no deja registrar el pago", async () => {
  supabase.rpc.mockResolvedValue({
    data: { ...SEMANA, semana_inicio: "2026-08-18", semana_fin: "2026-08-21", dias_trabajo: 4 },
    error: null,
  });
  render(<NominaSemanalPanel empleados={EMPS} S={S} C={C} />);
  await userEvent.selectOptions(screen.getByLabelText("Empleado"), "1");
  expect(await screen.findByText(/patch_rh_semana_sabado_viernes_20260926\.sql/)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Registrar pago del viernes" })).toBeDisabled();
});

test("si falta el SQL semanal, calcula en local y no inventa ISR", async () => {
  supabase.rpc.mockResolvedValue({
    data: null,
    error: { message: "Could not find the function public.rh_semana_empleado" },
  });
  render(<NominaSemanalPanel empleados={EMPS} S={S} C={C} />);
  await userEvent.selectOptions(screen.getByLabelText("Empleado"), "1");
  expect(await screen.findByText(/patch_rh_pago_semanal_20260822\.sql/)).toBeInTheDocument();
  expect(screen.getByText(/Neto a pagar el viernes/)).toBeInTheDocument();
  expect(screen.getAllByText("$1,133.32").length).toBeGreaterThan(0);
  expect(screen.getByText("ISR").parentElement).toHaveTextContent("$0.00");
});
