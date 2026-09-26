import { createContext, useContext, useEffect, useState } from "react";
import { Star } from "lucide-react";
import { supabase } from "../../supabase";
import { getClienteToken } from "../../utils";
import { productoAceptaResena, resumenVisible, textoPromedio } from "../../lib/resenasProducto";

export const ResenasResumenCtx = createContext({});

const FIELD = {
  background: "#ffffff",
  color: "#0f172a",
  WebkitTextFillColor: "#0f172a",
  caretColor: "#0f172a",
  colorScheme: "light",
  border: "1px solid #dce2ea",
  borderRadius: 10,
  padding: "11px 14px",
  fontSize: 16,
  width: "100%",
  boxSizing: "border-box",
  fontFamily: "inherit",
};

function mensajeError(code) {
  if (code === "ya_enviada") return "Ya enviaste tu reseña de este producto.";
  if (code === "pedido_no_entregado") return "La reseña se pide cuando el pedido ya se entregó.";
  if (code === "producto_sin_resena") return "Este producto no lleva reseñas.";
  if (code === "comentario_largo") return "El comentario puede tener hasta 800 caracteres.";
  if (code === "estrellas_invalidas") return "Elige de 1 a 5 estrellas.";
  if (code === "no_autorizado") return "Este enlace ya no sirve. Entra a tu cuenta si el pedido es tuyo.";
  return "No se pudo guardar la reseña.";
}

export function EstrellasResena({ resumen, etiqueta }) {
  if (!resumen) return null;
  const label = etiqueta || textoPromedio(resumen);
  const promedio = Number(resumen.promedio) || 0;
  return (
    <span
      role="img"
      aria-label={label}
      title={label}
      className="fc-stars"
      style={{ display: "inline-flex", alignItems: "center", gap: 2, color: "#7A4A1E" }}
    >
      {[1, 2, 3, 4, 5].map((i) => {
        const pct = Math.max(0, Math.min(1, promedio - (i - 1))) * 100;
        return (
          <span key={i} aria-hidden="true" style={{ position: "relative", width: 14, height: 14, display: "inline-block", flex: "none" }}>
            <Star size={14} color="#C4B5A4" />
            <span style={{ position: "absolute", left: 0, top: 0, width: `${pct}%`, overflow: "hidden", lineHeight: 0 }}>
              <Star size={14} color="#7A4A1E" fill="#7A4A1E" />
            </span>
          </span>
        );
      })}
      <span style={{ marginLeft: 4, fontSize: 12, fontWeight: 700 }}>{resumen.promedio}</span>
    </span>
  );
}

export function EstrellasDeProducto({ prod }) {
  const map = useContext(ResenasResumenCtx);
  const fila = prod?.id != null ? (map?.[prod.id] || map?.[String(prod.id)]) : null;
  const resumen = resumenVisible(prod, fila);
  if (!resumen) return null;
  return (
    <div style={{ margin: "4px 0 6px" }}>
      <EstrellasResena resumen={resumen} />
    </div>
  );
}

export function ListaResenasPublicas({ prod }) {
  const [filas, setFilas] = useState([]);
  const acepta = productoAceptaResena(prod);

  useEffect(() => {
    if (!acepta || !prod?.id) {
      setFilas([]);
      return undefined;
    }
    let cancel = false;
    supabase
      .from("resenas")
      .select("id,estrellas,comentario,created_at")
      .eq("producto_id", prod.id)
      .eq("estado", "aprobada")
      .order("created_at", { ascending: false })
      .limit(20)
      .then(({ data, error }) => {
        if (cancel || error) return;
        setFilas(Array.isArray(data) ? data : []);
      });
    return () => { cancel = true; };
  }, [acepta, prod?.id]);

  if (!acepta || !filas.length) return null;
  return (
    <section aria-label="Reseñas" style={{ marginTop: 18 }}>
      <h2 style={{ fontSize: 18, margin: "0 0 10px" }}>Reseñas</h2>
      {filas.map((r) => (
        <article key={r.id} style={{ padding: "10px 0", borderTop: "1px solid #dce2ea" }}>
          <EstrellasResena
            resumen={{ promedio: Number(r.estrellas), total: 1 }}
            etiqueta={`${Number(r.estrellas)} de 5`}
          />
          {r.comentario ? (
            <p style={{ margin: "6px 0 0", fontSize: 14, lineHeight: 1.5, color: "#3A4B63" }}>{r.comentario}</p>
          ) : null}
        </article>
      ))}
    </section>
  );
}

function SelectorEstrellas({ value, onChange, nombre }) {
  return (
    <div role="radiogroup" aria-label={`Calificación de ${nombre || "producto"}`} style={{ display: "flex", gap: 4 }}>
      {[1, 2, 3, 4, 5].map((n) => (
        <button
          key={n}
          type="button"
          role="radio"
          aria-checked={value === n}
          aria-label={`${n} de 5`}
          onClick={() => onChange(n)}
          style={{
            border: "1px solid #dce2ea",
            background: value >= n ? "#F4ECE2" : "#ffffff",
            borderRadius: 8,
            minWidth: 40,
            minHeight: 40,
            cursor: "pointer",
            color: "#7A4A1E",
          }}
        >
          <Star size={16} fill={value >= n ? "#7A4A1E" : "none"} color="#7A4A1E" aria-hidden />
        </button>
      ))}
    </div>
  );
}

function FormularioUna({ nombre, pedidoId, productoId, token, yaEnviada, onEnviada }) {
  const [estrellas, setEstrellas] = useState(0);
  const [comentario, setComentario] = useState("");
  const [estado, setEstado] = useState(yaEnviada ? "ya" : "idle");
  const [error, setError] = useState("");

  if (estado === "ya" || yaEnviada) {
    return <p style={{ margin: "8px 0 0", fontSize: 13, color: "#536176" }}>Ya enviaste tu reseña. La farmacia la revisa antes de publicarla.</p>;
  }

  const enviar = async () => {
    if (estrellas < 1) {
      setError("Elige de 1 a 5 estrellas.");
      return;
    }
    setEstado("guardando");
    setError("");
    const { data, error: rpcError } = await supabase.rpc("fn_crear_resena", {
      p_producto_id: Number(productoId),
      p_pedido_id: Number(pedidoId),
      p_estrellas: estrellas,
      p_comentario: comentario,
      p_session_token: token ? null : getClienteToken(),
      p_token_resena: token || null,
    });
    if (rpcError || !data?.ok) {
      const code = data?.error || "";
      if (code === "ya_enviada") {
        setEstado("ya");
        onEnviada?.();
        return;
      }
      setEstado("idle");
      setError(mensajeError(code || rpcError?.message));
      return;
    }
    setEstado("ya");
    onEnviada?.();
  };

  return (
    <div style={{ marginTop: 8 }}>
      <SelectorEstrellas value={estrellas} onChange={setEstrellas} nombre={nombre} />
      <textarea
        className="farmacapital-field-input"
        value={comentario}
        onChange={(e) => setComentario(e.target.value)}
        maxLength={800}
        rows={3}
        placeholder="Cuéntanos cómo te fue (opcional)"
        aria-label={`Comentario sobre ${nombre || "el producto"}`}
        style={{ ...FIELD, marginTop: 8, resize: "vertical" }}
      />
      {error ? <p style={{ color: "#B42318", fontSize: 13, margin: "6px 0 0" }}>{error}</p> : null}
      <button
        type="button"
        onClick={enviar}
        disabled={estado === "guardando"}
        style={{
          marginTop: 8,
          background: "#001534",
          color: "#ffffff",
          border: 0,
          borderRadius: 8,
          minHeight: 40,
          padding: "8px 14px",
          fontWeight: 700,
          cursor: "pointer",
        }}
      >
        {estado === "guardando" ? "Enviando..." : "Enviar reseña"}
      </button>
    </div>
  );
}

export function BloqueResenaPedido({ pedido, productos = [], enviadas = [] }) {
  if (String(pedido?.estado) !== "completado") return null;
  const ya = new Set(
    (enviadas || [])
      .filter((r) => String(r.pedido_id) === String(pedido.id))
      .map((r) => String(r.producto_id))
  );
  const lineas = (pedido.pedido_items || []).map((item) => {
    const id = item.producto_id || item.productos?.id;
    const cat = (productos || []).find((p) => String(p.id) === String(id));
    const prod = cat || { ...(item.productos || {}), id };
    if (!productoAceptaResena(prod)) return null;
    return { id, nombre: prod.nombre || item.productos?.nombre || "Producto", ya: ya.has(String(id)) };
  }).filter(Boolean);
  if (!lineas.length) return null;
  return (
    <div style={{ marginTop: 12 }}>
      <div style={{ fontSize: 12, fontWeight: 700, letterSpacing: 0.4, textTransform: "uppercase", color: "#536176" }}>
        Califica tu pedido
      </div>
      {lineas.map((linea) => (
        <div key={linea.id} style={{ marginTop: 10 }}>
          <div style={{ fontWeight: 700, fontSize: 14 }}>{linea.nombre}</div>
          <FormularioUna
            nombre={linea.nombre}
            pedidoId={pedido.id}
            productoId={linea.id}
            yaEnviada={linea.ya}
          />
        </div>
      ))}
    </div>
  );
}

export function FormularioResenaToken({ token }) {
  const [carga, setCarga] = useState("cargando");
  const [pedidoId, setPedidoId] = useState(null);
  const [items, setItems] = useState([]);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!token) return undefined;
    let cancel = false;
    supabase.rpc("fn_pedido_para_resena", { p_token: token }).then(({ data, error: rpcError }) => {
      if (cancel) return;
      if (rpcError || !data?.ok) {
        setError(mensajeError(data?.error || rpcError?.message));
        setCarga("error");
        return;
      }
      setPedidoId(data.pedido_id);
      setItems(Array.isArray(data.items) ? data.items : []);
      setCarga("listo");
    });
    return () => { cancel = true; };
  }, [token]);

  if (carga === "cargando") {
    return <p style={{ color: "#536176" }}>Cargando tu pedido...</p>;
  }
  if (carga === "error") {
    return <p style={{ color: "#B42318" }}>{error}</p>;
  }
  if (!items.length) {
    return <p>Este pedido no tiene productos que lleven reseña.</p>;
  }
  let destacado = "";
  try { destacado = new URLSearchParams(window.location.search).get("producto") || ""; } catch { destacado = ""; }
  const ordenados = [...items].sort((a, b) => {
    if (String(a.producto_id) === destacado) return -1;
    if (String(b.producto_id) === destacado) return 1;
    return 0;
  });
  return (
    <div>
      <h1 style={{ fontSize: 28, margin: "0 0 8px" }}>¿Cómo te fue?</h1>
      <p style={{ color: "#536176", marginTop: 0 }}>Tu reseña queda en revisión. No se publica sola.</p>
      {ordenados.map((item) => (
        <div key={item.producto_id} id={`resena-${item.producto_id}`} style={{ padding: "14px 0", borderTop: "1px solid #dce2ea" }}>
          <div style={{ fontWeight: 700 }}>{item.nombre}</div>
          <FormularioUna
            nombre={item.nombre}
            pedidoId={pedidoId}
            productoId={item.producto_id}
            token={token}
            yaEnviada={item.ya_enviada === true}
          />
        </div>
      ))}
    </div>
  );
}
