import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import ResenasModeracion from "./ResenasModeracion";

const mockRpc = jest.fn();

jest.mock("../../supabase", () => ({
  supabase: { rpc: (...args) => mockRpc(...args) },
}));

jest.mock("../../utils", () => ({
  getSessionToken: () => "tok",
}));

jest.mock("../../ui", () => ({
  Btn: ({ children, onClick, dis }) => (
    <button type="button" onClick={onClick} disabled={dis}>{children}</button>
  ),
  showToast: jest.fn(),
}));

beforeEach(() => {
  mockRpc.mockReset();
  mockRpc.mockImplementation((name) => {
    if (name === "fn_listar_resenas_moderacion") {
      return Promise.resolve({
        data: [{
          id: 4,
          nombre: "Shampoo",
          marca: "Sedal",
          categoria: "Higiene",
          pedido_id: 90,
          estrellas: 5,
          comentario: "Me gustó el aroma",
          estado: "pendiente",
        }],
        error: null,
      });
    }
    return Promise.resolve({ data: { ok: true }, error: null });
  });
});

test("la lista pendiente muestra el producto y se puede aprobar", async () => {
  render(<ResenasModeracion />);
  expect(await screen.findByText("Shampoo")).toBeInTheDocument();
  expect(screen.getByText(/Me gustó el aroma/)).toBeInTheDocument();
  expect(screen.getByText(/Pedido #90/)).toBeInTheDocument();
  fireEvent.click(screen.getByRole("button", { name: "Aprobar" }));
  await waitFor(() => {
    expect(mockRpc).toHaveBeenCalledWith("fn_moderar_resena", expect.objectContaining({
      p_resena_id: 4,
      p_estado: "aprobada",
    }));
  });
  await waitFor(() => {
    expect(screen.queryByText("Shampoo")).not.toBeInTheDocument();
  });
});
