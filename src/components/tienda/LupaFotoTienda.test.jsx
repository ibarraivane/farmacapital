import React, { useState } from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import GaleriaProducto from "../GaleriaProducto";
import LupaFotoTienda from "./LupaFotoTienda";

const tres = ["http://x/1.webp", "http://x/2.webp", "http://x/3.webp"];

it("cerrada no deja el diálogo en la página", () => {
  render(<LupaFotoTienda open={false} onClose={() => {}} imagenes={tres} alt="Nido" />);
  expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
});

it("abre la foto que se estaba viendo y la cierra con la X, afuera o Escape", () => {
  const onClose = jest.fn();
  render(
    <LupaFotoTienda open onClose={onClose} imagenes={tres} alt="Nido" indice={1} />,
  );
  expect(screen.getByRole("dialog")).toHaveAttribute("aria-label", "Foto ampliada de Nido");
  expect(screen.getByAltText("Nido")).toHaveAttribute("src", tres[1]);

  fireEvent.click(screen.getByRole("dialog"));
  expect(onClose).not.toHaveBeenCalled();

  fireEvent.click(screen.getByRole("presentation"));
  expect(onClose).toHaveBeenCalledTimes(1);

  fireEvent.click(screen.getByLabelText("Cerrar"));
  expect(onClose).toHaveBeenCalledTimes(2);

  fireEvent.keyDown(document, { key: "Escape" });
  expect(onClose).toHaveBeenCalledTimes(3);
});

it("las flechas del teclado cambian la foto cuando el foco no está en la galería", () => {
  const onIndiceChange = jest.fn();
  render(
    <LupaFotoTienda open onClose={() => {}} imagenes={tres} alt="Nido" indice={0} onIndiceChange={onIndiceChange} />,
  );
  fireEvent.keyDown(screen.getByRole("dialog"), { key: "ArrowRight" });
  expect(onIndiceChange).toHaveBeenCalledWith(1);
  expect(screen.getByAltText("Nido")).toHaveAttribute("src", tres[1]);
});

function FichaConLupa() {
  const [abierta, setAbierta] = useState(false);
  const [indice, setIndice] = useState(0);
  return (
    <div>
      <GaleriaProducto
        imagenes={tres}
        alt="Nido"
        lupa
        onImagenClick={() => setAbierta(true)}
        indice={indice}
        onIndiceChange={setIndice}
      />
      <LupaFotoTienda
        open={abierta}
        onClose={() => setAbierta(false)}
        imagenes={tres}
        alt="Nido"
        indice={indice}
        onIndiceChange={setIndice}
      />
    </div>
  );
}

it("la miniatura y la foto grande se quedan en la misma foto", () => {
  render(<FichaConLupa />);
  fireEvent.click(screen.getByLabelText("Foto siguiente"));
  fireEvent.click(screen.getByLabelText("Ver foto de Nido"));
  const dialog = screen.getByRole("dialog");
  expect(dialog.querySelector("img")).toHaveAttribute("src", tres[1]);
  fireEvent.keyDown(dialog, { key: "ArrowRight" });
  expect(dialog.querySelector("img")).toHaveAttribute("src", tres[2]);
  fireEvent.click(screen.getByLabelText("Cerrar"));
  expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  expect(document.querySelector("[data-galeria-fotos] img")).toHaveAttribute("src", tres[2]);
});
