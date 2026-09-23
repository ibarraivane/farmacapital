import { aplicarLente, indiceEnRango, posicionLupa } from "./lupaFoto";

it("indiceEnRango se queda dentro de la lista", () => {
  expect(indiceEnRango(0, 3)).toBe(0);
  expect(indiceEnRango(2, 3)).toBe(2);
  expect(indiceEnRango(9, 3)).toBe(2);
  expect(indiceEnRango(-1, 3)).toBe(0);
  expect(indiceEnRango(Number.NaN, 3)).toBe(0);
  expect(indiceEnRango(1, 0)).toBe(0);
});

it("la lente se centra en el cursor y agranda esa zona", () => {
  const pos = posicionLupa(
    { left: 10, top: 20, width: 400, height: 300 },
    210,
    170,
    { lente: 148, zoom: 2.5 },
  );
  expect(pos.left).toBe(200 - 74);
  expect(pos.top).toBe(150 - 74);
  expect(pos.backgroundSize).toBe("1000px 750px");
  expect(pos.backgroundPosition).toBe(`${74 - 200 * 2.5}px ${74 - 150 * 2.5}px`);
});

it("no muestra lente si la foto es chica o el cursor se salió", () => {
  const chica = { left: 0, top: 0, width: 80, height: 80 };
  expect(posicionLupa(chica, 10, 10)).toBeNull();
  const grande = { left: 0, top: 0, width: 400, height: 400 };
  expect(posicionLupa(grande, -1, 10)).toBeNull();
  expect(posicionLupa(grande, 10, 500)).toBeNull();
  expect(posicionLupa(null, 10, 10)).toBeNull();
});

it("aplicarLente esconde o pinta la foto ampliada", () => {
  const el = { style: {} };
  aplicarLente(el, null);
  expect(el.style.opacity).toBe("0");
  aplicarLente(
    el,
    { left: 4, top: 6, backgroundSize: "20px 20px", backgroundPosition: "1px 2px" },
    'https://x.test/a"b.webp',
  );
  expect(el.style.opacity).toBe("1");
  expect(el.style.left).toBe("4px");
  expect(el.style.backgroundImage).toBe('url("https://x.test/a%22b.webp")');
  expect(el.style.backgroundPosition).toBe("1px 2px");
  aplicarLente(null, null);
});
