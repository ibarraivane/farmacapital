import React from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import TableroEquivalentes from "./TableroEquivalentes";
import { grupoOpcionesRelacionadas } from "../../../utils/equivalentesPos";

const treda = { id: 1, nombre: "Treda C/20", marca: "Treda", tipo: "marca", principio_activo: "Neomicina + Caolin + Pectina", presentacion: "C/20", forma_farmaceutica: "Tabletas", concentracion: "129/280/30 mg", precio: 189, activo: true };
const nineka = { id: 2, nombre: "Nineka C/20", marca: "Nineka", tipo: "generico", principio_activo: "Neomicina + Caolin + Pectina", presentacion: "C/20", forma_farmaceutica: "Tabletas", concentracion: "129/280/30 mg", precio: 61, activo: true, imagen_url: "http://x/nineka.jpg" };
const suspension = { id: 3, nombre: "Nineka suspensión", marca: "Nineka", principio_activo: "Neomicina + Caolin + Pectina", presentacion: "75 mL", forma_farmaceutica: "Suspensión", concentracion: "500/36/35 mg/5 mL", precio: 38, activo: true };
const grupo = grupoOpcionesRelacionadas([treda, nineka, suspension], treda, "treda");
const stockLleno = () => ({ agotado: false, etiqueta: "3 disp." });

it("agrupa por marca: Nineka es una tarjeta, no dos", () => {
  render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} onAdd={() => {}} estadoStock={stockLleno} />);
  expect(screen.getAllByRole("article")).toHaveLength(2);
  expect(screen.getAllByText("Treda")).toHaveLength(1);
  expect(screen.getByText("Nineka")).toBeInTheDocument();
  expect(screen.getByText("2 presentaciones")).toBeInTheDocument();
});

it("pone la patente antes que los genéricos", () => {
  render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} onAdd={() => {}} estadoStock={stockLleno} />);
  const marcas = screen.getAllByRole("article").map((a) => a.textContent);
  expect(marcas[0]).toContain("Treda");
  expect(marcas[0]).toContain("Patente");
  expect(marcas[1]).toContain("Nineka");
  expect(marcas[1]).toContain("Genérico");
});

it("mete las presentaciones como cajitas dentro de la tarjeta de su marca", () => {
  render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} onAdd={() => {}} estadoStock={stockLleno} />);
  const nk = screen.getAllByRole("article")[1];
  expect(nk).toHaveTextContent("500/36/35 mg/5 mL · 75 mL · Suspensión");
  expect(nk).toHaveTextContent("129/280/30 mg · C/20 · Tabletas");
  expect(nk).toHaveTextContent("$38.00");
  expect(nk).toHaveTextContent("$61.00");
});

it("tocar una presentación abre la ficha de ESA presentación", () => {
  const onSelect = jest.fn();
  render(<TableroEquivalentes grupo={grupo} onSelect={onSelect} onAdd={() => {}} estadoStock={stockLleno} />);
  fireEvent.click(screen.getByText("500/36/35 mg/5 mL · 75 mL · Suspensión"));
  expect(onSelect).toHaveBeenCalledWith(suspension);
});

it("avisa que cambia la dosis sin tapar el stock", () => {
  render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} onAdd={() => {}} estadoStock={stockLleno} />);
  const cajita = screen.getByText("500/36/35 mg/5 mL · 75 mL · Suspensión").closest("button");
  expect(cajita).toHaveTextContent("Otra dosis o forma");
  expect(cajita).toHaveTextContent("3 disp.");
});

it("la marca de una sola presentación trae su botón Agregar", () => {
  const onAdd = jest.fn();
  render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} onAdd={onAdd} estadoStock={stockLleno} />);
  const agregar = screen.getAllByRole("button", { name: "Agregar" });
  expect(agregar).toHaveLength(1);
  fireEvent.click(agregar[0]);
  expect(onAdd).toHaveBeenCalledWith(treda);
});

it("sin foto propia pone la marca en letras y no inventa otra imagen", () => {
  const { container } = render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} onAdd={() => {}} estadoStock={stockLleno} />);
  expect(container.querySelectorAll("img")).toHaveLength(1);
  expect(screen.getAllByRole("article")[0]).toHaveTextContent("Treda");
});

it("no inventa clasificación cuando ninguna presentación declara tipo", () => {
  const sinTipo = { ...suspension, id: 9, marca: "Anónima" };
  const g = grupoOpcionesRelacionadas([treda, sinTipo], treda, "treda");
  render(<TableroEquivalentes grupo={g} onSelect={() => {}} onAdd={() => {}} estadoStock={stockLleno} />);
  const anon = screen.getAllByRole("article").find((a) => a.textContent.includes("Anónima"));
  expect(anon).not.toHaveTextContent("Patente");
  expect(anon).not.toHaveTextContent("Genérico");
});

it("sin grupo no pinta nada", () => {
  const { container } = render(<TableroEquivalentes grupo={null} onSelect={() => {}} onAdd={() => {}} />);
  expect(container).toBeEmptyDOMElement();
});
