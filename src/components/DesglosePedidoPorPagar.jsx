import { Btn } from "../ui";
import { BRAND } from "../constants";
import { useTheme } from "../themeContext";
import { $ } from "../utils";
import { desgloseEnvioCheckout, feeEnvioEnCheckout, formatEnvioMoney } from "../lib/envioDomicilio";

/**
 * Pedido a domicilio ya cotizado, todavía sin pagar.
 * Muestra las piezas del carrito, el envío y el total. El botón abre Mercado Pago.
 */
export default function DesglosePedidoPorPagar({ pedido, busy, onPagar }) {
  const C = useTheme();
  const fee = feeEnvioEnCheckout(pedido);
  const partes = desgloseEnvioCheckout(pedido?.total, fee);
  const lineas = Array.isArray(pedido?.pedido_items) ? pedido.pedido_items : [];

  return (
    <div style={{ background: C.white, border: "1px solid #fcd34d", borderRadius: 14, padding: 16, marginBottom: 12 }}>
      <div style={{ color: C.dark, fontWeight: 800, fontSize: 18 }}>Pedido #{pedido?.id}</div>
      <div style={{ color: C.mid, fontSize: 13, lineHeight: 1.45, marginTop: 4 }}>
        Revisa el desglose. El botón te lleva a Mercado Pago para pagar este total.
      </div>
      <div style={{ marginTop: 14 }}>
        {lineas.map((item, i) => {
          const qty = Number(item?.cantidad) || 1;
          const unit = Number(item?.precio_unitario) || 0;
          const nombre = item?.productos?.nombre || "Producto";
          return (
            <div
              key={item?.producto_id || i}
              style={{
                display: "flex",
                justifyContent: "space-between",
                gap: 12,
                padding: "10px 0",
                borderTop: i ? `1px solid ${C.border}` : "none",
              }}
            >
              <div style={{ minWidth: 0 }}>
                <div style={{ color: C.dark, fontWeight: 700, fontSize: 14 }}>{nombre}</div>
                <div style={{ color: C.dim, fontSize: 12, marginTop: 2 }}>{qty} × {$(unit)}</div>
              </div>
              <div style={{ color: C.dark, fontWeight: 800, fontSize: 14, flexShrink: 0 }}>{$(unit * qty)}</div>
            </div>
          );
        })}
      </div>
      <div style={{ borderTop: `1px solid ${C.border}`, marginTop: 8, paddingTop: 10 }}>
        <div style={{ display: "flex", justifyContent: "space-between", fontSize: 14, color: C.dark, marginBottom: 6 }}>
          <span>Productos</span><span>{$(partes.productos)}</span>
        </div>
        <div style={{ display: "flex", justifyContent: "space-between", fontSize: 14, color: C.dark, marginBottom: 8 }}>
          <span>Envío a domicilio</span><span>{formatEnvioMoney(partes.envio)}</span>
        </div>
        <div style={{ display: "flex", justifyContent: "space-between", fontSize: 18, fontWeight: 800, color: C.dark }}>
          <span>Total</span><span>{$(partes.total)}</span>
        </div>
      </div>
      <Btn full onClick={() => onPagar?.(pedido)} col={BRAND.primary} disabled={busy} style={{ marginTop: 14 }}>
        {busy ? "Abriendo Mercado Pago..." : `Pagar ahora ${$(partes.total)}`}
      </Btn>
    </div>
  );
}
