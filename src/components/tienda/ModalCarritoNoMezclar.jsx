import { Btn } from "../../ui";
import { BRAND, C_LIGHT as C } from "../../constants";
import { etiquetaVaciarYAgregar } from "../../lib/bajoPedido";

/**
 * Sustituye el alert() nativo: el encargo no entra en el mismo carrito
 * que anaquel. Ofrece vaciar y seguir, no solo «Aceptar».
 */
export default function ModalCarritoNoMezclar({ motivo, producto, onCancelar, onVaciarYAgregar, onVerCarrito }) {
  if (!motivo || !producto) return null;
  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="fc-carrito-no-mezclar-titulo"
      onClick={onCancelar}
      style={{
        position: "fixed",
        inset: 0,
        background: "rgba(13,27,42,.55)",
        zIndex: 800,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: 16,
      }}
    >
      <div
        onClick={(e) => e.stopPropagation()}
        style={{
          background: C.card,
          color: C.text,
          borderRadius: 16,
          maxWidth: 420,
          width: "100%",
          padding: "22px 20px 18px",
          boxShadow: "0 18px 50px rgba(13,27,42,.28)",
          border: `1px solid ${C.border}`,
        }}
      >
        <h2
          id="fc-carrito-no-mezclar-titulo"
          style={{ color: C.dark, fontSize: 18, fontWeight: 800, margin: "0 0 10px", lineHeight: 1.25 }}
        >
          Este va en otro pedido
        </h2>
        <p style={{ color: C.mid, fontSize: 14, lineHeight: 1.55, margin: "0 0 18px" }}>{motivo}</p>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          <Btn col={BRAND.primary} full onClick={onVaciarYAgregar}>
            {etiquetaVaciarYAgregar(producto)}
          </Btn>
          <Btn outline col={BRAND.primary} full onClick={onVerCarrito}>
            Ver carrito
          </Btn>
          <button
            type="button"
            onClick={onCancelar}
            style={{
              background: "none",
              border: "none",
              color: C.mid,
              fontSize: 13,
              fontWeight: 600,
              cursor: "pointer",
              padding: "8px 4px",
              fontFamily: "var(--fc-body)",
            }}
          >
            Seguir viendo
          </button>
        </div>
      </div>
    </div>
  );
}
