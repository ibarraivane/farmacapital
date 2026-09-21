import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import BannersEstaSemana from "./BannersEstaSemana";

const productos = [
  { id: 1, nombre: "Vitamina C 1 g", presentacion: "30 tabletas", precio: 80, stock: 6, requiere_receta: false, imagen_url: "" },
  { id: 9, nombre: "Amoxicilina", precio: 90, stock: 4, requiere_receta: true },
];

test("muestra banner de producto con precio y oculta Rx", () => {
  const setPage = jest.fn();
  const setProdDetalle = jest.fn();
  render(
    <BannersEstaSemana
      banners={[
        { id: 1, plantilla: "producto", producto_ids: [1], activo: true, orden: 1, slot: "semana", ocultar_sin_stock: true },
        { id: 2, plantilla: "producto", producto_ids: [9], activo: true, orden: 2, slot: "semana" },
        { id: 3, plantilla: "imagen_propia", slot: "hero", activo: true, titulo: "Viejo" },
      ]}
      productos={productos}
      setPage={setPage}
      setProdDetalle={setProdDetalle}
    />
  );
  expect(screen.getByRole("heading", { name: "Esta semana" })).toBeInTheDocument();
  expect(screen.getByText("Vitamina C 1 g")).toBeInTheDocument();
  expect(screen.queryByText("Amoxicilina")).not.toBeInTheDocument();
  expect(screen.queryByText("Viejo")).not.toBeInTheDocument();
  fireEvent.click(screen.getByText("Vitamina C 1 g"));
  expect(setProdDetalle).toHaveBeenCalled();
  expect(setPage).toHaveBeenCalledWith("detalle", { productId: 1 });
});
