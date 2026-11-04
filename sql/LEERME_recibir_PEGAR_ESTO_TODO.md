# Recibir — UN SOLO pegado (estado + faltantes)

## Qué hace

1. **Diagnóstico** de los 14 folios recientes (veredicto por fila).
2. **Reabre** solo tickets cerrados **sin stock** (`lote_id` vacío). No toca lo ya recibido bien.
3. **Crea / refresca** lo que falta en cola.
4. Nadro **6091723171**: solo arregla BPOllen (no borra lo ya escaneado).
5. Agrega Nadro **6091546907** (Dove / Memantina / Zolufen) que faltaba.

## Pasos (fácil)

Si el archivo grande cuesta pegar, usa las **2 partes**:

1. `sql/patch_recibir_PEGAR_ESTO_TODO_parte1.sql` → Run
2. `sql/patch_recibir_PEGAR_ESTO_TODO_parte2.sql` → Run
3. Mira **VERIFICACION**: `OK visible en Recibir` / `YA RECIBIDO` / `NO EXISTE`
4. Tablet: **Recibir** → pestaña Tickets → recargar

O pega el archivo completo `patch_recibir_PEGAR_ESTO_TODO.sql`.

Si Run marca rojo: copia el mensaje completo.

## Folios

| Proveedor | Folio | Nota |
|---|---|---|
| Tenorio | 3838940 | $1,148.52 |
| Fanasa | B49445264 · B49397867 | Fluxedan · Lubrex |
| Nadro | 6091110421 · 6091723171 · 6091546907 | BPOllen solo arregla amarillos del 609172 |
| Levic | 9012545305 · 9012442706 | |
| Equilibrio | 450233 · 450041 | |
| Cityfarma | S336478 · S336493 | |
| Bodega F-42 | 76370 | |
| Farmalive | 11104 | |
