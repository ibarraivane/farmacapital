import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import TarjetaProducto from "./TarjetaProducto";

jest.mock("../../../hooks/useProductoImagenes", () => ({
  useUrlsImagenesProducto: () => () => [],
  siguienteIndiceFotoTarjeta: () => -1,
}));

const omeprazol = {
  id: 7,
  nombre: "Omeprazol 20 mg",
  marca: "Genérico",
  presentacion: "30 cápsulas",
  precio: 89,
  stock: 5,
  bajo_pedido: false,
  activo: true,
};

test("tarjeta de sucursal abre el producto", () => {
  const onClick = jest.fn();
  render(<TarjetaProducto prod={omeprazol} onClick={onClick} />);
  expect(screen.getByText("Disponible en sucursal")).toBeInTheDocument();
  expect(screen.getByText("Genérico")).toBeInTheDocument();
  expect(screen.getByText("$89")).toBeInTheDocument();
  expect(screen.getByText("30 cápsulas")).toBeInTheDocument();
  expect(screen.getByText("Ver producto →")).toBeInTheDocument();
  fireEvent.click(screen.getByText("Omeprazol 20 mg"));
  expect(onClick).toHaveBeenCalled();
});

test("bajo pedido no inventa precio y dice Ver encargo", () => {
  const onClick = jest.fn();
  render(
    <TarjetaProducto
      prod={{
        id: 2,
        nombre: "CeraVe Crema hidratante",
        marca: "CeraVe",
        presentacion: "473 ml",
        precio: 0,
        stock: 0,
        bajo_pedido: true,
        categoria: "Cuidado personal",
        subcategoria: "Dermatología",
      }}
      onClick={onClick}
    />
  );
  expect(screen.getByText("Por encargo")).toBeInTheDocument();
  expect(screen.getByText("Consultar")).toBeInTheDocument();
  expect(screen.queryByText("$0")).not.toBeInTheDocument();
  fireEvent.click(screen.getByText("Ver encargo →"));
  expect(onClick).toHaveBeenCalled();
});

test("grupo de sabores muestra el título sin sabor y la leyenda", () => {
  render(
    <TarjetaProducto
      prod={{
        id: 2,
        nombre: "Falcon Protein - Nueva Fórmula - Chocolate 480g",
        titulo_grupo_publico: "Falcon Protein - Nueva Fórmula - 480g",
        sabores_publicos: 6,
        marca: "Birdman",
        presentacion: "480 g",
        precio: 0,
        stock: 0,
        bajo_pedido: true,
        categoria: "Suplemento",
        subcategoria: "Proteína",
      }}
      onClick={() => {}}
    />
  );
  expect(screen.getByText("Falcon Protein - Nueva Fórmula - 480g")).toBeInTheDocument();
  expect(screen.getByText(/6 sabores/)).toBeInTheDocument();
  expect(screen.queryByText(/Chocolate/)).not.toBeInTheDocument();
});

test("antibiótico con receta marca Solo recoger", () => {
  render(
    <TarjetaProducto
      prod={{
        id: 9,
        nombre: "Amoxicilina 500 mg",
        presentacion: "12 cápsulas",
        precio: 72,
        stock: 3,
        requiere_receta: true,
        categoria: "Antibiótico",
      }}
      onClick={() => {}}
    />
  );
  expect(screen.getByText("Disponible en sucursal · Solo recoger")).toBeInTheDocument();
  expect(screen.getByText(/Requiere receta/)).toBeInTheDocument();
});
