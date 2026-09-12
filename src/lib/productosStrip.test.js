import { stripArrowState, stripPageScrollLeft } from "./productosStrip";

describe("stripArrowState", () => {
  test("sin elemento o sin overflow: ambas flechas apagadas", () => {
    expect(stripArrowState(null)).toEqual({ canPrev: false, canNext: false });
    expect(stripArrowState({ scrollLeft: 0, scrollWidth: 800, clientWidth: 800 }))
      .toEqual({ canPrev: false, canNext: false });
    expect(stripArrowState({ scrollLeft: 0, scrollWidth: 804, clientWidth: 800 }))
      .toEqual({ canPrev: false, canNext: false });
  });

  test("al inicio solo hay flecha siguiente", () => {
    expect(stripArrowState({ scrollLeft: 0, scrollWidth: 2000, clientWidth: 800 }))
      .toEqual({ canPrev: false, canNext: true });
  });

  test("a la mitad hay ambas flechas", () => {
    expect(stripArrowState({ scrollLeft: 400, scrollWidth: 2000, clientWidth: 800 }))
      .toEqual({ canPrev: true, canNext: true });
  });

  test("al final solo hay flecha anterior", () => {
    expect(stripArrowState({ scrollLeft: 1200, scrollWidth: 2000, clientWidth: 800 }))
      .toEqual({ canPrev: true, canNext: false });
  });
});

describe("stripPageScrollLeft", () => {
  test("avanza una página y no se pasa del final", () => {
    const el = { scrollLeft: 0, scrollWidth: 2000, clientWidth: 800 };
    expect(stripPageScrollLeft(el, 1)).toBe(800);
    // max = 2000 - 800 = 1200
    expect(stripPageScrollLeft({ ...el, scrollLeft: 800 }, 1)).toBe(1200);
    expect(stripPageScrollLeft({ ...el, scrollLeft: 1200 }, 1)).toBe(1200);
  });

  test("retrocede una página y no pasa de 0", () => {
    const el = { scrollLeft: 800, scrollWidth: 2000, clientWidth: 800 };
    expect(stripPageScrollLeft(el, -1)).toBe(0);
    expect(stripPageScrollLeft({ ...el, scrollLeft: 0 }, -1)).toBe(0);
  });

  test("sin elemento queda en 0", () => {
    expect(stripPageScrollLeft(null, 1)).toBe(0);
  });
});
