import { render, screen } from "@testing-library/react";
import { EstrellasResena, EstrellasDeProducto, ResenasResumenCtx, BloqueResenaPedido } from "./ResenasTienda";

jest.mock("../../supabase", () => ({ supabase: { rpc: jest.fn(), from: jest.fn() } }));

test("sin promedio no pinta estrellas", () => {
  const { container } = render(<EstrellasResena resumen={null} />);
  expect(container).toBeEmptyDOMElement();
});

test("el promedio aprobado se lee en voz alta", () => {
  render(<EstrellasResena resumen={{ promedio: 4.5, total: 2 }} />);
  expect(screen.getByRole("img", { name: "4.5 de 5 · 2 reseñas" })).toBeInTheDocument();
});

test("un medicamento no muestra estrellas aunque haya promedio", () => {
  render(
    <ResenasResumenCtx.Provider value={{ 7: { promedio: 5, total: 3 } }}>
      <EstrellasDeProducto prod={{ id: 7, nombre: "Omeprazol", categoria: "Gastro" }} />
    </ResenasResumenCtx.Provider>
  );
  expect(screen.queryByRole("img")).not.toBeInTheDocument();
});

test("higiene con promedio sí muestra estrellas", () => {
  render(
    <ResenasResumenCtx.Provider value={{ 3: { promedio: 4, total: 1 } }}>
      <EstrellasDeProducto prod={{ id: 3, nombre: "Shampoo", categoria: "Higiene" }} />
    </ResenasResumenCtx.Provider>
  );
  expect(screen.getByRole("img", { name: "4 de 5 · 1 reseña" })).toBeInTheDocument();
});

test("en un pedido entregado solo se califican los productos permitidos", () => {
  render(
    <BloqueResenaPedido
      pedido={{
        id: 12,
        estado: "completado",
        pedido_items: [
          { producto_id: 1, productos: { id: 1, nombre: "Ibuprofeno" } },
          { producto_id: 2, productos: { id: 2, nombre: "Shampoo" } },
        ],
      }}
      productos={[
        { id: 1, nombre: "Ibuprofeno", categoria: "Analgésico" },
        { id: 2, nombre: "Shampoo", categoria: "Higiene" },
      ]}
    />
  );
  expect(screen.getByText("Shampoo")).toBeInTheDocument();
  expect(screen.queryByText("Ibuprofeno")).not.toBeInTheDocument();
  expect(screen.getByRole("radio", { name: "5 de 5" })).toBeInTheDocument();
});

test("un pedido que no está entregado no pide reseña", () => {
  const { container } = render(
    <BloqueResenaPedido
      pedido={{ id: 1, estado: "listo", pedido_items: [{ producto_id: 2 }] }}
      productos={[{ id: 2, nombre: "Shampoo", categoria: "Higiene" }]}
    />
  );
  expect(container).toBeEmptyDOMElement();
});
