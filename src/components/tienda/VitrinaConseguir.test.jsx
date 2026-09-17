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

test("mientras carga no muestra el formulario", () => {
  render(
    <VitrinaConseguir
      productos={[]}
      loading
      stack
      seccion="dermatologia"
      setPage={jest.fn()}
      renderProducto={(p) => <div key={p.id}>{p.nombre}</div>}
      formulario={<div>FORMULARIO</div>}
    />
  );
  expect(screen.getByText(/Cargando productos/i)).toBeInTheDocument();
  expect(screen.queryByText("FORMULARIO")).not.toBeInTheDocument();
  expect(screen.queryByText(/No hay piezas cargadas/i)).not.toBeInTheDocument();
  expect(screen.queryByText(/En este rubro no hay piezas/i)).not.toBeInTheDocument();
});

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
  expect(screen.getByText(/No hay piezas cargadas/i)).toBeInTheDocument();
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
  expect(screen.queryByRole("heading", { name: "Nutrición deportiva" })).not.toBeInTheDocument();
  expect(screen.queryByText(/Effaclar|Pharmaton|Cicaplast/i)).not.toBeInTheDocument();
  expect(screen.getByText(/Redoxon/)).toBeInTheDocument();
});

test("vitaminas vacía igual muestra chips de rubro", () => {
  render(
    <VitrinaConseguir
      productos={[]}
      loading={false}
      stack
      seccion="nutricion"
      setPage={jest.fn()}
      renderProducto={(p) => <div key={p.id}>{p.nombre}</div>}
    />
  );
  expect(screen.getByRole("tab", { name: /Todos/i })).toBeInTheDocument();
  expect(screen.getByRole("tab", { name: /Nutrición deportiva/i })).toBeInTheDocument();
});

test("fase 2: anaquel de vitaminas entra a la banda", () => {
  const anaquelVit = { id: 3, nombre: "Redoxon anaquel", marca: "Redoxon", activo: true, bajo_pedido: false, stock: 4, categoria: "Vitaminas" };
  render(
    <VitrinaConseguir
      productos={[anaquelVit]}
      loading={false}
      stack={false}
      seccion="nutricion"
      rubro=""
      setPage={jest.fn()}
      renderProducto={(p) => <div key={p.id}>{p.nombre}</div>}
    />
  );
  expect(screen.getByText("Redoxon anaquel")).toBeInTheDocument();
  expect(screen.getByRole("heading", { name: "Vitaminas" })).toBeInTheDocument();
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
  expect(screen.getAllByText(/tarjeta de crédito/i).length).toBeGreaterThan(0);
});
