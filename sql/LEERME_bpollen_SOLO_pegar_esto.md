# Qué hacer ahora (BPOllen amarillos)

## Pasos

1. Abre **Supabase** → tu proyecto FarmaCapital → **SQL Editor** → **New query**.
2. Abre este archivo en GitHub (botón **Raw**):
   `sql/patch_bpollen_SOLO_pegar_esto.sql`
3. **Ctrl+A / Cmd+A** → copiar TODO.
4. Pega en el SQL Editor → **Run**.
5. Abajo deben salir **2 productos** (BPOllen 5% y 2.5%) y los renglones con `pendiente_alta = false`.
6. En la tablet: **Recibir** → recargar → Nadro → ya no pide alta → teclea **MMAA** de la caja → Guardar.

## Si Run marca error

Copia el mensaje rojo completo y mándalo. No pegues el archivo largo `…_TODOS.sql`; usa solo este.

## Si los productos salen bien pero Recibir sigue amarillo

Recarga fuerte la PWA (cerrar pestaña / “Actualizar” del admin) y vuelve a abrir el ticket Nadro.
