import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import EncabezadoV2 from "./EncabezadoV2";

test("franja, menú y buscador del prototipo ChatGPT", () => {
  render(<EncabezadoV2 setPage={() => {}} cart={[]} />);
  expect(screen.getByText("Farmacia y consultorio · Ciudad de México")).toBeInTheDocument();
  expect(screen.getByText("Atención en sucursal · 8:00–22:30")).toBeInTheDocument();
  expect(screen.queryByText(/Desde 2016/i)).not.toBeInTheDocument();
  expect(screen.queryByText(/Chinampac/i)).not.toBeInTheDocument();
  expect(screen.getByLabelText("Buscar producto, sustancia o marca")).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Buscar" })).toBeInTheDocument();
  expect(screen.getByLabelText("Ver carrito")).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Medicamentos" })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Dermocosmética" })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Nutrición" })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Cotizar especializado" })).toHaveClass("fc-nav-quote");
  expect(screen.getByRole("button", { name: /Sucursal CDMX · Ver ubicación/ })).toBeInTheDocument();
});

test("el contador del carrito y el logo abren las pantallas", () => {
  const setPage = jest.fn();
  const { container } = render(
    <EncabezadoV2 setPage={setPage} cart={[{ qty: 2 }, { qty: 1 }]} />
  );
  expect(container.querySelector(".fc-cartnum")).toHaveTextContent("3");
  fireEvent.click(screen.getByLabelText("Inicio FarmaCapital"));
  expect(setPage).toHaveBeenCalledWith("home");
  fireEvent.click(screen.getByLabelText("Ver carrito"));
  expect(setPage).toHaveBeenCalledWith("carrito");
});

test("el buscador reusa las sugerencias del catálogo", () => {
  window.scrollTo = jest.fn();
  const setPage = jest.fn();
  const setProdDetalle = jest.fn();
  render(
    <EncabezadoV2
      setPage={setPage}
      setBusqHero={() => {}}
      setProdDetalle={setProdDetalle}
      busqHero="omepra"
      productos={[{ id: 11, nombre: "Omeprazol 20 mg", stock: 4, activo: true }]}
    />
  );
  fireEvent.focus(screen.getByLabelText("Buscar producto, sustancia o marca"));
  expect(screen.getByRole("option", { name: /Omeprazol/ })).toBeInTheDocument();
  fireEvent.click(screen.getByRole("option", { name: /Omeprazol/ }));
  expect(setProdDetalle).toHaveBeenCalled();
  expect(setPage).toHaveBeenCalledWith("detalle", { productId: 11 });
});

test("Cotizar especializado abre conseguir hasta la fase C1", () => {
  const setPage = jest.fn();
  render(<EncabezadoV2 setPage={setPage} cart={[]} />);
  fireEvent.click(screen.getByRole("button", { name: "Cotizar especializado" }));
  expect(setPage).toHaveBeenCalledWith("conseguir");
});
