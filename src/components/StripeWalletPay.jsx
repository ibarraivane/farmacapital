import { loadStripe } from "@stripe/stripe-js";
import { Elements, ExpressCheckoutElement, useElements, useStripe } from "@stripe/react-stripe-js";
import { useMemo, useState } from "react";

const publishableKey = String(process.env.REACT_APP_STRIPE_PUBLISHABLE_KEY || "").trim();

let stripePromise = null;
export function getStripeJs() {
  if (!publishableKey) return null;
  if (!stripePromise) stripePromise = loadStripe(publishableKey);
  return stripePromise;
}

export function isStripeWalletConfigured() {
  return Boolean(publishableKey);
}

function WalletInner({ pedidoId, totalLabel, onPaid, onError, onUnavailable }) {
  const stripe = useStripe();
  const elements = useElements();
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState(null);

  const onConfirm = async () => {
    if (!stripe || !elements) return;
    setBusy(true);
    setMsg(null);
    try {
      const { error, paymentIntent } = await stripe.confirmPayment({
        elements,
        confirmParams: {
          return_url: `${window.location.origin}/?payment=success&pedido=${pedidoId}`,
        },
        redirect: "if_required",
      });
      if (error) {
        setMsg(error.message || "No se pudo completar el pago.");
        onError?.(error.message || "Pago cancelado o rechazado");
        setBusy(false);
        return;
      }
      if (paymentIntent?.status === "succeeded" || paymentIntent?.status === "processing") {
        onPaid?.(paymentIntent);
        return;
      }
      setMsg("Pago pendiente de confirmación.");
      onError?.("Pago pendiente");
    } catch (e) {
      const m = e?.message || "Error al confirmar el pago";
      setMsg(m);
      onError?.(m);
    }
    setBusy(false);
  };

  return (
    <div>
      <ExpressCheckoutElement
        options={{
          buttonHeight: 48,
          paymentMethods: {
            applePay: "always",
            googlePay: "always",
            link: "never",
            paypal: "never",
            amazonPay: "never",
          },
        }}
        onConfirm={onConfirm}
        onCancel={() => {
          setMsg("Pago cancelado.");
          onError?.("Pago cancelado");
        }}
        onReady={({ availablePaymentMethods }) => {
          const has =
            availablePaymentMethods &&
            (availablePaymentMethods.applePay || availablePaymentMethods.googlePay);
          if (!has) onUnavailable?.();
        }}
      />
      {busy && (
        <div style={{ marginTop: 10, fontSize: 13, color: "#64748b" }}>Confirmando pago…</div>
      )}
      {msg && (
        <div style={{ marginTop: 10, fontSize: 13, color: "#b45309" }}>{msg}</div>
      )}
      {totalLabel ? (
        <div style={{ marginTop: 8, fontSize: 12, color: "#64748b" }}>
          Total a cobrar: {totalLabel}
        </div>
      ) : null}
    </div>
  );
}

/**
 * Apple Pay / Google Pay via Stripe Express Checkout.
 * Only mounts when clientSecret is present and Stripe is configured.
 */
export default function StripeWalletPay({
  clientSecret,
  pedidoId,
  totalLabel,
  onPaid,
  onError,
  onUnavailable,
}) {
  const stripe = useMemo(() => getStripeJs(), []);
  if (!stripe || !clientSecret) return null;

  return (
    <Elements
      stripe={stripe}
      options={{
        clientSecret,
        appearance: {
          variables: {
            borderRadius: "10px",
          },
        },
      }}
    >
      <WalletInner
        pedidoId={pedidoId}
        totalLabel={totalLabel}
        onPaid={onPaid}
        onError={onError}
        onUnavailable={onUnavailable}
      />
    </Elements>
  );
}
