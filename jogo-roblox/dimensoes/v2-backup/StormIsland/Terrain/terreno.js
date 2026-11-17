/* Ilha das Tempestades · Terrain · V2 (reconstrução cinematográfica)
   Campo de alturas de 1,5 stud em blocos com 2 níveis de detalhe. Cordilheira assimétrica (cristas com domínio torcido no eixo NO–SE),
   ravinas de erosão, estratos geológicos que viram degraus nas encostas, fissuras naturais. Material triplanar (rocha nos paredões,
   musgo, terra úmida e lajes nas trilhas). Bordas: paredões estratificados, raízes pendentes, cachoeiras, cristais incrustados e
   fragmentos flutuantes. Mesmas posições e caminhos da V1 (as conexões entre as áreas não mudaram). */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
I.buildTerrain=function(ctx){const P=I.poi;
  const X0=-300,Z0=-262,STEP=1.5,NX=401,NZ=337;
  function mask(x,z){const wx=x+24*MM.fbm(x/130,z/130,3,5),wz=z+24*MM.fbm(x/130+9.1,z/130,3,6);return 1-Math.hypot(wx/274,(wz+12)/220)+.05*MM.fbm(x/48,z/48,3,7)+.018*MM.fbm(x/14,z/14,2,8);}
  const plato=(h,x,z,c,r,edge,H)=>{const d=Math.hypot(x-c.x,z-c.z);return MM.lerp(h,H,MM.ss(r+edge,r,d));};
  const ca=Math.cos(.45),sa=Math.sin(.45);
  /* fissuras naturais nas montanhas: [x0,z0,x1,z1,largura,profundidade] */
  const fiss=[[-110,-150,-96,-196,3,16],[-30,-150,-8,-200,2.5,14],[58,-168,74,-206,3,18],[-196,-120,-214,-160,2.5,12]];
  function raw(x,z){let h=7+4.5*MM.fbm(x/70,z/70,4,1)+1.4*MM.fbm(x/16,z/16,2,2)+.5*MM.fbm(x/5,z/5,2,3);
    /* cordilheira: cristas de domínio torcido, eixo inclinado → picos assimétricos, nunca cones */
    const north=MM.ss(-20,-130,z)*(1-MM.ss(178,258,Math.abs(x-6)));
    if(north>0){const qx=x*ca-z*sa,qz=x*sa+z*ca;const wx=qx+30*MM.fbm(qx/90,qz/90,3,12),wz=qz+30*MM.fbm(qx/90+4,qz/90,3,13);
      const rid=MM.ridged(wx/95,wz/48,6,3);const rid2=MM.ridged(wx/38,wz/26,4,14);let m=rid*72+rid2*20+34*MM.ss(.25,.9,rid);
      [[-152,-152,70,30,52,.5],[-72,-178,96,26,46,-.4],[28,-186,66,34,22,.9],[-14,-142,30,22,30,0],[96,-178,46,22,40,-.7],[-214,-128,38,20,26,.3]].forEach(([cx,cz,Hh,rx,rz,rot])=>{
        const dx=x-cx,dz=z-cz,c=Math.cos(rot),s=Math.sin(rot);const u=(dx*c-dz*s)/rx,v=(dx*s+dz*c)/rz;const g=Math.exp(-(u*u+v*v)/2);/* assimetria: um lado mais íngreme */const skew=1+.35*Math.tanh(u*1.4);m+=Hh*g*skew*(.7+.3*rid2);});
      /* ravinas de erosão descendo as encostas */
      const gully=Math.pow(Math.abs(MM.noise2(wx/16,wz/60,15)),.5);m-=north*14*(1-gully)*MM.ss(20,70,m);
      h+=north*m;}
    {const d=Math.hypot(x-P.torre.x,z-P.torre.z);let hill=P.torre.h*(1-MM.ss(P.torre.r,P.torre.r+84,d));const t=hill/6;hill=(Math.floor(t)+MM.ss(.72,1,t-Math.floor(t)))*6;hill+=MM.fbm(x/9,z/9,2,16)*.6*MM.ss(P.torre.r+2,P.torre.r+12,d);h=d<P.torre.r?P.torre.h:Math.max(h,hill);}
    h=plato(h,x,z,P.vila,P.vila.r,26,P.vila.h+.4*MM.fbm(x/12,z/12,2,17));
    h=plato(h,x,z,P.observatorio,P.observatorio.r,16,P.observatorio.h);
    {const w=MM.ss(128,168,x)*MM.ss(-70,-30,z)*(1-MM.ss(130,175,z));h=MM.lerp(h,P.penhasco.h+3*MM.fbm(x/30,z/30,2,4)+MM.ridged(x/20,z/20,3,18)*3,w);}
    h=plato(h,x,z,P.santuario,P.santuario.r,10,P.santuario.h);
    h=plato(h,x,z,P.chegada,24,18,P.chegada.h);
    {const b=P.caverna.boca;const wx=1-MM.ss(16,28,Math.abs(x-b.x));const pad=26;h=MM.lerp(h,pad,wx*MM.ss(-103,-99,z)*(1-MM.ss(-80,-68,z)));h=Math.max(h,MM.lerp(h,64,wx*MM.ss(-99,-104,z)));}
    {const f=I.fenda;const s=MM.segDist(x,z,f.a[0],f.a[1],f.b[0],f.b[1]);const w=f.largura/2*(1+.25*MM.noise2(z/18,1,11));if(s.t>0&&s.t<1)h=MM.lerp(h,-140,MM.ss(w+5,w-1,s.d));}
    /* estratos: nas encostas íngremes e altas a altura "degrau-a-degrau" vira camadas geológicas */
    if(h>22){const L=8.5+2.5*MM.noise2(x/60,z/60,24),t=(h+3*MM.noise2(x/25,z/25,25))/L,f=t-Math.floor(t);const st=(Math.floor(t)+MM.ss(.25,.8,f))*L;h=MM.lerp(h,st,.35*MM.ss(22,45,h));}
    for(const [ax,az,bx,bz,w,dp] of fiss){const s=MM.segDist(x,z,ax,az,bx,bz);if(s.d<w*3)h-=dp*MM.ss(w*2.4,w*.4,s.d)*Math.sin(s.t*Math.PI)*MM.ss(25,45,h);}
    return h;}
  const inFenda=(x,z)=>{const f=I.fenda;const s=MM.segDist(x,z,f.a[0],f.a[1],f.b[0],f.b[1]);return s.t>0&&s.t<1&&s.d<f.largura/2+7;};
  const paths=I.caminhos.map(c=>{const S=[];for(let i=0;i<c.pts.length-1;i++){const [ax,az]=c.pts[i],[bx,bz]=c.pts[i+1];const L=Math.hypot(bx-ax,bz-az),n=Math.max(1,Math.round(L/3));for(let k=0;k<n;k++){const t=k/n;S.push([ax+(bx-ax)*t,az+(bz-az)*t]);}}S.push(c.pts[c.pts.length-1]);
    let H=S.map(([x,z])=>inFenda(x,z)?NaN:raw(x,z));
    for(let i=0;i<H.length;i++)if(isNaN(H[i])){let a=i;while(a>0&&isNaN(H[a]))a--;let b=i;while(b<H.length-1&&isNaN(H[b]))b++;H[i]=MM.lerp(H[a],H[b],(i-a)/Math.max(1,b-a));}
    for(let it=0;it<3;it++)H=H.map((v,i)=>{let s=0,n=0;for(let k=-4;k<=4;k++){const j=i+k;if(j>=0&&j<H.length){s+=H[j];n++;}}return s/n;});
    const g=.33*3;for(let i=1;i<H.length;i++)H[i]=MM.clamp(H[i],H[i-1]-g,H[i-1]+g);for(let i=H.length-2;i>=0;i--)H[i]=MM.clamp(H[i],H[i+1]-g,H[i+1]+g);return{c,S,H,hw:c.w/2};});
  const N=NX*NZ;const Hg=new Float32Array(N),Mg=new Float32Array(N),Pm=new Float32Array(N);
  for(let j=0;j<NZ;j++)for(let i=0;i<NX;i++){const x=X0+i*STEP,z=Z0+j*STEP;const k=j*NX+i;const m=mask(x,z);Mg[k]=m;let h=raw(x,z);let pm=0;
    if(!inFenda(x,z))for(const p of paths){for(let s=0;s<p.S.length-1;s++){const a=p.S[s],b=p.S[s+1];if(Math.abs(x-a[0])>p.hw+12||Math.abs(z-a[1])>p.hw+12)continue;const q=MM.segDist(x,z,a[0],a[1],b[0],b[1]);if(q.d>p.hw+7)continue;
      const ph=MM.lerp(p.H[s],p.H[s+1],q.t);const w=MM.ss(p.hw+6,p.hw-1,q.d);h=MM.lerp(h,ph-.3+.25*MM.noise2(x/2,z/2,19),w);pm=Math.max(pm,MM.ss(p.hw+.5,p.hw-2.5,q.d)*(p.c.tipo==='secreto'?.5:1)*(.75+.25*MM.noise2(x/5,z/5,20)));}}
    /* borda: paredão até a base, com saliências de estrato (a altura de cada camada recua/avança) */
    /* fora do contorno o chão só desce um pouco: a saia de paredão (malha própria) cobre a borda */
    h=MM.lerp(h-5,h,MM.ss(-.02,.004,m));Hg[k]=h;Pm[k]=pm;}
  /* posições (com recortes horizontais no paredão), normais pela grade, pesos de material e umidade */
  const pos=new Float32Array(N*3);
  for(let j=0;j<NZ;j++)for(let i=0;i<NX;i++){const k=j*NX+i;let x=X0+i*STEP,z=Z0+j*STEP;const band=MM.ss(-.05,-.01,Mg[k])*(1-MM.ss(0,.012,Mg[k]));
    /* (V2: a borda agora é a saia de paredão; nada de deslocar vértices aqui) */
    pos[k*3]=x;pos[k*3+1]=Hg[k];pos[k*3+2]=z;}
  const nrm=new Float32Array(N*3);const hAt=(i,j)=>Hg[MM.clamp(j,0,NZ-1)*NX+MM.clamp(i,0,NX-1)];
  for(let j=0;j<NZ;j++)for(let i=0;i<NX;i++){const k=j*NX+i;const dx=(hAt(i+1,j)-hAt(i-1,j))/(2*STEP),dz=(hAt(i,j+1)-hAt(i,j-1))/(2*STEP);const l=Math.hypot(dx,1,dz);nrm[k*3]=-dx/l;nrm[k*3+1]=1/l;nrm[k*3+2]=-dz/l;}
  const aW=new Float32Array(N*4),aWet=new Float32Array(N),col=new Float32Array(N*3);const F=P.floresta;
  const cR=MM.C('#5b5e72'),cM=MM.C('#4a6a4c'),cS=MM.C('#4a403a'),cPa=MM.C('#8a8780'),tmp=new T.Color();
  for(let k=0;k<N;k++){const x=pos[k*3],y=pos[k*3+1],z=pos[k*3+2];const ny=nrm[k*3+1];const slope=1-ny;const n=MM.fbm(x/18,z/18,3,40);
    let rock=MM.clamp(MM.ss(.26,.5,slope)+MM.ss(55,95,y)*.7+(y<0?1:0),0,1);
    const fd=Math.hypot(x-F.x,z-F.z);let soil=MM.clamp(MM.ss(.15,.45,n*.5+.5)*.35+MM.ss(F.r+10,F.r-35,fd)*.55+MM.ss(.6,.2,Pm[k])*Pm[k]*1.6,0,1);
    const path=Pm[k];aW[k*4]=rock;aW[k*4+1]=0;aW[k*4+2]=soil;aW[k*4+3]=path;
    /* umidade: trilhas e baixadas planas (poças), menos nas encostas */
    aWet[k]=MM.clamp((path*.55+MM.ss(.55,.85,MM.fbm(x/26,z/26,3,44)*.5+.5)*.6)*MM.ss(.2,.05,slope),0,1);
    tmp.copy(cM).lerp(cS,soil).lerp(cR,rock).lerp(cPa,path*(1-rock));col[k*3]=tmp.r;col[k*3+1]=tmp.g;col[k*3+2]=tmp.b;}
  const tMat=MM.triplanar({mode:'terreno',name:'TerrenoTempestadeV2',env:.75});
  /* blocos com 2 níveis de detalhe (no Roblox: Terrain pelo heightmap; ou MeshParts por bloco) */
  const terr=MM.obj('STORM.TERRAIN.MAIN','Terreno principal (V2)','Terrain',{notes:'Campo de alturas 600 × 504 studs, passo 1,5, em blocos de 60 × 60 com 2 níveis de detalhe. No Roblox: Terrain pelo heightmap + MaterialVariants.'});
  const b=P.caverna.boca;const CH=40;let tris0=0;
  for(let cj=0;cj<NZ-1;cj+=CH)for(let ci=0;ci<NX-1;ci+=CH){const lod=new T.LOD();lod.name='Bloco_'+ci+'_'+cj;let any=false;
    for(const st of [1,2]){const i1=Math.min(ci+CH,NX-1),j1=Math.min(cj+CH,NZ-1);const vi=[],idx=[];const map=new Map();const vid=(i,j)=>{const key=j*NX+i;if(!map.has(key)){map.set(key,vi.length);vi.push(key);}return map.get(key);};
      for(let j=cj;j<j1;j+=st)for(let i=ci;i<i1;i+=st){const i2=Math.min(i+st,i1),j2=Math.min(j+st,j1);const a=j*NX+i,b2=j*NX+i2,c=j2*NX+i,d=j2*NX+i2;if(Math.max(Mg[a],Mg[b2],Mg[c],Mg[d])<-.012)continue;
        const cx=(pos[a*3]+pos[d*3])/2,cz=(pos[a*3+2]+pos[d*3+2])/2,cy=(Hg[a]+Hg[d])/2;if(Math.abs(cx-b.x)<9.5&&cz<-98&&cz>-107&&cy>25&&cy<41)continue;
        idx.push(vid(i,j),vid(i,j2),vid(i2,j),vid(i2,j),vid(i,j2),vid(i2,j2));}
      if(!idx.length)continue;any=true;const n=vi.length;const P3=new Float32Array(n*3),N3=new Float32Array(n*3),W4=new Float32Array(n*4),WT=new Float32Array(n),C3=new Float32Array(n*3);
      vi.forEach((k,q)=>{P3.set(pos.subarray(k*3,k*3+3),q*3);N3.set(nrm.subarray(k*3,k*3+3),q*3);W4.set(aW.subarray(k*4,k*4+4),q*4);WT[q]=aWet[k];C3.set(col.subarray(k*3,k*3+3),q*3);});
      const g=new T.BufferGeometry();g.setAttribute('position',new T.BufferAttribute(P3,3));g.setAttribute('normal',new T.BufferAttribute(N3,3));g.setAttribute('aW',new T.BufferAttribute(W4,4));g.setAttribute('aWet',new T.BufferAttribute(WT,1));g.setAttribute('color',new T.BufferAttribute(C3,3));g.setIndex(idx);
      const m=new T.Mesh(g,tMat);m.receiveShadow=true;m.castShadow=st===1;m.name='TerrenoLOD'+(st-1);lod.addLevel(m,st===1?0:300);if(st===1)tris0+=idx.length/3;}
    if(any)terr.add(lod);}
  terr.userData.tris0=tris0;
  /* ---- saia de paredão: malha própria que desce do contorno com estratos salientes e ravinas (sem textura esticada) ---- */
  const AS=360;const cont=[];for(let a=0;a<AS;a++){const ang=a/AS*Math.PI*2;let r=80;while(r<330&&mask(Math.cos(ang)*r,Math.sin(ang)*r)>0)r+=.5;cont.push(r);}
  const skirt=MM.obj('STORM.TERRAIN.CLIFFS','Paredões da borda','Terrain',{notes:'Malha separada do campo de alturas: camadas que avançam e recuam (estratos) e ravinas verticais. No Roblox: MeshParts de paredão em segmentos.'});
  {const K=40,V=[],Fc=[];const topY=a=>{const ang=a/AS*Math.PI*2,r=cont[a]-1.2;return heightAt(Math.cos(ang)*r,Math.sin(ang)*r);};
    for(let k=0;k<=K;k++)for(let a=0;a<AS;a++){const ang=a/AS*Math.PI*2;const top=topY(a);const t=k/K;const y=MM.lerp(top-.3,-58,Math.pow(t,1.15));
      const ledge=2.4*Math.max(-.4,Math.sin(y*.5+3*MM.noise2(ang*3,1,65)))*(k>0?1:0);const gully=-3.2*Math.pow(Math.abs(MM.noise2(ang*9,y*.02,66)),.6)+1.6;
      const r=cont[a]+.6+(k?ledge+gully*.6+1.4*MM.noise2(ang*20,y*.15,67):0)-t*4;V.push(Math.cos(ang)*r,y,Math.sin(ang)*r);}
    for(let k=0;k<K;k++)for(let a=0;a<AS;a++){const i0=k*AS+a,i1=k*AS+(a+1)%AS,i2=i0+AS,i3=i1+AS;Fc.push(i0,i1,i2,i1,i3,i2);}/* normais para fora */
    const g=new T.BufferGeometry();g.setAttribute('position',new T.Float32BufferAttribute(V,3));g.setIndex(Fc);g.computeVertexNormals();
    const sm=new T.Mesh(g,null);sm.name='Paredao';sm.receiveShadow=true;sm.castShadow=true;skirt.add(sm);skirt.userData.mesh=sm;}
  /* ---- base flutuante estratificada ---- */
  const base=MM.obj('STORM.TERRAIN.BASE','Base flutuante da ilha (V2)','Terrain',{notes:'Raiz de rocha estratificada com pontas e cristais. Só visual.'});
  const rockMat=MM.triplanar({mode:'rocha',name:'RochaTriplanar',rockScale:.035,tint:'#d8d4d0',mossTop:.8});ctx.rockMat=rockMat;skirt.userData.mesh.material=rockMat;
  const A=96,R=22;const outline=[];for(let a=0;a<A;a++){const ang=a/A*Math.PI*2;let r=60;while(r<330&&mask(Math.cos(ang)*r,Math.sin(ang)*r)>-.02)r+=2;outline.push(r);}
  {const V=[],Fc=[];for(let k=0;k<=R;k++){const t=k/R;const y=-54-t*215;const strata=1+.06*Math.sin(k*1.7);const sc=Math.pow(1-t,1.18)*strata;
      for(let a=0;a<A;a++){const ang=a/A*Math.PI*2;const rr=outline[a]*sc*(1+.1*MM.noise2(a*.4,k*.5,5)+.05*MM.noise2(a*1.7,k*1.3,6));V.push(Math.cos(ang)*rr,y+5*MM.noise2(a*.8,k,7),Math.sin(ang)*rr);}}
    V.push(0,-290,0);for(let k=0;k<R;k++)for(let a=0;a<A;a++){const i0=k*A+a,i1=k*A+(a+1)%A,i2=i0+A,i3=i1+A;Fc.push(i0,i1,i2,i1,i3,i2);}const tip=(R+1)*A;for(let a=0;a<A;a++)Fc.push(R*A+a,R*A+(a+1)%A,tip);
    const g=new T.BufferGeometry();g.setAttribute('position',new T.Float32BufferAttribute(V,3));g.setIndex(Fc);g.computeVertexNormals();const bm=new T.Mesh(g,rockMat);bm.receiveShadow=true;base.add(bm);}
  const r=MM.rng(77);
  /* pontas penduradas: rocha esculpida alongada (não cones lisos) */
  for(let s=0;s<22;s++){const ang=r()*Math.PI*2,rad=(.25+r()*.55)*outline[Math.floor(ang/(Math.PI*2)*A)%A]*.75,L=26+r()*60;const g=MM.rockGeo(900+s,5+r()*7,L/2,5+r()*7,2);g.translate(0,-L/2,0);
    const m=MM.mesh(g,rockMat,Math.cos(ang)*rad,-70-r()*80,Math.sin(ang)*rad,base);m.rotation.y=r()*3;}
  /* ---- detalhes da borda: raízes pendentes, cristais incrustados, cachoeiras, fragmentos flutuantes ---- */
  const edge=MM.obj('STORM.TERRAIN.EDGE','Detalhes da borda (raízes, cristais, cachoeiras, fragmentos)','Terrain',{notes:'Cachoeiras animadas no navegador; no Roblox: Beam/textura animada + ParticleEmitter de névoa.'});
  const rootM=new T.MeshStandardMaterial({color:MM.C('#3a2e2a'),roughness:.95});rootM.name='RaizPendente';
  const edgePt=(ang)=>{const rr=outline[Math.floor(((ang%(Math.PI*2))+Math.PI*2)%(Math.PI*2)/(Math.PI*2)*A)%A]-3;return[Math.cos(ang)*rr,Math.sin(ang)*rr];};
  for(let s=0;s<34;s++){const ang=r()*Math.PI*2;const [x,z]=edgePt(ang);const top=heightAt(x,z);if(top<2)continue;const n=2+Math.floor(r()*4);
    for(let k=0;k<n;k++){const ox=(r()-.5)*6,oz=(r()-.5)*6,L=8+r()*26;const pts=[];for(let q=0;q<=6;q++){const t=q/6;pts.push(new T.Vector3(x+ox+Math.cos(ang)*(1.5+t*2)+Math.sin(q*1.3+k)*.8,top-1-t*L,z+oz+Math.sin(ang)*(1.5+t*2)+Math.cos(q*1.1)*.8));}
      edge.add(MM.tube(pts,.35+r()*.35,rootM,10,5));}}
  const cris=new T.MeshPhysicalMaterial({color:MM.C('#9ae8ff'),roughness:.08,metalness:0,transmission:.55,transparent:true,opacity:.92,emissive:MM.C('#2fb8ff'),emissiveIntensity:.35,clearcoat:1,flatShading:true});cris.name='CristalIncrustado';
  for(let s=0;s<20;s++){const ang=r()*Math.PI*2;const [x,z]=edgePt(ang);const top=heightAt(x,z);if(top<4)continue;const y=top-6-r()*40;const g=new T.Group();g.position.set(x+Math.cos(ang)*2.5,y,z+Math.sin(ang)*2.5);g.lookAt(x+Math.cos(ang)*20,y+6,z+Math.sin(ang)*20);
    const n=3+Math.floor(r()*4);for(let k=0;k<n;k++){const c=MM.mesh(MM.crystalGeo(.5+r()*.7,2+r()*3.5,1.2+r()),cris,(r()-.5)*2,(r()-.5)*2,0,g);c.rotation.set(Math.PI/2+(r()-.5)*.8,0,(r()-.5)*.8);}edge.add(g);}
  /* cachoeiras: duas descidas pela borda (leste e oeste) */
  const wf=[];const wMat=new T.ShaderMaterial({transparent:true,depthWrite:false,side:T.DoubleSide,uniforms:{uT:{value:0}},
    vertexShader:'varying vec2 vU;void main(){vU=uv;gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.);}',
    fragmentShader:'varying vec2 vU;uniform float uT;float h(vec2 p){return fract(sin(dot(p,vec2(12.9,78.2)))*43758.5);}float n(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);return mix(mix(h(i),h(i+vec2(1,0)),f.x),mix(h(i+vec2(0,1)),h(i+vec2(1,1)),f.x),f.y);}void main(){float s=n(vec2(vU.x*18.,vU.y*6.+uT*3.2))*.6+n(vec2(vU.x*40.,vU.y*14.+uT*5.))*.4;float edge=smoothstep(0.,.18,vU.x)*smoothstep(1.,.82,vU.x);float fade=smoothstep(0.,.12,vU.y)*smoothstep(1.,.75,vU.y);vec3 c=mix(vec3(.55,.66,.85),vec3(.92,.96,1.),s);gl_FragColor=vec4(c,(.25+.55*s)*edge*fade*.85);}'});
  [[.05,9],[3.3,7]].forEach(([ang,w])=>{const [x,z]=edgePt(ang);const top=heightAt(x,z);const pl=new T.PlaneGeometry(w,150,1,30);pl.translate(0,-75,0);const p=pl.attributes.position;for(let i=0;i<p.count;i++){const yy=p.getY(i);p.setZ(i,Math.pow(-yy/150,1.4)*14);}pl.computeVertexNormals();
    const m=new T.Mesh(pl,wMat);m.position.set(x+Math.cos(ang)*1.5,top+.2,z+Math.sin(ang)*1.5);m.rotation.y=-ang+Math.PI/2;m.name='Cachoeira';edge.add(m);wf.push(m);});
  edge.userData.anim={wMat};
  /* fragmentos de rocha soltos flutuando em volta da ilha */
  for(let s=0;s<16;s++){const ang=r()*Math.PI*2;const [x,z]=edgePt(ang);const d=18+r()*55;const sz=4+r()*10;const g=MM.rockGeo(1200+s,sz,sz*.8,sz,2);const m=MM.mesh(g,rockMat,x+Math.cos(ang)*d,-10-r()*70,z+Math.sin(ang)*d,edge);m.rotation.set(r(),r()*3,r());m.name='Fragmento';
    const top=MM.mesh(MM.rockGeo(1300+s,sz*.85,sz*.25,sz*.85,1),new T.MeshStandardMaterial({color:MM.C('#3b4d37'),roughness:.95}),0,sz*.62,0,m);top.name='MusgoFragmento';}
  function heightAt(x,z){const fi=(x-X0)/STEP,fj=(z-Z0)/STEP;const i=Math.floor(fi),j=Math.floor(fj);if(i<0||j<0||i>=NX-1||j>=NZ-1)return -200;const u=fi-i,v=fj-j,k=j*NX+i;return MM.lerp(MM.lerp(Hg[k],Hg[k+1],u),MM.lerp(Hg[k+NX],Hg[k+NX+1],u),v);}
  function inside(x,z){return mask(x,z)>.004&&heightAt(x,z)>-5;}
  return{objects:[terr,skirt,base,edge],heightAt,inside,grid:{X0,Z0,STEP,NX,NZ,H:Hg,P:Pm,col,W:aW},paths,mask,rockMat};};
})();
