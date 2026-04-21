import { Expediente } from "./patients/Expediente";

/** Encabezado del paciente en consulta + panel de expediente (alergias / antecedentes). */
export function Paciente({
  citaActual,
  editExpediente,
  onToggleExpediente,
  alergias,
  setAlergias,
  antecedentes,
  setAntecedentes,
  inputStyle,
  C,
}) {
  return (
    <div style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 12, padding: 18, marginBottom: 14 }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
        <div style={{ color: C.blue, fontWeight: 800, fontSize: 14 }}>👤 Paciente en consulta</div>
        <button
          type="button"
          onClick={onToggleExpediente}
          style={{
            fontSize: 10,
            padding: "3px 8px",
            borderRadius: 6,
            border: `1px solid ${C.border}`,
            background: "transparent",
            color: C.textMid,
            cursor: "pointer",
          }}
        >
          {editExpediente ? "✕ Cerrar" : "📋 Expediente"}
        </button>
      </div>
      <div style={{ color: C.text, fontWeight: 700, fontSize: 16, marginBottom: 6 }}>
        {citaActual.nombre || citaActual.paciente || "—"}
      </div>
      <div style={{ color: C.textMid, fontSize: 12 }}>📞 {citaActual.telefono || "—"}</div>
      {citaActual.motivo && (
        <div style={{ color: C.textMid, fontSize: 12, marginTop: 8 }}>
          Motivo: <strong style={{ color: C.text }}>{citaActual.motivo}</strong>
        </div>
      )}
      {citaActual.hora && (
        <div style={{ color: C.textMid, fontSize: 12, marginTop: 4 }}>
          Hora: <strong style={{ color: C.amber }}>{citaActual.hora}</strong>
        </div>
      )}
      {editExpediente && (
        <Expediente
          alergias={alergias}
          setAlergias={setAlergias}
          antecedentes={antecedentes}
          setAntecedentes={setAntecedentes}
          inputStyle={inputStyle}
          C={C}
        />
      )}
    </div>
  );
}
