import {
  checkoutUserSuffix,
  checkoutAddressDraftKey,
  savedAddressesKey,
  loadSavedAddresses,
  upsertSavedAddress,
  deleteSavedAddress,
  savedAddressToDestino,
} from "./savedCheckoutAddresses";

describe("savedCheckoutAddresses", () => {
  beforeEach(() => {
    localStorage.clear();
  });

  test("clave distinta para cuenta e invitado", () => {
    expect(checkoutUserSuffix(null)).toBe("guest");
    expect(checkoutUserSuffix({ id: 9 })).toBe("9");
    expect(savedAddressesKey({ id: 9 })).toBe("farmacapital_saved_addresses_9");
    expect(checkoutAddressDraftKey({ telefono: "55 1234 5678" })).toBe(
      "farmacapital_checkout_address_5512345678"
    );
  });

  test("guarda con nombre y recupera", () => {
    const dest = {
      calle: "Av Insurgentes Sur",
      numero: "300",
      colonia: "Roma Norte",
      cp: "06700",
      lat: 19.41,
      lng: -99.16,
    };
    const { ok, entry } = upsertSavedAddress({ id: 3 }, { name: "Casa", dest, referencia: "Depto 4" });
    expect(ok).toBe(true);
    expect(entry.name).toBe("Casa");
    const list = loadSavedAddresses({ id: 3 });
    expect(list).toHaveLength(1);
    expect(list[0].colonia).toBe("Roma Norte");
    expect(savedAddressToDestino(list[0]).referencia).toBe("Depto 4");
    expect(loadSavedAddresses(null)).toEqual([]);
  });

  test("mismo lugar o mismo nombre reemplaza, no duplica", () => {
    const dest = { calle: "Av Insurgentes Sur", numero: "300", colonia: "Roma Norte", cp: "06700" };
    upsertSavedAddress(null, { name: "Casa", dest });
    upsertSavedAddress(null, { name: "Casa", dest: { ...dest, colonia: "Roma Norte" }, referencia: "Nuevo" });
    upsertSavedAddress(null, { name: "Trabajo", dest });
    const list = loadSavedAddresses(null);
    expect(list).toHaveLength(1);
    expect(list[0].name).toBe("Trabajo");
  });

  test("no guarda incompleta", () => {
    const r = upsertSavedAddress(null, {
      name: "Casa",
      dest: { calle: "Av X", numero: "", colonia: "", cp: "067" },
    });
    expect(r.ok).toBe(false);
    expect(loadSavedAddresses(null)).toEqual([]);
  });

  test("borra por id", () => {
    const { entry } = upsertSavedAddress(null, {
      name: "Oficina",
      dest: { calle: "Paseo de la Reforma", numero: "222", colonia: "Juárez", cp: "06600" },
    });
    expect(loadSavedAddresses(null)).toHaveLength(1);
    deleteSavedAddress(null, entry.id);
    expect(loadSavedAddresses(null)).toEqual([]);
  });
});
