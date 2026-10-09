import { fireEvent, render, screen } from "@testing-library/react";
import ServiciosSaludPanel from "./ServiciosSaludPanel";

const presion = {
  id: 2,
  sku: "SERV-PRESION",
  nombre: "Toma de presión arterial",
  tipo: "servicio",
  precio: 20,
  activo: true,
  stock: 0,
  costo: 0,
};

test("solo ofrece nombre, precio y activo", () => {
  const onGuardar = jest.fn();
  const onToggleActivo = jest.fn();
  render(
    <ServiciosSaludPanel
      servicios={[presion, { ...presion, id: 4, sku: "SERV-GLUCOSA", nombre: "Medición de glucosa capilar", activo: false, precio: 40 }]}
      onGuardar={onGuardar}
      onToggleActivo={onToggleActivo}
    />
  );
  expect(screen.getByText(/No llevan stock, lote ni costo/)).toBeInTheDocument();
  expect(screen.getAllByText(/Quien aplica/).length).toBeGreaterThan(0);
  expect(screen.getByText(/Quien aplica \$10\.00 · Farmacia \$10\.00/)).toBeInTheDocument();
  expect(screen.queryByLabelText(/stock/i)).not.toBeInTheDocument();
  expect(screen.queryByLabelText(/lote/i)).not.toBeInTheDocument();
  expect(screen.queryByLabelText(/costo/i)).not.toBeInTheDocument();
  expect(screen.queryByLabelText(/proveedor/i)).not.toBeInTheDocument();

  const precio = screen.getAllByDisplayValue("20")[0];
  fireEvent.change(precio, { target: { value: "25" } });
  fireEvent.blur(precio);
  expect(onGuardar).toHaveBeenCalledWith(presion, "precio", "25");

  fireEvent.click(screen.getByRole("button", { name: "Activo" }));
  expect(onToggleActivo).toHaveBeenCalledWith(presion);
  expect(screen.getByRole("button", { name: "Inactivo" })).toBeInTheDocument();
});

test("avisa si el catálogo aún no tiene servicios", () => {
  render(<ServiciosSaludPanel servicios={[]} onGuardar={() => {}} onToggleActivo={() => {}} />);
  expect(screen.getByText(/Todavía no hay servicios/)).toBeInTheDocument();
});
