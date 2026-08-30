import { $ } from "../utils";
import { TOKENS as T } from "../theme/tokens";
import { ofertaDeProducto } from "../lib/precioOferta";

const SIZE = {
  sm: { ahora: 20, antes: 12, chip: 10, leyenda: 10, gap: 8 },
  md: { ahora: 18, antes: 12, chip: 10, leyenda: 11, gap: 8 },
  lg: { ahora: "clamp(26px, 7vw, 36px)", antes: 16, chip: 11, leyenda: 12, gap: 12 },
};

/**
 * Precio normal tachado (gris + raya roja) y precio especial al lado.
 * Misma lectura que Del Ahorro: “precio normal / precio oferta”.
 */
export default function PrecioOferta({
  prod,
  promos,
  size = "sm",
  showAhorro = true,
  align = "start",
}) {
  const o = ofertaDeProducto(prod, promos);
  const s = SIZE[size] || SIZE.sm;
  const ahora = o.hayOferta ? o.oferta : o.lista;

  return (
    <div style={{ minWidth: 0 }}>
      {o.hayOferta && (
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 6,
            flexWrap: "wrap",
            marginBottom: 4,
          }}
        >
          <span
            style={{
              background: T.red,
              color: "#fff",
              fontSize: s.chip,
              fontWeight: 800,
              letterSpacing: 0.2,
              borderRadius: 4,
              padding: "2px 6px",
              lineHeight: 1.2,
            }}
          >
            {o.etiqueta}
          </span>
          <span
            style={{
              color: T.red,
              fontSize: s.leyenda,
              fontWeight: 800,
              letterSpacing: 0.01,
            }}
          >
            {o.leyenda}
          </span>
        </div>
      )}
      <div
        style={{
          display: "flex",
          alignItems: "baseline",
          gap: s.gap,
          flexWrap: "wrap",
          justifyContent: align === "end" ? "flex-end" : "flex-start",
        }}
      >
        {o.hayOferta && (
          <span
            style={{
              color: T.textDim,
              fontSize: s.antes,
              fontWeight: 600,
              textDecoration: "line-through",
              textDecorationColor: T.red,
              textDecorationThickness: "2px",
              textUnderlineOffset: 2,
            }}
          >
            {$(o.lista)}
          </span>
        )}
        <span
          style={{
            color: T.ink,
            fontWeight: 900,
            fontSize: s.ahora,
            lineHeight: 1.1,
          }}
        >
          {$(ahora)}
        </span>
      </div>
      {o.hayOferta && showAhorro && o.ahorro > 0 && (
        <div
          style={{
            color: T.jade,
            fontSize: s.leyenda,
            fontWeight: 700,
            marginTop: 4,
          }}
        >
          Ahorras {$(o.ahorro)}
        </div>
      )}
    </div>
  );
}

export { ofertaDeProducto };
