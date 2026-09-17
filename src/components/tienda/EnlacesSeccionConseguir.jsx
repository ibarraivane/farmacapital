import { FASE2_INCLUIR_ANAQUEL, SECCIONES_CONSEGUIR, filtrarSeccion } from "../../lib/bajoPedido";
import { V, displayTitle } from "./vitrinaUi";

/**
 * Dos tarjetas: Dermocosmética · Vitaminas y suplementos.
 */
export default function EnlacesSeccionConseguir({ setPage, productos = [], stack = false }) {
  return (
    <div
      style={{
        display: "grid",
        gridTemplateColumns: stack ? "1fr" : "1fr 1fr",
        gap: stack ? 12 : 16,
      }}
    >
      {SECCIONES_CONSEGUIR.map((sec) => {
        const n = filtrarSeccion(productos, sec.id, { incluirAnaquel: FASE2_INCLUIR_ANAQUEL }).length;
        const derma = sec.id === "dermatologia";
        return (
          <button
            key={sec.id}
            type="button"
            onClick={() => setPage(sec.page, { search: "" })}
            style={{
              display: "flex",
              flexDirection: "column",
              alignItems: "flex-start",
              textAlign: "left",
              padding: stack ? "22px 20px 20px" : "28px 26px 24px",
              minHeight: stack ? 148 : 176,
              borderRadius: V.radius,
              border: `1px solid ${V.border}`,
              background: derma
                ? `linear-gradient(165deg, ${V.surface} 0%, #e8f6ee 100%)`
                : `linear-gradient(165deg, ${V.surface} 0%, #e8eef8 100%)`,
              cursor: "pointer",
              fontFamily: V.body,
              boxShadow: V.shadow,
            }}
          >
            <span style={{ width: 28, height: 2, background: derma ? V.jade : V.blue, marginBottom: 16 }} />
            <span style={{ ...displayTitle, fontSize: stack ? 24 : 28, margin: 0 }}>
              {sec.label}
            </span>
            <p style={{ margin: "10px 0 0", color: V.mid, fontSize: 14, lineHeight: 1.5, maxWidth: 280 }}>
              {sec.desc}
            </p>
            <span
              style={{
                marginTop: "auto",
                paddingTop: 18,
                color: V.ink,
                fontWeight: 600,
                fontSize: 13,
                letterSpacing: "0.01em",
              }}
            >
              {n > 0
                ? `${n} ${n === 1 ? "producto" : "productos"}`
                : "Sobre pedido · 24-48 h"}
              <span aria-hidden style={{ marginLeft: 8 }}>→</span>
            </span>
          </button>
        );
      })}
    </div>
  );
}
