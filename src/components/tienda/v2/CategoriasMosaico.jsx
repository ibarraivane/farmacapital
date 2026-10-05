import EnlaceTienda from "./EnlaceTienda";

/**
 * «Comprar por categoría»: puertas de entrada del inicio, en discos con la foto
 * de un producto real de cada mundo (como Farmacias del Ahorro, pero con los
 * tonos de FarmaCapital). Reemplaza la lista de categorías en cajas de texto.
 *
 * Presentacional: recibe los `items` armados por InicioV2.
 *   { id, titulo, foto?, icono?, tono, href?, onClick }
 */
export default function CategoriasMosaico({ items = [], titulo = "Comprar por categoría" }) {
  if (!items.length) return null;
  return (
    <section className="fc-section fc-mosaico" aria-labelledby="fc-mosaico-titulo">
      <div className="fc-section-top">
        <h2 id="fc-mosaico-titulo">{titulo}</h2>
      </div>
      <ul className="fc-mosaico-grid">
        {items.map((it) => {
          const clase = `fc-mosaico-item fc-mosaico-item--${it.tono || "azul"}`;
          const cuerpo = (
            <>
              <span className="fc-mosaico-disco" aria-hidden="true">
                {it.foto ? <img src={it.foto} alt="" loading="lazy" decoding="async" draggable={false} /> : it.icono}
              </span>
              <span className="fc-mosaico-nombre">{it.titulo}</span>
            </>
          );
          return (
            <li key={it.id}>
              {it.href ? (
                <EnlaceTienda className={clase} href={it.href} onNavigate={it.onClick}>
                  {cuerpo}
                </EnlaceTienda>
              ) : (
                <button type="button" className={clase} onClick={it.onClick}>
                  {cuerpo}
                </button>
              )}
            </li>
          );
        })}
      </ul>
    </section>
  );
}
