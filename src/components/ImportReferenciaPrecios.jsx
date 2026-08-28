import { useState } from "react";
import { C_LIGHT } from "../constants";
import { supabase } from "../supabase";
import { showToast } from "../ui";
import {
  FUENTES_IMPORT,
  parseCsvText,
  parseExprezoRows,
  parseGenericoRows,
  matchImportRows,
  persistImportReferencia,
} from "../lib/importReferenciaPrecio";

const BRAND = { gradient: "linear-gradient(135deg,#0D1B2A,#1E3ABA)" };

export default function ImportReferenciaPrecios({ productos, onImported }) {
  const C = C_LIGHT;
  const [open, setOpen] = useState(false);
  const [fuente, setFuente] = useState("exprezo");
  const [precioCol, setPrecioCol] = useState("mayoreo");
  const [fecha, setFecha] = useState(() => new Date().toISOString().slice(0, 10));
  const [fileName, setFileName] = useState("");
  const [preview, setPreview] = useState(null);
  const [saving, setSaving] = useState(false);

  const fuenteMeta = FUENTES_IMPORT.find((f) => f.id === fuente) || FUENTES_IMPORT[0];

  const handleFile = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setFileName(file.name);
    const reader = new FileReader();
    reader.onload = () => {
      try {
        const { headers, rows } = parseCsvText(String(reader.result || ""));
        let parsed;
        if (fuenteMeta.adapter === "exprezo") {
          parsed = parseExprezoRows(rows, precioCol);
        } else {
          parsed = parseGenericoRows(rows, headers);
        }
        const { matched, unmatched } = matchImportRows(parsed, productos);
        setPreview({ matched, unmatched, total: parsed.length });
      } catch (err) {
        showToast(err.message || "Error leyendo CSV", "error");
        setPreview(null);
      }
    };
    reader.readAsText(file, "UTF-8");
    e.target.value = "";
  };

  const confirmar = async () => {
    if (!preview?.matched?.length) return;
    setSaving(true);
    try {
      const { count } = await persistImportReferencia(supabase, {
        fuente,
        tipo: fuenteMeta.tipo,
        fecha,
        archivo: fileName,
        matched: preview.matched,
      });
      showToast(`✅ ${count} referencias importadas (${fuenteMeta.label})`, "success");
      setPreview(null);
      setOpen(false);
      onImported?.();
    } catch (err) {
      showToast("Error al importar: " + (err.message || err), "error");
    }
    setSaving(false);
  };

  const inp = {
    padding: "7px 10px",
    borderRadius: 8,
    border: `1px solid ${C.border}`,
    fontSize: 12,
    background: C.card,
    color: C.text,
  };

  if (!open) {
    return (
      <button
        type="button"
        onClick={() => setOpen(true)}
        style={{
          padding: "8px 16px", borderRadius: 8, border: "none",
          background: BRAND.gradient, color: "#fff", fontWeight: 700, fontSize: 12, cursor: "pointer",
        }}
      >
        📥 Importar lista CSV
      </button>
    );
  }

  return (
    <div style={{
      marginBottom: 20, padding: 16, borderRadius: 12,
      border: `1px solid ${C.border}`, background: C.card,
    }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
        <strong style={{ color: C.text, fontSize: 14 }}>Importar referencias</strong>
        <button type="button" onClick={() => { setOpen(false); setPreview(null); }}
          style={{ border: "none", background: "transparent", cursor: "pointer", color: C.textMid, fontWeight: 700 }}>
          ✕
        </button>
      </div>

      <div style={{ display: "flex", gap: 10, flexWrap: "wrap", marginBottom: 12 }}>
        <label style={{ fontSize: 11, color: C.textMid }}>
          Fuente
          <select value={fuente} onChange={(e) => { setFuente(e.target.value); setPreview(null); }} style={{ ...inp, display: "block", marginTop: 4 }}>
            {FUENTES_IMPORT.map((f) => (
              <option key={f.id} value={f.id}>{f.label}</option>
            ))}
          </select>
        </label>
        {fuente === "exprezo" && (
          <label style={{ fontSize: 11, color: C.textMid }}>
            Precio Exprezo
            <select value={precioCol} onChange={(e) => setPrecioCol(e.target.value)} style={{ ...inp, display: "block", marginTop: 4 }}>
              <option value="mayoreo">Mayoreo</option>
              <option value="unidad">Por unidad</option>
            </select>
          </label>
        )}
        <label style={{ fontSize: 11, color: C.textMid }}>
          Fecha lista
          <input type="date" value={fecha} onChange={(e) => setFecha(e.target.value)} style={{ ...inp, display: "block", marginTop: 4 }} />
        </label>
        <label style={{ fontSize: 11, color: C.textMid }}>
          Archivo CSV
          <input type="file" accept=".csv,text/csv" onChange={handleFile}
            style={{ display: "block", marginTop: 4, fontSize: 11 }} />
        </label>
      </div>

      {preview && (
        <>
          <p style={{ fontSize: 12, color: C.textMid, margin: "0 0 10px" }}>
            Match: <strong style={{ color: C.green }}>{preview.matched.length}</strong> / {preview.total}
            {preview.unmatched.length > 0 && (
              <> · Sin match: <strong>{preview.unmatched.length}</strong></>
            )}
          </p>
          <div style={{ maxHeight: 200, overflow: "auto", border: `1px solid ${C.border}`, borderRadius: 8, marginBottom: 12 }}>
            <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 11 }}>
              <thead>
                <tr style={{ background: C.cardDark }}>
                  {["Conf.", "SKU", "Catálogo", "Precio ref."].map((h) => (
                    <th key={h} style={{ padding: "6px 8px", textAlign: "left", color: C.textMid }}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {preview.matched.slice(0, 40).map((m, i) => (
                  <tr key={i} style={{ background: i % 2 ? "#f8fafc" : "transparent" }}>
                    <td style={{ padding: "6px 8px" }}>{m.confianza}%</td>
                    <td style={{ padding: "6px 8px", fontFamily: "monospace", fontSize: 10 }}>{m.sku || "—"}</td>
                    <td style={{ padding: "6px 8px", maxWidth: 220 }}>{m.nombre_catalogo}</td>
                    <td style={{ padding: "6px 8px" }}>${m.precio.toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          {preview.matched.length > 40 && (
            <p style={{ fontSize: 10, color: C.textDim, marginTop: -8 }}>Mostrando 40 de {preview.matched.length}</p>
          )}
          <button type="button" disabled={saving} onClick={confirmar}
            style={{
              padding: "9px 18px", borderRadius: 8, border: "none",
              background: BRAND.gradient, color: "#fff", fontWeight: 700, fontSize: 12,
              cursor: saving ? "wait" : "pointer", opacity: saving ? 0.7 : 1,
            }}>
            {saving ? "Importando…" : `Confirmar ${preview.matched.length} referencias`}
          </button>
        </>
      )}

      <p style={{ fontSize: 10, color: C.textDim, marginTop: 12, marginBottom: 0 }}>
        Del Ahorro / Marzam / Nadro / Levic: CSV con columnas <code>sku</code> + <code>precio</code> (o nombre + precio).
      </p>
    </div>
  );
}
