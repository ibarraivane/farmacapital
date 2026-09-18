import { supabase } from "../supabase";
import { fetchSesionCajaAbierta, esErrorTimeoutPostgres } from "./cajaSesion";

jest.mock("../supabase", () => ({
  supabase: { rpc: jest.fn() },
}));

beforeEach(() => {
  sessionStorage.setItem("farmacapital_session_token", "tok-caja");
  supabase.rpc.mockReset();
});

test("el timeout de Postgres no se trata como caja cerrada", () => {
  expect(esErrorTimeoutPostgres("canceling statement due to statement timeout")).toBe(true);
  expect(esErrorTimeoutPostgres("canceling statement due to lock timeout")).toBe(true);
  expect(esErrorTimeoutPostgres("Ya tienes una caja abierta.")).toBe(false);
  expect(esErrorTimeoutPostgres("Sesión inválida o expirada")).toBe(false);
});

test("reintenta si Postgres corta por timeout y luego encuentra la caja", async () => {
  const waits = [];
  supabase.rpc
    .mockResolvedValueOnce({
      data: null,
      error: { message: "canceling statement due to statement timeout" },
    })
    .mockResolvedValueOnce({
      data: { abierta: true, id: 9, turno: "vespertino" },
      error: null,
    });

  const out = await fetchSesionCajaAbierta({
    esperar: async (ms) => { waits.push(ms); },
  });

  expect(supabase.rpc).toHaveBeenCalledTimes(2);
  expect(waits).toEqual([350]);
  expect(out.error).toBeNull();
  expect(out.sesion).toEqual({ abierta: true, id: 9, turno: "vespertino" });
});

test("tras 3 timeouts no dice que la caja se cerró", async () => {
  supabase.rpc.mockResolvedValue({
    data: null,
    error: { message: "canceling statement due to statement timeout" },
  });

  const out = await fetchSesionCajaAbierta({ esperar: async () => {} });

  expect(supabase.rpc).toHaveBeenCalledTimes(3);
  expect(out.auth).toBe(false);
  expect(out.sesion).toBeNull();
  expect(out.error).toMatch(/tardó en responder/i);
  expect(out.error).not.toMatch(/canceling statement/i);
});

test("sesión inválida no se reintenta", async () => {
  supabase.rpc.mockResolvedValue({
    data: null,
    error: { message: "Sesión inválida o expirada" },
  });

  const out = await fetchSesionCajaAbierta({ esperar: async () => {} });

  expect(supabase.rpc).toHaveBeenCalledTimes(1);
  expect(out.auth).toBe(true);
  expect(out.error).toMatch(/inválida/i);
});
