import { Children, useCallback, useEffect, useRef, useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { stripArrowState, stripPageScrollLeft } from "../lib/productosStrip";

/**
 * Ancho fijo de cada tarjeta en banda = celda de la cuadrícula del catálogo.
 * NO volver a dejar que ProductCard (width:100% inline) mande el ancho del flex:
 * eso regenera el bug de “1 tarjeta gigante por categoría”.
 * El ítem wrapper + `width: 100% !important` en el hijo lo evitan.
 */
export const STRIP_CARD_WIDTH_PX = 220;

/**
 * Franja horizontal de productos (recompra, sugeridos o categoría).
 * Las tarjetas son las de la cuadrícula, en fila. Celular: desliza.
 * Laptop: ~5 por banda y flechas para el siguiente grupo.
 */
export default function RecompraStrip({
  title,
  subtitle,
  children,
  empty,
  actionLabel,
  onAction,
}) {
  const scrollerRef = useRef(null);
  const [arrows, setArrows] = useState({ canPrev: false, canNext: false });

  const syncArrows = useCallback(() => {
    setArrows(stripArrowState(scrollerRef.current));
  }, []);

  useEffect(() => {
    const el = scrollerRef.current;
    if (!el) return;
    syncArrows();
    el.addEventListener("scroll", syncArrows, { passive: true });
    const ro = typeof ResizeObserver !== "undefined" ? new ResizeObserver(syncArrows) : null;
    ro?.observe(el);
    window.addEventListener("resize", syncArrows);
    return () => {
      el.removeEventListener("scroll", syncArrows);
      ro?.disconnect();
      window.removeEventListener("resize", syncArrows);
    };
  }, [syncArrows, children]);

  const irPagina = (dir) => {
    const el = scrollerRef.current;
    if (!el) return;
    const left = stripPageScrollLeft(el, dir);
    if (typeof el.scrollTo === "function") {
      el.scrollTo({ left, behavior: "smooth" });
    } else {
      el.scrollLeft = left;
    }
    syncArrows();
  };

  if (empty) return null;

  const items = Children.map(children, (child, i) => (
    <div
      key={child?.key ?? i}
      className="farmacapital-productos-strip-item"
      style={{
        flex: "0 0 auto",
        width: STRIP_CARD_WIDTH_PX,
        maxWidth: "min(220px, 72vw)",
        minWidth: 0,
        boxSizing: "border-box",
        scrollSnapAlign: "start",
      }}
    >
      {child}
    </div>
  ));

  return (
    <div style={{ marginBottom: 28 }}>
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "flex-end",
          gap: 12,
          marginBottom: 12,
          flexWrap: "wrap",
        }}
      >
        <div style={{ minWidth: 0, flex: "1 1 auto" }}>
          <h2
            style={{
              color: "#1e293b",
              fontSize: "clamp(18px,4.2vw,22px)",
              fontWeight: 800,
              margin: 0,
              fontFamily: "var(--fc-body)",
            }}
          >
            {title}
          </h2>
          {subtitle ? (
            <div style={{ color: "#64748b", fontSize: 13, marginTop: 4, lineHeight: 1.4 }}>
              {subtitle}
            </div>
          ) : null}
        </div>
        {actionLabel && typeof onAction === "function" ? (
          <button
            type="button"
            onClick={onAction}
            style={{
              background: "none",
              border: "none",
              color: "#0052cc",
              fontWeight: 700,
              fontSize: 13,
              cursor: "pointer",
              padding: "4px 0",
              fontFamily: "var(--fc-body)",
              flexShrink: 0,
            }}
          >
            {actionLabel}
          </button>
        ) : null}
      </div>
      <div className="farmacapital-productos-strip-wrap">
        <button
          type="button"
          className="farmacapital-productos-strip-arrow farmacapital-productos-strip-arrow--prev"
          aria-label="Productos anteriores"
          disabled={!arrows.canPrev}
          onClick={() => irPagina(-1)}
        >
          <ChevronLeft size={22} strokeWidth={2.25} aria-hidden />
        </button>
        <div
          ref={scrollerRef}
          className="farmacapital-productos-strip"
          tabIndex={arrows.canPrev || arrows.canNext ? 0 : undefined}
          onKeyDown={(e) => {
            if (e.key === "ArrowRight" && arrows.canNext) {
              e.preventDefault();
              irPagina(1);
            }
            if (e.key === "ArrowLeft" && arrows.canPrev) {
              e.preventDefault();
              irPagina(-1);
            }
          }}
          style={{
            display: "flex",
            gap: 12,
            overflowX: "auto",
            scrollSnapType: "x mandatory",
            WebkitOverflowScrolling: "touch",
            scrollbarWidth: "none",
            paddingBottom: 6,
            marginInline: -4,
            paddingInline: 4,
          }}
        >
          {items}
        </div>
        <button
          type="button"
          className="farmacapital-productos-strip-arrow farmacapital-productos-strip-arrow--next"
          aria-label="Siguientes productos"
          disabled={!arrows.canNext}
          onClick={() => irPagina(1)}
        >
          <ChevronRight size={22} strokeWidth={2.25} aria-hidden />
        </button>
      </div>
    </div>
  );
}

/** CSS una sola vez (Home / Cuenta montan varias bandas). */
export function ProductosStripStyles() {
  return (
    <style>{`
      .farmacapital-productos-strip-wrap {
        position: relative;
        min-width: 0;
        max-width: 100%;
      }
      .farmacapital-productos-strip {
        min-width: 0;
        max-width: 100%;
      }
      .farmacapital-productos-strip::-webkit-scrollbar { display: none; }
      .farmacapital-productos-strip-item {
        flex: 0 0 auto;
        width: 220px;
        max-width: min(220px, 72vw);
        box-sizing: border-box;
        scroll-snap-align: start;
      }
      .farmacapital-productos-strip-item > * {
        width: 100% !important;
        max-width: 100% !important;
        height: 100%;
      }
      @media (min-width: 768px) {
        .farmacapital-productos-strip {
          padding-inline-end: 48px;
        }
      }
      .farmacapital-productos-strip-arrow {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        z-index: 3;
        width: 42px;
        height: 42px;
        border-radius: 999px;
        border: 1px solid #e2e8f0;
        background: #fff;
        color: #1E3ABA;
        box-shadow: 0 4px 16px rgba(15, 23, 42, 0.16);
        display: none;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        padding: 0;
        font: inherit;
      }
      .farmacapital-productos-strip-arrow:hover:not(:disabled) {
        background: #1E3ABA;
        color: #fff;
        border-color: #1E3ABA;
      }
      .farmacapital-productos-strip-arrow:disabled {
        opacity: 0;
        pointer-events: none;
      }
      .farmacapital-productos-strip-arrow--prev { left: 2px; }
      .farmacapital-productos-strip-arrow--next { right: 2px; }
      @media (min-width: 768px) {
        .farmacapital-productos-strip-arrow { display: inline-flex; }
      }
    `}</style>
  );
}
