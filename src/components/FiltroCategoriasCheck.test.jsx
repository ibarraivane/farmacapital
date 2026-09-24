import { render, screen, fireEvent } from "@testing-library/react";
import FiltroCategoriasCheck from "./FiltroCategoriasCheck";

const CATS = ["Analgésico", "Gastro", "Vitaminas"];

test("marcar varias categorías y volver a todas", () => {
  const onChange = jest.fn();
  render(<FiltroCategoriasCheck categorias={CATS} value={[]} onChange={onChange} />);
  fireEvent.click(screen.getByRole("button", { name: "Todas las categorías" }));
  fireEvent.click(screen.getByRole("checkbox", { name: "Analgésico" }));
  expect(onChange).toHaveBeenCalledWith(["Analgésico"]);
  fireEvent.click(screen.getByRole("checkbox", { name: "Gastro" }));
});

test("con dos marcas el botón dice cuántas y se puede quitar una", () => {
  const onChange = jest.fn();
  render(
    <FiltroCategoriasCheck
      categorias={CATS}
      value={["Analgésico", "Gastro"]}
      onChange={onChange}
    />
  );
  expect(screen.getByRole("button", { name: "2 categorías" })).toBeInTheDocument();
  fireEvent.click(screen.getByRole("button", { name: "2 categorías" }));
  expect(screen.getByRole("checkbox", { name: "Analgésico" })).toBeChecked();
  expect(screen.getByRole("checkbox", { name: "Vitaminas" })).not.toBeChecked();
  fireEvent.click(screen.getByRole("checkbox", { name: "Analgésico" }));
  expect(onChange).toHaveBeenCalledWith(["Gastro"]);
  fireEvent.click(screen.getByRole("checkbox", { name: "Todas las categorías" }));
  expect(onChange).toHaveBeenCalledWith([]);
});
