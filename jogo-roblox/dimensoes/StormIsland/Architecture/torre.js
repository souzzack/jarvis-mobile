/* Ilha das Tempestades · Architecture · Torre Meteorológica · V2 (engenharia atmosférica monumental)
   Pedra em fiadas (triplanar), metal envelhecido, cobre oxidado, vidro reforçado e cristal atmosférico.
   Base com escadaria e portal → fuste com cornijas, janelas em arco e escada em espiral → galeria de instrumentos →
   casa de máquinas com engrenagens → treliça de vigas I com núcleo de energia → plataforma de antenas → cúpula →
   CAPTADOR DE TEMPESTADES (três anéis em cardã em volta do cristal atmosférico). Condutores de cobre descem até o chão
   com pulsos de energia. Altura total ≈ 165 studs sobre a colina de 36. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
MM.bevelBox=function(w,h,d,b){b=Math.min(b,w/3,h/3,d/3);const s=new T.Shape();s.moveTo(-w/2+b,-h/2+b);s.lineTo(w/2-b,-h/2+b);s.lineTo(w/2-b,h/2-b);s.lineTo(-w/2+b,h/2-b);s.lineTo(-w/2+b,-h/2+b);
  const g=new T.ExtrudeGeometry(s,{depth:d-2*b,bevelEnabled:true,bevelThickness:b,bevelSize:b,bevelSegments:1});g.translate(0,0,-(d-2*b)/2);return g;};
function gearGeo(R,teeth,th,hole){const s=new T.Shape();const n=teeth*4;for(let i=0;i<=n;i++){const a=i/n*Math.PI*2;const k=i%4;const r=k===0||k===3?R:R*1.16;i?s.lineTo(Math.cos(a)*r,Math.sin(a)*r):s.moveTo(Math.cos(a)*r,Math.sin(a)*r);}
  const h=new T.Path();h.absarc(0,0,hole,0,Math.PI*2,true);s.holes.push(h);for(let k=0;k<5;k++){const a=k/5*Math.PI*2;const p=new T.Path();p.absarc(Math.cos(a)*R*.58,Math.sin(a)*R*.58,R*.18,0,Math.PI*2,true);s.holes.push(p);}
  const g=new T.ExtrudeGeometry(s,{depth:th,bevelEnabled:true,bevelThickness:.12,bevelSize:.12,bevelSegments:1,curveSegments:6});g.translate(0,0,-th/2);return g;}
function ibeam(h,w){const s=new T.Shape();const f=.28*w,t=.2*w;s.moveTo(-w/2,-w/2);s.lineTo(w/2,-w/2);s.lineTo(w/2,-w/2+f);s.lineTo(t/2,-w/2+f);s.lineTo(t/2,w/2-f);s.lineTo(w/2,w/2-f);s.lineTo(w/2,w/2);s.lineTo(-w/2,w/2);s.lineTo(-w/2,w/2-f);s.lineTo(-t/2,w/2-f);s.lineTo(-t/2,-w/2+f);s.lineTo(-w/2,-w/2+f);s.lineTo(-w/2,-w/2);
  const g=new T.ExtrudeGeometry(s,{depth:h,bevelEnabled:false});g.rotateX(-Math.PI/2);return g;}
function gaugeTex(){const c=document.createElement('canvas');c.width=c.height=256;const g=c.getContext('2d');g.fillStyle='#e9e2cf';g.beginPath();g.arc(128,128,124,0,Math.PI*2);g.fill();g.strokeStyle='#2a2522';g.lineWidth=3;
  for(let i=0;i<=40;i++){const a=Math.PI*.75+i/40*Math.PI*1.5;const r0=i%5?100:88;g.beginPath();g.moveTo(128+Math.cos(a)*r0,128+Math.sin(a)*r0);g.lineTo(128+Math.cos(a)*112,128+Math.sin(a)*112);g.stroke();}
  g.font='bold 22px serif';g.fillStyle='#2a2522';g.textAlign='center';g.fillText('TEMPESTADE',128,190);g.lineWidth=5;g.strokeStyle='#8a1f1f';g.beginPath();g.moveTo(128,128);g.lineTo(128+Math.cos(-.5)*92,128+Math.sin(-.5)*92);g.stroke();
  const t=new T.CanvasTexture(c);t.encoding=T.sRGBEncoding;return t;}
I.buildTower=function(ctx){const P=I.poi.torre,y0=P.h,tx=MM.tex;
  /* ---- materiais da torre ---- */
  const stone=MM.triplanar({mode:'rocha',name:'PedraTorre',rockScale:.085,strata:0,tint:'#e8e3dc',mossTop:.35,env:.5});stone.userData.u.tRockC.value=tx.blocos.map;stone.userData.u.tRockN.value=tx.blocos.normalMap;
  const stone2=MM.triplanar({mode:'rocha',name:'PedraEntalhada',rockScale:.06,strata:0,tint:'#fffaf2',env:.5});
  const met=new T.MeshStandardMaterial({name:'MetalEnvelhecido',map:tx.metal.map,normalMap:tx.metal.normalMap,roughnessMap:tx.metal.roughnessMap,metalness:.85,roughness:.62,envMapIntensity:1.25});/* escovado: rugosidade menor que a do metal escuro */
  const bronze=new T.MeshStandardMaterial({name:'BronzeOxidado',color:MM.C('#c9a46a'),map:tx.cobre.map,normalMap:tx.cobre.normalMap,roughnessMap:tx.cobre.roughnessMap,metalness:.85,roughness:.75,envMapIntensity:1.3});
  const metD=new T.MeshStandardMaterial({name:'MetalEscuroTorre',color:MM.C('#3b3f4a'),map:tx.metal.map,normalMap:tx.metal.normalMap,roughnessMap:tx.metal.roughnessMap,metalness:.7,roughness:1});
  const cu=new T.MeshStandardMaterial({name:'CobreOxidado',map:tx.cobre.map,normalMap:tx.cobre.normalMap,roughnessMap:tx.cobre.roughnessMap,metalness:.75,roughness:1,envMapIntensity:1.2});
  const wood=new T.MeshStandardMaterial({name:'MadeiraPorta',color:MM.C('#4a3428'),roughness:.8});
  const glass=new T.MeshPhysicalMaterial({name:'VidroReforcado',color:MM.C('#5e7b8a'),roughness:.06,metalness:0,transmission:.55,transparent:true,opacity:.75,clearcoat:1,envMapIntensity:1.4,emissive:MM.C('#ffb36b'),emissiveIntensity:.5});/* luz quente de dentro */
  const crys=new T.MeshPhysicalMaterial({name:'CristalAtmosferico',color:MM.C('#b8eeff'),roughness:.04,transmission:.7,transparent:true,opacity:.9,clearcoat:1,flatShading:true,emissive:MM.C('#3fc8ff'),emissiveIntensity:.35,envMapIntensity:2});
  const core=new T.MeshStandardMaterial({name:'NucleoEnergia',color:MM.C('#9ef0ff'),emissive:MM.C('#43d9ff'),emissiveIntensity:2.2});
  const rune=new T.MeshStandardMaterial({name:'FaixaDeRunas',color:MM.C('#77737c'),roughness:.85,emissive:MM.C('#43d9ff'),emissiveMap:tx.runas,emissiveIntensity:.55});
  /* condutor com pulso de energia correndo pelo comprimento (no Roblox: Beam com textura animada) */
  const cond=cu.clone();cond.name='CondutorCobre';cond.userData.u={uT:{value:0},uPulse:{value:1}};cond.onBeforeCompile=sh=>{Object.assign(sh.uniforms,cond.userData.u);
    sh.fragmentShader=sh.fragmentShader.replace('#include <common>','#include <common>\nuniform float uT,uPulse;').replace('#include <emissivemap_fragment>','#include <emissivemap_fragment>\ntotalEmissiveRadiance+=vec3(.35,.85,1.)*pow(max(0.,sin(vUv.x*55.-uT*7.)),28.)*2.4*uPulse;');};
  const tw=MM.obj('STORM.ARCH.TOWER','Torre Meteorológica (V2)','Architecture',{notes:'Monumento central. Porta 10 × 13 studs para a vila. Peças animadas separadas: anéis do captador, engrenagens, anemômetro, cata-vento. Futuro puzzle STORM.PUZZLE.TOWER (alinhar os anéis).'});
  tw.position.set(P.x,y0,P.z);const add=(g,m,x,y,z,p)=>MM.mesh(g,m,x,y,z,p||tw);
  const oct=(r1,r2,h,m,y)=>{const c=add(new T.CylinderGeometry(r1,r2,h,8),m,0,y,0);c.rotation.y=Math.PI/8;return c;};
  /* 1. base: plintos escalonados, paredes com painéis rebaixados, contrafortes com condutores */
  oct(30,31,1.2,stone2,.6);oct(27.5,28.5,1.6,stone,2);oct(24,26,13,stone,9.3);oct(26.6,26.6,1.4,stone2,16.5);
  for(let i=0;i<8;i++){const a=i/8*Math.PI*2+Math.PI/8;if(i===7||i===0)continue;const px=Math.sin(a)*24.3,pz=Math.cos(a)*24.3;const pn=add(MM.bevelBox(11,8,.6,.2),stone2,px,9,pz);pn.rotation.y=a;
    const w=add(new T.BoxGeometry(2,5,.4),glass,Math.sin(a)*24.7,10,Math.cos(a)*24.7);w.rotation.y=a;}
  for(let i=0;i<8;i++){const a=i/8*Math.PI*2;if(i===0)continue;const g=new T.Group();g.position.set(Math.sin(a)*25.5,0,Math.cos(a)*25.5);g.rotation.y=a;tw.add(g);
    [[3.6,7,8,3.5],[3,5,6.4,9.4],[2.4,4,4.8,13.6]].forEach(([w,h,d,y])=>add(MM.bevelBox(w,h,d,.3),stone,0,y,d/2-1.5,g));add(new T.ConeGeometry(1.4,3.4,4),cu,0,17.4,0,g).rotation.y=Math.PI/4;
    /* condutor descendo pelo contraforte até a estaca */add(new T.BoxGeometry(.5,15,.25),cond,0,8,6.6,g);add(new T.CylinderGeometry(.35,.35,2.4,6),cu,0,.6,7.4,g);}
  /* escadaria e portal (frente +Z) */
  /* V2.3.1 — escadaria refeita a partir do terreno real: desce do patamar da porta (7,2) em degraus de 0,9 × 1,3 até o primeiro degrau
     que toca o chão (o terraço onde a trilha P1 chega). Cada degrau é maciço até o terreno sob ele, com murete lateral e colisor do mesmo tamanho.
     Antes: 8 degraus de 2 studs de piso que passavam POR CIMA do terraço da trilha (como um muro) e um lance de 27 degraus morro abaixo. */
  const degs=[];for(let i=0;i<40;i++){const top=7.2-.9*i,z=24.65+1.3*i,w=16+i*.12;const gl=Math.min(...[-w/2,-w/4,0,w/4,w/2].map(dx=>ctx.heightAt(P.x+dx,P.z+z)))-y0;if(i>0&&top<=gl+.3)break;
    const bot=Math.min(gl-.8,top-.9),h=top-bot;const st=add(MM.bevelBox(w,h,1.42,.12),i%2?stone2:stone,0,top-h/2,z);st.userData.apoio=true;MM.box(tw,0,top-h/2,z,w,h,1.42);degs.push({top,z,w,gl});}
  tw.userData.lowerSteps=degs.length;tw.userData.escada={degraus:degs.length,peZ:degs[degs.length-1].z,peTopo:degs[degs.length-1].top};
  /* muretes laterais maciços até o chão + balaustrada (pilaretes a cada 2 degraus, corrimão de metal, pilares de arranque com capitel de bronze) */
  [-1,1].forEach(sd=>{const rail=[];degs.forEach((q,j)=>{const x=sd*(q.w/2+.6);const gl=Math.min(ctx.heightAt(P.x+x,P.z+q.z)-y0,q.gl)-.8;const h=q.top+.5-gl;const m=add(MM.bevelBox(1.3,h,1.42,.12),stone,x,q.top+.5-h/2,q.z);m.userData.apoio=true;
      if(j%2===0||j===degs.length-1)add(MM.bevelBox(.8,2.8,.8,.12),stone2,x,q.top+1.9,q.z);rail.push(new T.Vector3(x,q.top+3.45,q.z));});
    tw.add(MM.tube(rail,.2,met,degs.length*3,6));[0,degs.length-1].forEach(j=>{const q=degs[j];const x=sd*(q.w/2+.6);add(MM.bevelBox(1.8,5,1.8,.2),stone2,x,q.top+2.5,q.z);add(new T.SphereGeometry(.7,10,8),bronze,x,q.top+5.6,q.z);add(MM.bevelBox(2.1,.4,2.1,.1),bronze,x,q.top+5.05,q.z);});});
  add(new T.BoxGeometry(11,13,1),new T.MeshStandardMaterial({color:MM.C('#120f14'),roughness:1}),0,13,24.4);
  [-1,1].forEach(sd=>{const leaf=new T.Group();leaf.position.set(sd*5.3,7.6,24.9);tw.add(leaf);add(MM.bevelBox(5.1,12.6,.8,.12),wood,-sd*2.55,6.3,0,leaf);
    [1.5,6.3,11].forEach(y=>add(new T.BoxGeometry(5.1,.5,.3),metD,-sd*2.55,y,.5,leaf));for(let k=0;k<4;k++)[1.5,6.3,11].forEach(y=>add(new T.SphereGeometry(.16,6,4),met,-sd*(.6+k*1.2),y,.7,leaf));
    add(new T.TorusGeometry(.5,.12,6,12),met,-sd*.8,6.6,.65,leaf);leaf.rotation.y=sd*.25;/* entreaberta */});
  for(let k=0;k<=10;k++){const a=Math.PI*k/10;const v=add(MM.bevelBox(2.4,2.8,3,.25),k===5?stone2:stone,Math.cos(a)*7.6,20.6+Math.sin(a)*5.4,25.3);v.rotation.z=a-Math.PI/2;}
  add(MM.crystalGeo(.8,1.8,1.4),crys,0,27,26.8).rotation.x=.2;[-7.6,7.6].forEach(x=>add(MM.bevelBox(2.6,14,3.2,.3),stone2,x,13.6,25.3));
  const rb=add(new T.CylinderGeometry(26.75,26.75,1.8,8,1,true),rune,0,18.2,0);rb.rotation.y=Math.PI/8;tx.runas.repeat.set(4,1);
  /* 2. fuste: fiadas de pedra, cornijas com mísulas, janelas em arco, escada em espiral */
  oct(14.5,18.5,44,stone,40);
  [26,40,54].forEach(y=>{const r=18.5-(y-18)/44*4;oct(r+1.1,r+.6,1.2,stone2,y);oct(r+.5,r+1.1,.8,stone2,y-1);for(let i=0;i<16;i++){const a=i/16*Math.PI*2;const c=add(MM.bevelBox(1,1.4,1.4,.15),stone2,Math.sin(a)*(r+.4),y-2,Math.cos(a)*(r+.4));c.rotation.y=a;}});
  for(let lv=0;lv<3;lv++)for(let i=0;i<4;i++){const a=i/4*Math.PI*2+Math.PI/4;const r=18.2-lv*1.3-1.9;const y=31+lv*14;const g=new T.Group();g.position.set(Math.sin(a)*r,y,Math.cos(a)*r);g.rotation.y=a;tw.add(g);
    add(new T.BoxGeometry(2.6,5,.6),glass,0,0,.4,g);add(new T.BoxGeometry(.25,5,.4),metD,0,0,.75,g);add(new T.BoxGeometry(2.6,.25,.4),metD,0,.6,.75,g);
    add(new T.TorusGeometry(1.4,.32,5,10,Math.PI),stone2,0,2.5,.6,g);[-1.5,1.5].forEach(x=>add(MM.bevelBox(.6,5.4,1,.1),stone2,x,-.2,.6,g));add(MM.bevelBox(3.8,.6,1.6,.1),stone2,0,-2.8,.8,g);}
  const steps=48;const rail=[];for(let s=0;s<steps;s++){const a=s/steps*Math.PI*2.6+Math.PI*.55,y=18.3+s*.82;const r=21.2-(s/steps)*3.6;const st=add(MM.bevelBox(6,.7,3,.15),stone2,Math.sin(a)*r,y,Math.cos(a)*r);st.rotation.y=a+Math.PI/2;
    const rr=r+2.7;rail.push(new T.Vector3(Math.sin(a)*rr,y+3.4,Math.cos(a)*rr));if(s%2===0)add(new T.CylinderGeometry(.13,.13,3.4,5),metD,Math.sin(a)*rr,y+1.7,Math.cos(a)*rr).castShadow=false;}
  tw.add(MM.tube(rail,.16,met,96,5));
  /* 3. galeria de instrumentos (y≈62): piso com mísulas, guarda-corpo, barômetro, pluviômetro, antenas */
  add(new T.CylinderGeometry(22,20.5,1.6,32),metD,0,62,0);for(let i=0;i<24;i++){const a=i/24*Math.PI*2;const c=add(MM.bevelBox(1,2.2,3,.12),stone2,Math.sin(a)*18.5,60.3,Math.cos(a)*18.5);c.rotation.y=a;}
  add(new T.TorusGeometry(21.6,.2,5,64),met,0,65.4,0).rotation.x=Math.PI/2;add(new T.TorusGeometry(21.6,.14,5,64),met,0,64,0).rotation.x=Math.PI/2;
  for(let i=0;i<36;i++){const a=i/36*Math.PI*2;add(new T.CylinderGeometry(.12,.12,3.4,4),metD,Math.sin(a)*21.6,63.7,Math.cos(a)*21.6).castShadow=false;}
  {const gm=new T.MeshStandardMaterial({map:gaugeTex(),roughness:.4});gm.name='MostradorBarometro';const bg=new T.Group();bg.position.set(12,66.5,12);bg.rotation.y=Math.PI/4;tw.add(bg);
    add(new T.CylinderGeometry(2.1,2.1,.5,24),cu,0,0,0,bg).rotation.x=Math.PI/2;const face=add(new T.CircleGeometry(1.85,24),gm,0,0,.27,bg);add(new T.CylinderGeometry(.3,.3,4.5,6),metD,0,-2.6,0,bg);
    add(new T.CylinderGeometry(.8,.8,3,10),glass,-14,64.5,8);add(new T.CylinderGeometry(.85,.85,.3,10),cu,-14,66,8);
    [[-6,15],[15,-6],[-15,-9]].forEach(([x,z],i)=>{add(new T.CylinderGeometry(.14,.22,9+i*2,5),met,x,67+i,z);add(new T.BoxGeometry(2.4,.12,.12),met,x,69+i*1.5,z);add(new T.BoxGeometry(1.6,.12,.12),met,x,70.5+i*1.5,z);});}
  /* 4. casa de máquinas com engrenagens à mostra (y 63–74) */
  oct(13,14,10,stone,67.8);oct(14.4,14.4,1,stone2,73.2);const gears=[];
  [[0,1],[Math.PI,1],[Math.PI/2,-1]].forEach(([a,dir],k)=>{const g=new T.Group();g.position.set(Math.sin(a)*13.8,68,Math.cos(a)*13.8);g.rotation.y=a;g.name='Engrenagens'+k;g.userData.animated=true;tw.add(g);
    const big=add(gearGeo(3.4,14,.9,.7),met,0,0,.9,g);const sm=add(gearGeo(1.7,8,.8,.4),cu,4.1,2.2,1.1,g);big.userData.spin=.35*dir;sm.userData.spin=-.35*2*dir;gears.push(big,sm);
    add(new T.CylinderGeometry(.4,.4,1.6,8),metD,0,0,.4,g).rotation.x=Math.PI/2;});
  for(let k=0;k<4;k++){const a=k/4*Math.PI*2+.4;const pts=[new T.Vector3(Math.sin(a)*14.6,62.5,Math.cos(a)*14.6),new T.Vector3(Math.sin(a)*15.2,67,Math.cos(a)*15.2),new T.Vector3(Math.sin(a)*14.2,73.6,Math.cos(a)*14.2),new T.Vector3(Math.sin(a)*9.5,76,Math.cos(a)*9.5)];tw.add(MM.tube(pts,.45,cu,20,7));}
  /* 5. treliça de vigas I com contraventamento e chapas rebitadas; passarela; núcleo de energia */
  const S=8;[[1,1],[1,-1],[-1,1],[-1,-1]].forEach(([a,b])=>{const c=add(ibeam(34,2),met,a*S,74,b*S);c.rotation.y=Math.atan2(a,b);});
  for(let lv=0;lv<4;lv++){const ya=74+lv*8.5,yb=ya+8.5;[[[S,S],[S,-S]],[[S,-S],[-S,-S]],[[-S,-S],[-S,S]],[[-S,S],[S,S]]].forEach(([p,q])=>{
      [[ya,yb],[yb,ya]].forEach(([y1,y2])=>{const A=new T.Vector3(p[0],y1,p[1]),B=new T.Vector3(q[0],y2,q[1]);const L=A.distanceTo(B);const br=add(new T.BoxGeometry(.5,L,.9),metD,(A.x+B.x)/2,(A.y+B.y)/2,(A.z+B.z)/2);br.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),B.clone().sub(A).normalize());});
      const mid=new T.Vector3((p[0]+q[0])/2,(ya+yb)/2,(p[1]+q[1])/2);const pl=add(new T.BoxGeometry(1.6,1.6,.3),met,mid.x,mid.y,mid.z);pl.lookAt(0,mid.y,0);for(const [ox,oy] of [[-.55,-.55],[.55,-.55],[-.55,.55],[.55,.55]])add(new T.SphereGeometry(.13,6,4),bronze,ox,oy,-.2,pl).castShadow=false;});
    [[0,S,1],[0,-S,1],[S,0,0],[-S,0,0]].forEach(([x,z,o])=>{const h=add(new T.BoxGeometry(o?S*2+2:1.2,1,o?1.2:S*2+2),met,x,yb,z);});}
  add(new T.TorusGeometry(12.5,.9,4,40),metD,0,91,0).rotation.x=Math.PI/2;add(new T.TorusGeometry(13.6,.15,5,48),met,0,94,0).rotation.x=Math.PI/2;
  for(let i=0;i<28;i++){const a=i/28*Math.PI*2;add(new T.CylinderGeometry(.1,.1,3,4),metD,Math.sin(a)*13.6,92.5,Math.cos(a)*13.6).castShadow=false;}
  /* mãos-francesas: passarela (y 91) presa às colunas; braços das bobinas; escoras da plataforma (y 108) */
  const strut=(A,B,w,m)=>{const L=A.distanceTo(B);const b=add(new T.BoxGeometry(w,L,w),m||metD,(A.x+B.x)/2,(A.y+B.y)/2,(A.z+B.z)/2);b.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),B.clone().sub(A).normalize());return b;};
  for(let i=0;i<8;i++){const a=i/8*Math.PI*2+Math.PI/8;const c=Math.cos(a),sn=Math.sin(a);const rc=i%2?9.3:8.6;strut(new T.Vector3(sn*rc,86.5,c*rc),new T.Vector3(sn*12.4,90.6,c*12.4),.45);add(new T.BoxGeometry(.5,.5,4.6),metD,sn*10.6,91,c*10.6).rotation.y=a;}
  [80,90,100].forEach(y=>{for(let i=0;i<4;i++){const a=i/4*Math.PI*2+Math.PI/4;const b=add(new T.BoxGeometry(.5,.7,2.4),met,Math.sin(a)*10.4,y,Math.cos(a)*10.4);b.rotation.y=a;add(new T.CylinderGeometry(.18,.18,.9,6),bronze,Math.sin(a)*9.8,y+.6,Math.cos(a)*9.8);}});
  for(let i=0;i<8;i++){const a=i/8*Math.PI*2+Math.PI/8;const c=Math.cos(a),sn=Math.sin(a);strut(new T.Vector3(Math.sign(sn)*S*.98,100,Math.sign(c)*S*.98),new T.Vector3(sn*14.6,108.2,c*14.6),.55);}
  for(let k=0;k<4;k++){const a=k/4*Math.PI*2;const A=new T.Vector3(Math.sin(a)*15,108.4,Math.cos(a)*15),B=new T.Vector3(Math.sin(a)*21,64.6,Math.cos(a)*21);tw.add(MM.tube(MM.catenary(A,B,2.2,16),.12,metD,20,4));
    add(new T.CylinderGeometry(.3,.3,.8,6),bronze,A.x,A.y-.2,A.z);add(new T.CylinderGeometry(.3,.3,.8,6),bronze,B.x,B.y+.3,B.z);}
  add(new T.CylinderGeometry(3.1,3.1,30,6),crys,0,90,0);add(new T.CylinderGeometry(.55,.55,31,6),core,0,90,0).castShadow=false;
  {const hp=[];for(let i=0;i<=120;i++){const t=i/120,a=t*Math.PI*14;hp.push(new T.Vector3(Math.cos(a)*1.9,75.5+t*29,Math.sin(a)*1.9));}const hx=MM.tube(hp,.14,core,240,4);hx.castShadow=false;tw.add(hx);}
  [80,90,100].forEach((y,i)=>{add(new T.TorusGeometry(9.8,.85,10,40),cu,0,y,0).rotation.x=Math.PI/2;add(new T.TorusGeometry(9.8,.3,6,40),core,0,y,0).rotation.x=Math.PI/2;});
  /* 6. plataforma de antenas, cúpula de cobre com escotilhas e lanterna */
  add(new T.CylinderGeometry(16,12,4,32),metD,0,110,0);add(new T.TorusGeometry(15.8,.25,5,48),met,0,114.4,0).rotation.x=Math.PI/2;
  for(let i=0;i<20;i++){const a=i/20*Math.PI*2;add(new T.CylinderGeometry(.14,.14,3,4),metD,Math.sin(a)*15.8,113,Math.cos(a)*15.8).castShadow=false;}
  [[1,0],[-.7,.7]].forEach(([dx,dz],i)=>{const g=new T.Group();g.position.set(dx*12,112.4,dz*12);g.lookAt(dx*40,130,dz*40);tw.add(g);const d=add(new T.SphereGeometry(4,20,8,0,Math.PI*2,0,Math.PI*.32),met,0,0,0,g);d.rotation.x=-Math.PI/2;d.material=met;add(new T.CylinderGeometry(.12,.12,4,4),metD,0,0,2,g).rotation.x=Math.PI/2;});
  const dome=add(new T.SphereGeometry(10,24,12,0,Math.PI*2,0,Math.PI/2),cu,0,112,0);for(let i=0;i<8;i++){add(new T.TorusGeometry(10.1,.32,5,18,Math.PI),met,0,112,0).rotation.y=i/8*Math.PI;}
  for(let i=0;i<6;i++){const a=i/6*Math.PI*2;const ph=.5;const p=new T.Vector3(Math.sin(a)*Math.cos(ph)*10.05,112+Math.sin(ph)*10.05,Math.cos(a)*Math.cos(ph)*10.05);const w=add(new T.CircleGeometry(.9,12),glass,p.x,p.y,p.z);w.lookAt(p.clone().multiplyScalar(2).sub(new T.Vector3(0,112,0)));add(new T.TorusGeometry(.95,.18,5,14),met,p.x,p.y,p.z).lookAt(0,112,0);}
  add(new T.CylinderGeometry(2.6,3,4,8),metD,0,123.5,0);add(new T.ConeGeometry(3.2,2.6,8),cu,0,126.8,0);
  /* anemômetro e cata-vento */
  const anem=new T.Group();anem.name='Anemometro';anem.position.set(10.5,114.5,-6);tw.add(anem);anem.userData.animated=true;add(new T.CylinderGeometry(.18,.18,5,5),met,0,-1.5,0,anem);
  for(let i=0;i<3;i++){const a=i/3*Math.PI*2;const arm=add(new T.BoxGeometry(.16,.16,4),met,Math.sin(a)*2,1.2,Math.cos(a)*2,anem);arm.rotation.y=a;const cup=add(new T.SphereGeometry(.7,10,6,0,Math.PI*2,0,Math.PI/2),cu,Math.sin(a)*4,1.2,Math.cos(a)*4,anem);cup.rotation.set(0,a+Math.PI/2,Math.PI/2);}
  const vane=new T.Group();vane.name='CataVento';vane.position.set(-10.5,114.5,6);tw.add(vane);vane.userData.animated=true;add(new T.CylinderGeometry(.15,.15,4,5),met,0,0,0,vane);add(new T.ConeGeometry(.7,2.4,4),cu,0,2.2,1.6,vane).rotation.x=Math.PI/2;add(new T.BoxGeometry(.12,1.8,2.6),cu,0,2.2,-1.6,vane);
  /* 7. CAPTADOR DE TEMPESTADES — cardã de verdade: anel externo gira no eixo vertical (mancais no mastro e no topo), anel médio gira
     sobre eixos presos ao externo, anel interno sobre eixos presos ao médio. Cristal suspenso no eixo de energia, no centro de todos. */
  add(new T.CylinderGeometry(1.1,1.6,22,8),met,0,128,0);[122,128,134].forEach(y=>add(new T.TorusGeometry(1.9,.4,6,14),bronze,0,y,0).rotation.x=Math.PI/2);
  for(let i=0;i<4;i++){const a=i/4*Math.PI*2;strut(new T.Vector3(Math.sin(a)*2.8,126.5,Math.cos(a)*2.8),new T.Vector3(Math.sin(a)*1.2,136,Math.cos(a)*1.2),.35,cu);}
  const catcher=new T.Group();catcher.name='CaptadorDeTempestades';catcher.position.set(0,152,0);tw.add(catcher);catcher.userData.animated=true;
  /* mancais fixos (base e topo) */
  add(new T.CylinderGeometry(1.7,2.1,3,12),bronze,0,-14.6,0,catcher);add(new T.TorusGeometry(2.2,.35,6,16),met,0,-13.2,0,catcher).rotation.x=Math.PI/2;
  add(new T.CylinderGeometry(1.7,1.7,2.8,12),bronze,0,14.4,0,catcher);add(new T.CylinderGeometry(3.2,2.4,.7,16),bronze,0,15.9,0,catcher);
  const ringDef=[[13,1.15],[10,.95],[7,.78]];const rings=[];let parent=catcher;
  ringDef.forEach(([R,t],k)=>{const g=new T.Group();g.name='AnelCardan'+k;parent.add(g);
    if(k===1)g.rotation.x=Math.PI/2;if(k===2)g.rotation.y=Math.PI/2;
    add(new T.TorusGeometry(R,t,12,96),met,0,0,0,g);const band=add(new T.TorusGeometry(R,t*1.03,4,96),rune,0,0,0,g);band.scale.z=.4;
    add(new T.TorusGeometry(R+t*.9,t*.28,5,96),bronze,0,0,0,g);add(new T.TorusGeometry(R-t*.9,t*.28,5,96),bronze,0,0,0,g);
    for(let n=0;n<8;n++){const a=n/8*Math.PI*2+Math.PI/8;add(new T.SphereGeometry(t*1.2,10,8),bronze,Math.cos(a)*R,Math.sin(a)*R,0,g);}
    if(k===0)for(let n=0;n<24;n++){const a=n/24*Math.PI*2;if(Math.abs(Math.cos(a))>.97||Math.abs(Math.sin(a))>.97)continue;const f=add(MM.bevelBox(.5,1.6,.7,.1),bronze,Math.cos(a)*(R+1.6),Math.sin(a)*(R+1.6),0,g);f.rotation.z=a-Math.PI/2;}
    /* eixos que prendem o próximo anel: k0 → eixo X (pinos em ±x); k1 → eixo local Y */
    if(k===0)[-1,1].forEach(sd=>{add(new T.CylinderGeometry(.42,.42,3.2,8),met,sd*11.5,0,0,g).rotation.z=Math.PI/2;add(new T.CylinderGeometry(.9,.9,.8,10),bronze,sd*(R-.2),0,0,g).rotation.z=Math.PI/2;});
    if(k===1)[-1,1].forEach(sd=>{add(new T.CylinderGeometry(.38,.38,3.2,8),met,0,sd*8.5,0,g);add(new T.CylinderGeometry(.8,.8,.7,10),bronze,0,sd*(R-.2),0,g);});
    rings.push(g);parent=g;});
  {const cg=new T.OctahedronGeometry(3.6,0);cg.scale(1,1.62,1);const cr=add(cg,crys,0,0,0,catcher);cr.name='CristalAtmosferico';const ci=add(new T.OctahedronGeometry(1.5,0),core,0,0,0,catcher);ci.scale.y=1.7;ci.castShadow=false;
    [[-13,-6.2],[6.2,13]].forEach(([y1,y2])=>{const b=add(new T.CylinderGeometry(.16,.16,y2-y1,6),core,0,(y1+y2)/2,0,catcher);b.castShadow=false;b.name='EixoDeEnergia';});}
  for(let k=0;k<5;k++){const a=k/5*Math.PI*2;const base=new T.Vector3(Math.cos(a)*2.6,16.2,Math.sin(a)*2.6);const tipv=new T.Vector3(Math.cos(a)*.7,24.5,Math.sin(a)*.7);
    const nd=strut(new T.Vector3(base.x,152+base.y,base.z),new T.Vector3(tipv.x,152+tipv.y,tipv.z),.3,met);nd.geometry=new T.CylinderGeometry(.08,.3,base.distanceTo(tipv),5);add(new T.SphereGeometry(.32,8,6),bronze,base.x,152+base.y,base.z);}
  add(new T.CylinderGeometry(.18,.5,10.5,6),met,0,172.3,0);const tip=add(new T.SphereGeometry(.9,12,8),core,0,177.4,0);tip.castShadow=false;tip.name='PontaParaRaios';
  /* condutores de cobre: do captador, pela treliça e contrafortes, até o chão */
  for(let k=0;k<4;k++){const a=k/4*Math.PI*2+Math.PI/4;const pts=[];const add3=(r,y)=>pts.push(new T.Vector3(Math.sin(a)*r,y,Math.cos(a)*r));
    add3(1.9,136.6);add3(5,133);add3(9.5,126);add3(13,116);add3(11.4,104);add3(9.6,90);add3(9.6,76);add3(15.5,72);add3(19,58);add3(21.5,30);add3(27,16);add3(30.5,2);add3(33,.3);
    const tb=MM.tube(pts,.32,cond,140,6);tb.name='Condutor'+k;tw.add(tb);}
  /* colisores (V2.3.1: a caixa da base para antes do patamar da porta, que agora é alcançável pela escadaria) */
  [[0,-1.3,21.5,49.4,0],[0,0,52,21.5,0],[0,0,21.5,52,Math.PI/4],[0,0,52,21.5,Math.PI/4]].forEach(([x,z,sx,sz,ry])=>MM.box(tw,x,8,z,sx,16,sz,ry));/* base octogonal (4 faixas) — antes um quadrado de 54 cujos cantos fechavam o platô */
  for(let i=1;i<8;i++){const a=i/8*Math.PI*2;MM.box(tw,Math.sin(a)*28,7,Math.cos(a)*28,3.8,14,8,a);}/* contrafortes */MM.box(tw,0,40,0,36,44,36);MM.box(tw,0,62,0,44,2,44);MM.box(tw,0,68,0,28,12,28);MM.box(tw,0,90,0,20,32,20);MM.box(tw,0,110,0,32,6,32);MM.box(tw,0,118,0,20,12,20);
  
  tw.userData.walk=[{type:'rect',y:y0+7.2,x:P.x,z:P.z+26,sx:14,sz:4}];tw.userData.assento=MM.seat(ctx,tw,{r:33,y:y0,mat:stone});/* alicerce só onde o platô não cobre o plinto */
  tw.userData.anim={anem,vane};tw.userData.tip=new T.Vector3(P.x,y0+177.4,P.z);tw.userData.coils=[80,90,100].map(y=>new T.Vector3(P.x,y0+y,P.z));
  const AX=[new T.Vector3(0,1,0),new T.Vector3(1,0,0),new T.Vector3(0,1,0)];
  tw.userData.update=function(dt,t,on){rings.forEach((g,i)=>{g.rotateOnAxis(AX[i],dt*(on?.3:.08)*(i%2?-1:1)*(1+i*.5));});gears.forEach(g=>g.rotation.z+=dt*g.userData.spin);cond.userData.u.uT.value=t;cond.userData.u.uPulse.value=on?1:0;};
  return[tw];};
})();
