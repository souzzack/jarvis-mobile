/* Ilha das Tempestades · Architecture · Oficina dos Inventores (V2.3.4)
   Edifício de fantasia tecnológica: plinto de pedra lavrada com canaletas de drenagem, embasamento de cantaria, enxaimel de madeira
   com reboco e reforços de ferro, telhado de duas águas estruturado (tesouras, caibros, tabuado, chapas de junta em pé, calhas,
   condutores e para-raios), entrada em arco com porta dupla, lanternas e placa. Interior explorável em quatro áreas:
   bancadas, laboratório atmosférico, depósito e canto do inventor (lugar do NPC STORM.NPC.02) — e, no centro, o
   CONDENSADOR ATMOSFÉRICO. Frente = +Z local. Piso interno em y = 1,6 (topo do plinto). Tudo em studs.
   Peças animadas ficam em grupos próprios; o telhado é um grupo separado para poder ser ocultado na inspeção. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
const W=26,D=20,F=1.6,TW=.9,E=F+11;/* largura (x), profundidade (z), piso, espessura da parede, topo das paredes */
const S=.55,YT=E+.35+S*10;/* inclinação do telhado (≈29°) e altura da cumeeira no eixo dos caibros */
function canvasTex(w,h,draw){const c=document.createElement('canvas');c.width=w;c.height=h;draw(c.getContext('2d'),w,h);const t=new T.CanvasTexture(c);t.encoding=T.sRGBEncoding;t.anisotropy=4;return t;}
function gearGeo(R,teeth,th){const s=new T.Shape();const n=teeth*4;for(let i=0;i<=n;i++){const a=i/n*Math.PI*2;const k=i%4;const r=k===0||k===3?R:R*1.18;i?s.lineTo(Math.cos(a)*r,Math.sin(a)*r):s.moveTo(Math.cos(a)*r,Math.sin(a)*r);}
  const h=new T.Path();h.absarc(0,0,R*.28,0,Math.PI*2,true);s.holes.push(h);const g=new T.ExtrudeGeometry(s,{depth:th,bevelEnabled:false,curveSegments:4});g.translate(0,0,-th/2);return g;}
/* parede com aberturas reais: retângulo (u,v) com furos (retangulares ou em arco) extrudado na espessura */
function wallGeo(u0,u1,v0,v1,holes,t){const s=new T.Shape();s.moveTo(u0,v0);s.lineTo(u1,v0);s.lineTo(u1,v1);s.lineTo(u0,v1);s.lineTo(u0,v0);
  (holes||[]).forEach(hh=>{const p=new T.Path();if(hh.circ){p.absarc(hh.u,hh.v,hh.r,0,Math.PI*2,true);}else if(hh.arch){p.moveTo(hh.u0,hh.v0);p.lineTo(hh.u0,hh.v1);p.absarc((hh.u0+hh.u1)/2,hh.v1,(hh.u1-hh.u0)/2,Math.PI,0,true);p.lineTo(hh.u1,hh.v0);p.lineTo(hh.u0,hh.v0);}
    else{p.moveTo(hh.u0,hh.v0);p.lineTo(hh.u0,hh.v1);p.lineTo(hh.u1,hh.v1);p.lineTo(hh.u1,hh.v0);p.lineTo(hh.u0,hh.v0);}s.holes.push(p);});
  const g=new T.ExtrudeGeometry(s,{depth:t,bevelEnabled:false,curveSegments:10});g.translate(0,0,-t/2);return g;}
I.buildWorkshop=function(ctx,ws){const M=ctx.mat,tx=MM.tex;const rnd=MM.rng(2341);
  /* ---------- materiais (compartilhados por toda a oficina) ---------- */
  const stone=MM.triplanar({mode:'rocha',name:'OficinaCantaria',rockScale:.11,strata:0,tint:'#e9e1d8',mossTop:.3,env:.5});stone.userData.u.tRockC.value=tx.blocos.map;stone.userData.u.tRockN.value=tx.blocos.normalMap;
  const stoneL=MM.triplanar({mode:'rocha',name:'OficinaPedraLavrada',rockScale:.07,strata:0,tint:'#fff6ea',env:.5});
  const wood=new T.MeshStandardMaterial({name:'OficinaMadeira',map:tx.madeira.map,normalMap:tx.madeira.normalMap,roughnessMap:tx.madeira.roughnessMap,roughness:1,color:MM.C('#d9c2a6')});
  const woodD=new T.MeshStandardMaterial({name:'OficinaMadeiraEstrutural',map:tx.madeira.map,normalMap:tx.madeira.normalMap,roughnessMap:tx.madeira.roughnessMap,roughness:1,color:MM.C('#8e6f58')});
  const pm=tx.terra.map.clone();pm.needsUpdate=true;pm.repeat.set(.16,.16);const plaster=new T.MeshStandardMaterial({name:'OficinaReboco',color:MM.C('#e8dccb'),map:pm,roughness:.95});/* reboco: textura de terra clara em escala grande */
  const iron=new T.MeshStandardMaterial({name:'OficinaFerroEscovado',map:tx.metal.map,normalMap:tx.metal.normalMap,roughnessMap:tx.metal.roughnessMap,metalness:.85,roughness:.62,color:MM.C('#9aa0a8')});
  const ironD=new T.MeshStandardMaterial({name:'OficinaFerroEscuro',map:tx.metal.map,normalMap:tx.metal.normalMap,roughnessMap:tx.metal.roughnessMap,metalness:.75,roughness:.9,color:MM.C('#4a4d55')});
  const bronze=new T.MeshStandardMaterial({name:'OficinaBronze',map:tx.cobre.map,normalMap:tx.cobre.normalMap,roughnessMap:tx.cobre.roughnessMap,metalness:.85,roughness:.7,color:MM.C('#d6b07a')});
  const copper=new T.MeshStandardMaterial({name:'OficinaCobreOxidado',map:tx.cobre.map,normalMap:tx.cobre.normalMap,roughnessMap:tx.cobre.roughnessMap,metalness:.75,roughness:1});
  const roofM=new T.MeshStandardMaterial({name:'OficinaChapaTelhado',map:tx.metal.map,normalMap:tx.metal.normalMap,roughnessMap:tx.metal.roughnessMap,metalness:.6,roughness:.8,color:MM.C('#5c6f78')});
  const glass=new T.MeshPhysicalMaterial({name:'OficinaVidro',color:MM.C('#6f8c99'),roughness:.08,transmission:.5,transparent:true,opacity:.6,clearcoat:1,emissive:MM.C('#ffb36b'),emissiveIntensity:.25});
  const crys=new T.MeshPhysicalMaterial({name:'OficinaCristal',color:MM.C('#b8eeff'),roughness:.05,transmission:.6,transparent:true,opacity:.92,clearcoat:1,flatShading:true,emissive:MM.C('#3fc8ff'),emissiveIntensity:.45});
  const core=new T.MeshStandardMaterial({name:'OficinaNucleo',color:MM.C('#c8f6ff'),emissive:MM.C('#43d9ff'),emissiveIntensity:1.8});
  const warm=new T.MeshStandardMaterial({name:'OficinaLuzQuente',color:MM.C('#ffd9a0'),emissive:MM.C('#ffb050'),emissiveIntensity:1.4});
  const rune=new T.MeshStandardMaterial({name:'OficinaRunas',color:MM.C('#77716a'),roughness:.85,emissive:MM.C('#43d9ff'),emissiveMap:tx.runas,emissiveIntensity:.6});
  const sign=new T.MeshStandardMaterial({name:'OficinaPlaca',roughness:.8,map:canvasTex(512,128,(g,w,h)=>{g.fillStyle='#3a2a1e';g.fillRect(0,0,w,h);g.strokeStyle='#c99a5b';g.lineWidth=6;g.strokeRect(8,8,w-16,h-16);
    g.fillStyle='#e8c98f';g.font='bold 40px serif';g.textAlign='center';g.fillText('OFICINA DOS',w/2+30,56);g.fillText('INVENTORES',w/2+30,100);g.beginPath();g.arc(64,64,34,0,Math.PI*2);g.lineWidth=8;g.stroke();
    for(let i=0;i<8;i++){const a=i/8*Math.PI*2;g.fillRect(64+Math.cos(a)*40-5,64+Math.sin(a)*40-5,10,10);}g.fillStyle='#7fe4ff';g.beginPath();g.moveTo(66,40);g.lineTo(54,68);g.lineTo(66,66);g.lineTo(60,90);g.lineTo(76,58);g.lineTo(64,60);g.fill();})});
  const paper=new T.MeshStandardMaterial({name:'OficinaProjetos',roughness:.9,side:T.DoubleSide,map:canvasTex(256,256,(g,w,h)=>{g.fillStyle='#24476e';g.fillRect(0,0,w,h);g.strokeStyle='rgba(220,235,255,.85)';g.lineWidth=2;
    for(let i=0;i<w;i+=16){g.globalAlpha=.25;g.beginPath();g.moveTo(i,0);g.lineTo(i,h);g.moveTo(0,i);g.lineTo(w,i);g.stroke();}g.globalAlpha=1;g.beginPath();g.arc(128,120,62,0,Math.PI*2);g.arc(128,120,30,0,Math.PI*2);g.stroke();
    for(let i=0;i<12;i++){const a=i/12*Math.PI*2;g.beginPath();g.moveTo(128+Math.cos(a)*62,120+Math.sin(a)*62);g.lineTo(128+Math.cos(a)*74,120+Math.sin(a)*74);g.stroke();}g.strokeRect(40,200,176,36);g.font='14px monospace';g.fillStyle='#dceaff';g.fillText('CONDENSADOR · CORTE A-A',46,222);})});
  const gauge=new T.MeshStandardMaterial({name:'OficinaMostrador',roughness:.4,map:canvasTex(128,128,(g,w,h)=>{g.fillStyle='#ece4cf';g.beginPath();g.arc(64,64,62,0,Math.PI*2);g.fill();g.strokeStyle='#2a2522';g.lineWidth=2;
    for(let i=0;i<=20;i++){const a=Math.PI*.75+i/20*Math.PI*1.5;const r0=i%5?48:40;g.beginPath();g.moveTo(64+Math.cos(a)*r0,64+Math.sin(a)*r0);g.lineTo(64+Math.cos(a)*56,64+Math.sin(a)*56);g.stroke();}g.fillStyle='#8a1f1f';g.fillRect(60,92,8,6);})});
  /* condutor com pulso (como na torre): no Roblox vira Beam com textura animada */
  const cond=copper.clone();cond.name='OficinaCondutor';cond.userData.u={uT:{value:0},uPulse:{value:1}};cond.onBeforeCompile=sh=>{Object.assign(sh.uniforms,cond.userData.u);
    sh.fragmentShader=sh.fragmentShader.replace('#include <common>','#include <common>\nuniform float uT,uPulse;').replace('#include <emissivemap_fragment>','#include <emissivemap_fragment>\ntotalEmissiveRadiance+=vec3(.35,.85,1.)*pow(max(0.,sin(vUv.x*40.-uT*6.)),24.)*2.*uPulse;');};
  ws.userData.materiais=[stone,stoneL,wood,woodD,plaster,iron,ironD,bronze,copper,roofM,glass,crys,core,warm,rune,sign,paper,gauge,cond].map(m=>m.name);
  /* ---------- auxiliares ---------- */
  const refs={};ws.__oficina=refs;/* referências a objetos ficam fora do userData (o userData é copiado em JSON na exportação) */
  const comps=[];const comp=(nome,parent)=>{const g=new T.Group();g.name=nome;(parent||ws).add(g);comps.push(g);return g;};
  const add=(geo,m,x,y,z,p)=>MM.mesh(geo,m,x,y,z,p);const bb=(w,h,d,b)=>MM.bevelBox(w,h,d,b===undefined?.08:b);
  const boltG=new T.SphereGeometry(.09,5,3);const bolts=(p,pts,m)=>pts.forEach(q=>add(boltG,m||ironD,q[0],q[1],q[2],p).castShadow=false);
  const strut=(p,A,B,w,m)=>{const L=A.distanceTo(B);const b=add(new T.BoxGeometry(w,L,w),m||woodD,(A.x+B.x)/2,(A.y+B.y)/2,(A.z+B.z)/2,p);b.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),B.clone().sub(A).normalize());return b;};
  const V=(x,y,z)=>new T.Vector3(x,y,z);
  /* ================= 1. FUNDAÇÃO: plinto lavrado, canaletas de drenagem, gárgulas ================= */
  const fund=comp('Fundacao e plinto');
  add(bb(W+1.6,F,D+1.6,.18),stone,0,F/2,0,fund).userData.apoio=true;
  add(bb(W+2,.3,D+2,.08),stoneL,0,F-.05,0,fund);/* pingadeira: borda saliente que afasta a água da parede */
  [-1,1].forEach(sd=>{/* canaleta rebaixada ao longo da frente e do fundo, entre a parede e a borda */
    add(new T.BoxGeometry(W+.4,.12,.45),ironD,0,F+.02,sd*(D/2+.55),fund);[-1,1].forEach(sx=>{const sp=add(bb(.7,.5,1.6,.06),stoneL,sx*(W/2+.2),F-.35,sd*(D/2+1.4),fund);});});
  /* ================= 2. PAREDES: cantaria embaixo, enxaimel com reboco em cima, aberturas reais ================= */
  const walls=comp('Paredes e enxaimel');const frente=new T.Group();frente.name='FachadaFrontal';ws.add(frente);refs.front=frente;/* fachada separada: pode ser ocultada na inspeção */
  const DOOR=3.2,DH=7.6;/* meia largura da porta, altura até a nascença do arco (arco de raio 3,2 → topo 10,8) */
  const winRect=(u)=>({u0:u-1.8,u1:u+1.8,v0:5.2,v1:9.2});
  /* frente (+Z) */
  {const g=new T.Group();g.position.set(0,F,D/2-TW/2);frente.add(g);
    add(wallGeo(-W/2,-DOOR,0,4,[],TW+.1),stone,0,0,0,g);add(wallGeo(DOOR,W/2,0,4,[],TW+.1),stone,0,0,0,g);
    add(wallGeo(-W/2,W/2,4,E-F,[{arch:1,u0:-DOOR,u1:DOOR,v0:4,v1:DH},winRect(-9.5),winRect(9.5)],TW),plaster,0,0,0,g);}
  /* fundo (-Z): janela redonda grande atrás do condensador */
  {const g=new T.Group();g.position.set(0,F,-D/2+TW/2);g.rotation.y=Math.PI;walls.add(g);add(wallGeo(-W/2,W/2,0,4,[],TW+.1),stone,0,0,0,g);
    add(wallGeo(-W/2,W/2,4,E-F,[{circ:1,u:0,v:7.6,r:2.4},winRect(-9.5),winRect(9.5)],TW),plaster,0,0,0,g);}
  /* laterais (±X) com empena triangular sob o telhado e óculo de ventilação */
  [-1,1].forEach(sd=>{const g=new T.Group();g.position.set(sd*(W/2-TW/2),F,0);g.rotation.y=sd*Math.PI/2;walls.add(g);
    add(wallGeo(-D/2+TW,D/2-TW,0,4,[],TW+.1),stone,0,0,0,g);add(wallGeo(-D/2+TW,D/2-TW,4,E-F,[winRect(-5.6),winRect(5.6)],TW),plaster,0,0,0,g);
    const s=new T.Shape();s.moveTo(-D/2,E-F);s.lineTo(D/2,E-F);s.lineTo(0,YT-.35-F);s.lineTo(-D/2,E-F);const h=new T.Path();h.absarc(0,E-F+2.3,.9,0,Math.PI*2,true);s.holes.push(h);
    const gg=new T.ExtrudeGeometry(s,{depth:TW,bevelEnabled:false});gg.translate(0,0,-TW/2);add(gg,plaster,0,0,0,g);add(new T.TorusGeometry(.95,.18,6,16),bronze,0,E-F+2.3,TW/2+.05,g);
    [-.6,0,.6].forEach(x=>add(new T.BoxGeometry(.12,1.7,.12),ironD,x,E-F+2.3,TW/2,g));});
  /* enxaimel: pilares, frechais, travessas e mãos-francesas; ficam salientes nos dois lados da parede */
  const frame=comp('Estrutura de madeira',walls);const ext=TW+.3;
  const postsX=[-6.5,-3.9,3.9,6.5],postsZ=[-3.3,3.3];
  [-1,1].forEach(sz=>{const pf=sz>0?frente:frame;postsX.forEach(x=>{if(sz<0&&Math.abs(x)<5)return;add(new T.BoxGeometry(.7,E-F-4,ext),woodD,x,F+4+(E-F-4)/2,sz*(D/2-TW/2),pf);});
    add(new T.BoxGeometry(W+.3,.7,ext+.1),woodD,0,E-.35,sz*(D/2-TW/2),pf);add(new T.BoxGeometry(W,.45,ext),woodD,0,F+4.2,sz*(D/2-TW/2),pf);});
  [-1,1].forEach(sx=>{postsZ.forEach(z=>add(new T.BoxGeometry(ext,E-F-4,.7),woodD,sx*(W/2-TW/2),F+4+(E-F-4)/2,z,frame));
    add(new T.BoxGeometry(ext+.1,.7,D+.3),woodD,sx*(W/2-TW/2),E-.35,0,frame);add(new T.BoxGeometry(ext,.45,D),woodD,sx*(W/2-TW/2),F+4.2,0,frame);
    /* mãos-francesas em X no vão central das laterais */[[-3.3,3.3],[3.3,-3.3]].forEach(([z0,z1])=>{const b=strut(frame,V(sx*(W/2-TW/2),F+4.4,z0),V(sx*(W/2-TW/2),E-.7,z1),.45);b.scale.z=ext/.45;});});
  /* cunhais de pedra nos quatro cantos (blocos alternados) e chapas de ferro aparafusadas nas juntas */
  [[-1,-1],[1,-1],[-1,1],[1,1]].forEach(([a,b])=>{for(let k=0;k<7;k++){const big=k%2===0;const q=add(bb(big?1.9:1.4,(E-F)/7-.06,big?1.4:1.9,.1),stoneL,a*(W/2-.45),F+(k+.5)*(E-F)/7,b*(D/2-.45),walls);}});
  [-1,1].forEach(sz=>[-6.5,6.5].forEach(x=>{const z=sz*(D/2+.12);add(new T.BoxGeometry(1.4,1.4,.12),ironD,x,E-.9,z,frame);bolts(frame,[[x-.45,E-.5,z+.08*sz],[x+.45,E-.5,z+.08*sz],[x-.45,E-1.3,z+.08*sz],[x+.45,E-1.3,z+.08*sz]]);}));
  /* janelas: caixilho, montantes, peitoril de pedra e vidro */
  const win=comp('Janelas',walls);const winAt=(x,z,ry)=>{const g=new T.Group();g.position.set(x,F,z);g.rotation.y=ry;(z>D/2-2?frente:win).add(g);
    add(new T.BoxGeometry(3.6,4,.12),glass,0,7.2,0,g).castShadow=false;[[0,7.2,.15,4],[0,7.2,3.6,.15]].forEach(([u,v,w,h])=>add(new T.BoxGeometry(w,h,.25),woodD,u,v,0,g));
    add(new T.BoxGeometry(4.2,.35,.4),woodD,0,9.35,.05,g);add(new T.BoxGeometry(4.2,.35,.4),woodD,0,5.05,.05,g);[-1.95,1.95].forEach(u=>add(new T.BoxGeometry(.35,4.6,.4),woodD,u,7.2,.05,g));add(bb(4.6,.4,1.3,.08),stoneL,0,4.9,.35,g);};
  [-9.5,9.5].forEach(x=>{winAt(x,D/2-TW/2,0);winAt(x,-D/2+TW/2,Math.PI);});[-5.6,5.6].forEach(z=>{winAt(-W/2+TW/2,z,-Math.PI/2);winAt(W/2-TW/2,z,Math.PI/2);});
  {const g=new T.Group();g.position.set(0,F+7.6,-D/2+TW/2);win.add(g);add(new T.TorusGeometry(2.45,.3,8,32),bronze,0,0,-.35,g);add(new T.CircleGeometry(2.4,24),glass,0,0,0,g);for(let i=0;i<6;i++){const sp=add(new T.BoxGeometry(.14,4.8,.18),ironD,0,0,0,g);sp.rotation.z=i/6*Math.PI;}add(new T.CylinderGeometry(.45,.45,.3,12),bronze,0,0,0,g).rotation.x=Math.PI/2;}
  /* ================= 3. ENTRADA: arco de aduelas, porta dupla, dobradiças, lanternas, placa ================= */
  const ent=comp('Entrada',frente);const zf=D/2+.05;
  for(let k=0;k<=8;k++){const a=Math.PI*k/8;const v=add(bb(1.4,1.2,TW+.5,.12),stoneL,Math.cos(a)*(DOOR+.6),F+DH+Math.sin(a)*(DOOR+.6),D/2-TW/2,ent);v.rotation.z=a-Math.PI/2;}
  [-1,1].forEach(sd=>add(bb(1.2,DH,TW+.5,.12),stoneL,sd*(DOOR+.6),F+DH/2,D/2-TW/2,ent));add(bb(2*DOOR+3,.5,TW+1.4,.12),stoneL,0,F+.1,D/2-TW/2+.3,ent);/* soleira */
  {/* bandeira (vidro em leque) */const fan=add(new T.CircleGeometry(DOOR,16,0,Math.PI),glass,0,F+DH,D/2-TW/2,ent);for(let i=1;i<4;i++){const r=add(new T.BoxGeometry(.12,DOOR,.16),woodD,0,F+DH+DOOR/2,D/2-TW/2,ent);r.position.set(Math.cos(i/4*Math.PI)*DOOR/2,F+DH+Math.sin(i/4*Math.PI)*DOOR/2,D/2-TW/2);r.rotation.z=i/4*Math.PI-Math.PI/2;}}
  [-1,1].forEach(sd=>{/* folhas abertas para dentro (70°) para o interior ficar acessível */const leaf=new T.Group();leaf.name='Folha'+(sd<0?'E':'D');leaf.position.set(sd*DOOR,F+.35,D/2-TW+.1);leaf.rotation.y=-sd*1.22;ent.add(leaf);
    for(let p=0;p<5;p++)add(new T.BoxGeometry(DOOR/5-.04,DH-.4,.32),wood,-sd*(DOOR/10+p*DOOR/5),(DH-.4)/2,0,leaf);
    [1,DH-1.4].forEach(y=>{add(new T.BoxGeometry(DOOR-.2,.32,.12),ironD,-sd*DOOR/2,y,.2,leaf);add(new T.CylinderGeometry(.16,.16,.7,6),ironD,0,y,0,leaf);/* dobradiça */bolts(leaf,[0,1,2,3].map(i=>[-sd*(.4+i*.75),y,.28]));});
    add(new T.TorusGeometry(.32,.07,6,12),ironD,-sd*(DOOR-.5),DH/2-.3,.25,leaf);});
  [-1,1].forEach(sd=>{/* lanternas de parede */const g=new T.Group();g.position.set(sd*(DOOR+2.2),F+7.4,zf+.3);ent.add(g);add(new T.BoxGeometry(.25,.25,1.2),ironD,0,.9,-.5,g);add(new T.BoxGeometry(.9,.12,.9),ironD,0,.55,.2,g);
    add(new T.BoxGeometry(.62,.9,.62),warm,0,0,.2,g).castShadow=false;[[-.36,-.36],[.36,-.36],[-.36,.36],[.36,.36]].forEach(([a,b])=>add(new T.BoxGeometry(.08,1.05,.08),ironD,a,0,.2+b,g));add(new T.ConeGeometry(.6,.45,4),ironD,0,.75,.2,g).rotation.y=Math.PI/4;});
  {/* placa em bandeira, presa num braço de ferro */const g=new T.Group();g.position.set(-DOOR-4.6,F+9.6,zf);ent.add(g);add(new T.BoxGeometry(.18,.18,3.4),ironD,0,0,1.6,g);[.9,2.4].forEach(z=>add(new T.CylinderGeometry(.03,.03,.5,4),ironD,0,-.3,z,g));
    const p=add(new T.BoxGeometry(.16,1.3,3.2),woodD,0,-1.15,1.65,g);[-1,1].forEach(sd=>{const f=add(new T.PlaneGeometry(3.1,1.2),sign,sd*.09,-1.15,1.65,g);f.rotation.y=sd*Math.PI/2;});}
  /* ================= 4. TELHADO: tesouras, caibros, ripas, tabuado, chapas de junta em pé, calhas, condutores ================= */
  const roof=comp('Telhado');roof.name='Telhado';const LS=11.6/Math.cos(Math.atan(S));const ang=Math.atan(S);
  [1,-1].forEach(sd=>{const a=new T.Group();a.position.set(0,YT,0);a.rotation.order='YXZ';a.rotation.set(ang,sd>0?0:Math.PI,0);/* YXZ: inclina e depois gira — a água do fundo desce para trás */roof.add(a);
    for(let x=-13.8;x<=13.81;x+=1.97)add(new T.BoxGeometry(.4,.65,LS),woodD,x,-.33,LS/2,a);
    for(let q=0;q<7;q++)add(new T.BoxGeometry(28.4,.18,.3),wood,0,.08,.8+q*LS/7,a);add(new T.BoxGeometry(28.6,.16,LS),wood,0,.25,LS/2,a);
    add(new T.BoxGeometry(28.8,.1,LS+.25),roofM,0,.38,LS/2,a);for(let x=-13.6;x<=13.61;x+=1.6)add(new T.BoxGeometry(.1,.2,LS+.2),roofM,x,.5,LS/2,a);
    add(new T.BoxGeometry(28.8,.3,.15),copper,0,.35,LS+.15,a);/* testeira */});
  add(new T.CylinderGeometry(.42,.42,29.2,10,1,false),copper,0,YT+.45,0,roof).rotation.z=Math.PI/2;/* cumeeira */
  for(let x=-12;x<=12;x+=4)bolts(roof,[[x,YT+.85,0]],copper);
  [-6.5,6.5].forEach(x=>{/* tesouras internas (visíveis de dentro) */add(new T.BoxGeometry(.7,.75,D+.6),woodD,x,E-.1,0,roof);add(new T.BoxGeometry(.6,YT-E-.6,.6),woodD,x,(E+YT-.6)/2,0,roof);
    [-1,1].forEach(sz=>strut(roof,V(x,E+.2,sz*.3),V(x,E+(YT-E)*.55,sz*5.2),.45));add(new T.BoxGeometry(.9,.9,.12),ironD,x,E-.1,D/2+.35,roof);});
  [-1,1].forEach(sz=>{/* calhas e condutores pluviais até as gárgulas do plinto */const ye=YT-S*11.6-.35,ze=sz*(11.6+.2);const gut=add(new T.CylinderGeometry(.34,.34,28.6,10,1,true,0,Math.PI),copper,0,ye,ze,roof);gut.rotation.z=Math.PI/2;gut.rotation.y=sz>0?0:Math.PI;
    [-1,1].forEach(sx=>{const x=sx*(W/2+.2);roof.add(MM.tube([V(x+sx*.6,ye,ze),V(x,ye-.6,ze-sz*.3),V(x,F+1.2,sz*(D/2+1.2)),V(x,F+.1,sz*(D/2+1.4))],.18,copper,10,6));
      for(let y=F+2;y<ye-1;y+=3)add(new T.BoxGeometry(.5,.12,.3),ironD,x,y,sz*(D/2+.95),roof);});});
  /* chaminé de pedra da forja */
  const ch=add(bb(2.2,YT+1.8-F,2.2,.12),stoneL,-9,F+(YT+1.8-F)/2,-6.4,roof);add(bb(2.8,.4,2.8,.08),stoneL,-9,YT+1.9,-6.4,roof);add(new T.CylinderGeometry(1.25,1.25,.35,10),copper,-9,YT-1.9,-6.4,roof);
  /* para-raios na cumeeira (2 extremos + 1 central ligado ao condensador) */
  const rods=[];[-12.4,0,12.4].forEach((x,i)=>{const h=i===1?3.2:4.2;add(new T.CylinderGeometry(.08,.18,h,6),ironD,x,YT+.8+h/2,0,roof);add(new T.SphereGeometry(.3,10,8),copper,x,YT+.8+h,0,roof);
    [.35,.6].forEach(f=>add(new T.TorusGeometry(.38,.1,5,12),copper,x,YT+.8+h*f,0,roof).rotation.x=Math.PI/2);add(new T.CylinderGeometry(.35,.45,.5,8),ironD,x,YT+.75,0,roof);rods.push(V(x,YT+.8+h,0));});
  [-1,1].forEach(sx=>{/* condutor de descida: do para-raios, pela empena, até a estaca no chão */const x=sx*12.4;const cnd=MM.tube([V(x,YT+.9,0),V(sx*13.25,YT-.4,-1.5),V(sx*13.25,E-1,-D/2+.5),V(sx*13.25,F+.4,-D/2-.3),V(sx*13.6,F-.1,-D/2-.8)],.13,cond,40,5);roof.add(cnd);
    for(let k=0;k<4;k++){const y=F+1.5+k*2.6;add(new T.CylinderGeometry(.14,.14,.4,6),copper,sx*13.4,y,-D/2+.45,roof).rotation.z=Math.PI/2;}});
  {/* bucha de passagem do telhado: condutor do para-raios central até o topo do condensador */const zb=-4.5,yb=YT-S*4.5+.45;add(new T.CylinderGeometry(.5,.6,.6,10),copper,0,yb,zb,roof);
    const c=MM.tube([rods[1].clone().setY(YT+1.2),V(0,YT+.7,-1.2),V(0,yb+.3,zb),V(0,yb-1.4,zb)],.12,cond,24,5);roof.add(c);}
  /* ================= 5. INTERIOR ================= */
  const floor=comp('Piso de tabuado');add(new T.BoxGeometry(W-2*TW,.2,D-2*TW),wood,0,F+.1,0,floor).receiveShadow=true;
  for(let z=-D/2+TW+1;z<D/2-TW;z+=2.2)add(new T.BoxGeometry(W-2*TW,.04,.05),woodD,0,F+.21,z,floor).castShadow=false;
  const FL=F+.2;/* topo do tabuado */
  /* --- 5a. bancadas (frente esquerda e parede esquerda) --- */
  const banc=comp('Bancadas');const gearS=gearGeo(.45,10,.12),gearM=gearGeo(.75,14,.16);
  const bench=(x,z,ry,len)=>{const g=new T.Group();g.position.set(x,FL,z);g.rotation.y=ry;banc.add(g);add(bb(len,.35,2.4,.06),wood,0,3.1,0,g);
    [[-1,-1],[1,-1],[-1,1],[1,1]].forEach(([a,b])=>add(new T.BoxGeometry(.3,2.95,.3),woodD,a*(len/2-.3),1.47,b*.95,g));add(new T.BoxGeometry(len-.6,.15,2),woodD,0,.6,0,g);/* travessa */
    for(let k=0;k<3;k++){const dx=-len/2+1.1+k*1.3;add(new T.BoxGeometry(1.15,.5,.1),wood,dx,2.6,1.2,g);add(new T.SphereGeometry(.07,5,3),bronze,dx,2.6,1.27,g);add(new T.BoxGeometry(1.15,.5,.1),wood,dx,2.05,1.2,g);add(new T.SphereGeometry(.07,5,3),bronze,dx,2.05,1.27,g);}/* gavetas */
    add(new T.BoxGeometry(1.25,1.15,2.1),woodD,-len/2+2.4-.05,2.3,0,g).visible=true;/* gaveteiro */
    /* painel de ferramentas na parede: martelo, chave, serrote, alicate */add(new T.BoxGeometry(len-.4,2.6,.15),woodD,0,4.7,-1.2,g);
    [[-len/2+1,'m'],[-len/2+2.2,'c'],[-len/2+3.4,'s'],[-len/2+4.6,'m'],[-len/2+5.6,'c']].forEach(([u,k])=>{if(u>len/2-.6)return;if(k==='m'){add(new T.BoxGeometry(.1,1.2,.08),woodD,u,4.6,-1.08,g);add(new T.BoxGeometry(.5,.22,.18),iron,u,5.2,-1.06,g);}
      else if(k==='c'){add(new T.BoxGeometry(.12,1.1,.06),iron,u,4.6,-1.08,g);add(new T.TorusGeometry(.18,.06,4,8,4.6),iron,u,5.2,-1.06,g);}else{add(new T.BoxGeometry(.7,.9,.03),iron,u,4.6,-1.09,g);add(new T.BoxGeometry(.18,.5,.12),woodD,u+.38,4.3,-1.07,g);}});
    /* sobre o tampo: morsa, engrenagens, parafusos, cristais, folha de projeto, lupa com lâmpada */
    add(new T.BoxGeometry(.9,.5,.6),ironD,len/2-1,3.55,.55,g);add(new T.BoxGeometry(.2,.2,1.1),iron,len/2-1,3.6,.95,g);
    [[-1.6,.2,gearM],[-.9,-.3,gearS],[-.4,.35,gearS],[.6,-.1,gearM]].forEach(([u,w,geo],i)=>{if(u>len/2-1.5)return;const k=add(geo,i%2?bronze:iron,u,3.33,w,g);k.rotation.x=-Math.PI/2;k.rotation.z=rnd()*3;});
    for(let i=0;i<10;i++)add(boltG,ironD,-1+rnd()*2,3.3,rnd()*.8-.4,g);
    [[1.2,.3],[1.5,.1]].forEach(([u,w])=>{const c=add(MM.crystalGeo(.12,.5,1),crys,u,3.5,w,g);c.rotation.z=.4;});
    const sh=add(new T.PlaneGeometry(1.6,1.1),paper,-.2,3.29,-.5,g);sh.rotation.x=-Math.PI/2;sh.rotation.z=.15;
    const lamp=new T.Group();lamp.position.set(-len/2+.8,3.28,-.8);g.add(lamp);add(new T.CylinderGeometry(.3,.35,.15,10),ironD,0,0,0,lamp);strut(lamp,V(0,0,0),V(.4,1.6,.4),.08,iron);strut(lamp,V(.4,1.6,.4),V(1.1,1.4,.9),.08,iron);
    add(new T.TorusGeometry(.32,.05,5,14),bronze,1.1,1.3,.9,lamp).rotation.x=Math.PI/2;add(new T.SphereGeometry(.13,8,6),warm,1.1,1.45,.9,lamp);
    const rot=Math.abs(Math.sin(ry))>.5;MM.box(ws,x,FL+1.8,z,rot?2.6:len,3.6,rot?len:2.6);};
  bench(-W/2+TW+1.4,1.3,Math.PI/2,7.2);bench(-7.4,D/2-TW-1.4,Math.PI,6.6);
  {/* banquinho */const g=new T.Group();g.position.set(-8.6,FL,-.8);banc.add(g);add(new T.CylinderGeometry(.75,.75,.18,10),wood,0,2.1,0,g);[0,1,2].forEach(i=>{const a=i/3*Math.PI*2;strut(g,V(Math.cos(a)*.55,2,Math.sin(a)*.55),V(Math.cos(a)*.75,0,Math.sin(a)*.75),.12);});}
  /* --- 5b. laboratório atmosférico (lado direito) --- */
  const lab=comp('Laboratório atmosférico');
  {/* bobina de alta tensão: base, secundário enrolado, toroide no topo */const g=new T.Group();g.position.set(9.6,FL,4.2);lab.add(g);add(bb(2.4,.9,2.4,.1),ironD,0,.45,0,g);add(new T.CylinderGeometry(.55,.55,4.4,14,1,true),woodD,0,3.1,0,g);
    for(let i=0;i<16;i++)add(new T.TorusGeometry(.6,.05,4,16),copper,0,1.2+i*.24,0,g).rotation.x=Math.PI/2;add(new T.TorusGeometry(1.05,.38,10,20),bronze,0,5.6,0,g).rotation.x=Math.PI/2;add(new T.SphereGeometry(.3,10,8),core,0,5.95,0,g);
    [0,1,2].forEach(i=>{const a=i/3*Math.PI*2+.5;strut(g,V(Math.cos(a)*1.05,.9,Math.sin(a)*1.05),V(Math.cos(a)*.6,3,Math.sin(a)*.6),.12,iron);});MM.box(ws,9.6,FL+3,4.2,2.6,6,2.6);refs.bobinaLab=g;}
  {/* gerador: carcaça, volante animado, correia, base */const g=new T.Group();g.position.set(9,FL,-1.4);lab.add(g);add(bb(3.4,.6,2.2,.08),ironD,0,.3,0,g);const hs=add(new T.CylinderGeometry(.95,.95,2.4,16),iron,-.3,1.55,0,g);hs.rotation.z=Math.PI/2;
    for(let i=0;i<5;i++)add(new T.TorusGeometry(.97,.06,4,18),ironD,-1.3+i*.5,1.55,0,g).rotation.y=Math.PI/2;
    const fw=new T.Group();fw.name='VolanteGerador';fw.position.set(1.35,1.55,0);fw.userData.animated=true;g.add(fw);add(new T.TorusGeometry(.9,.14,6,18),bronze,0,0,0,fw).rotation.y=Math.PI/2;for(let i=0;i<5;i++){const sp=add(new T.BoxGeometry(.08,1.7,.08),bronze,0,0,0,fw);sp.rotation.x=i/5*Math.PI;}
    add(new T.CylinderGeometry(.18,.18,.6,8),ironD,1.35,1.55,0,g).rotation.z=Math.PI/2;MM.box(ws,9,FL+1.3,-1.4,3.6,2.6,2.4);refs.volante=fw;}
  {/* painel de controle na parede direita: gabinete, mostradores, alavancas, botões, cabos */const g=new T.Group();g.position.set(W/2-TW-.6,FL,-3.6);g.rotation.y=-Math.PI/2;lab.add(g);add(bb(4.4,5.2,1.1,.08),ironD,0,2.6,0,g);add(new T.BoxGeometry(4.6,.25,1.3),bronze,0,5.3,0,g);
    [[-1.2,4],[0,4],[1.2,4]].forEach(([u,v])=>{add(new T.CylinderGeometry(.5,.5,.12,16),bronze,u,v,.56,g).rotation.x=Math.PI/2;add(new T.CircleGeometry(.43,16),gauge,u,v,.63,g);});
    for(let i=0;i<4;i++){add(new T.BoxGeometry(.18,.5,.18),ironD,-1.4+i*.95,2.7,.6,g);const lv=add(new T.CylinderGeometry(.05,.05,.9,6),iron,-1.4+i*.95,3,.75,g);lv.rotation.x=.5-i*.3;add(new T.SphereGeometry(.12,6,4),i%2?warm:core,-1.4+i*.95,3.4,.95-i*.08,g);}
    for(let i=0;i<6;i++)add(new T.CylinderGeometry(.1,.1,.1,8),i%3?warm:core,-1.5+i*.6,1.9,.56,g).rotation.x=Math.PI/2;MM.box(ws,W/2-TW-.6,FL+2.6,-3.6,1.2,5.2,4.4);}
  /* tubulação e calha de cabos: do painel e do gerador até o condensador */
  lab.add(MM.tube([V(W/2-TW-1.2,FL+4.6,-3.6),V(6,FL+5.4,-4.4),V(3.4,FL+4.6,-4.8)],.2,copper,16,6));lab.add(MM.tube([V(7.4,FL+.3,-1.4),V(5.2,FL+.3,-2.4),V(3.6,FL+.6,-3.8)],.16,cond,16,5));
  add(new T.BoxGeometry(4.4,.12,.7),ironD,6.2,FL+.08,-2.6,lab).rotation.y=.35;
  /* --- 5c. depósito (fundo esquerdo): estantes, caixotes, frascos, carretéis, barris --- */
  const dep=comp('Depósito');const crateG=bb(1.5,1.1,1.1,.05),jarG=new T.CylinderGeometry(.22,.22,.6,8),spoolG=new T.TorusGeometry(.32,.16,5,10),spoolCore=new T.CylinderGeometry(.18,.18,.4,8);
  const shelf=(x,z,ry,len)=>{const g=new T.Group();g.position.set(x,FL,z);g.rotation.y=ry;dep.add(g);[-1,1].forEach(a=>[-1,1].forEach(b=>add(new T.BoxGeometry(.22,6.6,.22),woodD,a*(len/2-.12),3.3,b*.55,g)));
    for(let k=0;k<4;k++){const y=.5+k*1.75;add(new T.BoxGeometry(len,.14,1.3),wood,0,y,0,g);for(let i=0;i<Math.floor(len/1.1);i++){const u=-len/2+.6+i*1.05;const r=rnd();
      if(k===0&&r<.7){add(crateG,wood,u,y+.62,0,g);}else if(r<.4){add(jarG,glass,u,y+.37,(rnd()-.5)*.4,g);add(new T.CylinderGeometry(.16,.16,.12,6),woodD,u,y+.73,0,g);}
      else if(r<.65){const sp=add(spoolG,copper,u,y+.4,0,g);sp.rotation.y=Math.PI/2;add(spoolCore,woodD,u,y+.4,0,g).rotation.z=Math.PI/2;}else if(r<.85){const k2=add(gearS,iron,u,y+.12,0,g);k2.rotation.x=-Math.PI/2;}else{add(new T.BoxGeometry(.35,.9,.7),woodD,u,y+.52,0,g);add(new T.BoxGeometry(.3,.85,.7),bronze,u+.32,y+.5,0,g);}}}
    MM.box(ws,x,FL+3.3,z,ry?1.4:len,6.6,ry?len:1.4);};
  shelf(-7.8,-D/2+TW+.9,0,6.4);shelf(-W/2+TW+.9,-5.4,Math.PI/2,4.2);
  [[-5.2,-6.4],[-6.6,-6]].forEach(([x,z],i)=>{/* barris com aros */add(new T.CylinderGeometry(.85,.75,1.9,12),woodD,x,FL+.95,z,dep);[.3,1.6].forEach(y=>add(new T.TorusGeometry(.84,.06,4,14),ironD,x,FL+y,z,dep).rotation.x=Math.PI/2);});
  [[-8.4,-3.8],[-7,-4],[-7.7,-3.9]].forEach(([x,z],i)=>add(crateG,wood,x,FL+.55+(i===2?1.1:0),z,dep).rotation.y=rnd()*.4);MM.box(ws,-7.7,FL+1.1,-3.9,3,2.2,1.4);
  /* --- 5d. canto do inventor (fundo direito): prancheta, banco, luminária, protótipos, notas; lugar do NPC --- */
  const inv=comp('Canto do inventor');
  {const g=new T.Group();g.position.set(7.6,FL,-7.4);inv.add(g);[[-1.3,-.6],[1.3,-.6],[-1.3,.6],[1.3,.6]].forEach(([a,b])=>add(new T.BoxGeometry(.2,3.2,.2),woodD,a,1.6,b,g));
    const top=add(bb(3.2,.18,2.2,.04),wood,0,3.4,.1,g);top.rotation.x=.42;const bp=add(new T.PlaneGeometry(2.6,1.7),paper,0,3.52,.08,g);bp.rotation.x=-Math.PI/2+.42;add(new T.BoxGeometry(3,.08,.12),bronze,0,2.98,1.05,g);/* régua */
    MM.box(ws,7.6,FL+1.8,-7.4,3.4,3.6,2.4);}
  {/* mesa lateral com protótipos: planetário mecânico e máquina voadora; luminária própria */const g=new T.Group();g.position.set(11.1,FL,-7.6);inv.add(g);add(bb(1.6,.2,3,.04),wood,0,3,0,g);[[-.6,-1.3],[.6,-1.3],[-.6,1.3],[.6,1.3]].forEach(([a,b])=>add(new T.BoxGeometry(.18,2.9,.18),woodD,a,1.45,b,g));
    const orr=new T.Group();orr.name='Planetario';orr.position.set(0,3.1,-.7);orr.userData.animated=true;g.add(orr);add(new T.CylinderGeometry(.25,.32,.2,10),bronze,0,.1,0,orr);add(new T.SphereGeometry(.22,10,8),warm,0,.7,0,orr);
    [.5,.8].forEach((r,i)=>{add(new T.TorusGeometry(r,.025,4,24),bronze,0,.7,0,orr).rotation.x=Math.PI/2+.2*i;add(new T.SphereGeometry(.08+.04*i,8,6),bronze,r,.7,0,orr);});
    const fly=new T.Group();fly.position.set(0,3.4,.6);g.add(fly);add(new T.CylinderGeometry(.18,.12,1,8),copper,0,0,0,fly).rotation.z=Math.PI/2;[-1,1].forEach(sd=>{const wg=add(new T.BoxGeometry(.04,.02,1),paper,0,.1,sd*.5,fly);});add(new T.BoxGeometry(.04,.5,.04),ironD,0,-.25,0,fly);
    const lamp=new T.Group();lamp.position.set(.4,3.1,1.1);g.add(lamp);strut(lamp,V(0,0,0),V(0,1.6,0),.07,iron);add(new T.ConeGeometry(.4,.4,10,1,true),bronze,0,1.55,0,lamp);add(new T.SphereGeometry(.14,8,6),warm,0,1.4,0,lamp);MM.box(ws,11.1,FL+1.6,-7.6,1.8,3.2,3.2);refs.orrery=orr;}
  {/* banco e notas presas na parede do fundo */const g=new T.Group();g.position.set(7.6,FL,-5.6);inv.add(g);add(new T.CylinderGeometry(.6,.6,.16,10),wood,0,2.3,0,g);add(new T.CylinderGeometry(.08,.08,2.2,6),iron,0,1.15,0,g);add(new T.CylinderGeometry(.6,.7,.12,10),ironD,0,.06,0,g);
    for(let i=0;i<6;i++){const n=add(new T.PlaneGeometry(.7+rnd()*.3,.5+rnd()*.3),i%3?paper:sign,3.1+i*.72,FL+6.6+(i%2)*.8,-D/2+TW+.02,inv);n.rotation.z=(rnd()-.5)*.2;}}
  {const npc=new T.Object3D();npc.name='PontoNPC';npc.position.set(9.4,FL,-4.8);npc.userData.npc='STORM.NPC.02';npc.userData.notas='lugar reservado para o inventor (NPC não implementado nesta etapa)';inv.add(npc);ws.userData.pontoNPC=[9.4,FL,-4.8];}
  /* ================= 6. CONDENSADOR ATMOSFÉRICO ================= */
  const cd=comp('Condensador Atmosférico');cd.position.set(0,FL,-4.6);const animC=[];
  /* base: plinto octogonal de pedra, degrau de bronze com faixa de runas, rebites */
  {const b=add(new T.CylinderGeometry(3.5,3.7,.8,8),stoneL,0,.4,0,cd);b.rotation.y=Math.PI/8;const st=add(new T.CylinderGeometry(3,3.2,.5,8),bronze,0,1.05,0,cd);st.rotation.y=Math.PI/8;
    const rb=add(new T.CylinderGeometry(3.21,3.21,.34,8,1,true),rune,0,1.05,0,cd);rb.rotation.y=Math.PI/8;for(let i=0;i<16;i++){const a=i/16*Math.PI*2;add(boltG,ironD,Math.cos(a)*3.1,1.33,Math.sin(a)*3.1,cd);}}
  /* carcaça inferior de ferro, flanges e respiros */
  add(new T.CylinderGeometry(2.1,2.3,1.6,20),iron,0,2.1,0,cd);add(new T.TorusGeometry(2.15,.14,6,24),bronze,0,2.9,0,cd).rotation.x=Math.PI/2;for(let i=0;i<8;i++){const a=i/8*Math.PI*2+.2;const v=add(new T.BoxGeometry(.5,.9,.12),ironD,Math.cos(a)*2.25,2.05,Math.sin(a)*2.25,cd);v.rotation.y=-a+Math.PI/2;}
  /* câmara de contenção: cilindro de vidro com quadro de ferro e cintas de cobre */
  add(new T.CylinderGeometry(1.75,1.75,5,24,1,true),glass,0,5.5,0,cd).castShadow=false;for(let i=0;i<4;i++){const a=i/4*Math.PI*2+Math.PI/4;add(new T.BoxGeometry(.22,5.2,.22),ironD,Math.cos(a)*1.82,5.5,Math.sin(a)*1.82,cd);}
  [3.2,7.8].forEach(y=>add(new T.TorusGeometry(1.84,.16,6,24),copper,0,y,0,cd).rotation.x=Math.PI/2);
  /* núcleo cristalino */{const cg=MM.crystalGeo(.85,4,1.3);const c=add(cg,crys,0,3.6,0,cd);[0,1,2].forEach(i=>{const a=i/3*Math.PI*2;const s=add(MM.crystalGeo(.35,1.8,1.2),crys,Math.cos(a)*.75,3.3,Math.sin(a)*.75,cd);s.rotation.set(Math.cos(a)*.35,0,-Math.sin(a)*.35);});
    const ci=add(new T.OctahedronGeometry(.42,0),core,0,5.5,0,cd);ci.scale.y=2.2;ci.castShadow=false;}
  /* anéis de contenção (animados): três aros inclinados com nós de bronze e faixa de runas no maior */
  [[2.55,.14,.35],[2.9,.12,-.55],[3.25,.16,.15]].forEach(([R,t,tilt],i)=>{const g=new T.Group();g.name='AnelContencao'+i;g.position.set(0,5.5,0);g.rotation.set(tilt,0,i*.6);g.userData.animated=true;cd.add(g);
    const rm=i===2?bronze:iron;add(new T.TorusGeometry(R,t,8,48),rm,0,0,0,g).rotation.x=Math.PI/2;if(i===2){const rb=add(new T.TorusGeometry(R,t*1.05,4,48),rune,0,0,0,g);rb.rotation.x=Math.PI/2;rb.scale.z=.45;}
    for(let n=0;n<6;n++){const a=n/6*Math.PI*2;add(new T.SphereGeometry(t*1.5,8,6),rm,Math.cos(a)*R,0,Math.sin(a)*R,g);}animC.push(g);});
  /* colunas de bobinas laterais e pontes de cobre até o topo */
  [-1,1].forEach(sd=>{const x=sd*2.95;add(new T.CylinderGeometry(.32,.32,6.2,10),ironD,x,4.6,0,cd);for(let i=0;i<14;i++)add(new T.TorusGeometry(.42,.07,4,12),copper,x,2.2+i*.36,0,cd).rotation.x=Math.PI/2;
    add(new T.SphereGeometry(.42,10,8),bronze,x,7.9,0,cd);cd.add(MM.tube([V(x,7.9,0),V(x*.75,8.9,0),V(x*.3,9.1,0)],.12,cond,14,5));
    /* escoras de bronze do plinto ao anel superior */strut(cd,V(x*1.05,1.3,sd*1.6),V(x*.62,8.3,sd*.9),.22,bronze);strut(cd,V(x*1.05,1.3,-sd*1.6),V(x*.62,8.3,-sd*.9),.22,bronze);});
  /* topo: tampa abobadada com aletas, faíscador (dois eletrodos) e colar do condutor do telhado */
  add(new T.CylinderGeometry(1.95,2.05,.5,20),bronze,0,8.3,0,cd);add(new T.SphereGeometry(1.7,20,8,0,Math.PI*2,0,Math.PI/2),copper,0,8.55,0,cd);for(let i=0;i<12;i++){const a=i/12*Math.PI*2;const f=add(new T.BoxGeometry(.08,.9,.6),bronze,Math.cos(a)*1.55,8.9,Math.sin(a)*1.55,cd);f.rotation.y=-a;}
  add(new T.CylinderGeometry(.22,.3,1.1,8),ironD,0,10.6,0,cd);[-1,1].forEach(sd=>{strut(cd,V(sd*.2,10.9,0),V(sd*.75,11.6,0),.1,iron);add(new T.SphereGeometry(.18,8,6),bronze,sd*.82,11.7,0,cd);});
  refs.faiscador=[V(-.82,11.7,0),V(.82,11.7,0)];refs.cd=cd;/* coordenadas do condensador; convertidas depois */
  /* tubulações de entrada com registros (volantes) e manômetro com ponteiro animado */
  [[-1,1.6],[1,1.6],[0,-1]].forEach(([sx,sz],i)=>{const p0=V(sx*1.9,2,sz*1.2),p1=V(sx*3.2,1.4,sz*2.4),p2=V(sx*3.4,.4,sz*3.1);cd.add(MM.tube([p0,p1,p2],.2,copper,12,6));const w=add(new T.TorusGeometry(.32,.06,4,12),iron,p1.x,p1.y+.35,p1.z,cd);w.rotation.x=Math.PI/2;});
  {const g=new T.Group();g.position.set(0,2.4,2.2);cd.add(g);add(new T.CylinderGeometry(.55,.55,.2,16),bronze,0,0,0,g).rotation.x=Math.PI/2;add(new T.CircleGeometry(.48,16),gauge,0,0,.11,g);
    const nd=new T.Group();nd.name='PonteiroManometro';nd.position.set(0,0,.13);nd.userData.animated=true;g.add(nd);add(new T.BoxGeometry(.04,.4,.02),ironD,0,.17,0,nd);animC.push(nd);}
  /* mecanismos móveis: par de engrenagens e pistões */
  const gearA=new T.Group();gearA.name='EngrenagensCondensador';gearA.position.set(-2.25,2.2,1.1);gearA.rotation.y=-.5;gearA.userData.animated=true;cd.add(gearA);const gg1=add(gearM,bronze,0,0,0,gearA),gg2=add(gearS,bronze,1.05,.55,0,gearA);
  const pist=[];const pg=new T.Group();pg.name='Pistoes';pg.position.set(0,1.4,-2.1);pg.userData.animated=true;cd.add(pg);pist.push(pg);[-1,1].forEach(sd=>{add(new T.CylinderGeometry(.22,.22,1.3,8),iron,sd*1.2,.65,0,pg);add(new T.CylinderGeometry(.32,.32,.25,8),iron,sd*1.2,1.3,0,pg);
    add(new T.CylinderGeometry(.36,.36,1,10),ironD,sd*1.2,1.8,-2.1,cd);});
  MM.box(ws,0,FL+2,-4.6,7.2,4,7.2);MM.box(ws,0,FL+6,-4.6,4,8,4);
  /* ================= 7. COLISORES DO EDIFÍCIO ================= */
  MM.box(ws,0,F/2,0,W+1.6,F,D+1.6);/* plinto (topo = piso) */
  MM.box(ws,-(W/2+DOOR)/2,F+5.5,D/2-TW/2,W/2-DOOR,11,TW);MM.box(ws,(W/2+DOOR)/2,F+5.5,D/2-TW/2,W/2-DOOR,11,TW);MM.box(ws,0,F+5.5+DH,D/2-TW/2,2*DOOR,11-DH,TW);/* frente com vão da porta */
  MM.box(ws,0,F+5.5,-D/2+TW/2,W,11,TW);MM.box(ws,-W/2+TW/2,F+5.5,0,TW,11,D);MM.box(ws,W/2-TW/2,F+5.5,0,TW,11,D);
  /* ================= 8. animação, luz e registro dos componentes ================= */
  const luz=new T.PointLight(MM.C('#ffb468'),0,34,2);luz.position.set(0,E-2.5,1);ws.add(luz);refs.luz=luz;
  ws.userData.update=function(dt,t,on,L,cam){animC.forEach((g,i)=>{if(g.name.startsWith('Anel'))g.rotateOnAxis(new T.Vector3(0,1,0),dt*(on?.5:.15)*(i%2?-1:1)*(1+i*.3));});
    gg1.rotation.z+=dt*.8;gg2.rotation.z-=dt*1.4;pist.forEach((p,i)=>p.position.y=1.4+Math.max(0,Math.sin(t*2.2+i*Math.PI))*.35);const nd=animC[animC.length-1];nd.rotation.z=-.8+Math.sin(t*.9)*.4+(on?.6:0);
    if(refs.volante)refs.volante.rotation.x+=dt*(on?3:.8);if(refs.orrery)refs.orrery.rotation.y+=dt*.3;
    const near=cam?cam.position.distanceTo(ws.position)<150:true;luz.intensity=(L&&L.full!==false&&!L.neutral&&near)?1.6:0;cond.userData.u.uT.value=t;cond.userData.u.uPulse.value=on?1:0;};
  refs.comps=comps;refs.roof=roof;return{roof,comps,cd,stone};};
/* registra caixas dos componentes (em mundo) depois que a oficina foi assentada no terreno */
I.workshopComponents=function(ws){ws.updateMatrixWorld(true);const R=ws.__oficina;const out=[];R.comps.forEach(g=>{const b=new T.Box3().setFromObject(g);if(b.isEmpty())return;out.push({nome:g.name,box:[b.min.x,b.min.y,b.min.z,b.max.x,b.max.y,b.max.z].map(v=>+v.toFixed(2))});});
  ws.userData.componentes=out;R.faiscaW=R.faiscador.map(p=>R.cd.localToWorld(p.clone()));R.faiscaLab=R.bobinaLab.localToWorld(new T.Vector3(0,5.95,0));
  const rb=R.roof.localToWorld(new T.Vector3(0,YT+1.2,-4.5));R.condutorFim=ws.localToWorld(new T.Vector3(0,YT-S*4.5+.45-1.4,-4.5));return out;};
})();
