import { eventBus } from "../../core/events/eventBus";
import { EVENTS } from "../../core/events/types";

export function closeConsultation(data) {
  // lógica clínica

  eventBus.emit(EVENTS.CONSULTATION_COMPLETED, {
    patientId: data.patientId,
    amount: data.fee,
    consultationId: data.id,
  });
}
