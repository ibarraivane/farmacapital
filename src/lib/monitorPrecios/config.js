/**
 * Monitor de precios de referencia — configuración.
 *
 * REGLA DE ORO: ningún modelo genera, estima ni recuerda precios.
 * El job diario rastrea catálogos públicos y escribe las columnas de Referencias.
 * Exprezo no tiene catálogo público: se actualiza importando la lista.
 *
 * Márgenes de ESTE monitor (piso sobre costo). No toca pricing_rules.
 *   patente 12 % · genérico 25 % · OTC 30 %
 *
 * Variables de entorno (solo servidor, nunca en el cliente):
 *   ANTHROPIC_API_KEY          — emparejador (import CSV), opcional
 *   ANTHROPIC_MODEL            — default claude-sonnet-4-20250514
 *   PROFECO_QQP_CSV_URL        — URL del CSV oficial de datos.profeco.gob.mx
 *   PROFECO_QQP_CIUDAD         — filtro opcional (ej. "Ciudad de México")
 *   DATOS_GOB_PATENTE_CSV_URL  — CSV del catálogo de datos abiertos (opcional)
 *   CRON_SECRET                — job /api/monitor-precios/job
 */

"use strict";

const MONITOR_PRECIOS_CONFIG = {
  dias_vigencia: 30,
  umbral_anomalia: 0.4,
  umbral_sugerencia_pct: 0.05,
  umbral_sugerencia_pesos: 10,
  factor_posicionamiento: {
    patente: 0.98,
    generico: 0.98,
    otc: 0.98,
    default: 0.98,
  },
  margen_minimo: {
    patente: 0.12,
    generico: 0.25,
    otc: 0.3,
    default: 0.25,
  },
  emparejador: {
    top_candidatos: 5,
    auto: 0.85,
    verificar: 0.6,
    max_llamadas_por_corrida: 40,
  },
  fuentes_venta: ["fahorro", "similares", "otros_venta", "profeco_qqp", "datos_gob_patente"],
  fuentes_compra: ["abarrotero", "scorpion", "mayoreototal", "lista_distribuidor"],
};

module.exports = { MONITOR_PRECIOS_CONFIG };
