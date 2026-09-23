import { mapearFichaTienda } from "../../lib/catalogoFichas/mapearFichaTienda";

function Accordion({ titulo, abierta, children }) {
  if (!children) return null;
  return (
    <details className="farmacapital-ficha-acc" open={abierta || undefined}>
      <summary>
        <span>{titulo}</span>
        <span className="farmacapital-ficha-chev" aria-hidden="true" />
      </summary>
      <div className="farmacapital-ficha-accb">{children}</div>
    </details>
  );
}

function Lista({ items }) {
  const list = (items || []).filter(Boolean);
  if (!list.length) return null;
  return (
    <ul className="farmacapital-ficha-ul">
      {list.map((x) => <li key={x}>{x}</li>)}
    </ul>
  );
}

/**
 * Ficha de tienda: solo contenido publicado. Sin él, ficha técnica + WhatsApp.
 */
export default function FichaProductoEnriquecida({
  producto,
  ficha,
  monografia,
  whatsappHref,
  ocultarFichaTecnica = false,
}) {
  const ui = mapearFichaTienda({ producto, ficha, monografia });
  const clinica = ui.clinica;
  const fab = ui.fabricante;

  return (
    <section className="farmacapital-ficha-info" aria-label="Información del producto">
      {ui.resumen ? <p className="farmacapital-ficha-resumen">{ui.resumen}</p> : null}
      {ui.chips.length ? (
        <div className="farmacapital-ficha-chips">
          {ui.chips.map((c) => <span key={c}>{c}</span>)}
        </div>
      ) : null}

      {clinica || fab ? (
        <>
          <h2 className="farmacapital-ficha-h2">
            {ui.tipo === "medicamento" ? "Información del medicamento" : "Sobre el producto"}
          </h2>
          <p className="farmacapital-ficha-legal">{ui.leyendaLegal}</p>
        </>
      ) : null}

      {clinica ? (
        <>
          <Accordion titulo="¿Para qué sirve?" abierta>
            {clinica.para_que_sirve ? <p>{clinica.para_que_sirve}</p> : null}
          </Accordion>
          <Accordion titulo="¿Cómo se toma?">
            <Lista items={clinica.como_se_usa} />
            <p className="farmacapital-ficha-fine">Sigue siempre la indicación de tu médico si es distinta.</p>
          </Accordion>
          <Accordion titulo="Antes de tomarlo">
            {clinica.no_usar_si.length ? <p className="farmacapital-ficha-sub">No lo tomes si:</p> : null}
            <Lista items={clinica.no_usar_si} />
            {clinica.consulta_si.length ? <p className="farmacapital-ficha-sub">Consulta a tu médico si:</p> : null}
            <Lista items={clinica.consulta_si} />
          </Accordion>
          <Accordion titulo="Interacciones">
            {clinica.interacciones ? <p>{clinica.interacciones}</p> : null}
          </Accordion>
          <Accordion titulo="Posibles efectos secundarios">
            <Lista items={clinica.efectos} />
            {clinica.alarma ? <p className="farmacapital-ficha-fine">{clinica.alarma}</p> : null}
          </Accordion>
          <Accordion titulo="Cómo guardarlo">
            <Lista items={clinica.conservacion} />
          </Accordion>
        </>
      ) : null}

      {fab ? (
        <>
          <Accordion titulo="Descripción" abierta>
            {fab.descripcion ? <p>{fab.descripcion}</p> : null}
          </Accordion>
          {fab.para_quien ? (
            <Accordion titulo="Para quién es">
              <div className="farmacapital-ficha-spec">
                {fab.para_quien.tipo_piel ? <div className="r"><span>Tipo de piel</span><span>{fab.para_quien.tipo_piel}</span></div> : null}
                {fab.para_quien.zona ? <div className="r"><span>Zona</span><span>{fab.para_quien.zona}</span></div> : null}
                {fab.para_quien.textura ? <div className="r"><span>Textura</span><span>{fab.para_quien.textura}</span></div> : null}
              </div>
            </Accordion>
          ) : null}
          <Accordion titulo="Cómo se usa">
            <Lista items={fab.modo_de_uso} />
          </Accordion>
          <Accordion titulo="Ingredientes">
            {fab.ingredientes_destacados.length ? <p className="farmacapital-ficha-sub">Destacados</p> : null}
            <Lista items={fab.ingredientes_destacados} />
            {fab.inci_completo ? (
              <>
                <p className="farmacapital-ficha-sub">Lista completa (INCI)</p>
                <p className="farmacapital-ficha-fine">{fab.inci_completo}</p>
              </>
            ) : null}
          </Accordion>
          <Accordion titulo="Precauciones">
            <Lista items={fab.precauciones} />
          </Accordion>
        </>
      ) : null}

      {ocultarFichaTecnica ? null : (
      <Accordion titulo="Ficha técnica" abierta={!clinica && !fab}>
        <div className="farmacapital-ficha-spec">
          {ui.fichaTecnica.map((row) => (
            <div className="r" key={row.k}><span>{row.k}</span><span>{row.v}</span></div>
          ))}
        </div>
      </Accordion>
      )}

      {ui.instructivo_url ? (
        <Accordion titulo="Instructivo completo">
          <a className="farmacapital-ficha-doc" href={ui.instructivo_url} target="_blank" rel="noopener noreferrer">
            Ver instructivo (PDF o foto del empaque)
          </a>
        </Accordion>
      ) : null}

      {whatsappHref ? (
        <aside className="farmacapital-ficha-wa">
          <div>
            <div className="t">¿Tienes dudas sobre este producto?</div>
            <div className="d">Escríbenos por WhatsApp y te atiende personal de la farmacia.</div>
            <a href={whatsappHref} target="_blank" rel="noopener noreferrer">Preguntar por WhatsApp</a>
          </div>
        </aside>
      ) : null}
    </section>
  );
}
