# Corte por sesión (24-oct-2026)

## Qué arregla
Cinthia abre y corta; luego Iván (u otra persona) abre caja. La pantalla
decía «ya hay un corte Matutino» y no dejaba guardar el segundo.

## Pegar en Supabase
1. `sql/patch_corte_por_sesion_20261024.sql` → Run.
2. Deploy del front (rama / PR de este cambio).

Sin el SQL, el front ya deja guardar si hay **caja abierta**; el SQL
alinea el RPC para que el aviso no mienta.
