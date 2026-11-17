/* Ilha das Tempestades · Resources · Depósitos naturais (V2.2)
   Quatro tipos com modelagem própria, posicionados onde a dimensão os produziria:
   - Cristal atmosférico: aglomerados de prismas num pedestal de rocha, nas bordas de estrato das montanhas (onde a tempestade bate).
   - Rocha condutora: rocha fraturada com veios de cobre nativo e nódulos, perto da torre e das torres de transmissão (zona de raios).
   - Mineral eletrificado: geodo aberto com cristais violeta e um arco elétrico preso por dentro, na beira da fenda e dos penhascos.
   - Fragmento de energia: estilhaço angular flutuando sobre um disco rúnico de pedra, junto ao observatório e às ruínas.
   Só visuais + pontos preparados (userData.pontos) para a futura coleta. Nenhuma mecânica nesta etapa. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
I.buildDeposits=function(ctx){const P=I.poi,out=[];const r=MM.rng(4242);const H=ctx.heightAt;
  const nrmAt=(x,z)=>{const e=1.5;return new T.Vector3(-(H(x+e,z)-H(x-e,z))/(2*e),1,-(H(x,z+e)-H(x,z-e))/(2*e)).normalize();};
  const crysA=new T.MeshPhysicalMaterial({name:'DepositoCristalAtmosferico',color:MM.C('#a9ecff'),roughness:.05,transmission:.6,transparent:true,opacity:.9,clearcoat:1,flatShading:true,emissive:MM.C('#2ab4ff'),emissiveIntensity:.4,envMapIntensity:1.8});
  const crysV=new T.MeshPhysicalMaterial({name:'MineralEletrificado',color:MM.C('#c7a8ff'),roughness:.08,transmission:.45,transparent:true,opacity:.92,clearcoat:1,flatShading:true,emissive:MM.C('#7a4dff'),emissiveIntensity:.5});
  const cuN=new T.MeshStandardMaterial({name:'CobreNativo',map:MM.tex.cobre.map,normalMap:MM.tex.cobre.normalMap,color:MM.C('#d39a62'),metalness:.9,roughness:.45,emissive:MM.C('#ff8a3a'),emissiveIntensity:.08});
  const spark=new T.MeshBasicMaterial({name:'ArcoEletrico',color:MM.C('#bfe9ff')});
  const runeDisc=new T.MeshStandardMaterial({name:'DiscoRunico',color:MM.C('#77716c'),roughness:.85,emissive:MM.C('#43d9ff'),emissiveMap:MM.tex.runas,emissiveIntensity:.5});
  const core=new T.MeshStandardMaterial({name:'NucleoFragmento',color:MM.C('#d6fbff'),emissive:MM.C('#5ce1ff'),emissiveIntensity:1.6});
  const keep=[P.vila,P.torre,P.chegada].map(p=>({x:p.x,z:p.z,r:(p.r||24)+4}));const okAt=(x,z,pd)=>ctx.inside(x,z)&&ctx.pathDist(x,z)>pd&&!keep.some(k=>Math.hypot(k.x-x,k.z-z)<k.r);
  /* busca um local que satisfaça a regra do tipo, perto de uma âncora */
  const find=(ax,az,rad,rule,tries)=>{for(let t=0;t<(tries||600);t++){const a=r()*6.28,d=Math.sqrt(r())*rad;const x=ax+Math.cos(a)*d,z=az+Math.sin(a)*d;if(!okAt(x,z,3))continue;const y=H(x,z);const n=nrmAt(x,z);if(rule(x,y,z,n))return{x,y,z,n};}return null;};
  const tipo=(id,nome,notes)=>{const o=MM.obj(id,nome,'Resources',{notes});o.userData.pontos=[];out.push(o);return o;};
  /* 1. cristal atmosférico */
  {const o=tipo('STORM.RES.ATMOS','Depósitos: cristal atmosférico','Aglomerados nas bordas de estrato das montanhas. Futuro: coleta com ferramenta de mineração. No Roblox: MeshPart Glass + núcleo Neon pequeno.');
    const anchors=[[-150,-118],[-60,-138],[24,-150],[96,-150],[-205,-112],[-100,-150]];anchors.forEach(([ax,az],i)=>{const s=find(ax,az,30,(x,y,z,n)=>y>30&&n.y>.72&&n.y<.95);if(!s)return;
      const gm=Math.min(...[[0,0],[3.4,0],[-3.4,0],[0,3.4],[0,-3.4],[2.4,2.4],[-2.4,-2.4],[2.4,-2.4],[-2.4,2.4]].map(([a,b])=>H(s.x+a,s.z+b)));const g=new T.Group();g.name='CristalAtmosferico_'+(i+1);g.position.set(s.x,gm+.1,s.z);g.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),s.n.clone().lerp(new T.Vector3(0,1,0),.4).normalize());o.add(g);
      MM.mesh(MM.rockGeo(4300+i,3.2,1.4,2.8,2),ctx.rockMat,0,.2,0,g);const n=7+Math.floor(r()*5);
      for(let k=0;k<n;k++){const a=r()*6.28,d=r()*1.6;const h=(k<2?4.5:1.5)+r()*3.5;const c=MM.mesh(MM.crystalGeo(.35+r()*.45,h,1+r()*.8),crysA,Math.cos(a)*d,.8,Math.sin(a)*d,g);c.rotation.set((r()-.5)*.7,r()*6.28,(r()-.5)*.7);}
      o.userData.pontos.push({id:'STORM.RES.ATMOS.'+String(i+1).padStart(2,'0'),x:s.x,y:s.y,z:s.z});});}
  /* 2. rocha condutora com veios de cobre nativo */
  {const o=tipo('STORM.RES.CONDUTORA','Depósitos: rocha condutora','Rochas com veios de cobre nativo na zona de raios (torre e linha de transmissão). No Roblox: MeshPart de rocha + MeshPart dos veios (CorrodedMetal).');
    const anchors=[[64,-6],[2,-52],[66,-58],[30,60],[82,96]];anchors.forEach(([ax,az],i)=>{const s=find(ax,az,22,(x,y,z,n)=>n.y>.88);if(!s)return;
      const gm=Math.min(...[[0,0],[3,0],[-3,0],[0,3],[0,-3]].map(([a,b])=>H(s.x+a,s.z+b)));const g=new T.Group();g.name='RochaCondutora_'+(i+1);g.position.set(s.x,gm-.2,s.z);g.rotation.y=r()*6.28;o.add(g);const sx=2.6+r(),sy=1.8+r()*.8,sz=2.2+r();
      MM.mesh(MM.rockGeo(4400+i,sx,sy,sz,2),ctx.rockMat,0,sy*.45,0,g);
      for(let v=0;v<3;v++){const pts=[];const a0=r()*6.28,tilt=(r()-.5)*1.2;for(let q=0;q<=10;q++){const a=a0+q/10*2.4;const yy=sy*.45+Math.sin(a*1.3+tilt)*sy*.55;const rr=Math.sqrt(Math.max(.05,1-Math.pow((yy-sy*.45)/(sy*.95),2)));pts.push(new T.Vector3(Math.cos(a)*sx*.98*rr,yy,Math.sin(a)*sz*.98*rr));}
        {const vt=MM.tube(pts,.11+r()*.08,cuN,24,5);vt.userData.semApoio=true;g.add(vt);}for(let q=0;q<3;q++){const p=pts[2+Math.floor(r()*7)];MM.mesh(new T.DodecahedronGeometry(.22+r()*.18,0),cuN,p.x,p.y,p.z,g).userData.semApoio=true;}/* veios e nódulos presos na rocha, não no chão */}
      o.userData.pontos.push({id:'STORM.RES.COND.'+String(i+1).padStart(2,'0'),x:s.x,y:s.y,z:s.z});});}
  /* 3. mineral eletrificado (geodos abertos) */
  {const o=tipo('STORM.RES.GEODO','Depósitos: mineral eletrificado (geodos)','Geodos rachados com cristais violeta e arco elétrico interno, na beira da fenda e dos penhascos. No Roblox: casca MeshPart + cristais Glass + Beam animado.');
    const f=I.fenda;const anchors=[[f.a[0],f.a[1]],[(f.a[0]+f.b[0])/2,(f.a[1]+f.b[1])/2],[200,20],[230,70],[-240,40]];
    anchors.forEach(([ax,az],i)=>{const s=find(ax,az,26,(x,y,z,n)=>n.y>.8&&y>2);if(!s)return;const g=new T.Group();g.name='Geodo_'+(i+1);g.position.set(s.x,s.y-.3,s.z);g.rotation.y=r()*6.28;o.add(g);
      const R=1.8+r()*.8;const shell=new T.SphereGeometry(R,14,10,0,Math.PI*2,0,Math.PI*.62);const p=shell.attributes.position;const rr=MM.rng(4500+i);for(let q=0;q<p.count;q++){const k=1+(rr()-.5)*.18;p.setXYZ(q,p.getX(q)*k,p.getY(q)*k,p.getZ(q)*k);}shell.computeVertexNormals();
      const sh=MM.mesh(shell,ctx.rockMat,0,0,0,g);sh.rotation.x=-1.15;sh.material=ctx.rockMat;const inner=new T.SphereGeometry(R*.86,12,8,0,Math.PI*2,0,Math.PI*.6);inner.scale(-1,1,1);const im=MM.mesh(inner,new T.MeshStandardMaterial({color:MM.C('#2b2238'),roughness:.7,side:T.DoubleSide}),0,0,0,g);im.rotation.x=-1.15;im.userData.semApoio=true;/* parede interna da cavidade: não é base */
      for(let k=0;k<14;k++){const a=r()*6.28,b=.25+r()*.9;const d=new T.Vector3(Math.cos(a)*Math.sin(b),Math.cos(b),Math.sin(a)*Math.sin(b)).applyAxisAngle(new T.Vector3(1,0,0),-1.15);const c=MM.mesh(MM.crystalGeo(.12+r()*.12,.5+r()*.7,1),crysV,d.x*R*.8,d.y*R*.8,d.z*R*.8,g);c.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),d.clone().negate());c.userData.semApoio=true;}
      const A=new T.Vector3(-.5,.4,.7),B=new T.Vector3(.6,.9,.2);const zz=[A];for(let q=1;q<6;q++)zz.push(A.clone().lerp(B,q/6).add(new T.Vector3((r()-.5)*.35,(r()-.5)*.35,(r()-.5)*.35)));zz.push(B);const sp=MM.tube(zz,.035,spark,12,3);sp.castShadow=false;sp.name='ArcoEletrico';sp.userData.semApoio=true;g.add(sp);
      /* V2.3.2: assenta o geodo pelo ponto mais baixo REAL da casca inclinada em relação ao chão sob ele (antes: altura do centro − 0,3) */
      {/* inclina com a encosta e enterra 85% da metade de baixo da casca (o ponto mais baixo sozinho deixava o lado alto no ar) */
       const yaw=g.rotation.y;g.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),s.n.clone().lerp(new T.Vector3(0,1,0),.3).normalize());g.rotateY(yaw);g.updateMatrixWorld(true);
       const pa=sh.geometry.attributes.position,v=new T.Vector3(),cy=g.position.y,G=[];for(let q=0;q<pa.count;q++){v.fromBufferAttribute(pa,q).applyMatrix4(sh.matrixWorld);if(v.y<cy+.3)G.push(v.y-H(v.x,v.z));}
       G.sort((a,b)=>a-b);const p85=G[Math.floor(G.length*.85)]||0;g.position.y-=p85+.15;}
      o.userData.pontos.push({id:'STORM.RES.GEO.'+String(i+1).padStart(2,'0'),x:s.x,y:s.y,z:s.z});});}
  /* 4. fragmentos de energia sobre discos rúnicos */
  {const o=tipo('STORM.RES.FRAGMENTO','Depósitos: fragmentos de energia','Estilhaço angular flutuando 2 studs acima de um disco rúnico de pedra. No Roblox: MeshPart Neon pequeno + Glass por fora, BodyPosition/TweenService para flutuar.');
    const anchors=[[P.observatorio.x-30,P.observatorio.z+18],[P.observatorio.x+20,P.observatorio.z+34],[-92,-14],[118,-20],[P.santuario.x+16,P.santuario.z-14]];
    anchors.forEach(([ax,az],i)=>{const s=find(ax,az,16,(x,y,z,n)=>n.y>.93);if(!s)return;const gm=Math.min(...[[0,0],[2.5,0],[-2.5,0],[0,2.5],[0,-2.5]].map(([a,b])=>H(s.x+a,s.z+b)));const g=new T.Group();g.name='FragmentoEnergia_'+(i+1);g.position.set(s.x,gm,s.z);o.add(g);
      const disc=MM.mesh(new T.CylinderGeometry(2.2,2.5,.5,10),ctx.rockMat,0,.1,0,g);const band=MM.mesh(new T.CylinderGeometry(2.21,2.21,.32,10,1,true),runeDisc,0,.18,0,g);
      for(let k=0;k<3;k++){const a=k/3*6.28;const b=MM.mesh(MM.rockGeo(4600+i*3+k,.45,.6,.45,1),ctx.rockMat,Math.cos(a)*1.7,.6,Math.sin(a)*1.7,g);}
      const fl=new T.Group();fl.name='Estilhaco';fl.position.y=2.6;fl.userData.animated=true;fl.userData.float=true;g.add(fl);const sg=new T.OctahedronGeometry(.75,0);sg.scale(.7,1.6,.5);
      fl.userData.flutua=true;MM.mesh(sg,crysA,0,0,0,fl);const c=MM.mesh(new T.OctahedronGeometry(.32,0),core,0,0,0,fl);c.scale.y=1.6;c.castShadow=false;
      for(let k=0;k<4;k++){const a=k/4*6.28;const bit=MM.mesh(new T.TetrahedronGeometry(.16,0),crysA,Math.cos(a)*1.1,(r()-.5)*.6,Math.sin(a)*1.1,fl);}
      o.userData.pontos.push({id:'STORM.RES.FRAG.'+String(i+1).padStart(2,'0'),x:s.x,y:s.y,z:s.z});});
    o.userData.update=(t)=>o.traverse(q=>{if(q.userData.float){q.position.y=2.6+Math.sin(t*1.3+q.parent.position.x)*.25;q.rotation.y=t*.6;}});}
  return out;};
})();
