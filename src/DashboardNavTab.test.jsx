import { readFileSync } from "fs";
import { join } from "path";
import { fireEvent, render, screen } from "@testing-library/react";
import { Banknote } from "lucide-react";
import { DashboardNavTab } from "./DashboardModule";
import { SegmentedNav } from "./components/SegmentedNav";

jest.mock("./supabase", () => ({
  supabase: { rpc: jest.fn(() => Promise.resolve({ data: null, error: null })) },
}));

const ITEMS = [
  { id: "a", label: "Uno" },
  { id: "b", label: "Resultados · pronto", disabled: true, title: "P&L bloqueado" },
  { id: "c", label: "Tres" },
];

test("Flujo de caja usa Banknote, no una gota", () => {
  const { container } = render(<DashboardNavTab id="flujo" active onClick={() => {}} isMobile={false} />);
  expect(screen.getByRole("tab", { name: /flujo de caja/i })).toBeInTheDocument();
  expect(container.textContent).not.toMatch(/💧/);
  const { container: money } = render(<Banknote size={15} strokeWidth={1.9} />);
  expect(container.querySelector("svg")?.innerHTML).toBe(money.querySelector("svg")?.innerHTML);
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

test("Flujo de caja usa labelMobile Flujo", () => {
  render(<DashboardNavTab id="flujo" active onClick={() => {}} isMobile />);
  expect(screen.getByRole("tab", { name: /^flujo$/i })).toBeInTheDocument();
});

test("solo un tab por tablist tiene tabIndex 0", () => {
  render(<SegmentedNav items={ITEMS} value="a" onChange={() => {}} ariaLabel="t" />);
  const tabs = screen.getAllByRole("tab");
  expect(tabs.filter((t) => t.tabIndex === 0)).toHaveLength(1);
});

test("ArrowRight salta aria-disabled y no llama onChange en manual", () => {
  const onChange = jest.fn();
  render(<SegmentedNav items={ITEMS} value="a" onChange={onChange} activation="manual" ariaLabel="t" />);
  const list = screen.getByRole("tablist");
  screen.getByRole("tab", { name: "Uno" }).focus();
  fireEvent.keyDown(list, { key: "ArrowRight" });
  expect(onChange).not.toHaveBeenCalled();
  expect(screen.getByRole("tab", { name: "Tres" })).toHaveFocus();
});

test("Enter sobre el tab enfocado llama onChange", () => {
  const onChange = jest.fn();
  render(<SegmentedNav items={ITEMS} value="a" onChange={onChange} activation="manual" ariaLabel="t" />);
  const list = screen.getByRole("tablist");
  screen.getByRole("tab", { name: "Uno" }).focus();
  fireEvent.keyDown(list, { key: "ArrowRight" });
  fireEvent.keyDown(list, { key: "Enter" });
  expect(onChange).toHaveBeenCalledWith("c");
});

test("el tab deshabilitado tiene aria-disabled y no disabled", () => {
  render(<SegmentedNav items={ITEMS} value="a" onChange={() => {}} ariaLabel="t" />);
  const blocked = screen.getByRole("tab", { name: /resultados/i });
  expect(blocked).toHaveAttribute("aria-disabled", "true");
  expect(blocked).not.toBeDisabled();
});

test("size=sm no pinta fondo inline en el well", () => {
  const { container } = render(
    <SegmentedNav
      size="sm"
      items={[{ id: "f", label: "Flujo", Icon: Banknote }]}
      value="f"
      onChange={() => {}}
      ariaLabel="t"
    />
  );
  expect(container.querySelector(".fc-dash-seg--sm")).toBeTruthy();
  const well = container.querySelector(".fc-dash-tab-well");
  expect(well).toBeTruthy();
  expect(well.getAttribute("style") || "").not.toMatch(/background/);
});

test("cada tab tiene aria-controls y existe el panel con ese id", () => {
  render(
    <div>
      <SegmentedNav idPrefix="dash" items={ITEMS} value="a" onChange={() => {}} ariaLabel="t" />
      {ITEMS.map((it) => (
        <div key={it.id} id={`dash-panel-${it.id}`} role="tabpanel" aria-labelledby={`dash-tab-${it.id}`} />
      ))}
    </div>
  );
  const tabs = screen.getAllByRole("tab");
  tabs.forEach((tab) => {
    const controls = tab.getAttribute("aria-controls");
    expect(controls).toBeTruthy();
    expect(document.getElementById(controls)).toBeTruthy();
  });
});

test("FlujoCajaTab deja es_recurrente como checkbox", () => {
  const src = readFileSync(join(__dirname, "FlujoCajaTab.jsx"), "utf8");
  expect(src).toMatch(/checked=\{form\.es_recurrente\}/);
  expect(src).toMatch(/type="checkbox"/);
});
