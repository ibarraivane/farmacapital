import { render, screen, fireEvent } from "@testing-library/react";
import CategoriasMosaico from "./CategoriasMosaico";

test("cada categoría es un botón con su nombre y avisa al hacer clic", () => {
  const onClick = jest.fn();
  render(
    <CategoriasMosaico
      items={[
        { id: "a", titulo: "Dermocosmética", tono: "crema", foto: "/x.jpg", onClick },
        { id: "b", titulo: "Te lo cotizamos", tono: "noche", icono: <svg data-testid="ico" />, onClick: () => {} },
      ]}
    />
  );
  expect(screen.getByRole("heading", { name: "Comprar por categoría" })).toBeInTheDocument();
  fireEvent.click(screen.getByRole("button", { name: "Dermocosmética" }));
  expect(onClick).toHaveBeenCalledTimes(1);
  expect(screen.getByTestId("ico")).toBeInTheDocument();
});

test("sin categorías no deja un título huérfano", () => {
  const { container } = render(<CategoriasMosaico items={[]} />);
  expect(container).toBeEmptyDOMElement();
});
