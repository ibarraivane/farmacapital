import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import EncabezadoV2 from "./EncabezadoV2";

test("franja de horario sin el texto Farmacia mexicana", () => {
  render(<EncabezadoV2 setPage={() => {}} cart={[]} />);
  expect(screen.getByText(/Abierto hoy 8:00–22:30/)).toBeInTheDocument();
  expect(screen.queryByText(/Farmacia mexicana/i)).not.toBeInTheDocument();
  expect(screen.getByLabelText("Buscar")).toBeInTheDocument();
  expect(screen.getByLabelText("Carrito")).toBeInTheDocument();
});

test("el contador del carrito es verde y el logo abre inicio", () => {
  const setPage = jest.fn();
  const { container } = render(
    <EncabezadoV2 setPage={setPage} cart={[{ qty: 2 }, { qty: 1 }]} />
  );
  expect(container.querySelector(".badge")).toHaveTextContent("3");
  fireEvent.click(screen.getByLabelText("Inicio FarmaCapital"));
  expect(setPage).toHaveBeenCalledWith("home");
});

test("el buscador reusa las sugerencias del catálogo", () => {
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
  fireEvent.focus(screen.getByLabelText("Buscar"));
  expect(screen.getByRole("option", { name: /Omeprazol/ })).toBeInTheDocument();
  fireEvent.click(screen.getByRole("option", { name: /Omeprazol/ }));
  expect(setProdDetalle).toHaveBeenCalled();
  expect(setPage).toHaveBeenCalledWith("detalle", { productId: 11 });
});
