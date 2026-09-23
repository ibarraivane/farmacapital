import React, { useState } from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import FilaSolicitudMostrador from "./FilaSolicitudMostrador";

const base = {
  id: 41,
  texto: "DROPS miel",
  cantidad: 1,
  estado: "pendiente",
  urgencia: "sin_prisa",
  tipo: "no_catalogo",
  origen: "mostrador",
  pago_tipo: "nada",
  anotado_por_nombre: "Rosa Raquel Lucas Galindo",
  created_at: "2026-09-23T15:02:00.000Z",
  notas: "tenemos de jengibre, buscaban sabor miel",
  cliente_nombre: "Ana",
  cliente_telefono: "5512345678",
};

function renderFila(overrides = {}, props = {}) {
  const onToggle = jest.fn();
  const onCambiarEstado = jest.fn();
  const onAbrirCotizacion = jest.fn();
  render(
    <FilaSolicitudMostrador
      solicitud={{ ...base, ...overrides }}
      abierta={false}
      onToggle={onToggle}
      esAdmin
      cotizacion={null}
      promoviendo={false}
      actualizando={false}
      onCambiarEstado={onCambiarEstado}
      onAbrirCotizacion={onAbrirCotizacion}
      {...props}
    />,
  );
  return { onToggle, onCambiarEstado, onAbrirCotizacion };
}

it("cerrada es una línea: estado visible, detalle oculto", () => {
  renderFila();
  const fila = screen.getByRole("button", { name: "DROPS miel" });
  expect(fila).toHaveAttribute("aria-expanded", "false");
  expect(screen.getByText("Pendiente")).toBeInTheDocument();
  expect(screen.queryByText("Sin prisa")).not.toBeInTheDocument();
  expect(screen.queryByText("No está en catálogo")).not.toBeInTheDocument();
  expect(screen.queryByText("Mostrador")).not.toBeInTheDocument();
  expect(screen.queryByText(/Rosa Raquel/)).not.toBeInTheDocument();
  expect(screen.queryByText(/Nota:/)).not.toBeInTheDocument();
  expect(screen.queryByText(/Pasar costo por WhatsApp/)).not.toBeInTheDocument();
  expect(screen.queryByRole("button", { name: "→ Pedir" })).not.toBeInTheDocument();
});

it("al abrir muestra vendedor, nota, WhatsApp y los estados", () => {
  const { onCambiarEstado, onAbrirCotizacion, onToggle } = renderFila({}, { abierta: true });
  expect(screen.getByRole("button", { name: "DROPS miel" })).toHaveAttribute("aria-expanded", "true");
  expect(screen.getByText(/Vendedor: Rosa Raquel Lucas Galindo/)).toBeInTheDocument();
  expect(screen.getByText(/Nota: tenemos de jengibre/)).toBeInTheDocument();
  expect(screen.getByText(/Cliente: Ana/)).toBeInTheDocument();
  expect(screen.getByText("Sin prisa")).toBeInTheDocument();
  expect(screen.getByText("No está en catálogo")).toBeInTheDocument();
  expect(screen.getByRole("link", { name: /Pasar costo por WhatsApp/ })).toHaveAttribute("href", expect.stringContaining("wa.me/525512345678"));
  fireEvent.click(screen.getByRole("button", { name: "→ Pedir" }));
  expect(onCambiarEstado).toHaveBeenCalledWith("pedir");
  expect(onToggle).not.toHaveBeenCalled();
  fireEvent.click(screen.getByRole("button", { name: "Abrir cotización" }));
  expect(onAbrirCotizacion).toHaveBeenCalled();
});

it("en la línea se ven Hoy, Web y el anticipo; Sin prisa no", () => {
  renderFila({
    urgencia: "hoy",
    origen: "tienda",
    pago_tipo: "deposito",
    pago_monto: 80,
    cliente_nombre: "",
    cliente_telefono: "",
    notas: "",
  });
  expect(screen.getByText("Hoy")).toBeInTheDocument();
  expect(screen.getByText("Web")).toBeInTheDocument();
  expect(screen.getByText(/Depósito/)).toBeInTheDocument();
  expect(screen.queryByText("Sin prisa")).not.toBeInTheDocument();
  expect(screen.queryByText(/Vendedor:/)).not.toBeInTheDocument();
});

it("la cantidad va en la línea y abrir otra cierra la anterior", () => {
  function Lista() {
    const [abiertaId, setAbiertaId] = useState(null);
    const filas = [
      { ...base, id: 1, texto: "DROPS miel" },
      { ...base, id: 2, texto: "vick pyrena noche", cantidad: 2, notas: "noche" },
    ];
    return filas.map((s, i) => (
      <FilaSolicitudMostrador
        key={s.id}
        solicitud={s}
        abierta={abiertaId === s.id}
        conDivision={i > 0}
        esAdmin={false}
        onToggle={() => setAbiertaId((cur) => (cur === s.id ? null : s.id))}
        onCambiarEstado={() => {}}
        onAbrirCotizacion={() => {}}
      />
    ));
  }
  render(<Lista />);
  expect(screen.getByRole("button", { name: "vick pyrena noche ×2" })).toBeInTheDocument();
  expect(screen.queryByText("Abrir cotización")).not.toBeInTheDocument();
  fireEvent.click(screen.getByRole("button", { name: "DROPS miel" }));
  expect(screen.getByText(/Rosa Raquel/)).toBeInTheDocument();
  fireEvent.click(screen.getByRole("button", { name: "vick pyrena noche ×2" }));
  expect(screen.getByText(/Nota: noche/)).toBeInTheDocument();
  expect(screen.getAllByText(/Rosa Raquel/)).toHaveLength(1);
  fireEvent.click(screen.getByRole("button", { name: "vick pyrena noche ×2" }));
  expect(screen.queryByText(/Nota: noche/)).not.toBeInTheDocument();
});
