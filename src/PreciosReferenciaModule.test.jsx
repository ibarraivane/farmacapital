import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import PreciosReferenciaModule from "./PreciosReferenciaModule";

function mockThenable(result) {
  const q = {
    select: () => q,
    eq: () => q,
    order: () => q,
    limit: () => q,
    maybeSingle: () => Promise.resolve(result),
    then: (resolve) => Promise.resolve(result).then(resolve),
  };
  return q;
}

jest.mock("./supabase", () => ({
  supabase: {
    from: (table) => {
      if (table === "productos") {
        return mockThenable({
          data: [{
            id: 1059,
            sku: "EQ-NOV179",
            nombre: "Acetif 10 Tab 500 Mg",
            categoria: "medicamento",
            tipo: "generico",
            costo: 8,
            precio: 15,
            principio_activo: "Paracetamol",
            concentracion: "500 mg",
            presentacion: "C/10",
            forma_farmaceutica: "tableta",
            requiere_receta: false,
            marca: "Novag",
          }],
          error: null,
        });
      }
      if (table === "producto_precios_referencia_actual") {
        return mockThenable({
          data: [{
            producto_id: 1059,
            fuente: "farmacity",
            tipo: "compra",
            precio: 5.98,
            fecha: "2026-09-04",
            nombre_fuente: "ACETIF 500MG C/10 TABS PARACETAMOL NOVAG",
          }],
          error: null,
        });
      }
      return mockThenable({ data: null, error: null });
    },
  },
}));

test("la tabla Compra muestra Farma City y no Otros", async () => {
  render(<PreciosReferenciaModule />);
  await userEvent.click(await screen.findByRole("button", { name: /compra \(proveedores\)/i }));
  await waitFor(() => {
    expect(screen.getByRole("columnheader", { name: "Farma City" })).toBeInTheDocument();
  });
  expect(screen.queryByRole("columnheader", { name: "Otros" })).not.toBeInTheDocument();
  expect(screen.getByRole("columnheader", { name: "Farmalive" })).toBeInTheDocument();
  expect(screen.getByText("$5.98")).toBeInTheDocument();
});
