import { useEffect, useRef, useState } from "react";
import { CreditCard, Lock, ShieldCheck } from "lucide-react";
import { Btn } from "../ui";
import { BRAND } from "../constants";
import { $ } from "../utils";
import { DIAS_RESERVA_MP } from "../lib/bajoPedido";

/** Public Key (no es secreta). Mismo default que src/utils/mercadoPago.js. */
const MP_PUBLIC_KEY = process.env.REACT_APP_MP_PUBLIC_KEY || "APP_USR-28b7f7b0-2e5d-44d4-a35a-1bef9cb11f44";
const MP_SDK_URL = "https://sdk.mercadopago.com/js/v2";

let sdkPromise = null;
function cargarSdkMercadoPago() {
  if (typeof window === "undefined") return Promise.reject(new Error("sin_window"));
  if (window.MercadoPago) return Promise.resolve(window.MercadoPago);
  if (sdkPromise) return sdkPromise;
  sdkPromise = new Promise((resolve, reject) => {
    const s = document.createElement("script");
    s.src = MP_SDK_URL;
    s.async = true;
    s.onload = () => (window.MercadoPago ? resolve(window.MercadoPago) : reject(new Error("sdk_sin_objeto")));
    s.onerror = () => { sdkPromise = null; reject(new Error("sdk_no_cargo")); };
    document.head.appendChild(s);
  });
  return sdkPromise;
}

export const MENSAJES_RESERVA = {
  solo_tarjeta_credito: "Para apartar un encargo usa tarjeta de crédito (débito no permite reservar).",
  amount_mismatch: "El total cambió. Regresa al carrito y vuelve a intentar.",
  pedido_ya_reservado: "Este pedido ya tiene una reserva.",
  guest_checkout_expired: "Pasó mucho tiempo desde que hiciste el pedido. Vuelve a hacerlo desde el carrito.",
  guest_phone_mismatch: "El teléfono no coincide con el del pedido.",
  reserva_rechazada: "La tarjeta no autorizó la reserva. Prueba con otra tarjeta de crédito.",
  mp_order_failed: "Mercado Pago no respondió. Intenta de nuevo en un momento.",
  supabase_update_failed_reserva_liberada: "No pudimos guardar tu reserva y la liberamos. No se hizo ningún cargo; intenta de nuevo.",
};

const campo = {
  height: 44,
  border: "1px solid #cbd5e1",
  borderRadius: 10,
  padding: "0 12px",
  background: "#fff",
  boxSizing: "border-box",
};

/**
 * Formulario de tarjeta (Secure Fields de Mercado Pago) para RESERVAR el total de un encargo.
 * El número de tarjeta nunca toca nuestro código: MP devuelve un token.
 */
export default function ReservaTarjetaMP({ pedidoId, monto, email, guest = false, guestPhone, clienteToken, onReservado }) {
  const [listo, setListo] = useState(false);
  const [errorSdk, setErrorSdk] = useState("");
  const [titular, setTitular] = useState("");
  const [metodo, setMetodo] = useState(null);
  const [enviando, setEnviando] = useState(false);
  const [error, setError] = useState("");
  const mpRef = useRef(null);
  const montados = useRef([]);
  const idBase = `fc-reserva-${pedidoId}`;

  useEffect(() => {
    let vivo = true;
    cargarSdkMercadoPago()
      .then((MercadoPago) => {
        if (!vivo) return;
        const mp = new MercadoPago(MP_PUBLIC_KEY, { locale: "es-MX" });
        mpRef.current = mp;
        const estilo = { style: { fontSize: "15px", color: "#0f172a" } };
        const numero = mp.fields.create("cardNumber", { placeholder: "Número de tarjeta", ...estilo }).mount(`${idBase}-numero`);
        const vence = mp.fields.create("expirationDate", { placeholder: "MM/AA", ...estilo }).mount(`${idBase}-vence`);
        const cvv = mp.fields.create("securityCode", { placeholder: "CVV", ...estilo }).mount(`${idBase}-cvv`);
        montados.current = [numero, vence, cvv];
        numero.on("binChange", async ({ bin }) => {
          if (!bin) { setMetodo(null); return; }
          try {
            const r = await mp.getPaymentMethods({ bin });
            const pm = r?.results?.[0] || null;
            setMetodo(pm ? { id: pm.id, tipo: pm.payment_type_id, nombre: pm.name } : null);
          } catch {
            setMetodo(null);
          }
        });
        setListo(true);
      })
      .catch(() => vivo && setErrorSdk("No se pudo cargar el formulario seguro de Mercado Pago. Revisa tu conexión y recarga."));
    return () => {
      vivo = false;
      montados.current.forEach((f) => { try { f.unmount(); } catch { /* noop */ } });
      montados.current = [];
    };
  }, [idBase]);

  const reservar = async () => {
    setError("");
    if (titular.trim().length < 3) { setError("Escribe el nombre como aparece en la tarjeta."); return; }
    if (!metodo) { setError("Revisa el número de tarjeta."); return; }
    if (metodo.tipo !== "credit_card") { setError(MENSAJES_RESERVA.solo_tarjeta_credito); return; }
    setEnviando(true);
    try {
      const tok = await mpRef.current.fields.createCardToken({ cardholderName: titular.trim() });
      if (!tok?.id) throw new Error("sin_token");
      const resp = await fetch("/api/payments/mp/create-preference", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          ...(clienteToken ? { Authorization: `Bearer ${clienteToken}` } : {}),
        },
        body: JSON.stringify({
          modo: "reserva",
          pedidoId,
          amount: monto,
          cardToken: tok.id,
          paymentMethodId: metodo.id,
          paymentTypeId: metodo.tipo,
          payer: { email },
          guest,
          guestPhone: guest ? guestPhone : undefined,
        }),
      });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok || !data?.ok) {
        setError(MENSAJES_RESERVA[data?.error] || "No se pudo apartar con esta tarjeta. Intenta de nuevo.");
        setEnviando(false);
        return;
      }
      onReservado?.(data);
    } catch {
      setError("Revisa los datos de la tarjeta (número, vencimiento y CVV).");
      setEnviando(false);
    }
  };

  return (
    <div style={{ border: "1px solid #e2e8f0", borderRadius: 14, padding: 16, background: "#fff" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 8, fontWeight: 800, color: "#0f172a", marginBottom: 6 }}>
        <ShieldCheck size={18} color={BRAND.accent} aria-hidden /> Apartar con tarjeta de crédito
      </div>
      <p style={{ margin: "0 0 14px", color: "#475569", fontSize: 13, lineHeight: 1.55 }}>
        Reservamos <strong>{$(monto)}</strong> en tu tarjeta; <strong>no se cobra todavía</strong>. Lo cobramos cuando
        conseguimos tu producto. Si no lo conseguimos en {DIAS_RESERVA_MP} días, cancelamos la reserva y tu banco libera el
        monto sin cargo.
      </p>

      {errorSdk ? (
        <div role="alert" style={{ color: "#b91c1c", fontSize: 13, marginBottom: 10 }}>{errorSdk}</div>
      ) : null}

      <label style={{ display: "block", fontSize: 12, fontWeight: 700, color: "#475569", marginBottom: 4 }} htmlFor={`${idBase}-titular`}>
        Nombre del titular
      </label>
      <input
        id={`${idBase}-titular`}
        value={titular}
        onChange={(e) => setTitular(e.target.value)}
        autoComplete="cc-name"
        placeholder="Como aparece en la tarjeta"
        style={{ ...campo, width: "100%", fontSize: 15, fontFamily: "inherit", marginBottom: 10 }}
      />
      <div style={{ fontSize: 12, fontWeight: 700, color: "#475569", marginBottom: 4 }}>Tarjeta</div>
      <div id={`${idBase}-numero`} style={{ ...campo, marginBottom: 10 }} />
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 10 }}>
        <div id={`${idBase}-vence`} style={campo} />
        <div id={`${idBase}-cvv`} style={campo} />
      </div>
      {metodo ? (
        <div style={{ fontSize: 12, color: metodo.tipo === "credit_card" ? "#475569" : "#b91c1c", marginBottom: 8, display: "flex", alignItems: "center", gap: 6 }}>
          <CreditCard size={14} aria-hidden /> {metodo.nombre || metodo.id}
          {metodo.tipo === "credit_card" ? " · crédito" : " · débito: no permite reservar"}
        </div>
      ) : null}

      {error ? <div role="alert" style={{ color: "#b91c1c", fontSize: 13, margin: "4px 0 10px" }}>{error}</div> : null}

      <Btn col={BRAND.primary} full onClick={reservar} disabled={!listo || enviando || Boolean(errorSdk)}>
        {enviando ? "Apartando…" : `Apartar ${$(monto)}`}
      </Btn>
      <div style={{ color: "#64748b", fontSize: 11, textAlign: "center", marginTop: 8, display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
        <Lock size={12} aria-hidden /> Datos de tarjeta protegidos por Mercado Pago
      </div>
    </div>
  );
}
