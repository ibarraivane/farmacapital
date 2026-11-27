import { $ } from "../../../utils";
import { pesoPublico } from "../../../utils/pesoPublico";
import { etiquetaCortaAtencion } from "../../../lib/servicioSalud";

/**
 * Acceso rápido de atención, en la misma línea y al mismo tamaño que la palabra «Atención».
 * El precio es el cobro al cliente.
 */
const LINEA = { fontSize: 13, lineHeight: "18px", fontFamily: "inherit" };

export default function PosAtencionRapida({ servicios, onAdd, C }) {
  const lista = servicios || [];
  if (!lista.length) return null;
  return (
    <div
      data-testid="pos-atencion"
      style={{
        display: "flex",
        gap: 14,
        flexWrap: "wrap",
        alignItems: "baseline",
        marginBottom: 8,
      }}
    >
      <span style={{ ...LINEA, fontWeight: 700, color: C.textMid }}>Atención</span>
      {lista.map((p) => (
        <button
          key={p.id}
          type="button"
          onClick={() => onAdd(p)}
          style={{
            ...LINEA,
            display: "inline-flex",
            alignItems: "baseline",
            gap: 4,
            margin: 0,
            padding: 0,
            border: "none",
            borderBottom: `1px solid ${C.teal}`,
            background: "transparent",
            color: "#0e7490",
            fontWeight: 600,
            cursor: "pointer",
          }}
        >
          <span>{etiquetaCortaAtencion(p)}</span>
          <span style={{ fontWeight: 700 }}>{$(pesoPublico(p.precio))}</span>
        </button>
      ))}
    </div>
  );
}
