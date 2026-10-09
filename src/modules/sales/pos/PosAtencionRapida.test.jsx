import { fireEvent, render, screen } from "@testing-library/react";
import { C_LIGHT } from "../../../constants";
import PosAtencionRapida from "./PosAtencionRapida";

const servicios = [
  { id: 1, sku: "SERV-INY-IM", nombre: "Aplicación de inyección intramuscular", tipo: "servicio", precio: 30, activo: true },
  { id: 2, sku: "SERV-PRESION", nombre: "Toma de presión arterial", tipo: "servicio", precio: 20, activo: true },
  { id: 3, sku: "SERV-OXIMETRIA", nombre: "Medición de oxigenación (oximetría)", tipo: "servicio", precio: 20, activo: true },
];

test("muestra Atención con precio y agrega al toque", () => {
  const onAdd = jest.fn();
  render(<PosAtencionRapida servicios={servicios} onAdd={onAdd} C={C_LIGHT} />);
  expect(screen.getByText("Atención")).toBeInTheDocument();
  const presion = screen.getByRole("button", { name: /Presión/ });
  expect(presion).toHaveTextContent("$20");
  expect(presion).toHaveStyle({ fontSize: "13px", lineHeight: "18px", padding: "0px" });
  expect(screen.getByRole("button", { name: /Inyección/ })).toHaveTextContent("$30");
  expect(screen.getByRole("button", { name: /Oxigenación/ })).toBeInTheDocument();
  fireEvent.click(presion);
  expect(onAdd).toHaveBeenCalledWith(servicios[1]);
});

test("sin servicios no pinta la fila", () => {
  const { container } = render(<PosAtencionRapida servicios={[]} onAdd={() => {}} C={C_LIGHT} />);
  expect(container).toBeEmptyDOMElement();
});
