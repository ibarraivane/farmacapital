import base64, os, urllib.request
src = os.path.expanduser('~/farmax/src')
print('Regenerando Tienda.jsx...')
# Usar el archivo original de la carpeta Farmax-web
import shutil
src_file = '/Users/ibarra/Documents/Farmax-web/farmax-web/farmax-tienda.jsx'
dst_file = os.path.join(src, 'Tienda.jsx')
if os.path.exists(src_file):
    shutil.copy(src_file, dst_file)
    print(f'  OK Tienda.jsx copiado desde Farmax-web ({os.path.getsize(dst_file):,} bytes)')
else:
    print(f'  ERROR: No se encontro {src_file}')
    print('  Archivos disponibles:')
    folder = '/Users/ibarra/Documents/Farmax-web/farmax-web/'
    if os.path.exists(folder):
        for f in os.listdir(folder): print(f'    - {f}')
