/**
 * Un mismo producto con dos códigos (pieza vs bote, bote vs OCR del ticket).
 * Lo usan POS y Recibir. Sin React ni utils/: el check de tablet lo importa.
 */
export const EAN_PARES_CONOCIDOS = [
  ["747589705123", "714706903205"], // Broncolin paleta suelta / vitrolero C/50
  ["7501868900233", "7501868990023"], // Dibar rojo 500 ml (bote) / ticket OCR 112558
  // Teatrical 19 g: ticket Farmalive 12 dígitos (se come un 0) ↔ caja 13.
  ["650240079009", "6502400079009", "6502400070009"],
  ["650240078996", "6502400078996"],
  // Palmolive Optims Extra Suavidad 250 ml. El ticket F-42 84416 la partió en dos SKU.
  ["7509546695570", "7509546695587"],
  // Tena Pants Maxi → Maxi Protect Proskin (Essity relanzó con EAN nuevo).
  // Ticket/catálogo viejo ↔ caja 2026. Folio Farmalive 310545 (Cyntia).
  ["7501019051159", "750101905115", "7501019064432"], // CH/M C/13
  ["7501019051166", "750101905116", "7501019064449"], // Grande C/13
];
