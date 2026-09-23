import { useCallback, useEffect, useState } from "react";
import { supabase } from "../../supabase";
import { C_LIGHT, BRAND } from "../../constants";
import { Btn, showToast } from "../../ui";
import { getSessionToken } from "../../utils";

const C = C_LIGHT;

function textoEstado(estado) {
  if (estado === "aprobada") return "Aprobadas";
  if (estado === "rechazada") return "Rechazadas";
  return "Pendientes";
}

export default function ResenasModeracion() {
  const [estado, setEstado] = useState("pendiente");
  const [filas, setFilas] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [ocupado, setOcupado] = useState(null);

  const cargar = useCallback(async (filtro) => {
    setCargando(true);
    const tok = getSessionToken();
    const { data, error } = await supabase.rpc("fn_listar_resenas_moderacion", {
      p_session_token: tok,
      p_estado: filtro,
    });
    if (error) {
      showToast(error.message || "No se pudieron cargar las reseñas", "error");
      setFilas([]);
    } else {
      setFilas(Array.isArray(data) ? data : []);
    }
    setCargando(false);
  }, []);

  useEffect(() => { cargar(estado); }, [cargar, estado]);

  const moderar = async (id, siguiente) => {
    setOcupado(id);
    const tok = getSessionToken();
    const { data, error } = await supabase.rpc("fn_moderar_resena", {
      p_session_token: tok,
      p_resena_id: id,
      p_estado: siguiente,
    });
    setOcupado(null);
    if (error || !data?.ok) {
      showToast(error?.message || "No se pudo guardar", "error");
      return;
    }
    setFilas((prev) => prev.filter((r) => r.id !== id));
  };

  return (
    <div style={{ padding: 24, maxWidth: 860 }}>
      <h1 style={{ fontSize: 22, margin: "0 0 6px", color: C.text }}>Reseñas de la tienda</h1>
      <p style={{ margin: "0 0 16px", color: C.textMid, fontSize: 14, lineHeight: 1.5 }}>
        Nada se publica hasta que la apruebes. Los medicamentos no pueden recibir reseñas.
      </p>
      <div style={{ display: "flex", gap: 8, marginBottom: 16 }}>
        {["pendiente", "aprobada", "rechazada"].map((id) => (
          <Btn key={id} sm col={estado === id ? BRAND.primary : C.textMid} ol={estado !== id} onClick={() => setEstado(id)}>
            {textoEstado(id)}
          </Btn>
        ))}
      </div>
      {cargando ? <p style={{ color: C.textMid }}>Cargando...</p> : null}
      {!cargando && !filas.length ? (
        <p style={{ color: C.textMid }}>No hay reseñas {textoEstado(estado).toLowerCase()}.</p>
      ) : null}
      {filas.map((r) => (
        <article key={r.id} style={{ background: C.card, border: `1px solid ${C.border}`, borderRadius: 12, padding: 16, marginBottom: 12 }}>
          <div style={{ display: "flex", justifyContent: "space-between", gap: 12, flexWrap: "wrap" }}>
            <div>
              <div style={{ fontWeight: 800, color: C.text }}>{r.nombre || "Producto"}</div>
              <div style={{ fontSize: 12, color: C.textMid, marginTop: 2 }}>
                {[r.marca, r.categoria].filter(Boolean).join(" · ")} · Pedido #{r.pedido_id} · {r.estrellas} de 5
              </div>
            </div>
            {estado === "pendiente" ? (
              <div style={{ display: "flex", gap: 8 }}>
                <Btn sm col={BRAND.primary} dis={ocupado === r.id} onClick={() => moderar(r.id, "aprobada")}>Aprobar</Btn>
                <Btn sm ol col={C.red} dis={ocupado === r.id} onClick={() => moderar(r.id, "rechazada")}>Rechazar</Btn>
              </div>
            ) : null}
          </div>
          {r.comentario ? (
            <p style={{ margin: "10px 0 0", color: C.text, fontSize: 14, lineHeight: 1.5 }}>{r.comentario}</p>
          ) : (
            <p style={{ margin: "10px 0 0", color: C.textDim, fontSize: 13 }}>Sin comentario.</p>
          )}
        </article>
      ))}
    </div>
  );
}
