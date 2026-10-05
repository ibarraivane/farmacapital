import { clickNavegacionTienda } from "./enlaceTienda";

function ev(extra = {}) {
  return {
    defaultPrevented: false,
    button: 0,
    metaKey: false,
    ctrlKey: false,
    shiftKey: false,
    altKey: false,
    preventDefault: jest.fn(),
    ...extra,
  };
}

test("el clic normal se intercepta para la SPA", () => {
  const e = ev();
  expect(clickNavegacionTienda(e)).toBe(true);
  expect(e.preventDefault).toHaveBeenCalled();
});

test("Ctrl, Cmd, Shift, Alt o clic medio dejan el href nativo", () => {
  expect(clickNavegacionTienda(ev({ ctrlKey: true }))).toBe(false);
  expect(clickNavegacionTienda(ev({ metaKey: true }))).toBe(false);
  expect(clickNavegacionTienda(ev({ shiftKey: true }))).toBe(false);
  expect(clickNavegacionTienda(ev({ altKey: true }))).toBe(false);
  expect(clickNavegacionTienda(ev({ button: 1 }))).toBe(false);
});

test("si ya se evitó el default, no vuelve a interceptar", () => {
  const e = ev({ defaultPrevented: true });
  expect(clickNavegacionTienda(e)).toBe(false);
  expect(e.preventDefault).not.toHaveBeenCalled();
});
