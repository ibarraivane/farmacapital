import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import ExpedientesDoctora from "./ExpedientesDoctora";
import { supabase } from "../../../supabase";

jest.mock("../../../supabase", () => ({
  supabase: {
    rpc: jest.fn(),
    from: jest.fn(),
  },
}));

const PACIENTE = {
  telefono: "525537275035",
  nombre: "Ivan ibarra",
  ultima: "2026-07-30",
  primera: "2026-04-19",
  n: 2,
  n_completadas: 2,
};

const CITA = {
  id: 11,
  nombre: "Ivan ibarra",
  telefono: "525537275035",
  fecha: "2026-07-30",
  hora: "09:00",
  motivo: "Control",
  estado: "completada",
  diagnostico: "HTA",
  signos_vitales: { ta: "128/82", peso: "68.2", talla: "162", fc: "74", temp: "36.6", sat: "97" },
  expediente_json: { edad: "34", sexo: "M", alergias: "Ninguna", antecedentes: "" },
  medicamentos_prescritos: [],
  procedimientos_realizados: [],
  notas_medico: "",
  consumo_consulta: [],
};

beforeEach(() => {
  sessionStorage.setItem("farmacapital_session_token", "tok");
  supabase.rpc.mockImplementation((name) => {
    if (name === "empleado_listar_pacientes_expedientes") {
      return Promise.resolve({ data: [PACIENTE], error: null });
    }
    if (name === "empleado_listar_citas_expediente_paciente") {
      return Promise.resolve({ data: [CITA], error: null });
    }
    return Promise.resolve({ data: null, error: null });
  });
  const single = jest.fn().mockResolvedValue({
    data: { ...CITA, consumibles_consulta: [] },
    error: null,
  });
  supabase.from.mockReturnValue({
    select: () => ({
      eq: () => ({
        single,
        neq: () => ({
          order: () => ({
            order: () => Promise.resolve({ data: [CITA], error: null }),
          }),
        }),
      }),
    }),
  });
});

test("cerrar la ficha vuelve al expediente del paciente, no a la lista", async () => {
  const user = userEvent.setup();
  render(<ExpedientesDoctora />);

  await screen.findByText("Ivan ibarra");
  await user.click(screen.getByRole("button", { name: /Ver expediente/i }));

  expect(await screen.findByTestId("evolucion-clinica")).toBeInTheDocument();
  expect(screen.getByText(/Historial de consultas/i)).toBeInTheDocument();
  expect(screen.getByText(/Evolución en el tiempo/i)).toBeInTheDocument();

  await user.click(screen.getByRole("button", { name: /Ver ficha completa/i }));
  expect(await screen.findByText(/Solo lectura/i)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /Volver a citas/i })).toBeInTheDocument();
  expect(screen.queryByText(/Historial de consultas/i)).toBeNull();

  await user.click(screen.getByRole("button", { name: /Volver a citas/i }));
  expect(await screen.findByText(/Historial de consultas/i)).toBeInTheDocument();
  expect(screen.getByTestId("evolucion-clinica")).toBeInTheDocument();
  const listHeading = screen.getByRole("heading", { name: /Expedientes/i });
  expect(listHeading).toBeInTheDocument();
  expect(within(document.body).getByText(/Expediente clínico/i)).toBeInTheDocument();
});
