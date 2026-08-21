import { useEffect, useMemo, useRef, useState } from "react";
import { BookOpen, Search, ArrowLeft, ArrowUpRight, Hash } from "lucide-react";
import { C_LIGHT, BRAND, NAV_ITEMS } from "./constants";
import { puedeVerModulo } from "./utils/permissions";
import { useMediaQuery } from "./hooks/useMediaQuery";
import {
  GLOSARIO,
  buscarManual,
  glosarioPorId,
  temasParaUsuario,
  temasQueMencionan,
} from "./lib/manualContenido";

function labelModulo(id) {
  if (id === "ayuda") return "Manual";
  return NAV_ITEMS.find((n) => n.id === id)?.label || id;
}

function TextoConGlosario({ text, onTerm }) {
  const parts = String(text || "").split(/(\[\[[a-z0-9-]+\]\])/g);
  return (
    <>
      {parts.map((part, i) => {
        const m = part.match(/^\[\[([a-z0-9-]+)\]\]$/);
        if (!m) return <span key={i}>{part}</span>;
        const g = glosarioPorId(m[1]);
        if (!g) return <span key={i}>{part}</span>;
        return (
          <button
            key={i}
            type="button"
            onClick={() => onTerm(g.id)}
            title={g.def}
            style={{
              border: "none",
              background: "transparent",
              color: BRAND.primary,
              fontWeight: 800,
              cursor: "pointer",
              padding: 0,
              font: "inherit",
              textDecoration: "underline",
              textUnderlineOffset: 3,
            }}
          >
            {g.term}
          </button>
        );
      })}
    </>
  );
}

export default function ManualModule({ usuario, onNavigate }) {
  const C = C_LIGHT;
  const isMobile = useMediaQuery("(max-width: 768px)");
  const searchRef = useRef(null);
  const [q, setQ] = useState("");
  const [vista, setVista] = useState("temas");
  const [temaId, setTemaId] = useState(null);
  const [termId, setTermId] = useState(null);
  const [filtro, setFiltro] = useState("todos");

  const temas = useMemo(() => temasParaUsuario(usuario, puedeVerModulo), [usuario]);
  const busqueda = useMemo(() => buscarManual(q, temas, GLOSARIO), [q, temas]);
  const buscando = q.trim().length > 0;

  const modulos = useMemo(() => {
    const ids = [...new Set(temas.map((t) => t.moduloId))];
    return ids;
  }, [temas]);

  const temasFiltrados = buscando
    ? busqueda.temas
    : filtro === "todos"
      ? temas
      : temas.filter((t) => t.moduloId === filtro);

  const tema = temas.find((t) => t.id === temaId) || null;
  const termino = glosarioPorId(termId);
  const menciones = termino ? temasQueMencionan(termId, temas) : [];

  useEffect(() => {
    if (!temaId && !isMobile && temas[0]) setTemaId(temas[0].id);
  }, [temaId, isMobile, temas]);

  const abrirTermino = (id) => {
    setTermId(id);
    setVista("glosario");
    setTemaId(null);
  };

  const abrirTema = (id) => {
    setTemaId(id);
    setVista("temas");
    setTermId(null);
  };

  const irAlModulo = (t) => {
    if (!onNavigate || !t?.moduloId || t.moduloId === "ayuda") return;
    if (t.moduloId === "recibir" || t.invTab === "recibir") onNavigate("recibir");
    else if (t.moduloId === "inv" && t.invTab) onNavigate("inv", { tab: t.invTab });
    else onNavigate(t.moduloId);
  };

  const chip = (active) => ({
    border: `1px solid ${active ? BRAND.primary : C.border}`,
    background: active ? C.blueDim : C.card,
    color: active ? BRAND.primary : C.textMid,
    borderRadius: 999,
    padding: "6px 12px",
    fontSize: 12,
    fontWeight: 700,
    cursor: "pointer",
  });

  const mostrarDetalle = Boolean(tema) && vista === "temas" && !buscando;
  const mostrarTermino = Boolean(termino) && vista === "glosario";

  return (
    <div style={{ padding: isMobile ? "12px 16px 40px" : "18px 24px 48px", maxWidth: 980 }}>
      <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between", gap: 12, marginBottom: 14, flexWrap: "wrap" }}>
        <div>
          <h2 style={{ margin: 0, color: C.text, fontSize: 20, fontWeight: 800, display: "flex", alignItems: "center", gap: 8 }}>
            <BookOpen size={22} strokeWidth={2.2} /> Manual
          </h2>
          <p style={{ margin: "4px 0 0", color: C.textMid, fontSize: 13 }}>
            Dudas de tu perfil. Toca una palabra subrayada para el glosario.
          </p>
        </div>
        <div style={{ display: "flex", gap: 6 }}>
          <button type="button" onClick={() => { setVista("temas"); setTermId(null); }} style={chip(vista === "temas")}>Cómo se hace</button>
          <button type="button" onClick={() => { setVista("glosario"); setTemaId(null); }} style={chip(vista === "glosario")}>Glosario</button>
        </div>
      </div>

      <label htmlFor="manual-q" style={{ display: "block", color: C.textMid, fontSize: 11, fontWeight: 700, marginBottom: 6 }}>Buscar</label>
      <div style={{ position: "relative", marginBottom: 14 }}>
        <Search size={16} style={{ position: "absolute", left: 12, top: 13, color: C.textDim }} />
        <input
          id="manual-q"
          ref={searchRef}
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="caducidad, corte, receta, lote…"
          autoComplete="off"
          style={{
            width: "100%", boxSizing: "border-box", padding: "11px 14px 11px 36px",
            borderRadius: 10, border: `1px solid ${C.border}`, background: C.card,
            color: C.text, fontSize: 16, outline: "none",
          }}
        />
      </div>

      {vista === "temas" && !buscando && (
        <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginBottom: 14 }}>
          <button type="button" onClick={() => setFiltro("todos")} style={chip(filtro === "todos")}>Todos</button>
          {modulos.map((id) => (
            <button key={id} type="button" onClick={() => setFiltro(id)} style={chip(filtro === id)}>
              {labelModulo(id)}
            </button>
          ))}
        </div>
      )}

      {buscando && (
        <div style={{ display: "grid", gap: 16 }}>
          <section>
            <div style={{ color: C.textDim, fontSize: 11, fontWeight: 800, letterSpacing: 0.06, textTransform: "uppercase", marginBottom: 8 }}>
              Temas ({busqueda.temas.length})
            </div>
            {busqueda.temas.length === 0 && <div style={{ color: C.textMid, fontSize: 14 }}>Ningún tema con eso.</div>}
            {busqueda.temas.map((t) => (
              <button
                key={t.id}
                type="button"
                onClick={() => { setQ(""); abrirTema(t.id); }}
                style={{
                  display: "block", width: "100%", textAlign: "left", marginBottom: 8,
                  background: C.card, border: `1px solid ${C.border}`, borderRadius: 12, padding: "12px 14px", cursor: "pointer",
                }}
              >
                <div style={{ fontWeight: 800, color: C.text, fontSize: 14 }}>{t.titulo}</div>
                <div style={{ color: C.textMid, fontSize: 12, marginTop: 4 }}>{t.resumen}</div>
              </button>
            ))}
          </section>
          <section>
            <div style={{ color: C.textDim, fontSize: 11, fontWeight: 800, letterSpacing: 0.06, textTransform: "uppercase", marginBottom: 8 }}>
              Glosario ({busqueda.glosario.length})
            </div>
            {busqueda.glosario.length === 0 && <div style={{ color: C.textMid, fontSize: 14 }}>Ningún término con eso.</div>}
            {busqueda.glosario.map((g) => (
              <button
                key={g.id}
                type="button"
                onClick={() => { setQ(""); abrirTermino(g.id); }}
                style={{
                  display: "block", width: "100%", textAlign: "left", marginBottom: 8,
                  background: C.card, border: `1px solid ${C.border}`, borderRadius: 12, padding: "12px 14px", cursor: "pointer",
                }}
              >
                <div style={{ fontWeight: 800, color: BRAND.primary, fontSize: 14 }}>{g.term}</div>
                <div style={{ color: C.textMid, fontSize: 12, marginTop: 4 }}>{g.def}</div>
              </button>
            ))}
          </section>
        </div>
      )}

      {!buscando && vista === "glosario" && (
        <div style={{ display: "grid", gridTemplateColumns: isMobile || !termino ? "1fr" : "minmax(200px, 280px) 1fr", gap: 16 }}>
          {(!isMobile || !termino) && (
            <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
              {GLOSARIO.map((g) => (
                <button
                  key={g.id}
                  type="button"
                  onClick={() => setTermId(g.id)}
                  style={{
                    textAlign: "left", border: `1px solid ${termId === g.id ? BRAND.primary : C.border}`,
                    background: termId === g.id ? C.blueDim : C.card, borderRadius: 10, padding: "10px 12px", cursor: "pointer",
                  }}
                >
                  <div style={{ fontWeight: 800, color: C.text, fontSize: 13 }}>{g.term}</div>
                </button>
              ))}
            </div>
          )}
          {mostrarTermino && (
            <div style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 14, padding: isMobile ? 16 : 22 }}>
              {isMobile && (
                <button type="button" onClick={() => setTermId(null)} style={{ ...chip(false), marginBottom: 12, display: "inline-flex", alignItems: "center", gap: 6 }}>
                  <ArrowLeft size={14} /> Términos
                </button>
              )}
              <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 8 }}>
                <Hash size={16} color={BRAND.primary} />
                <h3 style={{ margin: 0, fontSize: 20, fontWeight: 800, color: C.text }}>{termino.term}</h3>
              </div>
              <p style={{ margin: "0 0 16px", color: C.text, fontSize: 15, lineHeight: 1.5 }}>{termino.def}</p>
              {termino.aliases?.length > 0 && (
                <div style={{ color: C.textMid, fontSize: 12, marginBottom: 16 }}>
                  También: {termino.aliases.join(" · ")}
                </div>
              )}
              <div style={{ color: C.textDim, fontSize: 11, fontWeight: 800, textTransform: "uppercase", letterSpacing: 0.06, marginBottom: 8 }}>Aparece en</div>
              {menciones.length === 0 && <div style={{ color: C.textMid, fontSize: 13 }}>En los temas de tu perfil no está enlazado aún; ya viste la definición.</div>}
              {menciones.map((t) => (
                <button key={t.id} type="button" onClick={() => abrirTema(t.id)} style={{
                  display: "block", width: "100%", textAlign: "left", marginBottom: 8,
                  background: C.cardDark, border: `1px solid ${C.border}`, borderRadius: 10, padding: "10px 12px", cursor: "pointer",
                }}>
                  <span style={{ fontWeight: 800, color: C.text, fontSize: 13 }}>{t.titulo}</span>
                </button>
              ))}
            </div>
          )}
        </div>
      )}

      {!buscando && vista === "temas" && (
        <div style={{ display: "grid", gridTemplateColumns: isMobile ? "1fr" : "minmax(220px, 300px) 1fr", gap: 16 }}>
          {(!isMobile || !tema) && (
            <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
              {temasFiltrados.map((t) => (
                <button
                  key={t.id}
                  type="button"
                  onClick={() => setTemaId(t.id)}
                  style={{
                    textAlign: "left",
                    border: `1px solid ${temaId === t.id ? BRAND.primary : C.border}`,
                    background: temaId === t.id ? C.blueDim : C.card,
                    borderRadius: 12, padding: "10px 12px", cursor: "pointer",
                  }}
                >
                  <div style={{ fontWeight: 800, color: C.text, fontSize: 13 }}>{t.titulo}</div>
                  <div style={{ color: C.textMid, fontSize: 11, marginTop: 3 }}>{labelModulo(t.moduloId)}</div>
                </button>
              ))}
            </div>
          )}

          {mostrarDetalle && (
            <article style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 14, padding: isMobile ? 16 : 22 }}>
              {isMobile && (
                <button type="button" onClick={() => setTemaId(null)} style={{ ...chip(false), marginBottom: 12, display: "inline-flex", alignItems: "center", gap: 6 }}>
                  <ArrowLeft size={14} /> Temas
                </button>
              )}
              <h3 style={{ margin: "0 0 6px", fontSize: 20, fontWeight: 800, color: C.text }}>{tema.titulo}</h3>
              <p style={{ margin: "0 0 16px", color: C.textMid, fontSize: 14, lineHeight: 1.45 }}>
                <TextoConGlosario text={tema.resumen} onTerm={abrirTermino} />
              </p>
              <ol style={{ margin: "0 0 18px", paddingLeft: 18 }}>
                {tema.pasos.map((p, i) => (
                  <li key={i} style={{ margin: "8px 0", color: C.text, fontSize: 14, lineHeight: 1.45 }}>
                    <TextoConGlosario text={p} onTerm={abrirTermino} />
                  </li>
                ))}
              </ol>
              {tema.dudas?.length > 0 && (
                <div>
                  <div style={{ color: C.textDim, fontSize: 11, fontWeight: 800, textTransform: "uppercase", letterSpacing: 0.06, marginBottom: 8 }}>Si te atoras</div>
                  {tema.dudas.map((d) => (
                    <div key={d.q} style={{ background: C.cardDark, borderRadius: 10, padding: "10px 12px", marginBottom: 8 }}>
                      <div style={{ fontWeight: 800, fontSize: 13, color: C.text }}>{d.q}</div>
                      <div style={{ fontSize: 13, color: C.textMid, marginTop: 4, lineHeight: 1.45 }}>
                        <TextoConGlosario text={d.a} onTerm={abrirTermino} />
                      </div>
                    </div>
                  ))}
                </div>
              )}
              {tema.moduloId !== "ayuda" && (
                <button
                  type="button"
                  onClick={() => irAlModulo(tema)}
                  style={{
                    marginTop: 16, display: "inline-flex", alignItems: "center", gap: 8,
                    padding: "10px 16px", borderRadius: 10, border: "none",
                    background: BRAND.gradient, color: "#fff", fontWeight: 800, fontSize: 13, cursor: "pointer",
                  }}
                >
                  Abrir {labelModulo(tema.moduloId)} <ArrowUpRight size={16} />
                </button>
              )}
            </article>
          )}
        </div>
      )}
    </div>
  );
}
