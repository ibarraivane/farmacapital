/**
 * Subida de imágenes públicas para tienda (banners y productos).
 * Buckets: farmax-banners, farmax-productos — crear en Supabase y aplicar sql/storage_farmax_tienda.sql
 */

export const FARMAX_STORAGE = {
  banners: "farmax-banners",
  productos: "farmax-productos",
};

export function guessImageExt(file) {
  const t = file?.type || "";
  if (t.includes("png")) return "png";
  if (t.includes("webp")) return "webp";
  if (t.includes("gif")) return "gif";
  if (t.includes("jpeg") || t.includes("jpg")) return "jpg";
  const n = file?.name?.split(".").pop();
  if (n && /^[a-z0-9]+$/i.test(n) && n.length <= 5) return n.toLowerCase();
  return "jpg";
}

async function removePrefixFiles(supabaseClient, bucket, folder, namePrefix) {
  const folderStr = String(folder);
  const { data: files, error: listErr } = await supabaseClient.storage.from(bucket).list(folderStr);
  if (listErr) throw listErr;
  const paths = (files || [])
    .filter((f) => f.name && f.name.startsWith(namePrefix))
    .map((f) => `${folderStr}/${f.name}`);
  if (paths.length) {
    const { error: rmErr } = await supabaseClient.storage.from(bucket).remove(paths);
    if (rmErr) throw rmErr;
  }
}

/**
 * @param {"desktop"|"mobile"} variant
 */
export async function uploadBannerImage(supabaseClient, bannerId, file, variant) {
  const id = String(bannerId);
  const ext = guessImageExt(file);
  const prefix = variant === "mobile" ? "mobile" : "desktop";
  await removePrefixFiles(supabaseClient, FARMAX_STORAGE.banners, id, prefix);
  const path = `${id}/${prefix}.${ext}`;
  const { error: upErr } = await supabaseClient.storage.from(FARMAX_STORAGE.banners).upload(path, file, {
    upsert: true,
    cacheControl: "3600",
    contentType: file.type || "image/jpeg",
  });
  if (upErr) throw upErr;
  const { data } = supabaseClient.storage.from(FARMAX_STORAGE.banners).getPublicUrl(path);
  return { path, publicUrl: data.publicUrl };
}

export async function uploadProductImage(supabaseClient, productId, file) {
  const id = String(productId);
  await removePrefixFiles(supabaseClient, FARMAX_STORAGE.productos, id, "principal");
  const ext = guessImageExt(file);
  const path = `${id}/principal.${ext}`;
  const { error: upErr } = await supabaseClient.storage.from(FARMAX_STORAGE.productos).upload(path, file, {
    upsert: true,
    cacheControl: "3600",
    contentType: file.type || "image/jpeg",
  });
  if (upErr) throw upErr;
  const { data } = supabaseClient.storage.from(FARMAX_STORAGE.productos).getPublicUrl(path);
  return { path, publicUrl: data.publicUrl };
}

/** Borra solo desktop o mobile en Storage (prefijos de archivo). */
export async function deleteBannerVariantFiles(supabaseClient, bannerId, variant) {
  const id = String(bannerId);
  const prefix = variant === "mobile" ? "mobile" : "desktop";
  await removePrefixFiles(supabaseClient, FARMAX_STORAGE.banners, id, prefix);
}

export async function deleteBannerStorageFolder(supabaseClient, bannerId) {
  const id = String(bannerId);
  const { data: files, error: listErr } = await supabaseClient.storage.from(FARMAX_STORAGE.banners).list(id);
  if (listErr) return;
  const paths = (files || []).map((f) => `${id}/${f.name}`);
  if (paths.length) await supabaseClient.storage.from(FARMAX_STORAGE.banners).remove(paths);
}

export async function deleteProductImageStorageFolder(supabaseClient, productId) {
  const id = String(productId);
  const { data: files, error: listErr } = await supabaseClient.storage.from(FARMAX_STORAGE.productos).list(id);
  if (listErr) return;
  const paths = (files || []).map((f) => `${id}/${f.name}`);
  if (paths.length) await supabaseClient.storage.from(FARMAX_STORAGE.productos).remove(paths);
}
