import { PackageSearch } from "lucide-react";
import { BRAND } from "../../constants";
import EnlacesSeccionConseguir from "./EnlacesSeccionConseguir";
import { TEXTO_AVISO_RECETA, TEXTO_RESERVA } from "../../lib/bajoPedido";

const PASOS = [
  "Dinos qué necesitas.",
  "Lo pedimos al mayorista, 24-48 h.",
  "Te avisamos para recogerlo o enviarlo.",
];

export default function PedidosEspeciales({ setPage, productos = [], stack = false, children }) {
  return (
    <section style={{ maxWidth: 760, margin: "0 auto", padding: "clamp(20px,4vw,32px) 16px 8px" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 8 }}>
        <div style={{ width: 40, height: 40, borderRadius: 12, background: BRAND.gradient, display: "grid", placeItems: "center", color: "#fff", flexShrink: 0 }}>
          <PackageSearch size={20} aria-hidden />
        </div>
        <h1 style={{ margin: 0, fontSize: "clamp(22px,5vw,26px)", fontWeight: 800, color: "#0f172a" }}>
          Pedidos especiales
        </h1>
      </div>
      <ol style={{ margin: "0 0 16px", padding: "0 0 0 20px", color: "#334155", fontSize: 14, lineHeight: 1.65 }}>
        {PASOS.map((p) => (
          <li key={p} style={{ marginBottom: 4 }}>{p}</li>
        ))}
      </ol>
      <p style={{ margin: "0 0 12px", color: "#475569", fontSize: 14, lineHeight: 1.6 }}>{TEXTO_RESERVA}</p>
      <p style={{ margin: "0 0 20px", color: "#92400e", fontSize: 13, lineHeight: 1.55, background: "#fffbeb", border: "1px solid #fde68a", borderRadius: 10, padding: "10px 12px" }}>
        {TEXTO_AVISO_RECETA}
      </p>
      {children}
      <div style={{ marginTop: 8, paddingBottom: 24 }}>
        <div style={{ fontSize: 13, fontWeight: 700, color: "#64748b", marginBottom: 10 }}>Ver el catálogo sobre pedido</div>
        <EnlacesSeccionConseguir setPage={setPage} productos={productos} stack={stack} />
      </div>
    </section>
  );
}
