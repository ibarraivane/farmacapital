import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
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
  expect(screen.getByLabelText("Mes del flujo")).toBeInTheDocument();
  expect(screen.getByLabelText("Mes anterior")).toBeInTheDocument();
  expect(screen.getByLabelText("Mes siguiente")).toBeDisabled();
  expect(screen.getByText(/Caja abierta el 18 de agosto con \$282\.00/)).toBeInTheDocument();
  expect(screen.getByText("De los cortes de caja")).toBeInTheDocument();
  expect(screen.getByText("Todo de liquidación Mercado Pago")).toBeInTheDocument();
  expect(screen.getByText("Faltan gastos por capturar")).toBeInTheDocument();
  expect(screen.getByText("Dinero contado hasta hoy")).toBeInTheDocument();
  expect(screen.getByText("Faltan gastos por capturar este mes")).toBeInTheDocument();
  expect(screen.getByText(/La nómina se paga los viernes/)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Capturar gastos" })).toBeInTheDocument();
  expect(screen.getByText("Este mes no compré a proveedor")).toBeInTheDocument();
  expect(screen.getByText("Recargas: el cobro ya está contado")).toBeInTheDocument();
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

test("si hubo recargas con tarjeta, el flujo las muestra fuera del cajón", async () => {
  const bundle = {
    ...FLUJO_DEMO_BUNDLE,
    cubetas: {
      ...FLUJO_DEMO_BUNDLE.cubetas,
      cajon_cobrado_servicios: 110,
      tarjeta_cobrada_servicios: 100,
    },
  };
  render(<FlujoCajaTab usuario={{ nombre: "Ivan Ibarra" }} demoBundle={bundle} />);
  expect(await screen.findByText("Cobrado con tarjeta")).toBeInTheDocument();
  expect(screen.getByText("corte de tarjeta, no cajón")).toBeInTheDocument();
  expect(screen.getByText("$100.00")).toBeInTheDocument();
});

test("en Gastos la nómina se describe como semanal de viernes", async () => {
  render(<FlujoCajaTab usuario={{ nombre: "Ivan Ibarra" }} demoBundle={FLUJO_DEMO_BUNDLE} />);
  await userEvent.click(screen.getByRole("tab", { name: "Gastos" }));
  expect(await screen.findByText(/Nómina \(viernes\)/)).toBeInTheDocument();
  await userEvent.selectOptions(screen.getByDisplayValue("Renta"), "nomina");
  expect(screen.getByPlaceholderText(/Nómina viernes/i)).toBeInTheDocument();
  expect(screen.getByText(/nómina: cada viernes/i)).toBeInTheDocument();
});

test("un gasto a mano se puede corregir: categoría, concepto y monto", async () => {
  render(<FlujoCajaTab usuario={{ nombre: "Ivan Ibarra" }} demoBundle={FLUJO_DEMO_BUNDLE} />);
  await userEvent.click(screen.getByRole("tab", { name: "Gastos" }));
  await userEvent.click(screen.getByRole("button", { name: "Editar Erika" }));
  expect(screen.getByText("Corregir gasto")).toBeInTheDocument();
  expect(screen.getByDisplayValue("Erika")).toBeInTheDocument();
  expect(screen.getByDisplayValue("1133.32")).toBeInTheDocument();
  await userEvent.selectOptions(screen.getByDisplayValue("Renta"), "nomina");
  await userEvent.click(screen.getByRole("button", { name: "Guardar cambios" }));
  expect(screen.queryByText("Corregir gasto")).not.toBeInTheDocument();
  expect(screen.getByRole("cell", { name: "Nómina" })).toBeInTheDocument();
});
