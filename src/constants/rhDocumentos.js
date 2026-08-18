export const RH_DOC_TIPOS = [
  { id: "contrato",    label: "Contrato firmado",              requerido: true },
  { id: "ine_frente",  label: "INE (frente)",                  requerido: true },
  { id: "ine_reverso", label: "INE (reverso)",                 requerido: true },
  { id: "domicilio",   label: "Comprobante de domicilio",      requerido: false },
  { id: "curp",        label: "CURP",                          requerido: false },
  { id: "rfc",         label: "Constancia de situación fiscal", requerido: false },
  { id: "nss",         label: "NSS / alta IMSS",               requerido: false },
  { id: "clabe",       label: "CLABE / estado de cuenta",      requerido: false },
  { id: "foto",        label: "Foto de perfil",                requerido: false },
  { id: "otro",        label: "Otro",                          requerido: false },
];

export const RH_DOC_MAX_MB = 10;
export const RH_DOC_ACCEPT = ".pdf,.jpg,.jpeg,.png,.webp";
export const RH_DOC_MIMES = [
  "application/pdf",
  "image/jpeg",
  "image/png",
  "image/webp",
];

export function rhDocLabel(tipo) {
  return RH_DOC_TIPOS.find((t) => t.id === tipo)?.label || tipo;
}
