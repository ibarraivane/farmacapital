-- Reemplaza la URL del banner genéricos que aún apunta al PNG 1920×840.
-- Ejecutar DESPUÉS de subir el archivo nuevo desde Admin → Banners
-- (nombre distinto, ej. farmacapital-genericos-desktop-1920x600-<timestamp>.png).
--
-- 1) Revisa qué hay hoy:
--    select id, titulo, imagen_url, imagen_mobile_url, modo_visualizacion
--      from public.banners where slot = 'hero';
--
-- 2) Si ya subiste el PNG 1920×600, pega la URL pública completa en el UPDATE manual (abajo).
-- 3) Este patch usa imagen_mobile_url (columna estándar). Si también tienes imagen_url_mobile,
--    ejecuta antes sql/banners_imagen_url_mobile.sql o el bloque opcional al final.

begin;

-- Opcional: URL exacta del archivo nuevo (Storage → copiar enlace público)
-- update public.banners
--    set imagen_url = 'https://TU-PROYECTO.supabase.co/storage/v1/object/public/banners/farmacapital-genericos-desktop-1920x600-XXXXXXXX.png?v=...',
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
   set imagen_mobile_url = replace(coalesce(imagen_mobile_url, ''), '1920x840', '1920x600')
 where coalesce(imagen_mobile_url, '') ilike '%1920x840%';

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
