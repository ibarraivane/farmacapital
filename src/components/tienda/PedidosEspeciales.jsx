import EnlacesSeccionConseguir from "./EnlacesSeccionConseguir";
import { TEXTO_AVISO_RECETA, TEXTO_RESERVA } from "../../lib/bajoPedido";
import { V, displayTitle, eyebrowStyle, heroBand } from "./vitrinaUi";

const PASOS = [
  { n: "01", t: "Dinos qué necesitas", d: "Marca, presentación o el nombre de mostrador." },
  { n: "02", t: "Lo pedimos", d: "Al mayorista. Suele tardar 24-48 h." },
  { n: "03", t: "Te avisamos", d: "Para recogerlo en tienda o enviarlo." },
];

export default function PedidosEspeciales({ setPage, productos = [], stack = false, children }) {
  return (
    <div>
      <header style={{ ...heroBand, padding: stack ? "28px 16px 22px" : "40px 24px 28px" }}>
        <div style={{ maxWidth: 760, margin: "0 auto" }}>
          <p style={eyebrowStyle}>Sobre pedido · 24-48 h</p>
          <h1 style={{ ...displayTitle, fontSize: stack ? 34 : 44 }}>Pedidos especiales</h1>
          <p style={{ margin: "14px 0 0", color: V.mid, fontSize: 16, lineHeight: 1.55, maxWidth: 520 }}>
            Si no está en las vitrinas, anótalo. Te escribimos con el costo.
          </p>
        </div>
      </header>

      <section style={{ maxWidth: 760, margin: "0 auto", padding: stack ? "22px 16px 48px" : "28px 24px 64px" }}>
        <ol
          style={{
            listStyle: "none",
            margin: "0 0 28px",
            padding: 0,
            display: "grid",
            gridTemplateColumns: stack ? "1fr" : "repeat(3, minmax(0, 1fr))",
            gap: stack ? 14 : 18,
          }}
        >
          {PASOS.map((p) => (
            <li key={p.n}>
              <div style={{ fontFamily: V.display, fontSize: 13, color: V.jade, letterSpacing: "0.08em", marginBottom: 6 }}>
                {p.n}
              </div>
              <div style={{ color: V.ink, fontWeight: 600, fontSize: 15 }}>{p.t}</div>
              <div style={{ color: V.mid, fontSize: 13, lineHeight: 1.45, marginTop: 4 }}>{p.d}</div>
            </li>
          ))}
        </ol>

        <p style={{ margin: "0 0 12px", color: V.mid, fontSize: 14, lineHeight: 1.6 }}>{TEXTO_RESERVA}</p>
        <p
          style={{
            margin: "0 0 24px",
            color: V.inkSoft,
            fontSize: 13,
            lineHeight: 1.55,
            background: V.surface,
            border: `1px solid ${V.border}`,
            borderRadius: V.radiusMd,
            padding: "12px 14px",
          }}
        >
          {TEXTO_AVISO_RECETA}
        </p>

        {children}

        <div style={{ marginTop: 40, paddingTop: 28, borderTop: `1px solid ${V.border}` }}>
          <p style={{ ...eyebrowStyle, marginBottom: 12 }}>También en vitrina</p>
          <EnlacesSeccionConseguir setPage={setPage} productos={productos} stack={stack} />
        </div>
      </section>
    </div>
  );
}
