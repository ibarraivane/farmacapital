import {
  flyerHomeUrl,
  flyerConseguirPath,
  flyerWhatsAppShareUrl,
  flyerShareCaption,
  flyerMailtoShareUrl,
  flyerEmailBody,
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
  expect(flyerShareCaption("https://www.farmacapital.mx")).not.toMatch(/Iztapalapa/i);
});

test("correo lleva ligas reales, no botones de imagen", () => {
  const body = flyerEmailBody("https://www.farmacapital.mx");
  expect(body).toMatch(/Pedir en línea:/);
  expect(body).toMatch(/conseguir/);
  expect(body).not.toMatch(/Iztapalapa/i);
  expect(flyerMailtoShareUrl("https://www.farmacapital.mx")).toMatch(/^mailto:\?subject=/);
});
