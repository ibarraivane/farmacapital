/** PNG del recibo: en el celular se comparte (WhatsApp); en la compu se descarga. */

export async function compartirODescargarPng(el, filename) {
  if (!el) throw new Error("sin_ticket");
  const { default: html2canvas } = await import("html2canvas");
  const canvas = await html2canvas(el, {
    scale: 3,
    backgroundColor: "#ffffff",
    useCORS: true,
    logging: false,
  });
  const blob = await new Promise((resolve) => canvas.toBlob(resolve, "image/png"));
  if (!blob) throw new Error("png_vacio");
  const file = new File([blob], filename, { type: "image/png" });
  if (typeof navigator !== "undefined" && navigator.canShare?.({ files: [file] })) {
    await navigator.share({ files: [file], title: "Recibo FarmaCapital" });
    return "shared";
  }
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  a.click();
  setTimeout(() => URL.revokeObjectURL(url), 1500);
  return "downloaded";
}
