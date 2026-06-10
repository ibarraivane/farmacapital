/**
 * Subida de imágenes públicas para tienda (banners y productos).
 * Buckets: farmacapital-banners, farmacapital-productos — crear en Supabase y aplicar sql/storage_farmacapital_tienda.sql
 */

import {
  prepareBannerDualForUpload,
  prepareProductDualForUpload,
  prepareImageForUpload,
  extFromContentType,
} from "./imageUploadResize";

export const FARMACAPITAL_STORAGE = {
  banners: "farmacapital-banners",
  productos: "farmacapital-productos",
};

export function guessImageExt(file) {
  return extFromContentType(file?.type || "");
}

async function removePrefixFiles(supabaseClient, bucket, folder, namePrefix) {
  const folderStr = String(folder);
  const { data: files, error: listErr } = await supabaseClient.storage.from(bucket).list(folderStr);
  if (listErr) {
    // No bloquear la subida: carpetas nuevas, políticas de list distintas o bucket recién creado.
    console.warn("[farmacapital storage] list omitido:", bucket, folderStr, listErr.message || listErr);
    return;
  }
  const paths = (files || [])
    .filter((f) => f.name && f.name.startsWith(namePrefix))
    .map((f) => `${folderStr}/${f.name}`);
  if (paths.length) {
    const { error: rmErr } = await supabaseClient.storage.from(bucket).remove(paths);
    if (rmErr) {
      console.warn("[farmacapital storage] remove parcial:", bucket, rmErr.message || rmErr);
    }
  }
}

async function clearBannerImageSlots(supabaseClient, bannerId) {
  const id = String(bannerId);
  await removePrefixFiles(supabaseClient, FARMACAPITAL_STORAGE.banners, id, "desktop");
  await removePrefixFiles(supabaseClient, FARMACAPITAL_STORAGE.banners, id, "mobile");
}

async function clearProductImageSlots(supabaseClient, productId) {
  const id = String(productId);
  await removePrefixFiles(supabaseClient, FARMACAPITAL_STORAGE.productos, id, "principal");
  await removePrefixFiles(supabaseClient, FARMACAPITAL_STORAGE.productos, id, "desktop");
  await removePrefixFiles(supabaseClient, FARMACAPITAL_STORAGE.productos, id, "mobile");
}

/**
 * Sube una imagen y genera URLs escritorio + móvil (misma URL si es GIF/SVG).
 * @returns {Promise<{ imagen_url: string, imagen_mobile_url: string }>}
 */
export async function uploadAutoBannerImages(supabaseClient, bannerId, file) {
  const id = String(bannerId);
  const prep = await prepareBannerDualForUpload(file);
  await clearBannerImageSlots(supabaseClient, id);
  const bucket = FARMACAPITAL_STORAGE.banners;

  if (prep.mode === "single") {
    const ext = extFromContentType(prep.contentType);
    const path = `${id}/desktop.${ext}`;
    const { error } = await supabaseClient.storage.from(bucket).upload(path, prep.file, {
      upsert: true,
      cacheControl: "3600",
      contentType: prep.contentType,
    });
    if (error) throw error;
    const { data } = supabaseClient.storage.from(bucket).getPublicUrl(path);
    const url = data.publicUrl;
    return { imagen_url: url, imagen_mobile_url: url };
  }

  const extD = extFromContentType(prep.desktop.contentType);
  const extM = extFromContentType(prep.mobile.contentType);
  const pathD = `${id}/desktop.${extD}`;
  const pathM = `${id}/mobile.${extM}`;
  let { error: e1 } = await supabaseClient.storage.from(bucket).upload(pathD, prep.desktop.file, {
    upsert: true,
    cacheControl: "3600",
    contentType: prep.desktop.contentType,
  });
  if (e1) throw e1;
  let { error: e2 } = await supabaseClient.storage.from(bucket).upload(pathM, prep.mobile.file, {
    upsert: true,
    cacheControl: "3600",
    contentType: prep.mobile.contentType,
  });
  if (e2) throw e2;
  const uD = supabaseClient.storage.from(bucket).getPublicUrl(pathD).data.publicUrl;
  const uM = supabaseClient.storage.from(bucket).getPublicUrl(pathM).data.publicUrl;
  return { imagen_url: uD, imagen_mobile_url: uM };
}

/**
 * @returns {Promise<{ imagen_url: string, imagen_mobile_url: string }>}
 */
export async function uploadAutoProductImages(supabaseClient, productId, file) {
  const id = String(productId);
  const prep = await prepareProductDualForUpload(file);
  await clearProductImageSlots(supabaseClient, id);
  const bucket = FARMACAPITAL_STORAGE.productos;

  if (prep.mode === "single") {
    const ext = extFromContentType(prep.contentType);
    const path = `${id}/desktop.${ext}`;
    const { error } = await supabaseClient.storage.from(bucket).upload(path, prep.file, {
      upsert: true,
      cacheControl: "3600",
      contentType: prep.contentType,
    });
    if (error) throw error;
    const { data } = supabaseClient.storage.from(bucket).getPublicUrl(path);
    const url = data.publicUrl;
    return { imagen_url: url, imagen_mobile_url: url };
  }

  const extD = extFromContentType(prep.desktop.contentType);
  const extM = extFromContentType(prep.mobile.contentType);
  const pathD = `${id}/desktop.${extD}`;
  const pathM = `${id}/mobile.${extM}`;
  let { error: e1 } = await supabaseClient.storage.from(bucket).upload(pathD, prep.desktop.file, {
    upsert: true,
    cacheControl: "3600",
    contentType: prep.desktop.contentType,
  });
  if (e1) throw e1;
  let { error: e2 } = await supabaseClient.storage.from(bucket).upload(pathM, prep.mobile.file, {
    upsert: true,
    cacheControl: "3600",
    contentType: prep.mobile.contentType,
  });
  if (e2) throw e2;
  const uD = supabaseClient.storage.from(bucket).getPublicUrl(pathD).data.publicUrl;
  const uM = supabaseClient.storage.from(bucket).getPublicUrl(pathM).data.publicUrl;
  return { imagen_url: uD, imagen_mobile_url: uM };
}

/**
 * @param {"desktop"|"mobile"} variant — subida manual de una variante (legacy)
 */
export async function uploadBannerImage(supabaseClient, bannerId, file, variant) {
  const id = String(bannerId);
  const preset = variant === "mobile" ? "bannerMobile" : "bannerDesktop";
  const { file: uploadFile, contentType } = await prepareImageForUpload(file, preset);
  const ext = extFromContentType(contentType);
  const prefix = variant === "mobile" ? "mobile" : "desktop";
  await removePrefixFiles(supabaseClient, FARMACAPITAL_STORAGE.banners, id, prefix);
  const path = `${id}/${prefix}.${ext}`;
  const { error: upErr } = await supabaseClient.storage.from(FARMACAPITAL_STORAGE.banners).upload(path, uploadFile, {
    upsert: true,
    cacheControl: "3600",
    contentType,
  });
  if (upErr) throw upErr;
  const { data } = supabaseClient.storage.from(FARMACAPITAL_STORAGE.banners).getPublicUrl(path);
  return { path, publicUrl: data.publicUrl };
}

/** Una sola variante producto (legacy); preferir uploadAutoProductImages */
export async function uploadProductImage(supabaseClient, productId, file) {
  const id = String(productId);
  const { file: uploadFile, contentType } = await prepareImageForUpload(file, "product");
  await clearProductImageSlots(supabaseClient, id);
  const ext = extFromContentType(contentType);
  const path = `${id}/desktop.${ext}`;
  const { error: upErr } = await supabaseClient.storage.from(FARMACAPITAL_STORAGE.productos).upload(path, uploadFile, {
    upsert: true,
    cacheControl: "3600",
    contentType,
  });
  if (upErr) throw upErr;
  const { data } = supabaseClient.storage.from(FARMACAPITAL_STORAGE.productos).getPublicUrl(path);
  return { path, publicUrl: data.publicUrl };
}

export async function deleteBannerVariantFiles(supabaseClient, bannerId, variant) {
  const id = String(bannerId);
  const prefix = variant === "mobile" ? "mobile" : "desktop";
  await removePrefixFiles(supabaseClient, FARMACAPITAL_STORAGE.banners, id, prefix);
}

export async function deleteBannerStorageFolder(supabaseClient, bannerId) {
  const id = String(bannerId);
  const { data: files, error: listErr } = await supabaseClient.storage.from(FARMACAPITAL_STORAGE.banners).list(id);
  if (listErr) return;
  const paths = (files || []).map((f) => `${id}/${f.name}`);
  if (paths.length) await supabaseClient.storage.from(FARMACAPITAL_STORAGE.banners).remove(paths);
}

export async function deleteProductImageStorageFolder(supabaseClient, productId) {
  const id = String(productId);
  const { data: files, error: listErr } = await supabaseClient.storage.from(FARMACAPITAL_STORAGE.productos).list(id);
  if (listErr) return;
  const paths = (files || []).map((f) => `${id}/${f.name}`);
  if (paths.length) await supabaseClient.storage.from(FARMACAPITAL_STORAGE.productos).remove(paths);
}
