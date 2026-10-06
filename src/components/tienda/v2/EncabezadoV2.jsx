import { useEffect, useLayoutEffect, useMemo, useRef, useState } from "react";
import { MapPin, Menu, Search, ShoppingBag, User } from "lucide-react";
import { logoFullSrc, logoFullSrcSet } from "../../../brand";
import { FARMACIA_FISCAL } from "../../../constants/farmaciaFiscal";
import { HORARIO_FARMACIA } from "../../../constants/turnos";
import { irASeccionVitrina } from "../../../lib/tiendaCatalogoCategorias";
import { SECCIONES_VITRINA, slugSeccion } from "../../../constants/vitrinaTienda";
import { pageIdToTiendaPath, seccionVitrinaFromPath } from "../../../shared/tiendaRoutes";
import { tiendaCatalogSearchSuggestions } from "../../../utils/fuzzySearch";
import EnlaceTienda from "./EnlaceTienda";

const PLACEHOLDER = "Buscar medicamento o marca";
const MOVIL = "(max-width: 760px)";

/** El encabezado no se compacta al bajar: ese cambio de alto lo hacía parpadear. */
export function decidirCompacto() {
  return false;
}

function useEspacioEncabezado(ref) {
  useLayoutEffect(() => {
    const el = ref.current;
    if (!el || typeof window.matchMedia !== "function") return undefined;
    const root = el.closest(".fc-v2");
    const mq = window.matchMedia(MOVIL);
    const apply = () => {
      if (!root) return;
      root.style.paddingTop = mq.matches ? `${el.offsetHeight}px` : "";
    };
    apply();
    const ro = typeof ResizeObserver !== "undefined" ? new ResizeObserver(apply) : null;
    ro?.observe(el);
    mq.addEventListener?.("change", apply);
    return () => {
      ro?.disconnect();
      mq.removeEventListener?.("change", apply);
      if (root) root.style.paddingTop = "";
    };
  }, [ref]);
}

export default function EncabezadoV2({
  page,
  setPage,
  cart = [],
  busqHero,
  setBusqHero,
  productos = [],
  setProdDetalle,
  aviso,
  avisoCarrito,
  user,
  onMenu,
  menuAbierto = false,
}) {
  const [busqFocus, setBusqFocus] = useState(false);
  const stickyRef = useRef(null);
  useEspacioEncabezado(stickyRef);
  const checkout = page === "checkout" || page === "carrito";
  const n = (cart || []).reduce((a, c) => a + (Number(c.qty) || 0), 0);
  const q = String(busqHero || "");
  const suggestions = useMemo(
    () => (busqFocus && q.trim().length >= 2
      ? tiendaCatalogSearchSuggestions(productos || [], q, { limit: 8 })
      : []),
    [productos, q, busqFocus]
  );

  useEffect(() => { setBusqFocus(false); }, [page]);

  const go = (id, opts) => {
    if (opts == null) setPage?.(id);
    else setPage?.(id, opts);
  };

  const irACatalogoBusqueda = () => {
    const t = q.trim();
    setBusqFocus(false);
    try {
      if (t) sessionStorage.setItem("farmacapital_busq", t);
      else sessionStorage.removeItem("farmacapital_busq");
    } catch (_) { /* noop */ }
    go("catalogo", t ? { search: t } : { rx: false });
  };

  const seccionActiva = (() => {
    if (page !== "catalogo") return "";
    try { return seccionVitrinaFromPath(window.location.pathname); } catch { return ""; }
  })();

  const pick = (row) => {
    if (!row) return;
    setProdDetalle?.(row);
    setBusqFocus(false);
    go("detalle", { productId: row.id });
    if (typeof window.scrollTo === "function") {
      try { window.scrollTo({ top: 0, behavior: "smooth" }); } catch (_) { /* jsdom */ }
    }
  };

  const irSucursal = () => {
    const url = FARMACIA_FISCAL.maps_url;
    if (url && typeof window.open === "function") {
      window.open(url, "_blank", "noopener,noreferrer");
    }
  };

  return (
    <div ref={stickyRef} className={`fc-sticky${checkout ? " fc-sticky--checkout" : ""}`} style={{ backgroundColor: "#ffffff", top: 0, zIndex: 80 }}>
      <div className="fc-top">
        <span>Farmacia y consultorio · Ciudad de México</span>
        <span>Atención en sucursal · {HORARIO_FARMACIA.apertura}–{HORARIO_FARMACIA.cierre}</span>
      </div>
      <header className="fc-hdr">
        <EnlaceTienda className="fc-brand" href={pageIdToTiendaPath("home")} onNavigate={() => go("home")} aria-label="Inicio FarmaCapital">
          <img
            src={logoFullSrc({ light: true })}
            srcSet={logoFullSrcSet({ light: true })}
            alt="FarmaCapital"
          />
        </EnlaceTienda>
        <form
          className="fc-search"
          role="search"
          onSubmit={(e) => {
            e.preventDefault();
            irACatalogoBusqueda();
          }}
        >
          <Search aria-hidden />
          <input
            className="farmacapital-field-input"
            type="search"
            value={q}
            placeholder={PLACEHOLDER}
            aria-label="Buscar producto, sustancia o marca"
            autoComplete="off"
            enterKeyHint="search"
            onChange={(e) => {
              const v = e.target.value;
              setBusqHero?.(v);
              try { if (v.trim()) sessionStorage.setItem("farmacapital_busq", v); } catch (_) { /* noop */ }
            }}
            onFocus={() => setBusqFocus(true)}
            onBlur={() => setTimeout(() => setBusqFocus(false), 280)}
            onKeyDown={(e) => {
              if (e.key === "Escape") setBusqFocus(false);
            }}
          />
          <button className="fc-textbtn" type="submit">Buscar</button>
          {suggestions.length > 0 && (
            <div className="fc-suggest" role="listbox" aria-label="Sugerencias de búsqueda">
              {suggestions.map((s) => {
                const row = (productos || []).find((x) => x.id === s.id);
                return (
                  <button
                    key={s.id}
                    type="button"
                    role="option"
                    onMouseDown={(e) => e.preventDefault()}
                    onClick={() => pick(row || s)}
                  >
                    {s.nombre}
                  </button>
                );
              })}
            </div>
          )}
        </form>
        <EnlaceTienda
          className="fc-iconbtn"
          href={pageIdToTiendaPath(user ? "cuenta" : "login")}
          aria-label={user ? "Mi cuenta" : "Iniciar sesión"}
          onNavigate={() => go(user ? "cuenta" : "login")}
        >
          <User aria-hidden />
        </EnlaceTienda>
        <button
          type="button"
          className="fc-iconbtn"
          aria-label="Abrir menú"
          aria-expanded={Boolean(menuAbierto)}
          aria-controls="fc-menu-tienda"
          onClick={() => onMenu?.()}
        >
          <Menu aria-hidden />
        </button>
        {checkout ? (
          <EnlaceTienda
            className="fc-textbtn"
            href={page === "checkout" ? pageIdToTiendaPath("carrito") : pageIdToTiendaPath("catalogo")}
            onNavigate={() => go(page === "checkout" ? "carrito" : "catalogo")}
          >
            {page === "checkout" ? "Volver al carrito" : "Seguir comprando"}
          </EnlaceTienda>
        ) : null}
        <EnlaceTienda
          className="fc-iconbtn"
          href={pageIdToTiendaPath("carrito")}
          aria-label="Ver carrito"
          onNavigate={() => go("carrito")}
        >
          <ShoppingBag aria-hidden />
          <span className="fc-cartnum">{n}</span>
        </EnlaceTienda>
      </header>
      <nav className="fc-nav" aria-label="Áreas de la tienda" style={{ backgroundColor: "#ffffff" }}>
        {SECCIONES_VITRINA.map((sec) => (
          <EnlaceTienda
            key={sec.id}
            href={pageIdToTiendaPath("catalogo", { seccion: sec.nombre })}
            aria-current={seccionActiva && slugSeccion(seccionActiva) === sec.id ? "page" : undefined}
            onNavigate={() => irASeccionVitrina(setPage, sec.nombre)}
          >
            {sec.nombre}
          </EnlaceTienda>
        ))}
        <EnlaceTienda className="fc-nav-quote" href={pageIdToTiendaPath("cotizar")} onNavigate={() => go("cotizar")}>
          Cotizar especializado
        </EnlaceTienda>
        <a className="fc-location" href={FARMACIA_FISCAL.maps_url} target="_blank" rel="noopener noreferrer" onClick={(e) => { if (!FARMACIA_FISCAL.maps_url) { e.preventDefault(); irSucursal(); } }}>
          <MapPin aria-hidden />
          Sucursal CDMX · Ver ubicación
        </a>
      </nav>
      {avisoCarrito ? (
        <div className="fc-toast" role="status">
          <span>{avisoCarrito}</span>
          <EnlaceTienda href={pageIdToTiendaPath("carrito")} onNavigate={() => go("carrito")}>Ver carrito</EnlaceTienda>
        </div>
      ) : null}
      {aviso}
    </div>
  );
}
