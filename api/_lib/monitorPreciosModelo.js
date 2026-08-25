/**
 * Única llamada al modelo del monitor: elegir candidato. Nunca ve precios.
 */
"use strict";

function extraerJson(text) {
  if (!text) return null;
  const trimmed = String(text).trim().replace(/^```json\s*|\s*```$/g, "");
  try {
    return JSON.parse(trimmed);
  } catch {
    const m = trimmed.match(/\{[\s\S]*\}/);
    if (!m) return null;
    try {
      return JSON.parse(m[0]);
    } catch {
      return null;
    }
  }
}

function crearLlamarModelo() {
  const key = String(process.env.ANTHROPIC_API_KEY || "").trim();
  if (!key) return null;

  return async function llamarModelo(prompt) {
    const resp = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": key,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: process.env.ANTHROPIC_MODEL || "claude-sonnet-4-20250514",
        max_tokens: 256,
        messages: [{ role: "user", content: prompt }],
      }),
    });
    const bodyText = await resp.text();
    if (!resp.ok) {
      throw new Error(`modelo_emparejamiento:${resp.status}:${bodyText.slice(0, 180)}`);
    }
    let data;
    try {
      data = JSON.parse(bodyText);
    } catch {
      return null;
    }
    const text = (data.content || [])
      .filter((b) => b.type === "text")
      .map((b) => b.text)
      .join("\n");
    return extraerJson(text);
  };
}

module.exports = { crearLlamarModelo, extraerJson };
