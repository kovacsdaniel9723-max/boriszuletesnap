const CACHE_NAME = 'bori-birthday-v1';
const urlsToCache = [
    '/',
    '/Bori_szuletesnap.html',
    '/bori_birthday.jpg',
    '/static/css/style.css',
    '/static/js/app.js'
];

// Service Worker telepítése
self.addEventListener('install', function(event) {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(function(cache) {
                console.log('Cache megnyitva');
                return cache.addAll(urlsToCache);
            })
    );
});

// Service Worker aktiválása
self.addEventListener('activate', function(event) {
    event.waitUntil(
        caches.keys().then(function(cacheNames) {
            return Promise.all(
                cacheNames.map(function(cacheName) {
                    if (cacheName !== CACHE_NAME) {
                        console.log('Régi cache törlése:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
});

// Fetch események kezelése
self.addEventListener('fetch', function(event) {
    event.respondWith(
        caches.match(event.request)
            .then(function(response) {
                // Cache hit - visszaadjuk a cache-ből
                if (response) {
                    return response;
                }
                
                return fetch(event.request).then(
                    function(response) {
                        // Ellenőrizzük, hogy érvényes válasz-e
                        if (!response || response.status !== 200 || response.type !== 'basic') {
                            return response;
                        }
                        
                        // Klónozzuk a választ
                        var responseToCache = response.clone();
                        
                        caches.open(CACHE_NAME)
                            .then(function(cache) {
                                cache.put(event.request, responseToCache);
                            });
                        
                        return response;
                    }
                );
            })
    );
});

// Push értesítések kezelése
self.addEventListener('push', function(event) {
    const options = {
        body: event.data ? event.data.text() : 'Új értesítés Borinak!',
        icon: '/bori_birthday.jpg',
        badge: '/bori_birthday.jpg',
        vibrate: [100, 50, 100],
        data: {
            dateOfArrival: Date.now(),
            primaryKey: 1
        },
        actions: [
            {
                action: 'explore',
                title: 'Megnézem',
                icon: '/bori_birthday.jpg'
            },
            {
                action: 'close',
                title: 'Bezárás',
                icon: '/bori_birthday.jpg'
            }
        ]
    };
    
    event.waitUntil(
        self.registration.showNotification('Bori Születésnap', options)
    );
});

// Notification click kezelése
self.addEventListener('notificationclick', function(event) {
    event.notification.close();
    
    if (event.action === 'explore') {
        event.waitUntil(
            clients.openWindow('/')
        );
    }
});
