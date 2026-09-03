import React from "react";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import ReabastoModule from "./ReabastoModule";

jest.mock("./hooks/useCatalogoVivo", () => ({ useCatalogoVivo: () => {} }));
jest.mock("./hooks/useMediaQuery", () => ({ useMediaQuery: () => false }));
jest.mock("./supabase", () => ({
  supabase: {
    from: () => ({
      select: () => Promise.resolve({ data: [], error: null }),
    }),
  },
}));
jest.mock("./ui", () => ({
  showToast: jest.fn(),
  HorizontalScrollSync: ({ children }) => <div>{children}</div>,
  SkeletonTable: () => <div>cargando</div>,
}));
jest.mock("./lib/preciosReferencia", () => ({
  buildReferenciasPorProducto: () => ({}),
  dedupeReferenciasActuales: (rows) => rows || [],
  calcMejorCompra: () => null,
  calcMejorTienda: () => null,
  fmtPrecioRef: (n) => `$${n}`,
}));
jest.mock("./lib/asignarPedidosPorTienda", () => ({ asignarPedidosPorTienda: () => [] }));
jest.mock("./lib/exportarPedidoProveedor", () => ({
  descargarPedidoTienda: jest.fn(),
  descargarPedidosWorkbook: jest.fn(),
}));
jest.mock("./lib/inventarioHubData", () => {
  const busconetFa = {
    id: 33,
    nombre: "Busconet 1 Fa 250/20mg/5 Ml",
    sku: "EQ-SON033",
    marca: "Busconet",
    principio_activo: "Bromuro de butil hiocina y metamizol sódico",
    forma_farmaceutica: "",
    presentacion: "",
    stock: 0,
    stock_minimo: 5,
    costo: 33.38,
    activo: true,
  };
  const pasmodilFa = {
    id: 80,
    nombre: "Pasmodil 1 Fa 250/20 Mg",
    sku: "EQ-COL080",
    marca: "Pasmodil",
    principio_activo: "Hioscina / Metamizol sódico",
    forma_farmaceutica: "Solución inyectable",
    presentacion: "1 frasco ámpula",
    stock: 6,
    stock_minimo: 5,
    costo: 28.5,
    activo: true,
  };
  return {
    agruparLotesPorProducto: () => ({}),
    enriquecerProductoConLotes: (p) => ({
      ...p,
      stock_peps: Number(p.stock) || 0,
      lotes: [],
      lotes_activos: [],
      min_caducidad_lotes: null,
      diasCaducidad: null,
      proveedor: "",
      sinLotePeps: false,
    }),
    fetchLotesInventario: async () => ({ data: [], error: null }),
    fetchProductosPaginados: async () => ({
      data: [busconetFa, pasmodilFa],
      error: null,
    }),
  };
});

beforeEach(() => {
  sessionStorage.clear();
});

test("por principio activo Pasmodil cubre a Busconet y no sale agotado", async () => {
  render(<ReabastoModule />);
  await waitFor(() => expect(screen.getByText(/Hay Pasmodil/)).toBeInTheDocument());
  expect(screen.getByText(/falta Busconet/)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /agotados/i })).toHaveTextContent("0");
  expect(screen.getByRole("button", { name: /pronto/i })).toHaveTextContent("1");
});

test("por marca Busconet vuelve a verse agotado", async () => {
  render(<ReabastoModule />);
  await waitFor(() => expect(screen.getByRole("button", { name: "Por marca" })).toBeInTheDocument());
  fireEvent.click(screen.getByRole("button", { name: "Por marca" }));
  await waitFor(() => expect(screen.getByText("Busconet 1 Fa 250/20mg/5 Ml")).toBeInTheDocument());
  expect(screen.getByRole("button", { name: /agotados/i })).toHaveTextContent("1");
  expect(screen.getByText("Pasmodil 1 Fa 250/20 Mg")).toBeInTheDocument();
});
