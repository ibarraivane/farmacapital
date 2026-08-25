import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import TableroEquivalentes from "./TableroEquivalentes";
import { agruparOpcionesEquivalentes } from "../../../utils/equivalentesPos";

const treda = { id: 1, nombre: "Treda antidiarreico C/20", marca: "Treda", tipo: "marca", principio_activo: "Neomicina + Caolin + Pectina", presentacion: "C/20", forma_farmaceutica: "Cápsulas", precio: 189, activo: true };
const tredaJarabe = { id: 5, nombre: "Treda jarabe", marca: "Treda", tipo: "marca", principio_activo: "Neomicina + Caolin + Pectina", presentacion: "Frasco 120 mL", precio: 145, activo: true };
const kpec = { id: 2, nombre: "Nineka suspensión", marca: "K-PEC", tipo: "generico", principio_activo: "Neomicina + Caolin + Pectina", presentacion: "Frasco 100 mL", precio: 38, activo: true, imagen_url: "http://x/1.jpg" };
const catalogo = [treda, tredaJarabe, kpec];
const grupo = agruparOpcionesEquivalentes(catalogo, kpec);

it("muestra la patente y el genérico con su etiqueta", () => {
  render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} />);
  expect(screen.getByText("PATENTE")).toBeInTheDocument();
  expect(screen.getByText("GENÉRICO")).toBeInTheDocument();
  expect(screen.getByText("K-PEC")).toBeInTheDocument();
});

it("pone las presentaciones de una marca como cajitas dentro de su tarjeta", () => {
  render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} />);
  expect(screen.getByText("Frasco 120 mL")).toBeInTheDocument();
  expect(screen.getByText("C/20 · Cápsulas")).toBeInTheDocument();
  expect(screen.getByText("$189.00")).toBeInTheDocument();
  expect(screen.getByText("$145.00")).toBeInTheDocument();
});

it("cuando no hay foto enseña la marca en grande, una sola vez", () => {
  const { container } = render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} />);
  expect(screen.getByText("SIN FOTO")).toBeInTheDocument();
  expect(screen.getAllByText("Treda")).toHaveLength(1);
  expect(container.querySelectorAll("img")).toHaveLength(1);
});

it("al tocar una presentación la devuelve completa", () => {
  const onSelect = jest.fn();
  render(<TableroEquivalentes grupo={grupo} onSelect={onSelect} />);
  fireEvent.click(screen.getByText("Frasco 120 mL"));
  expect(onSelect).toHaveBeenCalledWith(tredaJarabe);
});

it("marca lo agotado sin esconderlo", () => {
  const estadoStock = (p) => (p.id === 1 ? { agotado: true, etiqueta: "Sin lotes" } : { agotado: false, etiqueta: "3 disp." });
  render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} estadoStock={estadoStock} />);
  expect(screen.getByText("Sin lotes")).toBeInTheDocument();
  expect(screen.getByText("C/20 · Cápsulas")).toBeInTheDocument();
});

it("resume cuántas son de patente", () => {
  render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} />);
  expect(screen.getByText("1 de patente · 1 genérico")).toBeInTheDocument();
});

it("sin grupo no pinta nada", () => {
  const { container } = render(<TableroEquivalentes grupo={null} onSelect={() => {}} />);
  expect(container).toBeEmptyDOMElement();
});
