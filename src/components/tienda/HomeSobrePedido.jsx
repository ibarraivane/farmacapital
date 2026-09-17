import EnlacesSeccionConseguir from "./EnlacesSeccionConseguir";
import { V, sectionTitle } from "./vitrinaUi";

export default function HomeSobrePedido({ setPage, productos = [], stack = false }) {
  return (
    <section style={{ maxWidth: 1120, margin: "0 auto", padding: stack ? "20px 16px 24px" : "24px 16px 28px" }}>
      <h2 style={sectionTitle}>¿No lo encuentras?</h2>
      <p style={{ margin: "6px 0 14px", color: V.mid, fontSize: 14, lineHeight: 1.45, maxWidth: "40em" }}>
        Si no está en el anaquel, lo pedimos. Llega en 24-48 h.
      </p>
      <EnlacesSeccionConseguir setPage={setPage} productos={productos} stack={stack} />
      <button
        type="button"
        onClick={() => setPage("pedidos-especiales")}
        style={{
          background: "none",
          border: "none",
          color: V.ink,
          fontWeight: 700,
          fontSize: 13,
          cursor: "pointer",
          fontFamily: V.body,
          padding: "12px 0 0",
        }}
      >
        Otro producto, pedidos especiales →
      </button>
    </section>
  );
}
