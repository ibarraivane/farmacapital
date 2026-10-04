const { escalaPackshot, contenidoPackshot } = require("./escalaPackshot");

test("un tubo con mucho margen blanco se acerca y no se estira", () => {
  const zoom = escalaPackshot({
    imgW: 591,
    imgH: 591,
    minX: 40,
    minY: 228,
    maxX: 552,
    maxY: 362,
    boxW: 216,
    boxH: 131,
  });
  expect(zoom).toBeGreaterThan(1.5);
  expect(zoom).toBeLessThan(2.2);
});

test("una caja chica en un cuadro grande se acerca hasta llenar el alto", () => {
  const zoom = escalaPackshot({
    imgW: 1200,
    imgH: 1200,
    minX: 239,
    minY: 385,
    maxX: 961,
    maxY: 815,
    boxW: 360,
    boxH: 131,
  });
  expect(zoom).toBeGreaterThan(2);
  expect(zoom).toBeLessThanOrEqual(2.8);
});

test("un packshot que ya llena el recuadro no se recorta", () => {
  expect(escalaPackshot({
    imgW: 1000,
    imgH: 1000,
    minX: 25,
    minY: 25,
    maxX: 975,
    maxY: 975,
    boxW: 240,
    boxH: 131,
  })).toBe(1);
});

test("el margen blanco de las esquinas no cuenta como producto", () => {
  const w = 8;
  const h = 8;
  const data = new Uint8ClampedArray(w * h * 4);
  for (let i = 0; i < data.length; i += 4) {
    data[i] = 255;
    data[i + 1] = 255;
    data[i + 2] = 255;
    data[i + 3] = 255;
  }
  const pintar = (x, y) => {
    const i = (y * w + x) * 4;
    data[i] = 20;
    data[i + 1] = 80;
    data[i + 2] = 180;
  };
  pintar(3, 4);
  pintar(4, 4);
  const box = contenidoPackshot(data, w, h);
  expect(box.minX).toBe(3);
  expect(box.maxX).toBe(5);
  expect(box.minY).toBe(4);
  expect(box.maxY).toBe(5);
});

test("el blanco de adentro de la caja cuenta como producto", () => {
  const w = 10;
  const h = 10;
  const data = new Uint8ClampedArray(w * h * 4);
  for (let i = 0; i < data.length; i += 4) {
    data[i] = 255;
    data[i + 1] = 255;
    data[i + 2] = 255;
    data[i + 3] = 255;
  }
  const pintar = (x, y) => {
    const i = (y * w + x) * 4;
    data[i] = 20;
    data[i + 1] = 90;
    data[i + 2] = 40;
  };
  for (let x = 2; x <= 7; x += 1) {
    pintar(x, 2);
    pintar(x, 7);
  }
  for (let y = 2; y <= 7; y += 1) {
    pintar(2, y);
    pintar(7, y);
  }
  const box = contenidoPackshot(data, w, h);
  expect(box.minX).toBe(2);
  expect(box.maxX).toBe(8);
  expect(box.minY).toBe(2);
  expect(box.maxY).toBe(8);
});
