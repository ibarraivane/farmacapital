import { render, screen, fireEvent } from "@testing-library/react";
import FichaV2, { fichaTecnicaDe, entregaFicha } from "./FichaV2";

const PROD = {
  id: 7,
  nombre: "Omeprazol 20 mg cápsulas C/30",
  marca: "Ultra",
  stock: 12,
  precio: 89,
  principio_activo: "Omeprazol",
  concentracion: "20 mg",
  requiere_receta: false,
};

test("la ficha técnica solo trae renglones con dato", () => {
  const filas = fichaTecnicaDe(PROD, null, null).map((f) => f.k);
  expect(filas).toContain("Sustancia activa");
  expect(filas).toContain("Concentración");
  expect(filas).not.toContain("Registro sanitario");
});

test("producto en sucursal: se puede agregar y comprar", () => {
  const onAgregar = jest.fn();
  const onComprar = jest.fn();
  render(
    <FichaV2
      prod={PROD}
      estadoCompra={{ agotado: false, permitidoWeb: true, esEncargo: false }}
      precioSlot={<span>$93.00</span>}
      onAgregar={onAgregar}
      onComprar={onComprar}
      setPage={() => {}}
    />
  );
  expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent("Omeprazol");
  expect(screen.getByText("Listo para recoger hoy")).toBeInTheDocument();
  fireEvent.click(screen.getByRole("button", { name: /Agregar al carrito/i }));
  fireEvent.click(screen.getByRole("button", { name: /Comprar ahora/i }));
  expect(onAgregar).toHaveBeenCalled();
  expect(onComprar).toHaveBeenCalled();
});

test("agotado no deja comprar", () => {
  render(
    <FichaV2
      prod={{ ...PROD, stock: 0 }}
      estadoCompra={{ agotado: true, permitidoWeb: true, esEncargo: false }}
      setPage={() => {}}
    />
  );
  expect(screen.getByRole("button", { name: /Agotado/i })).toBeDisabled();
  expect(screen.getByText("Agotado por ahora")).toBeInTheDocument();
});

test("por encargo ofrece pedir, no agregar", () => {
  const onCotizar = jest.fn();
  render(
    <FichaV2
      prod={{ ...PROD, stock: 0, bajo_pedido: true }}
      estadoCompra={{ agotado: false, permitidoWeb: true, esEncargo: true }}
      onCotizar={onCotizar}
      setPage={() => {}}
    />
  );
  expect(screen.queryByRole("button", { name: /Agregar al carrito/i })).not.toBeInTheDocument();
  fireEvent.click(screen.getByRole("button", { name: /Pedir por encargo/i }));
  expect(onCotizar).toHaveBeenCalled();
});

test("con receta muestra el aviso", () => {
  render(
    <FichaV2
      prod={{ ...PROD, requiere_receta: true }}
      estadoCompra={{ agotado: false, permitidoWeb: true, esEncargo: false }}
      requiereReceta
      avisoReceta="La receta se revisa al entregar el medicamento."
      setPage={() => {}}
    />
  );
  expect(screen.getByText(/Requiere receta médica/)).toBeInTheDocument();
  expect(screen.getByText(/La receta se revisa al entregar/)).toBeInTheDocument();
});

test("el nombre va antes de la foto, no debajo", () => {
  const { container } = render(
    <FichaV2
      prod={PROD}
      imagen="/foto.jpg"
      estadoCompra={{ agotado: false, permitidoWeb: true, esEncargo: false }}
      setPage={() => {}}
    />
  );
  const orden = [...container.querySelectorAll("h1, .fc-detail-photo, .fc-buybox")];
  expect(orden.map((n) => n.tagName === "H1" ? "nombre" : n.className.includes("photo") ? "foto" : "compra"))
    .toEqual(["nombre", "foto", "compra"]);
});

test("cada estado dice cuándo lo tienes", () => {
  expect(entregaFicha({ esEncargo: true }).titulo).toMatch(/24-48/);
  expect(entregaFicha({ agotado: true }).titulo).toMatch(/Agotado/);
  expect(entregaFicha({ permitidoWeb: false, textoBloqueo: "Solo minisuper" }).titulo).toBe("Solo minisuper");
  expect(entregaFicha({ permitidoWeb: true }).titulo).toMatch(/recoger hoy/);
});
