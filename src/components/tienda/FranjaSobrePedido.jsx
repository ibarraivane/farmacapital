import { useState } from "react";
import { X } from "lucide-react";
import { FRANJA_HOME } from "../../lib/bajoPedido";
import { V } from "./vitrinaUi";

const STORAGE_KEY = "farmacapital_franja_sobre_pedido_cerrada";

export default function FranjaSobrePedido({ setPage }) {
  const [visible, setVisible] = useState(() => {
    try {
      return window.localStorage.getItem(STORAGE_KEY) !== "1";
    } catch {
      return true;
    }
  });

  if (!visible) return null;

  const cerrar = () => {
    try {
      window.localStorage.setItem(STORAGE_KEY, "1");
    } catch {
      /* ignore */
    }
    setVisible(false);
  };

  return (
    <div style={{ background: V.ink, color: V.surface, padding: "9px 16px" }}>
      <div
        style={{
          maxWidth: 1120,
          margin: "0 auto",
          display: "flex",
          alignItems: "center",
          gap: 12,
          fontSize: 13,
        }}
      >
        <span style={{ flex: 1, fontWeight: 500, lineHeight: 1.4, letterSpacing: "0.01em" }}>{FRANJA_HOME}</span>
        <button
          type="button"
          onClick={() => setPage("pedidos-especiales")}
          style={{
            background: "transparent",
            border: `1px solid rgba(251,250,248,.35)`,
            color: V.surface,
            fontWeight: 600,
            fontSize: 12,
            borderRadius: V.pill,
            padding: "6px 12px",
            cursor: "pointer",
            fontFamily: V.body,
            whiteSpace: "nowrap",
          }}
        >
          Pedidos especiales
        </button>
        <button
          type="button"
          onClick={cerrar}
          aria-label="Cerrar aviso"
          style={{
            background: "none",
            border: "none",
            color: V.surface,
            cursor: "pointer",
            padding: 4,
            display: "grid",
            placeItems: "center",
            opacity: 0.7,
          }}
        >
          <X size={16} aria-hidden />
        </button>
      </div>
    </div>
  );
}
