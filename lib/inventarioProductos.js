'use strict';

const { rpc } = require('../api/_lib/supabaseAdmin');

const ABREVIATURAS = {
  CAP: 'CAPSULAS',
  CAPS: 'CAPSULAS',
  TAB: 'TABLETAS',
  TABS: 'TABLETAS',
  COMP: 'COMPRIMIDOS',
  SUSP: 'SUSPENSION',
  SOL: 'SOLUCION',
  INY: 'INYECTABLE',
};

function safeJsonParse(text) {
  const raw = String(text || '').trim();
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch {
    const m = raw.match(/\{[\s\S]*\}/);
    if (m) {
      try {
        return JSON.parse(m[0]);
      } catch {
        return null;
      }
    }
  }
  return null;
}

function parseNumero(val, fallback = 0) {
  if (val == null || val === '') return fallback;
  if (typeof val === 'number' && Number.isFinite(val)) return val;
  const clean = String(val).replace(/[$,\s]/g, '').replace(/[^\d.-]/g, '');
  const n = Number(clean);
  return Number.isFinite(n) ? n : fallback;
}

function parseEntero(val, fallback = 1) {
  const n = parseNumero(val, fallback);
  return Math.max(1, Math.round(n));
}

function normalizarPresentacion(raw) {
  if (!raw) return '';
  let pres = String(raw).toUpperCase().trim();
  for (const [abrev, completo] of Object.entries(ABREVIATURAS)) {
    pres = pres.replace(new RegExp(`\\b${abrev}\\b`, 'g'), completo);
  }
  return pres;
}

function normalizarContenido(raw, unidadHint) {
  if (raw == null || raw === '') {
    return { contenido: null, contenido_unidad: unidadHint || null };
  }
  const s = String(raw).toUpperCase().trim();
  const m = s.match(/(\d+(?:\.\d+)?)\s*([A-Z/]+)?/);
  if (m) {
    return {
      contenido: parseNumero(m[1], null),
      contenido_unidad: (m[2] || unidadHint || '').replace('/', '').trim() || null,
    };
  }
  return { contenido: parseNumero(s, null), contenido_unidad: unidadHint || null };
}

function deducirUnidad(presentacion) {
  const pres = String(presentacion || '').toUpperCase();
  if (pres.includes('CAPSULAS')) return 'CAPS';
  if (pres.includes('TABLETAS') || pres.includes('COMPRIMIDOS')) return 'TAB';
  if (pres.includes('ML') || pres.includes('SUSPENSION') || pres.includes('SOLUCION')) return 'ML';
  if (pres.includes('GRAMOS') || /\bG\b/.test(pres)) return 'G';
  if (pres.includes('AMPOL')) return 'AMP';
  return 'UNIT';
}

function deducirCategoria(nombre) {
  const n = String(nombre || '').toUpperCase();
  const map = {
    AMOXICILINA: 'ANTIBIÓTICOS',
    IBUPROFENO: 'ANALGÉSICOS',
    PARACETAMOL: 'ANALGÉSICOS',
    OMEPRAZOL: 'DIGESTIVOS',
    LORATADINA: 'ANTIHISTAMÍNICOS',
    VITAMINA: 'VITAMINAS',
  };
  for (const [kw, cat] of Object.entries(map)) {
    if (n.includes(kw)) return cat;
  }
  return 'GENERAL';
}

function isoDateOrNull(val) {
  if (!val) return null;
  const s = String(val).trim();
  if (/^\d{4}-\d{2}-\d{2}$/.test(s)) return s;
  const m = s.match(/(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})/);
  if (m) {
    let [, d, mo, y] = m;
    if (y.length === 2) y = `20${y}`;
    return `${y}-${mo.padStart(2, '0')}-${d.padStart(2, '0')}`;
  }
  return null;
}

function defaultCaducidad(fechaCompra) {
  const base = fechaCompra ? new Date(fechaCompra) : new Date();
  if (Number.isNaN(base.getTime())) return null;
  base.setFullYear(base.getFullYear() + 2);
  return base.toISOString().slice(0, 10);
}

function hoyIso() {
  return new Date().toISOString().slice(0, 10);
}

/** Normaliza un producto crudo (Claude, JSON manual o parser texto) al formato interno. */
function normalizarProducto(raw, proveedor) {
  const codigo = String(
    raw.codigo_barras || raw.codigo || raw.barcode || raw.ean || raw.upc || ''
  ).replace(/\D/g, '').trim();

  const nombre = String(raw.nombre || raw.name || raw.descripcion || '').trim().toUpperCase();
  if (!nombre) return null;

  const marca = String(raw.marca || raw.laboratorio || raw.fabricante || '').trim().toUpperCase();
  const presentacion = normalizarPresentacion(raw.presentacion || raw.presentacion_norm || '');
  const unidadHint = String(raw.unidad || raw.contenido_unidad || '').toUpperCase().trim();
  const { contenido, contenido_unidad } = normalizarContenido(
    raw.contenido ?? raw.contenido_norm ?? raw.concentracion,
    unidadHint
  );

  const cantidad = parseEntero(raw.cantidad ?? raw.qty ?? raw.cant, 1);
  const precio = parseNumero(raw.precio ?? raw.precio_unitario ?? raw.precioUnitario, 0);
  const fechaCompra = isoDateOrNull(raw.fecha_compra || raw.fecha) || hoyIso();
  const caducidad = isoDateOrNull(raw.caducidad || raw.fecha_caducidad) || defaultCaducidad(fechaCompra);
  const lote = String(raw.lote || raw.numero_lote || `LOTE-${proveedor.slice(0, 8).replace(/\s/g, '')}-${Date.now().toString().slice(-6)}`).trim();

  return {
    codigo: codigo || `TMP-${Date.now().toString().slice(-8)}-${Math.random().toString(36).slice(2, 6)}`,
    codigo_barras: codigo || null,
    nombre,
    marca,
    presentacion,
    contenido,
    contenido_unidad,
    unidad: raw.unidad || deducirUnidad(presentacion),
    cantidad,
    precio,
    caducidad,
    lote,
    categoria: raw.categoria || deducirCategoria(nombre),
    proveedor,
    fecha_compra: fechaCompra,
  };
}

function productosFromParsedJson(parsed) {
  if (!parsed) return [];
  if (Array.isArray(parsed)) return parsed;
  if (Array.isArray(parsed.productos)) return parsed.productos;
  if (Array.isArray(parsed.items)) return parsed.items;
  if (parsed.nombre) return [parsed];
  return [];
}

/** Parser heurístico para texto plano de tickets PDF (fallback sin IA). */
function extraerProductosDeTexto(texto, proveedor) {
  const lines = String(texto || '')
    .split(/\r?\n/)
    .map((l) => l.trim())
    .filter(Boolean);

  const productos = [];
  const barcodeRe = /\b(\d{8,14})\b/;

  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];
    if (line.length < 4) continue;
    if (/^(total|subtotal|iva|importe|fecha|ticket|folio|rfc|proveedor)/i.test(line)) continue;

    const priceMatch = line.match(/(\d+(?:\.\d{1,2})?)\s*$/);
    if (!priceMatch) continue;

    const precio = parseNumero(priceMatch[1], 0);
    if (precio <= 0 || precio > 500000) continue;

    let resto = line.slice(0, priceMatch.index).trim();
    resto = resto.replace(/\s+/g, ' ').trim();
    if (resto.length < 3) continue;
    if (!/[A-ZÁÉÍÓÚÑ]/i.test(resto)) continue;

    let codigo = '';
    let cantidad = 1;
    const bc = resto.match(barcodeRe);
    if (bc) {
      codigo = bc[1];
      resto = resto.replace(barcodeRe, '').trim();
    } else {
      resto = resto.replace(/^\d+\s+/, '').trim();
    }

    const qtyTail = resto.match(/\s(\d{1,4})$/);
    if (qtyTail) {
      cantidad = parseEntero(qtyTail[1], 1);
      resto = resto.slice(0, qtyTail.index).trim();
    }

    let nombre = resto;
    let presentacion = '';
    const presMatch = resto.match(/^(.+?)\s+(\d+\s*(?:CAPS?|TABS?|ML|GR|COMPRIMIDOS?|TABLETAS?|CAPSULAS?).*)/i);
    if (presMatch) {
      nombre = presMatch[1].trim();
      presentacion = presMatch[2].trim();
    }

    productos.push(
      normalizarProducto(
        {
          codigo,
          nombre,
          presentacion,
          cantidad,
          precio,
        },
        proveedor
      )
    );
  }

  const seen = new Set();
  return productos.filter((p) => {
    if (!p) return false;
    const key = `${p.codigo || ''}|${p.nombre}|${p.precio}|${p.cantidad}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

async function insertarProductos(supabaseUrl, serviceKey, productosRaw, proveedor) {
  const insertados = [];
  const errores = [];

  for (const raw of productosRaw) {
    const p = normalizarProducto(raw, proveedor);
    if (!p) {
      errores.push({ item: raw, error: 'Producto sin nombre válido' });
      continue;
    }

    const payload = {
      p_producto: {
        codigo_barras: p.codigo_barras || p.codigo,
        nombre: p.nombre,
        marca: p.marca || null,
        presentacion: p.presentacion || null,
        contenido: p.contenido != null ? String(p.contenido) : null,
        contenido_unidad: p.contenido_unidad || null,
        categoria: p.categoria || 'GENERAL',
        tipo: 'MEDICAMENTO',
        requiere_receta: false,
        descripcion: [p.nombre, p.presentacion, p.contenido != null ? `${p.contenido} ${p.contenido_unidad || ''}`.trim() : '']
          .filter(Boolean)
          .join(' '),
      },
      p_cantidad: p.cantidad,
      p_proveedor: proveedor,
      p_precio_unitario: p.precio,
      p_fecha_compra: p.fecha_compra,
      p_numero_lote: p.lote,
      p_fecha_caducidad: p.caducidad,
    };

    try {
      const rows = await rpc(serviceKey, supabaseUrl, 'create_producto_con_oferta', payload);
      const row = Array.isArray(rows) ? rows[0] : rows;
      insertados.push({
        ...p,
        producto_id: row?.producto_id ?? null,
        estado: 'insertado',
      });
    } catch (e) {
      const msg = e?.message || String(e);
      errores.push({ producto: p.nombre, codigo: p.codigo, error: msg });
    }
  }

  return { insertados, errores };
}

function isAnthropicCreditError(status, bodyText) {
  const t = String(bodyText || '').toLowerCase();
  if (status === 402) return true;
  if (status === 429 && (t.includes('credit') || t.includes('billing') || t.includes('balance'))) return true;
  return (
    t.includes('credit balance') ||
    t.includes('insufficient') ||
    t.includes('billing') ||
    t.includes('purchase credits')
  );
}

const CLAUDE_EXTRACT_PROMPT = `Eres un extractor de productos farmacéuticos desde tickets/facturas de compra en México.

Analiza el PDF y devuelve ÚNICAMENTE un JSON válido (sin markdown) con esta forma:
{
  "productos": [
    {
      "codigo": "7501090131234",
      "nombre": "AMOXICILINA",
      "marca": "FARMALAB",
      "presentacion": "40 CAPSULAS",
      "contenido": "500",
      "unidad": "MG",
      "precio": 85.50,
      "cantidad": 2,
      "caducidad": "2025-12-15",
      "lote": "A123456"
    }
  ]
}

Reglas:
- codigo = código de barras si aparece (8-14 dígitos), si no null
- nombre en MAYÚSCULAS, sin precio ni cantidad en el nombre
- precio = precio unitario en MXN (número)
- cantidad = unidades compradas (entero, mínimo 1)
- caducidad y lote si aparecen; si no, null
- Incluye TODOS los productos del documento
- Si no hay productos legibles, devuelve {"productos":[]}`;

async function extraerConClaude(apiKey, pdfBase64, options = {}) {
  const prompt = options.prompt || CLAUDE_EXTRACT_PROMPT;
  const maxTokens = options.max_tokens || 8192;
  const resp = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: process.env.ANTHROPIC_MODEL || options.model || 'claude-sonnet-4-20250514',
      max_tokens: maxTokens,
      messages: [
        {
          role: 'user',
          content: [
            {
              type: 'document',
              source: {
                type: 'base64',
                media_type: 'application/pdf',
                data: pdfBase64,
              },
            },
            { type: 'text', text: prompt },
          ],
        },
      ],
    }),
  });

  const bodyText = await resp.text();
  if (!resp.ok) {
    const err = new Error(`claude_error:${resp.status}:${bodyText.slice(0, 300)}`);
    err.status = resp.status;
    err.creditError = isAnthropicCreditError(resp.status, bodyText);
    throw err;
  }

  let data;
  try {
    data = JSON.parse(bodyText);
  } catch {
    throw new Error('claude_invalid_response');
  }

  const textBlock = (data.content || []).find((b) => b.type === 'text');
  const parsed = safeJsonParse(textBlock?.text || '');
  return productosFromParsedJson(parsed);
}

async function extraerTextoPdf(_pdfBuffer) {
  // Sin pdf-parse en el bundle (rompe deploy Vercel). Fallback texto deshabilitado.
  return '';
}

module.exports = {
  normalizarProducto,
  productosFromParsedJson,
  extraerProductosDeTexto,
  insertarProductos,
  extraerConClaude,
  extraerTextoPdf,
  isAnthropicCreditError,
  safeJsonParse,
};
