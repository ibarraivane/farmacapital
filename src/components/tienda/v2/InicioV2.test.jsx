import { render, screen } from "@testing-library/react";
import InicioV2, { productosEnSucursal, productosPorEncargo, esGenericoReal, esPatenteReal } from "./InicioV2";

const PRODUCTOS = [
  { id: 1, nombre: "Omeprazol 20 mg", precio: 89, stock: 12, categoria: "Gastro", imagen_url: "https://x/o.jpg" },
  { id: 2, nombre: "Amoxicilina 500 mg", precio: 93, stock: 4, categoria: "Antibiótico", requiere_receta: true },
  { id: 3, nombre: "Sensibio H2O", precio: 329, stock: 0, bajo_pedido: true, marca: "Bioderma", imagen_url: "https://x/b.jpg" },
  { id: 4, nombre: "Agotado sin encargo", precio: 50, stock: 0 },
];

test("separa lo que hay en sucursal de lo que es por encargo", () => {
  const sucursal = productosEnSucursal(PRODUCTOS).map((p) => p.id);
  const encargo = productosPorEncargo(PRODUCTOS).map((p) => p.id);
  expect(sucursal).toEqual([1, 2]);
  expect(encargo).toEqual([3]);
});

test("el inicio muestra los bloques del diseño de ChatGPT", () => {
  render(<InicioV2 productos={PRODUCTOS} setPage={() => {}} setProdDetalle={() => {}} precioConsulta={80} />);
  expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent("Tu receta.");
  expect(screen.getByText("¿Qué estás buscando?")).toBeInTheDocument();
  expect(screen.getByText(/Te lo cotizamos/)).toBeInTheDocument();
  expect(screen.getByText("Listos para recoger hoy.")).toBeInTheDocument();
  expect(screen.getByText("Tu cuidado, a tu manera.")).toBeInTheDocument();
  expect(screen.getByText(/Consulta \$80/)).toBeInTheDocument();
});

test("sin catálogo no inventa secciones vacías", () => {
  render(<InicioV2 productos={[]} setPage={() => {}} setProdDetalle={() => {}} />);
  expect(screen.queryByText("Listos para recoger hoy.")).not.toBeInTheDocument();
  expect(screen.queryByText("Tu cuidado, a tu manera.")).not.toBeInTheDocument();
  expect(screen.getByText("¿Qué estás buscando?")).toBeInTheDocument();
});

describe("qué foto entra al carrusel de genéricos y de patente", () => {
  test("genérico: laboratorio conocido y el nombre es la sustancia", () => {
    expect(esGenericoReal({ marca: "Maver", categoria: "Gastro", principio_activo: "Esomeprazol", nombre: "Esomeprazol 28 Tab 40 Mg" })).toBe(true);
    expect(esGenericoReal({ marca: "Cloxan", categoria: "Respiratorio", principio_activo: "Ambroxol", nombre: "Cloxan ambroxol 30 mg" })).toBe(true);
  });

  test("genérico: el laboratorio no basta si el nombre es una marca de fantasía", () => {
    expect(esGenericoReal({ marca: "Maver", categoria: "Alergia", principio_activo: "Loratadina", nombre: "Laritol 10 mg" })).toBe(false);
  });

  test("genérico: nunca fuera de una categoría de medicamento", () => {
    expect(esGenericoReal({ marca: "Maver", categoria: "Cuidado personal", principio_activo: "Ibuprofeno", nombre: "Ibuprofeno gel" })).toBe(false);
  });

  test("patente: marca reconocible en categoría de medicamento", () => {
    expect(esPatenteReal({ marca: "Tylenol", categoria: "Analgésico" })).toBe(true);
    expect(esPatenteReal({ marca: "BAYER", categoria: "Antiinflamatorio" })).toBe(true);
    expect(esPatenteReal({ marca: "Genérico", categoria: "Analgésico" })).toBe(false);
  });

  test("con menos de 2 fotos reales, el carrusel usa el ícono, no una vitrina a medias", () => {
    const soloUno = [
      { id: 1, activo: true, marca: "Maver", categoria: "Gastro", principio_activo: "Esomeprazol", nombre: "Esomeprazol 40 Mg", imagen_url: "https://x/e.jpg" },
    ];
    const { container } = render(<InicioV2 productos={soloUno} setPage={() => {}} setProdDetalle={() => {}} />);
    // una sola foto de "Maver" no debe aparecer como si fuera la muestra completa de genéricos
    expect(screen.queryByText("Maver")).not.toBeInTheDocument();
    expect(container.querySelector(".fc-studio-icono")).toBeInTheDocument();
  });
});
