import { useMemo, useState } from "react";
import { C_LIGHT } from "../../../constants";
import { Box } from "../../../ui";
import {
  clasificarFC,
  clasificarIMC,
  clasificarSat,
  clasificarTA,
  clasificarTemp,
  fmtFechaCorta,
  narrarEvolucion,
  tendenciaCampo,
  ultimoConValor,
} from "../../../lib/evolucionClinica";

const C = C_LIGHT;

const TONO = {
  green: C.green,
  amber: C.amber,
  red: C.red,
};

function tonoDe(cl) {
  return (cl && TONO[cl.tono]) || C.textMid;
}

function fmtVal(n, decimales) {
  if (!Number.isFinite(n)) return "—";
  if (decimales === 0) return String(Math.round(n));
  return Number(n).toFixed(decimales).replace(/\.0$/, "");
}

function LineaSvg({ serie, keys, colors, height = 118, selectedId, onSelect, decimales = 1 }) {
  const W = 440;
  const H = height;
  const padL = 34;
  const padR = 12;
  const padT = 10;
  const padB = 22;
  const innerW = W - padL - padR;
  const innerH = H - padT - padB;

  const all = [];
  keys.forEach((k) => {
    serie.forEach((p) => {
      if (Number.isFinite(p[k])) all.push(p[k]);
    });
  });
  if (!all.length) return null;

  let min = Math.min(...all);
  let max = Math.max(...all);
  if (min === max) {
    min -= 1;
    max += 1;
  }
  const span = max - min;
  min -= span * 0.12;
  max += span * 0.12;

  const conX = serie.filter((p) => keys.some((k) => Number.isFinite(p[k])));
  const xAt = (i) => {
    if (conX.length <= 1) return padL + innerW / 2;
    return padL + (i / (conX.length - 1)) * innerW;
  };
  const yAt = (v) => padT + ((max - v) / (max - min)) * innerH;

  const polylines = keys.map((k, ki) => {
    const pts = conX
      .map((p, i) => (Number.isFinite(p[k]) ? `${xAt(i).toFixed(1)},${yAt(p[k]).toFixed(1)}` : null))
      .filter(Boolean)
      .join(" ");
    return { k, color: colors[ki], pts };
  });

  const ticks = [max, (max + min) / 2, min];

  return (
    <svg
      viewBox={`0 0 ${W} ${H}`}
      width="100%"
      height={height}
      role="img"
      aria-label="Gráfica de evolución"
      style={{ display: "block" }}
    >
      {ticks.map((t, i) => {
        const y = yAt(t);
        return (
          <g key={i}>
            <line x1={padL} x2={W - padR} y1={y} y2={y} stroke={C.border} strokeWidth="1" />
            <text x={padL - 4} y={y + 3} textAnchor="end" fontSize="8" fill={C.textDim}>
              {fmtVal(t, decimales)}
            </text>
          </g>
        );
      })}
      {polylines.map((pl) =>
        pl.pts ? (
          <polyline
            key={pl.k}
            fill="none"
            stroke={pl.color}
            strokeWidth="2.4"
            strokeLinejoin="round"
            strokeLinecap="round"
            points={pl.pts}
          />
        ) : null
      )}
      {conX.map((p, i) =>
        keys.map((k, ki) => {
          if (!Number.isFinite(p[k])) return null;
          const sel = selectedId === p.id;
          return (
            <circle
              key={`${p.id}-${k}`}
              cx={xAt(i)}
              cy={yAt(p[k])}
              r={sel ? 5.5 : 3.6}
              fill={sel ? colors[ki] : C.card}
              stroke={colors[ki]}
              strokeWidth={sel ? 2.4 : 1.8}
              style={{ cursor: onSelect ? "pointer" : "default" }}
              onClick={() => onSelect?.(p.id)}
            />
          );
        })
      )}
      {conX.map((p, i) => {
        if (conX.length > 6 && i !== 0 && i !== conX.length - 1 && i !== Math.floor(conX.length / 2)) {
          return null;
        }
        return (
          <text
            key={`x-${p.id}`}
            x={xAt(i)}
            y={H - 4}
            textAnchor="middle"
            fontSize="8"
            fill={C.textDim}
          >
            {fmtFechaCorta(p.fecha).slice(0, 5)}
          </text>
        );
      })}
    </svg>
  );
}

function ChipTendencia({ t }) {
  if (!t) return null;
  const col = t.dir === "up" ? C.amber : t.dir === "down" ? C.blue : C.textMid;
  const arrow = t.dir === "up" ? "↑" : t.dir === "down" ? "↓" : "→";
  return (
    <span style={{ color: col, fontWeight: 700, fontSize: 11 }}>
      {arrow} {t.texto}
    </span>
  );
}

function CardIndicador({
  titulo,
  valor,
  unidad,
  clasif,
  tendencia,
  children,
  nota,
}) {
  return (
    <div
      style={{
        padding: 12,
        borderRadius: 12,
        border: `1px solid ${C.border}`,
        background: C.bg,
        minWidth: 0,
      }}
    >
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", gap: 8, marginBottom: 2 }}>
        <div style={{ color: C.textDim, fontSize: 10, fontWeight: 800, letterSpacing: 0.8, textTransform: "uppercase" }}>
          {titulo}
        </div>
        {clasif && (
          <span style={{ color: tonoDe(clasif), fontSize: 10, fontWeight: 800 }}>{clasif.label}</span>
        )}
      </div>
      <div style={{ display: "flex", alignItems: "baseline", gap: 8, flexWrap: "wrap", marginBottom: 4 }}>
        <div style={{ color: C.text, fontWeight: 800, fontSize: 22, fontVariantNumeric: "tabular-nums", lineHeight: 1.1 }}>
          {valor}
          {unidad ? <span style={{ fontSize: 12, fontWeight: 700, color: C.textMid, marginLeft: 4 }}>{unidad}</span> : null}
        </div>
        <ChipTendencia t={tendencia} />
      </div>
      {children}
      {nota && (
        <div style={{ color: C.textMid, fontSize: 11, marginTop: 6, lineHeight: 1.4 }}>{nota}</div>
      )}
    </div>
  );
}

/**
 * Resumen visual de signos a lo largo de las consultas.
 * `puntos` ya vienen de puntosDesdeCitas (cronológico).
 */
export function EvolucionClinica({ puntos }) {
  const [selId, setSelId] = useState(null);
  const serie = puntos || [];
  const narracion = useMemo(() => narrarEvolucion(serie), [serie]);
  const sel = serie.find((p) => p.id === selId) || serie[serie.length - 1] || null;

  const lastPeso = ultimoConValor(serie, "peso");
  const lastTalla = ultimoConValor(serie, "talla") || ultimoConValor(serie, "tallaEfectiva");
  const lastIMC = ultimoConValor(serie, "imc");
  const lastTA = [...serie].reverse().find((p) => p.sis != null) || null;
  const lastFC = ultimoConValor(serie, "fc");
  const lastTemp = ultimoConValor(serie, "temp");
  const lastSat = ultimoConValor(serie, "sat");

  const hayPeso = serie.some((p) => Number.isFinite(p.peso));
  const hayTalla = serie.some((p) => Number.isFinite(p.talla) || Number.isFinite(p.tallaEfectiva));
  const hayIMC = serie.some((p) => Number.isFinite(p.imc));
  const hayTA = serie.some((p) => Number.isFinite(p.sis));
  const hayFC = serie.some((p) => Number.isFinite(p.fc));
  const hayTemp = serie.some((p) => Number.isFinite(p.temp));
  const haySat = serie.some((p) => Number.isFinite(p.sat));

  const sectionTitle = {
    color: C.textDim,
    fontSize: 10,
    fontWeight: 700,
    letterSpacing: 1.5,
    textTransform: "uppercase",
    marginBottom: 8,
  };

  if (!serie.length) {
    return (
      <div data-testid="evolucion-clinica">
        <Box style={{ padding: 14, marginBottom: 12 }}>
          <div style={sectionTitle}>📈 Evolución en el tiempo</div>
          <p style={{ margin: 0, color: C.textMid, fontSize: 12, lineHeight: 1.45 }}>{narracion}</p>
        </Box>
      </div>
    );
  }

  return (
    <div data-testid="evolucion-clinica">
    <Box style={{ padding: 14, marginBottom: 12 }}>
      <div style={sectionTitle}>📈 Evolución en el tiempo</div>
      <p
        style={{
          margin: "0 0 12px",
          padding: "10px 12px",
          borderRadius: 10,
          background: C.blueDim,
          color: C.blueDark,
          fontSize: 13,
          lineHeight: 1.5,
          fontWeight: 600,
        }}
      >
        {narracion}
      </p>
      <p style={{ margin: "0 0 12px", color: C.textMid, fontSize: 11, lineHeight: 1.4 }}>
        Cada punto es una consulta. Toca uno para ver la fecha exacta.
        {hayIMC && !serie.every((p) => p.talla != null) ? " El IMC usa la talla medida más reciente si esa visita no la anotó." : ""}
      </p>

      <div style={{ display: "grid", gap: 10 }}>
        {hayPeso && (
          <CardIndicador
            titulo="Peso"
            valor={fmtVal(lastPeso?.peso, 1)}
            unidad="kg"
            tendencia={tendenciaCampo(serie, "peso", { umbral: 0.5, decimales: 1, unidad: " kg" })}
            nota={sel && Number.isFinite(sel.peso) ? `${fmtFechaCorta(sel.fecha)} · ${fmtVal(sel.peso, 1)} kg` : null}
          >
            <LineaSvg
              serie={serie}
              keys={["peso"]}
              colors={["#7c3aed"]}
              selectedId={sel?.id}
              onSelect={setSelId}
              decimales={1}
            />
          </CardIndicador>
        )}

        {(hayTalla || hayIMC) && (
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: 10 }}>
            {hayTalla && (
              <CardIndicador
                titulo="Talla"
                valor={fmtVal(lastTalla?.talla ?? lastTalla?.tallaEfectiva, 1)}
                unidad="cm"
                tendencia={tendenciaCampo(serie, "talla", { umbral: 0.5, decimales: 1, unidad: " cm" })}
                nota="En adultos casi no cambia; sirve sobre todo para el IMC y para pediatría."
              >
                {serie.filter((p) => Number.isFinite(p.talla)).length >= 1 && (
                  <LineaSvg
                    serie={serie}
                    keys={["talla"]}
                    colors={["#0891b2"]}
                    selectedId={sel?.id}
                    onSelect={setSelId}
                    decimales={1}
                    height={96}
                  />
                )}
              </CardIndicador>
            )}
            {hayIMC && (
              <CardIndicador
                titulo="IMC"
                valor={fmtVal(lastIMC?.imc, 1)}
                clasif={clasificarIMC(lastIMC?.imc)}
                tendencia={tendenciaCampo(serie, "imc", { umbral: 0.3, decimales: 1 })}
                nota={sel && Number.isFinite(sel.imc) ? `${fmtFechaCorta(sel.fecha)} · IMC ${fmtVal(sel.imc, 1)}` : null}
              >
                <LineaSvg
                  serie={serie}
                  keys={["imc"]}
                  colors={["#1E3ABA"]}
                  selectedId={sel?.id}
                  onSelect={setSelId}
                  decimales={1}
                  height={96}
                />
              </CardIndicador>
            )}
          </div>
        )}

        {hayTA && (
          <CardIndicador
            titulo="Presión arterial"
            valor={lastTA?.taTexto || "—"}
            unidad="mmHg"
            clasif={clasificarTA(lastTA?.sis, lastTA?.dia)}
            nota={sel && sel.taTexto ? `${fmtFechaCorta(sel.fecha)} · ${sel.taTexto}` : "Rojo: sistólica · ámbar: diastólica"}
          >
            <div style={{ display: "flex", gap: 12, fontSize: 10, fontWeight: 700, color: C.textMid, marginBottom: 4 }}>
              <span><span style={{ color: "#ef4444" }}>●</span> Sistólica</span>
              <span><span style={{ color: "#f59e0b" }}>●</span> Diastólica</span>
            </div>
            <LineaSvg
              serie={serie}
              keys={["sis", "dia"]}
              colors={["#ef4444", "#f59e0b"]}
              selectedId={sel?.id}
              onSelect={setSelId}
              decimales={0}
            />
          </CardIndicador>
        )}

        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(150px, 1fr))", gap: 10 }}>
          {hayFC && (
            <CardIndicador
              titulo="Frecuencia"
              valor={fmtVal(lastFC?.fc, 0)}
              unidad="lpm"
              clasif={clasificarFC(lastFC?.fc)}
              tendencia={tendenciaCampo(serie, "fc", { umbral: 3, decimales: 0, unidad: " lpm" })}
            >
              <LineaSvg
                serie={serie}
                keys={["fc"]}
                colors={["#1E3ABA"]}
                selectedId={sel?.id}
                onSelect={setSelId}
                decimales={0}
                height={88}
              />
            </CardIndicador>
          )}
          {hayTemp && (
            <CardIndicador
              titulo="Temperatura"
              valor={fmtVal(lastTemp?.temp, 1)}
              unidad="°C"
              clasif={clasificarTemp(lastTemp?.temp)}
              tendencia={tendenciaCampo(serie, "temp", { umbral: 0.2, decimales: 1, unidad: " °C" })}
            >
              <LineaSvg
                serie={serie}
                keys={["temp"]}
                colors={["#f59e0b"]}
                selectedId={sel?.id}
                onSelect={setSelId}
                decimales={1}
                height={88}
              />
            </CardIndicador>
          )}
          {haySat && (
            <CardIndicador
              titulo="SpO₂"
              valor={fmtVal(lastSat?.sat, 0)}
              unidad="%"
              clasif={clasificarSat(lastSat?.sat)}
              tendencia={tendenciaCampo(serie, "sat", { umbral: 1, decimales: 0, unidad: "%" })}
            >
              <LineaSvg
                serie={serie}
                keys={["sat"]}
                colors={["#22C55E"]}
                selectedId={sel?.id}
                onSelect={setSelId}
                decimales={0}
                height={88}
              />
            </CardIndicador>
          )}
        </div>
      </div>
    </Box>
    </div>
  );
}
