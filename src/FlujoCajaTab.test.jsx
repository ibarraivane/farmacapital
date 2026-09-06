import { render, screen } from "@testing-library/react";
import FlujoCajaTab from "./FlujoCajaTab";
import { FLUJO_DEMO_BUNDLE } from "./lib/flujoCajaDemo";

jest.mock("./supabase", () => ({
  supabase: { rpc: jest.fn() },
}));

const { supabase } = require("./supabase");

beforeEach(() => {
  sessionStorage.setItem("farmacapital_session_token", "tok");
  supabase.rpc.mockResolvedValue({ data: FLUJO_DEMO_BUNDLE, error: null });
});

test("Flujo muestra textos de mostrador y las mismas cifras", async () => {
  render(<FlujoCajaTab usuario={{ nombre: "Ivan Ibarra" }} demoBundle={FLUJO_DEMO_BUNDLE} />);
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
  expect(screen.getAllByText("$-30.50").length).toBeGreaterThanOrEqual(1);
  expect(screen.getByText("$180.00")).toBeInTheDocument();
  expect(screen.getAllByText("$-210.50").length).toBeGreaterThanOrEqual(1);
  expect(screen.getByText("$1,208.86")).toBeInTheDocument();
  const visible = document.body.textContent;
  expect(visible).not.toMatch(/total_general|costo_liquidacion|\bv1\b|RRHH|semilla|cubeta|pass-through|P&L|consulta 4/i);
  expect(visible).not.toMatch(/\bpiso\b/i);
  expect(supabase.rpc).not.toHaveBeenCalled();
});
