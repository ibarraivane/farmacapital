import { useEffect, useState } from "react";
import { cronometroPedidoOnline } from "../utils/pedidoOnlineTimer";

const TONE = {
  ok: { bg: "#dcfce7", col: "#15803d" },
  warn: { bg: "#fef3c7", col: "#b45309" },
  late: { bg: "#fee2e2", col: "#b91c1c" },
};

export default function CronometroPedidoOnline({ pedido }) {
  const [now, setNow] = useState(() => Date.now());
  const t = cronometroPedidoOnline(pedido, now);

  useEffect(() => {
    if (!t.running) return undefined;
    const id = setInterval(() => setNow(Date.now()), 30000);
    return () => clearInterval(id);
  }, [t.running]);

  const pal = TONE[t.tone] || TONE.ok;
  return (
    <span
      title={t.enviado ? "Tiempo desde que pidieron hasta que salió" : "Tiempo desde que pidieron, hasta que salga el envío"}
      style={{
        display: "inline-block",
        padding: "2px 8px",
        borderRadius: 20,
        background: pal.bg,
        color: pal.col,
        fontWeight: 800,
        fontSize: 11,
        fontVariantNumeric: "tabular-nums",
      }}
    >
      ⏱ {t.label}
    </span>
  );
}
