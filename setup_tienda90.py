import base64, os
src = os.path.expanduser('~/farmax/src')
b64 = ''
b64 += 'aW1wb3J0IHsgdXNlU3RhdGUsIHVzZUVmZmVjdCwgdXNlUmVmIH0gZnJvbSAicmVhY3QiOwp'
b64 += 'cbW1wb3J0IHsgdXNlU3RhdGUsIHVzZUVmZmVjdCwgdXNlUmVmIH0gZnJvbSAicmVhY3QiOwp'
with open(os.path.join(src, 'Tienda.jsx'), 'wb') as f:
    f.write(base64.b64decode(b64))
print('  ✅ Tienda.jsx actualizado')
