import { supabase } from "../../supabase";
import { EVENTS } from "../events/types";
import { ymdMexico } from "../../lib/fecha";

export async function buildSalesProjection() {
  const { data: events } = await supabase
    .from("event_log")
    .select("*")
    .eq("type", EVENTS.SALE_CREATED);

  const rows = events ?? [];

  const summary = rows.reduce((acc, ev) => {
    const date = ymdMexico(ev.created_at);

    acc[date] = acc[date] || { total: 0, count: 0 };
    acc[date].total += ev.payload?.total || 0;
    acc[date].count += 1;

    return acc;
  }, {});

  return summary;
}
