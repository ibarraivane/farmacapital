import { forwardRef, useEffect, useImperativeHandle, useRef, useState } from "react";
import ImageUploader from "./ImageUploader";
import { C_LIGHT, BRAND } from "../constants";
import { showToast } from "../ui";
import { gestionarFotoProducto, listarFotosEditor, mismaFoto } from "../lib/fotosProducto";
import { subirImagenStorage } from "../lib/subirImagenStorage";
import { invalidarImagenesProducto } from "../hooks/useProductoImagenes";
import { avisarCatalogoCambio } from "../utils/catalogoVivo";

function avisarFotos(productoId) {
  if (productoId == null) return;
  invalidarImagenesProducto(productoId);
  avisarCatalogoCambio({ origen: "fotos-producto", table: "producto_imagenes" });
}

/**
 * Foto principal + galería del producto.
 * Cada miniatura se puede quitar. «Subir varias fotos» agrega más de una.
 */
const FotosProductoEditor = forwardRef(function FotosProductoEditor({
  productoId,
  imagenUrl,
  onImagenUrl,
  filenamePrefix = "prod",
}, ref) {
  const C = C_LIGHT;
  const [filas, setFilas] = useState([]);
  const [pendientes, setPendientes] = useState([]);
  const [cargando, setCargando] = useState(Boolean(productoId));
  const [ocupado, setOcupado] = useState(false);
  const [progreso, setProgreso] = useState("");
  const multiRef = useRef(null);
  const imagenRef = useRef(imagenUrl || "");
  imagenRef.current = imagenUrl || "";

  useEffect(() => {
    if (!productoId) {
      setFilas([]);
      setCargando(false);
      return undefined;
    }
    let vivo = true;
    setCargando(true);
    gestionarFotoProducto({ action: "listar", productoId }).then((res) => {
      if (!vivo) return;
      setCargando(false);
      if (!res.ok) {
        showToast(res.message || "No se pudieron cargar las fotos", "error");
        return;
      }
      setFilas(res.imagenes || []);
    });
    return () => { vivo = false; };
  }, [productoId]);

  const fotos = listarFotosEditor({ imagenUrl, filas, locales: pendientes });

  const aplicarRespuesta = (res) => {
    if (!res?.ok) {
      showToast(res?.message || "No se pudieron guardar las fotos", "error");
      return false;
    }
    setFilas(res.imagenes || []);
    onImagenUrl?.(res.imagen_url || "");
    avisarFotos(productoId);
    return true;
  };

  const quitar = async (url, { confirmar = true } = {}) => {
    if (!url || ocupado) return;
    if (confirmar && !window.confirm("¿Quitar esta foto? Deja de verse en la tienda.")) return;
    if (!productoId) {
      setPendientes((prev) => prev.filter((u) => !mismaFoto(u, url)));
      if (mismaFoto(imagenRef.current, url)) {
        const otra = fotos.find((f) => !mismaFoto(f.url, url));
        onImagenUrl?.(otra?.url || "");
      }
      showToast("Foto quitada", "info");
      return;
    }
    setOcupado(true);
    const res = await gestionarFotoProducto({ action: "quitar", productoId, url });
    setOcupado(false);
    if (aplicarRespuesta(res)) showToast("Foto quitada", "info");
  };

  const guardarPrincipalSubida = async (url) => {
    const previa = imagenRef.current;
    if (!productoId) {
      onImagenUrl?.(url);
      imagenRef.current = url;
      return;
    }
    if (!url || mismaFoto(url, previa)) return;
    onImagenUrl?.(url);
    imagenRef.current = url;
    setOcupado(true);
    const res = await gestionarFotoProducto({ action: "principal", productoId, url, principal: true });
    setOcupado(false);
    if (!aplicarRespuesta(res)) {
      onImagenUrl?.(previa);
      imagenRef.current = previa;
    }
  };

  const hacerPrincipal = async (url) => {
    if (!url || ocupado || mismaFoto(url, imagenRef.current)) return;
    if (!productoId) {
      onImagenUrl?.(url);
      return;
    }
    setOcupado(true);
    const res = await gestionarFotoProducto({ action: "principal", productoId, url, principal: true });
    setOcupado(false);
    if (aplicarRespuesta(res)) showToast("Foto principal actualizada", "success");
  };

  const subirVarias = async (lista) => {
    const files = [...(lista || [])].filter(Boolean);
    if (!files.length || ocupado) return;
    setOcupado(true);
    let ok = 0;
    for (let i = 0; i < files.length; i += 1) {
      setProgreso(`Subiendo ${i + 1} de ${files.length}…`);
      const subida = await subirImagenStorage(files[i], {
        bucket: "productos",
        maxSizeMB: 5,
        filenamePrefix,
      });
      if (!subida.ok) {
        showToast(subida.message, "error");
        continue;
      }
      if (!productoId) {
        setPendientes((prev) => (prev.some((u) => mismaFoto(u, subida.publicUrl)) ? prev : [...prev, subida.publicUrl]));
        if (!imagenRef.current) {
          imagenRef.current = subida.publicUrl;
          onImagenUrl?.(subida.publicUrl);
        }
        ok += 1;
        continue;
      }
      const res = await gestionarFotoProducto({
        action: "agregar",
        productoId,
        url: subida.publicUrl,
        principal: false,
      });
      if (!aplicarRespuesta(res)) continue;
      ok += 1;
    }
    setOcupado(false);
    setProgreso("");
    if (multiRef.current) multiRef.current.value = "";
    if (ok > 0) showToast(ok === 1 ? "Foto agregada" : `${ok} fotos agregadas`, "success");
  };

  useImperativeHandle(ref, () => ({
    adjuntarA: async (id) => {
      const pid = Number(id);
      if (!Number.isInteger(pid) || pid <= 0) return;
      const urls = [];
      const push = (url) => {
        const limpia = String(url || "").trim();
        if (!limpia || urls.some((u) => mismaFoto(u, limpia))) return;
        urls.push(limpia);
      };
      push(imagenRef.current);
      pendientes.forEach(push);
      filas.forEach((f) => push(f.url));
      if (!urls.length) return;
      let primero = true;
      for (const url of urls) {
        const res = await gestionarFotoProducto({
          action: primero ? "principal" : "agregar",
          productoId: pid,
          url,
          principal: primero,
        });
        primero = false;
        if (!res.ok) showToast(res.message || "No se pudo guardar una foto", "error");
      }
      avisarFotos(pid);
    },
  }), [pendientes, filas]);

  const btnQuitar = {
    marginTop: 4,
    width: "100%",
    minHeight: 44,
    padding: "10px 6px",
    borderRadius: 8,
    border: `1px solid ${C.red}`,
    background: "#ffffff",
    color: C.red,
    fontWeight: 700,
    fontSize: 11,
    cursor: ocupado ? "wait" : "pointer",
  };

  return (
    <div style={{ marginBottom: 16, padding: 14, background: C.bg, borderRadius: 10, border: `1px solid ${C.border}` }}>
      <label style={{ color: C.textMid, fontSize: 11, fontWeight: 700, display: "block", marginBottom: 8 }}>
        📷 FOTO DEL PRODUCTO
      </label>
      <ImageUploader
        bucket="productos"
        currentUrl={imagenUrl}
        filenamePrefix={filenamePrefix}
        aspectRatio="1:1"
        size="medium"
        avisarAlQuitar={false}
        onUploaded={(url) => { guardarPrincipalSubida(url); }}
        onRemoved={() => { quitar(imagenUrl, { confirmar: false }); }}
      />
      <div style={{ fontSize: 11, color: C.textDim, marginTop: 8, lineHeight: 1.4 }}>
        Cambiar imagen reemplaza la principal. Para sumar más de una, usá el botón de abajo.
      </div>

      <div style={{ marginTop: 12, paddingTop: 12, borderTop: `1px solid ${C.border}` }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 8, marginBottom: 8, flexWrap: "wrap" }}>
          <label style={{ color: C.textMid, fontSize: 11, fontWeight: 700 }}>
            🖼️ FOTOS DE ESTE PRODUCTO ({fotos.length})
          </label>
          <button
            type="button"
            onClick={() => multiRef.current?.click()}
            disabled={ocupado}
            style={{
              padding: "8px 12px",
              borderRadius: 8,
              border: "none",
              background: BRAND.primary,
              color: "#fff",
              fontWeight: 700,
              fontSize: 12,
              cursor: ocupado ? "wait" : "pointer",
              opacity: ocupado ? 0.7 : 1,
            }}
          >
            {progreso || "Subir varias fotos"}
          </button>
          <input
            ref={multiRef}
            type="file"
            accept="image/jpeg,image/png,image/webp,image/gif"
            multiple
            onChange={(e) => { subirVarias(e.target.files); }}
            style={{ display: "none" }}
          />
        </div>
        <div style={{ fontSize: 11, color: C.textDim, lineHeight: 1.45, marginBottom: 8 }}>
          Elegí una o varias a la vez. Tocá una foto para dejarla como principal. Quitar la saca de la tienda: sirve para borrar las que no son de este producto.
        </div>

        {cargando ? (
          <div style={{ fontSize: 12, color: C.textMid }}>Cargando fotos…</div>
        ) : fotos.length === 0 ? (
          <div style={{ fontSize: 12, color: C.textMid }}>Todavía no hay fotos. Subí la caja, el frente y el dorso.</div>
        ) : (
          <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
            {fotos.map((foto, i) => (
              <div key={foto.clave} style={{ width: 96 }}>
                <button
                  type="button"
                  onClick={() => hacerPrincipal(foto.url)}
                  disabled={ocupado}
                  title={foto.esPrincipal ? "Foto principal" : "Usar como foto principal"}
                  aria-label={foto.esPrincipal ? `Foto principal ${i + 1}` : `Usar foto ${i + 1} como principal`}
                  style={{
                    width: 96,
                    height: 96,
                    padding: 4,
                    borderRadius: 10,
                    cursor: ocupado ? "wait" : "pointer",
                    background: "#ffffff",
                    border: foto.esPrincipal ? `2px solid ${BRAND.primary}` : `1px solid ${C.border}`,
                  }}
                >
                  <img src={foto.url} alt="" style={{ width: "100%", height: "100%", objectFit: "contain", display: "block" }} />
                </button>
                <div style={{ fontSize: 10, fontWeight: 800, color: foto.esPrincipal ? BRAND.primary : "transparent", textAlign: "center", minHeight: 14 }}>
                  {foto.esPrincipal ? "Principal" : "·"}
                </div>
                <button
                  type="button"
                  onClick={() => quitar(foto.url)}
                  disabled={ocupado}
                  aria-label={`Quitar foto ${i + 1}`}
                  style={btnQuitar}
                >
                  Quitar
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
});

export default FotosProductoEditor;
