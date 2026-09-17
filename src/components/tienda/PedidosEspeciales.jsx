import EnlacesSeccionConseguir from "./EnlacesSeccionConseguir";
import { TEXTO_AVISO_RECETA, TEXTO_RESERVA } from "../../lib/bajoPedido";
import { V, leadStyle, pageTitle, quietStyle } from "./vitrinaUi";

export default function PedidosEspeciales({ setPage, productos = [], stack = false, children }) {
  return (
    <section style={{ maxWidth: 640, margin: "0 auto", padding: stack ? "20px 16px 40px" : "28px 20px 56px" }}>
      <h1 style={pageTitle}>Pedidos especiales</h1>
      <p style={leadStyle}>
        Medicamento, vitamina o dispositivo. Anota marca y presentación. Tarda 24-48 h.
      </p>
      <p style={{ ...quietStyle, marginBottom: 20 }}>
        {TEXTO_RESERVA} {TEXTO_AVISO_RECETA}
      </p>
      {children}
      <div style={{ marginTop: 36, paddingTop: 22, borderTop: `1px solid ${V.border}` }}>
        <p style={{ margin: "0 0 10px", color: V.ink, fontWeight: 800, fontSize: 15 }}>
          También en catálogo
        </p>
        <EnlacesSeccionConseguir setPage={setPage} productos={productos} stack={stack} />
      </div>
    </section>
  );
}
