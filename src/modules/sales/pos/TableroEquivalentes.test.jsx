import React from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import TableroEquivalentes from "./TableroEquivalentes";
import { grupoOpcionesRelacionadas } from "../../../utils/equivalentesPos";

const treda = { id: 1, nombre: "Treda C/20", marca: "Treda", tipo: "marca", principio_activo: "Neomicina + Caolin + Pectina", presentacion: "C/20", forma_farmaceutica: "Tabletas", concentracion: "129/280/30 mg", precio: 189, activo: true };
const nineka = { id: 2, nombre: "Nineka C/20", marca: "Nineka", tipo: "generico", principio_activo: "Neomicina + Caolin + Pectina", presentacion: "C/20", forma_farmaceutica: "Tabletas", concentracion: "129/280/30 mg", precio: 61, activo: true, imagen_url: "http://x/nineka.jpg" };
const suspension = { id: 3, nombre: "Nineka suspensión", marca: "Nineka", principio_activo: "Neomicina + Caolin + Pectina", presentacion: "75 mL", forma_farmaceutica: "Suspensión", concentracion: "500/36/35 mg/5 mL", precio: 38, activo: true };
const grupo = grupoOpcionesRelacionadas([treda, nineka, suspension], treda, "treda");

it("pinta un SKU por tarjeta, su foto propia y el respaldo sin inventar otra", () => {
  const { container } = render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} onAdd={() => {}} estadoStock={() => ({ agotado: false, etiqueta: "3 disp." })} />);
  expect(screen.getAllByRole("article")).toHaveLength(3);
  expect(container.querySelectorAll("img")).toHaveLength(1);
  expect(screen.getAllByText("Treda").length).toBeGreaterThan(0);
  expect(screen.getAllByText("3 disp.")).toHaveLength(3);
});

it("separa la suspensión como Otras presentaciones", () => {
  render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} onAdd={() => {}} />);
  expect(screen.getByText("3 opciones con Neomicina + Caolín + Pectina")).toBeInTheDocument();
  expect(screen.getByText("Misma presentación")).toBeInTheDocument();
  expect(screen.getByText("Otras presentaciones")).toBeInTheDocument();
  expect(screen.getByText(/cambia forma, vía o concentración/i)).toBeInTheDocument();
});

it("abre ficha al tocar tarjeta y usa el callback de carrito al agregar", () => {
  const onSelect = jest.fn();
  const onAdd = jest.fn();
  render(<TableroEquivalentes grupo={grupo} onSelect={onSelect} onAdd={onAdd} estadoStock={() => ({ agotado: false, etiqueta: "2 disp." })} />);
  fireEvent.click(screen.getByRole("button", { name: /ver ficha de treda/i }));
  expect(onSelect).toHaveBeenCalledWith(treda);
  fireEvent.click(screen.getAllByRole("button", { name: "Agregar" })[0]);
  expect(onAdd).toHaveBeenCalledWith(treda);
});

it("no muestra clasificación falsa cuando falta tipo", () => {
  render(<TableroEquivalentes grupo={grupo} onSelect={() => {}} onAdd={() => {}} />);
  expect(screen.getByText("Marca")).toBeInTheDocument();
  expect(screen.getByText("Genérico")).toBeInTheDocument();
  expect(screen.getByText("Nineka Suspensión")).toBeInTheDocument();
});

it("cada tarjeta identifica sus activos sin inferirlos", () => {
  const sinActivos = { ...suspension, id: 4, nombre: "Producto sin activos", marca: "", presentacion: "", forma_farmaceutica: "", principio_activo: "", denominacion_generica: "" };
  const grupoConHueco = { ...grupo, total: 4, otrasPresentaciones: [...grupo.otrasPresentaciones, sinActivos] };
  render(<TableroEquivalentes grupo={grupoConHueco} onSelect={() => {}} onAdd={() => {}} />);
  expect(screen.getAllByText("Activos: Neomicina + Caolín + Pectina")).toHaveLength(3);
  expect(screen.getAllByText("Producto Sin Activos")).toHaveLength(2);
});

it("sin grupo no pinta nada", () => {
  const { container } = render(<TableroEquivalentes grupo={null} onSelect={() => {}} onAdd={() => {}} />);
  expect(container).toBeEmptyDOMElement();
});
