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

/** Botón ☰: mismo ícono que el admin en celular. */
export function AdminNavToggle({
  expanded = false,
  onClick,
  label,
  floating = false,
  compact = false,
  style,
}) {
  const size = compact ? 36 : floating ? 48 : 44;
  const aria = label || (expanded ? "Cerrar menú de navegación" : "Abrir menú de navegación");
  return (
    <button
      type="button"
      className="fc-admin-nav-toggle"
      aria-label={aria}
      title={aria}
      aria-expanded={expanded}
      onClick={onClick}
      style={{
        width: size,
        height: size,
        borderRadius: 12,
        border: `1px solid ${C.border}`,
        background: C.card,
        color: C.text,
        fontSize: compact ? 18 : 20,
        lineHeight: 1,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        cursor: "pointer",
        flexShrink: 0,
        pointerEvents: "auto",
        touchAction: "manipulation",
        boxShadow: floating ? "0 4px 20px rgba(0,0,0,.08)" : "none",
        ...style,
      }}
    >
      ☰
    </button>
  );
}

/** Barra superior de escritorio cuando el menú izquierdo está minimizado. */
export function AdminCollapsedTopbar({ title, navOpen, onToggleNav, onPin }) {
  return (
    <div
      className="fc-admin-collapsed-topbar"
      data-testid="admin-collapsed-topbar"
      style={{
        position: "fixed",
        top: 0,
        left: 0,
        right: 0,
        zIndex: 2102,
        display: "flex",
        alignItems: "center",
        gap: 10,
        minHeight: 52,
        height: "calc(52px + env(safe-area-inset-top, 0px))",
        padding: "env(safe-area-inset-top, 0px) 16px 0 max(12px, env(safe-area-inset-left, 0px))",
        background: "#ffffff",
        borderBottom: "1px solid #e2e8f0",
        boxSizing: "border-box",
        boxShadow: "0 1px 0 #e2e8f0",
      }}
    >
      <AdminNavToggle
        expanded={navOpen}
        onClick={onToggleNav}
        label={navOpen ? "Cerrar menú de navegación" : "Abrir menú de navegación"}
      />
      <div
        className="fc-admin-collapsed-topbar-title"
        style={{
          minWidth: 0,
          flex: 1,
          fontWeight: 800,
          fontSize: 16,
          color: C.text,
          whiteSpace: "nowrap",
          overflow: "hidden",
          textOverflow: "ellipsis",
        }}
      >
        {title}
      </div>
      {onPin ? (
        <button
          type="button"
          onClick={onPin}
          style={{
            flexShrink: 0,
            border: `1px solid ${C.border}`,
            background: "#ffffff",
            color: C.textMid,
            borderRadius: 10,
            padding: "8px 12px",
            fontSize: 12,
            fontWeight: 700,
            cursor: "pointer",
            fontFamily: "var(--fc-body)",
          }}
        >
          Fijar menú
        </button>
      ) : null}
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
