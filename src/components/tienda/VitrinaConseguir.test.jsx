import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import VitrinaConseguir from "./VitrinaConseguir";
import { STRIP_TOPE_CONSEGUIR } from "../../lib/bajoPedido";

const productos = [
  { id: 1, nombre: "Omron Monitor de Presión", precio: 847, stock: 0, activo: true, bajo_pedido: true, categoria: "Dispositivo médico" },
  { id: 2, nombre: "Redoxon Vitamina C", precio: 160, stock: 0, activo: true, bajo_pedido: true, categoria: "Vitaminas" },
  { id: 3, nombre: "Effaclar Gel", precio: 538, stock: 0, activo: true, bajo_pedido: true, categoria: "Cuidado personal", subcategoria: "Dermatología" },
];

function renderVitrina(items = productos) {
  return render(
    <VitrinaConseguir
      productos={items}
      renderProducto={(p) => <div>{p.nombre}</div>}
    />
  );
}

it("explica que se ordena sin publicar precio", () => {
  renderVitrina();
  expect(screen.getByText(/Ordenar/)).toBeInTheDocument();
  expect(screen.queryByText(/Encargar/)).not.toBeInTheDocument();
  expect(screen.getByText(/todavía no publicamos el precio/i)).toBeInTheDocument();
});

it("tiene bandas propias de Vitaminas y Dispositivos médicos, no las tira a Otros encargos", () => {
  renderVitrina();
  expect(screen.getByRole("heading", { name: "Vitaminas" })).toBeInTheDocument();
  expect(screen.getByRole("heading", { name: "Dispositivos médicos" })).toBeInTheDocument();
  expect(screen.getByRole("heading", { name: "Dermatología" })).toBeInTheDocument();
  expect(screen.queryByRole("heading", { name: "Otros encargos" })).not.toBeInTheDocument();
  expect(screen.getByRole("tab", { name: /Dispositivos médicos/ })).toBeInTheDocument();
  expect(screen.getByRole("tab", { name: /Vitaminas/ })).toBeInTheDocument();
  expect(screen.getByText("Omron Monitor de Presión")).toBeInTheDocument();
  expect(screen.getByText("Redoxon Vitamina C")).toBeInTheDocument();
});

it("Otros encargos solo aparece si hay un bajo pedido sin rubro", () => {
  renderVitrina([
    ...productos,
    { id: 9, nombre: "Producto suelto", precio: 50, stock: 0, activo: true, bajo_pedido: true, categoria: "Otro" },
  ]);
  expect(screen.getByRole("heading", { name: "Otros encargos" })).toBeInTheDocument();
  expect(screen.getByText("Producto suelto")).toBeInTheDocument();
});

function prod(id, extras = {}) {
  return {
    id,
    nombre: `Producto ${String(id).padStart(2, "0")}`,
    precio: 100,
    stock: 0,
    activo: true,
    bajo_pedido: true,
    categoria: "Dispositivo médico",
    subcategoria: "Insumos",
    ...extras,
  };
}

test("rubro Dispositivos y tope de banda en Todos", () => {
  const muchos = Array.from({ length: 20 }, (_, i) => prod(i + 1));
  const seen = [];
  render(
    <VitrinaConseguir
      productos={muchos}
      renderProducto={(p) => {
        seen.push(p.id);
        return <div key={p.id}>{p.nombre}</div>;
      }}
    />,
  );
  expect(screen.getByRole("tab", { name: /Dispositivos/i })).toBeInTheDocument();
  expect(seen.length).toBe(STRIP_TOPE_CONSEGUIR);

  fireEvent.click(screen.getByRole("tab", { name: /Dispositivos/i }));
  expect(screen.getAllByText(/Producto /).length).toBe(20);
});
