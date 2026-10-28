import { useEffect, useRef, useState } from "react";
import { ChevronLeft, ChevronRight, ArrowRight, Pause, Play } from "lucide-react";
import EnlaceTienda from "./EnlaceTienda";

export const AUTO_MS = 6500;

function prefiereMenosMovimiento() {
  try {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  } catch (_) {
    return false;
  }
}

function Media({ slide, activa }) {
  if (slide.imagenes?.length) {
    return (
      <div className="fc-packshots">
        {slide.imagenes.map((img) => (
          <figure key={img.id} className="fc-packshot">
            <div className="fc-packshot-foto">
              <img src={img.src} alt="" decoding="async" loading={activa ? "eager" : "lazy"} />
            </div>
            {img.marca ? <figcaption>{img.marca}</figcaption> : null}
          </figure>
        ))}
      </div>
    );
  }
  if (slide.icono) {
    return (
      <div className="fc-studio-icono" aria-hidden="true">
        <span className="fc-studio-icono-burbuja">{slide.icono}</span>
      </div>
    );
  }
  return <div className="fc-studio-icono" aria-hidden="true" />;
}

/**
 * Carrusel del recuadro "estudio" del inicio. Cada slide es su propia
 * historia — piel, cotización, genéricos, patente — con su fondo y su CTA.
 *
 * Todas las slides se dibujan apiladas en la misma celda de la cuadrícula:
 * el recuadro toma la altura de la más alta y NO cambia al rotar, así la
 * página no brinca. Solo la activa es visible e interactiva.
 *
 * Puramente de presentación: recibe los `slides` ya armados por InicioV2.
 */
export default function HeroCarrusel({ slides = [] }) {
  const [i, setI] = useState(0);
  const [pausaManual, setPausaManual] = useState(false);
  const [encima, setEncima] = useState(false);
  const arrastreRef = useRef(null);

  const total = slides.length;
  const quieto = prefiereMenosMovimiento();
  const corriendo = total > 1 && !pausaManual && !encima && !quieto;
  const ir = (n) => setI(((n % total) + total) % total);
  const siguiente = () => ir(i + 1);
  const anterior = () => ir(i - 1);

  useEffect(() => {
    if (!corriendo) return undefined;
    const t = setTimeout(() => setI((v) => (v + 1) % total), AUTO_MS);
    return () => clearTimeout(t);
  }, [corriendo, total, i]);

  if (!total) return null;
  const slide = slides[i];

  const onKeyDown = (e) => {
    if (e.key === "ArrowRight") { e.preventDefault(); siguiente(); }
    if (e.key === "ArrowLeft") { e.preventDefault(); anterior(); }
  };

  const onPointerDown = (e) => { arrastreRef.current = e.clientX; };
  const onPointerUp = (e) => {
    if (arrastreRef.current == null) return;
    const dx = e.clientX - arrastreRef.current;
    arrastreRef.current = null;
    if (Math.abs(dx) < 40) return;
    if (dx < 0) siguiente(); else anterior();
  };

  return (
    <div
      className={`fc-studio fc-studio--${slide.tono || "cream"}${corriendo ? " fc-studio--corriendo" : ""}`}
      role="region"
      aria-roledescription="carrusel"
      aria-label="Destacados"
      tabIndex={0}
      style={{ "--fc-auto-ms": `${AUTO_MS}ms` }}
      onKeyDown={onKeyDown}
      onMouseEnter={() => setEncima(true)}
      onMouseLeave={() => setEncima(false)}
      onPointerDown={onPointerDown}
      onPointerUp={onPointerUp}
    >
      {total > 1 ? (
        <div className="fc-studio-controles">
          <button
            type="button"
            className="fc-studio-arrow fc-studio-pause"
            aria-pressed={pausaManual}
            aria-label={pausaManual ? "Reproducir carrusel" : "Pausar carrusel"}
            onClick={() => setPausaManual((v) => !v)}
          >
            {pausaManual ? <Play aria-hidden="true" /> : <Pause aria-hidden="true" />}
          </button>
          <button type="button" className="fc-studio-arrow fc-studio-arrow--prev" onClick={anterior} aria-label="Anterior">
            <ChevronLeft aria-hidden="true" />
          </button>
          <button type="button" className="fc-studio-arrow fc-studio-arrow--next" onClick={siguiente} aria-label="Siguiente">
            <ChevronRight aria-hidden="true" />
          </button>
        </div>
      ) : null}

      <div className="fc-studio-stage">
        {slides.map((s, idx) => {
          const activa = idx === i;
          return (
            <div
              key={s.id || idx}
              className={`fc-studio-slide${activa ? " fc-studio-slide--activa" : ""}`}
              aria-hidden={activa ? undefined : "true"}
              inert={!activa}
            >
              <div className="fc-studio-head">
                <div className="fc-eyebrow">{s.eyebrow}</div>
                <h2>
                  {s.titulo}
                  {s.acento ? <><br /><span className="fc-serif">{s.acento}</span></> : null}
                </h2>
              </div>

              <Media slide={s} activa={activa} />

              <div className="fc-studio-note" aria-live={activa && pausaManual ? "polite" : "off"}>
                <span>{s.nota}</span>
                {s.href ? (
                  <EnlaceTienda className="fc-studio-cta" href={s.href} onNavigate={s.onIr} tabIndex={activa ? undefined : -1}>
                    {s.cta || "Descubrir"} <ArrowRight aria-hidden="true" />
                  </EnlaceTienda>
                ) : (
                  <button type="button" className="fc-studio-cta" onClick={s.onIr} tabIndex={activa ? undefined : -1}>
                    {s.cta || "Descubrir"} <ArrowRight aria-hidden="true" />
                  </button>
                )}
              </div>
            </div>
          );
        })}
      </div>

      {total > 1 ? (
        <div className="fc-studio-dots" role="tablist" aria-label="Elegir destacado">
          {slides.map((s, idx) => (
            <button
              key={`${s.id || idx}-${idx === i ? i : "x"}`}
              type="button"
              role="tab"
              aria-selected={idx === i}
              aria-current={idx === i}
              aria-label={`Ver: ${s.eyebrow}`}
              onClick={() => ir(idx)}
            />
          ))}
        </div>
      ) : null}
    </div>
  );
}
