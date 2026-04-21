import { useEffect, useState } from "react";
import { buildLedger } from "../../../core/ledger/buildLedger";

export default function LedgerView() {
  const [ledger, setLedger] = useState([]);

  useEffect(() => {
    buildLedger()
      .then(setLedger)
      .catch((err) => {
        console.error("[LedgerView]", err);
        setLedger([]);
      });
  }, []);

  return (
    <div>
      <h2>Ledger Financiero</h2>

      {ledger.map((l, i) => (
        <div key={l.ref != null ? String(l.ref) : `${l.date}-${i}`}>
          {l.type} | {l.source} | ${l.amount ?? "—"}
        </div>
      ))}
    </div>
  );
}
