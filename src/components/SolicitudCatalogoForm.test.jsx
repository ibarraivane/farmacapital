import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import SolicitudCatalogoForm, { CatalogoVacioConseguir } from "./SolicitudCatalogoForm";

test("búsqueda sin resultados: Solicitarlo precarga el término", async () => {
  const setPage = jest.fn();
  render(<CatalogoVacioConseguir busq="losartan 50" setPage={setPage} />);
  expect(screen.getByText(/No lo tenemos en tienda, pero lo pedimos por ti/i)).toBeInTheDocument();
  await userEvent.click(screen.getByRole("button", { name: /Solicitarlo/i }));
  expect(setPage).toHaveBeenCalledWith("pedidos-especiales", { search: "losartan 50" });
  expect(sessionStorage.getItem("farmacapital_busq")).toBe("losartan 50");
});

test("formulario de categoría no usa Te lo conseguimos", () => {
  render(<SolicitudCatalogoForm setPage={jest.fn()} variante="categoria" bajoVitrina />);
  expect(screen.getByRole("heading", { name: /¿No está en la lista\? Pídelo aquí/i })).toBeInTheDocument();
  expect(screen.queryByText(/Te lo conseguimos/i)).not.toBeInTheDocument();
  expect(screen.getByText(/tarjeta de crédito/i)).toBeInTheDocument();
  expect(document.getElementById("pedido-especial-form")).toBeTruthy();
  expect(document.getElementById("pedido-especial-form").className).toMatch(/farmacapital-solicitud-form/);
  expect(document.getElementById("conseguir-form")).toBeTruthy();
});
