import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import GestionUsuariosTabla, { etiquetaAcceso } from "./GestionUsuariosTabla";

const USUARIOS = [
  {
    id: 1,
    nombre: "Erika Juarez",
    email: "erika@farmacapital.mx",
    telefono: "5550001111",
    rol: "vendedor",
    activo: true,
    notas: "Baja 25 ago 2026. Ventas y cortes quedan a su nombre.",
  },
  {
    id: 2,
    nombre: "Ivan Ibarra",
    email: "ivan@farmacapital.mx",
    telefono: "",
    rol: "admin",
    activo: true,
    notas: "",
  },
  {
    id: 3,
    nombre: "Ana Perez",
    telefono: "5550002222",
    rol: "doctora",
    activo: false,
    notas: "Alta 25 ago 2026. Primer día en capacitación.",
  },
];

function renderTabla(props = {}) {
  const handlers = {
    onCerrarDetalle: jest.fn(),
    onVerDetalle: jest.fn(),
    onEditar: jest.fn(),
    onModulos: jest.fn(),
    onToggle: jest.fn(),
    onClave: jest.fn(),
    onBorrar: jest.fn(),
    ...props,
  };
  const view = render(
    <GestionUsuariosTabla
      usuarios={USUARIOS}
      detalleUsuario={null}
      {...handlers}
    />
  );
  return { ...view, handlers };
}

test("etiquetaAcceso junta correo y teléfono", () => {
  expect(etiquetaAcceso({ email: "a@b.com", telefono: "5512345678" })).toBe("a@b.com · 5512345678");
  expect(etiquetaAcceso({ email: "", telefono: "" })).toBe("—");
});

test("las notas largas no se imprimen en la tabla; hay Detalle o un guión", () => {
  renderTabla();
  expect(screen.queryByText(/Ventas y cortes quedan a su nombre/)).toBeNull();
  expect(screen.queryByText(/Primer día en capacitación/)).toBeNull();
  expect(screen.getByLabelText("Ver detalle de Erika Juarez")).toBeInTheDocument();
  expect(screen.getByLabelText("Ver detalle de Ana Perez")).toBeInTheDocument();
  const ivan = screen.getByText("Ivan Ibarra").closest("tr");
  expect(within(ivan).getByText("—")).toBeInTheDocument();
  expect(within(ivan).queryByRole("button", { name: /Ver detalle/ })).toBeNull();
});

test("las acciones de cada fila quedan en un solo grupo sin wrap", () => {
  renderTabla();
  const erika = screen.getByText("Erika Juarez").closest("tr");
  const acciones = erika.querySelector("[data-actions] > div");
  expect(acciones).toBeTruthy();
  expect(acciones.style.flexWrap).toBe("nowrap");
  expect(within(erika).getByRole("button", { name: "Editar usuario" })).toBeInTheDocument();
  expect(within(erika).getByRole("button", { name: "Módulos y permisos" })).toBeInTheDocument();
  expect(within(erika).getByRole("button", { name: "Desactivar usuario" })).toBeInTheDocument();
  expect(within(erika).getByRole("button", { name: "Resetear contraseña" })).toBeInTheDocument();
  expect(within(erika).getByRole("button", { name: "Eliminar usuario" })).toBeInTheDocument();

  const ivan = screen.getByText("Ivan Ibarra").closest("tr");
  expect(within(ivan).queryByRole("button", { name: "Módulos y permisos" })).toBeNull();
});

test("Detalle abre el popup con las notas y permite editar", async () => {
  const onEditar = jest.fn();
  const onCerrarDetalle = jest.fn();
  render(
    <GestionUsuariosTabla
      usuarios={USUARIOS}
      detalleUsuario={USUARIOS[0]}
      onCerrarDetalle={onCerrarDetalle}
      onVerDetalle={jest.fn()}
      onEditar={onEditar}
      onModulos={jest.fn()}
      onToggle={jest.fn()}
      onClave={jest.fn()}
      onBorrar={jest.fn()}
    />
  );

  expect(screen.getByRole("dialog", { name: "Detalle · Erika Juarez" })).toBeInTheDocument();
  expect(screen.getByText(/Ventas y cortes quedan a su nombre/)).toBeInTheDocument();
  await userEvent.click(screen.getByRole("button", { name: "Editar" }));
  expect(onCerrarDetalle).toHaveBeenCalled();
  expect(onEditar).toHaveBeenCalledWith(USUARIOS[0]);
});
