import { useEffect, useState } from "react";
import { supabase } from "../supabase";
import { getClienteToken } from "../utils";
import { formatEnvioMoney, feeEnvioEnCheckout, pedidosConEnvioPorPagar } from "../lib/envioDomicilio";

/** Aviso fijo: el envío cotizado no vive en el carrito, está en Mi cuenta. */
export default function AvisoEnvioPorPagar({ user, setPage }) {
  const [pedido, setPedido] = useState(null);

  useEffect(() => {
    let vivo = true;
    const tok = getClienteToken();
    if (!user || !tok) {
      setPedido(null);
      return undefined;
    }
    supabase.rpc("cliente_listar_mis_pedidos", { p_session_token: tok, p_limite: 20 })
      .then(({ data }) => {
        if (!vivo) return;
        const listos = pedidosConEnvioPorPagar(Array.isArray(data) ? data : []);
        setPedido(listos[0] || null);
      })
      .catch(() => {
        if (vivo) setPedido(null);
      });
    return () => { vivo = false; };
  }, [user?.id, user?.telefono]);

  if (!pedido) return null;
  const fee = feeEnvioEnCheckout(pedido);
  const folio = `#${pedido.id}`;

  return (
    <div style={{
      background: "#fef3c7",
      color: "#92400e",
      borderBottom: "1px solid #fcd34d",
      padding: "10px 16px",
      fontSize: 13,
      lineHeight: 1.45,
      display: "flex",
      flexWrap: "wrap",
      gap: 10,
      alignItems: "center",
      justifyContent: "space-between",
    }}>
      <span>
        Tu pedido {folio} ya tiene el envío cotizado{fee != null ? `: ${formatEnvioMoney(fee)}` : ""}.
        {" "}No está en el carrito: entra a Mi cuenta, revísalo y toca Pagar ahora.
      </span>
      <button
        type="button"
        onClick={() => setPage?.("cuenta")}
        style={{
          background: "#92400e",
          color: "#fff",
          border: "none",
          borderRadius: 8,
          padding: "8px 12px",
          fontWeight: 800,
          fontSize: 13,
          cursor: "pointer",
          fontFamily: "var(--fc-body)",
        }}
      >
        Revisar y pagar
      </button>
    </div>
  );
}
