import { C_LIGHT } from "../constants";
import {
  DENOMINACIONES_CAJA,
  etiquetaDenominacion,
  totalDesdeDenominaciones,
} from "../constants/caja";

const fmt = (n) => `$${parseFloat(n || 0).toFixed(2)}`;

/**
 * Conteo por denominación. El total se calcula; no se teclea.
 */
export default function ArqueoDenominaciones({ denoms, onChange, disabled = false }) {
  const C = C_LIGHT;
  const total = totalDesdeDenominaciones(denoms);

  return (
    <div>
      <div style={{
        display: "grid",
        gridTemplateColumns: "repeat(2, minmax(0, 1fr))",
        gap: 6,
      }}>
        {DENOMINACIONES_CAJA.map((d) => {
          const piezas = parseInt(denoms[d], 10) || 0;
          const sub = d * piezas;
          return (
            <label
              key={d}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 8,
                padding: "6px 8px",
                borderRadius: 8,
                border: `1px solid ${C.border}`,
                background: C.bg,
              }}
            >
              <span style={{
                color: C.textMid,
                fontSize: 12,
                fontWeight: 700,
                width: 48,
                textAlign: "right",
                flexShrink: 0,
              }}>
                {etiquetaDenominacion(d)}
              </span>
              <input
                type="number"
                min="0"
                inputMode="numeric"
                disabled={disabled}
                value={denoms[d] ?? ""}
                onChange={(e) => onChange(d, e.target.value)}
                placeholder="0"
                aria-label={`Piezas de ${etiquetaDenominacion(d)}`}
                style={{
                  width: 56,
                  padding: "6px 8px",
                  borderRadius: 6,
                  border: `1px solid ${C.border}`,
                  background: C.card,
                  color: C.text,
                  fontSize: 13,
                  outline: "none",
                }}
              />
              <span style={{
                color: piezas ? C.text : C.textDim,
                fontSize: 11,
                flex: 1,
                minWidth: 0,
              }}>
                {piezas ? fmt(sub) : ""}
              </span>
            </label>
          );
        })}
      </div>
      <div style={{
        marginTop: 12,
        padding: "10px 12px",
        borderRadius: 8,
        background: C.greenDim,
        color: C.greenDark,
        fontWeight: 800,
        fontSize: 16,
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
      }}>
        <span style={{ fontSize: 11, letterSpacing: 0.6, textTransform: "uppercase" }}>Total contado</span>
        <span>{fmt(total)}</span>
      </div>
    </div>
  );
}
