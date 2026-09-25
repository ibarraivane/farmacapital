import { useEffect, useRef, useState } from "react";
import { ChevronLeft, ChevronRight, ArrowRight } from "lucide-react";

const AUTO_MS = 6500;

function prefiereMenosMovimiento() {
  try {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  } catch (_) {
    return false;
  }
}

/**
 * Carrusel del recuadro "estudio" del inicio (antes una sola tarjeta fija de
 * dermocosmética). Cada slide es su propia historia — piel, cotización,
 * genéricos, patente — con su fondo y su llamada a la acción.
 *
 * Puramente de presentación: recibe los `slides` ya armados por InicioV2 y
 * no decide destinos ni redacta textos, para poder probarlo sin la tienda.
 */
export default function HeroCarrusel({ slides = [] }) {
  const [i, setI] = useState(0);
  const [pausado, setPausado] = useState(false);
  const arrastreRef = useRef(null);

  const total = slides.length;
  const ir = (n) => setI(((n % total) + total) % total);
  const siguiente = () => ir(i + 1);
  const anterior = () => ir(i - 1);

  useEffect(() => {
    if (total < 2 || pausado || prefiereMenosMovimiento()) return undefined;
    const t = setInterval(() => setI((v) => (v + 1) % total), AUTO_MS);
    return () => clearInterval(t);
  }, [total, pausado]);

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
      className={`fc-studio fc-studio--${slide.tono || "cream"}`}
      role="region"
      aria-roledescription="carrusel"
      aria-label="Destacados"
      tabIndex={0}
      onKeyDown={onKeyDown}
      onMouseEnter={() => setPausado(true)}
      onMouseLeave={() => setPausado(false)}
      onFocus={() => setPausado(true)}
      onBlur={() => setPausado(false)}
      onPointerDown={onPointerDown}
      onPointerUp={onPointerUp}
    >
      {total > 1 ? (
        <button type="button" className="fc-studio-arrow fc-studio-arrow--prev" onClick={anterior} aria-label="Anterior">
          <ChevronLeft aria-hidden="true" />
        </button>
      ) : null}
      {total > 1 ? (
        <button type="button" className="fc-studio-arrow fc-studio-arrow--next" onClick={siguiente} aria-label="Siguiente">
          <ChevronRight aria-hidden="true" />
        </button>
      ) : null}

      <div>
        <div className="fc-eyebrow">{slide.eyebrow}</div>
        <h2>
          {slide.titulo}
          {slide.acento ? <><br /><span className="fc-serif">{slide.acento}</span></> : null}
        </h2>
      </div>

      {slide.imagenes?.length ? (
        <div className="fc-packshots">
          {slide.imagenes.map((img) => (
            <figure key={img.id} className="fc-packshot">
              <img src={img.src} alt="" loading="lazy" decoding="async" />
              {img.marca ? <figcaption>{img.marca}</figcaption> : null}
            </figure>
          ))}
        </div>
      ) : slide.icono ? (
        <div className="fc-studio-icono" aria-hidden="true">{slide.icono}</div>
      ) : null}

      {total > 1 ? (
        <div className="fc-studio-dots" role="tablist" aria-label="Elegir destacado">
          {slides.map((s, idx) => (
            <button
              key={s.id || idx}
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

      <div className="fc-studio-note">
        <span>{slide.nota}</span>
        <button type="button" className="fc-studio-cta" onClick={slide.onIr}>
          {slide.cta || "Descubrir"} <ArrowRight aria-hidden="true" />
        </button>
      </div>
    </div>
  );
}
