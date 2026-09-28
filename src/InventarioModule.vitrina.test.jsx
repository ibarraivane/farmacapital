import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import InventarioModule from "./InventarioModule";
import { STORAGE_MOSTRAR_VITRINA } from "./lib/inventarioVista";

jest.mock("./supabase", () => {
  const filas = [
    { id: 1, nombre: "Omeprazol 20 mg", sku: "FC-1", categoria: "Gastro", stock: 4, stock_minimo: 2, costo: 10, precio: 25, activo: true, bajo_pedido: false },
    { id: 2, nombre: "Anthelios UV Air", sku: "FC-2", categoria: "Cuidado personal", subcategoria: "Dermatología", stock: 0, costo: 80, precio: 0, activo: true, bajo_pedido: true },
    { id: 3, nombre: "Whey Gold", sku: "FC-3", categoria: "Suplemento", stock: 0, costo: 40, precio: 0, activo: true, bajo_pedido: true },
  ];
  const query = (result) => {
    const q = {
      select: () => q,
      eq: () => q,
      or: () => q,
      order: () => q,
      range: () => q,
      in: () => q,
      limit: () => q,
      then: (ok, fail) => Promise.resolve(result).then(ok, fail),
    };
    return q;
  };
  return {
    supabase: {
      from: (table) => query(table === "productos"
        ? { data: filas, error: null }
        : { data: [], error: null }),
      rpc: () => Promise.resolve({ data: [], error: null }),
      channel: () => {
        const ch = { on: () => ch, subscribe: () => ch };
        return ch;
      },
      removeChannel: () => {},
    },
  };
});

beforeEach(() => {
  localStorage.removeItem(STORAGE_MOSTRAR_VITRINA);
  localStorage.setItem("farmacapital_tour_inv_anon", "1");
});

test("el interruptor apaga y prende suplementos y dermatología sin borrarlos", async () => {
  render(<InventarioModule />);

  expect(await screen.findByText("Omeprazol 20 mg")).toBeInTheDocument();
  expect(screen.queryByText("Anthelios UV Air")).not.toBeInTheDocument();
  expect(screen.queryByText("Whey Gold")).not.toBeInTheDocument();
  expect(screen.getByText(/No se borran: siguen en «Te lo conseguimos»/)).toBeInTheDocument();

  await userEvent.click(screen.getByRole("switch", { name: "Suplementos y dermatología" }));

  await waitFor(() => {
    expect(screen.getByText("Anthelios UV Air")).toBeInTheDocument();
  });
  expect(screen.getByText("Whey Gold")).toBeInTheDocument();
  expect(screen.getByText("Omeprazol 20 mg")).toBeInTheDocument();
  expect(screen.queryByText(/No se borran/)).not.toBeInTheDocument();

  await userEvent.click(screen.getByRole("switch", { name: "Suplementos y dermatología" }));

  await waitFor(() => {
    expect(screen.queryByText("Anthelios UV Air")).not.toBeInTheDocument();
    expect(screen.getByText("Omeprazol 20 mg")).toBeInTheDocument();
  });
  expect(screen.queryByText("Whey Gold")).not.toBeInTheDocument();
});
