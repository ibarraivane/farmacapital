import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import ModalCarritoNoMezclar from "./ModalCarritoNoMezclar";

test("ofrece vaciar y encargar, no solo Aceptar", async () => {
  const onVaciar = jest.fn();
  const onCarrito = jest.fn();
  const onCancelar = jest.fn();
  render(
    <ModalCarritoNoMezclar
      motivo="Tu carrito ya tiene productos de la tienda. El encargo va en otro pedido."
      producto={{ id: 1, bajo_pedido: true, nombre: "A-Derma" }}
      onVaciarYAgregar={onVaciar}
      onVerCarrito={onCarrito}
      onCancelar={onCancelar}
    />
  );
  expect(screen.getByRole("dialog", { name: /otro pedido/i })).toBeInTheDocument();
  expect(screen.getByText(/productos de la tienda/i)).toBeInTheDocument();
  expect(screen.queryByRole("button", { name: /^aceptar$/i })).not.toBeInTheDocument();
  await userEvent.click(screen.getByRole("button", { name: /vaciar carrito y encargar este/i }));
  expect(onVaciar).toHaveBeenCalledTimes(1);
});
