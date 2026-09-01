self.addEventListener('install', () => self.skipWaiting());
// build 2026-09-01T17-icono-oficial-og
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.map((k) => caches.delete(k)));
    await self.clients.claim();
    const clients = await self.clients.matchAll({ type: "window", includeUncontrolled: true });
    for (const client of clients) {
      client.postMessage({ type: "FC_SW_UPDATED" });
    }
  })());
});

self.addEventListener('message', (event) => {
  const data = event.data || {};
  if (data.type === 'SHOW_NOTIFICATION') {
    const title = data.titulo || 'FarmaCapital';
    const options = {
      body: data.cuerpo || '',
      icon: '/icons/farmacapital-192.png',
      badge: '/icons/farmacapital-96.png',
      tag: data.tag || 'farmacapital-staff',
      requireInteraction: true,
      data: { url: data.url || '/admin' },
      vibrate: [180, 80, 180],
    };
    event.waitUntil(self.registration.showNotification(title, options));
  }
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const url = event.notification?.data?.url || '/admin';
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clients) => {
      for (const client of clients) {
        if ('focus' in client) {
          client.postMessage({ type: 'FC_NOTIFICATION_CLICK', url });
          return client.focus();
        }
      }
      if (self.clients.openWindow) return self.clients.openWindow(url);
      return undefined;
    })
  );
});
