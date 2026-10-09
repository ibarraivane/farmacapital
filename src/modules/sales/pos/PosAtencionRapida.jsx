import { $ } from "../../../utils";
import { pesoPublico } from "../../../utils/pesoPublico";
import { etiquetaCortaAtencion } from "../../../lib/servicioSalud";

/**
 * Acceso rápido de atención en la pestaña Venta.
 * Botones grandes: se usan con prisa y a veces con guantes.
 */
export default function PosAtencionRapida({ servicios, onAdd, C }) {
  const lista = servicios || [];
  if (!lista.length) return null;
  return (
    <div
      data-testid="pos-atencion"
      style={{
        display: "flex",
        gap: 8,
        flexWrap: "wrap",
        alignItems: "center",
        marginBottom: 12,
      }}
    >
      <span style={{ fontSize: 13, fontWeight: 800, color: C.textMid, marginRight: 2 }}>Atención</span>
      {lista.map((p) => (
        <button
          key={p.id}
          type="button"
          onClick={() => onAdd(p)}
          style={{
            minHeight: 52,
            padding: "12px 18px",
            borderRadius: 12,
            border: `2px solid ${C.teal}`,
            background: C.tealDim,
            color: "#0e7490",
            fontWeight: 800,
            fontSize: 16,
            cursor: "pointer",
            fontFamily: "inherit",
          }}
        >
          {etiquetaCortaAtencion(p)} {$(pesoPublico(p.precio))}
        </button>
      ))}
    </div>
  );
}
