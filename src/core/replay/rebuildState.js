import { supabase } from "../../supabase";
import { EVENTS } from "../events/types";

export async function rebuildState() {
  const { data: events } = await supabase
    .from("event_log")
    .select("*")
    .order("created_at", { ascending: true });

  const rows = events ?? [];

  const state = {
    sales: [],
    inventory: {},
    patients: {},
    balance: 0,
  };

  for (const ev of rows) {
    const p = ev.payload || {};

    switch (ev.type) {
      case EVENTS.SALE_CREATED:
        state.sales.push(p);
        state.balance += Number(p.total) || 0;
        break;

      case EVENTS.REFUND_REQUESTED:
        state.balance -= Number(p.amount) || 0;
        break;

      case EVENTS.CONSULTATION_COMPLETED:
        state.balance += Number(p.amount) || 0;
        break;

      case EVENTS.PAYMENT_PROCESSED:
        // opcional tracking
        break;

      default:
        break;
    }

    if (ev.type === EVENTS.SALE_CREATED) {
      (p.items || []).forEach((item) => {
        const id = item.id;
        const qty = Number(item.quantity) || 0;
        if (id == null) return;
        state.inventory[id] = (state.inventory[id] || 0) - qty;
      });
    }
  }

  return state;
}
