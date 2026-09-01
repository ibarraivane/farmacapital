import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import DestinationPicker from "./DestinationPicker";
import { fetchAddressSuggestions } from "../lib/addressSuggestClient";

jest.mock("../lib/addressSuggestClient", () => ({
  fetchAddressSuggestions: jest.fn(),
}));

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
  expect(screen.queryByText(/código postal/i)).not.toBeInTheDocument();

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

test("con destino ya elegido muestra tarjeta y Cambiar", () => {
  render(
    <DestinationPicker
      calle="Av Insurgentes Sur"
      numero="300"
      colonia="Roma Norte"
      cp="06700"
      lat={19.41}
      lng={-99.16}
    />
  );
  expect(screen.getByText(/insurgentes sur 300/i)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /cambiar/i })).toBeInTheDocument();
  expect(screen.queryByRole("combobox")).not.toBeInTheDocument();
});
