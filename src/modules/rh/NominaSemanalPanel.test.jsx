import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
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

const SEMANA = {
  empleado_id: 1,
  nombre: "Erika",
  salario_semanal: 1133.32,
  diario: 283.33,
  semana_inicio: "2026-08-18",
  semana_fin: "2026-08-21",
  dias: [
    { fecha: "2026-08-18", estado: "trabajo", origen: "caja", abrio_caja: true },
    { fecha: "2026-08-19", estado: "trabajo", origen: "caja", abrio_caja: true },
    { fecha: "2026-08-20", estado: "trabajo", origen: "caja", abrio_caja: true },
    { fecha: "2026-08-21", estado: "trabajo", origen: "caja", abrio_caja: true },
  ],
  dias_trabajo: 4,
  bruto: 1133.32,
  pago: null,
};

beforeEach(() => {
  sessionStorage.setItem("farmacapital_session_token", "tok");
  supabase.rpc.mockReset();
});

test("el panel es semanal de viernes, no quincenal ni ISR automático", () => {
  render(<NominaSemanalPanel empleados={EMPS} S={S} C={C} />);
  expect(screen.getByText(/Nómina semanal/i)).toBeInTheDocument();
  expect(screen.getByText(/se paga el viernes/i)).toBeInTheDocument();
  expect(screen.queryByText(/quincenal/i)).not.toBeInTheDocument();
  expect(screen.queryByText(/ISR estimado/i)).not.toBeInTheDocument();
});

test("al elegir empleado carga la semana martes–viernes", async () => {
  const user = userEvent.setup();
  supabase.rpc.mockResolvedValue({ data: SEMANA, error: null });
  render(<NominaSemanalPanel empleados={EMPS} S={S} C={C} />);
  await user.selectOptions(screen.getByLabelText("Empleado"), "1");
  await waitFor(() => {
    expect(supabase.rpc).toHaveBeenCalledWith(
      "rh_semana_empleado",
      expect.objectContaining({ p_empleado_id: 1 }),
    );
  });
  expect(await screen.findByText("Neto a pagar el viernes")).toBeInTheDocument();
  expect(screen.getByText("$1,133.32")).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Registrar pago del viernes" })).toBeInTheDocument();
});

test("si falta el SQL semanal, calcula en local y no inventa ISR", async () => {
  const user = userEvent.setup();
  supabase.rpc.mockResolvedValue({
    data: null,
    error: { message: "Could not find the function public.rh_semana_empleado" },
  });
  render(<NominaSemanalPanel empleados={EMPS} S={S} C={C} />);
  await user.selectOptions(screen.getByLabelText("Empleado"), "1");
  expect(await screen.findByText(/patch_rh_pago_semanal_20260822\.sql/)).toBeInTheDocument();
  expect(screen.getByText("Neto a pagar el viernes")).toBeInTheDocument();
  expect(screen.getAllByText("$1,133.32").length).toBeGreaterThan(0);
  expect(screen.getByText("ISR").parentElement).toHaveTextContent("$0.00");
});
