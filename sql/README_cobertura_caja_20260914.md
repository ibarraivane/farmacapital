# Cobertura de caja (14-sep-2026)

**Regla:** quien abre caja trabaja ese turno. El perfil RH (matutino/vespertino) es la costumbre semanal, no un candado.

## Pegar en Supabase (en este orden)

1. `patch_atendido_por_caja_meta_20260914.sql` — ventas cuentan para quien tiene la caja abierta
2. `patch_midia_meta_por_sesion_caja_20260914.sql` — Mi Día suma como el corte (sesión de caja)
3. `patch_cobertura_quien_abre_caja_20260914.sql` — apertura por reloj / cadena, no solo perfil RH

Luego: que la vendedora cierre sesión, vuelva a entrar y abra caja.
