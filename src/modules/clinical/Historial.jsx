/** Consultas previas completadas del mismo teléfono (vista compacta). */
export function Historial({ items, fmtDate, C }) {
  return (
    <div style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 12, padding: 18 }}>
      <div style={{ color: C.textMid, fontSize: 11, fontWeight: 700, letterSpacing: 0.5, marginBottom: 12 }}>
        CONSULTAS ANTERIORES
      </div>
      {items.length === 0 ? (
        <div style={{ color: C.textDim, fontSize: 12 }}>Primera visita</div>
      ) : (
        items.map((h, i) => (
          <div key={h.id || i} style={{ borderBottom: `1px solid ${C.border}`, paddingBottom: 8, marginBottom: 8 }}>
            <div style={{ color: C.text, fontSize: 12, fontWeight: 600 }}>{fmtDate(h.fecha)}</div>
            {h.motivo && <div style={{ color: C.textMid, fontSize: 11 }}>{h.motivo}</div>}
            {h.diagnostico && (
              <div style={{ color: C.textDim, fontSize: 11, fontStyle: "italic", marginTop: 2 }}>Dx: {h.diagnostico}</div>
            )}
          </div>
        ))
      )}
    </div>
  );
}
