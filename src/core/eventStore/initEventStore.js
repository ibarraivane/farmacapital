import { supabase } from "../../supabase";
import { eventBus } from "../events/eventBus";
import { validateEvent } from "../events/validation/validateEvent";

let patched = false;

export function initEventStore() {
  if (patched) return;
  patched = true;

  const originalEmit = eventBus.emit.bind(eventBus);

  eventBus.emit = async (event, data) => {
    if (!validateEvent(event, data)) {
      console.error("Event rejected:", event, data);
      return;
    }

    try {
      await supabase.from("event_log").insert({
        type: event,
        payload: data,
        created_at: new Date().toISOString(),
      });

      return originalEmit(event, data);
    } catch (err) {
      console.error("Event store error:", err);

      return originalEmit(event, data);
    }
  };
}
