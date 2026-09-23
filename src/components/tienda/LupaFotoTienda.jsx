import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import GaleriaProducto from "../GaleriaProducto";
import { C_LIGHT } from "../../constants";

/**
 * Foto de la ficha en grande. El POS abre la misma galería en un modal de
 * formulario (560px); en la tienda el cliente necesita ver el empaque, así
 * que el recuadro usa casi toda la pantalla. Cierra con la X, Escape o un
 * toque afuera.
 */
export default function LupaFotoTienda({
  open,
  onClose,
  imagenes = [],
  alt = "",
  indice = 0,
  onIndiceChange,
}) {
  const C = C_LIGHT;
  const closeRef = useRef(null);
  const onCloseRef = useRef(onClose);
  onCloseRef.current = onClose;
  const [alto, setAlto] = useState(640);

  useEffect(() => {
    if (!open) return undefined;
    const medir = () => {
      const h = window.innerHeight || 800;
      setAlto(Math.max(280, Math.min(860, Math.round(h - 168))));
    };
    medir();
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    const onKey = (e) => {
      if (e.key === "Escape") {
        e.preventDefault();
        onCloseRef.current?.();
      }
    };
    document.addEventListener("keydown", onKey);
    window.addEventListener("resize", medir);
    const t = setTimeout(() => closeRef.current?.focus?.(), 0);
    return () => {
      document.body.style.overflow = prev || "auto";
      document.removeEventListener("keydown", onKey);
      window.removeEventListener("resize", medir);
      clearTimeout(t);
    };
  }, [open]);

  if (!open) return null;

  const moverConFlecha = (e) => {
    if (e.key !== "ArrowLeft" && e.key !== "ArrowRight") return;
    if (e.target?.closest?.("[data-galeria-fotos]")) return;
    const label = e.key === "ArrowLeft" ? "Foto anterior" : "Foto siguiente";
    const btn = e.currentTarget.querySelector(`[aria-label="${label}"]`);
    if (!btn) return;
    e.preventDefault();
    btn.click();
  };

  const cuadro = (
    <div
      role="presentation"
      onClick={() => onClose?.()}
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 1300,
        background: "rgba(0,21,52,.72)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "max(12px, env(safe-area-inset-top, 0px)) max(12px, env(safe-area-inset-right, 0px)) max(12px, env(safe-area-inset-bottom, 0px)) max(12px, env(safe-area-inset-left, 0px))",
        boxSizing: "border-box",
        overscrollBehavior: "contain",
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label={alt ? `Foto ampliada de ${alt}` : "Foto ampliada"}
        tabIndex={-1}
        onClick={(e) => e.stopPropagation()}
        onKeyDown={moverConFlecha}
        style={{
          background: C.card,
          borderRadius: 16,
          width: "min(960px, 100%)",
          maxHeight: "min(92dvh, 92vh)",
          overflow: "auto",
          WebkitOverflowScrolling: "touch",
          boxShadow: "0 16px 48px rgba(0,21,52,.28)",
          padding: "16px 16px 20px",
          boxSizing: "border-box",
          outline: "none",
          position: "relative",
        }}
      >
        <div style={{ display: "flex", alignItems: "flex-start", gap: 12, marginBottom: 12 }}>
          <h2 style={{
            flex: 1,
            margin: 0,
            minWidth: 0,
            fontSize: 16,
            fontWeight: 800,
            color: C.text,
            lineHeight: 1.35,
          }}
          >
            {alt || "Foto del producto"}
          </h2>
          <button
            ref={closeRef}
            type="button"
            onClick={() => onClose?.()}
            aria-label="Cerrar"
            style={{
              flexShrink: 0,
              width: 44,
              height: 44,
              borderRadius: 12,
              border: `1px solid ${C.border}`,
              background: C.bg,
              color: C.textMid,
              fontSize: 18,
              fontFamily: "inherit",
              lineHeight: 1,
              cursor: "pointer",
              display: "inline-flex",
              alignItems: "center",
              justifyContent: "center",
              padding: 0,
            }}
          >
            ✕
          </button>
        </div>
        <GaleriaProducto
          imagenes={imagenes}
          alt={alt}
          maxAlto={alto}
          indice={indice}
          onIndiceChange={onIndiceChange}
          iconoVacio={72}
          style={{ background: "#fff", borderRadius: 12 }}
        />
      </div>
    </div>
  );

  return createPortal(cuadro, document.body);
}
