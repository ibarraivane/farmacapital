import { createSafeRealtimeTransport } from "./safeRealtimeTransport";

describe("createSafeRealtimeTransport", () => {
  it("devuelve un constructor usable cuando WebSocket existe", () => {
    const Transport = createSafeRealtimeTransport();
    expect(typeof Transport).toBe("function");
    expect(Transport.OPEN).toBe(1);
  });

  it("no lanza si el WebSocket nativo falla (SecurityError)", () => {
    const RealWS = global.WebSocket;
    global.WebSocket = class {
      constructor() {
        throw new DOMException("The operation is insecure.", "SecurityError");
      }
    };
    try {
      const Transport = createSafeRealtimeTransport();
      expect(() => new Transport("wss://example.test/socket")).not.toThrow();
      const sock = new Transport("wss://example.test/socket");
      expect(sock.readyState).toBe(3);
    } finally {
      global.WebSocket = RealWS;
    }
  });
});
