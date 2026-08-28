import {
  CATALOGO_VIVO_EVENT,
  CATALOGO_VIVO_CHANNEL,
  avisarCatalogoCambio,
  crearDebounceCatalogo,
  suscribirCatalogoVivo,
} from "./catalogoVivo";

describe("crearDebounceCatalogo", () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });
  afterEach(() => {
    jest.useRealTimers();
  });

  test("junta varios avisos en una sola llamada", () => {
    const fn = jest.fn();
    const run = crearDebounceCatalogo(fn, 200);
    run("a");
    run("b");
    run("c");
    expect(fn).not.toHaveBeenCalled();
    jest.advanceTimersByTime(199);
    expect(fn).not.toHaveBeenCalled();
    jest.advanceTimersByTime(1);
    expect(fn).toHaveBeenCalledTimes(1);
    expect(fn).toHaveBeenCalledWith("c");
  });

  test("cancel evita la llamada", () => {
    const fn = jest.fn();
    const run = crearDebounceCatalogo(fn, 100);
    run();
    run.cancel();
    jest.advanceTimersByTime(200);
    expect(fn).not.toHaveBeenCalled();
  });
});

describe("avisarCatalogoCambio", () => {
  test("dispara el evento de la misma pestaña", () => {
    const heard = jest.fn();
    window.addEventListener(CATALOGO_VIVO_EVENT, heard);
    const detalle = avisarCatalogoCambio({ origen: "inventario" });
    expect(detalle.origen).toBe("inventario");
    expect(heard).toHaveBeenCalledTimes(1);
    expect(heard.mock.calls[0][0].detail.origen).toBe("inventario");
    window.removeEventListener(CATALOGO_VIVO_EVENT, heard);
  });
});

describe("suscribirCatalogoVivo", () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });
  afterEach(() => {
    jest.useRealTimers();
  });

  test("el evento local refresca sin recargar", () => {
    const onRefresh = jest.fn();
    const off = suscribirCatalogoVivo(onRefresh, { debounceMs: 50 });
    avisarCatalogoCambio({ origen: "test" });
    avisarCatalogoCambio({ origen: "test2" });
    jest.advanceTimersByTime(50);
    expect(onRefresh).toHaveBeenCalledTimes(1);
    off();
  });

  test("quita el listener al desuscribir", () => {
    const onRefresh = jest.fn();
    const off = suscribirCatalogoVivo(onRefresh, { debounceMs: 10 });
    off();
    avisarCatalogoCambio({ origen: "despues" });
    jest.advanceTimersByTime(20);
    expect(onRefresh).not.toHaveBeenCalled();
  });

  test("escucha postgres_changes si hay cliente supabase", () => {
    const onRefresh = jest.fn();
    const handlers = [];
    const channel = {
      on: jest.fn((_type, _filter, cb) => {
        handlers.push(cb);
        return channel;
      }),
      subscribe: jest.fn(() => channel),
    };
    const client = {
      channel: jest.fn(() => channel),
      removeChannel: jest.fn(),
    };
    const off = suscribirCatalogoVivo(onRefresh, { supabase: client, debounceMs: 20 });
    expect(client.channel).toHaveBeenCalled();
    expect(channel.on).toHaveBeenCalledTimes(3);
    handlers[0]({ table: "productos", eventType: "INSERT" });
    jest.advanceTimersByTime(20);
    expect(onRefresh).toHaveBeenCalledTimes(1);
    expect(onRefresh.mock.calls[0][0].table).toBe("productos");
    off();
    expect(client.removeChannel).toHaveBeenCalledWith(channel);
  });

  test("BroadcastChannel avisa a otras pestañas", () => {
    expect(CATALOGO_VIVO_CHANNEL).toBe("farmacapital-catalogo-vivo");
    if (typeof BroadcastChannel === "undefined") return;
    const onRefresh = jest.fn();
    const off = suscribirCatalogoVivo(onRefresh, { debounceMs: 10 });
    const bc = new BroadcastChannel(CATALOGO_VIVO_CHANNEL);
    bc.postMessage({ origen: "otra-pestana" });
    jest.advanceTimersByTime(10);
    expect(onRefresh).toHaveBeenCalled();
    bc.close();
    off();
  });
});
