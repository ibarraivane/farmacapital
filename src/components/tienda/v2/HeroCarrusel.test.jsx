import { render, screen, fireEvent } from "@testing-library/react";
import HeroCarrusel from "./HeroCarrusel";

const slide = (id, extra = {}) => ({
  id,
  tono: "cream",
  eyebrow: `Slide ${id}`,
  titulo: "Título",
  nota: `Nota ${id}`,
  cta: `Ir ${id}`,
  onIr: jest.fn(),
  ...extra,
});

test("sin slides no dibuja nada", () => {
  const { container } = render(<HeroCarrusel slides={[]} />);
  expect(container).toBeEmptyDOMElement();
});

test("una sola slide no trae flechas ni puntos", () => {
  render(<HeroCarrusel slides={[slide("único")]} />);
  expect(screen.getByText("Slide único")).toBeInTheDocument();
  expect(screen.queryByRole("tablist")).not.toBeInTheDocument();
  expect(screen.queryByLabelText("Siguiente")).not.toBeInTheDocument();
});

test("las flechas avanzan y regresan", () => {
  render(<HeroCarrusel slides={[slide("a"), slide("b"), slide("c")]} />);
  expect(screen.getByText("Slide a")).toBeInTheDocument();
  fireEvent.click(screen.getByLabelText("Siguiente"));
  expect(screen.getByText("Slide b")).toBeInTheDocument();
  fireEvent.click(screen.getByLabelText("Anterior"));
  expect(screen.getByText("Slide a")).toBeInTheDocument();
  // de la primera hacia atrás da la vuelta a la última
  fireEvent.click(screen.getByLabelText("Anterior"));
  expect(screen.getByText("Slide c")).toBeInTheDocument();
});

test("los puntos llevan directo a una slide y marcan la activa", () => {
  render(<HeroCarrusel slides={[slide("a"), slide("b"), slide("c")]} />);
  fireEvent.click(screen.getByLabelText("Ver: Slide c"));
  expect(screen.getByText("Nota c")).toBeInTheDocument();
  expect(screen.getByLabelText("Ver: Slide c")).toHaveAttribute("aria-current", "true");
  expect(screen.getByLabelText("Ver: Slide a")).toHaveAttribute("aria-current", "false");
});

test("las flechas del teclado también cambian de slide", () => {
  render(<HeroCarrusel slides={[slide("a"), slide("b")]} />);
  const region = screen.getByRole("region", { name: "Destacados" });
  fireEvent.keyDown(region, { key: "ArrowRight" });
  expect(screen.getByText("Slide b")).toBeInTheDocument();
});

test("el botón llama al onIr de la slide visible, no al de otra", () => {
  const onA = jest.fn();
  const onB = jest.fn();
  render(<HeroCarrusel slides={[slide("a", { onIr: onA }), slide("b", { onIr: onB })]} />);
  fireEvent.click(screen.getByText("Ir a"));
  expect(onA).toHaveBeenCalledTimes(1);
  expect(onB).not.toHaveBeenCalled();
});

test("cada slide aplica el tono que trae, para que cada historia tenga su fondo", () => {
  const { container } = render(<HeroCarrusel slides={[slide("a", { tono: "ink" })]} />);
  expect(container.querySelector(".fc-studio--ink")).toBeInTheDocument();
});

test("una slide con imágenes muestra la marca de cada una", () => {
  render(<HeroCarrusel slides={[slide("a", {
    imagenes: [{ id: 1, src: "/x.jpg", marca: "Isdin" }, { id: 2, src: "/y.jpg", marca: "Bioderma" }],
  })]} />);
  expect(screen.getByText("Isdin")).toBeInTheDocument();
  expect(screen.getByText("Bioderma")).toBeInTheDocument();
});
