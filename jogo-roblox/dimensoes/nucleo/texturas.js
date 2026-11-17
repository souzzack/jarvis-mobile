/* Magnata do Multiverso · Dimensões — texturas PBR procedurais (repetíveis, sem emenda)
   Cada material gera cor (albedo), normal (relevo) e aspereza a partir de ruído periódico. Nada vem de arquivo externo:
   tudo pode ser exportado em PNG para virar MaterialVariant/SurfaceAppearance no Roblox. */
(function(){const MM=window.MM,T=THREE;
function H(x,y,s){let h=Math.imul(x|0,374761393)^Math.imul(y|0,668265263)^Math.imul(s|0,1442695041);h=Math.imul(h^(h>>>13),1274126177);h^=h>>>16;return(h>>>0)/4294967296;}
/* ruído de valor periódico (período P células) e fbm periódico */
function pn(x,y,P,s){const xi=Math.floor(x),yi=Math.floor(y),xf=x-xi,yf=y-yi;const u=xf*xf*(3-2*xf),v=yf*yf*(3-2*yf);const m=k=>((k%P)+P)%P;
  const a=H(m(xi),m(yi),s),b=H(m(xi+1),m(yi),s),c=H(m(xi),m(yi+1),s),d=H(m(xi+1),m(yi+1),s);return a+(b-a)*u+(c-a)*v+(a-b-c+d)*u*v;}
function pfbm(x,y,P,o,s){let t=0,a=.5,f=1,n=0;for(let i=0;i<o;i++){t+=a*pn(x*f,y*f,P*f,s+i*7);n+=a;a*=.5;f*=2;}return t/n;}
/* Worley periódico: devolve F1, F2 e o id da célula */
function worley(x,y,P,s){const xi=Math.floor(x),yi=Math.floor(y);let f1=9,f2=9,id=0;for(let j=-1;j<=1;j++)for(let i=-1;i<=1;i++){const cx=xi+i,cy=yi+j;const wx=((cx%P)+P)%P,wy=((cy%P)+P)%P;
    const px=cx+H(wx,wy,s),py=cy+H(wx,wy,s+1);const d=Math.hypot(px-x,py-y);if(d<f1){f2=f1;f1=d;id=H(wx,wy,s+2);}else if(d<f2)f2=d;}return{f1,f2,id};}
const C3=h=>{const c=new T.Color(h);return[c.r,c.g,c.b];};const mix=(a,b,t)=>[a[0]+(b[0]-a[0])*t,a[1]+(b[1]-a[1])*t,a[2]+(b[2]-a[2])*t];
const sst=(a,b,x)=>{const t=Math.max(0,Math.min(1,(x-a)/(b-a)));return t*t*(3-2*t);};
/* monta as três texturas a partir de uma função por pixel → {cor, altura, aspereza} */
function make(N,fn,strength){const col=new Uint8ClampedArray(N*N*4),hgt=new Float32Array(N*N),rgh=new Uint8ClampedArray(N*N*4);
  for(let y=0;y<N;y++)for(let x=0;x<N;x++){const r=fn(x/N,y/N);const k=y*N+x;col[k*4]=r.c[0]*255;col[k*4+1]=r.c[1]*255;col[k*4+2]=r.c[2]*255;col[k*4+3]=255;hgt[k]=r.h;const g=r.r*255;rgh[k*4]=g;rgh[k*4+1]=g;rgh[k*4+2]=g;rgh[k*4+3]=255;}
  const nrm=new Uint8ClampedArray(N*N*4);const at=(x,y)=>hgt[((y+N)%N)*N+((x+N)%N)];
  for(let y=0;y<N;y++)for(let x=0;x<N;x++){const dx=(at(x+1,y)-at(x-1,y))*strength,dy=(at(x,y+1)-at(x,y-1))*strength;const l=Math.hypot(dx,dy,1);const k=(y*N+x)*4;nrm[k]=(-dx/l*.5+.5)*255;nrm[k+1]=(dy/l*.5+.5)*255;nrm[k+2]=(1/l*.5+.5)*255;nrm[k+3]=255;}
  const tex=(arr,srgb)=>{const c=document.createElement('canvas');c.width=c.height=N;c.getContext('2d').putImageData(new ImageData(arr,N,N),0,0);const t=new T.CanvasTexture(c);t.wrapS=t.wrapT=T.RepeatWrapping;t.anisotropy=4;if(srgb)t.encoding=T.sRGBEncoding;return t;};
  return{map:tex(col,true),normalMap:tex(nrm,false),roughnessMap:tex(rgh,false)};}
const G={};
/* rocha estratificada com fraturas e grão */
G.rocha=(N=512)=>{const A=C3('#55524f'),B=C3('#716c66'),D=C3('#2e2b2a'),V=C3('#5d5862');return make(N,(u,v)=>{const w=pfbm(u*4,v*4,4,4,11);const band=(.5+.5*Math.sin((v+w*.5)*Math.PI*2*3))*(.3+.7*pfbm(u*3,v*3,3,3,12));
    const W=worley(u*3,v*9,3,21);const keep=W.id>.62?1:0;/* só algumas bordas viram fratura */const crack=(1-sst(0,.035,W.f2-W.f1))*keep*sst(.3,.6,pfbm(u*6,v*6,6,3,22));
    const grain=pfbm(u*32,v*32,32,3,31);const layer=pfbm(u*2,v*24,2,4,23);/* camadas finas horizontais */
    let c=mix(A,B,sst(.3,.8,band)*.7+grain*.2+layer*.25);c=mix(c,V,sst(.6,.9,pfbm(u*3,v*3,3,3,41))*.3);c=mix(c,D,crack*.8);
    const h=band*.4+layer*.35+grain*.2-crack*.9;return{c,h,r:.78+.15*grain+crack*.07};},4.5);};
/* musgo e grama rasteira */
G.musgo=(N=256)=>{const A=C3('#3c5a43'),B=C3('#5d7a4c'),D=C3('#28392f'),Y=C3('#7d8a55');return make(N,(u,v)=>{const n=pfbm(u*8,v*8,8,4,51),f=pfbm(u*40,v*40,40,2,52);
    let c=mix(D,A,sst(.25,.6,n));c=mix(c,B,sst(.55,.85,n)*.8);c=mix(c,Y,sst(.75,.95,f)*.25);return{c,h:n*.6+f*.4,r:.9};},3);};
/* terra úmida com pedrinhas */
G.terra=(N=256)=>{const A=C3('#3d3431'),B=C3('#554a43'),P=C3('#7a736c');return make(N,(u,v)=>{const n=pfbm(u*10,v*10,10,4,61);const W=worley(u*14,v*14,14,62);const peb=sst(.42,.28,W.f1)*(W.id>.55?1:0);
    let c=mix(A,B,n*.7);c=mix(c,mix(P,B,W.id),peb);return{c,h:n*.3+peb*.8*(1-W.f1),r:.55+.3*(1-peb)};},4);};
/* calçamento de lajes (trilhas) */
G.lajes=(N=512)=>{const A=C3('#8d8a84'),B=C3('#6f6c68'),M=C3('#3b3936');return make(N,(u,v)=>{const W=worley(u*7,v*7,7,71);const edge=sst(.0,.09,W.f2-W.f1);const n=pfbm(u*24,v*24,24,3,72);
    let c=mix(A,B,W.id*.7+n*.3);c=mix(M,c,edge);return{c,h:edge*(.6+.2*n),r:.6+.25*(1-edge)};},5);};
/* alvenaria: fiadas de blocos chanfrados, com desgaste nas quinas */
G.blocos=(N=512)=>{const A=C3('#726c68'),B=C3('#89837c'),M=C3('#2f2c2b');return make(N,(u,v)=>{const rows=6,cols=3;const ry=v*rows,row=Math.floor(ry);const rx=u*cols+(row%2)*.5;const col=Math.floor(rx);
    const fx=rx-col,fy=ry-row;const id=H(((col%cols)+cols)%cols,row,81);const e=Math.min(fx,1-fx,fy*1.6,(1-fy)*1.6);const bev=sst(0,.06,e);const n=pfbm(u*20,v*20,20,3,82);
    let c=mix(A,B,id*.6+n*.3);c=mix(c,C3('#9a97a1'),sst(.06,.02,e)*.3);c=mix(M,c,sst(.005,.02,e));return{c,h:bev*.8+n*.15,r:.82+.1*n};},6);};
/* metal envelhecido: riscos, encardido e pontos de ferrugem */
G.metal=(N=256)=>{const A=C3('#8a93a3'),D=C3('#4d5260'),R=C3('#6e4e3c');return make(N,(u,v)=>{const g=pfbm(u*6,v*6,6,4,91);const s=Math.pow(pn(u*2,v*90,2,92),6);const rust=sst(.7,.85,pfbm(u*5,v*5,5,4,93));
    let c=mix(A,D,g*.6);c=mix(c,C3('#b6bdc9'),s*.5);c=mix(c,R,rust*.7);return{c,h:g*.2-rust*.3,r:.32+g*.3+rust*.4};},2);};
/* cobre com pátina verde-azulada escorrida */
G.cobre=(N=256)=>{const Cu=C3('#a5683c'),Cl=C3('#c98a55'),Pt=C3('#4f9a8a'),Pd=C3('#2f6b63');return make(N,(u,v)=>{const g=pfbm(u*5,v*5,5,4,101);const drip=pfbm(u*14,v*1.5,14,3,102);const p=sst(.58,.74,g*.7+drip*.45);
    let c=mix(Cu,Cl,pfbm(u*16,v*16,16,2,103)*.6);c=mix(c,mix(Pt,Pd,g),p);return{c,h:p*.4+g*.2,r:.35+p*.5};},2);};
/* faixa de inscrições antigas (para pedra entalhada; o canal de cor serve de máscara emissiva) */
G.runas=(N=512)=>{const c=document.createElement('canvas');c.width=N;c.height=N/4;const g=c.getContext('2d');g.fillStyle='#000';g.fillRect(0,0,N,N/4);g.strokeStyle='#fff';g.lineWidth=5;g.lineCap='round';
  const r=MM.rng(7);for(let i=0;i<14;i++){const x0=12+i*(N-24)/14,w=(N-24)/14-10,y0=18,h=N/4-36;g.beginPath();const k=3+Math.floor(r()*3);for(let s=0;s<k;s++){const a=[x0+r()*w,y0+r()*h],b=[x0+r()*w,y0+r()*h];g.moveTo(a[0],a[1]);if(r()<.4)g.arc(a[0],a[1],4+r()*8,0,Math.PI*2);else g.lineTo(b[0],b[1]);}g.stroke();}
  const t=new T.CanvasTexture(c);t.wrapS=T.RepeatWrapping;return t;};
MM.tex={};MM.makeTextures=function(){const t0=performance.now();for(const k of ['rocha','musgo','terra','lajes','blocos','metal','cobre'])MM.tex[k]=G[k]();MM.tex.runas=G.runas();MM.tex.ms=Math.round(performance.now()-t0);return MM.tex;};
})();
