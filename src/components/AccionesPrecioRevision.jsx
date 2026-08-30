import { C_LIGHT, BRAND } from "../constants";

const C = C_LIGHT;

export default function AccionesPrecioRevision({
  botones,
  applying,
  onSubir,
  onBajar,
  onAceptar,
}) {
  if (!botones || (!botones.subir && !botones.bajar && !botones.aceptar)) {
    return <span style={{ color: C.textDim, fontSize: 10 }}>—</span>;
  }
  return (
    <div style={{ display: "flex", flexWrap: "wrap", gap: 4, alignItems: "center" }}>
      {botones.subir ? (
        <button
          type="button"
          disabled={applying}
          onClick={onSubir}
          style={{
            padding: "4px 10px", borderRadius: 6, border: "none",
            background: BRAND.gradient, color: "#fff", cursor: "pointer",
            fontSize: 11, fontWeight: 700, opacity: applying ? 0.6 : 1,
          }}
        >
          Subir
        </button>
      ) : null}
      {botones.bajar ? (
        <button
          type="button"
          disabled={applying}
          onClick={onBajar}
          style={{
            padding: "4px 10px", borderRadius: 6, border: "none",
            background: C.amber, color: "#fff", cursor: "pointer",
            fontSize: 11, fontWeight: 700, opacity: applying ? 0.6 : 1,
          }}
        >
          Bajar
        </button>
      ) : null}
      {botones.aceptar ? (
        <button
          type="button"
          disabled={applying}
          onClick={onAceptar}
          style={{
            padding: "4px 10px", borderRadius: 6,
            border: `1px solid ${C.border}`,
            background: C.card, color: C.text, cursor: "pointer",
            fontSize: 11, fontWeight: 700, opacity: applying ? 0.6 : 1,
          }}
        >
          Aceptar
        </button>
      ) : null}
    </div>
  );
}
