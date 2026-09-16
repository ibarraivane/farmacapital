import React from "react";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import EncargosBajoPedidoPanel from "./EncargosBajoPedidoPanel";
import { supabase } from "../supabase";

jest.mock("../supabase", () => ({ supabase: { rpc: jest.fn() } }));
jest.mock("../ui", () => ({ showToast: jest.fn() }));

const enDias = (d) => new Date(Date.now() + d * 86400000).toISOString();

const encargo = {
  id: 77, total: 958, estado: "pendiente", tipo_entrega: "recoger", payment_status: "authorized",
  payment_payload: { modo: "reserva", order_id: "ORD1", reserva_expira_at: enDias(3) },
  logistics_meta: { bajo_pedido: true }, clientes: { nombre: "Ana", telefono: "5512345678" },
  pedido_items: [{ cantidad: 2, precio_unitario: 479, productos: { id: 901, nombre: "Anthelios", codigo_barras: "3337875", stock: 2 } }],
};

beforeEach(() => {
  sessionStorage.setItem("farmacapital_session_token", "emp-tok");
  supabase.rpc.mockReset();
  global.fetch = jest.fn();
  window.confirm = jest.fn(() => true);
  window.prompt = jest.fn(() => "No lo surtió Nadro");
});

it("lista la reserva con vencimiento y cobra con la sesión de empleado", async () => {
  supabase.rpc.mockResolvedValue({ data: [encargo], error: null });
  global.fetch.mockResolvedValue({ ok: true, json: async () => ({ ok: true }) });
  render(<EncargosBajoPedidoPanel />);
  expect(await screen.findByText(/Encargo #77/)).toBeInTheDocument();
  expect(screen.getByText(/Vence en 7\d h/)).toBeInTheDocument();
  expect(screen.getByText(/en tienda: 2/)).toBeInTheDocument();
  fireEvent.click(screen.getByRole("button", { name: "Cobrar reserva" }));
  await waitFor(() => expect(global.fetch).toHaveBeenCalled());
  const [url, init] = global.fetch.mock.calls[0];
  expect(url).toBe("/api/payments/mp/point?action=reserva-cobrar");
  expect(init.headers["x-session-token"]).toBe("emp-tok");
  expect(JSON.parse(init.body).pedidoId).toBe(77);
  expect(supabase.rpc).toHaveBeenCalledWith("empleado_listar_encargos_bajo_pedido", { p_session_token: "emp-tok", p_limit: 100 });
});

it("si aún no llegó avisa en el botón; cancelar pide motivo", async () => {
  const sinStock = { ...encargo, pedido_items: [{ ...encargo.pedido_items[0], productos: { ...encargo.pedido_items[0].productos, stock: 0 } }] };
  supabase.rpc.mockResolvedValue({ data: [sinStock], error: null });
  global.fetch.mockResolvedValue({ ok: true, json: async () => ({ ok: true }) });
  render(<EncargosBajoPedidoPanel />);
  expect(await screen.findByRole("button", { name: "Cobrar (¿ya llegó?)" })).toBeInTheDocument();
  fireEvent.click(screen.getByRole("button", { name: "Cancelar reserva" }));
  await waitFor(() => expect(global.fetch).toHaveBeenCalled());
  const [url, init] = global.fetch.mock.calls[0];
  expect(url).toBe("/api/payments/mp/point?action=reserva-cancelar");
  expect(JSON.parse(init.body).motivo).toBe("No lo surtió Nadro");
});

it("reserva vencida no deja cobrar", async () => {
  supabase.rpc.mockResolvedValue({ data: [{ ...encargo, payment_payload: { ...encargo.payment_payload, reserva_expira_at: enDias(-1) } }], error: null });
  render(<EncargosBajoPedidoPanel />);
  expect(await screen.findByText("Reserva vencida")).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /Cobrar/ })).toBeDisabled();
});
