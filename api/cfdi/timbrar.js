'use strict';

// ═══════════════════════════════════════════════════════════════
// FARMAX — Timbrado CFDI 4.0 vía SW Sapien
// Documentación SW: https://developers.sw.com.mx
//
// Variables de entorno requeridas (Vercel → Settings → Env Vars):
//   SW_USER                  tu usuario SW Sapien
//   SW_PASSWORD              tu contraseña SW Sapien
//   SW_SANDBOX               "true" para pruebas, "false" para producción
//   RFC_EMISOR               RFC de la farmacia (ej: XAXX010101000)
//   NOMBRE_EMISOR            Razón social de la farmacia
//   REGIMEN_EMISOR           Clave régimen fiscal (ej: 612)
//   CP_EXPEDICION            Código postal de la farmacia (ej: 09208)
//   SUPABASE_URL             URL de Supabase
//   SUPABASE_SERVICE_ROLE_KEY Service role key
// ═══════════════════════════════════════════════════════════════

const SW_AUTH_URL  = "https://services.sw.com.mx/security/authenticate";
const SW_STAMP_URL = "https://services.sw.com.mx/cfdi33/stamp/v4/b64/";
// SW Sapien usa el mismo host para CFDI 3.3 y 4.0 — la versión va en el XML

function normalizeUrl(url) {
  if (!url) return url;
  return url.trim().replace(/\/+$/, "").replace(/\/rest\/v1$/i, "").replace(/\/+$/, "");
}

async function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === "object") return req.body;
    return JSON.parse(req.body || "{}");
  } catch { return {}; }
}

// ── Autenticar con SW Sapien ───────────────────────────────────
async function swAutenticar(user, password) {
  const res = await fetch(SW_AUTH_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json", "Accept": "application/json" },
    body: JSON.stringify({ user, password }),
  });
  const json = await res.json();
  if (!res.ok || !json?.data?.token) {
    throw new Error(`SW Sapien auth error: ${json?.message || res.status}`);
  }
  return json.data.token;
}

// ── Timbrar XML en SW Sapien ───────────────────────────────────
async function swTimbrar(token, xmlBase64) {
  const res = await fetch(SW_STAMP_URL, {
    method:  "POST",
    headers: {
      "Authorization": `bearer ${token}`,
      "Content-Type":  "application/json",
      "Accept":        "application/json",
    },
    body: JSON.stringify({ xml: xmlBase64 }),
  });
  const json = await res.json();
  if (!res.ok || json?.status !== "success") {
    const detail = json?.message || json?.messageDetail || JSON.stringify(json);
    throw new Error(`SW Sapien timbrado error: ${detail}`);
  }
  return {
    uuid:      json.data?.uuid || "",
    xmlTimbrado: json.data?.cfdi || "",          // XML timbrado en base64
    cadenaOriginalSAT: json.data?.cadenaOriginalSAT || "",
    noCertificadoSAT:  json.data?.noCertificadoSAT || "",
    selloSAT:          json.data?.selloSAT || "",
  };
}

// ── Construir XML CFDI 4.0 ─────────────────────────────────────
function buildCfdiXml({ emisor, receptor, conceptos, total, subtotal, totalIva, formaPago, metodoPago, lugarExpedicion }) {
  const ahora = new Date();
  const pad = n => String(n).padStart(2, "0");
  const fecha = `${ahora.getFullYear()}-${pad(ahora.getMonth()+1)}-${pad(ahora.getDate())}T${pad(ahora.getHours())}:${pad(ahora.getMinutes())}:${pad(ahora.getSeconds())}`;

  const fmt2 = n => parseFloat(n).toFixed(2);

  const conceptosXml = conceptos.map(c => {
    const importe = fmt2(c.precio * c.cantidad);
    const baseIva = fmt2(c.precio * c.cantidad / 1.16);
    const montoIva = fmt2(c.precio * c.cantidad - parseFloat(baseIva));
    return `
      <cfdi:Concepto ClaveProdServ="${c.claveProdServ || "01010101"}" ClaveUnidad="${c.claveUnidad || "H87"}" Descripcion="${escXml(c.nombre)}" Cantidad="${c.cantidad}" ValorUnitario="${fmt2(c.precio / 1.16)}" Importe="${baseIva}" ObjetoImp="02">
        <cfdi:Impuestos>
          <cfdi:Traslados>
            <cfdi:Traslado Base="${baseIva}" Impuesto="002" TipoFactor="Tasa" TasaOCuota="0.160000" Importe="${montoIva}"/>
          </cfdi:Traslados>
        </cfdi:Impuestos>
      </cfdi:Concepto>`;
  }).join("");

  const totalIvaFmt = fmt2(totalIva);
  const subtotalFmt = fmt2(subtotal);
  const totalFmt    = fmt2(total);

  return `<?xml version="1.0" encoding="utf-8"?>
<cfdi:Comprobante
  xmlns:cfdi="http://www.sat.gob.mx/cfd/4"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.sat.gob.mx/cfd/4 http://www.sat.gob.mx/sitio_internet/cfd/4/cfdv40.xsd"
  Version="4.0"
  Fecha="${fecha}"
  Sello=""
  NoCertificado=""
  Certificado=""
  SubTotal="${subtotalFmt}"
  Moneda="MXN"
  Total="${totalFmt}"
  TipoDeComprobante="I"
  Exportacion="01"
  MetodoPago="${metodoPago}"
  FormaPago="${formaPago}"
  LugarExpedicion="${lugarExpedicion}">
  <cfdi:Emisor Rfc="${emisor.rfc}" Nombre="${escXml(emisor.nombre)}" RegimenFiscal="${emisor.regimen}"/>
  <cfdi:Receptor Rfc="${receptor.rfc}" Nombre="${escXml(receptor.nombre)}" DomicilioFiscalReceptor="${receptor.cp || "09208"}" RegimenFiscalReceptor="${receptor.regimen}" UsoCFDI="${receptor.usoCfdi}"/>
  <cfdi:Conceptos>${conceptosXml}
  </cfdi:Conceptos>
  <cfdi:Impuestos TotalImpuestosTrasladados="${totalIvaFmt}">
    <cfdi:Traslados>
      <cfdi:Traslado Base="${subtotalFmt}" Impuesto="002" TipoFactor="Tasa" TasaOCuota="0.160000" Importe="${totalIvaFmt}"/>
    </cfdi:Traslados>
  </cfdi:Impuestos>
</cfdi:Comprobante>`;
}

function escXml(s) {
  return String(s || "").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&apos;");
}

// Mapeo de método de pago POS → clave SAT FormaPago
function formaPagoSAT(metodoPosStr) {
  const m = (metodoPosStr || "").toLowerCase();
  if (m === "efectivo")            return "01"; // Efectivo
  if (m.includes("tarjeta"))       return "04"; // Tarjeta de crédito (genérico)
  if (m.includes("bbva"))          return "04"; // Tarjeta de débito/crédito BBVA
  if (m.includes("mercadopago") || m.includes("point")) return "04";
  if (m === "spei" || m.includes("transfer")) return "03"; // Transferencia
  return "99"; // Otros
}

// ── Handler principal ──────────────────────────────────────────
module.exports = async function handler(req, res) {
  if (req.method !== "POST") return res.status(405).json({ ok: false, error: "method_not_allowed" });

  // Variables de entorno
  const SW_USER    = (process.env.SW_USER    || "").trim();
  const SW_PASSWORD= (process.env.SW_PASSWORD|| "").trim();
  const SANDBOX    = (process.env.SW_SANDBOX || "true").toLowerCase() !== "false";

  const RFC_EMISOR    = (process.env.RFC_EMISOR    || "").trim().toUpperCase();
  const NOMBRE_EMISOR = (process.env.NOMBRE_EMISOR || "FARMAX FARMACIA").trim().toUpperCase();
  const REGIMEN_EMISOR= (process.env.REGIMEN_EMISOR|| "612").trim();
  const CP_EXPEDICION = (process.env.CP_EXPEDICION || "09208").trim();

  const SUPABASE_URL  = normalizeUrl(process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL || "");
  const SERVICE_KEY   = (process.env.SUPABASE_SERVICE_ROLE_KEY || "").trim();

  if (!SW_USER || !SW_PASSWORD) {
    return res.status(500).json({ ok: false, error: "SW_USER y SW_PASSWORD no están configurados en Vercel" });
  }
  if (!RFC_EMISOR) {
    return res.status(500).json({ ok: false, error: "RFC_EMISOR no configurado en Vercel" });
  }
  if (!SUPABASE_URL || !SERVICE_KEY) {
    return res.status(500).json({ ok: false, error: "Supabase service role no configurado" });
  }

  const body = await safeJson(req);
  const { session_token, pedido_id, rfc_receptor, nombre_receptor, uso_cfdi, regimen_receptor, cp_receptor, email_receptor } = body;

  if (!session_token || !pedido_id || !rfc_receptor || !nombre_receptor) {
    return res.status(400).json({ ok: false, error: "Faltan campos requeridos" });
  }

  // ── 1. Validar sesión y obtener datos del pedido ─────────────
  const supaHeaders = {
    "apikey": SERVICE_KEY,
    "Authorization": `Bearer ${SERVICE_KEY}`,
    "Content-Type": "application/json",
  };

  // Validar que el session_token pertenece a un empleado activo
  const tokRes = await fetch(`${SUPABASE_URL}/rest/v1/rpc/fn_validar_session_token`, {
    method: "POST",
    headers: supaHeaders,
    body: JSON.stringify({ p_token: session_token }),
  });
  if (!tokRes.ok) {
    return res.status(401).json({ ok: false, error: "Sesión inválida o expirada" });
  }
  const tokData = await tokRes.json();
  if (!tokData || tokData === null || tokData === false || tokData?.error) {
    return res.status(401).json({ ok: false, error: "Sesión inválida" });
  }

  // Obtener pedido con items
  const pedRes = await fetch(
    `${SUPABASE_URL}/rest/v1/pedidos?id=eq.${encodeURIComponent(pedido_id)}&select=id,total,metodo_pago,created_at,pedido_items(cantidad,precio_unitario,productos(nombre,sku))`,
    { headers: supaHeaders }
  );
  const pedidos = await pedRes.json();
  const pedido = Array.isArray(pedidos) ? pedidos[0] : null;
  if (!pedido) {
    return res.status(404).json({ ok: false, error: "Pedido no encontrado" });
  }

  const totalPedido = parseFloat(pedido.total || 0);
  const subtotal    = parseFloat((totalPedido / 1.16).toFixed(2));
  const totalIva    = parseFloat((totalPedido - subtotal).toFixed(2));

  const conceptos = (pedido.pedido_items || []).map(it => ({
    nombre:        it.productos?.nombre || "Medicamento",
    claveProdServ: "51101500", // Productos farmacéuticos — catálogo SAT
    claveUnidad:   "H87",     // Pieza
    cantidad:      it.cantidad || 1,
    precio:        parseFloat(it.precio_unitario || 0),
  }));

  if (!conceptos.length) {
    return res.status(400).json({ ok: false, error: "El pedido no tiene artículos" });
  }

  // ── 2. Construir XML CFDI 4.0 ────────────────────────────────
  const xml = buildCfdiXml({
    emisor: { rfc: RFC_EMISOR, nombre: NOMBRE_EMISOR, regimen: REGIMEN_EMISOR },
    receptor: {
      rfc:      rfc_receptor.trim().toUpperCase(),
      nombre:   nombre_receptor.trim().toUpperCase(),
      cp:       cp_receptor || "09208",
      regimen:  regimen_receptor || "616",
      usoCfdi:  uso_cfdi || "G03",
    },
    conceptos,
    total:       totalPedido,
    subtotal,
    totalIva,
    formaPago:   formaPagoSAT(pedido.metodo_pago),
    metodoPago:  "PUE", // Pago en una sola exhibición
    lugarExpedicion: CP_EXPEDICION,
  });

  const xmlBase64 = Buffer.from(xml, "utf-8").toString("base64");

  // ── 3. Timbrar con SW Sapien ─────────────────────────────────
  let timbre;
  try {
    // En sandbox: SW usa credenciales demo aunque no sean las reales
    const swUser = SANDBOX ? (process.env.SW_USER_SANDBOX || "demo") : SW_USER;
    const swPass = SANDBOX ? (process.env.SW_PASS_SANDBOX || "123456789") : SW_PASSWORD;
    const swToken = await swAutenticar(swUser, swPass);
    timbre = await swTimbrar(swToken, xmlBase64);
  } catch (e) {
    return res.status(502).json({ ok: false, error: `Error al timbrar: ${e.message}` });
  }

  // ── 4. Guardar en Supabase ───────────────────────────────────
  const guardRes = await fetch(`${SUPABASE_URL}/rest/v1/rpc/crear_factura`, {
    method: "POST",
    headers: supaHeaders,
    body: JSON.stringify({
      p_session_token:  session_token,
      p_pedido_id:      pedido_id,
      p_rfc:            rfc_receptor.trim().toUpperCase(),
      p_razon_social:   nombre_receptor.trim().toUpperCase(),
      p_uso_cfdi:       uso_cfdi || "G03",
      p_regimen_fiscal: regimen_receptor || "616",
      p_folio_fiscal:   timbre.uuid,
      p_pac_proveedor:  SANDBOX ? "sw_sapien_sandbox" : "sw_sapien",
      p_email:          email_receptor || null,
    }),
  });
  const guardData = await guardRes.json();
  if (!guardData?.success) {
    console.error("[cfdi/timbrar] Error guardando factura:", guardData);
    // No retornar error — el CFDI ya está timbrado, se guardó por lo menos el UUID
  }

  return res.status(200).json({
    ok:    true,
    uuid:  timbre.uuid,
    folio: timbre.uuid,
    sandbox: SANDBOX,
    xmlTimbrado: timbre.xmlTimbrado, // base64
  });
};
