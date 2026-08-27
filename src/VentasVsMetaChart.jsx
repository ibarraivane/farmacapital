import { useMemo, useState } from "react";
import { C_LIGHT, BRAND } from "./constants";
import { useMediaQuery } from "./hooks/useMediaQuery";
import { construirSerie, resumenMetasActuales, resumenPunto, ymdMexico } from "./lib/ventasVsMeta";
import { mezclarCfgMetas } from "./utils/turnosMetas";

const GRAINS = [
  { id: "dia", label: "Día" },
  { id: "semana", label: "Semana" },
  { id: "mes", label: "Mes" },
];

const fmtK = (n) => {
  const v = parseFloat(n || 0);
  if (v >= 1000) return `$${(v / 1000).toFixed(1)}k`;
  return `$${Math.round(v).toLocaleString("es-MX")}`;
};

function colorBarra(p) {
  const { pct, ok } = resumenPunto(p);
  if (ok) return C_LIGHT.green;
  if (pct >= 70) return C_LIGHT.blue;
  if (pct >= 40) return C_LIGHT.amber;
  return C_LIGHT.red;
}

export function MetasPeriodoStrip({ porDia, cfg, hoyYmd }) {
  const C = C_LIGHT;
  const { dia, semana, mes } = resumenMetasActuales({ porDia, cfg, hoyYmd: hoyYmd || ymdMexico() });
  const cards = [
    { id: "dia", label: "Hoy", punto: dia },
    { id: "semana", label: "Esta semana", punto: semana },
    { id: "mes", label: "Este mes", punto: mes },
  ];
  return (
    <div className="fc-metas-strip" aria-label="Metas de hoy, semana y mes">
      {cards.map((c) => {
        const { pct, ok, falta } = resumenPunto(c.punto);
        const col = colorBarra(c.punto);
        const meta = c.punto?.meta || 0;
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
              {meta > 0
                ? (ok ? `Meta ${fmtK(meta)} cubierta` : `de ${fmtK(meta)} · faltan ${fmtK(falta)}`)
                : "Falta configurar la meta"}
            </div>
          </div>
        );
      })}
    </div>
  );
}

export default function VentasVsMetaChart({ porDia, cfg, hoyYmd, onEditarMetas }) {
  const C = C_LIGHT;
  const [grano, setGrano] = useState("dia");
  const [selKey, setSelKey] = useState(null);
  const isPhone = useMediaQuery("(max-width: 768px)");
  const isLandscapePhone = useMediaQuery("(max-width: 900px) and (orientation: landscape)");

  const hoy = hoyYmd || ymdMexico();
  const cfgSafe = useMemo(() => mezclarCfgMetas(cfg), [cfg]);
  const ventana = grano !== "dia" ? undefined : (isPhone ? (isLandscapePhone ? 14 : 7) : 21);

  const serie = useMemo(
    () => construirSerie({ porDia, cfg: cfgSafe, grano, hoyYmd: hoy, ventana }),
    [porDia, cfgSafe, grano, hoy, ventana],
  );

  const elegido = serie.find((p) => p.key === selKey) || serie.find((p) => p.esActual) || serie[serie.length - 1];
  const { pct, falta, ok } = resumenPunto(elegido);
  const max = Math.max(...serie.map((p) => Math.max(p.actual || 0, p.meta || 0)), 1);

  const sub = grano === "dia"
    ? "Cada barra es un día. La raya punteada es la meta de ese día (domingo no es lo mismo que viernes)."
    : grano === "semana"
      ? "Lunes a domingo. La raya punteada es la meta de esos 7 días."
      : "La raya punteada es la meta mensual que configuraste.";

  return (
    <section className="fc-ventas-meta" style={{
      background: C.card,
      border: `1px solid ${C.border}`,
      borderRadius: 12,
      padding: "16px 16px 14px",
      marginBottom: 24,
      minWidth: 0,
    }}>
      <MetasPeriodoStrip porDia={porDia} cfg={cfgSafe} hoyYmd={hoy} />

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
        <span><i className="fc-ventas-meta-swatch" /> Ventas</span>
        <span><i className="fc-ventas-meta-dash" /> Meta</span>
      </div>

      <div
        className="fc-ventas-meta-scroll"
        role="img"
        aria-label={elegido
          ? `${elegido.detalle}: ${fmtK(elegido.actual)} de ${fmtK(elegido.meta)}`
          : "Ventas contra meta"}
      >
        <div className={`fc-ventas-meta-bars${grano === "dia" ? " is-dia" : ""}`}>
          {serie.map((p) => {
            const h = p.actual > 0 ? Math.max(3, (p.actual / max) * 100) : 0;
            const metaH = p.meta > 0 ? Math.min(100, (p.meta / max) * 100) : 0;
            const activo = elegido?.key === p.key;
            const col = colorBarra(p);
            return (
              <button
                key={p.key}
                type="button"
                className={`fc-ventas-meta-col${activo ? " is-on" : ""}${p.esActual ? " is-hoy" : ""}`}
                aria-pressed={activo}
                aria-label={`${p.detalle}: ${fmtK(p.actual)} de meta ${fmtK(p.meta)}`}
                onClick={() => setSelKey(p.key)}
              >
                <span className="fc-ventas-meta-track">
                  <span className="fc-ventas-meta-fill" style={{ height: `${h}%`, background: col }} />
                  {metaH > 0 && (
                    <span
                      className="fc-ventas-meta-tick"
                      aria-hidden="true"
                      style={{ bottom: `${metaH}%` }}
                    />
                  )}
                </span>
                <span className="fc-ventas-meta-xlabel">
                  <strong>{p.label}</strong>
                  {grano === "dia" && p.labelDia ? <em>{p.labelDia}</em> : null}
                </span>
              </button>
            );
          })}
        </div>
      </div>

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
