/**
 * Reglas del motor de descuento por caducidad.
 * Todos los umbrales viven aquí; el código de cálculo no incrusta números.
 */
"use strict";

const CADUCIDAD_CONFIG = {
  FACTOR_SEGURIDAD: 0.8,
  DIAS_EVALUACION: 21,
  UMBRAL_SELLTHROUGH: 0.3,
  DIAS_SILENCIO: 14,
  canje_ventana_dias: 180,
  rotacion_dias: 90,
  fases: {
    1: { min_dias: 90, max_dias: 120, descuento: 0.1, perdida_maxima: 0 },
    2: { min_dias: 60, max_dias: 90, descuento: 0.2, perdida_maxima: 0 },
    3: { min_dias: 30, max_dias: 60, descuento: 0.35, perdida_maxima: 0.15 },
    4: { min_dias: 7, max_dias: 30, descuento: 0.5, perdida_maxima: 0.35 },
    5: { min_dias: 0, max_dias: 7, descuento: 0.6, perdida_maxima: 0.6 },
  },
};

module.exports = { CADUCIDAD_CONFIG };
