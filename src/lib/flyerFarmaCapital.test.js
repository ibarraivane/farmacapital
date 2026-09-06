import {
  flyerHomeUrl,
  flyerConseguirPath,
  flyerWhatsAppShareUrl,
  flyerShareCaption,
} from "./flyerFarmaCapital";

test("QR apunta a la home con UTM de flyer", () => {
  expect(flyerHomeUrl("https://www.farmacapital.mx")).toBe(
    "https://www.farmacapital.mx/?utm_source=flyer&utm_medium=whatsapp&utm_campaign=tarjeta",
  );
});

test("conseguir lleva la búsqueda", () => {
  expect(flyerConseguirPath("losartan 50")).toBe("/conseguir?q=losartan%2050");
  expect(flyerConseguirPath("")).toBe("/conseguir");
});

test("share de WhatsApp abre selector de contactos con la URL", () => {
  const url = flyerWhatsAppShareUrl("https://www.farmacapital.mx");
  expect(url.startsWith("https://wa.me/?text=")).toBe(true);
  expect(decodeURIComponent(url)).toContain("farmacapital.mx/?utm_source=flyer");
  expect(flyerShareCaption("https://www.farmacapital.mx")).toMatch(/te lo conseguimos/i);
});
