import { render, screen, fireEvent } from "@testing-library/react";
import VitrinaConseguir from "./VitrinaConseguir";
import { STRIP_TOPE_CONSEGUIR } from "../../lib/bajoPedido";

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
