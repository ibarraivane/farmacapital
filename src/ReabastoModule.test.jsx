import { render, screen, waitFor } from "@testing-library/react";
import ReabastoModule from "./ReabastoModule";
import { fetchLotesInventario, fetchProductosPaginados } from "./lib/inventarioHubData";

jest.mock("./hooks/useCatalogoVivo", () => ({
  useCatalogoVivo: () => {},
}));

jest.mock("./lib/inventarioHubData", () => {
  const actual = jest.requireActual("./lib/inventarioHubData");
  return {
    ...actual,
    fetchProductosPaginados: jest.fn(),
    fetchLotesInventario: jest.fn(),
  };
});

jest.mock("./supabase", () => ({
  supabase: {
    from: () => ({
      select: () => Promise.resolve({ data: [], error: null }),
    }),
  },
}));

const tempra = {
  id: 1,
  nombre: "Tempra 500 mg C/20",
  sku: "FC-TEMPRA",
  marca: "Tempra",
  tipo: "marca",
  principio_activo: "Paracetamol",
  stock: 0,
  stock_minimo: 5,
  costo: 28,
  activo: true,
};
const paracetamolGen = {
  id: 2,
  nombre: "Paracetamol 500 mg C/20",
  sku: "FC-PARA",
  marca: "Genérico",
  tipo: "generico",
  principio_activo: "Paracetamol",
  stock: 2,
  stock_minimo: 8,
  costo: 12,
  activo: true,
};
const tylenolOk = {
  id: 3,
  nombre: "Tylenol 500 mg",
  sku: "FC-TYL",
  marca: "Tylenol",
  tipo: "marca",
  principio_activo: "Paracetamol",
  stock: 18,
  stock_minimo: 5,
  costo: 40,
  activo: true,
};
const huggies80 = {
  id: 20,
  nombre: "Toallitas Huggies C/80",
  sku: "FC-H80",
  marca: "Huggies",
  stock: 3,
  stock_minimo: 6,
  costo: 45,
  activo: true,
};
const huggies40 = {
  id: 21,
  nombre: "Toallitas Huggies C/40",
  sku: "FC-H40",
  marca: "Huggies",
  stock: 4,
  stock_minimo: 6,
  costo: 28,
  activo: true,
};

beforeEach(() => {
  sessionStorage.setItem("farmacapital_session_token", "tok");
  fetchProductosPaginados.mockResolvedValue({
    data: [tempra, paracetamolGen, tylenolOk, huggies80, huggies40],
    error: null,
  });
  fetchLotesInventario.mockResolvedValue({ data: [], error: null });
});

test("agrupa Tempra y el genérico como el mismo medicamento y avisa stock de Tylenol", async () => {
  render(<ReabastoModule />);
  await waitFor(() => expect(screen.getByText("Tempra 500 mg C/20")).toBeInTheDocument());
  expect(screen.getByText("Agrupado por principio activo (mismo medicamento) y marca.")).toBeInTheDocument();
  expect(screen.getAllByText("Paracetamol").length).toBeGreaterThan(0);
  expect(screen.getByText(/Mismo medicamento · 2 marcas/)).toBeInTheDocument();
  expect(screen.getByText(/También hay stock: Tylenol \(18\)/)).toBeInTheDocument();
  expect(screen.getByText("Tempra 500 mg C/20")).toBeInTheDocument();
  expect(screen.getByText("Paracetamol 500 mg C/20")).toBeInTheDocument();
  expect(screen.getAllByText("PA: Paracetamol").length).toBeGreaterThanOrEqual(2);
  expect(screen.getByText("Patente")).toBeInTheDocument();
  expect(screen.getAllByText("Genérico").length).toBeGreaterThan(0);
});

test("sin principio activo junta las presentaciones de la misma marca", async () => {
  render(<ReabastoModule />);
  await waitFor(() => expect(screen.getByText("Toallitas Huggies C/80")).toBeInTheDocument());
  expect(screen.getAllByText("Huggies").length).toBeGreaterThan(1);
  expect(screen.getByText(/Misma marca/)).toBeInTheDocument();
  expect(screen.getByText("Toallitas Huggies C/40")).toBeInTheDocument();
});
