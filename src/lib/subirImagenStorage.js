import { supabase } from "../supabase";
import { esPlaceholderImagenCompetencia, mensajeRechazoImagenCompetencia } from "./imagenCompetencia";

const EXT_TO_MIME = {
  jpg: "image/jpeg",
  jpeg: "image/jpeg",
  png: "image/png",
  webp: "image/webp",
  gif: "image/gif",
};

function leerMedidas(file) {
  return new Promise((resolve) => {
    if (!file?.type?.startsWith("image/") || file.type === "image/svg+xml") {
      resolve(null);
      return;
    }
    const url = URL.createObjectURL(file);
    const img = new Image();
    img.onload = () => {
      URL.revokeObjectURL(url);
      resolve({ width: img.naturalWidth || img.width, height: img.naturalHeight || img.height });
    };
    img.onerror = () => {
      URL.revokeObjectURL(url);
      resolve(null);
    };
    img.src = url;
  });
}

function tokenSesion() {
  try { return sessionStorage.getItem("farmacapital_session_token") || ""; } catch { return ""; }
}

/**
 * Sube un archivo al bucket de Storage.
 * @returns {Promise<{ ok: true, publicUrl: string } | { ok: false, message: string }>}
 */
export async function subirImagenStorage(file, {
  bucket = "productos",
  maxSizeMB = 5,
  filenamePrefix = "",
  onProgress,
} = {}) {
  if (!file) return { ok: false, message: "Selecciona una imagen." };
  const rawExt = (file.name.split(".").pop() || "").toLowerCase();
  const ext = rawExt === "jfif" ? "jpg" : rawExt;
  const fallbackMime = EXT_TO_MIME[ext] || "";
  const fileMime = file.type && file.type.startsWith("image/") ? file.type : fallbackMime;
  if (!fileMime) return { ok: false, message: "Por favor selecciona una imagen válida" };

  const sizeMB = file.size / 1024 / 1024;
  if (sizeMB > maxSizeMB) {
    return { ok: false, message: `La imagen pesa ${sizeMB.toFixed(1)}MB. Máximo permitido: ${maxSizeMB}MB` };
  }

  const dims = await leerMedidas(file);
  if (esPlaceholderImagenCompetencia({
    byteLength: file.size,
    width: dims?.width,
    height: dims?.height,
  })) {
    return { ok: false, message: mensajeRechazoImagenCompetencia() };
  }

  onProgress?.(10);
  const finalExt =
    fileMime === "image/jpeg" ? "jpg" :
    fileMime === "image/png" ? "png" :
    fileMime === "image/webp" ? "webp" :
    fileMime === "image/gif" ? "gif" :
    (ext || "jpg");
  const timestamp = Date.now();
  const dimTag = dims?.width && dims?.height ? `${dims.width}x${dims.height}` : "img";
  const cleanPrefix = String(filenamePrefix || "").toLowerCase().replace(/[^a-z0-9-]/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "");
  const fileName = cleanPrefix
    ? `${cleanPrefix}-${dimTag}-${timestamp}.${finalExt}`
    : `${bucket}-${dimTag}-${timestamp}.${finalExt}`;

  onProgress?.(30);
  const sessionToken = tokenSesion();
  const useServerUpload = sessionToken && (bucket === "banners" || bucket === "productos");

  try {
    if (useServerUpload) {
      const resp = await fetch("/api/admin/storage-upload", {
        method: "POST",
        headers: {
          "Content-Type": fileMime,
          "X-Session-Token": sessionToken,
          "X-Bucket": bucket,
          "X-File-Name": fileName,
        },
        body: file,
      });
      const data = await resp.json().catch(() => ({}));
      if (!resp.ok || !data?.ok) {
        throw new Error(data?.message || data?.error || `Error ${resp.status}`);
      }
      onProgress?.(100);
      return { ok: true, publicUrl: data.publicUrl };
    }

    const { error: uploadError } = await supabase.storage.from(bucket).upload(fileName, file, {
      cacheControl: "3600",
      upsert: true,
      contentType: fileMime,
    });
    if (uploadError) throw uploadError;
    const { data } = supabase.storage.from(bucket).getPublicUrl(fileName);
    onProgress?.(100);
    return { ok: true, publicUrl: `${data.publicUrl}?v=${timestamp}` };
  } catch (e) {
    console.error("[subirImagenStorage]", e);
    return { ok: false, message: `Error al subir: ${e.message || String(e)}` };
  }
}
