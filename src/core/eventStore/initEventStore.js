import { eventBus } from "../events/eventBus";
import { validateEvent } from "../events/validation/validateEvent";

let patched = false;

/**
 * Parchea eventBus.emit para validar eventos antes de propagarlos.
 *
 * La persistencia en `public.event_log` desde el navegador está **desactivada**:
 * el cliente anon/authenticated no debe depender de INSERT directo; si se necesita
 * telemetría persistente, debe hacerse con service_role / edge function / job.
 *
 * El bus en memoria (originalEmit) sigue funcionando para coordinación en UI.
 */
export function initEventStore() {
  if (patched) return;
  patched = true;

  const originalEmit = eventBus.emit.bind(eventBus);

  eventBus.emit = async (event, data) => {
    if (!validateEvent(event, data)) {
      console.error("Event rejected:", event, data);
      return;
    }

    return originalEmit(event, data);
  };
}
