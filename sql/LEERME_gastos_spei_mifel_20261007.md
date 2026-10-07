# Tickets SPEI Mifel — 7-oct-2026

Correr en Supabase SQL Editor:

1. `patch_gastos_spei_mifel_20261007.sql`

Quedan en **Flujo de caja → Gastos**. Tickets de texto en `sql/tickets/`.

## Transferencias

| Monto | Alias | Beneficiario | Banco | Folio | Clave de rastreo | Categoría |
|---|---|---|---|---|---|---|
| $200.00 | Juan Maistro | Misael Isac Ramirez Valdes | Banorte ****8547 | 53973518 | `…MIFB000233404` | mantenimiento |
| $1,000.00 | Nana | Angel Gerardo Rodriguez Valero | Scotiabank ****2156 | 53975588 | `…MIFB000236078` | otros |

Origen ambos: Mifel Digital Evoluciona ****8716. Fecha local: 2026-10-07.

## Notas

- Idempotente: si ya está la clave de rastreo en `gastos.notas`, no duplica.
- Juan Maistro → `mantenimiento` por el alias. Nana → `otros` (no hay ficha RH clara). Si Nana es nómina/anticipo, editar categoría en Flujo.
- No registra `rh_pagos_semana` (eso es el flujo de viernes con asistencia).
- CEP: https://www.banxico.org.mx/cep
