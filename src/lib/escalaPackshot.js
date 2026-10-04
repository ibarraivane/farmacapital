/**
 * Acerca un packshot con margen blanco para que el producto llene la tarjeta.
 * El zoom es uniforme: no estira. Si el producto ya ocupa el recuadro, queda en 1
 * para no recortarlo.
 */

export const ESCALA_PACKSHOT_MAX = 2.8;
export const ESCALA_PACKSHOT_LLENADO = 0.92;

export function escalaPackshot({
  imgW,
  imgH,
  minX,
  minY,
  maxX,
  maxY,
  boxW,
  boxH,
  llenado = ESCALA_PACKSHOT_LLENADO,
  max = ESCALA_PACKSHOT_MAX,
} = {}) {
  if (!(imgW > 0 && imgH > 0 && boxW > 0 && boxH > 0)) return 1;
  const cw = Math.max(1, maxX - minX);
  const ch = Math.max(1, maxY - minY);
  const fit = Math.min(boxW / imgW, boxH / imgH);
  if (!(fit > 0)) return 1;
  const zoomW = (boxW * llenado) / (cw * fit);
  const zoomH = (boxH * llenado) / (ch * fit);
  const zoom = Math.min(zoomW, zoomH);
  if (!Number.isFinite(zoom) || zoom <= 1.04) return 1;
  return Math.min(zoom, max);
}

/** Pixel de fondo: el promedio de las esquinas. */
export function fondoDeEsquinas(data, width, height) {
  const puntos = [
    [0, 0],
    [width - 1, 0],
    [0, height - 1],
    [width - 1, height - 1],
  ];
  let r = 0;
  let g = 0;
  let b = 0;
  let n = 0;
  for (const [x, y] of puntos) {
    if (x < 0 || y < 0) continue;
    const i = (y * width + x) * 4;
    r += data[i];
    g += data[i + 1];
    b += data[i + 2];
    n += 1;
  }
  if (!n) return { r: 255, g: 255, b: 255 };
  return { r: r / n, g: g / n, b: b / n };
}

export function esMargen(r, g, b, a, fondo, tolerancia = 22) {
  if (a < 24) return true;
  return Math.abs(r - fondo.r) <= tolerancia
    && Math.abs(g - fondo.g) <= tolerancia
    && Math.abs(b - fondo.b) <= tolerancia;
}

/**
 * Recuadro del producto. El margen es solo el fondo que toca el borde
 * (inundación desde las orillas). El blanco de adentro de una caja se queda:
 * si no, el zoom recortaría la caja y dejaría solo la impresión.
 */
export function contenidoPackshot(data, width, height) {
  if (!(width > 0 && height > 0) || !data) return null;
  const fondo = fondoDeEsquinas(data, width, height);
  const visto = new Uint8Array(width * height);
  const pila = [];
  const marcar = (x, y) => {
    if (x < 0 || y < 0 || x >= width || y >= height) return;
    const p = y * width + x;
    if (visto[p]) return;
    const i = p * 4;
    if (!esMargen(data[i], data[i + 1], data[i + 2], data[i + 3], fondo)) return;
    visto[p] = 1;
    pila.push(p);
  };
  for (let x = 0; x < width; x += 1) {
    marcar(x, 0);
    marcar(x, height - 1);
  }
  for (let y = 1; y < height - 1; y += 1) {
    marcar(0, y);
    marcar(width - 1, y);
  }
  while (pila.length) {
    const p = pila.pop();
    const x = p % width;
    const y = (p - x) / width;
    marcar(x + 1, y);
    marcar(x - 1, y);
    marcar(x, y + 1);
    marcar(x, y - 1);
  }
  let minX = width;
  let minY = height;
  let maxX = -1;
  let maxY = -1;
  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      if (visto[y * width + x]) continue;
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
  }
  if (maxX < minX || maxY < minY) return null;
  return { minX, minY, maxX: maxX + 1, maxY: maxY + 1 };
}

export function zoomDeImagen(img, boxW, boxH) {
  const w = img?.naturalWidth || 0;
  const h = img?.naturalHeight || 0;
  if (!(w > 0 && h > 0) || typeof document === "undefined") return 1;
  const paso = w > 900 ? 8 : 4;
  const sw = Math.max(1, Math.round(w / paso));
  const sh = Math.max(1, Math.round(h / paso));
  const canvas = document.createElement("canvas");
  canvas.width = sw;
  canvas.height = sh;
  const ctx = canvas.getContext("2d", { willReadFrequently: true });
  if (!ctx) return 1;
  try {
    ctx.drawImage(img, 0, 0, sw, sh);
    const data = ctx.getImageData(0, 0, sw, sh).data;
    const contenido = contenidoPackshot(data, sw, sh);
    if (!contenido) return 1;
    return escalaPackshot({ imgW: sw, imgH: sh, ...contenido, boxW, boxH });
  } catch {
    return 1;
  }
}
