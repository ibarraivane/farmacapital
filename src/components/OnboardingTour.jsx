/**
 * OnboardingTour
 * ──────────────────────────────────────────────────────────────
 * Corre un tour de react-joyride para un módulo (POS, Inventario,
 * Corte de Caja, Consultorio) la primera vez que un usuario lo abre.
 *
 * Props:
 *   - usuario:  objeto sesión (se usa usuario.id para clave localStorage).
 *               Si no se pasa, cae a sessionStorage farmacapital_admin_user.
 *   - tourId:   "pos" | "inv" | "caja" | "cons"  (ver src/utils/tours.js)
 *   - autoStart: boolean  (default true; si false, solo se muestra FAB "?")
 *   - showFab: boolean (default true). Si false, no se pinta el botón "?" fijo;
 *               usa ref imperativo startTour() o un botón propio (p. ej. barra en POS).
 *
 * Uso:
 *   <OnboardingTour tourId="pos" usuario={usuario} />
 */

import React, {
  forwardRef,
  useCallback,
  useEffect,
  useImperativeHandle,
  useMemo,
  useRef,
  useState,
} from "react";
import { Joyride, STATUS } from "react-joyride";
import { TOURS, tourStorageKey } from "../utils/tours";
import { useMediaQuery } from "../hooks/useMediaQuery";

const JOYRIDE_STYLES = {
  options: {
    primaryColor: "#1E3ABA",
    zIndex: 10000,
    arrowColor: "#ffffff",
    backgroundColor: "#ffffff",
    textColor: "#1f2937",
    overlayColor: "rgba(10, 25, 55, 0.55)",
  },
  tooltip: {
    borderRadius: 14,
    padding: 16,
    fontSize: 13,
    boxShadow: "0 24px 60px rgba(10, 25, 55, 0.35)",
  },
  tooltipTitle: {
    fontSize: 15,
    fontWeight: 800,
    color: "#1E3ABA",
  },
  buttonNext: {
    borderRadius: 8,
    fontWeight: 700,
    fontSize: 12,
    padding: "8px 14px",
  },
  buttonBack: {
    color: "#1E3ABA",
    fontSize: 12,
  },
  buttonSkip: {
    color: "#64748b",
    fontSize: 12,
  },
};

const LOCALE = {
  back: "Atrás",
  close: "Cerrar",
  last: "¡Listo!",
  next: "Siguiente",
  skip: "Saltar",
  open: "Abrir",
};

function usuarioDeSesion() {
  try {
    return JSON.parse(sessionStorage.getItem("farmacapital_admin_user") || "{}");
  } catch {
    return {};
  }
}

/**
 * Filtra los pasos cuyo `target` no está presente en el DOM.
 * Evita que Joyride reviente si algún elemento todavía no se renderizó
 * (ej. una pestaña oculta dentro del módulo).
 */
function filtrarPasosVivos(steps) {
  if (typeof document === "undefined") return steps;
  return steps.filter((s) => {
    if (!s?.target || typeof s.target !== "string") return true;
    try {
      return !!document.querySelector(s.target);
    } catch {
      return false;
    }
  });
}

const OnboardingTour = forwardRef(function OnboardingTour(
  { tourId, usuario, autoStart = true, showFab = true },
  ref
) {
  const tour = TOURS[tourId];
  const user = usuario && usuario.id ? usuario : usuarioDeSesion();
  const storageKey = useMemo(
    () => tourStorageKey(tourId, user?.id),
    [tourId, user?.id]
  );

  const [run, setRun] = useState(false);
  const [steps, setSteps] = useState([]);
  const autoStartedRef = useRef(false);
  const isMobile = useMediaQuery("(max-width: 900px)");

  const abrirTour = useCallback(() => {
    if (!tour) return;
    const vivos = filtrarPasosVivos(tour.steps);
    if (!vivos.length) {
      console.info(`[Tour ${tourId}] ningún target visible; se omite.`);
      return;
    }
    setSteps(vivos);
    setRun(true);
  }, [tour, tourId]);

  useImperativeHandle(
    ref,
    () => ({
      startTour: abrirTour,
    }),
    [abrirTour]
  );

  // Auto-arranque si el usuario no lo ha visto.
  useEffect(() => {
    if (!autoStart || !tour || !storageKey) return;
    if (autoStartedRef.current) return;
    let done = null;
    try {
      done = localStorage.getItem(storageKey);
    } catch {
      /* localStorage deshabilitado */
    }
    if (done === "done") return;
    const t = setTimeout(() => {
      // Marcar en cuanto se muestra automáticamente para evitar re-disparos molestos.
      // El botón "?" queda disponible para abrirlo manualmente cuando quieras.
      autoStartedRef.current = true;
      try {
        localStorage.setItem(storageKey, "done");
      } catch {
        /* noop */
      }
      abrirTour();
    }, 600); // dejar renderizar la página
    return () => clearTimeout(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [storageKey, autoStart]);

  const handleCallback = useCallback(
    (data) => {
      const { status } = data;
      const finished = [STATUS.FINISHED, STATUS.SKIPPED].includes(status);
      if (finished) {
        setRun(false);
        if (storageKey) {
          try {
            localStorage.setItem(storageKey, "done");
          } catch {
            /* noop */
          }
        }
      }
    },
    [storageKey]
  );

  if (!tour) return null;

  const pasos = isMobile
    ? steps.map((s) => ({ ...s, placement: "center", disableBeacon: true }))
    : steps;

  return (
    <>
      <Joyride
        steps={pasos}
        run={run}
        continuous
        showProgress
        showSkipButton
        disableOverlayClose
        disableScrolling={isMobile}
        scrollToFirstStep={!isMobile}
        locale={LOCALE}
        styles={{
          ...JOYRIDE_STYLES,
          tooltip: {
            ...JOYRIDE_STYLES.tooltip,
            maxWidth: isMobile ? "min(360px, calc(100vw - 28px))" : 420,
          },
        }}
        callback={handleCallback}
      />
      {showFab ? (
        <button
          type="button"
          onClick={abrirTour}
          aria-label={tour.label}
          title={tour.label}
          style={{
            position: "fixed",
            right: "max(12px, env(safe-area-inset-right, 0px))",
            bottom: "max(16px, env(safe-area-inset-bottom, 0px))",
            width: isMobile ? 40 : 48,
            height: isMobile ? 40 : 48,
            borderRadius: 24,
            border: "none",
            background: "linear-gradient(135deg,#1E3ABA,#1E3ABA)",
            color: "#fff",
            fontWeight: 800,
            fontSize: isMobile ? 18 : 20,
            cursor: "pointer",
            boxShadow: "0 8px 20px rgba(0, 82, 204, 0.35)",
            zIndex: 20,
            pointerEvents: "auto",
            touchAction: "manipulation",
          }}
        >
          ?
        </button>
      ) : null}
    </>
  );
});

export default OnboardingTour;
