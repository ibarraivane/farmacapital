Specs de encargo — estado en repo

Presentes:
- docs/claude_encargo-medicamentos.md (fuente exacta enums/flujo)
- docs/claude_envio-domicilio.md (rediseño DiDi + preauth MP)

Ausente:
- perfil-vendedor-pos.md (no llegó; el tercer pegado fue FEFO).
  solicitud_producto = aspiracional; no migrar/tocar.

Decisiones de producto: respuestas E.1–E.11 del mensaje de confirmación.

Envío a domicilio en CÓDIGO hoy:
- Sigue vivo Uber Direct (api/_lib/uberDirect.js, Tienda/POS).
- NO hay tabla_tarifa_envio, direccion_entrega, envio, preauth MP ni DiDi.
- Fase (f) del encargo = BLOQUEADA hasta implementar claude_envio-domicilio.md.
- Fases (a)–(e) siguen; Caso B con recoger_en_tienda no depende de (f).

FEFO: no tocar (regla explícita).
