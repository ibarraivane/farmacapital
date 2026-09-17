import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import EnlacesSeccionConseguir from "./EnlacesSeccionConseguir";

const productos = [
  { id: 1, nombre: "Cicaplast", activo: true, bajo_pedido: true, categoria: "Cuidado personal", subcategoria: "Dermatología" },
  { id: 2, nombre: "Elevit", activo: true, bajo_pedido: true, categoria: "Vitaminas" },
];

test("dos enlaces: derma y vitaminas/suplementos", async () => {
  const setPage = jest.fn();
  render(<EnlacesSeccionConseguir setPage={setPage} productos={productos} stack />);
  expect(screen.getByRole("button", { name: /Dermatología/i })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /Vitaminas y suplementos/i })).toBeInTheDocument();
  await userEvent.click(screen.getByRole("button", { name: /Dermatología/i }));
  expect(setPage).toHaveBeenCalledWith("conseguir", { seccion: "dermatologia", search: "" });
  await userEvent.click(screen.getByRole("button", { name: /Vitaminas y suplementos/i }));
  expect(setPage).toHaveBeenCalledWith("conseguir", { seccion: "nutricion", search: "" });
});
