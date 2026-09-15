/** Config Caso A/B encargo de medicamentos. Valores [CONFIGURABLE] del spec. */

import { TZ_FARMACIA } from "../lib/fecha";

/** Días de vigencia de una cotización enviada (America/Mexico_City). */
export const TIEMPO_VIGENCIA_COTIZACION_DIAS_DEFAULT = 3;

/** Clave en tabla public.configuracion. */
export const CONFIG_CLAVE_VIGENCIA_COTIZACION_DIAS = "tiempo_vigencia_cotizacion_dias";

export const ENCARGO_TZ = TZ_FARMACIA;

/** Teléfono siempre obligatorio — no configurable. */
export const REQUIERE_TELEFONO_OBLIGATORIO = true;

/**
 * Lee días de vigencia desde env (servidor/CRA) o default.
 * En runtime admin se puede sobreescribir con configuracion.clave.
 */
export function tiempoVigenciaCotizacionDiasFromEnv(env = process.env) {
  const raw =
    env.REACT_APP_TIEMPO_VIGENCIA_COTIZACION_DIAS ||
    env.TIEMPO_VIGENCIA_COTIZACION_DIAS ||
    "";
  const n = Number(String(raw).trim());
  if (Number.isFinite(n) && n >= 1 && n <= 30) return Math.round(n);
  return TIEMPO_VIGENCIA_COTIZACION_DIAS_DEFAULT;
}
