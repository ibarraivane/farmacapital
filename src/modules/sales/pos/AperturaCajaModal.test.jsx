import { render, screen, waitFor, fireEvent } from "@testing-library/react";
import AperturaCajaModal from "./AperturaCajaModal";
import { fetchJornadaHoy, abrirSesionCaja } from "../../../utils/cajaSesion";

jest.mock("../../../utils/cajaSesion", () => ({
  fetchJornadaHoy: jest.fn(),
  abrirSesionCaja: jest.fn(),
}));

jest.mock("../../../ui", () => ({
  showToast: jest.fn(),
}));

jest.mock("../../../components/ArqueoDenominaciones", () => {
  return function MockArqueo({ denoms, onChange }) {
    return (
      <button type="button" onClick={() => onChange(500, "2")}>
        mock-denoms-{Object.keys(denoms || {}).length}
      </button>
    );
  };
});

beforeEach(() => {
  fetchJornadaHoy.mockReset();
  abrirSesionCaja.mockReset();
  fetchJornadaHoy.mockResolvedValue({
    jornada: { turno_habitual: null, turno_abrir: null, caja_ocupada_por: null },
    error: null,
  });
});

test("modo opcional: admin puede confirmar sin turno RH", async () => {
  abrirSesionCaja.mockResolvedValue({
    sesion: { abierta: true, id: 11, turno: "matutino", abierta_at: "2026-09-26T15:00:00Z" },
    error: null,
    auth: false,
  });
  const onAbierta = jest.fn();
  const onCancel = jest.fn();

  render(
    <AperturaCajaModal
      usuario={{ nombre: "Iván", rol: "admin" }}
      opcional
      onCancel={onCancel}
      onAbierta={onAbierta}
    />
  );

  await waitFor(() => {
    expect(screen.getByRole("button", { name: /Confirmar apertura/i })).toBeEnabled();
  });

  fireEvent.click(screen.getByText(/mock-denoms/i));
  fireEvent.click(screen.getByRole("button", { name: /Confirmar apertura/i }));

  await waitFor(() => {
    expect(abrirSesionCaja).toHaveBeenCalled();
    expect(onAbierta).toHaveBeenCalledWith(
      expect.objectContaining({ id: 11, turno: "matutino" })
    );
  });
});

test("modo opcional: Seguir sin abrir caja llama onCancel", async () => {
  const onCancel = jest.fn();
  render(
    <AperturaCajaModal
      usuario={{ nombre: "Iván", rol: "admin" }}
      opcional
      onCancel={onCancel}
    />
  );

  await waitFor(() => {
    expect(screen.getByRole("button", { name: /Seguir sin abrir caja/i })).toBeInTheDocument();
  });
  fireEvent.click(screen.getByRole("button", { name: /Seguir sin abrir caja/i }));
  expect(onCancel).toHaveBeenCalled();
});
