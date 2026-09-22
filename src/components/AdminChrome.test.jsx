import { fireEvent, render, screen } from "@testing-library/react";
import { AdminCollapsedTopbar, AdminNavToggle } from "./AdminChrome";

test("AdminNavToggle usa el ícono de 3 líneas y el aria-label pedido", () => {
  const onClick = jest.fn();
  render(<AdminNavToggle expanded={false} onClick={onClick} label="Minimizar menú de navegación" />);
  const btn = screen.getByRole("button", { name: "Minimizar menú de navegación" });
  expect(btn).toHaveTextContent("☰");
  expect(btn).toHaveAttribute("aria-expanded", "false");
  fireEvent.click(btn);
  expect(onClick).toHaveBeenCalledTimes(1);
});

test("topbar minimizado abre el menú y permite fijarlo de nuevo", () => {
  const onToggleNav = jest.fn();
  const onPin = jest.fn();
  render(
    <AdminCollapsedTopbar
      title="Inventario"
      navOpen={false}
      onToggleNav={onToggleNav}
      onPin={onPin}
    />
  );
  expect(screen.getByTestId("admin-collapsed-topbar")).toHaveTextContent("Inventario");
  fireEvent.click(screen.getByRole("button", { name: "Abrir menú de navegación" }));
  expect(onToggleNav).toHaveBeenCalledTimes(1);
  fireEvent.click(screen.getByRole("button", { name: "Fijar menú" }));
  expect(onPin).toHaveBeenCalledTimes(1);
});
