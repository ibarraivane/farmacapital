import { $ } from "../../../utils";
import { pesoPublico } from "../../../utils/pesoPublico";
import { etiquetaCortaAtencion } from "../../../lib/servicioSalud";

/**
 * Acceso rápido de atención en la pestaña Venta.
 * Pastillas chicas, arriba del buscador: el precio es el cobro al cliente.
 */
export default function PosAtencionRapida({ servicios, onAdd, C }) {
  const lista = servicios || [];
  if (!lista.length) return null;
  return (
    <div
      data-testid="pos-atencion"
      style={{
        display: "flex",
        gap: 6,
        flexWrap: "wrap",
        alignItems: "center",
        marginBottom: 8,
      }}
    >
      <span style={{ fontSize: 11, fontWeight: 700, letterSpacing: 0.3, color: C.textDim, marginRight: 2 }}>
        Atención
      </span>
      {lista.map((p) => (
        <button
          key={p.id}
          type="button"
          onClick={() => onAdd(p)}
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 6,
            height: 32,
            padding: "0 11px",
            borderRadius: 999,
            border: `1px solid ${C.teal}`,
            background: "#ffffff",
            color: "#0e7490",
            fontWeight: 600,
            fontSize: 13,
            lineHeight: 1,
            cursor: "pointer",
            fontFamily: "inherit",
            boxShadow: "0 1px 1px rgba(14, 116, 144, 0.06)",
          }}
        >
          <span>{etiquetaCortaAtencion(p)}</span>
          <span style={{ fontWeight: 800 }}>{$(pesoPublico(p.precio))}</span>
        </button>
      ))}
    </div>
  );
}
