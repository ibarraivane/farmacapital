/** Franja de “Comprar de nuevo” / “Sugerido para ti”. */
export default function RecompraStrip({ title, subtitle, children, empty }) {
  if (empty) return null;
  return (
    <div style={{ marginBottom: 24 }}>
      <div style={{ marginBottom: 12 }}>
        <h2 style={{ color: "#1e293b", fontSize: "clamp(18px,4.2vw,22px)", fontWeight: 800, margin: 0 }}>
          {title}
        </h2>
        {subtitle ? (
          <div style={{ color: "#64748b", fontSize: 13, marginTop: 4, lineHeight: 1.4 }}>{subtitle}</div>
        ) : null}
      </div>
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fill,minmax(min(100%,220px),1fr))",
          gap: 16,
        }}
      >
        {children}
      </div>
    </div>
  );
}
