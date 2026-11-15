/* Månedens Verdensoverblik – virker uden internet.
   HTML/JS hentes friskt når der er net (så månedens opdatering slår igennem), ellers fra gemt kopi.
   Billeder og skrifttyper gemmes og vises fra gemt kopi. */
const VERSION = "vo-2026-11-v1";
const CORE = ["./", "index.html", "data.js", "config.js", "stem.html", "img/apec.jpg", "img/benzin.jpg", "img/boenekald.jpg", "img/cop31.jpg", "img/drikkevand.jpg", "img/eksport.jpg", "img/fed.jpg", "img/gaza.jpg", "img/handel.jpg", "img/hormuz.jpg", "img/icc.jpg", "img/israel.jpg", "img/midtvejsvalg.jpg", "img/nojsomhed.jpg", "img/screening.jpg", "img/taliban.jpg", "img/trivsel.jpg", "img/ukraine.jpg", "img/sm/apec.jpg", "img/sm/benzin.jpg", "img/sm/boenekald.jpg", "img/sm/cop31.jpg", "img/sm/drikkevand.jpg", "img/sm/eksport.jpg", "img/sm/fed.jpg", "img/sm/gaza.jpg", "img/sm/handel.jpg", "img/sm/hormuz.jpg", "img/sm/icc.jpg", "img/sm/israel.jpg", "img/sm/midtvejsvalg.jpg", "img/sm/nojsomhed.jpg", "img/sm/screening.jpg", "img/sm/taliban.jpg", "img/sm/trivsel.jpg", "img/sm/ukraine.jpg"];
self.addEventListener("install", e=>{
  e.waitUntil(caches.open(VERSION).then(c=>Promise.all(CORE.map(u=>c.add(u).catch(()=>{})))).then(()=>self.skipWaiting()));
});
self.addEventListener("activate", e=>{
  e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==VERSION).map(k=>caches.delete(k)))).then(()=>self.clients.claim()));
});
self.addEventListener("fetch", e=>{
  const req=e.request; if(req.method!=="GET") return;
  const url=new URL(req.url);
  if(url.hostname.endsWith("supabase.co")) return;               // stemmer altid live
  const isPage = req.mode==="navigate" || /\.(html|js|json)$/.test(url.pathname) || url.pathname.endsWith("/");
  if(isPage){
    e.respondWith(fetch(req).then(r=>{ const cp=r.clone(); caches.open(VERSION).then(c=>c.put(req,cp)); return r; })
      .catch(()=>caches.match(req).then(r=>r||caches.match("index.html"))));
  }else{
    e.respondWith(caches.match(req).then(hit=>hit||fetch(req).then(r=>{ if(r.ok||r.type==="opaque"){ const cp=r.clone(); caches.open(VERSION).then(c=>c.put(req,cp)); } return r; })));
  }
});
