import { useEffect, useState } from "react";
import { rebuildState } from "../../../core/replay/rebuildState";

export default function ReplayDashboard() {
  const [state, setState] = useState(null);

  useEffect(() => {
    rebuildState()
      .then(setState)
      .catch((err) => {
        console.error("[ReplayDashboard]", err);
        setState(null);
      });
  }, []);

  return (
    <div>
      <h2>System Replay</h2>

      <pre>
        {JSON.stringify(state, null, 2)}
      </pre>
    </div>
  );
}
