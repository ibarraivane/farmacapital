/**
 * Safari / WebViews (p. ej. app de Google en iOS) a veces lanzan
 * SecurityError "The operation is insecure" al crear WebSocket.
 * Sin esto, @supabase/realtime-js revienta con "WebSocket not available: …"
 * y tumba toda la tienda.
 *
 * Devolvemos un transport que nunca lanza: si el WS real falla, un stub
 * cerrado para que Realtime quede offline sin romper React.
 */

function noopWebSocket() {
  const ws = {
    readyState: 3, // CLOSED
    bufferedAmount: 0,
    extensions: "",
    protocol: "",
    url: "",
    binaryType: "blob",
    onopen: null,
    onclose: null,
    onmessage: null,
    onerror: null,
    send() {},
    close() {},
    addEventListener() {},
    removeEventListener() {},
    dispatchEvent() {
      return false;
    },
  };
  queueMicrotask(() => {
    try {
      ws.onerror?.({ message: "WebSocket blocked in this browser context" });
    } catch (_) { /* noop */ }
    try {
      ws.onclose?.({ code: 1006, reason: "unavailable", wasClean: false });
    } catch (_) { /* noop */ }
  });
  return ws;
}

export function createSafeRealtimeTransport() {
  const Native = typeof WebSocket !== "undefined" ? WebSocket : null;
  if (!Native) return undefined;

  function SafeWebSocket(url, protocols) {
    try {
      return protocols !== undefined ? new Native(url, protocols) : new Native(url);
    } catch (err) {
      // eslint-disable-next-line no-console
      console.warn("[FarmaCapital] Realtime WebSocket bloqueado:", err?.message || err);
      return noopWebSocket();
    }
  }

  SafeWebSocket.CONNECTING = Native.CONNECTING;
  SafeWebSocket.OPEN = Native.OPEN;
  SafeWebSocket.CLOSING = Native.CLOSING;
  SafeWebSocket.CLOSED = Native.CLOSED;
  SafeWebSocket.prototype = Native.prototype;

  return SafeWebSocket;
}
