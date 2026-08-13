'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "ebbe0961239ae39f27a1403c6655da8c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"index.html": "5b20d94c6af49675b701179a42b19446",
"/": "5b20d94c6af49675b701179a42b19446",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"assets/AssetManifest.json": "503ad80603a52c79b23301f669c9c28c",
"assets/AssetManifest.bin.json": "8edb7afecb13e388d5d332015cb676a5",
"assets/NOTICES": "6eafe60c32402798c6407a5bfe1b14f9",
"assets/fonts/MaterialIcons-Regular.otf": "408b2b12c6bf8a5e8fc275548f3c4b04",
"assets/FontManifest.json": "ff58e38fd18602b0307a375b11f32810",
"assets/AssetManifest.bin": "ff7a529fb56d5b3b8253c768826168c3",
"assets/assets/images/sketches/46.png": "570717a97037ba26c29b9faafe5a63d5",
"assets/assets/images/sketches/75.png": "6f6f559d331e4dca3d21e79d892abe30",
"assets/assets/images/sketches/56.png": "85679558ccafaf31a13a7161d82476b8",
"assets/assets/images/sketches/6.png": "25f2bd1ae4f6f78d6d63f2fbafecbd6b",
"assets/assets/images/sketches/26.png": "24bf00030abdb294bf4c716ce0f74d33",
"assets/assets/images/sketches/16.png": "03842fa5d951a0b614e4dacd94264345",
"assets/assets/images/sketches/65.png": "25eeee20d000afc765624d36c38d0817",
"assets/assets/questions.json": "89a6c328979e725cd8a01ebd3d29d910",
"assets/assets/courses/sachkundenachweis/questions.json": "7ef949361699700a9750c1eee594c2e9",
"assets/assets/courses/begleithund/questions.json": "daac7c274c56c0320c5c9599c19f4b98",
"assets/assets/courses/fibutroniker/questions.json": "d3525dcd2dff7f627036ce1b979b862f",
"assets/assets/fonts/Montserrat-Bold.ttf": "8b88a4090df930c276c69a633181d12e",
"assets/assets/fonts/Nunito-Bold.ttf": "baafe6f458c23aa85f0a96f53194aab6",
"assets/assets/fonts/Nunito-Regular.ttf": "063be819638e89599fff4ae8c05ca232",
"assets/assets/fonts/Montserrat-Regular.ttf": "ac1552693039e7011b3426dba40229b1",
"assets/assets/fonts/Inter-Bold.ttf": "06059b89f55c90a4ce7f1f97573c2180",
"assets/assets/fonts/Inter-Regular.ttf": "60379e095640a35194d7f82b9f56d4d3",
"assets/assets/animations/firework.json": "8d068d1989205c3cd9d0a61ae558cbba",
"assets/assets/animations/trophy.json": "06363136e1a81639b8ae12789528088c",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"main.dart.js": "a9cefff8ca99d07d83ad47f2f5021276",
"flutter_bootstrap.js": "391764ffd25c20a8b35f9b3cf2343cb2",
"manifest.json": "ee4efba6776228dab5077221da873f74"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
