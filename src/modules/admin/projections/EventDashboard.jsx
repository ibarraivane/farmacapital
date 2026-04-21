import { useEffect, useState } from "react";
import { supabase } from "../../../supabase";

export default function EventDashboard() {
  const [events, setEvents] = useState([]);

  useEffect(() => {
    supabase
      .from("event_log")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(50)
      .then(({ data, error }) => {
        if (error) console.error("[EventDashboard]", error);
        setEvents(data ?? []);
      });
  }, []);

  return (
    <div>
      <h2>Event Log</h2>
      {events?.map((e) => (
        <div key={e.id}>
          {e.type} - {JSON.stringify(e.payload)}
        </div>
      ))}
    </div>
  );
}
