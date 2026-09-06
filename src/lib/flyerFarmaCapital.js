/** Flyer digital FarmaCapital — URLs y copy para WhatsApp / QR. */

export const FLYER_SITE = "https://www.farmacapital.mx";

export function flyerHomeUrl(origin) {
  const base = String(origin || FLYER_SITE).replace(/\/+$/, "") || FLYER_SITE;
  return `${base}/?utm_source=flyer&utm_medium=whatsapp&utm_campaign=tarjeta`;
}

export function flyerTarjetaPath() {
  return "/tarjeta";
}

export function flyerConseguirPath(q) {
  const query = String(q || "").trim();
  return query ? `/conseguir?q=${encodeURIComponent(query)}` : "/conseguir";
}

export function flyerWhatsAppFarmaciaUrl(telefono = "5562530631") {
  const digits = String(telefono || "").replace(/\D/g, "").slice(-10);
  const msg =
    "Hola FarmaCapital, vi el flyer y quiero pedir. " +
    "Si no está en el catálogo, ¿me lo pueden conseguir?";
  return `https://wa.me/52${digits}?text=${encodeURIComponent(msg)}`;
}

export function flyerShareCaption(origin) {
  const url = flyerHomeUrl(origin);
  return (
    "FarmaCapital — tu farmacia en Iztapalapa.\n" +
    "Entra, busca lo que necesitas y compra en línea. " +
    "Si no está, te lo conseguimos a domicilio (el envío tiene costo).\n\n" +
    url
  );
}

/** Abre el selector de contactos de WhatsApp (no un número fijo). */
export function flyerWhatsAppShareUrl(origin) {
  return `https://wa.me/?text=${encodeURIComponent(flyerShareCaption(origin))}`;
}
