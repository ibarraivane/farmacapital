'use strict';

const {
  getSupabaseAdminConfig,
  validateEmployeeSession,
} = require('../api/_lib/supabaseAdmin');
const {
  productosFromParsedJson,
  extraerProductosDeTexto,
  insertarProductos,
  extraerConClaude,
  extraerTextoPdf,
  isAnthropicCreditError,
  renglonDesdeRaw,
} = require('./inventarioProductos');

async function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

function decodeBase64Pdf(archivoBase64) {
  let raw = String(archivoBase64 || '').trim();
  if (!raw) return null;
  const dataUrlMatch = raw.match(/^data:application\/pdf;base64,(.+)$/i);
  if (dataUrlMatch) raw = dataUrlMatch[1];
  raw = raw.replace(/\s/g, '');
  try {
    const buf = Buffer.from(raw, 'base64');
    if (!buf.length) return null;
    if (buf.slice(0, 4).toString() !== '%PDF') {
      return null;
    }
    return buf;
  } catch {
    return null;
  }
}

async function extraerProductosDelPdf(pdfBuffer, proveedor, options = {}) {
  const anthropicKey = String(process.env.ANTHROPIC_API_KEY || process.env.REACT_APP_ANTHROPIC_API_KEY || '').trim();
  const pdfBase64 = pdfBuffer.toString('base64');
  const avisos = [];
  const preview = options.preview === true;

  if (anthropicKey) {
    try {
      const extracted = await extraerConClaude(anthropicKey, pdfBase64, { ticketCompleto: preview });
      if (preview) {
        const productos = productosFromParsedJson(extracted);
        if (productos.length) {
          return {
            productos,
            metodo: 'claude',
            avisos,
            folio: extracted?.folio || null,
            total: extracted?.total ?? null,
            proveedor: extracted?.proveedor || proveedor,
          };
        }
      } else if (Array.isArray(extracted) && extracted.length) {
        return { productos: extracted, metodo: 'claude', avisos };
      }
      avisos.push('Claude no detectó productos; se intenta extracción por texto.');
    } catch (e) {
      if (e.creditError || isAnthropicCreditError(e.status, e.message)) {
        avisos.push('Créditos insuficientes en Anthropic. Usando extracción por texto del PDF.');
      } else {
        avisos.push(`Claude falló (${e.message}). Usando extracción por texto.`);
      }
    }
  } else {
    avisos.push('ANTHROPIC_API_KEY no configurada. Usando extracción por texto del PDF.');
  }

  const texto = await extraerTextoPdf(pdfBuffer);
  if (!texto.trim()) {
    return { productos: [], metodo: 'texto', avisos: [...avisos, 'No se pudo leer texto del PDF.'] };
  }

  const productos = extraerProductosDeTexto(texto, proveedor);
  return { productos, metodo: 'texto', avisos };
}

async function inventarioProcesarPdfHandler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ error: 'Supabase no configurado en el servidor' });
  }

  try {
    const body = await safeJson(req);
    const sessionToken = String(body?.session_token || '').trim();
    const proveedor = String(body?.proveedor || 'EQUILIBRIO FARMACEÚTICO').trim() || 'EQUILIBRIO FARMACEÚTICO';

    const sessionOk = await validateEmployeeSession(supabaseUrl, serviceKey, sessionToken);
    if (!sessionOk) {
      return res.status(401).json({ error: 'Sesión no válida o expirada' });
    }

    const soloExtraer = body?.solo_extraer === true || body?.modo === 'preview';
    let productosRaw = productosFromParsedJson(body?.productos != null ? { productos: body.productos } : null);
    let metodoExtraccion = 'json';
    const avisos = [];
    let folioExtra = body?.folio || null;
    let totalExtra = body?.total ?? null;
    let proveedorDoc = proveedor;

    if (!productosRaw.length) {
      const pdfBuffer = decodeBase64Pdf(body?.archivo_base64);
      if (!pdfBuffer) {
        return res.status(400).json({
          error: 'archivo_base64 requerido (PDF válido en base64) o arreglo productos',
        });
      }

      const extracted = await extraerProductosDelPdf(pdfBuffer, proveedor, { preview: soloExtraer });
      productosRaw = extracted.productos;
      metodoExtraccion = extracted.metodo;
      avisos.push(...extracted.avisos);
      if (extracted.folio) folioExtra = extracted.folio;
      if (extracted.total != null) totalExtra = extracted.total;
      if (extracted.proveedor) proveedorDoc = extracted.proveedor;

      if (!productosRaw.length) {
        const creditMsg = avisos.some((a) => a.includes('Créditos insuficientes'));
        return res.status(422).json({
          error: creditMsg
            ? 'Créditos insuficientes en Anthropic y el PDF no pudo parsearse por texto. Sube el CSV del ticket o recarga créditos.'
            : 'No se detectaron productos en el PDF. Verifica que sea un ticket legible o carga el CSV.',
          avisos,
          extraccion: metodoExtraccion,
        });
      }
    }

    if (soloExtraer) {
      const renglones = productosRaw.map(renglonDesdeRaw).filter(Boolean);
      return res.status(200).json({
        ok: true,
        renglones,
        folio: folioExtra,
        total: totalExtra,
        proveedor: proveedorDoc,
        extraccion: metodoExtraccion,
        avisos: avisos.length ? avisos : undefined,
      });
    }

    const { insertados, errores } = await insertarProductos(
      supabaseUrl,
      serviceKey,
      productosRaw,
      proveedor
    );

    if (!insertados.length && errores.length) {
      const firstErr = errores[0]?.error || 'Error desconocido';
      const rpcMissing = errores.every((e) => String(e.error || '').includes('create_producto_con_oferta'));
      return res.status(502).json({
        error: rpcMissing
          ? 'RPC create_producto_con_oferta no existe en Supabase. Ejecuta sql/schema_inventario_v2_con_proveedores.sql'
          : `No se insertó ningún producto: ${firstErr}`,
        errores,
        avisos,
        extraccion: metodoExtraccion,
      });
    }

    const mensaje = errores.length
      ? `${insertados.length} productos cargados (${errores.length} con error)`
      : `${insertados.length} productos cargados exitosamente`;

    return res.status(200).json({
      success: true,
      productos: insertados,
      insertados: insertados.length,
      mensaje,
      extraccion: metodoExtraccion,
      avisos: avisos.length ? avisos : undefined,
      errores: errores.length ? errores : undefined,
    });
  } catch (error) {
    console.error('[procesar-pdf] Error:', error);
    return res.status(500).json({
      error: 'Error procesando PDF',
      detalle: error?.message || String(error),
    });
  }
}

module.exports = { inventarioProcesarPdfHandler };
