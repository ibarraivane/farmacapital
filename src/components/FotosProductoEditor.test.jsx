import React from "react";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import FotosProductoEditor from "./FotosProductoEditor";
import { gestionarFotoProducto } from "../lib/fotosProducto";
import { subirImagenStorage } from "../lib/subirImagenStorage";

jest.mock("../lib/fotosProducto", () => {
  const actual = jest.requireActual("../lib/fotosProducto");
  return { ...actual, gestionarFotoProducto: jest.fn() };
});
jest.mock("../lib/subirImagenStorage", () => ({ subirImagenStorage: jest.fn() }));
jest.mock("../ui", () => ({ showToast: jest.fn() }));
jest.mock("../hooks/useProductoImagenes", () => ({ invalidarImagenesProducto: jest.fn() }));
jest.mock("../utils/catalogoVivo", () => ({ avisarCatalogoCambio: jest.fn() }));
jest.mock("../supabase", () => ({ supabase: {} }));

const CONTAC = "https://cdn.ejemplo/contac-roja.jpg";
const LENTE_A = "https://cdn.ejemplo/bausch-a.jpg";
const LENTE_B = "https://cdn.ejemplo/bausch-b.jpg";

beforeEach(() => {
  sessionStorage.setItem("farmacapital_session_token", "tok");
  window.confirm = jest.fn(() => true);
  gestionarFotoProducto.mockReset();
  gestionarFotoProducto.mockResolvedValue({
    ok: true,
    imagen_url: CONTAC,
    imagenes: [
      { id: 1, url: LENTE_A, posicion: 1, es_principal: false },
      { id: 2, url: LENTE_B, posicion: 2, es_principal: false },
    ],
  });
});

it("muestra Quitar en cada foto y borra la que no es del producto", async () => {
  const onImagenUrl = jest.fn();
  render(
    <FotosProductoEditor
      productoId={41}
      imagenUrl={CONTAC}
      onImagenUrl={onImagenUrl}
      filenamePrefix="contac-ultra"
    />,
  );

  expect(await screen.findByRole("button", { name: "Subir varias fotos" })).toBeInTheDocument();
  const quitar = await screen.findAllByRole("button", { name: /Quitar foto/ });
  expect(quitar).toHaveLength(3);
  expect(screen.getByText("Principal")).toBeInTheDocument();

  fireEvent.click(quitar[1]);

  await waitFor(() => {
    expect(gestionarFotoProducto).toHaveBeenCalledWith(expect.objectContaining({
      action: "quitar",
      productoId: 41,
      url: LENTE_A,
    }));
  });
});

it("sube varias fotos de una sola vez y las agrega al producto", async () => {
  subirImagenStorage
    .mockResolvedValueOnce({ ok: true, publicUrl: "https://cdn.ejemplo/contac-dorso.jpg" })
    .mockResolvedValueOnce({ ok: true, publicUrl: "https://cdn.ejemplo/contac-lado.jpg" });

  render(
    <FotosProductoEditor
      productoId={41}
      imagenUrl={CONTAC}
      onImagenUrl={jest.fn()}
      filenamePrefix="contac-ultra"
    />,
  );
  await screen.findAllByRole("button", { name: /Quitar foto/ });

  const input = document.querySelector('input[type="file"][multiple]');
  const frente = new File(["a"], "frente.jpg", { type: "image/jpeg" });
  const dorso = new File(["b"], "dorso.jpg", { type: "image/jpeg" });
  fireEvent.change(input, { target: { files: [frente, dorso] } });

  await waitFor(() => {
    expect(subirImagenStorage).toHaveBeenCalledTimes(2);
    expect(gestionarFotoProducto).toHaveBeenCalledWith(expect.objectContaining({
      action: "agregar",
      productoId: 41,
      url: "https://cdn.ejemplo/contac-dorso.jpg",
    }));
    expect(gestionarFotoProducto).toHaveBeenCalledWith(expect.objectContaining({
      action: "agregar",
      productoId: 41,
      url: "https://cdn.ejemplo/contac-lado.jpg",
    }));
  });
});
