import { render, screen } from "@testing-library/react";
import { Wallet } from "lucide-react";
import { DashboardNavTab } from "./DashboardModule";

jest.mock("./supabase", () => ({
  supabase: { rpc: jest.fn(() => Promise.resolve({ data: null, error: null })) },
}));

test("Flujo de caja usa Wallet, no una gota", () => {
  const { container } = render(<DashboardNavTab id="flujo" active onClick={() => {}} isMobile={false} />);
  expect(screen.getByRole("button", { name: /flujo de caja/i })).toBeInTheDocument();
  expect(container.textContent).not.toMatch(/💧/);
  const { container: wallet } = render(<Wallet size={15} strokeWidth={2.1} />);
  expect(container.querySelector("svg")?.innerHTML).toBe(wallet.querySelector("svg")?.innerHTML);
});

test("las pestañas caben en una fila con labels cortos", () => {
  const ids = ["proyecto", "operacion", "resumen", "transacciones", "margen", "flujo"];
  render(
    <div>
      {ids.map((id) => (
        <DashboardNavTab key={id} id={id} active={id === "flujo"} onClick={() => {}} isMobile={false} />
      ))}
    </div>
  );
  expect(screen.getByText("Proyecto Farma")).toBeInTheDocument();
  expect(screen.getByText("Operación")).toBeInTheDocument();
  expect(screen.getByText("Flujo de caja")).toBeInTheDocument();
  expect(screen.queryByText(/Operación — farmacia/)).toBeNull();
  expect(screen.queryByText(/💧/)).toBeNull();
});
