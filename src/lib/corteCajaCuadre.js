/** Cuadre de cajón. El fondo ya incluye lo que había al abrir. */

export function round2(n) {
  return Math.round((Number(n) || 0) * 100) / 100;
}

/** Lo que debe haber en el cajón: fondo al abrir + movimientos desde que abrió. */
export function esperadoEnCajon(fondo, ventasDesdeApertura) {
  return round2((Number(fondo) || 0) + (Number(ventasDesdeApertura) || 0));
}

/**
 * Si el sistema arrastra ventas desde el corte anterior, esas piezas
 * ya iban en el fondo y se cuentan dos veces. Fabrican un faltante.
 */
export function cuadreSiArrastraCortePrevio({
  fondo,
  ventasDesdeApertura,
  ventasEntreCortes,
  contado,
}) {
  const desdeAbrio = round2(ventasDesdeApertura);
  const entre = round2(ventasEntreCortes);
  const sistemaMal = round2(desdeAbrio + entre);
  const esperadoMal = esperadoEnCajon(fondo, sistemaMal);
  const esperadoBien = esperadoEnCajon(fondo, desdeAbrio);
  const cont = round2(contado);
  return {
    sistemaMal,
    sistemaBien: desdeAbrio,
    esperadoMal,
    esperadoBien,
    diferenciaMal: round2(cont - esperadoMal),
    diferenciaBien: round2(cont - esperadoBien),
  };
}
