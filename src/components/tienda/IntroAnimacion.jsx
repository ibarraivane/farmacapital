import { useEffect, useState } from "react";
import { BRAND_LOGO } from "../../brand";
import { debeMostrarIntro, marcarIntroVista } from "../../lib/introAnimacion";

const DURACION_MS = 2100;

function CruzLogo() {
  return (
    <svg viewBox="0 0 64 64" width="64" height="64" aria-hidden="true">
      <rect className="farmacapital-intro-v" x="26" y="10" width="12" height="44" rx="6" fill="#FFFFFF" />
      <rect className="farmacapital-intro-h" x="10" y="26" width="44" height="12" rx="6" fill="#FFFFFF" />
      <path
        className="farmacapital-intro-arc"
        d="M 19 44 A 12 12 0 0 1 28 26"
        fill="none"
        stroke="#22C55E"
        strokeWidth="4.4"
        strokeLinecap="round"
      />
    </svg>
  );
}

/**
 * Cortina de primera visita. CSS only. No retrasa el contenido (la página
 * ya está debajo). sessionStorage + prefers-reduced-motion.
 */
export default function IntroAnimacion() {
  const [visible, setVisible] = useState(false);
  const [out, setOut] = useState(false);

  useEffect(() => {
    if (!debeMostrarIntro()) return undefined;
    setVisible(true);
    marcarIntroVista();
    const t = setTimeout(() => setOut(true), DURACION_MS);
    return () => clearTimeout(t);
  }, []);

  useEffect(() => {
    if (!out) return undefined;
    const t = setTimeout(() => setVisible(false), 700);
    return () => clearTimeout(t);
  }, [out]);

  if (!visible) return null;

  const saltar = () => setOut(true);

  return (
    <div
      className={`farmacapital-intro${out ? " out" : ""}`}
      role="presentation"
    >
      <div className="farmacapital-intro-mark">
        <CruzLogo />
        <span className="farmacapital-intro-word">
          <img src={BRAND_LOGO.fullLight} alt="FarmaCapital" height="40" />
        </span>
      </div>
      <p className="farmacapital-intro-line">Farmacia mexicana</p>
      <button type="button" className="farmacapital-intro-skip" onClick={saltar}>
        Saltar
      </button>
    </div>
  );
}
