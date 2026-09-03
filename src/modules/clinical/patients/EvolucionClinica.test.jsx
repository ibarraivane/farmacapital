import { render, screen } from "@testing-library/react";
import { EvolucionClinica } from "./EvolucionClinica";
import { puntosDesdeCitas } from "../../../lib/evolucionClinica";

const CITAS = [
  {
    id: 1,
    fecha: "2026-04-19",
    hora: "10:00",
    signos_vitales: { ta: "138/88", fc: "80", temp: "36.8", sat: "96", peso: "71.4", talla: "162" },
  },
  {
    id: 2,
    fecha: "2026-07-30",
    hora: "09:00",
    signos_vitales: { ta: "128/82", fc: "74", temp: "36.6", sat: "97", peso: "68.2" },
  },
];

test("muestra narración, peso, IMC y presión", () => {
  render(<EvolucionClinica puntos={puntosDesdeCitas(CITAS)} />);
  const root = screen.getByTestId("evolucion-clinica");
  expect(root).toHaveTextContent(/peso bajó 3\.2 kg/i);
  expect(root).toHaveTextContent("Peso");
  expect(root).toHaveTextContent("68.2");
  expect(root).toHaveTextContent("IMC");
  expect(root).toHaveTextContent("Presión arterial");
  expect(root).toHaveTextContent("128/82");
  expect(document.querySelectorAll("svg").length).toBeGreaterThan(2);
});

test("vacío explica que faltan signos", () => {
  render(<EvolucionClinica puntos={[]} />);
  expect(screen.getByTestId("evolucion-clinica")).toHaveTextContent(/Aún no hay signos/);
});
