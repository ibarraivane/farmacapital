'use strict';

const { isAnthropicCreditError } = require('./inventarioProductos');

function readAnthropicKey() {
  return String(
    process.env.ANTHROPIC_API_KEY ||
    process.env.REACT_APP_ANTHROPIC_API_KEY ||
    process.env.REACT_APP_ANTHROPIC_KEY ||
    ''
  ).trim();
}

function claudeModel() {
  return process.env.ANTHROPIC_MODEL || 'claude-sonnet-4-20250514';
}

async function callClaudeText(apiKey, systemText, userText, options = {}) {
  const resp = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: options.model || claudeModel(),
      max_tokens: options.max_tokens || 1024,
      system: systemText,
      messages: [{ role: 'user', content: userText }],
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
  return String(textBlock?.text || '').trim();
}

async function callClaudeChat(apiKey, systemText, messages, options = {}) {
  const resp = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: options.model || claudeModel(),
      max_tokens: options.max_tokens || 2048,
      system: systemText,
      messages: (Array.isArray(messages) ? messages : [])
        .filter((m) => m && String(m.content || '').trim())
        .map((m) => ({
          role: m.role === 'assistant' ? 'assistant' : 'user',
          content: String(m.content),
        })),
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
  return String(textBlock?.text || '').trim();
}

module.exports = {
  readAnthropicKey,
  callClaudeText,
  callClaudeChat,
};
