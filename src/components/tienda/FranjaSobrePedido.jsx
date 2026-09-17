import { useState } from "react";
import { X } from "lucide-react";
import { BRAND } from "../../constants";
import { FRANJA_HOME } from "../../lib/bajoPedido";

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
    <div
      style={{
        background: BRAND.primary,
        color: "#fff",
        padding: "8px 16px",
      }}
    >
      <div style={{ maxWidth: 1200, margin: "0 auto", display: "flex", alignItems: "center", gap: 10, fontSize: 13 }}>
        <span style={{ flex: 1, fontWeight: 600, lineHeight: 1.4 }}>{FRANJA_HOME}</span>
        <button
          type="button"
          onClick={() => setPage("pedidos-especiales")}
          style={{
            background: "rgba(255,255,255,.16)",
            border: "1px solid rgba(255,255,255,.28)",
            color: "#fff",
            fontWeight: 700,
            fontSize: 12,
            borderRadius: 999,
            padding: "6px 12px",
            cursor: "pointer",
            fontFamily: "inherit",
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
            color: "#fff",
            cursor: "pointer",
            padding: 4,
            display: "grid",
            placeItems: "center",
          }}
        >
          <X size={16} aria-hidden />
        </button>
      </div>
    </div>
  );
}
