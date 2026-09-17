import { FASE2_INCLUIR_ANAQUEL, SECCIONES_CONSEGUIR, filtrarSeccion } from "../../lib/bajoPedido";
import { V } from "./vitrinaUi";

/**
 * Entradas de vitrina: Dermocosmética · Vitaminas · Dispositivos.
 */
export default function EnlacesSeccionConseguir({ setPage, productos = [], stack = false }) {
  const cols = SECCIONES_CONSEGUIR.length;
  return (
    <div
      style={{
        display: "grid",
        gridTemplateColumns: stack ? "1fr" : `repeat(${cols}, minmax(0, 1fr))`,
        gap: 12,
      }}
    >
      {SECCIONES_CONSEGUIR.map((sec) => {
        const n = filtrarSeccion(productos, sec.id, { incluirAnaquel: FASE2_INCLUIR_ANAQUEL }).length;
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
              padding: "16px 16px 14px",
              minHeight: 108,
              borderRadius: 12,
              border: `1px solid ${V.border}`,
              background: "#fff",
              cursor: "pointer",
              fontFamily: V.body,
            }}
          >
            <span style={{ color: V.ink, fontWeight: 800, fontSize: 16, lineHeight: 1.25 }}>
              {sec.label}
            </span>
            <p style={{ margin: "6px 0 0", color: V.mid, fontSize: 13, lineHeight: 1.45 }}>
              {sec.teaser || sec.desc}
            </p>
            <span style={{ marginTop: "auto", paddingTop: 12, color: V.ink, fontWeight: 700, fontSize: 13 }}>
              {n > 0 ? `${n} ${n === 1 ? "producto" : "productos"}` : "Ver"}
              <span aria-hidden> →</span>
            </span>
          </button>
        );
      })}
    </div>
  );
}
