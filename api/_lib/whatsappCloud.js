'use strict';

const crypto = require('crypto');

/** Graph API — override con WHATSAPP_GRAPH_VERSION si Meta depreca la versión por defecto. */
const DEFAULT_GRAPH_VERSION = 'v21.0';

function trimEnv(name) {
  return String(process.env[name] || '')
    .replace(/^\uFEFF/, '')
    .trim()
    .replace(/^["']|["']$/g, '');
}

/**
 * Configuración desacoplada: cambiar token / Phone Number ID en Vercel
 * sin tocar la lógica de envío ni webhooks.
 */
function getWhatsAppCloudConfig() {
  const accessToken =
    trimEnv('WHATSAPP_ACCESS_TOKEN') || trimEnv('META_WHATSAPP_TOKEN');
  const phoneNumberId =
    trimEnv('WHATSAPP_PHONE_NUMBER_ID') || trimEnv('META_WHATSAPP_PHONE_ID');
  const businessAccountId =
    trimEnv('WHATSAPP_BUSINESS_ACCOUNT_ID') || trimEnv('META_WHATSAPP_BUSINESS_ACCOUNT_ID');
  const verifyToken = trimEnv('WHATSAPP_VERIFY_TOKEN');
  const appSecret =
    trimEnv('WHATSAPP_APP_SECRET') || trimEnv('META_APP_SECRET');
  const graphVersion = trimEnv('WHATSAPP_GRAPH_VERSION') || DEFAULT_GRAPH_VERSION;
  const internalSecret =
    trimEnv('WHATSAPP_INTERNAL_SECRET') || trimEnv('WHATSAPP_SEND_SECRET');

  return {
    accessToken,
    phoneNumberId,
    businessAccountId,
    verifyToken,
    appSecret,
    graphVersion,
    internalSecret,
    isConfigured: Boolean(accessToken && phoneNumberId),
  };
}

/** Meta espera códigos ISO (es_MX), no etiquetas UI («Spanish (MEX)»). */
function normalizeTemplateLanguage(raw) {
  const s = String(raw || '').trim();
  if (!s) return 'es_MX';
  const lower = s.toLowerCase();
  const alpha = lower.replace(/[^a-z]/g, '');
  if (alpha.includes('mex') || alpha === 'esmx') return 'es_MX';
  if (alpha === 'es' || alpha === 'spanish') return 'es';
  if (/^es_[a-z]{2}$/i.test(s)) {
    const [, region] = s.split('_');
    return `es_${region.toUpperCase()}`;
  }
  if (/^es-[a-z]{2}$/i.test(s)) {
    const [, region] = s.split('-');
    return `es_${region.toUpperCase()}`;
  }
  if (/^[a-z]{2}_[A-Z]{2}$/.test(s)) return s;
  return 'es_MX';
}

/** Plantillas Utility (Meta). Defaults = WHATSAPP_META_SNAPSHOT.md; override con WHATSAPP_TEMPLATE_* si hace falta. */
function getWhatsAppTemplateConfig() {
  const language = normalizeTemplateLanguage(trimEnv('WHATSAPP_TEMPLATE_LANGUAGE'));
  const fallbackText = trimEnv('WHATSAPP_TEMPLATE_FALLBACK_TEXT').toLowerCase() === 'true';
  return {
    language,
    fallbackText,
    pedidoConfirmado: trimEnv('WHATSAPP_TEMPLATE_PEDIDO_CONFIRMADO') || 'pedido_confirmado',
    pedidoPago:
      trimEnv('WHATSAPP_TEMPLATE_PEDIDO_PAGO') ||
      trimEnv('WHATSAPP_TEMPLATE_PEDIDO_PAGO_APROBADO') ||
      'pedido_pago_aprobado',
    pedidoListo: trimEnv('WHATSAPP_TEMPLATE_PEDIDO_LISTO') || 'pedido_listo',
    citaConfirmacion:
      trimEnv('WHATSAPP_TEMPLATE_CITA') ||
      trimEnv('WHATSAPP_TEMPLATE_CITA_CONFIRMACION') ||
      'cita_confirmacion',
    /** Activa botón URL en plantilla (requiere botón «Ver ticket» en Meta). */
    pedidoUrlButton: trimEnv('WHATSAPP_TEMPLATE_PEDIDO_URL_BUTTON').toLowerCase() === 'true',
  };
}

function normalizeTemplateParams(params) {
  if (!Array.isArray(params)) return [];
  return params.map((p) => ({
    type: 'text',
    text: String(p ?? '').slice(0, 1024),
  }));
}

function resolveWhatsAppProvider() {
  const pref = trimEnv('WHATSAPP_PROVIDER').toLowerCase();
  if (pref === 'twilio') return 'twilio';
  if (pref === 'meta') return 'meta';
  const cfg = getWhatsAppCloudConfig();
  if (cfg.isConfigured) return 'meta';
  return 'twilio';
}

function digitsOnly(v) {
  return String(v || '').replace(/\D/g, '');
}

function extractMetaErrorCode(detail) {
  try {
    const parsed = typeof detail === 'string' ? JSON.parse(detail) : detail;
    return parsed?.error?.code ?? null;
  } catch {
    return null;
  }
}

/** Últimos 10 dígitos de un teléfono MX. */
function localMx10(input) {
  const digits = digitsOnly(input);
  return digits.length >= 10 ? digits.slice(-10) : '';
}

/**
 * Candidatos `to` para Meta Cloud API (MX).
 * - 521… = entrega móvil en producción
 * - 52…  = formato de la lista de prueba en Meta Developer (Getting Started)
 */
function getWhatsAppMxCandidates(input) {
  const digits = digitsOnly(input);
  if (!digits) return [];

  if (digits.length === 11 && digits.startsWith('1')) {
    return [digits];
  }

  const local = localMx10(digits);
  if (local.length !== 10) {
    return digits.length >= 11 ? [digits] : [];
  }

  const with521 = `521${local}`;
  const with52 = `52${local}`;
  return with521 === with52 ? [with521] : [with521, with52];
}

/**
 * Normaliza a E.164 sin '+' (formato Meta Cloud API en `to`).
 * Preferimos 521… (móvil MX en producción); getWhatsAppMxCandidates reintenta 52… si Meta lo pide.
 */
function normalizePhoneE164(input, { defaultCountryCode = '52' } = {}) {
  const candidates = getWhatsAppMxCandidates(input);
  if (!candidates.length) return null;
  return candidates[0];
}

function redactPhone(e164) {
  const d = digitsOnly(e164);
  if (d.length < 4) return '***';
  return `***${d.slice(-4)}`;
}

function graphUrl(path, graphVersion) {
  const ver = graphVersion || getWhatsAppCloudConfig().graphVersion;
  const p = String(path || '').replace(/^\//, '');
  return `https://graph.facebook.com/${ver}/${p}`;
}

function templateRowLanguage(row) {
  const lang = row?.language;
  if (lang && typeof lang === 'object') {
    return String(lang.code || lang.language || '').trim();
  }
  return String(lang || '').trim();
}

/** WABA real vinculado al Phone Number ID (evita mismatch con WHATSAPP_BUSINESS_ACCOUNT_ID en Vercel). */
async function fetchWabaIdForPhoneNumber({ phoneNumberId, token, graphVersion } = {}) {
  const id = String(phoneNumberId || '').trim();
  if (!id || !token) return null;

  try {
    const resp = await fetch(
      graphUrl(`${encodeURIComponent(id)}?fields=whatsapp_business_account`, graphVersion),
      { headers: { Authorization: `Bearer ${token}` } }
    );
    const data = await resp.json().catch(() => ({}));
    if (!resp.ok) return null;
    const waba = data?.whatsapp_business_account;
    if (waba && typeof waba === 'object' && waba.id) return String(waba.id).trim();
    if (waba) return String(waba).trim();
    return null;
  } catch {
    return null;
  }
}

/** Lista plantillas del WABA (sin filtrar status — «calidad pendiente» sigue siendo enviable). */
async function fetchWabaMessageTemplates({ wabaId, token, graphVersion }) {
  const waba = String(wabaId || '').trim();
  if (!waba || !token) return { ok: false, rows: [], error: 'missing_waba_or_token' };

  const rows = [];
  let after = '';
  for (let page = 0; page < 5; page += 1) {
    const qs = new URLSearchParams({
      fields: 'name,language,status,category',
      limit: '100',
    });
    if (after) qs.set('after', after);

    const resp = await fetch(
      graphUrl(`${encodeURIComponent(waba)}/message_templates?${qs}`, graphVersion),
      { headers: { Authorization: `Bearer ${token}` } }
    );
    const data = await resp.json().catch(() => ({}));
    if (!resp.ok) {
      return {
        ok: false,
        rows,
        error: data?.error?.message || `list_templates_http_${resp.status}`,
        code: data?.error?.code ?? null,
      };
    }
    if (Array.isArray(data?.data)) rows.push(...data.data);
    after = data?.paging?.cursors?.after || '';
    if (!after) break;
  }

  return { ok: true, rows };
}

/** Resuelve nombre e idioma exactos en el WABA antes de enviar (evita 132001). */
async function resolveTemplateOnWaba({ wabaId, templateName, token, graphVersion }) {
  const wanted = String(templateName || '').trim().toLowerCase();
  if (!wanted) return { ok: false, reason: 'missing_template_name' };

  const primaryWaba = String(wabaId || '').trim();
  const scanWabas = [...new Set([
    primaryWaba,
    '1575449287233472',
    '2277703916307084',
  ].filter(Boolean))];
  let lastListError = null;
  const availableByWaba = {};

  for (const waba of scanWabas) {
    const listed = await fetchWabaMessageTemplates({ wabaId: waba, token, graphVersion });
    if (!listed.ok) {
      lastListError = listed.error;
      continue;
    }
    const rows = listed.rows || [];
    availableByWaba[waba] = [...new Set(rows.map((r) => String(r?.name || '').trim()).filter(Boolean))];
    const matches = rows.filter((r) => String(r?.name || '').trim().toLowerCase() === wanted);
    if (!matches.length) continue;

    if (waba !== primaryWaba) {
      return {
        ok: false,
        reason: 'template_on_other_waba',
        wanted: templateName,
        templateWabaId: waba,
        phoneWabaId: primaryWaba,
        available: availableByWaba[waba] || [],
      };
    }

    const preferred =
      matches.find((r) => String(r?.status || '').toUpperCase() === 'APPROVED') || matches[0];
    const rawLang = templateRowLanguage(preferred);
    const langs = [...new Set([
      rawLang,
      normalizeTemplateLanguage(rawLang),
      'es_MX',
      'es',
    ].filter(Boolean))];

    return {
      ok: true,
      name: String(preferred.name || templateName).trim(),
      languages: langs,
      status: preferred?.status || null,
      wabaId: waba,
      available: availableByWaba[waba] || [],
    };
  }

  return {
    ok: false,
    reason: lastListError ? 'template_list_failed' : 'template_not_on_waba',
    wanted: templateName,
    wabaId: primaryWaba,
    available: availableByWaba[primaryWaba] || [],
    availableByWaba,
    detail: lastListError || null,
  };
}

function parseMetaSendSuccess(data, toE164) {
  const messageId = data?.messages?.[0]?.id || null;
  const contact = Array.isArray(data?.contacts) ? data.contacts[0] : null;
  if (!messageId) {
    return {
      sent: false,
      reason: 'meta_no_message_id',
      detail: sanitizeMetaError(data),
      to: redactPhone(toE164),
    };
  }
  return {
    sent: true,
    messageId,
    waId: contact?.wa_id ? redactPhone(contact.wa_id) : null,
    input: contact?.input ? redactPhone(contact.input) : redactPhone(toE164),
  };
}

function sanitizeMetaError(detail) {
  if (!detail) return null;
  try {
    const raw = typeof detail === 'string' ? detail : JSON.stringify(detail);
    return raw
      .replace(/Bearer\s+[A-Za-z0-9._-]+/gi, 'Bearer ***')
      .replace(/"access_token"\s*:\s*"[^"]+"/gi, '"access_token":"***"')
      .slice(0, 500);
  } catch {
    return 'meta_error';
  }
}

/**
 * Envío de texto libre (solo dentro de ventana 24h o números de prueba Meta).
 * Fase 2+: plantillas Utility/Marketing vía sendWhatsAppTemplate().
 */
async function sendWhatsAppText({ to, text, phoneNumberId, accessToken, graphVersion } = {}) {
  const cfg = getWhatsAppCloudConfig();
  const token = accessToken || cfg.accessToken;
  const fromId = phoneNumberId || cfg.phoneNumberId;
  const bodyText = String(text || '').trim();

  if (!token || !fromId) {
    return { sent: false, reason: 'whatsapp_cloud_not_configured' };
  }
  if (!bodyText) {
    return { sent: false, reason: 'empty_message' };
  }

  const candidates = getWhatsAppMxCandidates(to);
  if (!candidates.length) {
    return { sent: false, reason: 'invalid_phone' };
  }

  let lastResult = null;
  for (const toE164 of candidates) {
    const resp = await fetch(graphUrl(`${encodeURIComponent(fromId)}/messages`, graphVersion), {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        messaging_product: 'whatsapp',
        to: toE164,
        type: 'text',
        text: { body: bodyText.slice(0, 4096) },
      }),
    });

    let data = null;
    try {
      data = await resp.json();
    } catch {
      data = null;
    }

    if (resp.ok) {
      const parsed = parseMetaSendSuccess(data, toE164);
      if (!parsed.sent) return parsed;
      return {
        ...parsed,
        to: redactPhone(toE164),
        phoneFormat: toE164.startsWith('521') ? '521' : '52',
      };
    }

    lastResult = {
      sent: false,
      reason: 'meta_provider_error',
      status: resp.status,
      detail: sanitizeMetaError(data),
      to: redactPhone(toE164),
    };

    const code = data?.error?.code;
    if (code !== 131030 && code !== 131031) break;
  }

  return lastResult;
}

/**
 * Plantilla Utility/Marketing (mensajes iniciados por la empresa).
 * `bodyParameters` / `headerParameters`: arrays de strings → {{1}}, {{2}}, …
 */
async function sendWhatsAppTemplate({
  to,
  templateName,
  languageCode,
  bodyParameters,
  headerParameters,
  buttonUrlSuffix,
  buttonIndex = '0',
  phoneNumberId,
  accessToken,
  graphVersion,
} = {}) {
  const cfg = getWhatsAppCloudConfig();
  const tplCfg = getWhatsAppTemplateConfig();
  const token = accessToken || cfg.accessToken;
  const fromId = phoneNumberId || cfg.phoneNumberId;
  const requestedName = String(templateName || '').trim();

  if (!token || !fromId) {
    return { sent: false, reason: 'whatsapp_cloud_not_configured' };
  }
  if (!requestedName) {
    return { sent: false, reason: 'missing_template_name' };
  }
  const candidates = getWhatsAppMxCandidates(to);
  if (!candidates.length) {
    return { sent: false, reason: 'invalid_phone' };
  }

  const gv = graphVersion || cfg.graphVersion;
  const phoneWabaId = await fetchWabaIdForPhoneNumber({
    phoneNumberId: fromId,
    token,
    graphVersion: gv,
  });
  const envWabaId = cfg.businessAccountId;
  const effectiveWabaId = phoneWabaId || envWabaId;

  if (!effectiveWabaId) {
    return {
      sent: false,
      reason: 'missing_waba_id',
      detail: 'Falta WHATSAPP_BUSINESS_ACCOUNT_ID=1575449287233472 en Vercel',
    };
  }

  if (phoneWabaId && envWabaId && phoneWabaId !== envWabaId) {
    console.warn('[whatsapp] waba_env_mismatch', JSON.stringify({
      phoneWabaId,
      envWabaId,
      phoneNumberId: fromId,
    }));
  }

  const resolved = await resolveTemplateOnWaba({
    wabaId: effectiveWabaId,
    templateName: requestedName,
    token,
    graphVersion: gv,
  });

  if (resolved.ok === false && resolved.reason === 'template_not_on_waba') {
    const other = resolved.availableByWaba?.['2277703916307084'] || [];
    const hint = other.length
      ? `Tus plantillas están en el WABA viejo (2277703916307084): ${other.join(', ')}. `
        + 'Créalas de nuevo en WhatsApp Manager con el WABA 1575449287233472 (API Setup → Phone ID 1320112064512676).'
      : 'pedido_confirmado no está en el WABA del número. Créala en WhatsApp Manager '
        + 'vinculado al Phone ID 1320112064512676 (WABA 1575449287233472).';
    return {
      sent: false,
      reason: 'meta_template_not_on_waba',
      detail: JSON.stringify({
        wanted: requestedName,
        wabaId: effectiveWabaId,
        phoneWabaId: phoneWabaId || null,
        envWabaId: envWabaId || null,
        phoneNumberId: fromId,
        available: resolved.available || [],
        templatesOnLegacyWaba: other,
        hint,
      }),
    };
  }

  if (resolved.ok === false && resolved.reason === 'template_on_other_waba') {
    return {
      sent: false,
      reason: 'meta_template_wrong_waba',
      detail: JSON.stringify({
        wanted: requestedName,
        templateWabaId: resolved.templateWabaId,
        phoneWabaId: resolved.phoneWabaId,
        available: resolved.available || [],
        hint:
          'Las plantillas están en otro WABA de Meta (probablemente 2277703916307084). '
          + 'Abre business.facebook.com/wa/manage/message-templates/, elige el WABA 1575449287233472 '
          + 'y crea pedido_confirmado, pedido_pago_aprobado, pedido_listo y cita_confirmacion en es_MX.',
      }),
    };
  }

  if (resolved.ok === false && resolved.reason === 'template_list_failed') {
    console.warn('[whatsapp] template list failed, attempting send anyway', JSON.stringify({
      wanted: requestedName,
      wabaId: effectiveWabaId,
      metaError: resolved.detail || null,
    }));
  }

  const sendName = resolved.ok ? resolved.name : requestedName;
  let langCandidates = resolved.ok
    ? [...resolved.languages]
    : [normalizeTemplateLanguage(languageCode || tplCfg.language), 'es_MX', 'es'];

  if (resolved.ok) {
    console.log('[whatsapp] template resolved', JSON.stringify({
      requested: requestedName,
      sendName,
      langs: langCandidates,
      status: resolved.status,
    }));
  }

  const components = [];
  const headerParams = normalizeTemplateParams(headerParameters);
  const bodyParams = normalizeTemplateParams(bodyParameters);
  if (headerParams.length) {
    components.push({ type: 'header', parameters: headerParams });
  }
  if (bodyParams.length) {
    components.push({ type: 'body', parameters: bodyParams });
  }
  const urlSuffix = String(buttonUrlSuffix || '').trim();
  if (urlSuffix && tplCfg.pedidoUrlButton) {
    components.push({
      type: 'button',
      sub_type: 'url',
      index: String(buttonIndex),
      parameters: [{ type: 'text', text: urlSuffix.slice(0, 2000) }],
    });
  }

  const cfgLang = normalizeTemplateLanguage(languageCode || tplCfg.language);
  if (!resolved.ok) {
    langCandidates.push(cfgLang);
    langCandidates = [...new Set(langCandidates.filter(Boolean))];
  }

  let lastResult = null;
  for (const toE164 of candidates) {
    for (const lang of [...new Set(langCandidates)]) {
      const payload = {
        messaging_product: 'whatsapp',
        to: toE164,
        type: 'template',
        template: {
          name: sendName,
          language: { code: lang },
        },
      };
      if (components.length) {
        payload.template.components = components;
      }

      const resp = await fetch(graphUrl(`${encodeURIComponent(fromId)}/messages`, graphVersion), {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
      });

      let data = null;
      try {
        data = await resp.json();
      } catch {
        data = null;
      }

      if (resp.ok) {
        const parsed = parseMetaSendSuccess(data, toE164);
        if (!parsed.sent) {
          lastResult = {
            ...parsed,
            reason: 'meta_template_error',
            status: resp.status,
            language: lang,
          };
          break;
        }
        return {
          ...parsed,
          to: redactPhone(toE164),
          template: sendName,
          language: lang,
          phoneFormat: toE164.startsWith('521') ? '521' : '52',
        };
      }

      lastResult = {
        sent: false,
        reason: 'meta_template_error',
        status: resp.status,
        detail: sanitizeMetaError(data),
        to: redactPhone(toE164),
        language: lang,
      };

      const code = data?.error?.code;
      if (code === 131030 || code === 131031) {
        break;
      }

      const errBlob = String(sanitizeMetaError(data) || '').toLowerCase();
      const languageMismatch =
        errBlob.includes('language') ||
        errBlob.includes('locale') ||
        errBlob.includes('translation');
      if (!languageMismatch) break;
    }

    const code = extractMetaErrorCode(lastResult?.detail);
    if (code !== 131030 && code !== 131031) break;
  }

  return lastResult;
}

/**
 * Intenta plantilla; si falla y WHATSAPP_TEMPLATE_FALLBACK_TEXT≠false, envía texto libre.
 */
async function sendWhatsAppSmart({
  to,
  text,
  templateName,
  templateLanguage,
  bodyParameters,
  headerParameters,
  buttonUrlSuffix,
  buttonIndex,
  allowTextFallback,
  phoneNumberId,
  accessToken,
  graphVersion,
} = {}) {
  const tplCfg = getWhatsAppTemplateConfig();
  const name = String(templateName || '').trim();
  const bodyText = String(text || '').trim();
  const mayFallback =
    allowTextFallback !== false && tplCfg.fallbackText && Boolean(bodyText);

  if (name) {
    const tplResult = await sendWhatsAppTemplate({
      to,
      templateName: name,
      languageCode: templateLanguage,
      bodyParameters,
      headerParameters,
      buttonUrlSuffix,
      buttonIndex,
      phoneNumberId,
      accessToken,
      graphVersion,
    });
    if (tplResult.sent) {
      return { ...tplResult, via: 'template' };
    }
    console.warn('[whatsapp] template failed:', name, tplResult.detail || tplResult.reason);
    if (!mayFallback) {
      return { ...tplResult, via: 'template_failed' };
    }
    console.warn('[whatsapp] falling back to free text (may fail with 131047 outside 24h window)');
    const textResult = await sendWhatsAppText({
      to,
      text: bodyText,
      phoneNumberId,
      accessToken,
      graphVersion,
    });
    return {
      ...textResult,
      via: textResult.sent ? 'text_fallback' : textResult.reason,
      templateError: tplResult.reason,
      templateDetail: tplResult.detail || undefined,
    };
  }

  if (!bodyText) {
    return { sent: false, reason: 'empty_message' };
  }

  const textResult = await sendWhatsAppText({
    to,
    text: bodyText,
    phoneNumberId,
    accessToken,
    graphVersion,
  });
  return { ...textResult, via: 'text' };
}

function verifyWebhookSubscribe(query, verifyToken) {
  const mode = String(query?.['hub.mode'] || query?.hub?.mode || '').trim();
  const token = String(query?.['hub.verify_token'] || query?.hub?.verify_token || '').trim();
  const challenge = query?.['hub.challenge'] ?? query?.hub?.challenge;

  if (mode !== 'subscribe') {
    return { ok: false, reason: 'invalid_mode' };
  }
  if (!verifyToken || token !== verifyToken) {
    return { ok: false, reason: 'invalid_verify_token' };
  }
  if (challenge == null || challenge === '') {
    return { ok: false, reason: 'missing_challenge' };
  }
  return { ok: true, challenge: String(challenge) };
}

function verifyMetaSignature(rawBody, signatureHeader, appSecret) {
  if (!appSecret) {
    return { ok: false, reason: 'missing_app_secret' };
  }
  const sig = String(signatureHeader || '').trim();
  if (!sig.startsWith('sha256=')) {
    return { ok: false, reason: 'missing_signature' };
  }

  const expected =
    'sha256=' + crypto.createHmac('sha256', appSecret).update(rawBody).digest('hex');

  try {
    const a = Buffer.from(sig, 'utf8');
    const b = Buffer.from(expected, 'utf8');
    if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
      return { ok: false, reason: 'invalid_signature' };
    }
  } catch {
    return { ok: false, reason: 'invalid_signature' };
  }

  return { ok: true };
}

function parseWebhookPayload(body) {
  const events = [];
  if (!body || body.object !== 'whatsapp_business_account') {
    return events;
  }

  for (const entry of body.entry || []) {
    const wabaId = entry?.id || null;
    for (const change of entry.changes || []) {
      const value = change?.value || {};
      const phoneNumberId = value?.metadata?.phone_number_id || null;
      const field = change?.field || null;

      for (const msg of value.messages || []) {
        events.push({
          kind: 'message',
          wabaId,
          phoneNumberId,
          field,
          messageId: msg?.id || null,
          from: msg?.from ? redactPhone(msg.from) : null,
          type: msg?.type || null,
          timestamp: msg?.timestamp || null,
        });
      }

      for (const st of value.statuses || []) {
        events.push({
          kind: 'status',
          wabaId,
          phoneNumberId,
          field,
          messageId: st?.id || null,
          status: st?.status || null,
          recipient: st?.recipient_id ? redactPhone(st.recipient_id) : null,
          timestamp: st?.timestamp || null,
          errors: Array.isArray(st?.errors)
            ? st.errors.map((e) => ({
                code: e?.code ?? null,
                title: e?.title ?? null,
              }))
            : null,
        });
      }
    }
  }

  return events;
}

function logWebhookEvents(events) {
  for (const ev of events) {
    if (ev.kind === 'status' && ev.status === 'failed') {
      console.error('[whatsapp-delivery-failed]', JSON.stringify(ev));
    } else {
      console.log('[whatsapp-webhook]', JSON.stringify(ev));
    }
  }
}

function authorizeInternalSend(req, body) {
  const cfg = getWhatsAppCloudConfig();
  const auth = String(req.headers.authorization || req.headers.Authorization || '');
  const bearer = auth.replace(/^Bearer\s+/i, '').trim();

  if (cfg.internalSecret && bearer && bearer === cfg.internalSecret) {
    return { ok: true, via: 'internal_secret' };
  }

  const headerSecret = String(req.headers['x-whatsapp-internal-secret'] || '').trim();
  if (cfg.internalSecret && headerSecret && headerSecret === cfg.internalSecret) {
    return { ok: true, via: 'internal_header' };
  }

  return { ok: false, reason: 'unauthorized' };
}

/** Diagnóstico: WABA del Phone ID vs plantillas en cada WABA conocido. */
async function diagnoseWhatsAppTemplates() {
  const cfg = getWhatsAppCloudConfig();
  if (!cfg.isConfigured) {
    return { ok: false, reason: 'whatsapp_cloud_not_configured' };
  }

  const phoneWabaId = await fetchWabaIdForPhoneNumber({
    phoneNumberId: cfg.phoneNumberId,
    token: cfg.accessToken,
    graphVersion: cfg.graphVersion,
  });
  const effectiveWabaId = phoneWabaId || cfg.businessAccountId || null;
  const wabasToScan = [...new Set([
    effectiveWabaId,
    cfg.businessAccountId,
    phoneWabaId,
    '1575449287233472',
    '2277703916307084',
  ].filter(Boolean))];

  const templatesByWaba = {};
  for (const waba of wabasToScan) {
    const listed = await fetchWabaMessageTemplates({
      wabaId: waba,
      token: cfg.accessToken,
      graphVersion: cfg.graphVersion,
    });
    templatesByWaba[waba] = {
      ok: listed.ok,
      error: listed.error || null,
      names: listed.ok
        ? [...new Set((listed.rows || []).map((r) => String(r?.name || '').trim()).filter(Boolean))]
        : [],
    };
  }

  const resolved = effectiveWabaId
    ? await resolveTemplateOnWaba({
        wabaId: effectiveWabaId,
        templateName: getWhatsAppTemplateConfig().pedidoConfirmado,
        token: cfg.accessToken,
        graphVersion: cfg.graphVersion,
      })
    : { ok: false, reason: 'missing_waba' };

  return {
    ok: true,
    phoneNumberId: cfg.phoneNumberId,
    envWabaId: cfg.businessAccountId || null,
    phoneWabaId,
    effectiveWabaId,
    wabaMismatch: Boolean(
      phoneWabaId && cfg.businessAccountId && phoneWabaId !== cfg.businessAccountId
    ),
    templateLanguage: getWhatsAppTemplateConfig().language,
    pedidoConfirmado: getWhatsAppTemplateConfig().pedidoConfirmado,
    resolved: resolved.ok
      ? { ok: true, name: resolved.name, languages: resolved.languages, status: resolved.status }
      : { ok: false, reason: resolved.reason, detail: resolved.detail || null },
    templatesByWaba,
  };
}

module.exports = {
  DEFAULT_GRAPH_VERSION,
  getWhatsAppCloudConfig,
  getWhatsAppTemplateConfig,
  resolveWhatsAppProvider,
  getWhatsAppMxCandidates,
  extractMetaErrorCode,
  localMx10,
  normalizePhoneE164,
  redactPhone,
  digitsOnly,
  graphUrl,
  sendWhatsAppText,
  sendWhatsAppTemplate,
  sendWhatsAppSmart,
  verifyWebhookSubscribe,
  verifyMetaSignature,
  parseWebhookPayload,
  logWebhookEvents,
  authorizeInternalSend,
  sanitizeMetaError,
  diagnoseWhatsAppTemplates,
};
