import {
  validarSolicitudTienda,
  normalizarTelefonoPedido,
  buildSolicitudWhatsAppCliente,
} from "./solicitudTienda";

test("exige nombre, teléfono 10 dígitos y texto", () => {
  expect(validarSolicitudTienda({ texto: "a", nombre: "Ana", telefono: "5512345678", cantidad: 1 }).ok).toBe(false);
  const ok = validarSolicitudTienda({
    texto: "Losartan 50 mg",
    nombre: "Ana Pérez",
    telefono: "55 1234 5678",
    cantidad: 2,
  });
  expect(ok.ok).toBe(true);
  expect(ok.value.cliente_telefono).toBe("5512345678");
  expect(ok.value.cantidad).toBe(2);
});

test("normaliza teléfono a 10 dígitos", () => {
  expect(normalizarTelefonoPedido("5215512345678")).toBe("5512345678");
});

test("arma wa.me al cliente para cotizar", () => {
  const url = buildSolicitudWhatsAppCliente({
    telefono: "5512345678",
    texto: "Losartan",
    nombre: "Ana",
  });
  expect(url).toMatch(/^https:\/\/wa\.me\/525512345678\?text=/);
  expect(decodeURIComponent(url)).toMatch(/Losartan/);
});
