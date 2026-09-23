import { render, screen, fireEvent } from "@testing-library/react";
import CatalogoV2, { ordenarCatalogoV2 } from "./CatalogoV2";

const PRODUCTOS = [
  { id: 1, nombre: "Omeprazol 20 mg", precio: 89, stock: 5 },
  { id: 2, nombre: "Paracetamol 500 mg", precio: 28, stock: 9 },
  { id: 3, nombre: "Sin precio", precio: 0, stock: 0, bajo_pedido: true },
];

test("ordena por menor precio y deja el resto como viene", () => {
  expect(ordenarCatalogoV2(PRODUCTOS, "precio").map((p) => p.id)).toEqual([2, 1, 3]);
  expect(ordenarCatalogoV2(PRODUCTOS, "relevancia").map((p) => p.id)).toEqual([1, 2, 3]);
});

test("muestra los productos, el conteo y la salida a cotizar", () => {
  const setPage = jest.fn();
  render(
    <CatalogoV2
      titulo="Medicamentos"
      productos={PRODUCTOS}
      total={3}
      categorias={["Todos", "Gastro"]}
      categoria="Todos"
      setPage={setPage}
      onProducto={() => {}}
    />
  );
  expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent("Medicamentos");
  expect(screen.getByRole("status")).toHaveTextContent("3 productos · Precios en línea");
  expect(screen.getByText("Omeprazol 20 mg")).toBeInTheDocument();
  fireEvent.click(screen.getByText("¿No está aquí?"));
  expect(setPage).toHaveBeenCalledWith("cotizar");
});

test("sin resultados no deja la pantalla vacía", () => {
  render(<CatalogoV2 productos={[]} total={0} setPage={() => {}} />);
  expect(screen.getByText("No encontramos esa combinación.")).toBeInTheDocument();
});

test("el filtro de categoría avisa al contenedor", () => {
  const onCategoria = jest.fn();
  render(
    <CatalogoV2
      productos={PRODUCTOS}
      total={3}
      categorias={["Todos", "Gastro"]}
      categoria="Todos"
      onCategoria={onCategoria}
      setPage={() => {}}
    />
  );
  fireEvent.click(screen.getByRole("button", { name: "Gastro" }));
  expect(onCategoria).toHaveBeenCalledWith("Gastro");
});
