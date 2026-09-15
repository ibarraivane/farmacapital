# Especificación: Venta por Vencimiento Más Próximo (FEFO)
### Farmacia Ventura — POS
**Versión 1.0 — 14 de septiembre de 2026**

> Documento de implementación. Escrito para ser usado como contexto en Cursor.
> Complementa a `perfil-vendedor-pos.md` (ya define `entrada_inventario` con `lote` y `caducidad`).
> Los valores marcados como `[CONFIGURABLE]` deben confirmarse con el dueño antes de fijarlos en código.

---

## 0. El problema real antes de programar

Lo que se pidió: al escanear un producto, si no es el lote que vence más pronto, avisar y pedir que se venda el otro.

**La complicación:** un código de barras estándar (EAN-13/UPC) es idéntico para **todas las cajas del mismo producto**, sin importar el lote. El sistema no sabe, solo con el escaneo normal, cuál caja física tomó la vendedora. Hay dos escenarios posibles y cambian todo el flujo:

- **Escenario A — el empaque trae un código con lote y caducidad codificados** (código GS1-128 o DataMatrix de dos dimensiones, común en empaque secundario de medicamentos regulados). Si el proveedor de Farmacia Ventura ya usa esto, el sistema puede identificar el lote exacto al escanear y validar automáticamente, sin pedirle nada extra a la vendedora salvo cuando hay un error.
- **Escenario B — el código es el genérico de siempre** (el más probable). El sistema no puede saber qué caja se tomó solo con el escaneo; necesita que la vendedora **confirme el lote** con un paso adicional (selector simple, no reescribir nada a mano).

**Punto abierto crítico:** hay que confirmar cuál escenario aplica antes de implementar — ver §8. El diseño de abajo cubre ambos, pero uno es transparente para la vendedora y el otro le agrega un paso.

---

## 1. Objetivo

1. Asegurar que, siempre que sea posible, se venda primero el lote con fecha de caducidad más próxima.
2. Avisar a la vendedora cuando el producto escaneado (o seleccionado) no es el de vencimiento más próximo disponible.
3. Dejar un registro de cuándo se rompe el orden FEFO y por qué, sin necesariamente bloquear la venta a fuerza.

---

## 2. Modelo de datos

### 2.1 `lote_producto` — existencia por lote

Se alimenta de `entrada_inventario` (ya definida en `perfil-vendedor-pos.md` §3.3), agregando el descuento por venta.

```
lote_producto
├─ id                    uuid, pk
├─ producto_id           fk productos
├─ lote                  varchar
├─ caducidad             date
├─ codigo_lote_barras    varchar nullable   -- si el Escenario A aplica, el valor
│                                              leído del código GS1/DataMatrix
├─ cantidad_recibida     int                -- suma de entrada_inventario validadas
│                                              de este lote (ver perfil-vendedor-pos.md §3.3)
├─ cantidad_vendida      int                -- suma de venta_detalle descontada de este lote
├─ cantidad_merma        int default 0      -- ajustes manuales de merma sobre este lote
├─ cantidad_disponible   int generado: cantidad_recibida - cantidad_vendida - cantidad_merma
└─ created_at / updated_at
```

**Restricción:** único por `(producto_id, lote)`. Si llega una nueva entrada del mismo lote (remesa repetida), suma a `cantidad_recibida` de la misma fila en vez de crear una nueva.

### 2.2 Extensión a `venta_detalle` (asumiendo que ya existe en el sistema de ventas)

```
venta_detalle
├─ ...(campos existentes)
├─ lote_producto_id      fk lote_producto        -- de qué lote se descontó esta unidad
├─ era_fefo               bool                    -- true si era el lote de caducidad más próxima
│                                                    con stock al momento de la venta
├─ motivo_excepcion_fefo  text nullable           -- obligatorio si era_fefo=false
└─ (resto sin cambios)
```

**Regla:** ninguna venta se descuenta de `lote_producto.cantidad_vendida` sin que `lote_producto_id` esté definido. No existe la venta "genérica" de un producto sin lote una vez que este sistema esté activo.

---

## 3. Cálculo del lote FEFO

```
FEFO(producto_id) =
  SELECT * FROM lote_producto
  WHERE producto_id = :producto_id AND cantidad_disponible > 0
  ORDER BY caducidad ASC
  LIMIT 1
```

Se recalcula en cada venta, no se guarda en caché — el lote con caducidad más próxima puede cambiar de un momento a otro conforme se vende inventario.

---

## 4. Flujo al escanear (Escenario B — código genérico, el más probable)

```
Vendedora escanea el producto (código de barras estándar)
        │
        ▼
Buscar lote_producto con cantidad_disponible > 0
para este producto_id
        │
        ├── 0 lotes con stock ──► No hay existencia, no se puede vender
        │
        ├── 1 solo lote con stock ──► Se vende de ese lote automáticamente,
        │                              sin pedir nada. era_fefo=true por defecto.
        │
        └── 2+ lotes con stock
                │
                ▼
        Se muestra a la vendedora, ANTES de continuar el cobro:
        "Este producto tiene más de un lote en existencia.
         Vende primero: Lote L045 — vence 12/2026 (quedan 8 pzas)"
        + selector simple: botones por lote, cada uno mostrando
          lote y fecha de caducidad, para que la vendedora indique
          cuál caja física tomó
                │
                ▼
        ¿El lote seleccionado es el FEFO (§3)?
                │
        ┌───────┴───────┐
        SÍ               NO
        │                │
   era_fefo=true    ⚠️ Advertencia bloqueante:
   Continúa el      "Este no es el lote que vence primero.
   cobro normal      Tienes el Lote L045 (vence antes).
                      ¿Seguro que quieres vender este?"
                            │
                      ┌─────┴─────┐
                   Cambiar de   Confirmar igual
                   lote (vuelve  (requiere motivo:
                   al selector)  ej. "el otro lote
                                  está dañado" /
                                  "no lo encontré
                                  en anaquel")
                            │
                      era_fefo=false
                      motivo_excepcion_fefo = texto capturado
                      Continúa el cobro
```

## 4.1 Flujo si el Escenario A aplica (código con lote/caducidad codificados)

Si se confirma que el empaque trae código GS1-128/DataMatrix con lote y caducidad:

- El escaneo identifica el lote exacto automáticamente — no hace falta selector manual.
- El sistema compara ese lote contra el FEFO calculado en §3.
- Si coincide → venta normal, sin fricción, `era_fefo=true`.
- Si no coincide → misma advertencia bloqueante de arriba, con la diferencia de que ya sabe con certeza qué caja física se escaneó (no depende de que la vendedora reporte bien). El único motivo válido para anular en este caso es algo como "el lote correcto no se encuentra físicamente" — vale la pena limitar las opciones de motivo a una lista corta en vez de texto libre, para que los reportes del admin sean consistentes.

---

## 5. Bloquear o solo advertir — decisión pendiente

Dos formas de aplicar esto, controladas por un flag:

- `FEFO_BLOQUEA_VENTA = true`: no se puede completar el cobro sin resolver la advertencia (cambiar de lote o justificar). Más estricto, más consistente.
- `FEFO_BLOQUEA_VENTA = false`: la advertencia se muestra pero la vendedora puede seguir sin capturar motivo. Más flexible, pero el dato de auditoría queda incompleto.

> Recomendación: empezar con `true`. Es una farmacia — vender por vencimiento no es solo un tema de eficiencia de inventario, también evita vender productos que caducan pronto sin que el cliente lo note.

---

## 6. Lo que ve el admin

- Reporte de excepciones FEFO por periodo: cuántas veces se vendió un lote que no era el más próximo a vencer, y con qué motivo — permite detectar si es un problema de acomodo en anaquel (el lote viejo queda escondido atrás) más que de disciplina de venta.
- Vista de "próximos a vencer" por producto, independiente de si se vendieron o no — para poder ofrecerlos con descuento o retirarlos a tiempo. Esto es un tema relacionado pero distinto (gestión de merma), no se resuelve en este documento.

El vendedor no necesita ver el detalle acumulado de excepciones de otros compañeros — solo la advertencia en el momento de su propia venta, igual que el resto de los datos operativos vs. agregados en `perfil-vendedor-pos.md` §7.

---

## 7. Parámetros configurables

| Parámetro | Valor sugerido | Notas |
|---|---|---|
| `FEFO_BLOQUEA_VENTA` | `[CONFIGURABLE] true` | Ver §5. |
| `MOTIVOS_EXCEPCION_FEFO` | `[CONFIGURABLE]` lista corta | Ej. "Lote dañado", "No se encontró en anaquel", "Otro (especificar)" — mejor lista cerrada que texto libre para que los reportes sirvan. |
| `DIAS_ALERTA_PROXIMO_VENCER` | `[CONFIGURABLE] 90 días` | Para la vista de próximos a vencer del admin (§6), no bloquea nada, solo informa. |

---

## 8. Puntos abiertos

- **Confirmar cuál escenario aplica (§0):** revisar con los proveedores si el empaque trae código GS1-128/DataMatrix con lote y caducidad, o si es el código genérico de siempre. Esto determina si el flujo es el manual de §4 o el automático de §4.1 — es lo primero que hay que resolver, cambia el diseño de la pantalla.
- **Bloquear vs. solo advertir (§5):** decidir antes de fijar `FEFO_BLOQUEA_VENTA` en el código.
- **Acomodo físico en anaquel.** Ningún sistema resuelve esto si las cajas viejas quedan atrás del anaquel y las nuevas al frente — vale la pena que el procedimiento de reabasto incluya rotar físicamente el inventario (lo nuevo atrás, lo próximo a vencer al frente), como complemento a esta lógica, no sustituto.
- **Relación con `entrada_inventario`.** Esa tabla ya captura `lote` y `caducidad` por entrada (opcionales hoy, según `perfil-vendedor-pos.md` §12) — con este sistema activo, esos campos dejan de ser opcionales: sin lote y caducidad no se puede calcular FEFO.
