import { supabase } from "../../supabase";
import { buildSalesModel } from "./salesModel";

/**
 * Reconstruye `sales_read_model` borrando e insertando agregados por fecha.
 *
 * **No debe ejecutarse en el navegador en producción**: las políticas F6a suelen
 * prohibir DELETE/INSERT directo; además el read model debe alimentarse con
 * service_role, cron o RPC admin. Mantener este módulo solo para utilidades
 * locales / scripts si se invoca con `__allowInBrowser: true` en desarrollo.
 */
export async function syncSalesModel(opts = {}) {
  if (
    typeof window !== "undefined" &&
    process.env.NODE_ENV === "production" &&
    !opts.__allowInBrowser
  ) {
    return;
  }

  const model = await buildSalesModel();

  const { error: delErr } = await supabase.from("sales_read_model").delete().not("id", "is", null);
  if (delErr) throw delErr;

  const rows = Object.keys(model).map((date) => ({
    date,
    total: model[date].total,
    count: model[date].count,
  }));

  if (rows.length === 0) return;

  const { error: insErr } = await supabase.from("sales_read_model").insert(rows);
  if (insErr) throw insErr;
}
