# Månedens Verdensoverblik – byggenoter

Filer: index.html (bygget), data.js (alt indhold: window.VO), img/*.jpg (2560×1600, Unsplash, ingen kvinder/ʿawrah).

Månedlig opdatering = skift data.js + img/. index.html skal kun genbygges, hvis layout eller QR ændres:
  python: index.template.html → erstat {{MAP}} (svg fra map.json, viewBox "40 28 920 392"), {{MARKERS}} (map.json markers) og {{QR}} (qrcode-SVG af afstemningslinket) → index.html.
  build.mjs laver map.json (world-atlas countries-110m + d3-geo geoNaturalEarth1).

data.js-felter pr. sag: id, cat (lokalt|danmark|globalt|mellemosten|usa|kina), main, img, title, hook?, date, stat{v,l}, what, background[], consequences[{k,t}×3], islam{problem,solution,ref}, debate, source.
Desuden: month, period, top5[{id,why}], pause[{id,q}] (pauseskærm: skarpe spørgsmål til de 5 varmeste sager; vises kun når der trykkes P (automatisk visning fjernet efter ønske)), intro{ayah,tr,ref}, outro{points[3],ayah,tr,ref}.
Afstemning: Google Formular-link i FORM (QR) og svar-link i RESULTS (knappen "Se svarene") i index.template.html + QR.
Test: ingen overflow på 1920×1080, 1366×768, 1280×720 og 390×844.
Mini-kort pr. sag: feltet actors (ISO-numre, fx "840" USA) i data.js. Pins-koordinater i pins.json (laves af pins.mjs: tilføj land med lon/lat), indsættes som {{PINS}}. Danske landenavne i LAND-tabellen i skabelonen.
actors kan indeholde "*" (alle lande lyses svagt op, fx FN-topmøder) og actorNote overskriver teksten under kortet.
Forsidens rækkefølge: kategorierne sorteres efter top5 (den varmeste først, med mærket "Månedens vigtigste"); kan overstyres med D.catOrder. Flag er SVG (FLAG i skabelonen) – ingen flag-emojis, de vises ikke på Windows.
Billeder: img/*.jpg = HD 2560×1600 (q82) til one-pager og hovedkort; img/sm/*.jpg = 1000 px (q80) til fliser, små kort og afstemning. Lav begge, når billeder skiftes.

## GitHub Pages-version (nsj-mahaliyah/verdensoverblik)
- Live-afstemning: stem.html (telefon) + afstemningssiden (storskærm). Supabase-nøgler i config.js. Tabel oprettes med supabase/opsaetning.sql. pollId i data.js (fx "2026-11") – ny måned = ny afstemning automatisk.
- Uden internet: sw.js gemmer siden og billederne. Hæv VERSION i sw.js ved hver månedlig opdatering, og opdatér CORE-listen hvis billednavne ændres.
- Arkiv: før en ny måned lægges ind, kopieres den nuværende til arkiv/<pollId>/ (index.html med ../../config.js og VO_SW="../../sw.js", data.js og img/), og der tilføjes en linje i arkiv/maaneder.js.
- Styring: "Start afstemning" (ingen kode) og "Styring ▾" med kode til Stop / Nulstil alle svar. Når åben opdateres tallene hvert sekund. Kontrollerne er skjult på mobil. Koden skiftes i Supabase (se supabase/opsaetning.sql).
- Mobil: bundmenu (‹ Overblik · Stem · Pointer ›).
- Anonyme spørgsmål: spoerg.html (telefon, via lille QR øverst til højre eller tast Q for stor QR). admin.html = styring (kode): godkend/afvis spørgsmål med lyd + notifikation, vis/skjul på storskærm, start/stop/nulstil afstemning. QR til spoerg.html: src/qr_spoerg.svg ({{QRASK}} i skabelonen).
- Sceneskift: titelkort i 1,3 sek. når der bladres fra sag til sag. B = sort skærm (en vilkårlig tast/klik vender tilbage). Admin: "Slet alle spørgsmål".
- .github/workflows/hold-databasen-vaagen.yml kalder Supabase mandag og torsdag, så det gratis projekt ikke går i dvale. GitHub slår planlagte workflows fra efter 60 dage uden commits – de månedlige opdateringer holder det i gang.
