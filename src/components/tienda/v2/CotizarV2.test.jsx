import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import CotizarV2, { folioCotizacion, notasCotizacion } from "./CotizarV2";

function llenar({ tel = "5512345678" } = {}) {
  fireEvent.change(screen.getByLabelText(/Medicamento o sustancia activa/i), { target: { value: "Pirfenidona 600 mg" } });
  fireEvent.change(screen.getByLabelText(/^Presentación$/i), { target: { value: "1 caja" } });
  fireEvent.change(screen.getByLabelText(/Tu nombre/i), { target: { value: "Iván Ibarra" } });
  fireEvent.change(screen.getByLabelText(/WhatsApp/i), { target: { value: tel } });
}

test("arma folio y notas sin datos de receta", () => {
  expect(folioCotizacion(142)).toBe("COT-0142");
  expect(folioCotizacion(null)).toBe("");
  const notas = notasCotizacion({ presentacion: "150 mg", entrega: "envio" });
  expect(notas).toMatch(/Presentación: 150 mg/);
  expect(notas).toMatch(/Entrega: Envío en CDMX/);
});

test("el botón se activa solo con el consentimiento", () => {
  render(<CotizarV2 setPage={() => {}} />);
  const enviar = screen.getByRole("button", { name: /Enviar solicitud/i });
  expect(enviar).toBeDisabled();
  fireEvent.click(screen.getByRole("checkbox"));
  expect(enviar).not.toBeDisabled();
});

test("envía la solicitud y muestra el folio", async () => {
  global.fetch = jest.fn().mockResolvedValue({ ok: true, json: async () => ({ ok: true, id: 142 }) });
  render(<CotizarV2 setPage={() => {}} />);
  llenar();
  fireEvent.click(screen.getByRole("checkbox"));
  fireEvent.click(screen.getByRole("button", { name: /Enviar solicitud/i }));

  await waitFor(() => expect(screen.getByText("Recibimos tu solicitud.")).toBeInTheDocument());
  expect(screen.getByText("COT-0142")).toBeInTheDocument();
  expect(screen.getByText("Cotizando")).toBeInTheDocument();

  const [url, opts] = global.fetch.mock.calls[0];
  expect(url).toBe("/api/solicitudes");
  const body = JSON.parse(opts.body);
  expect(body.texto).toBe("Pirfenidona 600 mg");
  expect(body.cliente_telefono).toBe("5512345678");
  expect(body.notas).toMatch(/Presentación: 1 caja/);
});

test("avisa cuando el teléfono no sirve y no manda nada", async () => {
  global.fetch = jest.fn();
  render(<CotizarV2 setPage={() => {}} />);
  llenar({ tel: "123" });
  fireEvent.click(screen.getByRole("checkbox"));
  fireEvent.click(screen.getByRole("button", { name: /Enviar solicitud/i }));
  await waitFor(() => expect(screen.getByRole("alert")).toHaveTextContent(/10 dígitos/i));
  expect(global.fetch).not.toHaveBeenCalled();
});
