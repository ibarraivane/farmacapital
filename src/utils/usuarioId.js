/** Valor ya es `usuarios.id` (bigint en JS como number o string de dígitos). */
export function parseUsuariosBigintId(value) {
  if (value == null) return null;
  if (typeof value === "number" && Number.isFinite(value)) return value;
  const s = String(value);
  if (/^\d+$/.test(s)) return parseInt(s, 10);
  return null;
}

/**
 * Resuelve el id numérico de `public.usuarios`.
 * En el flujo con session tokens custom (F6), `usuario.id` ya es bigint
 * nativamente — este helper solo parsea. El fallback vía email fue
 * removido porque requería SELECT directo a `usuarios` (revocado en F6a 2/4);
 * cualquier consumidor nuevo debe obtener el id desde el objeto de sesión.
 */
export async function idEmpleadoUsuarios(usuario) {
  if (!usuario?.id) return null;
  return parseUsuariosBigintId(usuario.id);
}
