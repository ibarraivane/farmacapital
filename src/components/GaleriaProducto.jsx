import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { ChevronLeft, ChevronRight, Package } from "lucide-react";
import { BRAND, C_LIGHT } from "../constants";

/**
 * Galería de fotos de un producto: flechas ‹ › sobre la imagen y puntos abajo.
 *
 * Con una sola foto se comporta igual que el <img> que reemplaza: sin
 * controles, sin puntos, sin nada que estorbe. Los controles aparecen solo
 * cuando de verdad hay más de una.
 *
 * @param {string[]} imagenes  URLs ya ordenadas; la primera es la que se ve.
 * @param {string} [alt]
 * @param {number} [maxAlto]   Alto máximo de la imagen en px.
 * @param {number} [iconoVacio] Tamaño del placeholder cuando no hay fotos.
 * @param {object} [style]     Estilos del contenedor.
 * @param {() => void} [onImagenClick] Si se pasa, la foto se vuelve pulsable
 *   (p. ej. para abrir el zoom). Las flechas quedan fuera de ese botón, no
 *   anidadas dentro, para no romper el HTML ni el foco por teclado.
 * @param {object} [imagenRef] Ref al botón de la foto, para devolver el foco
 *   al cerrar el zoom.
 * @param {boolean} [puntosFlotantes] Pone los puntos encima de la foto en vez
 *   de debajo. Para cajas de alto acotado (la ficha del POS), donde una fila
 *   extra abajo se recortaría y la foto es lo que el vendedor necesita grande.
 */
export default function GaleriaProducto({
  imagenes = [],
  alt = "",
  maxAlto = 420,
  iconoVacio = 88,
  style = {},
  onImagenClick,
  imagenRef,
  puntosFlotantes = false,
}) {
  const C = C_LIGHT;
  const fotos = useMemo(
    () => (imagenes || []).map((u) => String(u || "").trim()).filter(Boolean),
    [imagenes],
  );
  const total = fotos.length;
  const firma = fotos.join("|");
  const [i, setI] = useState(0);
  const [rotas, setRotas] = useState(() => new Set());
  const touchX = useRef(null);

  // Producto distinto (o lista distinta): volver a la primera foto.
  useEffect(() => { setI(0); setRotas(new Set()); }, [firma]);

  const ir = useCallback((delta) => {
    if (total < 2) return;
    setI((prev) => (prev + delta + total) % total);
  }, [total]);

  // Precarga la siguiente para que el salto no parpadee.
  useEffect(() => {
    if (total < 2) return;
    const sig = new Image();
    sig.src = fotos[(i + 1) % total];
  }, [i, total, fotos]);

  const onKeyDown = (e) => {
    if (e.key === "ArrowLeft") { e.preventDefault(); ir(-1); }
    if (e.key === "ArrowRight") { e.preventDefault(); ir(1); }
  };

  const onTouchStart = (e) => { touchX.current = e.touches?.[0]?.clientX ?? null; };
  const onTouchEnd = (e) => {
    if (touchX.current == null) return;
    const dx = (e.changedTouches?.[0]?.clientX ?? 0) - touchX.current;
    touchX.current = null;
    if (Math.abs(dx) > 40) ir(dx < 0 ? 1 : -1);
  };

  if (!total) {
    return (
      <div style={{ display: "flex", alignItems: "center", justifyContent: "center", padding: 24, ...style }}>
        <Package size={iconoVacio} strokeWidth={1} color={C.dim} aria-hidden />
      </div>
    );
  }

  const actual = fotos[i];
  const soloUna = total < 2;
  const marcarRota = () => setRotas((prev) => new Set(prev).add(actual));
  const estiloImg = {
    maxWidth: "100%",
    maxHeight: maxAlto,
    width: "auto",
    height: "auto",
    objectFit: "contain",
    display: "block",
    pointerEvents: "none",
  };

  const flecha = (lado) => ({
    position: "absolute",
    [lado]: 8,
    top: "50%",
    transform: "translateY(-50%)",
    width: 36,
    height: 36,
    borderRadius: 999,
    border: `1px solid ${C.border}`,
    background: "rgba(255,255,255,.92)",
    color: C.text,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    cursor: "pointer",
    padding: 0,
    boxShadow: "0 1px 6px rgba(0,21,52,.14)",
    zIndex: 2,
  });

  return (
    <div
      role="group"
      aria-roledescription="galería de fotos"
      aria-label={alt || "Fotos del producto"}
      tabIndex={soloUna ? -1 : 0}
      onKeyDown={onKeyDown}
      onTouchStart={onTouchStart}
      onTouchEnd={onTouchEnd}
      style={{
        position: "relative",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        width: "100%",
        outline: "none",
        ...style,
      }}
    >
      <div style={{ position: "relative", width: "100%", display: "flex", alignItems: "center", justifyContent: "center" }}>
        {rotas.has(actual) ? (
          <Package size={iconoVacio} strokeWidth={1} color={C.dim} aria-hidden />
        ) : onImagenClick ? (
          <button
            type="button"
            ref={imagenRef}
            onClick={onImagenClick}
            aria-label={alt ? `Ver foto de ${alt}` : "Ver foto en grande"}
            aria-haspopup="dialog"
            style={{
              border: "none",
              background: "transparent",
              padding: 0,
              cursor: "zoom-in",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              maxWidth: "100%",
              font: "inherit",
              color: "inherit",
            }}
          >
            <img src={actual} alt={alt} onError={marcarRota} style={estiloImg} />
          </button>
        ) : (
          <img src={actual} alt={alt} onError={marcarRota} style={estiloImg} />
        )}

        {!soloUna && (
          <>
            <button
              type="button"
              onClick={(e) => { e.stopPropagation(); ir(-1); }}
              aria-label="Foto anterior"
              style={flecha("left")}
            >
              <ChevronLeft size={20} aria-hidden />
            </button>
            <button
              type="button"
              onClick={(e) => { e.stopPropagation(); ir(1); }}
              aria-label="Foto siguiente"
              style={flecha("right")}
            >
              <ChevronRight size={20} aria-hidden />
            </button>
          </>
        )}
      </div>

      {!soloUna && (
        <>
          <div style={{
            display: "flex",
            gap: 6,
            flexWrap: "wrap",
            justifyContent: "center",
            ...(puntosFlotantes
              ? {
                  position: "absolute",
                  bottom: 6,
                  left: "50%",
                  transform: "translateX(-50%)",
                  padding: "5px 8px",
                  borderRadius: 999,
                  background: "rgba(255,255,255,.86)",
                  boxShadow: "0 1px 4px rgba(0,21,52,.16)",
                  zIndex: 2,
                }
              : { marginTop: 10 }),
          }}>
            {fotos.map((u, idx) => (
              <button
                key={u}
                type="button"
                onClick={(e) => { e.stopPropagation(); setI(idx); }}
                aria-label={`Ver foto ${idx + 1} de ${total}`}
                aria-current={idx === i}
                style={{
                  width: idx === i ? 20 : 8,
                  height: 8,
                  borderRadius: 999,
                  border: "none",
                  padding: 0,
                  cursor: "pointer",
                  background: idx === i ? BRAND.primary : C.border,
                  transition: "width .15s ease, background .15s ease",
                }}
              />
            ))}
          </div>
          <span aria-live="polite" style={{ position: "absolute", width: 1, height: 1, overflow: "hidden", clip: "rect(0 0 0 0)", whiteSpace: "nowrap" }}>
            Foto {i + 1} de {total}
          </span>
        </>
      )}
    </div>
  );
}
