import { render, screen } from "@testing-library/react";
import VitrinaConseguir from "./VitrinaConseguir";

const derma = {
  id: 1,
  nombre: "Cicaplast",
  marca: "La Roche-Posay",
  activo: true,
  bajo_pedido: true,
  categoria: "Cuidado personal",
  subcategoria: "Dermatología",
};

test("sección vacía oculta la cuadrícula y muestra el formulario arriba", () => {
  render(
    <VitrinaConseguir
      productos={[]}
      loading={false}
      stack
      seccion="dermatologia"
      setPage={jest.fn()}
      renderProducto={(p) => <div key={p.id}>{p.nombre}</div>}
      formulario={<div>FORMULARIO</div>}
    />
  );
  expect(screen.getByText(/Aún no hay productos en esta página/i)).toBeInTheDocument();
  expect(screen.getByText("FORMULARIO")).toBeInTheDocument();
  expect(screen.queryByText("Cicaplast")).not.toBeInTheDocument();
});

test("banda en 0 no se muestra; copy no inventa marcas", () => {
  const vit = { id: 2, nombre: "Vitamina C", marca: "Redoxon", activo: true, bajo_pedido: true, categoria: "Vitaminas" };
  render(
    <VitrinaConseguir
      productos={[derma, vit]}
      loading={false}
      stack={false}
      seccion="nutricion"
      rubro=""
      setPage={jest.fn()}
      renderProducto={(p) => <div key={p.id}>{p.nombre}</div>}
    />
  );
  expect(screen.getByRole("heading", { name: "Vitaminas" })).toBeInTheDocument();
  expect(screen.queryByRole("heading", { name: "Proteína" })).not.toBeInTheDocument();
  expect(screen.queryByText(/Effaclar|Pharmaton|Cicaplast/i)).not.toBeInTheDocument();
  expect(screen.getByText(/Redoxon/)).toBeInTheDocument();
});

test("dermocosmética usa marcas del catálogo", () => {
  render(
    <VitrinaConseguir
      productos={[derma]}
      loading={false}
      stack
      seccion="dermatologia"
      setPage={jest.fn()}
      renderProducto={(p) => <div key={p.id}>{p.nombre}</div>}
    />
  );
  expect(screen.getByRole("heading", { name: "Dermocosmética" })).toBeInTheDocument();
  expect(screen.getByText(/La Roche-Posay/)).toBeInTheDocument();
  expect(screen.getByText(/tarjeta de crédito/i)).toBeInTheDocument();
});
