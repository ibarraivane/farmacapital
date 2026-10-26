import { useMemo, useState } from "react";
import { C_LIGHT, BRAND } from "./constants";
import { useMediaQuery } from "./hooks/useMediaQuery";
import { construirSerie, fmtMiles, notaCruceSemanaMes, resumenMetasActuales, resumenPunto, ymdMexico } from "./lib/ventasVsMeta";
import { mezclarCfgMetas } from "./utils/turnosMetas";
import "./styles/ventasMeta.css";

const GRAINS = [
  { id: "dia", label: "Día" },
  { id: "semana", label: "Semana" },
  { id: "mes", label: "Mes" },
];

const fmtK = fmtMiles;
const GANANCIA = "#0f766e";

function colorBarra(p) {
  const { pct, ok } = resumenPunto(p);
  if (ok) return C_LIGHT.green;
  if (pct >= 70) return C_LIGHT.blue;
  if (pct >= 40) return C_LIGHT.amber;
  return C_LIGHT.red;
}

function lineaMeta(punto) {
  const { ok, falta } = resumenPunto(punto);
  const meta = punto?.meta || 0;
  const completa = punto?.metaCompleta || 0;
  if (!(meta > 0)) return "Falta configurar la meta";
  const ritmo = completa > meta + 0.5;
  const cabeza = ok
    ? `Meta ${fmtK(meta)} cubierta`
    : ritmo
      ? `ritmo de ${fmtK(meta)} · faltan ${fmtK(falta)}`
      : `de ${fmtK(meta)} · faltan ${fmtK(falta)}`;
  if (ritmo) return `${cabeza} · meta ${fmtK(completa)}`;
  return cabeza;
}

export function MetasPeriodoStrip({ porDia, gananciaPorDia, cfg, hoyYmd }) {
  const C = C_LIGHT;
  const hoy = hoyYmd || ymdMexico();
  const { dia, semana, mes } = resumenMetasActuales({ porDia, gananciaPorDia, cfg, hoyYmd: hoy });
  const nota = notaCruceSemanaMes({ semana, mes, hoyYmd: hoy });
  const cards = [
    { id: "dia", label: "Hoy", punto: dia },
    { id: "semana", label: "Esta semana", punto: semana },
    { id: "mes", label: "Este mes", punto: mes },
  ];
  return (
    <>
      <div className="fc-metas-strip" aria-label="Metas de hoy, semana y mes">
        {cards.map((c) => {
          const { pct, ok } = resumenPunto(c.punto);
          const col = colorBarra(c.punto);
          const ganancia = c.punto?.ganancia;
          return (
            <div key={c.id} className="fc-metas-strip-card">
              <div style={{ color: C.textDim, fontSize: 10, fontWeight: 800, letterSpacing: 0.6, textTransform: "uppercase" }}>{c.label}</div>
              <div className="fc-metas-strip-row">
                <div style={{ color: C.text, fontWeight: 900, fontSize: 18, fontVariantNumeric: "tabular-nums", whiteSpace: "nowrap" }}>
                  {fmtK(c.punto?.actual)}
                </div>
                <div style={{ color: col, fontWeight: 800, fontSize: 13, whiteSpace: "nowrap" }}>
                  {ok ? "Meta ok" : `${pct.toFixed(0)}%`}
                </div>
              </div>
              <div className="fc-metas-strip-bar">
                <div style={{ height: "100%", width: `${Math.min(100, pct)}%`, background: col, borderRadius: 99 }} />
              </div>
              <div style={{ color: C.textMid, fontSize: 11, marginTop: 6, lineHeight: 1.35 }}>
                {lineaMeta(c.punto)}
              </div>
              {ganancia != null && (
                <div style={{ color: GANANCIA, fontSize: 11, fontWeight: 800, marginTop: 4 }}>
                  Ganancia {fmtK(ganancia)}
                </div>
              )}
            </div>
          );
        })}
      </div>
      {nota ? <p className="fc-ventas-meta-note">{nota}</p> : null}
    </>
  );
}

export default function VentasVsMetaChart({ porDia, gananciaPorDia, cfg, hoyYmd, onEditarMetas }) {
  const C = C_LIGHT;
  const [grano, setGrano] = useState("dia");
  const [selKey, setSelKey] = useState(null);
  const isPhone = useMediaQuery("(max-width: 768px)");
  const isIphone = useMediaQuery("(max-width: 767px)");
  const isLandscapePhone = useMediaQuery("(max-width: 900px) and (orientation: landscape)");

  const hoy = hoyYmd || ymdMexico();
  const cfgSafe = useMemo(() => mezclarCfgMetas(cfg), [cfg]);
  const ventana = grano !== "dia" ? undefined : (isPhone ? (isLandscapePhone ? 14 : 7) : 21);

  const serie = useMemo(
    () => construirSerie({ porDia, gananciaPorDia, cfg: cfgSafe, grano, hoyYmd: hoy, ventana }),
    [porDia, gananciaPorDia, cfgSafe, grano, hoy, ventana],
  );

  const elegido = serie.find((p) => p.key === selKey) || serie.find((p) => p.esActual) || serie[serie.length - 1];
  const { pct, falta, ok } = resumenPunto(elegido);
  const hayGanancia = serie.some((p) => p.ganancia != null);
  const max = Math.max(
    ...serie.map((p) => Math.max(p.actual || 0, p.meta || 0, Math.max(0, p.ganancia || 0))),
    1,
  );

  const par = hayGanancia ? "par de barras es" : "barra es";
  const ganTxt = hayGanancia
    ? " La verde es la ganancia bruta: venta neta menos el costo de lo vendido."
    : "";
  const sub = grano === "dia"
    ? `Cada ${par} el día civil en México (tickets completados menos devoluciones de ese día). La raya punteada es la meta de venta (domingo no es lo mismo que viernes).${ganTxt}`
    : grano === "semana"
      ? `Lunes a domingo del calendario de la farmacia. La raya punteada es la meta de venta de esos 7 días.${ganTxt}`
      : `Mes calendario. La raya punteada es la meta mensual de venta.${ganTxt}`;

  return (
    <section className="fc-ventas-meta" style={{
      background: C.card,
      border: `1px solid ${C.border}`,
      borderRadius: 12,
      padding: "16px 16px 14px",
      marginBottom: 24,
      minWidth: 0,
    }}>
      <MetasPeriodoStrip porDia={porDia} gananciaPorDia={gananciaPorDia} cfg={cfgSafe} hoyYmd={hoy} />

      <div className="fc-ventas-meta-head">
        <div>
          <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.5 }}>
            VENTAS VS META
          </div>
          <p style={{ margin: "4px 0 0", color: C.textMid, fontSize: 13, lineHeight: 1.45, maxWidth: 560 }}>
            {sub}
            {onEditarMetas && (
              <>
                {" "}
                <button
                  type="button"
                  onClick={() => {
                    try { sessionStorage.setItem("farmacapital_config_tab", "ventas"); } catch { /* noop */ }
                    onEditarMetas();
                  }}
                  style={{
                    border: "none",
                    background: "none",
                    padding: 0,
                    color: BRAND.primary,
                    fontWeight: 800,
                    fontSize: 13,
                    cursor: "pointer",
                    textDecoration: "underline",
                  }}
                >
                  Cambiar metas
                </button>
              </>
            )}
          </p>
        </div>
        <div role="tablist" aria-label="Periodo de la gráfica" className="fc-ventas-meta-tabs">
          {GRAINS.map((g) => {
            const on = grano === g.id;
            return (
              <button
                key={g.id}
                type="button"
                role="tab"
                aria-selected={on}
                onClick={() => { setGrano(g.id); setSelKey(null); }}
                style={{
                  padding: "7px 14px",
                  border: "none",
                  borderRadius: 8,
                  background: on ? "#fff" : "transparent",
                  color: on ? C.text : C.textMid,
                  fontWeight: 800,
                  fontSize: 13,
                  cursor: "pointer",
                  boxShadow: on ? "0 1px 2px rgba(15,23,42,.08)" : "none",
                }}
              >
                {g.label}
              </button>
            );
          })}
        </div>
      </div>

      <div className="fc-ventas-meta-legend" aria-hidden="true">
        <span><i className="fc-ventas-meta-swatch" /> Venta</span>
        {hayGanancia && <span><i className="fc-ventas-meta-swatch is-ganancia" /> Ganancia</span>}
        <span><i className="fc-ventas-meta-dash" /> Meta</span>
      </div>

      <figure
        className="fc-ventas-meta-scroll"
        aria-label={elegido
          ? `${elegido.detalle}: ${fmtK(elegido.actual)} de ${fmtK(elegido.meta)}${elegido.ganancia != null ? `, ganancia ${fmtK(elegido.ganancia)}` : ""}`
          : "Ventas contra meta"}
      >
        <div className={`fc-ventas-meta-bars${grano === "dia" ? " is-dia" : ""}${hayGanancia ? " has-ganancia" : ""}`}>
          {serie.map((p) => {
            const h = p.actual > 0 ? Math.max(3, (p.actual / max) * 100) : 0;
            const g = p.ganancia > 0 ? Math.max(3, (p.ganancia / max) * 100) : 0;
            const metaH = p.meta > 0 ? Math.min(100, (p.meta / max) * 100) : 0;
            const activo = elegido?.key === p.key;
            const col = colorBarra(p);
            const ganLabel = p.ganancia != null ? `, ganancia ${fmtK(p.ganancia)}` : "";
            return (
              <button
                key={p.key}
                type="button"
                className={`fc-ventas-meta-col${activo ? " is-on" : ""}${p.esActual ? " is-hoy" : ""}`}
                aria-pressed={activo}
                aria-label={`${p.detalle}: ${fmtK(p.actual)} de meta ${fmtK(p.meta)}${ganLabel}`}
                onClick={() => setSelKey(p.key)}
              >
                {hayGanancia ? (
                  <span className="fc-ventas-meta-pair">
                    <span className="fc-ventas-meta-track">
                      <span className="fc-ventas-meta-fill" style={{ height: `${h}%`, background: col }} />
                      {metaH > 0 && (
                        <span className="fc-ventas-meta-tick" aria-hidden="true" style={{ bottom: `${metaH}%` }} />
                      )}
                    </span>
                    <span className="fc-ventas-meta-track is-ganancia">
                      <span
                        className={`fc-ventas-meta-fill is-ganancia${p.ganancia < 0 ? " is-neg" : ""}`}
                        style={{
                          height: p.ganancia < 0 ? "4px" : `${g}%`,
                          background: p.ganancia < 0 ? C_LIGHT.red : GANANCIA,
                        }}
                      />
                    </span>
                  </span>
                ) : (
                  <span className="fc-ventas-meta-track">
                    <span className="fc-ventas-meta-fill" style={{ height: `${h}%`, background: col }} />
                    {metaH > 0 && (
                      <span className="fc-ventas-meta-tick" aria-hidden="true" style={{ bottom: `${metaH}%` }} />
                    )}
                  </span>
                )}
                <span className="fc-ventas-meta-xlabel">
                  <strong>{isIphone && p.labelDia ? p.labelDia : p.label}</strong>
                  {!isIphone && grano === "dia" && p.labelDia ? <em>{p.labelDia}</em> : null}
                </span>
              </button>
            );
          })}
        </div>
      </figure>

      {elegido && (
        <div className="fc-ventas-meta-foot" aria-live="polite">
          <div>
            <div style={{ color: C.text, fontWeight: 800, fontSize: 15 }}>
              {elegido.detalle}
              {elegido.esActual ? (grano === "dia" ? " · hoy" : " · en curso") : ""}
            </div>
            <div style={{ color: C.textMid, fontSize: 13, marginTop: 2 }}>
              {!elegido.meta
                ? `${fmtK(elegido.actual)} vendidos · falta configurar la meta.`
                : ok
                  ? `Meta cubierta. ${fmtK(elegido.actual)} de ${fmtK(elegido.meta)}.`
                  : `${fmtK(elegido.actual)} de ${fmtK(elegido.meta)} · falta ${fmtK(falta)}`}
              {elegido.ganancia != null && (
                <>
                  {" "}
                  Ganancia {fmtK(elegido.ganancia)}
                  {elegido.actual > 0 ? ` (${Math.round((elegido.ganancia / elegido.actual) * 100)}% de la venta).` : "."}
                </>
              )}
            </div>
          </div>
          <div style={{ fontWeight: 800, fontSize: 22, color: colorBarra(elegido), fontVariantNumeric: "tabular-nums" }}>
            {pct.toFixed(0)}%
          </div>
        </div>
      )}
    </section>
  );
}
