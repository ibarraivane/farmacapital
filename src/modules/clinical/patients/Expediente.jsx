/** Alergias y antecedentes durante consulta activa (panel colapsable). */
export function Expediente({ alergias, setAlergias, antecedentes, setAntecedentes, inputStyle, C }) {
  return (
    <div style={{ marginTop: 12, borderTop: `1px solid ${C.border}`, paddingTop: 12 }}>
      <div style={{ marginBottom: 8 }}>
        <div style={{ color: C.red, fontSize: 10, fontWeight: 700, marginBottom: 3 }}>⚠️ ALERGIAS</div>
        <textarea
          value={alergias}
          onChange={(e) => setAlergias(e.target.value)}
          rows={2}
          placeholder="Ej: Penicilina, AINES, látex…"
          style={{ ...inputStyle, fontSize: 11, resize: "none", width: "100%" }}
        />
      </div>
      <div>
        <div style={{ color: C.amber, fontSize: 10, fontWeight: 700, marginBottom: 3 }}>📋 ANTECEDENTES</div>
        <textarea
          value={antecedentes}
          onChange={(e) => setAntecedentes(e.target.value)}
          rows={2}
          placeholder="Ej: DM2, HTA, cirugías previas…"
          style={{ ...inputStyle, fontSize: 11, resize: "none", width: "100%" }}
        />
      </div>
    </div>
  );
}
