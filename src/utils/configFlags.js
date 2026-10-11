/**
 * Interruptores de `configuracion`: la tabla guarda texto, no booleanos.
 *
 * Quien captura puede escribir "1", "true", "sí" o dejar la casilla en "0".
 * Falta la clave = apagado, nunca encendido por accidente.
 */

const VERDADEROS = new Set(["1", "true", "si", "sí", "on", "yes"]);

/** true solo si el valor dice explícitamente que sí. */
export function flagActiva(valor) {
  return VERDADEROS.has(String(valor ?? "").trim().toLowerCase());
}

/** Lee una clave de un mapa de configuración y la interpreta como interruptor. */
export function configFlagActiva(map, clave) {
  return flagActiva(map?.[clave]);
}
