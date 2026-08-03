-- Reemplaza la URL del banner genéricos que aún apunta al PNG 1920×840.
-- Ejecutar DESPUÉS de subir el archivo nuevo desde Admin → Banners
-- (nombre distinto, ej. farmacapital-genericos-desktop-1920x600-<timestamp>.png).
--
-- 1) Revisa qué hay hoy:
--    select id, titulo, imagen_url, imagen_url_mobile, modo_visualizacion from public.banners where slot = 'hero';
--
-- 2) Si ya subiste el PNG 1920×600, pega la URL pública completa abajo y descomenta el UPDATE manual.
-- 3) El bloque automático solo corrige filas que aún contienen "1920x840" en la URL.

begin;

-- Opcional: URL exacta del archivo nuevo (Storage → copiar enlace público)
-- \set nueva_url_desktop 'https://TU-PROYECTO.supabase.co/storage/v1/object/public/banners/farmacapital-genericos-desktop-1920x600-XXXXXXXX.png?v=...'

-- update public.banners
--    set imagen_url = :'nueva_url_desktop',
--        titulo = '',
--        subtitulo = '',
--        descripcion = '',
--        modo_visualizacion = 'imagen_completa'
--  where slot = 'hero'
--    and (titulo ilike '%genéric%' or titulo ilike '%generico%' or imagen_url ilike '%genericos%');

update public.banners
   set imagen_url = replace(imagen_url, '1920x840', '1920x600')
 where imagen_url ilike '%1920x840%';

update public.banners
   set imagen_url = replace(imagen_url, 'farmacapital-genericos-desktop-1920x840', 'farmacapital-genericos-desktop-1920x600')
 where imagen_url ilike '%farmacapital-genericos-desktop-1920x840%';

update public.banners
   set imagen_url_mobile = replace(coalesce(imagen_url_mobile, ''), '1920x840', '1920x600')
 where coalesce(imagen_url_mobile, '') ilike '%1920x840%';

-- Sin copy superpuesto cuando el arte ya trae texto
update public.banners
   set titulo = '',
       subtitulo = '',
       descripcion = ''
 where slot = 'hero'
   and coalesce(modo_visualizacion, 'imagen_completa') = 'imagen_completa'
   and (
     titulo ilike '%genéric%' or titulo ilike '%generico%'
     or titulo ilike '%consulta%'
   );

commit;
