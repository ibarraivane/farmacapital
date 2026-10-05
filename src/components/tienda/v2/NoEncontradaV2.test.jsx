import { render, screen, fireEvent } from "@testing-library/react";
import NoEncontradaV2 from "./NoEncontradaV2";

test("la 404 ofrece inicio, catálogo y Te lo conseguimos", () => {
  const setPage = jest.fn();
  render(<NoEncontradaV2 setPage={setPage} />);
  expect(screen.getByRole("heading", { name: /Página no encontrada/ })).toBeInTheDocument();
  expect(screen.getByRole("link", { name: "Ir al inicio" })).toHaveAttribute("href", "/");
  fireEvent.click(screen.getByRole("link", { name: "Ver catálogo" }));
  expect(setPage).toHaveBeenCalledWith("catalogo");
  expect(screen.getByRole("link", { name: "Te lo conseguimos" })).toHaveAttribute("href", "/conseguir");
});
