/**
 * JWT Decoder Service Worker
 * 
 * This service worker implements a cache-first strategy with proper
 * cache versioning to prevent stale content issues.
 */

// Cache version - increment this when making changes
const CACHE_VERSION = 'v2';
const CACHE_NAME = 'jwt-decoder-' + CACHE_VERSION;

// Assets to cache
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/sw.js'
];

// Install event - cache static assets
self.addEventListener('install', function(event) {
  console.log('[SW] Installing service worker version', CACHE_VERSION);
  
  event.waitUntil(
    caches.open(CACHE_NAME).then(function(cache) {
      console.log('[SW] Caching static assets');
      return cache.addAll(STATIC_ASSETS);
    }).then(function() {
      // Skip waiting to activate immediately
      return self.skipWaiting();
    })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', function(event) {
  console.log('[SW] Activating service worker version', CACHE_VERSION);
  
  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(
        cacheNames.map(function(cacheName) {
          // Delete any cache that doesn't match the current version
          if (cacheName !== CACHE_NAME) {
            console.log('[SW] Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(function() {
      // Take control of all clients immediately
      return self.clients.claim();
    })
  );
});

// Fetch event - cache-first strategy with network fallback
self.addEventListener('fetch', function(event) {
  const request = event.request;
  
  // Only handle GET requests
  if (request.method !== 'GET') {
    return;
  }
  
  // Skip non-same-origin requests
  if (!request.url.startsWith(self.location.origin)) {
    return;
  }
  
  event.respondWith(
    caches.match(request).then(function(cachedResponse) {
      if (cachedResponse) {
        // Return cached response immediately
        // Then fetch from network to update cache (background refresh)
        fetch(request).then(function(networkResponse) {
          if (networkResponse && networkResponse.status === 200) {
            caches.open(CACHE_NAME).then(function(cache) {
              cache.put(request, networkResponse.clone());
            });
          }
        }).catch(function(err) {
          // Network fetch failed, but we already returned cached version
          console.log('[SW] Background refresh failed:', err);
        });
        
        return cachedResponse;
      }
      
      // Not in cache, fetch from network
      return fetch(request).then(function(networkResponse) {
        // Don't cache non-successful responses
        if (!networkResponse || networkResponse.status !== 200) {
          return networkResponse;
        }
        
        // Clone the response before caching
        const responseToCache = networkResponse.clone();
        
        caches.open(CACHE_NAME).then(function(cache) {
          cache.put(request, responseToCache);
        });
        
        return networkResponse;
      });
    }).catch(function(err) {
      console.error('[SW] Fetch error:', err);
      // Return a fallback if available
      return new Response('Network error', { status: 503, statusText: 'Service Unavailable' });
    })
  );
});

// Message event - handle messages from main thread
self.addEventListener('message', function(event) {
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
  }
});
