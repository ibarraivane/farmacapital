/**
 * Impresoras físicas del local. El navegador no puede forzar el dispositivo
 * (Chrome usa la última / la predeterminada), pero el sistema sí distingue
 * formatos: ticket 80 mm vs receta carta.
 *
 * Ticket  → Epson TM-T20 (térmica 80 mm)
 * Receta → Brother DCP-L2660DW (láser, hoja carta, una cara)
 */

export const IMPRESORA_TICKET = {
  uso: "ticket",
  marca: "Epson",
  modelo: "TM-T20",
  papel: "80mm",
  duplex: false,
};

export const IMPRESORA_RECETA = {
  uso: "receta",
  marca: "Brother",
  modelo: "DCP-L2660DW",
  /** México: hoja carta. No A4. */
  papel: "letter",
  papelLabel: "Carta (Letter)",
  /** La Brother tiene dúplex; la receta va en una sola cara (firma y sello). */
  duplex: false,
};

export const LEYENDA_IMPRESORA_RECETA =
  "Brother DCP-L2660DW · hoja carta · una cara. No uses la Epson térmica.";

export const LEYENDA_DIALOGO_RECETA =
  "En el diálogo: impresora Brother DCP-L2660DW, tamaño Carta / Letter, una cara (sin dúplex). Márgenes predeterminados. No «Ajustar a la página».";

const RE_TERMICA = /epson|tm-t20|tm-t88|thermal|receipt|t[eé]rmica|pos-80|xp-80/i;
const RE_LASER_RECETA = /brother|dcp-l2660|l2660dw|dcp-l26|hl-l2|laser|l[aá]ser/i;

export function esImpresoraTermica(nombre) {
  return RE_TERMICA.test(String(nombre || ""));
}

export function esImpresoraLaserReceta(nombre) {
  return RE_LASER_RECETA.test(String(nombre || ""));
}

/** Primera térmica. Nunca la Brother: un ticket en láser gasta hoja carta. */
export function elegirImpresoraTermica(impresoras = []) {
  const lista = Array.isArray(impresoras) ? impresoras.map(String) : [];
  return lista.find((p) => esImpresoraTermica(p) && !esImpresoraLaserReceta(p)) || null;
}

/** Primera Brother / láser. Nunca la Epson. */
export function elegirImpresoraReceta(impresoras = []) {
  const lista = Array.isArray(impresoras) ? impresoras.map(String) : [];
  return lista.find((p) => esImpresoraLaserReceta(p) && !esImpresoraTermica(p)) || null;
}
