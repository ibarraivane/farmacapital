# Login social — tienda FarmaCapital (Google / Facebook / Apple)

Sí se puede. La tienda en línea (`/login`, `/registro`) ya tiene botones para
continuar con Google, Facebook y Apple. **El admin / POS sigue solo con
correo-teléfono + contraseña** (acceso de empleados; no conviene OAuth ahí).

## Cómo funciona

1. El visitante elige Google (recomendado) / Facebook / Apple.
2. Supabase Auth abre el OAuth del proveedor y vuelve a `/auth/callback`.
3. La API `POST /api/auth/oauth-bridge` (rewrite a la función auth existente)
   valida el JWT de Auth.
4. El RPC `service_login_cliente_oauth` crea o vincula la fila en `clientes`
   y emite el mismo `sesiones_cliente.token` que el login con contraseña.
5. Si la cuenta no tiene teléfono, la tienda pide el celular (WhatsApp) una sola vez.
6. El frontend guarda el token FarmaCapital y entra a Mi cuenta / cita.

Si el correo ya existía (mostrador o registro web), se **vincula** a esa
cuenta; no se duplica.

**Activo por default: Google.** Apple (requiere Apple Developer Program)
y Facebook se suman con `REACT_APP_SOCIAL_LOGIN=google,apple` o
`REACT_APP_SOCIAL_LOGIN=google,facebook,apple`.

## Checklist para activarlo en producción

### 1. SQL en Supabase

Ejecutá en el SQL Editor:

- `sql/patch_cliente_oauth_login.sql`

### 2. Providers en Supabase

Dashboard → **Authentication → Providers**:

| Provider  | Qué necesitás |
|-----------|----------------|
| Google    | Client ID + Secret de Google Cloud (OAuth 2.0 Web) |
| Facebook  | App ID + App Secret de Meta for Developers |
| Apple     | Apple Developer Program (pago), Services ID, Key |

Redirect URLs permitidas (Authentication → URL Configuration):

```
https://www.farmacapital.mx/auth/callback
https://farmacapital.mx/auth/callback
http://localhost:3000/auth/callback
```

Site URL: `https://www.farmacapital.mx`

### 3. Google Cloud (mínimo para arrancar)

1. Consola Google Cloud → APIs y servicios → Credenciales → OAuth client **Web**.
2. Authorized redirect URIs (las que te muestra Supabase para Google), típico:
   `https://<PROJECT_REF>.supabase.co/auth/v1/callback`
3. Pegá Client ID y Secret en Supabase → Providers → Google → Enable.

### 4. Variables en Vercel / `.env`

```bash
# Ya existentes (obligatorias para el puente)
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=...
REACT_APP_SUPABASE_URL=...
REACT_APP_SUPABASE_ANON_KEY=...
PUBLIC_SITE_URL=https://www.farmacapital.mx

# Qué botones mostrar en la tienda (coma-separados)
REACT_APP_SOCIAL_LOGIN=google
# Cuando tengas Apple Developer: google,apple
```

Sin `REACT_APP_SOCIAL_LOGIN`, el default del código es **solo google**.

### Apple (Supabase → Authentication → Providers → Apple)

1. Apple Developer Program → Identifiers → **Services ID** (Sign in with Apple).
2. Domains: `www.farmacapital.mx` y Return URL de Supabase:
   `https://<PROJECT_REF>.supabase.co/auth/v1/callback`
3. Keys → crear Key con Sign in with Apple → bajar `.p8`.
4. En Supabase Apple: Services ID, Team ID, Key ID y contenido del `.p8`.

### 5. Redeploy

Tras guardar env vars y el SQL, redeploy en Vercel. Probá en
`https://www.farmacapital.mx/login`.

## Archivos tocados

- `sql/patch_cliente_oauth_login.sql` — columnas + RPC service-role
- `api/auth/oauth-bridge.js` — canje JWT Auth → token FarmaCapital
- `src/utils/clienteOAuth.js` — start/complete OAuth
- `src/components/SocialLoginButtons.jsx` — UI
- `src/Tienda.jsx` — login, registro, página `/auth/callback`
- `src/shared/tiendaRoutes.js` — ruta `auth-callback`
- `vercel.json` — CSP para dominios OAuth

## Trigger legado (no tocar perfiles)

En producción existía `public.handle_new_auth_user`, disparado al insertar
en `auth.users`. Copiaba al usuario a `perfiles` como `vendedor`. Eso
rompe **Continuar con Google** de un cliente (`Database error saving new
user`) y, si pasara, le daría perfil de empleado.

El personal se crea con `admin_crear_usuario`. Los clientes, con
`service_login_cliente_oauth`. Neutralizar el trigger:

- `sql/patch_oauth_no_perfil_staff_20260901.sql` (SQL Editor de Supabase)

## Notas

- Cuentas solo-OAuth no tienen `password_hash`; pueden seguir entrando por
  el mismo proveedor, o pedir “olvidé mi contraseña” si más adelante se les
  asigna una clave.
- Apple a veces oculta el correo (relay `@privaterelay.appleid.com`); el
  vínculo estable es `auth_provider` + `auth_subject`.
- Facebook y Apple requieren apps revisadas por Meta/Apple para producción
  pública; Google suele ser el más rápido de habilitar.
