/**
 * Escala imágenes antes de subirlas, preservando el formato cuando el navegador lo permite.
 * Genera pares escritorio / móvil para banners y productos (GIF y SVG: un solo archivo, misma URL).
 */

const PRESETS = {
  bannerDesktop: { maxWidth: 1920, maxHeight: 600 },
  bannerMobile: { maxWidth: 1080, maxHeight: 1080 },
  productDesktop: { maxWidth: 1200, maxHeight: 1200 },
  productMobile: { maxWidth: 900, maxHeight: 900 },
};

const JPEG_Q = 0.88;
const WEBP_Q = 0.9;

let webpEncodeCache;
function canEncodeWebP() {
  if (webpEncodeCache !== undefined) return webpEncodeCache;
  try {
    const c = document.createElement("canvas");
    webpEncodeCache = c.toDataURL("image/webp").indexOf("data:image/webp") === 0;
  } catch {
    webpEncodeCache = false;
  }
  return webpEncodeCache;
}

/** Extensión de archivo acorde al MIME */
export function extFromContentType(ct) {
  const m = String(ct || "").toLowerCase();
  if (m === "image/png") return "png";
  if (m === "image/webp") return "webp";
  if (m === "image/gif") return "gif";
  if (m === "image/svg+xml") return "svg";
  if (m === "image/jpeg" || m === "image/jpg") return "jpg";
  if (m === "image/bmp" || m === "image/x-ms-bmp") return "bmp";
  return "png";
}

/** MIME de salida al re-encodear raster (respeta PNG/WebP/JPEG; resto ��� PNG) */
function outputMimeFromInput(inputMime) {
  const m = String(inputMime || "").toLowerCase();
  if (m === "image/png") return "image/png";
  if (m === "image/webp") return canEncodeWebP() ? "image/webp" : "image/png";
  if (m === "image/jpeg" || m === "image/jpg") return "image/jpeg";
  return "image/png";
}

const IMAGE_DECODE_MS = 25000;

function loadImageElement(file) {
  return new Promise((resolve, reject) => {
    const url = URL.createObjectURL(file);
    const to = setTimeout(() => {
      try {
        URL.revokeObjectURL(url);
      } catch (_) {
        /* ignore */
      }
      reject(new Error("Tiempo agotado al leer la imagen (prueba otra foto o exporta como JPEG estándar)."));
    }, IMAGE_DECODE_MS);
    const img = new Image();
    img.onload = () => {
      clearTimeout(to);
      URL.revokeObjectURL(url);
      resolve(img);
    };
    img.onerror = () => {
      clearTimeout(to);
      URL.revokeObjectURL(url);
      reject(new Error("No se pudo leer la imagen"));
    };
    img.src = url;
  });
}

async function getDrawable(file) {
  if (typeof createImageBitmap === "function") {
    try {
      const bm = await Promise.race([
        createImageBitmap(file, { imageOrientation: "from-image" }),
        new Promise((_, rej) =>
          setTimeout(() => rej(new Error("bitmap-timeout")), 12000)
        ),
      ]);
      return {
        width: bm.width,
        height: bm.height,
        draw(ctx, dx, dy, dw, dh) {
          ctx.drawImage(bm, dx, dy, dw, dh);
        },
        dispose() {
          try {
            bm.close();
          } catch (_) {
            /* ignore */
          }
        },
      };
    } catch (_) {
      /* Algunos JPEG/progresivos o marcas de agua cuelgan el decodificador: usar <img> */
    }
  }
  const img = await loadImageElement(file);
  return {
    width: img.naturalWidth || img.width,
    height: img.naturalHeight || img.height,
    draw(ctx, dx, dy, dw, dh) {
      ctx.drawImage(img, dx, dy, dw, dh);
    },
    dispose() {},
  };
}

function baseName(file) {
  const n = String(file?.name || "imagen");
  const i = n.lastIndexOf(".");
  return i > 0 ? n.slice(0, i) : n;
}

async function canvasToBlob(canvas, mime) {
  return new Promise((resolve, reject) => {
    const to = setTimeout(
      () => reject(new Error("Tiempo agotado al comprimir la imagen")),
      25000
    );
    const done = (b) => {
      clearTimeout(to);
      if (b) resolve(b);
      else reject(new Error("No se pudo generar la imagen"));
    };
    if (mime === "image/jpeg") canvas.toBlob(done, mime, JPEG_Q);
    else if (mime === "image/webp") canvas.toBlob(done, mime, WEBP_Q);
    else canvas.toBlob(done, mime);
  });
}

/**
 * Una sola versión escalada (raster).
 * @param {typeof PRESETS[keyof typeof PRESETS]} box
 */
async function scaleOnce(drawable, box, outputMime, nameBase) {
  const w = drawable.width;
  const h = drawable.height;
  if (!w || !h) throw new Error("Dimensiones inválidas");
  const scale = Math.min(box.maxWidth / w, box.maxHeight / h, 1);
  const tw = Math.max(1, Math.round(w * scale));
  const th = Math.max(1, Math.round(h * scale));
  const canvas = document.createElement("canvas");
  canvas.width = tw;
  canvas.height = th;
  const ctx = canvas.getContext("2d");
  if (!ctx) throw new Error("Canvas no disponible");
  ctx.imageSmoothingEnabled = true;
  ctx.imageSmoothingQuality = "high";
  if (outputMime === "image/jpeg") {
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(0, 0, tw, th);
  }
  drawable.draw(ctx, 0, 0, tw, th);
  const blob = await canvasToBlob(canvas, outputMime);
  const ext = extFromContentType(outputMime);
  return new File([blob], `${nameBase}-${tw}x${th}.${ext}`, { type: outputMime });
}

function isPassiveDualFormat(file) {
  const t = file?.type || "";
  return t === "image/gif" || t === "image/svg+xml";
}

/**
 * Banners: versión web + versión móvil desde un archivo.
 * @returns {Promise<{ mode:'single', file: File, contentType: string } | { mode:'dual', desktop: { file: File, contentType: string }, mobile: { file: File, contentType: string } }>}
 */
export async function prepareBannerDualForUpload(file) {
  if (!file?.type?.startsWith("image/")) {
    throw new Error("Selecciona un archivo de imagen");
  }
  if (isPassiveDualFormat(file)) {
    return { mode: "single", file, contentType: file.type };
  }

  const outputMime = outputMimeFromInput(file.type);
  const drawable = await getDrawable(file);
  try {
    const nm = baseName(file);
    const desktopFile = await scaleOnce(drawable, PRESETS.bannerDesktop, outputMime, nm);
    const mobileFile = await scaleOnce(drawable, PRESETS.bannerMobile, outputMime, nm);
    return {
      mode: "dual",
      desktop: { file: desktopFile, contentType: outputMime },
      mobile: { file: mobileFile, contentType: outputMime },
    };
  } finally {
    drawable.dispose();
  }
}

/**
 * Productos: versión catálogo escritorio + móvil.
 */
export async function prepareProductDualForUpload(file) {
  if (!file?.type?.startsWith("image/")) {
    throw new Error("Selecciona un archivo de imagen");
  }
  if (isPassiveDualFormat(file)) {
    return { mode: "single", file, contentType: file.type };
  }

  const outputMime = outputMimeFromInput(file.type);
  const drawable = await getDrawable(file);
  try {
    const nm = baseName(file);
    const desktopFile = await scaleOnce(drawable, PRESETS.productDesktop, outputMime, nm);
    const mobileFile = await scaleOnce(drawable, PRESETS.productMobile, outputMime, nm);
    return {
      mode: "dual",
      desktop: { file: desktopFile, contentType: outputMime },
      mobile: { file: mobileFile, contentType: outputMime },
    };
  } finally {
    drawable.dispose();
  }
}

/** Compatibilidad: una sola escala (p. ej. llamadas antiguas) */
export async function prepareImageForUpload(file, presetKey) {
  const map = {
    bannerDesktop: PRESETS.bannerDesktop,
    bannerMobile: PRESETS.bannerMobile,
    product: PRESETS.productDesktop,
  };
  const box = map[presetKey] || PRESETS.productDesktop;
  if (!file?.type?.startsWith("image/")) throw new Error("No es imagen");
  if (isPassiveDualFormat(file)) return { file, contentType: file.type };
  const outputMime = outputMimeFromInput(file.type);
  const drawable = await getDrawable(file);
  try {
    const f = await scaleOnce(drawable, box, outputMime, baseName(file));
    return { file: f, contentType: outputMime };
  } finally {
    drawable.dispose();
  }
}
