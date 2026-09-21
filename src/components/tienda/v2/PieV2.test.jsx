import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import PieV2 from "./PieV2";

test("pie con datos fiscales reales y sin placeholders", () => {
  render(<PieV2 setPage={() => {}} />);
  expect(screen.getByText(/LUIS ANGEL PALILLERO VENTURA/i)).toBeInTheDocument();
  expect(screen.getByText(/PAVL911030NC8/)).toBeInTheDocument();
  expect(screen.getByText(/Radiodifusora 100/)).toBeInTheDocument();
  expect(screen.queryByText(/\[nombre/i)).not.toBeInTheDocument();
  expect(screen.queryByText(/Responsable sanitario/)).not.toBeInTheDocument();
});

test("el responsable sanitario solo aparece si hay dato", () => {
  render(
    <PieV2
      setPage={() => {}}
      farmacia={{
        razon_social: "ACME",
        rfc: "AAA010101AAA",
        direccion_comercial: "Calle 1",
        telefono_display: "55 0000 0000",
        email: "a@b.mx",
        responsable_sanitario: "Q.F.B. Ana Pérez",
        responsable_cedula: "1234567",
      }}
    />
  );
  expect(screen.getByText(/Responsable sanitario: Q.F.B. Ana Pérez · 1234567/)).toBeInTheDocument();
});

test("los enlaces navegan", () => {
  const setPage = jest.fn();
  render(<PieV2 setPage={setPage} />);
  fireEvent.click(screen.getByText("Aviso de privacidad"));
  expect(setPage).toHaveBeenCalledWith("privacidad");
});
