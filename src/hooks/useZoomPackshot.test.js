import React, { useRef } from "react";
import { render, screen, waitFor } from "@testing-library/react";
import { cajaFotoSinPadding, useZoomPackshot } from "./useZoomPackshot";

jest.mock("../lib/escalaPackshot", () => ({
  zoomDeImagen: jest.fn(() => 2.15),
}));

jest.mock("../utils/tiendaCardImage", () => ({
  tiendaCardImageUrl: (url) => (url ? `thumb:${url}` : ""),
}));

const { zoomDeImagen } = require("../lib/escalaPackshot");

function Foto({ src }) {
  const ref = useRef(null);
  const zoom = useZoomPackshot(src, ref);
  return <div ref={ref} data-testid="caja" data-zoom={String(zoom)} />;
}

let imagenOriginal;

beforeEach(() => {
  zoomDeImagen.mockClear();
  zoomDeImagen.mockReturnValue(2.15);
  imagenOriginal = global.Image;
  global.Image = class FakeImage {
    constructor() {
      this.naturalWidth = 591;
      this.naturalHeight = 591;
      this.crossOrigin = "";
    }

    set src(value) {
      this._src = value;
      queueMicrotask(() => this.onload?.());
    }
  };
  jest.spyOn(HTMLElement.prototype, "clientWidth", "get").mockReturnValue(250);
  jest.spyOn(HTMLElement.prototype, "clientHeight", "get").mockReturnValue(165);
  jest.spyOn(window, "getComputedStyle").mockReturnValue({
    paddingLeft: "17px",
    paddingRight: "17px",
    paddingTop: "17px",
    paddingBottom: "17px",
  });
});

afterEach(() => {
  global.Image = imagenOriginal;
  jest.restoreAllMocks();
});

test("la caja de la foto no cuenta el padding", () => {
  const el = document.createElement("div");
  expect(cajaFotoSinPadding(el)).toEqual({ boxW: 216, boxH: 131 });
});

test("acerca el packshot cuando ya se puede medir el recuadro", async () => {
  render(<Foto src="https://ejemplo.test/argental.webp" />);
  await waitFor(() => {
    expect(screen.getByTestId("caja")).toHaveAttribute("data-zoom", "2.15");
  });
  expect(zoomDeImagen).toHaveBeenCalledWith(expect.any(Object), 216, 131);
  expect(global.Image).toBeInstanceOf(Function);
});

test("sin foto no mide ni acerca", async () => {
  render(<Foto src="" />);
  expect(screen.getByTestId("caja")).toHaveAttribute("data-zoom", "1");
  await Promise.resolve();
  expect(zoomDeImagen).not.toHaveBeenCalled();
});
