import { supabase } from "../supabase";
import { CLAVE_SERVICIOS_RECARGOS, CLAVES_SALDO_MP } from "./pagoServicio";

/** Recargos de recibos + saldo MP. Supabase no deja leer esas claves con la llave pública
 *  (RLS de `configuracion`), así que se leen por el API con service role. */
export async function leerConfigServicios() {
  const tok = sessionStorage.getItem("farmacapital_session_token");
  if (tok) {
    try {
      const resp = await fetch("/api/inventarioProcesarPdf?type=pago-servicio", {
        method: "POST",
        headers: { "Content-Type": "application/json", "x-session-token": tok },
        body: JSON.stringify({ session_token: tok, action: "config" }),
      });
      const data = await resp.json().catch(() => ({}));
      if (resp.ok && data?.ok && Array.isArray(data.rows)) return data.rows;
    } catch (e) {
      console.error(e);
    }
  }
  const { data, error } = await supabase
    .from("configuracion")
    .select("clave,valor")
    .in("clave", [...CLAVES_SALDO_MP, CLAVE_SERVICIOS_RECARGOS]);
  if (error) throw error;
  return Array.isArray(data) ? data : [];
}
