import { useState, useRef } from "react";
import { showToast } from "../ui";
import { C_LIGHT, BRAND } from "../constants";
import { subirImagenStorage } from "../lib/subirImagenStorage";

/**
 * Subida de imágenes a Supabase Storage (buckets: banners | productos).
 *
 * @param {"banners"|"productos"} bucket
 * @param {string} [currentUrl]
 * @param {(url: string) => void} onUploaded
 * @param {() => void} [onRemoved]
 * @param {number} [maxSizeMB]
 * @param {string} [filenamePrefix]
 * @param {"1:1"|"16:9"|"16:5"} [aspectRatio]
 * @param {"small"|"medium"|"large"} [size]
 * @param {boolean} [avisarAlQuitar] Toast propio. En el editor de producto el aviso lo pone la galería.
 */
export default function ImageUploader({
  bucket,
  currentUrl,
  onUploaded,
  onRemoved,
  maxSizeMB = 5,
  filenamePrefix = "",
  aspectRatio = "1:1",
  size = "medium",
  avisarAlQuitar = true,
}) {
  const C = C_LIGHT;
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const fileInputRef = useRef(null);

  const handleFile = async (file) => {
    if (!file) return;
    const result = await subirImagenStorage(file, {
      bucket,
      maxSizeMB,
      filenamePrefix,
      onProgress: (n) => {
        setUploading(true);
        setProgress(n);
      },
    });
    setUploading(false);
    setProgress(0);
    if (fileInputRef.current) fileInputRef.current.value = "";
    if (!result.ok) {
      showToast(result.message, "error");
      return;
    }
    showToast("✅ Imagen subida correctamente", "success");
    onUploaded(result.publicUrl);
  };

  const handleRemove = () => {
    if (!window.confirm("¿Quitar esta imagen?")) return;
    onRemoved?.();
    if (avisarAlQuitar) showToast("Imagen quitada", "info");
  };

  const previewSize = size === "large" ? 200 : size === "small" ? 80 : 140;
  const aspectStyle =
    aspectRatio === "16:9"
      ? { width: Math.round(previewSize * 1.78), height: previewSize }
      : aspectRatio === "16:5"
        ? { width: Math.round(previewSize * 3.2), height: previewSize }
        : { width: previewSize, height: previewSize };

  return (
    <div style={{ display: "flex", gap: 12, alignItems: "flex-start", flexWrap: "wrap" }}>
      <div
        style={{
          ...aspectStyle,
          borderRadius: 10,
          border: `2px dashed ${currentUrl ? C.border : BRAND.primary}`,
          background: currentUrl ? `url(${currentUrl}) center/cover` : C.bg,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          position: "relative",
          flexShrink: 0,
        }}
      >
        {!currentUrl && !uploading && (
          <div style={{ textAlign: "center", color: C.textMid, fontSize: 11 }}>
            <div style={{ fontSize: 28 }}>📷</div>
            <div>Sin imagen</div>
          </div>
        )}
        {uploading && (
          <div
            style={{
              position: "absolute",
              inset: 0,
              background: "rgba(255,255,255,0.9)",
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              justifyContent: "center",
              borderRadius: 10,
            }}
          >
            <div style={{ fontSize: 24 }}>⏳</div>
            <div style={{ fontSize: 12, color: C.textMid, marginTop: 4 }}>{progress}%</div>
            <div
              style={{
                width: "70%",
                height: 4,
                background: C.border,
                borderRadius: 2,
                marginTop: 6,
                overflow: "hidden",
              }}
            >
              <div
                style={{
                  width: `${progress}%`,
                  height: "100%",
                  background: BRAND.primary,
                  transition: "width 0.3s",
                }}
              />
            </div>
          </div>
        )}
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: 8, flex: 1, minWidth: 200 }}>
        <input
          ref={fileInputRef}
          type="file"
          accept="image/jpeg,image/png,image/webp,image/gif"
          onChange={(e) => handleFile(e.target.files?.[0])}
          style={{ display: "none" }}
        />

        <button
          type="button"
          onClick={() => fileInputRef.current?.click()}
          disabled={uploading}
          style={{
            padding: "10px 16px",
            borderRadius: 8,
            border: `1px solid ${BRAND.primary}`,
            background: BRAND.primary,
            color: "#fff",
            fontWeight: 700,
            fontSize: 13,
            cursor: uploading ? "wait" : "pointer",
            opacity: uploading ? 0.6 : 1,
          }}
        >
          {uploading ? `Subiendo... ${progress}%` : currentUrl ? "🔄 Cambiar imagen" : "📤 Subir imagen"}
        </button>

        {currentUrl && !uploading && (
          <button
            type="button"
            onClick={handleRemove}
            style={{
              padding: "8px 14px",
              borderRadius: 8,
              border: `1px solid ${C.red}`,
              background: "transparent",
              color: C.red,
              fontWeight: 600,
              fontSize: 12,
              cursor: "pointer",
            }}
          >
            🗑️ Quitar
          </button>
        )}

        <div style={{ fontSize: 11, color: C.textDim, lineHeight: 1.4 }}>
          📐 {aspectRatio === "16:5" ? "Recomendado: 1920×600px (16:5)" : aspectRatio === "16:9" ? "Recomendado: 1600×900px" : "Recomendado: 1080×1080px"}
          <br />
          📦 Máximo: {maxSizeMB}MB · JPG, PNG, WEBP{bucket === "banners" ? ", GIF" : ""}
          <br />
          <span style={{ fontSize: 10 }}>Bucket Storage: {bucket}</span>
        </div>
      </div>
    </div>
  );
}
