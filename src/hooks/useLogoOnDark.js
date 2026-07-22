import { useLayoutEffect, useState, useRef, useCallback } from "react";

function parseRgb(color) {
  if (!color || color === "transparent") return null;
  const m = color.match(/rgba?\(\s*([\d.]+)[,\s]+([\d.]+)[,\s]+([\d.]+)(?:[,\s/]+([\d.]+))?\s*\)/i);
  if (!m) return null;
  return {
    r: Number(m[1]),
    g: Number(m[2]),
    b: Number(m[3]),
    a: m[4] === undefined ? 1 : Number(m[4]),
  };
}

function parseHex(hex) {
  const h = hex.replace("#", "");
  if (h.length === 3) {
    return {
      r: parseInt(h[0] + h[0], 16),
      g: parseInt(h[1] + h[1], 16),
      b: parseInt(h[2] + h[2], 16),
      a: 1,
    };
  }
  if (h.length >= 6) {
    return {
      r: parseInt(h.slice(0, 2), 16),
      g: parseInt(h.slice(2, 4), 16),
      b: parseInt(h.slice(4, 6), 16),
      a: 1,
    };
  }
  return null;
}

function relativeLuminance(r, g, b) {
  const lin = [r, g, b].map((c) => {
    const v = c / 255;
    return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4;
  });
  return 0.2126 * lin[0] + 0.7152 * lin[1] + 0.0722 * lin[2];
}

function isDarkRgb(rgb) {
  if (!rgb || rgb.a < 0.08) return null;
  return relativeLuminance(rgb.r, rgb.g, rgb.b) < 0.42;
}

function isDarkBackground(color) {
  return isDarkRgb(parseRgb(color));
}

/** Gradients no exponen backgroundColor; tomamos el primer color del gradiente. */
function isDarkGradient(backgroundImage) {
  if (!backgroundImage || backgroundImage === "none") return null;

  const rgbInGradient = backgroundImage.match(/rgba?\(\s*[\d.]+\s*[,\s]+[\d.]+\s*[,\s]+[\d.]+(?:\s*[,\s/]+\s*[\d.]+)?\s*\)/i);
  if (rgbInGradient) return isDarkBackground(rgbInGradient[0]);

  const hexInGradient = backgroundImage.match(/#([0-9a-fA-F]{3,8})\b/);
  if (hexInGradient) return isDarkRgb(parseHex(hexInGradient[0]));

  return null;
}

function detectOnDark(el) {
  if (!el) return false;

  const marked = el.closest("[data-brand-surface]");
  if (marked) return marked.dataset.brandSurface === "dark";

  let node = el.parentElement;
  while (node && node !== document.documentElement) {
    const style = window.getComputedStyle(node);

    const fromColor = isDarkBackground(style.backgroundColor);
    if (fromColor !== null) return fromColor;

    const fromGradient = isDarkGradient(style.backgroundImage);
    if (fromGradient !== null) return fromGradient;

    node = node.parentElement;
  }

  // Fondo indeterminado → logo a color (no usar prefers-color-scheme: eso es solo para favicon)
  return false;
}

/** Detecta si el logo debe usar variante light (fondos oscuros). */
export function useLogoOnDark(enabled = true) {
  const ref = useRef(null);
  const [onDark, setOnDark] = useState(false);

  const compute = useCallback(() => {
    if (!enabled) return;
    setOnDark(detectOnDark(ref.current));
  }, [enabled]);

  useLayoutEffect(() => {
    if (!enabled) return;
    compute();
    const el = ref.current;
    if (!el) return;

    const ro = typeof ResizeObserver !== "undefined" ? new ResizeObserver(compute) : null;
    ro?.observe(el);
    window.addEventListener("resize", compute);

    return () => {
      ro?.disconnect();
      window.removeEventListener("resize", compute);
    };
  }, [enabled, compute]);

  return { ref, onDark };
}
