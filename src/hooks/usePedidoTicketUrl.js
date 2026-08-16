import { useEffect, useState } from "react";
import { ensurePedidoTicketUrl } from "../utils/orderReceiptWhatsApp";

/** Obtiene o crea recibo_token → URL pública /r/{token} para QR del ticket impreso. */
export function usePedidoTicketUrl(pedidoId, enabled = true) {
  const [ticketUrl, setTicketUrl] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!enabled || !pedidoId) {
      setTicketUrl(null);
      setLoading(false);
      return undefined;
    }

    let cancelled = false;
    setLoading(true);
    setTicketUrl(null);

    ensurePedidoTicketUrl(pedidoId).then((result) => {
      if (cancelled) return;
      setTicketUrl(result.ok ? result.ticketUrl : null);
      setLoading(false);
    });

    return () => {
      cancelled = true;
    };
  }, [pedidoId, enabled]);

  return { ticketUrl, loading };
}
