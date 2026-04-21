import { EVENTS } from "../types";

export function validateEvent(event, payload) {
  if (!event || !payload) return false;

  const requiredFields = {
    [EVENTS.SALE_CREATED]: ["saleId", "total"],
    [EVENTS.CONSULTATION_COMPLETED]: ["consultationId", "amount"],
    [EVENTS.REFUND_REQUESTED]: ["refundId", "amount"],
  };

  const fields = requiredFields[event] || [];

  for (const f of fields) {
    if (payload[f] === undefined || payload[f] === null) {
      console.error(`Invalid event payload: missing ${f}`);
      return false;
    }
  }

  return true;
}
