import { fireEvent, render, screen } from "@testing-library/react";
import { SearchDropdown } from "./ui";

const ITEMS = [
  { nombre: "Aspirina 500 mg C/40", sku: "FC-8491966" },
];

function openWithValue(panelMode) {
  render(
    <div>
      <SearchDropdown
        panelMode={panelMode}
        value="Aspirina"
        onChange={() => {}}
        onSelect={() => {}}
        placeholder="Buscar inventario"
        items={ITEMS}
        labelKey="nombre"
        subKey="sku"
      />
      <label>Todas las categorías</label>
    </div>
  );
  fireEvent.focus(screen.getByPlaceholderText("Buscar inventario"));
}

test("Inventario: el resultado empuja «Todas las categorías» y no flota encima", () => {
  openWithValue("push");
  const panel = document.querySelector("[data-search-panel]");
  const categorias = screen.getByText("Todas las categorías");
  expect(panel).toBeTruthy();
  expect(panel.getAttribute("data-search-panel")).toBe("push");
  expect(panel.style.position).toBe("relative");
  expect(panel.style.position).not.toBe("absolute");
  expect(screen.getByText("Aspirina 500 mg C/40")).toBeTruthy();
  expect(panel.compareDocumentPosition(categorias) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  const input = screen.getByPlaceholderText("Buscar inventario");
  expect(input.className).toContain("farmacapital-field-input");
  const bg = `${input.style.backgroundColor} ${input.style.background}`.replace(/\s/g, "").toLowerCase();
  expect(bg).toMatch(/#fff|#ffffff|rgb\(255,255,255\)/);
  expect(bg).not.toMatch(/#f7f9fc/);
});

test("POS y el resto siguen con el panel flotante", () => {
  openWithValue("overlay");
  const panel = document.querySelector("[data-search-panel]");
  expect(panel.getAttribute("data-search-panel")).toBe("overlay");
  expect(panel.style.position).toBe("absolute");
});
