import { render, screen } from "@testing-library/react";
import FlujoCajaTab from "./FlujoCajaTab";

jest.mock("./supabase", () => ({
  supabase: { rpc: jest.fn() },
}));

const { supabase } = require("./supabase");

const BUNDLE = {
  configurado: true,
  desde: "2026-09-01",
  hasta: "2026-09-05",
  fecha_inicio: "2026-08-18",
  piso_aplicado: "2026-08-18",
  saldo_inicial: 282,
  origen_piso: "sesion",
  entro: -30.5,
  quedo: -210.5,
  en_caja_hoy: 1208.86,
  salio: { total: 180, medicamento: 0, nomina: 0, otros_gastos: 0, liquidacion_mp: 180 },
  completitud: { incompleta: true, mes: "2026-09", sin_compra: false },
  cubetas: {
    cajon_cobrado_servicios: 210,
    saldo_mp_liquidacion: 210,
    saldo_mp_compensacion: 2.1,
    utilidad_servicios: 2.1,
  },
  semanas: [],
  gastos: [],
};

beforeEach(() => {
  sessionStorage.setItem("farmacapital_session_token", "tok");
  supabase.rpc.mockResolvedValue({ data: BUNDLE, error: null });
});

test("Flujo muestra textos de mostrador y las mismas cifras", async () => {
  render(<FlujoCajaTab usuario={{ nombre: "Ivan Ibarra" }} />);
  expect(await screen.findByText(/1 – 5 de septiembre/)).toBeInTheDocument();
  expect(screen.getByText(/Caja abierta el 18 de agosto con \$282\.00/)).toBeInTheDocument();
  expect(screen.getByText("De los cortes de caja")).toBeInTheDocument();
  expect(screen.getByText("Todo de liquidación Mercado Pago")).toBeInTheDocument();
  expect(screen.getByText("Faltan gastos por capturar")).toBeInTheDocument();
  expect(screen.getByText("Dinero contado hasta hoy")).toBeInTheDocument();
  expect(screen.getByText("Faltan gastos por capturar este mes")).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Capturar gastos" })).toBeInTheDocument();
  expect(screen.getByText("Este mes no compré a proveedor")).toBeInTheDocument();
  expect(screen.getByText("Recargas: el efectivo ya está contado")).toBeInTheDocument();
  expect(screen.getByText("¿Por qué los $210.00 aparecen dos veces?")).toBeInTheDocument();
  expect(screen.getByText("¿Por qué comprar medicamento no aparece como pérdida?")).toBeInTheDocument();
  expect(screen.getByText("$-30.50")).toBeInTheDocument();
  expect(screen.getByText("$180.00")).toBeInTheDocument();
  expect(screen.getByText("$-210.50")).toBeInTheDocument();
  expect(screen.getByText("$1,208.86")).toBeInTheDocument();
  const visible = document.body.textContent;
  expect(visible).not.toMatch(/total_general|costo_liquidacion|\bv1\b|RRHH|semilla|cubeta|pass-through|P&L|consulta 4/i);
  expect(visible).not.toMatch(/\bpiso\b/i);
});
