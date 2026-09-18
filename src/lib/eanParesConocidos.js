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
];
