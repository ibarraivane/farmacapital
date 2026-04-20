# FARMAX — Backups automáticos + Health check

Sistema de respaldo automático de la base de datos Supabase, con:

- **Backup diario** a las 06:00 UTC (pg_dump custom → repo GitHub privado)
- **Health check diario** a las 12:00 UTC (select 1; evita auto-pause de Supabase Free)
- **Soporte opcional para Cloudflare R2** (stub preparado, desactivado)

## Arquitectura

```
Vercel Cron (0 6 * * *)
   └─> /api/backup.js  (valida CRON_SECRET)
         └─> POST https://api.github.com/repos/OWNER/farmax/dispatches
               └─> .github/workflows/backup.yml  (runner ubuntu-latest)
                     └─> node scripts/backup-db.js
                           ├─> pg_dump --format=custom (con timeout 15min)
                           ├─> validación tamaño (min 10KB, max 500MB)
                           ├─> git clone farmax-backups (shallow, con token HTTPS)
                           ├─> copy /tmp/backups/farmax-backup-YYYY-MM-DD.backup → backups/
                           ├─> git add + commit + push
                           ├─> rotación (borra > 30 días)
                           └─> (opcional) scripts/upload-r2.js  [stub]

Vercel Cron (0 12 * * *)
   └─> /api/health.js  (select 1 → Supabase; mantiene proyecto activo)
```

### ¿Por qué Vercel dispara un workflow en lugar de correr pg_dump directo?

Las funciones serverless de Vercel son AWS Lambda aisladas sin `pg_dump` ni `git` preinstalados, con timeout 10-60s y `/tmp` de 512MB. En cambio, un runner de GitHub Actions `ubuntu-latest` tiene:

- `git` preinstalado
- `postgresql-client` instalable en 10s
- 30 min de timeout
- disco efímero amplio

Por eso `/api/backup.js` actúa como **trigger ligero** y el workflow como **ejecutor pesado**.

## Archivos del sistema

| Ruta | Responsabilidad |
|---|---|
| `scripts/backup-db.js` | Script end-to-end: pg_dump → validación → git clone/commit/push → rotación |
| `scripts/upload-r2.js` | Stub para Cloudflare R2 (desactivado) |
| `scripts/README-backups.md` | Este archivo |
| `api/backup.js` | Endpoint que Vercel Cron llama; dispara GitHub Actions |
| `api/health.js` | Endpoint de health check; SELECT 1 contra Supabase |
| `.github/workflows/backup.yml` | Workflow del runner; instala pg_dump e invoca backup-db.js |
| `vercel.json` | Configura los 2 crons |

## Variables de entorno

### Vercel (Settings → Environment Variables, scope "Production")

| Variable | Valor | Cómo se usa |
|---|---|---|
| `CRON_SECRET` | Generar con `openssl rand -hex 32` | Autentica el dispatch contra `/api/backup` |
| `DISPATCH_GITHUB_REPO` | `owner/repo` del repo principal (ej. `ibarra/farmax`) | Target del repository_dispatch |
| `DISPATCH_GITHUB_TOKEN` | PAT fine-grained con Actions: Read and write | Autorización para disparar el workflow |
| `SUPABASE_URL` | URL del proyecto Supabase | Health check |
| `SUPABASE_ANON_KEY` | anon key pública de Supabase | Health check |

Vercel Cron envía automáticamente `Authorization: Bearer $CRON_SECRET` al endpoint. Sin ese header → 401.

### GitHub Actions (repo principal → Settings → Secrets and variables → Actions)

| Secret | Valor |
|---|---|
| `SUPABASE_DB_URL` | Connection string de Supabase (Settings → Database → URI, session mode port 5432) |
| `BACKUP_GITHUB_REPO` | `owner/repo` del repo privado de backups (ej. `ibarra/farmax-backups`) |
| `BACKUP_GITHUB_TOKEN` | PAT fine-grained con Contents: Read and write sobre ese repo |

### Opcional — Cloudflare R2 (para activar en el futuro)

| Secret | Valor |
|---|---|
| `R2_ENABLED` | `true` |
| `R2_ACCOUNT_ID` | Account ID en Cloudflare dashboard |
| `R2_ACCESS_KEY_ID` | API token R2 |
| `R2_SECRET_ACCESS_KEY` | API token R2 |
| `R2_BUCKET_NAME` | Nombre del bucket |

Ver `scripts/upload-r2.js` para los pasos de activación.

## Setup paso a paso (15-20 min)

### 1. Crear repo privado de backups

En GitHub, crea un nuevo repo **privado**, vacío, llamado por ejemplo `farmax-backups`.

### 2. Crear 2 PATs fine-grained

**PAT A — para Vercel (disparar workflow):**
1. GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new
2. Name: `farmax-vercel-dispatch`
3. Expiration: 1 año
4. Repository access: Only `owner/farmax`
5. Permissions → Actions: **Read and write**, Contents: Read
6. Copia el token → va a Vercel como `DISPATCH_GITHUB_TOKEN`

**PAT B — para el runner (pushear a backups):**
1. Repetir flujo anterior
2. Name: `farmax-backup-push`
3. Repository access: Only `owner/farmax-backups`
4. Permissions → Contents: **Read and write**
5. Copia el token → va a GitHub Secrets como `BACKUP_GITHUB_TOKEN`

### 3. Obtener la URL de Supabase

Supabase Dashboard → Project Settings → Database → Connection string → **URI**. Usar **Session mode** (port 5432), no pooler (6543).

```
postgres://postgres.xxxxx:PASSWORD@aws-0-us-east-1.pooler.supabase.com:5432/postgres
```

Esta URL incluye la password: trátala como secret.

### 4. Generar secret compartido para Vercel Cron

```bash
openssl rand -hex 32
```

### 5. Poner todas las variables en Vercel y GitHub

Ver la tabla de arriba.

### 6. Commitear y desplegar

```bash
git add scripts/ api/ .github/ vercel.json
git commit -m "feat(ops): backups diarios + health check"
git push
```

### 7. Probar manualmente

**Health check (instantáneo):**

```bash
curl -i https://TU_APP.vercel.app/api/health
# Esperado: 200 {"ok":true,"db":"up",...}
```

**Backup trigger:**

```bash
curl -i -X POST https://TU_APP.vercel.app/api/backup \
  -H "Authorization: Bearer TU_CRON_SECRET"
# Esperado: 202 {"ok":true,"dispatched":true,...}
```

Luego ve a GitHub → `farmax` → **Actions** → debería aparecer "FARMAX DB Backup" corriendo.

En 3-5 min aparecerá en `farmax-backups/backups/` el archivo `farmax-backup-YYYY-MM-DD.backup`.

### 8. Probar el script local (opcional)

Si tienes `pg_dump` instalado localmente (`brew install libpq` + añadir al PATH):

```bash
export SUPABASE_DB_URL="postgres://..."
export BACKUP_GITHUB_REPO="owner/farmax-backups"
export BACKUP_GITHUB_TOKEN="ghp_..."
export BACKUP_OUTPUT_DIR="./.local-backups"

node scripts/backup-db.js
```

Para probar solo el dump (sin git):

```bash
BACKUP_SKIP_GIT=true node scripts/backup-db.js
```

## Restauración

### Restauración completa

```bash
pg_restore \
  --clean \
  --if-exists \
  --no-owner \
  --no-privileges \
  --verbose \
  --dbname="postgres://postgres:PASSWORD@HOST:5432/DB_DESTINO" \
  ./farmax-backup-YYYY-MM-DD.backup
```

Flags:

- `--clean --if-exists`: borra objetos existentes antes de restaurar (solo úsalo en DBs de pruebas o nuevas).
- `--no-owner --no-privileges`: ignora owners y grants del dump; útil al restaurar en otro proyecto Supabase.

### Restauración solo-data (schema ya existe)

```bash
pg_restore --data-only --dbname="$SUPABASE_DB_URL" farmax-backup-YYYY-MM-DD.backup
```

### Restauración parcial (una tabla)

```bash
# Lista el contenido
pg_restore --list farmax-backup-YYYY-MM-DD.backup > toc.txt

# Edita toc.txt para dejar solo las líneas de la tabla deseada
# Restaura solo esas entradas
pg_restore --use-list=toc.txt --dbname="$SUPABASE_DB_URL" farmax-backup-YYYY-MM-DD.backup
```

### Inspeccionar sin restaurar

```bash
pg_restore --list farmax-backup-YYYY-MM-DD.backup | head -50
```

## Recuperación ante desastre (DR)

Si pierdes el proyecto Supabase por completo:

1. Crear nuevo proyecto Supabase (puede ser Free).
2. Aplicar todas las migraciones de `sql/` en orden:
   ```bash
   # orden aproximado
   refactor_fase1_aditivo.sql
   refactor_fase2_*.sql
   refactor_fase3_*.sql
   refactor_fase4_*.sql
   refactor_fase6a_*.sql
   refactor_fase6b_*.sql
   refactor_fase6c_*.sql
   refactor_fase6d_*.sql
   refactor_fase6e_*.sql
   ```
3. Clonar `farmax-backups`, tomar el último `.backup`.
4. Restaurar solo data:
   ```bash
   pg_restore --data-only --no-owner --no-privileges \
     --dbname="$NEW_SUPABASE_DB_URL" \
     backups/farmax-backup-YYYY-MM-DD.backup
   ```
5. Actualizar `SUPABASE_URL` y claves en Vercel.
6. Redeploy.

Tiempo estimado: 30-60 min para una DB de hasta 500 MB.

## Activar Cloudflare R2 (futuro)

Cuando quieras redundancia adicional en R2:

1. Crear bucket en Cloudflare R2 (dashboard).
2. Crear API token R2 (Account → R2 → Manage R2 API Tokens). Copiar `accessKeyId` y `secretAccessKey`.
3. Agregar estos secrets en GitHub Actions del repo principal:
   - `R2_ENABLED=true`
   - `R2_ACCOUNT_ID=...`
   - `R2_ACCESS_KEY_ID=...`
   - `R2_SECRET_ACCESS_KEY=...`
   - `R2_BUCKET_NAME=...`
4. Instalar dependencia:
   ```bash
   npm i -D @aws-sdk/client-s3
   git commit -am "chore: add aws-sdk for R2"
   git push
   ```
5. En `scripts/upload-r2.js`, descomentar el bloque marcado con "BLOQUE A DESCOMENTAR CUANDO SE ACTIVE R2".
6. El workflow `backup.yml` ya tiene el step condicionado a `R2_ENABLED == 'true'`. El siguiente backup subirá automáticamente a R2.

## Troubleshooting

### "pg_dump: error: server version mismatch"

La versión de `pg_dump` en el runner debe ser **≥** la de Supabase. El workflow usa `PG_MAJOR: "17"`. Si Supabase sube a Postgres 18, ajusta esa variable.

### El workflow nunca se dispara

- Verifica en Vercel que `DISPATCH_GITHUB_REPO`, `DISPATCH_GITHUB_TOKEN`, `CRON_SECRET` estén bien.
- Revisa los logs de `/api/backup` en Vercel (Logs tab).
- Prueba manualmente: GitHub → Actions → "FARMAX DB Backup" → Run workflow.

### "fatal: could not read Username for 'https://github.com'"

El PAT `BACKUP_GITHUB_TOKEN` expiró o no tiene permisos Contents: Read and write sobre el repo de backups. Regéneralo.

### Dump muy pequeño (< 10 KB) → exit code 4

Normalmente significa que la connection string está mal o el rol no tiene acceso a ninguna tabla. Verifica `SUPABASE_DB_URL` usando la copia literal del dashboard de Supabase.

### Dump excede 500 MB → exit code 5

Ya estás al borde del plan Free de Supabase. Opciones:

- Subir el límite en el workflow: `BACKUP_MAX_SIZE_MB: "1024"`.
- Migrar a Supabase Pro.
- Usar `pg_dump --exclude-table-data='audit_log_detallado'` para excluir tablas pesadas (modificar `scripts/backup-db.js`).

### El primer backup del día no generó commit

Si corres el backup dos veces el mismo día y el contenido es idéntico, `git diff --cached --quiet` retorna 0 y el script no commitea. No es un error; es el comportamiento esperado.

### "No hay cambios nuevos que commitear"

Igual que lo anterior — el dump es idéntico al existente. Normal.

## Comandos útiles

```bash
# Ver los últimos 5 backups en el repo remoto
gh api repos/OWNER/farmax-backups/contents/backups | jq '.[-5:] | .[].name'

# Descargar un backup específico
gh api repos/OWNER/farmax-backups/contents/backups/farmax-backup-2026-04-20.backup \
  --jq '.content' | base64 -d > farmax-backup-2026-04-20.backup

# Disparar el backup manualmente desde CLI
gh workflow run backup.yml -R OWNER/farmax
```

## Retención

- **Actual**: 30 días (automático, via `BACKUP_RETENTION_DAYS=30`).
- **Cambiar**: editar la variable en `.github/workflows/backup.yml`.
- **Infinita**: poner `BACKUP_RETENTION_DAYS=0` (nunca borra — cuidado con el tamaño del repo).
- **Histórico largo**: considera mover backups mensuales a R2 (el stub ya está preparado).

## Seguridad implementada

- ✅ Todos los secrets vía env vars (nunca en código).
- ✅ Logs sanitizados: regex que redacta connection strings, tokens GitHub (ghp\_…, github\_pat\_…), passwords, authorization headers.
- ✅ El token git no aparece en logs (git no imprime URLs con credenciales embebidas cuando se pasa --quiet).
- ✅ `/api/backup` requiere `Authorization: Bearer $CRON_SECRET` → 401 si falta.
- ✅ Validación de tamaño mínimo (detecta dumps vacíos).
- ✅ Validación de tamaño máximo (evita rellenar el repo de backups).
- ✅ Timeout duro de 15 min en pg_dump.
- ✅ Timeout de 5 min en cada comando git.
- ✅ Directorio temporal único por ejecución (`mkdtempSync`), borrado al final.
- ✅ `concurrency: cancel-in-progress: false` en el workflow: nunca aborta un backup en vuelo.
