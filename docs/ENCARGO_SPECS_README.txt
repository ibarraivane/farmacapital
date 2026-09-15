Specs de encargo — estado en el repo

Presentes:
- docs/claude_encargo-medicamentos.md
- docs/claude_envio-domicilio.md

Ausente: perfil-vendedor-pos.md (aspiracional). FEFO no tocado.

Fases:
- (a) modelo SQL aviso/encargo/cotizacion — aplicado
- (b) Caso A CTA + API + cola Pedidos online + trigger restock — en este branch
- (f) BLOQUEADA: envío DiDi/preauth aún no existe; Uber Direct sigue vivo

SQL fase b: sql/patch_aviso_disponibilidad_fase_b_20260915.sql
