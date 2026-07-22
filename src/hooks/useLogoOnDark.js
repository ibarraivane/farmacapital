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

function relativeLuminance(r, g, b) {
  const lin = [r, g, b].map((c) => {
    const v = c / 255;
    return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4;
  });
  return 0.2126 * lin[0] + 0.7152 * lin[1] + 0.0722 * lin[2];
}

function isDarkBackground(color) {
  const rgb = parseRgb(color);
  if (!rgb || rgb.a < 0.08) return null;
  return relativeLuminance(rgb.r, rgb.g, rgb.b) < 0.42;
}

function detectOnDark(el) {
  if (!el) return false;

  const marked = el.closest("[data-brand-surface]");
  if (marked) return marked.dataset.brandSurface === "dark";

  let node = el.parentElement;
  while (node && node !== document.documentElement) {
    const style = window.getComputedStyle(node);
    const dark = isDarkBackground(style.backgroundColor);
    if (dark !== null) return dark;
    node = node.parentElement;
  }

  return window.matchMedia("(prefers-color-scheme: dark)").matches;
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

    const mq = window.matchMedia("(prefers-color-scheme: dark)");
    mq.addEventListener("change", compute);
    window.addEventListener("resize", compute);

    return () => {
      ro?.disconnect();
      mq.removeEventListener("change", compute);
      window.removeEventListener("resize", compute);
    };
  }, [enabled, compute]);

  return { ref, onDark };
}
