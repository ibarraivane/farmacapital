import { C_LIGHT } from "./constants";
import { fmtPrecioRef, fmtPrecioVenta } from "./lib/preciosReferencia";

const C = C_LIGHT;

function toneOf(tone) {
  if (tone === "critica") return { bg: C.redDim, fg: C.red };
  if (tone === "caro") return { bg: C.redDim, fg: C.red };
  if (tone === "piso") return { bg: C.amberDim, fg: C.amber };
  if (tone === "compra") return { bg: C.blueDim, fg: C.blue };
  if (tone === "rappi") return { bg: C.tealDim, fg: C.teal };
  return { bg: C.cardDark, fg: C.textMid };
}

export default function AlertaPrecioChips({ alerta }) {
  if (!alerta?.chips?.length) {
    return <span style={{ color: C.textDim, fontSize: 10 }}>—</span>;
  }
  return (
    <div style={{ display: "flex", flexWrap: "wrap", gap: 4 }}>
      {alerta.chips.map((c) => {
        const col = toneOf(c.tone);
        return (
          <span
            key={c.id}
            style={{
              display: "inline-block",
              padding: "1px 6px",
              borderRadius: 999,
              background: col.bg,
              color: col.fg,
              fontSize: 9,
              fontWeight: 800,
              lineHeight: 1.4,
            }}
          >
            {c.label}
          </span>
        );
      })}
    </div>
  );
}

export function RefMercadoCell({ alerta }) {
  if (!alerta) return <span style={{ color: C.textDim }}>—</span>;
  return (
    <div style={{ lineHeight: 1.3 }}>
      <div style={{ fontWeight: 700, color: alerta.refMin != null ? C.text : C.textDim }}>
        {alerta.refMin != null ? `mín ${fmtPrecioRef(alerta.refMin)}` : "sin ref. venta"}
      </div>
      {alerta.sugerido != null && alerta.refMin != null ? (
        <div style={{ fontSize: 10, color: C.textMid }}>sug. {fmtPrecioVenta(alerta.sugerido)}</div>
      ) : null}
      {alerta.mejorCompra ? (
        <div style={{ fontSize: 10, color: C.blue, fontWeight: 700 }}>
          {alerta.mejorCompra.label} {fmtPrecioRef(alerta.mejorCompra.precio)}
        </div>
      ) : null}
    </div>
  );
}
