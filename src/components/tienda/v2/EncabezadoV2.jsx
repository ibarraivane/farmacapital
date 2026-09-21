import { useEffect, useMemo, useRef, useState } from "react";
import { Menu, Search, ShoppingCart } from "lucide-react";
import { logoFullSrc, logoFullSrcSet } from "../../../brand";
import { FARMACIA_FISCAL } from "../../../constants/farmaciaFiscal";
import { HORARIO_FARMACIA } from "../../../constants/turnos";
import { navigateToCita } from "../../../utils/clienteSession";
import { tiendaCatalogSearchSuggestions } from "../../../utils/fuzzySearch";
import { irACatalogoCategoria } from "../../../lib/tiendaCatalogoCategorias";

const PLACEHOLDER = "Medicamento, sustancia o marca";

function horarioAbiertoHoy() {
  return `Abierto hoy ${HORARIO_FARMACIA.apertura}–${HORARIO_FARMACIA.cierre}`;
}

export default function EncabezadoV2({
  page,
  setPage,
  cart = [],
  user,
  busqHero,
  setBusqHero,
  productos = [],
  setProdDetalle,
  renderMenu,
  aviso,
}) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [busqFocus, setBusqFocus] = useState(false);
  const searchRef = useRef(null);
  const n = (cart || []).reduce((a, c) => a + (Number(c.qty) || 0), 0);
  const q = String(busqHero || "");
  const suggestions = useMemo(
    () => (busqFocus && q.trim().length >= 2
      ? tiendaCatalogSearchSuggestions(productos || [], q, { limit: 8 })
      : []),
    [productos, q, busqFocus]
  );

  useEffect(() => { setMenuOpen(false); }, [page]);

  const irACatalogoBusqueda = () => {
    const t = q.trim();
    setBusqFocus(false);
    try { if (t) sessionStorage.setItem("farmacapital_busq", t); } catch (_) { /* noop */ }
    setPage?.("catalogo");
  };

  const pick = (row) => {
    if (!row) return;
    setProdDetalle?.(row);
    setBusqFocus(false);
    setPage?.("detalle", { productId: row.id });
    if (typeof window.scrollTo === "function") {
      try { window.scrollTo({ top: 0, behavior: "smooth" }); } catch (_) { /* jsdom */ }
    }
  };

  const go = (id, opts) => {
    setMenuOpen(false);
    if (id === "cita") navigateToCita(setPage);
    else if (opts == null) setPage?.(id);
    else setPage?.(id, opts);
  };

  const wa = FARMACIA_FISCAL.telefono_display;
  const waHref = `https://wa.me/52${FARMACIA_FISCAL.telefono}`;

  const searchBox = (
    <label className="search">
      <Search className="search-ico" size={18} strokeWidth={2.2} aria-hidden />
      <input
        ref={searchRef}
        className="farmacapital-field-input"
        type="search"
        value={q}
        placeholder={PLACEHOLDER}
        aria-label="Buscar"
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
          if (e.key === "Enter") {
            e.preventDefault();
            irACatalogoBusqueda();
          }
          if (e.key === "Escape") setBusqFocus(false);
        }}
      />
      {suggestions.length > 0 && (
        <div className="suggest" role="listbox" aria-label="Sugerencias de búsqueda">
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
    </label>
  );

  return (
    <div style={{ position: "sticky", top: 0, zIndex: 50 }}>
      <div className="hdr-top">
        <span className="dot pulse" aria-hidden />
        <span>{horarioAbiertoHoy()}</span>
        <a className="hdr-top-wa" href={waHref} target="_blank" rel="noopener noreferrer">
          WhatsApp {wa}
        </a>
      </div>
      <header className="hdr">
        <div className="row">
          <button type="button" className="hdr-logo" onClick={() => go("home")} aria-label="Inicio FarmaCapital">
            <img
              src={logoFullSrc({ light: true })}
              srcSet={logoFullSrcSet({ light: true })}
              alt="FarmaCapital"
              height={30}
            />
          </button>
          <div className="hdr-actions">
            <button type="button" className="iconbtn btn" onClick={() => go("carrito")} aria-label="Carrito">
              <ShoppingCart size={20} color="#fff" aria-hidden />
              {n > 0 ? <span className="badge pop">{n}</span> : null}
            </button>
            <button
              type="button"
              className="iconbtn btn iconbtn-menu"
              aria-label={menuOpen ? "Cerrar menú" : "Abrir menú"}
              aria-expanded={menuOpen}
              onClick={() => setMenuOpen((o) => !o)}
            >
              <Menu size={20} color="#fff" aria-hidden />
            </button>
          </div>
        </div>
        {searchBox}
        <div className="hdr-desk-links">
          <button type="button" onClick={() => go(user ? "cuenta" : "login")}>Mi cuenta</button>
          <button type="button" onClick={() => go("carrito")}>
            <ShoppingCart size={18} color="#fff" aria-hidden />
            Carrito{n > 0 ? ` (${n})` : ""}
          </button>
        </div>
      </header>
      <nav className="hdr-cats" aria-label="Categorías">
        <button type="button" onClick={() => go("catalogo", { rx: false })}>Medicamentos</button>
        <button type="button" onClick={() => go("conseguir")}>Dermocosmética</button>
        <button type="button" onClick={() => irACatalogoCategoria(setPage, "Vitaminas")}>Nutrición</button>
        <button type="button" onClick={() => go("conseguir")}>Equipo médico</button>
        <button type="button" onClick={() => go("cita")}>Consultorio</button>
        <button type="button" className="hdr-cats-cta" onClick={() => go("conseguir")}>
          Cotizar especializado →
        </button>
      </nav>
      {aviso}
      {typeof renderMenu === "function" ? renderMenu({ abierto: menuOpen, onClose: () => setMenuOpen(false) }) : null}
    </div>
  );
}
