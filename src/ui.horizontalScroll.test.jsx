import React from "react";
import { render } from "@testing-library/react";
import { HorizontalScrollSync } from "./ui";

function WideTable() {
  return (
    <table>
      <thead>
        <tr>
          <th>Foto</th>
          <th>Nombre</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>x</td>
          <td style={{ minWidth: 2400 }}>producto muy ancho</td>
        </tr>
      </tbody>
    </table>
  );
}

it("con altura limitada deja barra horizontal arriba y abajo y marca freeze para títulos fijos", () => {
  const { container } = render(
    <HorizontalScrollSync bodyMaxHeight={240}>
      <WideTable />
    </HorizontalScrollSync>
  );
  expect(container.querySelector(".fc-tabla-scroll--freeze")).toBeTruthy();
  expect(container.querySelector('[data-tabla-hscroll="top"]')).toBeTruthy();
  expect(container.querySelector('[data-tabla-hscroll="bottom"]')).toBeTruthy();
  expect(container.querySelector('[data-tabla-hscroll="body"]')).toBeTruthy();
});

it("sin altura limitada no pinta la barra inferior extra", () => {
  const { container } = render(
    <HorizontalScrollSync>
      <WideTable />
    </HorizontalScrollSync>
  );
  expect(container.querySelector(".fc-tabla-scroll--freeze")).toBeFalsy();
  expect(container.querySelector('[data-tabla-hscroll="bottom"]')).toBeFalsy();
  expect(container.querySelector('[data-tabla-hscroll="top"]')).toBeTruthy();
});

it("fillViewport también congela títulos y deja la barra de abajo", () => {
  const { container } = render(
    <HorizontalScrollSync fillViewport viewportBottomReserve={40}>
      <WideTable />
    </HorizontalScrollSync>
  );
  expect(container.querySelector(".fc-tabla-scroll--freeze")).toBeTruthy();
  expect(container.querySelector('[data-tabla-hscroll="bottom"]')).toBeTruthy();
});
