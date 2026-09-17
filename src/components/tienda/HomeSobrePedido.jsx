import EnlacesSeccionConseguir from "./EnlacesSeccionConseguir";
import { V, displayTitle, eyebrowStyle } from "./vitrinaUi";

/** Bloque del home: no es otra fila de atajos, es la entrada a las vitrinas. */
export default function HomeSobrePedido({ setPage, productos = [], stack = false }) {
  return (
    <section
      style={{
        background: V.canvas,
        borderTop: `1px solid ${V.border}`,
        borderBottom: `1px solid ${V.border}`,
        padding: stack ? "28px 16px 32px" : "40px 24px 44px",
      }}
    >
      <div style={{ maxWidth: 1120, margin: "0 auto" }}>
        <p style={eyebrowStyle}>Sobre pedido</p>
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: stack ? "flex-start" : "flex-end",
            gap: 16,
            flexWrap: "wrap",
            margin: "8px 0 22px",
          }}
        >
          <h2 style={{ ...displayTitle, fontSize: stack ? 30 : 36, margin: 0, maxWidth: 420 }}>
            Lo pedimos por ti
          </h2>
          <p style={{ margin: 0, color: V.mid, fontSize: 15, lineHeight: 1.5, maxWidth: 360 }}>
            Dermocosmética, vitaminas y nutrición deportiva. Si no está en anaquel, llega en 24-48 h.
          </p>
        </div>
        <EnlacesSeccionConseguir setPage={setPage} productos={productos} stack={stack} />
        <button
          type="button"
          onClick={() => setPage("pedidos-especiales")}
          style={{
            background: "none",
            border: "none",
            color: V.ink,
            fontWeight: 600,
            fontSize: 14,
            cursor: "pointer",
            fontFamily: V.body,
            padding: "16px 0 0",
          }}
        >
          Pedidos especiales →
        </button>
      </div>
    </section>
  );
}
