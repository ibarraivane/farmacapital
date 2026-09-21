import React from "react";
import { render, screen } from "@testing-library/react";
import Acordeon from "./Acordeon";
import FichaTecnica from "./FichaTecnica";
import Pasos from "./Pasos";

test("acordeón y ficha técnica no se pintan sin datos", () => {
  const { container } = render(
    <>
      <Acordeon titulo="Vacío">{""}</Acordeon>
      <FichaTecnica filas={[{ clave: "Registro", valor: "  " }]} />
      <Pasos items={[{ titulo: "", texto: "" }]} />
    </>
  );
  expect(container).toBeEmptyDOMElement();
  expect(screen.queryByText("Vacío")).not.toBeInTheDocument();
});

test("acordeón con cuerpo sí se muestra", () => {
  render(<Acordeon titulo="¿Para qué sirve?" abierto>Baja la acidez</Acordeon>);
  expect(screen.getByText("¿Para qué sirve?")).toBeInTheDocument();
  expect(screen.getByText("Baja la acidez")).toBeInTheDocument();
});
