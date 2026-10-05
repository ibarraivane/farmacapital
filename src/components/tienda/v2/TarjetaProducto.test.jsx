import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import TarjetaProducto from "./TarjetaProducto";
import { TiendaPlaceholderCtx } from "../tiendaPlaceholder";

const mockUrlsGaleria = jest.fn(() => []);

jest.mock("../../../hooks/useProductoImagenes", () => {
  const actual = jest.requireActual("../../../hooks/useProductoImagenes");
  return {
    ...actual,
    useUrlsImagenesProducto: () => (id) => mockUrlsGaleria(id),
  };
});

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

beforeEach(() => {
  mockUrlsGaleria.mockReset();
  mockUrlsGaleria.mockReturnValue([]);
});

test("sin foto en inventario no pinta la galería con marca de agua", () => {
  mockUrlsGaleria.mockReturnValue([
    "https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7502226295954/1.webp",
  ]);
  const { container } = render(
    <TarjetaProducto
      prod={{
        id: 915,
        nombre: "Dexketoprofeno 10 Tab 25 Mg",
        marca: "Alpharma",
        presentacion: "Caja con 10 tabletas",
        precio: 120,
        stock: 2,
        imagen_url: null,
        imagen_mobile_url: null,
      }}
      onClick={() => {}}
    />
  );
  expect(screen.getByText("Dexketoprofeno 10 Tab 25 Mg")).toBeInTheDocument();
  expect(container.querySelector("img")).toBeNull();
});

test("Allegra con enlace de Del Ahorro muestra la foto propia de la galería", () => {
  const propia = "https://www.farmacapital.mx/catalogo-propia/allegra-suspension-150ml.jpg";
  mockUrlsGaleria.mockReturnValue([propia]);
  const { container } = render(
    <TarjetaProducto
      prod={{
        id: 1728,
        nombre: "Allegra suspensión 6 mg/mL 150 mL",
        marca: "Allegra",
        presentacion: "Frasco 150 mL",
        precio: 189,
        stock: 1,
        imagen_url: "https://production-media.fahorro.com/media/catalog/product/7/5/7501165006171.jpg",
        imagen_mobile_url: "https://production-media.fahorro.com/media/catalog/product/7/5/7501165006171.jpg",
      }}
      onClick={() => {}}
    />
  );
  const src = container.querySelector("img")?.getAttribute("src") || "";
  expect(src).toBe(propia);
  expect(src).not.toContain("fahorro.com");
});

test("la foto guardada en inventario reemplaza la galería vieja", () => {
  const guardada = "https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/fc-28833707-1200x1200-1791128503974.webp?v=1791128504982";
  mockUrlsGaleria.mockReturnValue([
    "https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7501342802954/1.webp",
  ]);
  const { container } = render(
    <TarjetaProducto
      prod={{
        id: 1184,
        nombre: "Beadvance Levofloxacino 500 mg Caja con 7 tabletas",
        precio: 90,
        stock: 2,
        imagen_url: guardada,
        imagen_mobile_url: guardada,
      }}
      onClick={() => {}}
    />
  );
  const src = container.querySelector("img")?.getAttribute("src") || "";
  expect(src).toContain("fc-28833707-1200x1200-1791128503974.webp");
  expect(src).not.toContain("rappi/7501342802954");
});

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

test("sin foto de ficha muestra el mismo placeholder que al abrir el producto", () => {
  const ph = "https://cdn.example/placeholders/imagen-proximamente-v1.png";
  const { container } = render(
    <TiendaPlaceholderCtx.Provider value={ph}>
      <TarjetaProducto
        prod={{
          id: 18767,
          nombre: "100% Platinum Whey Chocolate Ice Cream",
          marca: "EAS",
          presentacion: "5 lb",
          precio: 0,
          stock: 0,
          bajo_pedido: true,
          imagen_url: null,
          imagen_mobile_url: null,
        }}
        onClick={() => {}}
      />
    </TiendaPlaceholderCtx.Provider>
  );
  const img = container.querySelector("img");
  expect(img?.getAttribute("src") || "").toContain("imagen-proximamente-v1.png");
  expect(img).toHaveAttribute("alt", "Imagen próximamente");
  expect(img).toHaveClass("fc-photo-ph");
});

test("una foto real no se cambia por el placeholder", () => {
  const propia = "https://www.farmacapital.mx/catalogo-propia/whey.jpg";
  const { container } = render(
    <TiendaPlaceholderCtx.Provider value="https://cdn.example/placeholders/imagen-proximamente-v1.png">
      <TarjetaProducto
        prod={{
          id: 8,
          nombre: "Con foto",
          precio: 40,
          stock: 2,
          imagen_url: propia,
          imagen_mobile_url: propia,
        }}
        onClick={() => {}}
      />
    </TiendaPlaceholderCtx.Provider>
  );
  const src = container.querySelector("img")?.getAttribute("src") || "";
  expect(src).toContain("catalogo-propia/whey.jpg");
  expect(src).not.toContain("imagen-proximamente");
});

test("si la foto real no carga, la tarjeta cae al placeholder", () => {
  const propia = "https://www.farmacapital.mx/catalogo-propia/rota.jpg";
  const { container } = render(
    <TiendaPlaceholderCtx.Provider value="https://cdn.example/placeholders/imagen-proximamente-v1.png">
      <TarjetaProducto
        prod={{
          id: 9,
          nombre: "Foto rota",
          precio: 40,
          stock: 2,
          imagen_url: propia,
        }}
        onClick={() => {}}
      />
    </TiendaPlaceholderCtx.Provider>
  );
  fireEvent.error(container.querySelector("img"));
  const src = container.querySelector("img")?.getAttribute("src") || "";
  expect(src).toContain("imagen-proximamente-v1.png");
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
