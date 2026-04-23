Quiero que prepares FARMAX, a nivel de código y funcionalidad, para operar con dos modelos de venta/entrega:

1. Marketplace externo (Rappi / Uber Eats)
2. Tienda propia FARMAX + pickup en tienda + futura última milla con Uber Direct

CONTEXTO
- FARMAX es una farmacia con tienda propia web y panel admin/POS.
- No tengo repartidores propios ni quiero tenerlos.
- Mi prioridad comercial es:
  A) vender también en plataformas tipo Rappi/Uber para no perder clientes jóvenes
  B) mantener mi propia tienda FARMAX
  C) permitir pickup en tienda y dejar listo el sistema para que una plataforma de reparto haga la entrega a domicilio cuando toque
- No quiero refactors masivos.
- No quiero tocar backend delicado o SQL agresivamente si no hace falta.
- Quiero cambios seguros, bien documentados y con buen criterio.

OBJETIVO
Preparar el sistema FARMAX para soportar correctamente:
- pedidos creados en la tienda web
- pickup en tienda
- futura entrega por tercero (ej. Uber Direct)
- futura recepción/mapeo de pedidos marketplace (Rappi / Uber Eats)
- elegibilidad de productos por canal

DISEÑO FUNCIONAL DESEADO

A. MODELO DE CANAL DEL PEDIDO
Quiero que el sistema soporte / deje preparado un campo o lógica equivalente para distinguir:
- web_pickup
- web_delivery
- rappi_marketplace
- uber_marketplace
- counter_pos

B. MODELO DE FULFILLMENT
Quiero que el sistema soporte / deje preparado un campo o lógica equivalente para:
- pickup_store
- marketplace_courier
- uber_direct
- own_delivery (aunque no lo use hoy)

C. ESTADOS DE PEDIDO
Quiero un flujo interno coherente, por ejemplo:
- created
- paid_pending_validation
- accepted
- preparing
- ready_for_pickup
- courier_requested
- courier_assigned
- picked_up
- delivered
- cancelled

D. CATÁLOGO / REGLAS POR SKU
Quiero que el sistema quede preparado para banderas por producto o familia, por ejemplo:
- sell_web
- sell_pickup
- sell_rappi
- sell_uber
- delivery_allowed
- requires_rx
- is_controlled

No inventes backend enorme si no hace falta, pero deja el sistema preparado de forma segura y clara.

E. CHECKOUT / TIENDA
Quiero que la tienda propia esté preparada para:
- pickup en tienda
- futura entrega a domicilio
- validación por elegibilidad del producto
- dirección de entrega cuando aplique

F. BACKOFFICE DE PEDIDOS ONLINE
Quiero que el admin/vendedor tengan una operación coherente para pedidos online:
- ver pedidos
- aceptar/rechazar
- preparar
- marcar listo para recoger
- marcar listo para despacho
- dejar listo el terreno para solicitar courier externo

G. TRACKING / REFERENCIAS EXTERNAS
Quiero que el sistema quede preparado para guardar / mapear:
- external_order_id
- external_delivery_id
- provider (rappi / uber / uber_direct / etc.)
- tracking_url
- courier metadata si aplica
- timestamps principales

H. MARKETPLACE / ÚLTIMA MILLA
No quiero que inventes una integración completa si no hay credenciales reales.
Sí quiero que:
1. analices qué piezas del repo ya existen
2. prepares la arquitectura / modelo / puntos de integración
3. dejes adaptadores o servicios placeholder bien documentados si hace falta
4. dejes claro qué parte sería:
   - Rappi marketplace
   - Uber Eats marketplace
   - Uber Direct última milla

I. PRODUCTOS RESTRINGIDOS
Revisa la lógica actual de productos controlados vs no controlados y deja preparado el sistema para que no todos los SKUs se traten igual en web/delivery.

J. SKUs / SURTIDO
Revisa si existe catálogo/seed/listado en repo.
Si existe y es razonable tocarlo, prepara una propuesta o archivo auxiliar para ampliar surtido mínimo con:
- multivitamínicos
- vitamina C
- vitamina D / D3
- complejo B
- multivitamínicos pediátricos
- prenatal / ácido fólico si aplica
- electrolitos orales / sueros / sobres / pediátricos / sin azúcar

Si el catálogo real vive en Supabase y no debes inventar datos en UI, entonces crea una propuesta estructurada para importación futura (CSV/JSON/SQL/doc), pero no dejes datos falsos conectados a producción.

ARCHIVOS PROBABLEMENTE IMPORTANTES
- src/Tienda.jsx
- src/Admin.jsx
- src/modules/sales/*
- src/modules/clinical/*
- src/* pedidos / carrito / checkout / POS
- src/supabase.js
- src/utils/*
- src/shared/*
- cualquier modelo/constante de productos o pedidos
- docs/*
- cualquier archivo relacionado a PWA o pedidos online

QUÉ QUIERO QUE HAGAS
1. Audita el repo y detecta cómo modela hoy:
   - pedidos
   - productos
   - clientes
   - entrega/pickup
2. Aplica cambios seguros para preparar el sistema para esos canales.
3. No rompas lo existente.
4. Si algo requiere integración real futura, deja la estructura lista y documentada.
5. Crea un documento claro, por ejemplo:
   - docs/DELIVERY_MARKETPLACE_PREP.md
6. Corre build al final.

ENTREGABLE FINAL
Quiero:
1. Resumen ejecutivo corto
2. Qué cambiaste para preparar FARMAX
3. Archivos modificados
4. Qué quedó listo para:
   - pickup
   - marketplace
   - Uber Direct
5. Qué quedó pendiente por credenciales o integraciones reales
6. Resultado de build
7. Dónde quedó la propuesta de SKUs si la generaste

NO te quedes en recomendaciones. Analiza el repo y aplica cambios seguros y útiles.
