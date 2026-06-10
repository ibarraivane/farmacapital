Quiero que prepares FARMACAPITAL, a nivel de código y funcionalidad, para operar con dos modelos de venta/entrega:

1. Marketplace externo (Rappi / Uber Eats)
2. Tienda propia FARMACAPITAL + pickup en tienda + futura última milla con Uber Direct

CONTEXTO
- FARMACAPITAL es una farmacia con tienda propia web y panel admin/POS.
- No tengo repartidores propios ni quiero tenerlos.
- Mi prioridad comercial es:
  A) vender también en plataformas tipo Rappi/Uber para no perder clientes jóvenes
  B) mantener mi propia tienda FARMACAPITAL
  C) permitir pickup en tienda y dejar listo el sistema para que una plataforma de reparto haga la entrega a domicilio cuando toque
- No quiero refactors masivos.
- No quiero tocar backend delicado o SQL agresivamente si no hace falta.
- Quiero cambios seguros, bien documentados y con buen criterio.

OBJETIVO
Preparar el sistema FARMACAPITAL para soportar correctamente:
- pedidos creados en la tienda web
- pickup en tienda
- futura entrega por tercero (ej. Uber Direct)
- futura recepción/mapeo de pedidos marketplace (Rappi / Uber Eats)
- elegibilidad de productos por canal

(Diseño funcional completo: ver resultado en `docs/DELIVERY_MARKETPLACE_PREP.md` y ejecución en el repo.)

QUÉ QUIERO QUE HAGAS
1. Audita el repo y detecta cómo modela hoy pedidos, productos, clientes, entrega/pickup.
2. Aplica cambios seguros para preparar el sistema para esos canales.
3. No rompas lo existente.
4. Si algo requiere integración real futura, deja la estructura lista y documentada.
5. Crea un documento claro: `docs/DELIVERY_MARKETPLACE_PREP.md`.
6. Corre build al final.

ENTREGABLE FINAL
Resumen ejecutivo, cambios, archivos modificados, qué quedó listo vs pendiente, resultado de build, ubicación de propuesta de SKUs.
