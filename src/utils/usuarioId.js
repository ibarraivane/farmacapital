import { supabase } from "../supabase";

/** Valor ya es `usuarios.id` (bigint en JS como number o string de dígitos). */
export function parseUsuariosBigintId(value) {
  if (value == null) return null;
  if (typeof value === "number" && Number.isFinite(value)) return value;
  const s = String(value);
  if (/^\d+$/.test(s)) return parseInt(s, 10);
  return null;
}

/**
 * Resuelve el id numérico de `public.usuarios` para RPC/columnas bigint.
 * Tras login con Supabase Auth, `usuario.id` en sesión es UUID; `atendido_por` y
 * `create_sale_transaction_v2(p_user_id)` esperan bigint.
 */
export async function idEmpleadoUsuarios(usuario) {
  if (!usuario?.id) return null;
  const parsed = parseUsuariosBigintId(usuario.id);
  if (parsed != null) return parsed;
  const email = (usuario.email || "").trim().toLowerCase();
  if (!email) return null;
  const { data, error } = await supabase.from("usuarios").select("id").eq("email", email).maybeSingle();
  if (error) console.warn("[Farmax] idEmpleadoUsuarios:", error.message);
  return data?.id ?? null;
}
