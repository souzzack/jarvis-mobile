const fs=require('fs');const vm=require('vm');
const v8=fs.readFileSync(process.argv[2],'utf8').split('\n'),v9=fs.readFileSync(process.argv[3],'utf8').split('\n');
const take=(L,a,b)=>L.slice(a-1,b).join('\n');
const end=v8.findIndex((l,i)=>i>=160&&l.includes('return d;}'))+1;
const c8=take(v8,82,82)+'\n'+take(v8,89,101)+'\n'+take(v8,122,141)+'\n'+take(v8,156,end)+'\nthis.sdfB=sdfB;this.sdfOld=sdfOld;';
const s9=v9.findIndex(l=>l.startsWith('function sdE'));const e9=v9.findIndex(l=>l.startsWith('function sculpt'));
const h9=v9.findIndex(l=>l.startsWith('const clamp'));
const c9=v9[h9]+'\n'+v9.slice(s9,e9).join('\n')+'\nthis.sdf=sdf;';
const A={},B={};vm.runInNewContext(c8,A);vm.runInNewContext(c9,B);
function sil(f,axis){/* projeção: true se algum ponto ao longo do eixo está dentro */const N=150,out=new Uint8Array(N*N);const R={x:[-.9,.9],y:[-.1,1.6],z:[-3.4,1.4]};
  const [u,v,w]=axis==='side'?['z','y','x']:['x','y','z'];
  for(let i=0;i<N;i++)for(let j=0;j<N;j++){const pu=R[u][0]+(R[u][1]-R[u][0])*(i+.5)/N,pv=R[v][0]+(R[v][1]-R[v][0])*(j+.5)/N;
    for(let k=0;k<70;k++){const pw=R[w][0]+(R[w][1]-R[w][0])*(k+.5)/70;const p={[u]:pu,[v]:pv,[w]:pw};if(f(p.x,p.y,p.z)<0){out[i*N+j]=1;break;}}}return out;}
const iou=(a,b)=>{let I=0,U=0;for(let i=0;i<a.length;i++){I+=a[i]&b[i];U+=a[i]|b[i];}return (I/U*100).toFixed(1)+'%';};
for(const ax of ['side','front']){const s9=sil(B.sdf,ax),sB=sil(A.sdfB,ax),sO=sil(A.sdfOld,ax);console.log(ax,'v9×ConceitoB',iou(s9,sB),' v9×V7',iou(s9,sO),' B×V7',iou(sB,sO));}
/* volume: pontos internos em comum */
let inB=0,in9=0,both=0;for(let n=0;n<200000;n++){const x=-.9+Math.random()*1.8,y=-.1+Math.random()*1.7,z=-3.4+Math.random()*4.8;const a=A.sdfB(x,y,z)<0,b=B.sdf(x,y,z)<0;inB+=a;in9+=b;both+=a&&b;}
console.log('volume IoU v9×B',(both/(inB+in9-both)*100).toFixed(1)+'%');
