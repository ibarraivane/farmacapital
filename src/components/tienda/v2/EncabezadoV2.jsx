import { useEffect, useMemo, useState } from "react";
import { MapPin, Search, ShoppingBag } from "lucide-react";
import { logoFullSrc, logoFullSrcSet } from "../../../brand";
import { FARMACIA_FISCAL } from "../../../constants/farmaciaFiscal";
import { HORARIO_FARMACIA } from "../../../constants/turnos";
import { irACatalogoCategoria } from "../../../lib/tiendaCatalogoCategorias";
import { tiendaCatalogSearchSuggestions } from "../../../utils/fuzzySearch";

const PLACEHOLDER = "Nombre, principio activo o marca…";

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
}) {
  const [busqFocus, setBusqFocus] = useState(false);
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
    try { if (t) sessionStorage.setItem("farmacapital_busq", t); } catch (_) { /* noop */ }
    go("catalogo");
  };

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
    <div style={{ position: "sticky", top: 0, zIndex: 50 }}>
      <div className="fc-top">
        <span>Farmacia y consultorio · Ciudad de México</span>
        <span>Atención en sucursal · {HORARIO_FARMACIA.apertura}–{HORARIO_FARMACIA.cierre}</span>
      </div>
      <header className="fc-hdr">
        <button type="button" className="fc-brand" onClick={() => go("home")} aria-label="Inicio FarmaCapital">
          <img
            src={logoFullSrc({ light: true })}
            srcSet={logoFullSrcSet({ light: true })}
            alt="FarmaCapital"
          />
        </button>
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
        <button
          type="button"
          className="fc-iconbtn"
          aria-label="Ver carrito"
          onClick={() => go("carrito")}
        >
          <ShoppingBag aria-hidden />
          <span className="fc-cartnum">{n}</span>
        </button>
      </header>
      <nav className="fc-nav" aria-label="Áreas de la tienda">
        <button type="button" onClick={() => go("catalogo", { rx: false })}>Medicamentos</button>
        <button type="button" onClick={() => go("conseguir")}>Dermocosmética</button>
        <button type="button" onClick={() => irACatalogoCategoria(setPage, "Vitaminas")}>Nutrición</button>
        <button type="button" className="fc-nav-quote" onClick={() => go("cotizar")}>Cotizar especializado</button>
        <button type="button" className="fc-location" onClick={irSucursal}>
          <MapPin aria-hidden />
          Sucursal CDMX · Ver ubicación
        </button>
      </nav>
      {avisoCarrito ? (
        <div className="fc-toast" role="status">
          <span>{avisoCarrito}</span>
          <button type="button" onClick={() => go("carrito")}>Ver carrito</button>
        </div>
      ) : null}
      {aviso}
    </div>
  );
}
