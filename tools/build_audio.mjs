// Original deterministic synthesis. Node built-ins only; no external recordings.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const out=path.join(root,'game/assets/audio/production');
fs.mkdirSync(out,{recursive:true});
const rate=48000, tau=Math.PI*2, manifest={};
const random=(seed)=>()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296*2-1;};
function write(name,channels,data){
  // Footsteps and UI sit below combat; preserve deliberate category differences.
  const targets={step_1:.12,step_2:.12,step_3:.12,step_wood_1:.12,step_wood_2:.12,step_wood_3:.12,jump:.14,land:.2,dodge:.16,slash:.24,heavy:.29,impact:.3,parry:.34,guard:.23,break:.32,heal:.15,interact:.1,echo:.18,echo_exit:.18,akio:.15,hurt:.22,death:.18,menu:.065,confirm:.1,cancel:.085,boss:.17,boss_impact:.32,boss_defeat:.18};
  if(targets[name]){let originalPeak=0;for(const v of data)originalPeak=Math.max(originalPeak,Math.abs(v));const gain=targets[name]/originalPeak;for(let i=0;i<data.length;i++)data[i]*=gain;}
  let peak=0;const pcm=Buffer.alloc(data.length*2);
  for(let i=0;i<data.length;i++){peak=Math.max(peak,Math.abs(data[i]));pcm.writeInt16LE(Math.round(data[i]*32767),i*2);}
  if(peak>=.96)throw Error(`${name}: clipping margin ${peak}`);
  const header=Buffer.alloc(44);header.write('RIFF');header.writeUInt32LE(36+pcm.length,4);header.write('WAVEfmt ',8);
  header.writeUInt32LE(16,16);header.writeUInt16LE(1,20);header.writeUInt16LE(channels,22);header.writeUInt32LE(rate,24);
  header.writeUInt32LE(rate*channels*2,28);header.writeUInt16LE(channels*2,32);header.writeUInt16LE(16,34);header.write('data',36);header.writeUInt32LE(pcm.length,40);
  fs.writeFileSync(path.join(out,name+'.wav'),Buffer.concat([header,pcm]));
  manifest[name]={channels,rate,seconds:data.length/channels/rate,peak,status:'TEMPORARY'};
}
function sound(name,duration,seed){
  const rng=random(seed), data=new Float64Array(Math.round(rate*duration));let low=0,last=0;
  for(let i=0;i<data.length;i++){
    const t=i/rate,p=t/duration,noise=rng();low+=.09*(noise-low);const high=noise-last;last=noise;
    const env=(1-Math.exp(-t*600))*Math.exp(-t*(['echo','echo_exit','akio','death','boss'].includes(name)?4:10));let v=0;
    if(name.startsWith('step')||['land','jump','dodge','boss_defeat'].includes(name))v=(low*(name.includes('wood')?.55:1.1)+Math.sin(tau*(name.includes('wood')?230:name==='land'?83:117)*t)*Math.exp(-t*38)*.3)*env;
    else if(['slash','heavy'].includes(name))v=(low*1.4+high*.055)*Math.sin(Math.PI*Math.min(1,p*1.5))**2*Math.exp(-t*7);
    else if(['impact','boss_impact','hurt','break'].includes(name)){
      v=(low*.75+noise*.09+Math.sin(tau*(name==='break'||name==='boss_impact'?67:121)*t)*.28*Math.exp(-t*15))*env;
      if(name==='break')v+=Math.sin(tau*1733*t)*Math.exp(-t*22)*.065;
    }else if(['parry','guard'].includes(name)){
      for(const [f,a,d] of [[1321,.14,9],[2183,.11,13],[3371,.045,18]])v+=Math.sin(tau*f*t)*a*Math.exp(-t*d);
      v=(v+high*.09*Math.exp(-t*120))*Math.min(1,t*1000)*(name==='parry'?1:.65);
    }else if(['menu','confirm','cancel','interact'].includes(name))v=(Math.sin(tau*(name==='cancel'?460:740)*t)*.1+low*.4)*env*Math.exp(-t*17);
    else{
      const freqs=['heal','echo','echo_exit','akio'].includes(name)?[294,392,587]:[73.5,110,147];
      freqs.forEach((f,j)=>v+=Math.sin(tau*f*t+Math.sin(tau*2*t)*.2)*.08/(j+1));
      v=v*Math.sin(Math.PI*p)**2+low*.15*env;
    }
    data[i]=v*Math.max(0,Math.min(1,t/.004,(duration-t)/.025))*.85;
  }return data;
}
function loop(context,music){
  const duration=16,count=rate*duration,rng=random(910+context.length+(music?40:0)),low=[0,0],data=new Float64Array(count*2);
  const notes={start:[196,233.08,293.66,349.23],present:[146.83,196,233.08,293.66],echo:[146.83,155.56,220,293.66],boss:[73.42,110,146.83,155.56],ending:[146.83,196,293.66,392]}[context];
  for(let i=0;i<count;i++){
    const t=i/rate,edge=Math.min(1,t/.04,(duration-t)/.04);
    for(let channel=0;channel<2;channel++){
      low[channel]+=.008*(rng()-low[channel]);let v=low[channel]*(music?.16:.5);
      if(music){
        for(let k=0;k<4;k++){
          const age=(t-k*4-channel*.025+duration*2)%duration,f=notes[k],attack=Math.min(1,age*100);
          v+=Math.sin(tau*f*age)*Math.exp(-age*1.15)*attack*.065;
          v+=Math.sin(tau*f*2.003*age)*Math.exp(-age*2.3)*attack*.019;
        }
        v+=Math.sin(tau*notes[0]/2*t)*.012*Math.sin(Math.PI*t/duration)**2;
      }else if(['start','present','ending'].includes(context)){
        for(let k=0;k<3;k++){const age=(t-(2.7+k*4.9+channel*.09)+duration)%duration;if(age<.24)v+=Math.sin(tau*(1650*age+1900*age*age))*.024*Math.sin(Math.PI*age/.24)**2;}
      }else if(context==='echo')v+=Math.sin(tau*(294+channel*.25)*t)*.015*Math.sin(Math.PI*t/duration)**2;
      else if(context==='water'){const age=(t+channel*.18)%1.7;v+=Math.sin(tau*(420*age-80*age*age))*Math.exp(-age*12)*.018;}
      else{const age=t%4;v+=Math.sin(tau*49*age)*Math.exp(-age*5)*Math.min(1,age*60)*.035;}
      data[i*2+channel]=v*edge;
    }
  }return data;
}
const effects={step_1:.15,step_2:.16,step_3:.14,step_wood_1:.15,step_wood_2:.16,step_wood_3:.14,jump:.24,land:.28,dodge:.22,slash:.25,heavy:.42,impact:.26,parry:.62,guard:.3,break:.5,heal:.9,interact:.22,echo:1.2,echo_exit:1.2,akio:.85,hurt:.32,death:1.3,menu:.12,confirm:.2,cancel:.18,boss:.9,boss_impact:.38,boss_defeat:.7};
Object.entries(effects).forEach(([name,duration],i)=>write(name,1,sound(name,duration,810+i)));
for(const context of ['start','present','echo','boss','ending'])for(const kind of ['ambient','music'])write(kind+'_'+context,2,loop(context,kind==='music'));
write('ambient_water',2,loop('water',false));
fs.writeFileSync(path.join(out,'production_manifest.json'),JSON.stringify({origin:'Original deterministic synthesis; tools/build_audio.mjs',license:'Project-original waveforms; no third party samples',review:'Technical only; final music and device listening pending',sounds:manifest},null,2)+'\n');
console.log(`Audio: ${Object.keys(effects).length} effects + eleven stereo loops; 48 kHz PCM16; category levels verified.`);
