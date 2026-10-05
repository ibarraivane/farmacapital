import { render, screen, within, fireEvent } from "@testing-library/react";
import InicioV2, { productosEnSucursal, productosPorEncargo, esGenericoReal, esPatenteReal } from "./InicioV2";
import { TiendaPlaceholderCtx } from "../tiendaPlaceholder";

const PRODUCTOS = [
  { id: 1, nombre: "Omeprazol 20 mg", precio: 89, stock: 12, categoria: "Gastro", vitrina_seccion: "Medicamentos", imagen_url: "https://x/o.jpg" },
  { id: 2, nombre: "Amoxicilina 500 mg", precio: 93, stock: 4, categoria: "Antibiótico", vitrina_seccion: "Medicamentos", requiere_receta: true },
  { id: 3, nombre: "Sensibio H2O", precio: 329, stock: 0, bajo_pedido: true, marca: "Bioderma", vitrina_seccion: "Dermocosmética", imagen_url: "https://x/b.jpg" },
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
  expect(screen.getByRole("heading", { name: "Comprar por categoría" })).toBeInTheDocument();
  expect(screen.getByText(/Te lo cotizamos/)).toBeInTheDocument();
  expect(screen.getByText("Listos para recoger hoy.")).toBeInTheDocument();
  expect(screen.getByText("Tu cuidado, a tu manera.")).toBeInTheDocument();
  expect(screen.getByText(/Consulta \$80/)).toBeInTheDocument();
});

test("el encargo sin foto usa el placeholder de la ficha", () => {
  const ph = "https://cdn.example/placeholders/imagen-proximamente-v1.png";
  const { container } = render(
    <TiendaPlaceholderCtx.Provider value={ph}>
      <InicioV2
        productos={[{ id: 9, nombre: "Whey", marca: "EAS", presentacion: "5 lb", precio: 0, stock: 0, bajo_pedido: true, activo: true, imagen_url: "" }]}
        setPage={() => {}}
        setProdDetalle={() => {}}
      />
    </TiendaPlaceholderCtx.Provider>
  );
  const src = container.querySelector(".fc-encargo img")?.getAttribute("src") || "";
  expect(src).toContain("imagen-proximamente-v1.png");
  expect(container.querySelector(".fc-encargo img")).toHaveAttribute("alt", "Imagen próximamente");
});

test("sin catálogo no inventa secciones vacías", () => {
  render(<InicioV2 productos={[]} setPage={() => {}} setProdDetalle={() => {}} />);
  expect(screen.queryByText("Listos para recoger hoy.")).not.toBeInTheDocument();
  expect(screen.queryByText("Tu cuidado, a tu manera.")).not.toBeInTheDocument();
  expect(screen.getByRole("heading", { name: "Comprar por categoría" })).toBeInTheDocument();
});

test("«Comprar por categoría» ofrece las seis secciones mientras no hay catálogo", () => {
  render(<InicioV2 productos={[]} setPage={() => {}} setProdDetalle={() => {}} />);
  const mosaico = screen.getByRole("heading", { name: "Comprar por categoría" }).closest("section");
  expect(within(mosaico).getAllByRole("button")).toHaveLength(6);
});

test("con catálogo, el mosaico solo muestra secciones con productos y abre esa vitrina", () => {
  const setPage = jest.fn();
  render(<InicioV2 productos={PRODUCTOS} setPage={setPage} setProdDetalle={() => {}} />);
  const mosaico = screen.getByRole("heading", { name: "Comprar por categoría" }).closest("section");
  const nombres = within(mosaico).getAllByRole("button").map((b) => b.textContent.replace(/\s+/g, " ").trim());
  expect(nombres).toEqual(["Dermocosmética", "Medicamentos"]);
  expect(nombres).not.toContain("Nutrición deportiva");
  fireEvent.click(within(mosaico).getByRole("button", { name: "Medicamentos" }));
  expect(setPage).toHaveBeenCalledWith("catalogo", expect.objectContaining({ seccion: "Medicamentos" }));
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
