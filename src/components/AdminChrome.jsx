import { RefreshCw } from "lucide-react";
import { C_LIGHT } from "../constants";

const C = C_LIGHT;

/** Título de módulo admin: Lucide + texto, sin emoji. */
export function PageHero({ Icon, children, sub, size = 20, style }) {
  return (
    <div style={style}>
      <h1
        className="fc-page-hero"
        style={{
          margin: 0,
          color: C.text,
          fontSize: size,
          fontWeight: 800,
          display: "inline-flex",
          alignItems: "center",
          gap: 8,
          lineHeight: 1.2,
        }}
      >
        {Icon ? <Icon size={Math.round(size * 0.95)} strokeWidth={2} aria-hidden /> : null}
        {children}
      </h1>
      {sub ? <p style={{ margin: "4px 0 0", color: C.textMid, fontSize: 12 }}>{sub}</p> : null}
    </div>
  );
}

export function RefreshButton({ onClick, style }) {
  return (
    <button
      type="button"
      onClick={onClick}
      style={{
        display: "inline-flex",
        alignItems: "center",
        gap: 6,
        padding: "8px 14px",
        borderRadius: 8,
        border: `1px solid ${C.border}`,
        background: "transparent",
        color: C.textMid,
        fontWeight: 700,
        fontSize: 12,
        cursor: "pointer",
        ...style,
      }}
    >
      <RefreshCw size={13} strokeWidth={2.1} aria-hidden />
      Actualizar
    </button>
  );
}
