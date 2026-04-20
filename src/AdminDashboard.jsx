import React, { useEffect, useMemo, useState } from "react";
import { supabase } from "./supabase";
import { idEmpleadoUsuarios } from "./utils/usuarioId";

const leerSesion = () => {
  try {
    return JSON.parse(sessionStorage.getItem("farmax_admin_user") || "{}");
  } catch {
    return {};
  }
};

const initialForm = {
  id: null,
  nombre: "",
  sku: "",
  categoria: "General",
  precio: "",
  stock: "",
  activo: true,
};

function asNumber(value, fallback = 0) {
  const n = Number(value);
  return Number.isFinite(n) ? n : fallback;
}

export default function AdminDashboard() {
  const [productos, setProductos] = useState([]);
  const [form, setForm] = useState(initialForm);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [okMsg, setOkMsg] = useState("");

  const isEdit = useMemo(() => !!form.id, [form.id]);

  const loadProductos = async () => {
    setLoading(true);
    setError("");
    const { data, error: qError } = await supabase
      .from("productos")
      .select("id,nombre,sku,categoria,precio,stock,activo")
      .order("id", { ascending: false })
      .limit(200);

    if (qError) {
      setError(`No se pudo cargar productos: ${qError.message}`);
      setProductos([]);
    } else {
      setProductos(data || []);
    }
    setLoading(false);
  };

  useEffect(() => {
    loadProductos();
  }, []);

  const onChange = (field, value) => {
    setForm((prev) => ({ ...prev, [field]: value }));
  };

  const resetForm = () => setForm(initialForm);

  const onSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setError("");
    setOkMsg("");

    const nombre = form.nombre.trim();
    const stockTarget = asNumber(form.stock, 0);
    const productoFields = {
      nombre,
      sku: form.sku.trim() || null,
      categoria: form.categoria.trim() || "General",
      precio: asNumber(form.precio, 0),
      activo: !!form.activo,
    };

    if (!nombre) {
      setError("El nombre es obligatorio.");
      setSaving(false);
      return;
    }

    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) {
      setError("Sesión expirada. Inicia sesión de nuevo.");
      setSaving(false);
      return;
    }

    let dbError = null;
    if (isEdit) {
      const { error: updError } = await supabase.rpc("admin_editar_producto", {
        p_session_token: tok,
        p_producto_id:   form.id,
        p_patch:         productoFields,
      });
      dbError = updError;
      if (!dbError) {
        const { error: adjErr } = await supabase.rpc("adjust_stock_secure", {
          p_session_token: tok,
          p_producto_id:   form.id,
          p_nuevo_stock:   stockTarget,
          p_motivo:        "Edición manual (Admin Dashboard)",
        });
        if (adjErr) dbError = adjErr;
      }
    } else {
      const { error: rpcErr } = await supabase.rpc("create_producto_secure", {
        p_session_token:   tok,
        p_producto_data:   productoFields,
        p_cantidad_inicial: stockTarget,
        p_numero_lote:     null,
        p_fecha_caducidad: null,
        p_costo_unitario:  null,
      });
      dbError = rpcErr;
    }

    if (dbError) {
      setError(`No se pudo guardar: ${dbError.message}`);
    } else {
      setOkMsg(isEdit ? "Producto actualizado." : "Producto creado.");
      resetForm();
      await loadProductos();
    }
    setSaving(false);
  };

  const onEdit = (p) => {
    setForm({
      id: p.id,
      nombre: p.nombre || "",
      sku: p.sku || "",
      categoria: p.categoria || "General",
      precio: String(p.precio ?? ""),
      stock: String(p.stock ?? ""),
      activo: p.activo !== false,
    });
  };

  const onDelete = async (id) => {
    if (!window.confirm("¿Eliminar este producto?")) return;
    setError("");
    setOkMsg("");
    const tok = sessionStorage.getItem("farmax_session_token");
    if (!tok) { setError("Sesión expirada."); return; }
    const { data: resp, error: delError } = await supabase.rpc("admin_eliminar_producto", {
      p_session_token: tok, p_producto_id: id,
    });
    if (delError || !resp?.success) {
      setError(`No se pudo eliminar: ${resp?.error || delError?.message}`);
      return;
    }
    setOkMsg("Producto eliminado.");
    await loadProductos();
  };

  return (
    <div style={{ maxWidth: 1100, margin: "0 auto", padding: 16, color: "#0f172a" }}>
      <h1 style={{ margin: "0 0 12px 0" }}>Admin Dashboard (Fallback)</h1>
      <p style={{ marginTop: 0, color: "#475569", fontSize: 13 }}>
        Panel de respaldo activo para asegurar disponibilidad de la ruta <code>/admin</code>.
      </p>

      {error && (
        <div style={{ background: "#fee2e2", color: "#b91c1c", padding: 10, borderRadius: 8, marginBottom: 12 }}>
          {error}
        </div>
      )}
      {okMsg && (
        <div style={{ background: "#dcfce7", color: "#166534", padding: 10, borderRadius: 8, marginBottom: 12 }}>
          {okMsg}
        </div>
      )}

      <form
        onSubmit={onSubmit}
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit,minmax(160px,1fr))",
          gap: 8,
          background: "#f8fafc",
          border: "1px solid #e2e8f0",
          borderRadius: 10,
          padding: 12,
          marginBottom: 14,
        }}
      >
        <input value={form.nombre} onChange={(e) => onChange("nombre", e.target.value)} placeholder="Nombre" required />
        <input value={form.sku} onChange={(e) => onChange("sku", e.target.value)} placeholder="SKU" />
        <input value={form.categoria} onChange={(e) => onChange("categoria", e.target.value)} placeholder="Categoría" />
        <input
          type="number"
          min="0"
          step="0.01"
          value={form.precio}
          onChange={(e) => onChange("precio", e.target.value)}
          placeholder="Precio"
        />
        <input type="number" min="0" value={form.stock} onChange={(e) => onChange("stock", e.target.value)} placeholder="Stock" />
        <label style={{ display: "flex", gap: 8, alignItems: "center", fontSize: 13 }}>
          <input type="checkbox" checked={form.activo} onChange={(e) => onChange("activo", e.target.checked)} />
          Activo
        </label>
        <div style={{ display: "flex", gap: 8 }}>
          <button type="submit" disabled={saving}>
            {saving ? "Guardando..." : isEdit ? "Actualizar producto" : "Agregar producto"}
          </button>
          {isEdit && (
            <button type="button" onClick={resetForm}>
              Cancelar edición
            </button>
          )}
        </div>
      </form>

      <div style={{ overflowX: "auto", border: "1px solid #e2e8f0", borderRadius: 10 }}>
        <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 13 }}>
          <thead style={{ background: "#f1f5f9" }}>
            <tr>
              <th style={{ textAlign: "left", padding: 8 }}>ID</th>
              <th style={{ textAlign: "left", padding: 8 }}>Nombre</th>
              <th style={{ textAlign: "left", padding: 8 }}>SKU</th>
              <th style={{ textAlign: "left", padding: 8 }}>Categoría</th>
              <th style={{ textAlign: "left", padding: 8 }}>Precio</th>
              <th style={{ textAlign: "left", padding: 8 }}>Stock</th>
              <th style={{ textAlign: "left", padding: 8 }}>Activo</th>
              <th style={{ textAlign: "left", padding: 8 }}>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={8} style={{ padding: 12 }}>
                  Cargando productos...
                </td>
              </tr>
            ) : !productos.length ? (
              <tr>
                <td colSpan={8} style={{ padding: 12 }}>
                  No hay productos.
                </td>
              </tr>
            ) : (
              productos.map((p) => (
                <tr key={p.id} style={{ borderTop: "1px solid #e2e8f0" }}>
                  <td style={{ padding: 8 }}>{p.id}</td>
                  <td style={{ padding: 8 }}>{p.nombre}</td>
                  <td style={{ padding: 8 }}>{p.sku || "—"}</td>
                  <td style={{ padding: 8 }}>{p.categoria || "—"}</td>
                  <td style={{ padding: 8 }}>${asNumber(p.precio).toFixed(2)}</td>
                  <td style={{ padding: 8 }}>{asNumber(p.stock)}</td>
                  <td style={{ padding: 8 }}>{p.activo === false ? "No" : "Sí"}</td>
                  <td style={{ padding: 8, display: "flex", gap: 8 }}>
                    <button onClick={() => onEdit(p)}>Editar</button>
                    <button onClick={() => onDelete(p.id)}>Eliminar</button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
