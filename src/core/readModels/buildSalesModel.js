import { supabase } from "../../supabase";
import { EVENTS } from "../events/types";
import { ymdMexico } from "../../lib/fecha";

export async function buildSalesModel() {
  const { data } = await supabase
    .from("event_log")
    .select("*")
    .eq("type", EVENTS.SALE_CREATED);

  const rows = data ?? [];
  const model = {};

  for (const ev of rows) {
    const date = ymdMexico(ev.created_at);
    const total = Number(ev.payload?.total) || 0;

    if (!model[date]) {
      model[date] = {
        total: 0,
        count: 0,
      };
    }

    model[date].total += total;
    model[date].count += 1;
  }

  return model;
}
