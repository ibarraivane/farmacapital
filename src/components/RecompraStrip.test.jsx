import React from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import RecompraStrip, { ProductosStripStyles } from "./RecompraStrip";

function mockStripMetrics(el, { clientWidth, scrollWidth, scrollLeft = 0 }) {
  Object.defineProperty(el, "clientWidth", { configurable: true, value: clientWidth });
  Object.defineProperty(el, "scrollWidth", { configurable: true, value: scrollWidth });
  Object.defineProperty(el, "scrollLeft", { configurable: true, writable: true, value: scrollLeft });
}

function renderBanda() {
  return render(
    <>
      <ProductosStripStyles />
      <RecompraStrip title="Analgésico" actionLabel="Ver todos →" onAction={() => {}}>
        <div>A</div>
        <div>B</div>
        <div>C</div>
        <div>D</div>
        <div>E</div>
        <div>F</div>
      </RecompraStrip>
    </>
  );
}

it("no rompe el título ni el enlace de la banda", () => {
  renderBanda();
  expect(screen.getByRole("heading", { name: "Analgésico" })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Ver todos →" })).toBeInTheDocument();
});

it("muestra la flecha siguiente cuando hay más productos fuera de vista", () => {
  const { container } = renderBanda();
  const strip = container.querySelector(".farmacapital-productos-strip");
  mockStripMetrics(strip, { clientWidth: 800, scrollWidth: 2000 });
  fireEvent.scroll(strip);
  expect(screen.getByLabelText("Siguientes productos")).not.toBeDisabled();
  expect(screen.getByLabelText("Productos anteriores")).toBeDisabled();
});

it("al click de la flecha avanza una página de productos", () => {
  const { container } = renderBanda();
  const strip = container.querySelector(".farmacapital-productos-strip");
  mockStripMetrics(strip, { clientWidth: 800, scrollWidth: 2000 });
  const scrollTo = jest.fn();
  strip.scrollTo = scrollTo;
  fireEvent.scroll(strip);
  fireEvent.click(screen.getByLabelText("Siguientes productos"));
  expect(scrollTo).toHaveBeenCalledWith({ left: 800, behavior: "smooth" });
});
