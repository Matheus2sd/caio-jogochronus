// Inspect exported PCM, including relative levels and loop seams. No packages.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const folder=path.join(root,'game/assets/audio/production');
const manifest=JSON.parse(fs.readFileSync(path.join(folder,'production_manifest.json'),'utf8'));
const report={status:'COMPLETE technical / TEMPORARY artistic',checks:[],sounds:{}};
function check(ok,message){if(!ok)throw Error(message);report.checks.push(message);}
for(const [name,meta] of Object.entries(manifest.sounds)){
 const data=fs.readFileSync(path.join(folder,name+'.wav'));let peak=0,sum=0;
 check(data.toString('ascii',0,4)==='RIFF'&&data.readUInt32LE(24)===48000,name+': 48 kHz WAV');
 const samples=(data.length-44)/2;
 for(let i=44;i<data.length;i+=2){const x=data.readInt16LE(i)/32768;peak=Math.max(peak,Math.abs(x));sum+=x*x;}
 check(peak<.96&&peak>.005,name+': nonempty and no clipping');
 const channels=data.readUInt16LE(22);
 const seam=Math.abs(data.readInt16LE(44)-data.readInt16LE(data.length-channels*2))/32768;
 if(channels===2)check(seam<.001,name+': low-discontinuity loop boundary');
 report.sounds[name]={peak_db:20*Math.log10(peak),rms_db:10*Math.log10(sum/samples),duration:samples/channels/48000,seam};
 check(Math.abs(report.sounds[name].duration-meta.seconds)<.001,name+': declared duration');
}
check(report.sounds.step_1.peak_db<report.sounds.parry.peak_db-6,'Footsteps below parry');
check(report.sounds.menu.peak_db<report.sounds.impact.peak_db-8,'UI below combat');
check(new Set(['step_1','step_2','step_3'].map(n=>fs.readFileSync(path.join(folder,n+'.wav')).toString('base64'))).size===3,'Three distinct footstep variants');
const out=path.join(root,'docs/audio/chapter1');fs.mkdirSync(out,{recursive:true});
fs.writeFileSync(path.join(out,'audio_validation.json'),JSON.stringify(report,null,2)+'\n');
console.log(`AUDIO ASSETS PASS: ${Object.keys(report.sounds).length} WAVs; peaks, relative levels, duration, variants and loop seams.`);
