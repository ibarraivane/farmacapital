# NO reaplicar `patch_corte_electronicos_servidor.sql`

Ese archivo quedó **superseded** el 24-ago-2026 por
`patch_caja_cadena_continua_20260824.sql`.

## Por qué rompe la farmacia

`patch_corte_electronicos_servidor.sql` hace esto:

1. Borra cualquier `registrar_corte_caja` que no tenga exactamente **13** argumentos.
2. Recrea la firma de 13 args **sin** `p_confirmar`.

La tablet, desde el 25-ago, llama con `p_confirmar`. PostgREST entonces responde:

> Could not find the function public.registrar_corte_caja(… p_confirmar …)

y el corte no se puede guardar. La caja queda abierta sin poder cerrarse.

## Qué hacer si ya se rompió

1. Diagnóstico (solo lee): `sql/diagnostico_firma_corte_20260904.sql`
2. Restaurar: `sql/patch_corte_restaurar_firma_20260904.sql`
3. Si el restore falla por helpers faltantes: reaplicar entero
   `sql/patch_caja_cadena_continua_20260824.sql`

## Qué NO hacer

- No volver a pegar `patch_corte_electronicos_servidor.sql` en Supabase.
- La lógica de electrónicos / servicios ya vive dentro de cadena continua
  (`reconcile_cash_rango`).
