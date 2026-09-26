import React from "react";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import CotizacionesModule from "./CotizacionesModule";
import { supabase } from "./supabase";

jest.mock("./supabase", () => ({ supabase: { rpc: jest.fn() } }));
jest.mock("./ui", () => {
  const actual = jest.requireActual("./ui");
  return { ...actual, showToast: jest.fn() };
});

const cotiz = {
  id: 142,
  folio: "C-142",
  cliente_nombre: "María López",
  cliente_telefono: "5512345678",
  origen: "tienda",
  urgencia: "hoy",
  estado: "buscando",
  resumen: "Anthelios UV Air ×2",
  created_at: "2026-09-21T10:00:00Z",
  totales: { costo: 778, venta: 972, ganancia: 194, lineas: 1 },
  items: [
    {
      id: 1,
      texto: "Anthelios UV Air",
      cantidad: 2,
      tipo_margen: "marca",
      estado: "elegido",
      costo_elegido: 389,
      precio_venta: 486,
      fuentes: [
        { id: 9, lugar: "dermaexpress", precio: 389, elegida: true, disponible: true, url: "https://ejemplo" },
      ],
    },
  ],
};

beforeEach(() => {
  sessionStorage.setItem("farmacapital_session_token", "adm-tok");
  sessionStorage.removeItem("farmacapital_cotiz_open_id");
  supabase.rpc.mockReset();
  supabase.rpc.mockImplementation((name) => {
    if (name === "admin_listar_cotizaciones") return Promise.resolve({ data: [cotiz], error: null });
    if (name === "admin_obtener_cotizacion") return Promise.resolve({ data: cotiz, error: null });
    return Promise.resolve({ data: cotiz, error: null });
  });
});

it("lista cotizaciones y abre la ficha con comparativa y recargo/margen", async () => {
  render(<CotizacionesModule usuario={{ id: 1, nombre: "Luis", rol: "admin" }} />);
  expect(await screen.findByRole("heading", { name: "Cotizaciones" })).toBeInTheDocument();
  expect(await screen.findByText(/C-142/)).toBeInTheDocument();
  expect(screen.getByText(/María López/)).toBeInTheDocument();

  fireEvent.click(screen.getByRole("button", { name: /Nueva cotización/ }));
  const nombre = screen.getByPlaceholderText("Nombre");
  expect(nombre).toHaveClass("farmacapital-field-input");
  expect(nombre).toHaveStyle({ background: "#ffffff" });

  fireEvent.click(screen.getByText(/C-142/));
  expect(await screen.findByText(/Agregar fuente/)).toBeInTheDocument();
  expect(screen.getAllByText(/Dermaexpress/).length).toBeGreaterThan(0);
  expect(screen.getAllByText(/Recargo/).length).toBeGreaterThan(0);
  expect(screen.getByText(/sobre venta/)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Guardar" })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Quitar" })).toBeInTheDocument();
  await waitFor(() =>
    expect(supabase.rpc).toHaveBeenCalledWith(
      "admin_obtener_cotizacion",
      expect.objectContaining({ p_id: 142 }),
    ),
  );
});
