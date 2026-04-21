import { supabase } from "../../supabase";
import { buildSalesModel } from "./salesModel";

export async function syncSalesModel() {
  const model = await buildSalesModel();

  // Borra todas las filas (válido con id uuid o numérico).
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
