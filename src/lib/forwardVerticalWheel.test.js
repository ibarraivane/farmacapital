import {
  shouldForwardVerticalWheel,
  forwardVerticalWheelToPage,
  attachForwardVerticalWheel,
  attachTiendaHorizontalStripWheel,
  TIENDA_H_SCROLL_SELECTOR,
} from "./forwardVerticalWheel";

describe("forwardVerticalWheelToPage", () => {
  test("solo reenvía gestos verticales", () => {
    expect(shouldForwardVerticalWheel({ deltaY: 80, deltaX: 0 })).toBe(true);
    expect(shouldForwardVerticalWheel({ deltaY: -40, deltaX: 10 })).toBe(true);
    expect(shouldForwardVerticalWheel({ deltaY: 10, deltaX: 40 })).toBe(false);
    expect(shouldForwardVerticalWheel({ deltaY: 0, deltaX: 0 })).toBe(false);
    expect(shouldForwardVerticalWheel(null)).toBe(false);
  });

  test("baja la página con deltaY", () => {
    const moved = [];
    expect(forwardVerticalWheelToPage({ deltaY: 120, deltaX: 0 }, (y) => moved.push(y))).toBe(true);
    expect(moved).toEqual([120]);
  });

  test("no mueve la página si el gesto es horizontal", () => {
    const moved = [];
    expect(forwardVerticalWheelToPage({ deltaY: 8, deltaX: 40 }, (y) => moved.push(y))).toBe(false);
    expect(moved).toEqual([]);
  });
});

describe("attachForwardVerticalWheel", () => {
  test("escucha wheel y limpia", () => {
    const listeners = [];
    const el = {
      addEventListener: (type, fn) => listeners.push({ type, fn }),
      removeEventListener: (type, fn) => {
        const i = listeners.findIndex((l) => l.type === type && l.fn === fn);
        if (i >= 0) listeners.splice(i, 1);
      },
    };
    const off = attachForwardVerticalWheel(el);
    expect(listeners).toHaveLength(1);
    expect(listeners[0].type).toBe("wheel");
    off();
    expect(listeners).toHaveLength(0);
  });
});

describe("attachTiendaHorizontalStripWheel", () => {
  test("cubre las bandas de home y catálogo", () => {
    expect(TIENDA_H_SCROLL_SELECTOR).toMatch(/farmacapital-productos-strip/);
    expect(TIENDA_H_SCROLL_SELECTOR).toMatch(/farmacapital-home-services-scroll/);
    expect(TIENDA_H_SCROLL_SELECTOR).toMatch(/farmacapital-home-promos-scroll/);
  });

  test("solo reenvía si el target está dentro de una banda", () => {
    const moved = [];
    const spy = jest.spyOn(window, "scrollBy").mockImplementation((_x, y) => { moved.push(y); });
    const handlers = [];
    const root = {
      addEventListener: (_t, fn) => handlers.push(fn),
      removeEventListener: () => {},
    };
    attachTiendaHorizontalStripWheel(root);
    const inside = { closest: (sel) => (sel.includes("farmacapital-productos-strip") ? {} : null) };
    const outside = { closest: () => null };
    handlers[0]({ target: outside, deltaY: 90, deltaX: 0 });
    expect(moved).toEqual([]);
    handlers[0]({ target: inside, deltaY: 90, deltaX: 0 });
    expect(moved).toEqual([90]);
    spy.mockRestore();
  });
});
