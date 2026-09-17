import { render, screen } from "@testing-library/react";
import PedidosEspeciales from "./PedidosEspeciales";

test("pedidos especiales menciona dispositivos y enlaza las tres vitrinas", () => {
  render(
    <PedidosEspeciales setPage={jest.fn()} productos={[]} stack>
      <div>FORMULARIO</div>
    </PedidosEspeciales>
  );
  expect(screen.getByRole("heading", { name: "Pedidos especiales" })).toBeInTheDocument();
  expect(screen.getByText(/Medicamento, vitamina o dispositivo/i)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /Dispositivos médicos/i })).toBeInTheDocument();
  expect(screen.getByText("FORMULARIO")).toBeInTheDocument();
});
