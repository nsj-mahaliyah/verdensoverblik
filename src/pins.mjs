import fs from 'fs';
import {geoNaturalEarth1} from 'd3-geo';
import {feature} from 'topojson-client';
const topo = JSON.parse(fs.readFileSync('node_modules/world-atlas/countries-110m.json'));
let fc = feature(topo, topo.objects.countries); fc.features = fc.features.filter(f=>f.id!=='010');
const proj = geoNaturalEarth1().fitExtent([[0,0],[1000,470]], fc);
const LL={"208":[9.5,56],"364":[53.7,32.4],"804":[31.2,49],"643":[60,58],"840":[-98,39],"784":[54.3,24],"004":[66,33.9],"792":[35,39],"634":[51.2,25.3],"376":[34.9,31.4],"275":[35.2,31.9],"156":[104,35]};
const out={}; for(const [k,v] of Object.entries(LL)) out[k]=proj(v).map(n=>+n.toFixed(1));
fs.writeFileSync('pins.json',JSON.stringify(out)); console.log(out);
