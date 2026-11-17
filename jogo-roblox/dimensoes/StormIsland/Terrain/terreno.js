/* Ilha das Tempestades · Terrain
   Campo de alturas próprio (studs), com cumes em crista ao norte, colina da torre em terraços, platôs da vila,
   do observatório e do penhasco, fenda até as nuvens, caminhos escavados com rampa limitada e a base flutuante.
   Exporta: malha do terreno (cores por vértice), malha da base, heightAt(x,z) e a grade para o heightmap do Roblox. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
I.buildTerrain=function(ctx){const P=I.poi,pal=I.paleta;
  const X0=-300,Z0=-262,STEP=2,NX=301,NZ=252;
  /* ---- máscara da ilha (contorno irregular, nunca uma elipse perfeita) ---- */
  function mask(x,z){const wx=x+22*MM.fbm(x/130,z/130,3,5),wz=z+22*MM.fbm(x/130+9.1,z/130,3,6);return 1-Math.hypot(wx/274,(wz+12)/220)+.05*MM.fbm(x/48,z/48,3,7);}
  const plato=(h,x,z,c,r,edge,H)=>{const d=Math.hypot(x-c.x,z-c.z);return MM.lerp(h,H,MM.ss(r+edge,r,d));};
  /* ---- relevo bruto ---- */
  function raw(x,z){let h=7+4.5*MM.fbm(x/70,z/70,4,1)+1.6*MM.fbm(x/16,z/16,2,2);
    /* cordilheira norte em ziguezague (vocabulário vertical e pontiagudo) */
    const north=MM.ss(-24,-128,z)*(1-MM.ss(175,255,Math.abs(x-6)));const rid=MM.ridged(x/78,z/58,5,3);
    h+=north*(rid*64+34*MM.ss(.25,.9,rid));
    [[-152,-152,74,34],[-72,-176,92,30],[28,-184,64,28],[-12,-140,30,26],[92,-176,44,24]].forEach(([cx,cz,H,r])=>{const d=Math.hypot(x-cx,z-cz);h+=H*Math.exp(-(d*d)/(2*r*r))*(.75+.25*MM.ridged(x/30,z/30,3,9));});
    /* colina da torre em terraços de 6 studs */
    {const d=Math.hypot(x-P.torre.x,z-P.torre.z);let hill=P.torre.h*(1-MM.ss(P.torre.r,P.torre.r+84,d));const t=hill/6;hill=(Math.floor(t)+MM.ss(.72,1,t-Math.floor(t)))*6;
      h=d<P.torre.r?P.torre.h:Math.max(h,hill);}
    h=plato(h,x,z,P.vila,P.vila.r,26,P.vila.h);
    h=plato(h,x,z,P.observatorio,P.observatorio.r,16,P.observatorio.h);
    /* terras altas do leste até o penhasco */
    {const w=MM.ss(128,168,x)*MM.ss(-70,-30,z)*(1-MM.ss(130,175,z));h=MM.lerp(h,P.penhasco.h+3*MM.fbm(x/30,z/30,2,4),w);}
    h=plato(h,x,z,P.santuario,P.santuario.r,10,P.santuario.h);
    h=plato(h,x,z,P.chegada,24,18,P.chegada.h);
    /* entrada da caverna: plataforma e paredão vertical ao norte dela */
    {const b=P.caverna.boca;const wx=1-MM.ss(16,28,Math.abs(x-b.x));const pad=26;
      h=MM.lerp(h,pad,wx*MM.ss(-103,-99,z)*(1-MM.ss(-80,-68,z)));
      h=Math.max(h,MM.lerp(h,64,wx*MM.ss(-99,-104,z)));}
    /* fenda até as nuvens */
    {const f=I.fenda;const s=MM.segDist(x,z,f.a[0],f.a[1],f.b[0],f.b[1]);const w=f.largura/2*(1+.25*MM.noise2(z/18,1,11));if(s.t>0&&s.t<1)h=MM.lerp(h,-140,MM.ss(w+5,w-1,s.d));}
    return h;}
  /* ---- caminhos: altura suavizada e rampa máxima 0,33 ---- */
  const inFenda=(x,z)=>{const f=I.fenda;const s=MM.segDist(x,z,f.a[0],f.a[1],f.b[0],f.b[1]);return s.t>0&&s.t<1&&s.d<f.largura/2+7;};
  const paths=I.caminhos.map(c=>{const S=[];for(let i=0;i<c.pts.length-1;i++){const [ax,az]=c.pts[i],[bx,bz]=c.pts[i+1];const L=Math.hypot(bx-ax,bz-az),n=Math.max(1,Math.round(L/3));for(let k=0;k<n;k++){const t=k/n;S.push([ax+(bx-ax)*t,az+(bz-az)*t]);}}S.push(c.pts[c.pts.length-1]);
    let H=S.map(([x,z])=>inFenda(x,z)?NaN:raw(x,z));
    for(let i=0;i<H.length;i++)if(isNaN(H[i])){let a=i;while(a>0&&isNaN(H[a]))a--;let b=i;while(b<H.length-1&&isNaN(H[b]))b++;H[i]=MM.lerp(H[a],H[b],(i-a)/Math.max(1,b-a));}
    for(let it=0;it<3;it++)H=H.map((v,i)=>{let s=0,n=0;for(let k=-4;k<=4;k++){const j=i+k;if(j>=0&&j<H.length){s+=H[j];n++;}}return s/n;});
    const g=.33*3;for(let i=1;i<H.length;i++)H[i]=MM.clamp(H[i],H[i-1]-g,H[i-1]+g);for(let i=H.length-2;i>=0;i--)H[i]=MM.clamp(H[i],H[i+1]-g,H[i+1]+g);
    return{c,S,H,hw:c.w/2};});
  /* ---- grade ---- */
  const Hg=new Float32Array(NX*NZ),Mg=new Float32Array(NX*NZ),Pm=new Float32Array(NX*NZ);
  for(let j=0;j<NZ;j++)for(let i=0;i<NX;i++){const x=X0+i*STEP,z=Z0+j*STEP;const k=j*NX+i;const m=mask(x,z);Mg[k]=m;let h=raw(x,z);let pm=0;
    if(!inFenda(x,z))for(const p of paths){for(let s=0;s<p.S.length-1;s++){const a=p.S[s],b=p.S[s+1];if(Math.abs(x-a[0])>p.hw+12||Math.abs(z-a[1])>p.hw+12)continue;const q=MM.segDist(x,z,a[0],a[1],b[0],b[1]);if(q.d>p.hw+7)continue;
      const ph=MM.lerp(p.H[s],p.H[s+1],q.t);const w=MM.ss(p.hw+6,p.hw-1,q.d);h=MM.lerp(h,ph-.25,w);pm=Math.max(pm,MM.ss(p.hw,p.hw-2.5,q.d)*(p.c.tipo==='secreto'?.55:1));}}
    /* borda: paredões até a base flutuante */
    h=MM.lerp(-62+8*MM.noise2(x/9,z/9,21),h,MM.ss(-.035,.012,m));Hg[k]=h;Pm[k]=pm;}
  /* ---- malha ---- */
  const pos=new Float32Array(NX*NZ*3);for(let j=0;j<NZ;j++)for(let i=0;i<NX;i++){const k=j*NX+i;let x=X0+i*STEP,z=Z0+j*STEP;
    /* paredões rochosos: desloca na horizontal os vértices da borda para quebrar a "cortina" lisa */
    if(Mg[k]<.012&&Mg[k]>-.05){const a=MM.noise2(x/7,z/7,61)*3.2,c=MM.noise2(x/7+40,z/7,62)*3.2,band=MM.ss(-.05,-.01,Mg[k])*(1-MM.ss(0,.012,Mg[k]));x+=a*band;z+=c*band;Hg[k]+=MM.noise2(x/5,z/5,63)*3*band;}
    pos[k*3]=x;pos[k*3+1]=Hg[k];pos[k*3+2]=z;}
  const b=P.caverna.boca;const idx=[];
  for(let j=0;j<NZ-1;j++)for(let i=0;i<NX-1;i++){const a=j*NX+i,b2=a+1,c=a+NX,d=c+1;if(Math.max(Mg[a],Mg[b2],Mg[c],Mg[d])<-.04)continue;
    /* boca da caverna: tira os triângulos do paredão no vão do arco (o túnel aparece por trás) */
    const cx=X0+(i+.5)*STEP,cz=Z0+(j+.5)*STEP,cy=(Hg[a]+Hg[d])/2;if(Math.abs(cx-b.x)<9.5&&cz<-98&&cz>-107&&cy>25&&cy<41)continue;
    idx.push(a,c,b2,b2,c,d);}
  const geo=new T.BufferGeometry();geo.setAttribute('position',new T.BufferAttribute(pos,3));geo.setIndex(idx);geo.computeVertexNormals();
  /* cores por vértice: musgo, rocha em estratos, rocha alta, trilha de lajes, chão da floresta, paredão */
  const nrm=geo.attributes.normal,col=new Float32Array(NX*NZ*3);const c=k=>MM.C(pal[k]);const cMus=c('musgo'),cMus2=c('musgo2'),cRoc=c('rocha'),cAlt=c('rochaAlta'),cTri=c('trilha'),cPen=c('penhasco'),cFlo=MM.C('#383552'),tmp=new T.Color();
  for(let k=0;k<NX*NZ;k++){const x=pos[k*3],y=pos[k*3+1],z=pos[k*3+2];const s=1-nrm.getY(k);const n=MM.fbm(x/22,z/22,3,40);
    tmp.copy(cMus).lerp(cMus2,.5+.5*n);
    const fd=Math.hypot(x-P.floresta.x,z-P.floresta.z);tmp.lerp(cFlo,.65*MM.ss(P.floresta.r+20,P.floresta.r-30,fd));
    const rock=MM.ss(.28,.5,s)+MM.ss(58,90,y)*.6;const str=.82+.18*Math.sin(y*.42+n*3.5);const rc=cRoc.clone().multiplyScalar(str).lerp(cAlt,MM.ss(60,105,y));tmp.lerp(rc,MM.clamp(rock,0,1));
    if(s>.35)tmp.lerp(cPen.clone().multiplyScalar(.75+.25*Math.sin(y*.55+n*4)),MM.ss(4,-28,y));/* paredão escuro em estratos */
    tmp.lerp(cTri.clone().multiplyScalar(.92+.08*MM.noise2(x/3,z/3,8)),Pm[k]*(1-MM.ss(.45,.7,s)));
    col[k*3]=tmp.r;col[k*3+1]=tmp.g;col[k*3+2]=tmp.b;}
  geo.setAttribute('color',new T.BufferAttribute(col,3));
  const tMat=new T.MeshStandardMaterial({vertexColors:true,roughness:.93,metalness:0});tMat.name='TerrenoTempestade';
  const terr=MM.obj('STORM.TERRAIN.MAIN','Terreno principal','Terrain',{notes:'Campo de alturas 600 × 504 studs, passo 2. No Roblox: Terrain gerado pelo heightmap + colormap exportados, ou MeshPart em blocos.'});
  const tm=new T.Mesh(geo,tMat);tm.receiveShadow=true;tm.castShadow=true;tm.name='TerrenoMalha';terr.add(tm);
  /* ---- base flutuante: raiz de rocha com estratos e pontas penduradas ---- */
  const base=MM.obj('STORM.TERRAIN.BASE','Base flutuante da ilha','Terrain',{notes:'Só visual (sem colisão).'});
  {const A=72,R=14;const outline=[];for(let a=0;a<A;a++){const ang=a/A*Math.PI*2;let r=60;while(r<330&&mask(Math.cos(ang)*r,Math.sin(ang)*r)>-.02)r+=3;outline.push(r);}
    const V=[],F=[];for(let k=0;k<=R;k++){const t=k/R;const y=-58-t*200-10*MM.noise2(k,1,3);const sc=Math.pow(1-t,1.25);
      for(let a=0;a<A;a++){const ang=a/A*Math.PI*2;const rr=outline[a]*sc*(1+.12*MM.noise2(a*.45,k*.6,5))+(t>.9?0:0);V.push(Math.cos(ang)*rr,y+6*MM.noise2(a*.8,k,6),Math.sin(ang)*rr);}}
    V.push(0,-280,0);for(let k=0;k<R;k++)for(let a=0;a<A;a++){const i0=k*A+a,i1=k*A+(a+1)%A,i2=i0+A,i3=i1+A;F.push(i0,i1,i2,i1,i3,i2);}
    const tip=(R+1)*A;for(let a=0;a<A;a++)F.push(R*A+a,R*A+(a+1)%A,tip);
    const g=new T.BufferGeometry();g.setAttribute('position',new T.Float32BufferAttribute(V,3));g.setIndex(F);g.computeVertexNormals();
    const bm=new T.Mesh(g.toNonIndexed(),ctx.mat.pedraEscura);bm.geometry.computeVertexNormals();bm.receiveShadow=true;base.add(bm);
    const r=MM.rng(77);for(let s=0;s<26;s++){const ang=r()*Math.PI*2,rad=(.2+r()*.6)*outline[Math.floor(ang/(Math.PI*2)*A)%A]*.7,L=30+r()*70;const cg=new T.ConeGeometry(6+r()*10,L,6);cg.rotateX(Math.PI);
      const m=MM.mesh(cg,ctx.mat.pedraEscura,Math.cos(ang)*rad,-90-r()*70-L/2,Math.sin(ang)*rad,base);m.rotation.y=r()*3;}
    for(let s=0;s<9;s++){const ang=r()*Math.PI*2,rad=(.3+r()*.4)*200;const cr=MM.mesh(MM.crystalGeo(2+r()*2,6+r()*6),ctx.mat.cristal,Math.cos(ang)*rad,-80-r()*40,Math.sin(ang)*rad,base);cr.rotation.x=Math.PI+(r()-.5)*.6;}}
  /* ---- consultas ---- */
  function heightAt(x,z){const fi=(x-X0)/STEP,fj=(z-Z0)/STEP;const i=Math.floor(fi),j=Math.floor(fj);if(i<0||j<0||i>=NX-1||j>=NZ-1)return -200;const u=fi-i,v=fj-j,k=j*NX+i;
    return MM.lerp(MM.lerp(Hg[k],Hg[k+1],u),MM.lerp(Hg[k+NX],Hg[k+NX+1],u),v);}
  function inside(x,z){return mask(x,z)>.004&&heightAt(x,z)>-5;}
  return{objects:[terr,base],heightAt,inside,grid:{X0,Z0,STEP,NX,NZ,H:Hg,P:Pm,col},paths,mask};};
})();
