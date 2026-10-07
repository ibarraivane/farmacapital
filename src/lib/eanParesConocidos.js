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
  // Troferit 30 mg C/15: caja Chinoín 7501088575495 · ticket Cityfarma S329263 tipografió 76495 (checksum inválido).
  ["7501088575495", "7501088576495"],
  // Schick Xtreme 3 Piel Sensible bolsa/display ×12: ticket Zorro 7502274881475 · empaque Edgewell 6937266702079.
  // No mezclar con pieza suelta 7591066701015.
  ["7502274881475", "6937266702079"],
];
