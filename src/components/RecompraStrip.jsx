/**
 * Franja horizontal de productos (recompra, sugeridos o categoría).
 * Scroll horizontal — estilo “banda” de catálogo.
 */
export default function RecompraStrip({
  title,
  subtitle,
  children,
  empty,
  actionLabel,
  onAction,
}) {
  if (empty) return null;
  return (
    <div style={{ marginBottom: 28 }}>
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "flex-end",
          gap: 12,
          marginBottom: 12,
          flexWrap: "wrap",
        }}
      >
        <div style={{ minWidth: 0, flex: "1 1 auto" }}>
          <h2
            style={{
              color: "#1e293b",
              fontSize: "clamp(18px,4.2vw,22px)",
              fontWeight: 800,
              margin: 0,
              fontFamily: "var(--fc-body)",
            }}
          >
            {title}
          </h2>
          {subtitle ? (
            <div style={{ color: "#64748b", fontSize: 13, marginTop: 4, lineHeight: 1.4 }}>
              {subtitle}
            </div>
          ) : null}
        </div>
        {actionLabel && typeof onAction === "function" ? (
          <button
            type="button"
            onClick={onAction}
            style={{
              background: "none",
              border: "none",
              color: "#0052cc",
              fontWeight: 700,
              fontSize: 13,
              cursor: "pointer",
              padding: "4px 0",
              fontFamily: "var(--fc-body)",
              flexShrink: 0,
            }}
          >
            {actionLabel}
          </button>
        ) : null}
      </div>
      <div
        className="farmacapital-productos-strip"
        style={{
          display: "flex",
          gap: 14,
          overflowX: "auto",
          scrollSnapType: "x mandatory",
          WebkitOverflowScrolling: "touch",
          scrollbarWidth: "none",
          paddingBottom: 6,
          marginInline: -4,
          paddingInline: 4,
        }}
      >
        {children}
      </div>
    </div>
  );
}

/** CSS una sola vez (Home / Cuenta montan varias bandas). */
export function ProductosStripStyles() {
  return (
    <style>{`
      .farmacapital-productos-strip::-webkit-scrollbar { display: none; }
      .farmacapital-productos-strip > * {
        flex: 0 0 auto;
        width: min(200px, 72vw);
        max-width: 220px;
        scroll-snap-align: start;
      }
    `}</style>
  );
}
