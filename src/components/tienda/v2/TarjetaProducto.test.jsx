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
  presentacion: "30 cápsulas",
  precio: 89,
  stock: 5,
  bajo_pedido: false,
};

test("tarjeta abre el producto y el + agrega", () => {
  const onClick = jest.fn();
  const addToCart = jest.fn(() => true);
  render(<TarjetaProducto prod={omeprazol} onClick={onClick} addToCart={addToCart} />);
  expect(screen.getByText("En sucursal")).toBeInTheDocument();
  expect(screen.getByText("$89")).toBeInTheDocument();
  expect(screen.getByText("30 cápsulas")).toBeInTheDocument();
  fireEvent.click(screen.getByText("Omeprazol 20 mg"));
  expect(onClick).toHaveBeenCalled();
  fireEvent.click(screen.getByLabelText("Agregar al carrito"));
  expect(addToCart).toHaveBeenCalledWith(omeprazol);
  expect(screen.getByLabelText("En tu carrito")).toBeInTheDocument();
});

test("bajo pedido no inventa precio y el + abre la ficha", () => {
  const onClick = jest.fn();
  const addToCart = jest.fn();
  render(
    <TarjetaProducto
      prod={{ id: 2, nombre: "CeraVe", presentacion: "473 ml", precio: 0, stock: 0, bajo_pedido: true, categoria: "Cuidado personal", subcategoria: "Dermatología" }}
      onClick={onClick}
      addToCart={addToCart}
    />
  );
  expect(screen.getByText(/Por encargo/)).toBeInTheDocument();
  expect(screen.queryByText("$0")).not.toBeInTheDocument();
  fireEvent.click(screen.getByLabelText("Ver producto"));
  expect(onClick).toHaveBeenCalled();
  expect(addToCart).not.toHaveBeenCalled();
});

test("agotado no muestra el botón +", () => {
  render(<TarjetaProducto prod={{ id: 3, nombre: "X", stock: 0, precio: 10 }} onClick={() => {}} />);
  expect(screen.getByText("Agotado")).toBeInTheDocument();
  expect(screen.queryByLabelText("Agregar al carrito")).not.toBeInTheDocument();
});
