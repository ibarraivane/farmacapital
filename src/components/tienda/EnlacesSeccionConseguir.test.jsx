import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import EnlacesSeccionConseguir from "./EnlacesSeccionConseguir";

const productos = [
  { id: 1, nombre: "Cicaplast", activo: true, bajo_pedido: true, categoria: "Cuidado personal", subcategoria: "Dermatología" },
  { id: 2, nombre: "Elevit", activo: true, bajo_pedido: true, categoria: "Vitaminas" },
];

test("tres tarjetas: Dermocosmética, Vitaminas y Dispositivos", async () => {
  const setPage = jest.fn();
  render(<EnlacesSeccionConseguir setPage={setPage} productos={productos} stack />);
  expect(screen.getByRole("button", { name: /Dermocosmética/i })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /Vitaminas y suplementos/i })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /Dispositivos médicos/i })).toBeInTheDocument();
  await userEvent.click(screen.getByRole("button", { name: /Dermocosmética/i }));
  expect(setPage).toHaveBeenCalledWith("dermocosmetica", { search: "" });
  await userEvent.click(screen.getByRole("button", { name: /Vitaminas y suplementos/i }));
  expect(setPage).toHaveBeenCalledWith("vitaminas", { search: "" });
  await userEvent.click(screen.getByRole("button", { name: /Dispositivos médicos/i }));
  expect(setPage).toHaveBeenCalledWith("dispositivos", { search: "" });
});

test("conteo N>0 y N=0", () => {
  const { rerender } = render(<EnlacesSeccionConseguir setPage={jest.fn()} productos={productos} />);
  expect(screen.getAllByText(/^1 producto$/i).length).toBe(2);
  expect(screen.getByText(/^Ver/)).toBeInTheDocument();
  rerender(<EnlacesSeccionConseguir setPage={jest.fn()} productos={[]} />);
  expect(screen.getAllByText(/^Ver/).length).toBe(3);
});
