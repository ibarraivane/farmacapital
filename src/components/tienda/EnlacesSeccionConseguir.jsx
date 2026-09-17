import { ChevronRight, Leaf, Sparkles } from "lucide-react";
import { BRAND } from "../../constants";
import { SECCIONES_CONSEGUIR, filtrarSeccion } from "../../lib/bajoPedido";

const ICONO = {
  dermatologia: Sparkles,
  nutricion: Leaf,
};

/**
 * Dos tarjetas: Dermocosmética · Vitaminas y suplementos.
 */
export default function EnlacesSeccionConseguir({ setPage, productos = [], stack = false }) {
  return (
    <div
      style={{
        display: "grid",
        gridTemplateColumns: stack ? "1fr" : "1fr 1fr",
        gap: 12,
      }}
    >
      {SECCIONES_CONSEGUIR.map((sec) => {
        const Icon = ICONO[sec.id] || Sparkles;
        const n = filtrarSeccion(productos, sec.id, { incluirAnaquel: false }).length;
        const derma = sec.id === "dermatologia";
        const tint = derma ? BRAND.accent : BRAND.secondary;
        return (
          <button
            key={sec.id}
            type="button"
            onClick={() => setPage(sec.page, { search: "" })}
            style={{
              display: "flex",
              alignItems: "flex-start",
              gap: 12,
              textAlign: "left",
              padding: "16px 16px 14px",
              borderRadius: 16,
              border: `1px solid ${derma ? "#c7ebd6" : "#cdd9f5"}`,
              background: derma
                ? "linear-gradient(180deg,#f3fbf6,#fff)"
                : "linear-gradient(180deg,#f3f6fd,#fff)",
              cursor: "pointer",
              fontFamily: "inherit",
              minHeight: 112,
              boxShadow: "0 8px 24px rgba(15,23,42,.06)",
            }}
          >
            <div
              style={{
                width: 44,
                height: 44,
                borderRadius: 12,
                background: `${tint}18`,
                color: tint,
                display: "grid",
                placeItems: "center",
                flexShrink: 0,
              }}
            >
              <Icon size={22} aria-hidden />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 6, color: "#0f172a", fontWeight: 800, fontSize: 16 }}>
                {sec.label}
                <ChevronRight size={16} aria-hidden />
              </div>
              <p style={{ margin: "6px 0 0", color: "#475569", fontSize: 13, lineHeight: 1.45 }}>
                {sec.desc}
              </p>
              {n > 0 ? (
                <div style={{ marginTop: 8, color: tint, fontWeight: 700, fontSize: 12 }}>
                  {n} {n === 1 ? "producto" : "productos"} · 24-48 h
                </div>
              ) : (
                <div style={{ marginTop: 8, color: "#64748b", fontWeight: 600, fontSize: 12 }}>
                  Sobre pedido · 24-48 h
                </div>
              )}
            </div>
          </button>
        );
      })}
    </div>
  );
}
