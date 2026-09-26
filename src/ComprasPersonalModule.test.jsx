import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import ComprasPersonalModule from "./ComprasPersonalModule";
import { supabase } from "./supabase";

jest.mock("./supabase", () => ({ supabase: { rpc: jest.fn() } }));
jest.mock("./ui", () => {
  const actual = jest.requireActual("./ui");
  return { ...actual, showToast: jest.fn() };
});

const pendienteAdmin = {
  id: 7,
  empleado_beneficiario_nombre: "Erika",
  vendedor_nombre: "Mary",
  estado: "pendiente_aprobacion",
  creado_at: "2026-09-25T18:00:00Z",
  total_lista: 130,
  total_descuento: 26,
  total_final: 104,
  uso_mensual_previo: 40,
  excede_tope_mensual: false,
  excede_limite_producto: false,
  items: [
    {
      nombre: "Anthelios UV Air",
      cantidad: 1,
      precio_venta: 130,
      costo: 80,
      costo_estimado: false,
      margen_pct: 38.46,
      descuento_pct: 20,
      precio_final: 104,
    },
  ],
};

beforeEach(() => {
  sessionStorage.setItem("farmacapital_session_token", "tok-test");
  supabase.rpc.mockReset();
});

test("el vendedor ve estado y cobro, nunca costo ni margen", async () => {
  supabase.rpc.mockImplementation((name) => {
    if (name === "empleado_personal_compra_listar_propias") {
      return Promise.resolve({
        data: [
          {
            id: 7,
            empleado_beneficiario_nombre: "Erika",
            estado: "aprobada",
            total_final: 104,
            motivo_rechazo: null,
            creado_at: "2026-09-25T18:00:00Z",
            costo: 80,
            margen_pct: 38.46,
          },
        ],
        error: null,
      });
    }
    return Promise.resolve({ data: null, error: null });
  });

  render(<ComprasPersonalModule usuario={{ id: 2, nombre: "Mary", rol: "vendedor" }} />);

  expect(await screen.findByText("Erika")).toBeInTheDocument();
  expect(screen.getByText(/Aprobada/)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /Cobrar/ })).toBeInTheDocument();
  expect(document.body.textContent).not.toMatch(/costo/i);
  expect(document.body.textContent).not.toMatch(/margen/i);

  await waitFor(() =>
    expect(supabase.rpc).toHaveBeenCalledWith(
      "empleado_personal_compra_listar_propias",
      expect.objectContaining({ p_session_token: "tok-test" }),
    ),
  );
  expect(supabase.rpc).not.toHaveBeenCalledWith(
    "admin_personal_compra_listar_pendientes",
    expect.anything(),
  );
});

test("el admin ve costo, margen y el aviso de tope", async () => {
  supabase.rpc.mockResolvedValue({
    data: [{ ...pendienteAdmin, excede_tope_mensual: true }],
    error: null,
  });

  render(<ComprasPersonalModule usuario={{ id: 1, nombre: "Luis", rol: "admin" }} />);

  expect(await screen.findByText(/Beneficiario: Erika/)).toBeInTheDocument();
  expect(screen.getByText(/costo/)).toBeInTheDocument();
  expect(screen.getByText(/margen 38.46%/)).toBeInTheDocument();
  expect(screen.getByText(/excede el tope mensual/)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Aprobar" })).toBeInTheDocument();
  expect(screen.queryByRole("button", { name: /Cobrar/ })).not.toBeInTheDocument();

  await waitFor(() =>
    expect(supabase.rpc).toHaveBeenCalledWith(
      "admin_personal_compra_listar_pendientes",
      expect.objectContaining({ p_session_token: "tok-test" }),
    ),
  );
});

test("cobrar mixto exige que efectivo más tarjeta igualen el total", async () => {
  supabase.rpc.mockResolvedValue({
    data: [
      {
        id: 7,
        empleado_beneficiario_nombre: "Erika",
        estado: "aprobada",
        total_final: 104,
        creado_at: "2026-09-25T18:00:00Z",
      },
    ],
    error: null,
  });

  render(<ComprasPersonalModule usuario={{ id: 2, nombre: "Mary", rol: "vendedor" }} />);
  fireEvent.click(await screen.findByRole("button", { name: /Cobrar/ }));
  fireEvent.click(screen.getByRole("button", { name: "Mixto" }));

  const confirmar = screen.getByRole("button", { name: /Confirmar cobro/ });
  expect(confirmar).toBeDisabled();

  fireEvent.change(screen.getByPlaceholderText("Efectivo"), { target: { value: "50" } });
  fireEvent.change(screen.getByPlaceholderText("Tarjeta"), { target: { value: "54" } });
  expect(confirmar).toBeEnabled();

  const efectivo = screen.getByPlaceholderText("Efectivo");
  const tarjeta = screen.getByPlaceholderText("Tarjeta");
  expect(efectivo).toHaveClass("farmacapital-field-input");
  expect(efectivo).toHaveStyle({ backgroundColor: "#ffffff", colorScheme: "light" });
  expect(tarjeta).toHaveStyle({ colorScheme: "light" });
});
