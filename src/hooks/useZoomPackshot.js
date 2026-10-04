import { useEffect, useState } from "react";
import { zoomDeImagen } from "../lib/escalaPackshot";
import { tiendaCardImageUrl } from "../utils/tiendaCardImage";

/** Hueco real de la foto: el padding no entra, porque la imagen vive adentro. */
export function cajaFotoSinPadding(el) {
  if (!el || typeof window === "undefined") return { boxW: 0, boxH: 0 };
  const estilo = window.getComputedStyle(el);
  const padX = (parseFloat(estilo.paddingLeft) || 0) + (parseFloat(estilo.paddingRight) || 0);
  const padY = (parseFloat(estilo.paddingTop) || 0) + (parseFloat(estilo.paddingBottom) || 0);
  return {
    boxW: Math.max(0, el.clientWidth - padX),
    boxH: Math.max(0, el.clientHeight - padY),
  };
}

/**
 * Zoom uniforme del packshot dentro del recuadro. Mide una copia con CORS
 * para no poner crossOrigin en la foto visible: si el host no lo permite,
 * la tarjeta se quedaría en blanco.
 */
export function useZoomPackshot(imgSrc, boxRef) {
  const [zoom, setZoom] = useState(1);

  useEffect(() => {
    setZoom(1);
    const url = tiendaCardImageUrl(imgSrc);
    if (!url) return undefined;
    let cancelado = false;
    let probeListo = null;

    const aplicar = () => {
      const img = probeListo;
      if (cancelado || !img?.naturalWidth) return;
      const { boxW, boxH } = cajaFotoSinPadding(boxRef?.current);
      if (!(boxW > 0 && boxH > 0)) return;
      setZoom(zoomDeImagen(img, boxW, boxH));
    };

    const probe = new Image();
    probe.crossOrigin = "anonymous";
    probe.onload = () => {
      probeListo = probe;
      aplicar();
    };
    probe.src = url;

    const el = boxRef?.current;
    let obs;
    if (el && typeof ResizeObserver === "function") {
      obs = new ResizeObserver(() => aplicar());
      obs.observe(el);
    }

    return () => {
      cancelado = true;
      obs?.disconnect();
    };
  }, [imgSrc, boxRef]);

  return zoom;
}
