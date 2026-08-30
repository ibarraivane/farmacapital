import { useEffect, useRef } from "react";
import { looksLikeCompleteScanInput, looksLikeInternalSku, normalizeBarcodeRaw } from "../utils/barcodeProductLookup";

function esCampoEditable(el) {
  if (!el || el === document.body || el === document.documentElement) return false;
  const tag = el.tagName;
  if (tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT") return true;
  return !!el.isContentEditable;
}

function esBusquedaPos(el) {
  return !!(el && el.classList && el.classList.contains("farmacapital-pos-srch"));
}

/**
 * Pistola USB/Bluetooth (HID teclado) en iPad: el campo de búsqueda suele estar
 * readonly para no abrir el teclado táctil, y el iPad no enfoca al escanear.
 * Capturamos ráfagas rápidas de dígitos + Enter a nivel documento.
 */
export function useHidBarcodeWedge({ enabled, onScan }) {
  const onScanRef = useRef(onScan);
  onScanRef.current = onScan;

  useEffect(() => {
    if (!enabled || typeof document === "undefined") return;

    let buf = "";
    let lastTs = 0;
    let idleTimer = 0;

    const reset = () => {
      buf = "";
      if (idleTimer) window.clearTimeout(idleTimer);
      idleTimer = 0;
    };

    const commit = () => {
      const raw = normalizeBarcodeRaw(buf) || buf.trim();
      reset();
      if (!raw) return;
      if (looksLikeCompleteScanInput(raw) || looksLikeInternalSku(raw)) {
        onScanRef.current?.(raw);
      }
    };

    const onKeyDown = (e) => {
      if (e.ctrlKey || e.metaKey || e.altKey) return;
      const target = e.target;
      const enOtroCampo = esCampoEditable(target) && !esBusquedaPos(target);
      const busquedaLibre = esBusquedaPos(target) && target.getAttribute("readonly") == null;

      // El input de POS ya maneja el escaneo si está enfocado y escribible.
      if (busquedaLibre) {
        reset();
        return;
      }

      const now = Date.now();
      const gap = lastTs ? now - lastTs : 0;
      lastTs = now;

      if (e.key === "Enter") {
        if (buf.length >= 8) {
          e.preventDefault();
          e.stopPropagation();
          commit();
        } else {
          reset();
        }
        return;
      }

      if (e.key.length !== 1) return;
      const ch = e.key;
      if (!/^[0-9A-Za-z._-]$/.test(ch)) {
        reset();
        return;
      }

      const rafaga = gap > 0 && gap <= 85;
      if (!rafaga) {
        buf = "";
        if (enOtroCampo) return;
      }

      buf += ch;
      if (buf.length > 40) buf = buf.slice(-40);
      if (idleTimer) window.clearTimeout(idleTimer);
      idleTimer = window.setTimeout(() => {
        if (looksLikeCompleteScanInput(buf) || looksLikeInternalSku(buf)) commit();
        else reset();
      }, 140);
    };

    document.addEventListener("keydown", onKeyDown, true);
    return () => {
      document.removeEventListener("keydown", onKeyDown, true);
      reset();
    };
  }, [enabled]);
}
