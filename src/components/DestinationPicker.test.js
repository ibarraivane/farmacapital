import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import DestinationPicker from "./DestinationPicker";
import { fetchAddressSuggestions } from "../lib/addressSuggestClient";
import { fetchColoniasByCp } from "../lib/sepomexColoniasClient";

jest.mock("../lib/addressSuggestClient", () => ({
  fetchAddressSuggestions: jest.fn(),
}));

jest.mock("../lib/sepomexColoniasClient", () => ({
  fetchColoniasByCp: jest.fn(),
}));

beforeEach(() => {
  localStorage.clear();
  fetchAddressSuggestions.mockResolvedValue({ ok: true, suggestions: [] });
  fetchColoniasByCp.mockResolvedValue({ ok: true, cp: "06700", colonias: ["Roma Norte"] });
});

test("usa lo escrito aunque el mapa traiga otra calle", async () => {
  fetchAddressSuggestions.mockResolvedValue({
    ok: true,
    suggestions: [
      {
        id: "cerrada",
        label: "Cerrada Doctor José Ignacio, 03100, Mexico City",
        calle: "Cerrada Doctor José Ignacio",
        colonia: "",
        cp: "03100",
        lat: 19.38,
        lng: -99.17,
      },
    ],
  });

  const onConfirm = jest.fn();
  render(<DestinationPicker calle="" onConfirm={onConfirm} inputStyle={{}} />);

  expect(screen.getByPlaceholderText(/insurgentes/i)).toBeInTheDocument();
  expect(screen.queryByLabelText(/código postal/i)).not.toBeInTheDocument();

  fireEvent.change(screen.getByRole("combobox"), {
    target: { value: "Av Insurgentes Sur 300 roma norte 06700" },
  });

  const usar = await screen.findByText(/usar esta dirección/i);
  fireEvent.click(usar.closest("button"));

  await waitFor(() => expect(onConfirm).toHaveBeenCalled());
  expect(onConfirm.mock.calls[0][0]).toMatchObject({
    calle: "Av Insurgentes Sur",
    numero: "300",
    colonia: "Roma norte",
    cp: "06700",
    lat: null,
    lng: null,
  });
});

test("con destino ya elegido muestra tarjeta, CP editable y colonia del CP", async () => {
  const onColoniaChange = jest.fn();
  render(
    <DestinationPicker
      calle="Av Insurgentes Sur"
      numero="300"
      colonia=""
      cp="06700"
      lat={19.41}
      lng={-99.16}
      onColoniaChange={onColoniaChange}
    />
  );
  expect(screen.getByText(/insurgentes sur 300/i)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /cambiar/i })).toBeInTheDocument();
  expect(screen.queryByPlaceholderText(/insurgentes/i)).not.toBeInTheDocument();
  expect(screen.getByLabelText(/código postal/i)).toHaveValue("06700");
  const colonia = await waitFor(() => {
    const el = screen.getByLabelText(/^colonia$/i);
    expect(el.tagName).toBe("SELECT");
    return el;
  });
  expect(colonia).toBeInTheDocument();
  await waitFor(() => expect(onColoniaChange).toHaveBeenCalledWith("Roma Norte"));
  expect(screen.getByText(/revisa código postal y colonia/i)).toBeInTheDocument();
});

test("destino completo dice Destino listo y permite guardar con nombre", async () => {
  const { rerender } = render(
    <DestinationPicker
      calle="Av Insurgentes Sur"
      numero="300"
      colonia="Roma Norte"
      cp="06700"
    />
  );
  expect(await screen.findByText(/destino listo/i)).toBeInTheDocument();
  expect(screen.getByLabelText(/nombre de la dirección/i)).toBeInTheDocument();

  fireEvent.change(screen.getByLabelText(/nombre de la dirección/i), {
    target: { value: "Casa" },
  });
  fireEvent.click(screen.getByRole("button", { name: /^guardar$/i }));
  expect(await screen.findByText(/guardada como/i)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /^casa$/i })).toBeInTheDocument();

  rerender(<DestinationPicker calle="" onConfirm={jest.fn()} />);
  expect(screen.getByRole("button", { name: /^casa$/i })).toBeInTheDocument();
});

test("chip de dirección guardada aplica calle, colonia y CP", () => {
  localStorage.setItem(
    "farmacapital_saved_addresses_guest",
    JSON.stringify([
      {
        id: "addr_1",
        name: "Trabajo",
        calle: "Paseo de la Reforma",
        numero: "222",
        colonia: "Juárez",
        cp: "06600",
      },
    ])
  );
  const onConfirm = jest.fn();
  render(<DestinationPicker calle="" onConfirm={onConfirm} />);
  fireEvent.click(screen.getByRole("button", { name: /^trabajo$/i }));
  expect(onConfirm).toHaveBeenCalledWith(
    expect.objectContaining({
      calle: "Paseo de la Reforma",
      numero: "222",
      colonia: "Juárez",
      cp: "06600",
    })
  );
});
