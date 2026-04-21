import { supabase } from "../../supabase";
import { EVENTS } from "../events/types";

export async function buildLedger() {
  const { data: events } = await supabase
    .from("event_log")
    .select("*")
    .in("type", [
      EVENTS.SALE_CREATED,
      EVENTS.PAYMENT_PROCESSED,
      EVENTS.CONSULTATION_COMPLETED,
      EVENTS.REFUND_REQUESTED,
    ]);

  const rows = events ?? [];
  const ledger = [];
  // PAYMENT_PROCESSED: añadir entrada cuando el payload y el flujo estén definidos.

  for (const ev of rows) {
    const p = ev.payload || {};

    if (ev.type === EVENTS.SALE_CREATED) {
      ledger.push({
        type: "INCOME",
        source: "SALE",
        amount: p.total,
        ref: p.saleId,
        date: ev.created_at,
      });
    }

    if (ev.type === EVENTS.CONSULTATION_COMPLETED) {
      ledger.push({
        type: "INCOME",
        source: "CONSULTATION",
        amount: p.amount,
        ref: p.consultationId,
        date: ev.created_at,
      });
    }

    if (ev.type === EVENTS.REFUND_REQUESTED) {
      ledger.push({
        type: "EXPENSE",
        source: "REFUND",
        amount: p.amount,
        ref: p.refundId,
        date: ev.created_at,
      });
    }
  }

  return ledger;
}
