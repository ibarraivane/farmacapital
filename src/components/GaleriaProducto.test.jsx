import React from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import GaleriaProducto from "./GaleriaProducto";

const tres = ["http://x/1.webp", "http://x/2.webp", "http://x/3.webp"];

it("con una sola foto no pinta controles: se comporta como el <img> que reemplaza", () => {
  const { container } = render(<GaleriaProducto imagenes={["http://x/unica.webp"]} alt="Nido" />);
  expect(container.querySelector("img")).toHaveAttribute("src", "http://x/unica.webp");
  expect(screen.queryByLabelText("Foto siguiente")).not.toBeInTheDocument();
  expect(screen.queryByLabelText("Foto anterior")).not.toBeInTheDocument();
});

it("avanza y retrocede con las flechas, y da la vuelta al llegar al final", () => {
  const { container } = render(<GaleriaProducto imagenes={tres} alt="Nido" />);
  const img = () => container.querySelector("img").getAttribute("src");

  expect(img()).toBe(tres[0]);
  fireEvent.click(screen.getByLabelText("Foto siguiente"));
  expect(img()).toBe(tres[1]);
  fireEvent.click(screen.getByLabelText("Foto siguiente"));
  fireEvent.click(screen.getByLabelText("Foto siguiente"));
  expect(img()).toBe(tres[0]);
  fireEvent.click(screen.getByLabelText("Foto anterior"));
  expect(img()).toBe(tres[2]);
});

it("los puntos saltan directo a una foto y anuncian la posición", () => {
  const { container } = render(<GaleriaProducto imagenes={tres} alt="Nido" />);
  fireEvent.click(screen.getByLabelText("Ver foto 3 de 3"));
  expect(container.querySelector("img")).toHaveAttribute("src", tres[2]);
  expect(screen.getByText("Foto 3 de 3")).toBeInTheDocument();
});

it("vuelve a la primera foto cuando cambia el producto", () => {
  const { container, rerender } = render(<GaleriaProducto imagenes={tres} alt="Nido" />);
  fireEvent.click(screen.getByLabelText("Foto siguiente"));
  expect(container.querySelector("img")).toHaveAttribute("src", tres[1]);

  const otras = ["http://y/a.webp", "http://y/b.webp"];
  rerender(<GaleriaProducto imagenes={otras} alt="NAN" />);
  expect(container.querySelector("img")).toHaveAttribute("src", otras[0]);
});

it("la foto es pulsable solo cuando hay zoom, y las flechas quedan fuera de ese botón", () => {
  const abrirZoom = jest.fn();
  render(<GaleriaProducto imagenes={tres} alt="Nido" onImagenClick={abrirZoom} />);

  const foto = screen.getByLabelText("Ver foto de Nido");
  fireEvent.click(foto);
  expect(abrirZoom).toHaveBeenCalledTimes(1);
  // Un <button> dentro de otro <button> rompe el HTML y el foco por teclado.
  expect(foto.querySelector("button")).toBeNull();
});

it("con puntos flotantes no ocupa alto extra: la caja del POS los recortaría", () => {
  const { rerender, container } = render(<GaleriaProducto imagenes={tres} alt="Nido" />);
  const puntos = () => container.querySelector('[aria-current]').parentElement;
  expect(puntos().style.position).not.toBe("absolute");

  rerender(<GaleriaProducto imagenes={tres} alt="Nido" puntosFlotantes />);
  expect(puntos().style.position).toBe("absolute");
});

it("sin puntos deja las flechas y un contador que no tapa la foto", () => {
  const { container } = render(<GaleriaProducto imagenes={tres} alt="Nido" mostrarPuntos={false} />);
  expect(screen.queryByLabelText("Ver foto 2 de 3")).not.toBeInTheDocument();
  expect(screen.getByLabelText("Foto siguiente")).toBeInTheDocument();
  expect(container).toHaveTextContent("1/3");
  fireEvent.click(screen.getByLabelText("Foto siguiente"));
  expect(container).toHaveTextContent("2/3");
});

it("cae al ícono cuando la foto no carga, sin romper la galería", () => {
  const { container } = render(<GaleriaProducto imagenes={tres} alt="Nido" />);
  fireEvent.error(container.querySelector("img"));
  expect(container.querySelector("img")).toBeNull();
  expect(screen.getByLabelText("Foto siguiente")).toBeInTheDocument();
});
