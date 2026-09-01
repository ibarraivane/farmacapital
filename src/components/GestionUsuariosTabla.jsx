import { C_LIGHT } from "../constants";
import { Box, Tag, Btn, Modal } from "../ui";

export function etiquetaAcceso(u) {
  const partes = [u?.email, u?.telefono].map((x) => String(x || "").trim()).filter(Boolean);
  return partes.length ? partes.join(" · ") : "—";
}

function rolColor(r, C) {
  return r === "admin" ? C.purple : r === "vendedor" ? C.blue : C.green;
}

const actionBtnBase = {
  minHeight: 32,
  borderRadius: 8,
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  gap: 6,
  cursor: "pointer",
  padding: "5px 10px",
  marginLeft: 0,
  fontSize: 11,
  fontWeight: 700,
  fontFamily: "var(--fc-body)",
  whiteSpace: "nowrap",
  flex: "0 0 auto",
};

function campoDetalle(label, value, C) {
  return (
    <div>
      <div style={{ color: C.textDim, fontSize: 10, fontWeight: 700, letterSpacing: 1.2, textTransform: "uppercase", marginBottom: 4 }}>{label}</div>
      {typeof value === "string" || typeof value === "number"
        ? <div style={{ color: C.text, fontSize: 13, lineHeight: 1.45, whiteSpace: "pre-wrap" }}>{value}</div>
        : value}
    </div>
  );
}

export default function GestionUsuariosTabla({
  usuarios,
  detalleUsuario,
  onCerrarDetalle,
  onVerDetalle,
  onEditar,
  onModulos,
  onToggle,
  onClave,
  onBorrar,
}) {
  const C = C_LIGHT;

  return (
    <>
      <Modal open={!!detalleUsuario} onClose={onCerrarDetalle} title={detalleUsuario ? `Detalle · ${detalleUsuario.nombre}` : "Detalle"}>
        {detalleUsuario && (
          <>
            <div style={{ display: "grid", gap: 14, marginBottom: 18 }}>
              {campoDetalle("Acceso", etiquetaAcceso(detalleUsuario), C)}
              {campoDetalle("Perfil", <Tag col={rolColor(detalleUsuario.rol, C)} sm>{detalleUsuario.rol}</Tag>, C)}
              {campoDetalle("Estado", <Tag col={detalleUsuario.activo ? C.green : C.red} sm>{detalleUsuario.activo ? "Activo" : "Inactivo"}</Tag>, C)}
              {campoDetalle("Notas", detalleUsuario.notas?.trim() || "Sin notas.", C)}
            </div>
            <div style={{ display: "flex", gap: 8, justifyContent: "flex-end", flexWrap: "wrap" }}>
              <Btn onClick={onCerrarDetalle} ol col={C.textMid}>Cerrar</Btn>
              <Btn col={C.amber} onClick={() => { const u = detalleUsuario; onCerrarDetalle(); onEditar(u); }}>Editar</Btn>
            </div>
          </>
        )}
      </Modal>

      <Box>
        <div style={{ overflowX: "auto" }}>
          <table className="fc-tabla-cards" style={{ width: "100%", minWidth: 760, borderCollapse: "collapse" }}>
            <thead>
              <tr>
                {["Nombre", "Acceso", "Perfil", "Notas", "Estado", "Acciones"].map((h) => (
                  <th key={h} style={{ padding: "8px 14px", color: C.textDim, fontSize: 9, textAlign: "left", letterSpacing: 1.5, textTransform: "uppercase", borderBottom: `1px solid ${C.border}` }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {usuarios.map((u) => (
                <tr key={u.id}>
                  <td data-label="Nombre" data-primary style={{ padding: "10px 14px", color: C.text, fontWeight: 700, fontSize: 13 }}>{u.nombre}</td>
                  <td data-label="Acceso" style={{ padding: "10px 14px", color: C.textMid, fontSize: 12 }}>{etiquetaAcceso(u)}</td>
                  <td data-label="Perfil" style={{ padding: "10px 14px" }}><Tag col={rolColor(u.rol, C)} sm>{u.rol}</Tag></td>
                  <td data-label="Notas" style={{ padding: "10px 14px", whiteSpace: "nowrap", width: 1 }}>
                    {String(u.notas || "").trim() ? (
                      <button
                        type="button"
                        onClick={() => onVerDetalle(u)}
                        title="Ver notas y detalle"
                        aria-label={`Ver detalle de ${u.nombre}`}
                        style={{ ...actionBtnBase, border: `1px solid ${C.blue}30`, background: C.blueDim, color: C.blue }}
                      >Detalle</button>
                    ) : (
                      <span style={{ color: C.textDim, fontSize: 12 }}>—</span>
                    )}
                  </td>
                  <td data-label="Estado" style={{ padding: "10px 14px" }}><Tag col={u.activo ? C.green : C.red} sm>{u.activo ? "Activo" : "Inactivo"}</Tag></td>
                  <td data-label="Acciones" data-actions style={{ padding: "10px 14px", whiteSpace: "nowrap", width: 1, verticalAlign: "middle" }}>
                    <div style={{ display: "inline-flex", alignItems: "center", gap: 6, flexWrap: "nowrap" }}>
                      <button
                        type="button"
                        onClick={() => onEditar(u)}
                        title="Editar usuario"
                        aria-label="Editar usuario"
                        style={{ ...actionBtnBase, border: `1px solid ${C.amber}30`, background: C.amberDim, color: C.amber }}
                      >Editar</button>
                      {u.rol !== "admin" && (
                        <button
                          type="button"
                          onClick={() => onModulos(u)}
                          title="Módulos y permisos"
                          aria-label="Módulos y permisos"
                          style={{ ...actionBtnBase, border: `1px solid ${C.purple}40`, background: C.purpleDim, color: C.purple }}
                        >Módulos</button>
                      )}
                      <button
                        type="button"
                        onClick={() => onToggle(u.id, u.activo)}
                        title={u.activo ? "Desactivar usuario" : "Activar usuario"}
                        aria-label={u.activo ? "Desactivar usuario" : "Activar usuario"}
                        style={{ ...actionBtnBase, border: `1px solid ${u.activo ? C.red : C.green}`, background: "transparent", color: u.activo ? C.red : C.green }}
                      >{u.activo ? "Desactivar" : "Activar"}</button>
                      <button
                        type="button"
                        onClick={() => onClave(u)}
                        title="Resetear contraseña"
                        aria-label="Resetear contraseña"
                        style={{ ...actionBtnBase, border: `1px solid ${C.blue}`, background: C.blueDim, color: C.blue }}
                      >Clave</button>
                      <button
                        type="button"
                        onClick={() => onBorrar(u.id, u.nombre)}
                        title="Eliminar usuario"
                        aria-label="Eliminar usuario"
                        style={{ ...actionBtnBase, border: `1px solid ${C.red}30`, background: C.redDim, color: C.red }}
                      >Borrar</button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Box>
    </>
  );
}
