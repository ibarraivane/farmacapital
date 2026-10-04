import { useEffect, useMemo, useRef, useState } from "react";
import { ChevronDown, Search, X } from "lucide-react";
import { MAX_CHIPS_VISIBLES, agruparPorInicial, filtrarOpciones, repartirChips } from "./chipsFiltro";

/**
 * Filtro por chips que no inunda la pantalla: muestra pocas opciones (las de
 * más producto + la elegida) y esconde el resto detrás de «Ver todas», un panel
 * con buscador y lista A–Z. Sirve igual para 8 categorías que para 127 marcas.
 *
 * No sabe qué filtra: recibe `opciones` (texto) y avisa con `onChange(opcion)`.
 */
export default function FiltroChips({
  opciones = [],
  valor = "Todos",
  onChange,
  conteos = {},
  max = MAX_CHIPS_VISIBLES,
  etiquetaMas = "Ver todas",
  etiquetaBuscar = "Buscar",
}) {
  const [abierto, setAbierto] = useState(false);
  const [texto, setTexto] = useState("");
  const raiz = useRef(null);
  const campo = useRef(null);
  const botonMas = useRef(null);

  const { visibles, ocultas } = useMemo(
    () => repartirChips(opciones, { valor, conteos, max }),
    [opciones, valor, conteos, max]
  );
  // En el panel se listan TODAS las opciones menos «Todos»: así se puede
  // cambiar de una a otra sin cerrar y reabrir, y se ve cuál está activa.
  const todasLasOpciones = useMemo(() => opciones.filter((o) => o && o !== "Todos"), [opciones]);
  const grupos = useMemo(
    () => agruparPorInicial(filtrarOpciones(todasLasOpciones, texto)),
    [todasLasOpciones, texto]
  );

  const cerrar = (devolverFoco = false) => {
    setAbierto(false);
    setTexto("");
    if (devolverFoco) botonMas.current?.focus();
  };

  useEffect(() => {
    if (!abierto) return undefined;
    campo.current?.focus();
    const fuera = (e) => {
      if (raiz.current && !raiz.current.contains(e.target)) {
        setAbierto(false);
        setTexto("");
      }
    };
    const tecla = (e) => {
      if (e.key === "Escape") {
        setAbierto(false);
        setTexto("");
        botonMas.current?.focus();
      }
    };
    document.addEventListener("mousedown", fuera);
    document.addEventListener("keydown", tecla);
    return () => {
      document.removeEventListener("mousedown", fuera);
      document.removeEventListener("keydown", tecla);
    };
  }, [abierto]);

  const elegir = (o) => {
    onChange?.(o);
    cerrar(true);
  };

  return (
    <div className="fc-chips" ref={raiz}>
      <div className="fc-chips-row">
        {visibles.map((c) => (
          <button
            key={c}
            type="button"
            className="fc-filter"
            aria-pressed={valor === c}
            onClick={() => onChange?.(c)}
          >
            {c}
          </button>
        ))}
        {ocultas.length ? (
          <button
            ref={botonMas}
            type="button"
            className="fc-filter fc-filter--mas"
            aria-haspopup="dialog"
            aria-expanded={abierto}
            onClick={() => (abierto ? cerrar() : setAbierto(true))}
          >
            {etiquetaMas} <span className="fc-filter-n">{ocultas.length}</span>
            <ChevronDown aria-hidden="true" />
          </button>
        ) : null}
      </div>

      {abierto ? (
        <div className="fc-chips-panel" role="dialog" aria-label={etiquetaMas}>
          <div className="fc-chips-panel-top">
            <label className="fc-chips-buscar">
              <Search aria-hidden="true" />
              <input
                ref={campo}
                className="farmacapital-field-input"
                type="search"
                value={texto}
                onChange={(e) => setTexto(e.target.value)}
                placeholder={etiquetaBuscar}
                aria-label={etiquetaBuscar}
                style={{
                  background: "#ffffff",
                  color: "#0f172a",
                  colorScheme: "light",
                  WebkitTextFillColor: "#0f172a",
                  caretColor: "#0f172a",
                }}
              />
            </label>
            <button type="button" className="fc-chips-cerrar" aria-label="Cerrar" onClick={() => cerrar(true)}>
              <X aria-hidden="true" />
            </button>
          </div>

          {grupos.length ? (
            <div className="fc-chips-lista">
              {grupos.map((g) => (
                <section key={g.letra} className="fc-chips-grupo" aria-label={`Letra ${g.letra}`}>
                  <h3>{g.letra}</h3>
                  <div>
                    {g.items.map((o) => (
                      <button
                        key={o}
                        type="button"
                        className="fc-chips-opcion"
                        aria-pressed={valor === o}
                        onClick={() => elegir(o)}
                      >
                        {o}
                        {conteos[o] ? <span className="fc-filter-n">{conteos[o]}</span> : null}
                      </button>
                    ))}
                  </div>
                </section>
              ))}
            </div>
          ) : (
            <p className="fc-small fc-chips-vacio">No hay coincidencias.</p>
          )}
        </div>
      ) : null}
    </div>
  );
}
