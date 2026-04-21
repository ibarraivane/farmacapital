import { supabase } from "../../supabase";
import { EVENTS } from "../events/types";

export async function buildInventoryProjection() {
  const { data: sales } = await supabase
    .from("event_log")
    .select("*")
    .eq("type", EVENTS.SALE_CREATED);

  const rows = sales ?? [];
  const stock = {};

  rows.forEach((ev) => {
    (ev.payload?.items || []).forEach((item) => {
      const id = item.id;
      const qty = item.quantity ?? 0;
      if (id == null) return;
      stock[id] = (stock[id] || 0) - qty;
    });
  });

  return stock;
}
