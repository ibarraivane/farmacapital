import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import DestinationPicker from "./DestinationPicker";
import { fetchAddressSuggestions } from "../lib/addressSuggestClient";

jest.mock("../lib/addressSuggestClient", () => ({
  fetchAddressSuggestions: jest.fn(),
}));

test("elige un destino de la lista y lo fija, sin pedir 4 campos", async () => {
  fetchAddressSuggestions.mockResolvedValue({
    ok: true,
    suggestions: [
      {
        id: "1",
        label: "José Ignacio Bartolache 1750, Del Valle Sur, 03104, Ciudad de México",
        calle: "José Ignacio Bartolache 1750",
        colonia: "Del Valle Sur",
        cp: "03104",
        lat: 19.3846,
        lng: -99.1699,
      },
    ],
  });

  const onConfirm = jest.fn();
  render(
    <DestinationPicker
      calle=""
      onConfirm={onConfirm}
      inputStyle={{}}
    />
  );

  expect(screen.getByPlaceholderText(/bartolache 1750/i)).toBeInTheDocument();
  expect(screen.queryByText(/código postal/i)).not.toBeInTheDocument();
  expect(screen.queryByText(/número exterior/i)).not.toBeInTheDocument();

  fireEvent.change(screen.getByRole("combobox"), {
    target: { value: "Bartolache 1750 Del Valle" },
  });

  const option = await screen.findByRole("option");
  fireEvent.click(option);

  await waitFor(() => expect(onConfirm).toHaveBeenCalled());
  expect(onConfirm.mock.calls[0][0]).toMatchObject({
    calle: "José Ignacio Bartolache",
    numero: "1750",
    colonia: "Del Valle Sur",
    cp: "03104",
    lat: 19.3846,
  });
});

test("con destino ya elegido muestra tarjeta y Cambiar", () => {
  render(
    <DestinationPicker
      calle="José Ignacio Bartolache"
      numero="1750"
      colonia="Del Valle Sur"
      cp="03104"
      lat={19.38}
      lng={-99.17}
    />
  );
  expect(screen.getByText(/bartolache 1750/i)).toBeInTheDocument();
  expect(screen.getByRole("button", { name: /cambiar/i })).toBeInTheDocument();
  expect(screen.queryByRole("combobox")).not.toBeInTheDocument();
});
