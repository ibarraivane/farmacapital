import { fireEvent, render, screen } from "@testing-library/react";
import AdminSidebarPreview from "./AdminSidebarPreview";

test("minimizar el menú estira el main y Fijar menú lo ancla otra vez", () => {
  const { container } = render(<AdminSidebarPreview />);
  const root = container.querySelector(".farmacapital-admin-root");
  const main = container.querySelector(".farmacapital-admin-main");
  expect(root).toHaveAttribute("data-sidebar-collapsed", "0");
  expect(main.style.marginLeft).toBe("220px");

  fireEvent.click(screen.getByRole("button", { name: "Minimizar menú de navegación" }));
  expect(root).toHaveAttribute("data-sidebar-collapsed", "1");
  expect(main.style.marginLeft).toBe("0px");
  expect(screen.getByTestId("admin-collapsed-topbar")).toHaveTextContent("Inventario");

  fireEvent.click(screen.getByRole("button", { name: "Abrir menú de navegación" }));
  expect(container.querySelector(".farmacapital-admin-sidebar")).toHaveAttribute("data-overlay", "1");

  fireEvent.click(screen.getByRole("button", { name: "Fijar menú" }));
  expect(root).toHaveAttribute("data-sidebar-collapsed", "0");
  expect(main.style.marginLeft).toBe("220px");
  expect(screen.getByRole("button", { name: "Minimizar menú de navegación" })).toBeInTheDocument();
});
