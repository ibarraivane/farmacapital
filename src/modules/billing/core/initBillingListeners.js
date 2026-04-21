import { eventBus } from "../../../core/events/eventBus";
import { EVENTS } from "../../../core/events/types";
import { createCharge } from "./createCharge";

let attached = false;

export function initBillingListeners() {
  if (attached) return;
  attached = true;

  eventBus.on(EVENTS.CONSULTATION_COMPLETED, (data) => {
    console.log("Billing consulta:", data);

    // aquí se genera el cobro
    createCharge({
      type: "CONSULTA",
      amount: data.amount,
      reference: data.consultationId,
    });
  });

  eventBus.on(EVENTS.SALE_CREATED, (data) => {
    console.log("Billing venta:", data);

    createCharge({
      type: "VENTA",
      amount: data.total,
      reference: data.saleId,
    });
  });
}
