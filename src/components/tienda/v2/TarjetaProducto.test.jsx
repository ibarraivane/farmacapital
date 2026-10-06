import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import TarjetaProducto from "./TarjetaProducto";

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
  expect(screen.getByRole("link", { name: "Omeprazol 20 mg" })).toHaveAttribute("href", "/producto?id=7");
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
  fireEvent.click(screen.getByText("Consultar →"));
  expect(onClick).toHaveBeenCalled();
});

test("producto listo para vender tiene + Agregar", () => {
  const onAgregar = jest.fn(() => true);
  render(<TarjetaProducto prod={omeprazol} onClick={() => {}} onAgregar={onAgregar} />);
  fireEvent.click(screen.getByRole("button", { name: "+ Agregar" }));
  expect(onAgregar).toHaveBeenCalled();
  expect(screen.getByRole("button", { name: "✓ Agregado" })).toBeInTheDocument();
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
