import { render, screen, fireEvent, within } from "@testing-library/react";
import FiltroChips from "./FiltroChips";

const MARCAS = ["Todos", "Solar", "Afrodit", "Agecaps", "Bepanthen", "CeraVe", "Dibar", "Eucerin", "Avène", "Vaseline"];
const CONTEOS = { Solar: 355, Eucerin: 80, CeraVe: 60, Bepanthen: 40, Vaseline: 3, "Avène": 78 };

test("con pocas opciones son solo chips, sin «Ver todas»", () => {
  render(<FiltroChips opciones={["Todos", "Gastro"]} valor="Todos" onChange={() => {}} />);
  expect(screen.getByRole("button", { name: "Gastro" })).toBeInTheDocument();
  expect(screen.queryByRole("button", { name: /Ver todas/ })).toBeNull();
});

test("con muchas opciones muestra pocas y un botón con cuántas faltan", () => {
  render(<FiltroChips opciones={MARCAS} valor="Todos" onChange={() => {}} conteos={CONTEOS} max={5} />);
  expect(screen.getByRole("button", { name: "Solar" })).toBeInTheDocument();
  expect(screen.queryByRole("button", { name: "Vaseline" })).toBeNull();
  // 10 opciones, 5 visibles (Todos + 4) → quedan 5 detrás
  expect(screen.getByRole("button", { name: /Ver todas/ })).toHaveTextContent("5");
});

test("el panel permite buscar sin acentos y elegir; avisa y se cierra", () => {
  const onChange = jest.fn();
  render(<FiltroChips opciones={MARCAS} valor="Todos" onChange={onChange} conteos={CONTEOS} max={5} />);
  fireEvent.click(screen.getByRole("button", { name: /Ver todas/ }));
  const panel = screen.getByRole("dialog");
  fireEvent.change(within(panel).getByRole("searchbox"), { target: { value: "avene" } });
  expect(within(panel).queryByRole("button", { name: /Vaseline/ })).toBeNull();
  fireEvent.click(within(panel).getByRole("button", { name: /Avène/ }));
  expect(onChange).toHaveBeenCalledWith("Avène");
  expect(screen.queryByRole("dialog")).toBeNull();
});

test("Escape cierra el panel", () => {
  render(<FiltroChips opciones={MARCAS} valor="Todos" onChange={() => {}} max={5} />);
  fireEvent.click(screen.getByRole("button", { name: /Ver todas/ }));
  expect(screen.getByRole("dialog")).toBeInTheDocument();
  fireEvent.keyDown(document, { key: "Escape" });
  expect(screen.queryByRole("dialog")).toBeNull();
});

test("la marca elegida sigue a la vista aunque sea de las chicas", () => {
  render(<FiltroChips opciones={MARCAS} valor="Vaseline" onChange={() => {}} conteos={CONTEOS} max={5} />);
  expect(screen.getByRole("button", { name: "Vaseline" })).toHaveAttribute("aria-pressed", "true");
});

test("sin coincidencias lo dice en vez de dejar el panel vacío", () => {
  render(<FiltroChips opciones={MARCAS} valor="Todos" onChange={() => {}} max={5} />);
  fireEvent.click(screen.getByRole("button", { name: /Ver todas/ }));
  fireEvent.change(screen.getByRole("searchbox"), { target: { value: "zzzz" } });
  expect(screen.getByText("No hay coincidencias.")).toBeInTheDocument();
});

test("«Más marcas» es la etiqueta del filtro de dermocosmética", () => {
  render(
    <FiltroChips
      opciones={MARCAS}
      valor="Todos"
      onChange={() => {}}
      conteos={CONTEOS}
      max={5}
      etiquetaMas="Más marcas"
      etiquetaBuscar="Buscar marca"
    />
  );
  fireEvent.click(screen.getByRole("button", { name: /Más marcas/ }));
  expect(screen.getByRole("dialog", { name: "Más marcas" })).toBeInTheDocument();
  expect(screen.getByRole("searchbox", { name: "Buscar marca" })).toBeInTheDocument();
});
