/* Ilha das Tempestades · Architecture · Caverna do Trovão (Mapa V1)
   Pórtico de mineração em cantaria construído contra o paredão: fachada com arco de aduelas de verdade, fecho com o emblema
   da tempestade (raio de cobre e cristal), contrafortes em talude, cornija, lanternas e rochas que fundem a obra no penhasco.
   Atrás do arco, abóbada de alvenaria que recebe o túnel natural (o terreno é vazado na boca).
   Túnel: piso contínuo, trilhos com dormentes, quadros de escoramento com lanternas. Câmara com a mina STORM.MINE.02 e a
   bobina antiga STORM.EQUIP.01 (agora detalhada). O túnel e a câmara são renderizados pelo lado de dentro (BackSide).
   Posição, traçado do túnel, piso caminhável, câmara, ids e marcadores: os mesmos de antes. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
function wallG(u0,u1,v0,v1,holes,t){const s=new T.Shape();s.moveTo(u0,v0);s.lineTo(u1,v0);s.lineTo(u1,v1);s.lineTo(u0,v1);s.lineTo(u0,v0);
  (holes||[]).forEach(h=>{const p=new T.Path();p.moveTo(h.u0,h.v0);p.lineTo(h.u0,h.v1);p.absarc((h.u0+h.u1)/2,h.v1,(h.u1-h.u0)/2,Math.PI,0,true);p.lineTo(h.u1,h.v0);p.lineTo(h.u0,h.v0);s.holes.push(p);});
  const g=new T.ExtrudeGeometry(s,{depth:t,bevelEnabled:false,curveSegments:16});g.translate(0,0,-t/2);return g;}
/* aduela: setor de coroa circular entre a0 e a1 (centro em (0,cy)), extrudado */
function voussoirG(ri,ro,a0,a1,cy,t){const s=new T.Shape();const P=(r,a)=>[Math.cos(a)*r,cy+Math.sin(a)*r];const n=4;
  s.moveTo(...P(ri,a0));for(let i=0;i<=n;i++)s.lineTo(...P(ro,a0+(a1-a0)*i/n));for(let i=n;i>=0;i--)s.lineTo(...P(ri,a0+(a1-a0)*i/n));
  const g=new T.ExtrudeGeometry(s,{depth:t,bevelEnabled:true,bevelSize:.08,bevelThickness:.08,bevelSegments:1});g.translate(0,0,-t/2);return g;}
/* abóbada: perfil em arco (ombreiras + semicírculo) com espessura, extrudado ao longo de Z; vê-se pelo lado de dentro */
function vaultG(r,spring,th,len){const s=new T.Shape();const ro=r+th;s.moveTo(-ro,-1);s.lineTo(-ro,spring);s.absarc(0,spring,ro,Math.PI,0,true);s.lineTo(ro,-1);s.lineTo(r,-1);s.lineTo(r,spring);s.absarc(0,spring,r,0,Math.PI,false);s.lineTo(-r,-1);s.lineTo(-ro,-1);
  const g=new T.ExtrudeGeometry(s,{depth:len,bevelEnabled:false,curveSegments:16});g.translate(0,0,-len);return g;}
function boltG(){const s=new T.Shape();[[.35,1.6],[-.45,.1],[.05,.1],[-.35,-1.6],[.55,-.05],[.05,-.05],[.35,1.6]].forEach((p,i)=>i?s.lineTo(p[0],p[1]):s.moveTo(p[0],p[1]));return new T.ExtrudeGeometry(s,{depth:.25,bevelEnabled:false});}
I.buildCave=function(ctx){const M=ctx.mat,K=I.houseMats(ctx),b=I.poi.caverna.boca;const out=[];const y=26;const BB=MM.bevelBox;const r=MM.rng(31);
  /* ================= PÓRTICO (frente = +Z local; fachada de z=-1 a z=4, ou seja, mundo −104 a −99) ================= */
  const arch=MM.obj('STORM.ARCH.CAVE.MOUTH','Boca da Caverna do Trovão','Architecture',{notes:'Pórtico de mineração 34 × 22 studs encostado no paredão. Vão em arco 18 × 17 studs (ombreiras de 8 + meia-volta de raio 9). Abóbada de alvenaria até o túnel natural.'});arch.position.set(b.x,y,b.z+1);
  const add=(geo,m,x,yy,z,p)=>MM.mesh(geo,m,x,yy,z,p||arch);
  const FZ=1.5,FT=5,FW=17,FH=22,R0=9,SP=8;/* centro da espessura, espessura, meia largura, altura, raio do vão, nascença */
  add(wallG(-FW,FW,-1.2,FH,[{u0:-R0,u1:R0,v0:-1.2,v1:SP}],FT),K.cant,0,0,FZ);
  /* aduelas (15) + fecho, salientes 0,35 da fachada; ombreiras de pedra lavrada em fiadas alternadas */
  const NV=15,ri=R0,ro=R0+2.1;for(let i=0;i<NV;i++){if(i===7)continue;const a0=Math.PI-(i/NV)*Math.PI,a1=Math.PI-((i+1)/NV)*Math.PI;add(voussoirG(ri,ro,a1+.012,a0-.012,SP,FT+.7),i%2?K.lav:K.cant,0,0,FZ+.35);}
  {const a0=Math.PI*8/15,a1=Math.PI*7/15;add(voussoirG(ri-.2,ro+.9,a1+.012,a0-.012,SP,FT+1.3),K.lav,0,0,FZ+.65);/* fecho */
    const em=new T.Group();em.position.set(0,SP+ro+.15,FZ+FT/2+1.35);arch.add(em);/* emblema da tempestade: aro de cobre, raio e cristal */
    add(new T.TorusGeometry(1.25,.18,8,24),K.copper,0,0,0,em);add(new T.CylinderGeometry(1.1,1.1,.12,20),K.iron,0,0,-.08,em).rotation.x=Math.PI/2;const bo=add(boltG(),K.copper,0,0,.0,em);bo.scale.set(.6,.6,1);
    const cr=add(MM.crystalGeo(.32,.9,.7),M.cristal,0,1.45,-.1,em);cr.castShadow=false;}
  [-1,1].forEach(s=>{for(let k=0;k<5;k++){const lng=k%2===0;const a=lng?2.4:1.6,h=1.6;add(BB(a,h-.06,FT+.5,.08),K.lav,s*(R0+a/2-.1),-1.2+h/2+k*1.84,FZ+.25);}
    add(BB(3.2,.7,FT+.9,.1),K.lav,s*(R0+1.3),SP+.1,FZ+.45);/* imposta */});
  /* embasamento, cornija, frontão escalonado e pingadeira */
  add(BB(2*FW+1,1.6,FT+1,.12),K.lav,0,-1.2+.8,FZ+.5).userData.apoio=true;
  add(BB(2*FW+1.2,.8,FT+1.2,.1),K.lav,0,FH-.2,FZ+.2);add(BB(2*FW-4,1.6,FT,.1),K.cant,0,FH+1,FZ-.4);add(BB(2*FW-3.4,.45,FT+.5,.08),K.lav,0,FH+1.95,FZ-.3);
  add(BB(12,2.2,FT-.6,.1),K.cant,0,FH+2.9,FZ-.6);add(BB(12.6,.4,FT,.08),K.lav,0,FH+4.1,FZ-.6);
  add(BB(2*FW,.5,.9,.08),K.lav,0,13.5,FZ+FT/2+.25);/* fiada saliente na altura do fecho */
  /* placas de ferro rebitadas e o nome gravado (faixa de cobre) entre o fecho e a cornija */
  [-1,1].forEach(s=>{add(BB(5.5,2.4,.3,.06),K.iron,s*12.5,17.3,FZ+FT/2+.15);[[0,1.2,5.7,.18],[0,-1.2,5.7,.18],[2.85,0,.18,2.6],[-2.85,0,.18,2.6]].forEach(([dx,dy,a,c])=>add(new T.BoxGeometry(a,c,.2),K.copper,s*12.5+dx,17.3+dy,FZ+FT/2+.32));add(new T.BoxGeometry(4.4,.12,.1),K.copper,s*12.5,17.3,FZ+FT/2+.32);for(let q=0;q<4;q++)add(new T.SphereGeometry(.13,6,4),K.copper,s*12.5+(q%2?2.4:-2.4),17.3+(q<2?.95:-.95),FZ+FT/2+.32);});
  /* contrafortes em talude nas pontas (cobrem a junta com o paredão) */
  [-1,1].forEach(s=>{const g=new T.CylinderGeometry(1,1,1,4,1);g.rotateY(Math.PI/4);const p=g.attributes.position;for(let i=0;i<p.count;i++){const top=p.getY(i)>0;p.setX(i,p.getX(i)*(top?2.2:3.6)*Math.SQRT2);p.setZ(i,p.getZ(i)*(top?3.2:7)*Math.SQRT2);p.setY(i,top?FH-1.5:-1.2);}g.computeVertexNormals();
    add(g,K.cant,s*(FW+1.2),0,FZ+.5).userData.apoio=true;add(BB(4.8,.5,6.8,.08),K.lav,s*(FW+1.2),FH-1.3,FZ+.5);MM.box(arch,s*(FW+1.2),(FH-2.7)/2,FZ+.5,6,FH-.3,11);});
  /* lanternas de parede dos dois lados do arco */
  [-1,1].forEach(s=>{const u=s*13.2,v=6.4,z=FZ+FT/2;add(new T.BoxGeometry(.4,.4,1.1),K.iron,u,v+1.3,z+.55);add(new T.CylinderGeometry(.13,.13,.7,6),K.iron,u,v+.9,z+1.1);
    const gl=add(new T.CylinderGeometry(.34,.42,1.1,6),K.glass,u,v+.15,z+1.1);gl.castShadow=false;add(new T.ConeGeometry(.55,.5,6),K.iron,u,v+.95,z+1.1);add(new T.CylinderGeometry(.46,.28,.18,6),K.iron,u,v-.48,z+1.1);});
  /* abóbada de alvenaria atrás do arco até o túnel natural, com arcos de ferro; anel de fechamento atrás (esconde a fresta para o vazio) */
  add(vaultG(R0,SP,1.4,11),K.cant,0,0,FZ+FT/2).userData.semApoio=true;/* abóbada: vence o vão apoiada nas ombreiras e na rocha, não no chão */
  [FZ-1,FZ-4,FZ-7].forEach(z=>add(vaultG(R0-.25,SP,.25,.5),K.iron,0,0,z+.25).userData.semApoio=true);
  {const s=new T.Shape();const ro2=R0+1.5,ri2=7.0;s.moveTo(-ro2,-1.2);s.lineTo(-ro2,SP);s.absarc(0,SP,ro2,Math.PI,0,true);s.lineTo(ro2,-1.2);s.lineTo(ri2,-1.2);s.lineTo(ri2,SP);s.absarc(0,SP,ri2,0,Math.PI,false);s.lineTo(-ri2,-1.2);s.lineTo(-ro2,-1.2);
    const g=new T.ExtrudeGeometry(s,{depth:.8,bevelEnabled:false,curveSegments:16});g.translate(0,0,-.4);add(g,K.cant,0,0,FZ+FT/2-11+.4).userData.semApoio=true;}
  /* soleira e adro de lajes diante da boca (cobre o recorte do terreno), degrau de 0,5 */
  add(BB(2*R0,1.7,FT+.2,.06),M.pedra,0,-1.2+.85,FZ-.1);
  add(BB(24,1.5,5,.12),K.lav,0,-1,FZ+FT/2+2.5).userData.apoio=true;for(let i=-5;i<=5;i++)add(new T.BoxGeometry(.1,.04,4.6),K.iron,i*2.1,-.24,FZ+FT/2+2.5).castShadow=false;
  /* rochas que fundem a fachada ao penhasco (cantos e topo) */
  [[-20.5,-1,6,4.2,3.4,5],[21,-.8,5.5,3.8,3,4.6],[-16,23.5,1,4.6,2.6,4],[15.5,23.8,.5,5,2.8,4],[-21.5,16,1,3,4,3.4],[22,15,1,3.2,3.8,3.2]].forEach(([x,yy,z,sx,sy,sz],i)=>{const R=Math.max(sx,sz)*.8;yy=Math.min(...[[0,0],[R,0],[-R,0],[0,R],[0,-R]].map(([a,c])=>ctx.heightAt(b.x+x+a,b.z+1+z+c)))-y+sy*.15;/* pousada no ponto mais baixo do chão sob ela */const m=add(MM.rockGeo(7300+i,sx,sy,sz,2),ctx.rockMat,x,yy,z);m.rotation.y=r()*6.3;m.userData.apoio=true;});
  /* colisores: pilares de cada lado do vão, faixa acima do arco, adro */
  [-1,1].forEach(s=>MM.box(arch,s*(R0+(FW-R0)/2),(FH-1.2)/2,FZ,FW-R0,FH+1.2,FT));MM.box(arch,0,(SP+R0+FH)/2,FZ,2*FW,FH-(SP+R0),FT);
  [-1,1].forEach(s=>MM.box(arch,s*(R0-.8),SP+5.5,FZ,2.6,6,FT));/* rins do arco (ninguém fica preso no topo do vão) */
  out.push(arch);
  /* ================= TÚNEL E CÂMARA ================= */
  const tun=MM.obj('STORM.ARCH.CAVE.TUNNEL','Túnel e câmara da caverna','Architecture',{notes:'Chão plano caminhável de 12 studs com trilhos; quadros de escoramento a cada ~9 studs (colisores nos esteios); teto alto o bastante para pular (≥ 12 studs).'});
  const curve=new T.CatmullRomCurve3([new T.Vector3(b.x,y+7,b.z+2),new T.Vector3(b.x+2,y+7.5,b.z-16),new T.Vector3(b.x-3,y+8,b.z-32),new T.Vector3(-150,y+8.5,-140)]);
  const tg=new T.TubeGeometry(curve,48,8,12,false);{const p=tg.attributes.position;for(let i=0;i<p.count;i++){const n=MM.noise2(p.getX(i)*.35,p.getY(i)*.35+p.getZ(i)*.2,4);p.setXYZ(i,p.getX(i)+n*.9,p.getY(i)+n*.6,p.getZ(i));}tg.computeVertexNormals();}
  const tm=new T.Mesh(tg,M.pedraEscura.clone());tm.material.side=T.BackSide;tm.material.name='PedraEscuraInterna';tm.receiveShadow=true;tun.add(tm);
  const pts=curve.getPoints(40);
  /* piso contínuo (antes: 40 placas soltas com frestas na curva) — faixa de 12 studs com saia de 1 stud */
  {const P=[],idx=[];const side=i=>{const a=pts[Math.max(0,i-1)],c=pts[Math.min(pts.length-1,i+1)];const dx=c.x-a.x,dz=c.z-a.z,L=Math.hypot(dx,dz)||1;return[-dz/L,dx/L];};
    pts.forEach((p,i)=>{const[sx,sz]=side(i);for(const [o,yy] of [[-6.2,y-.5],[-6,y+.5],[6,y+.5],[6.2,y-.5]])P.push(p.x+sx*o,yy,p.z+sz*o);});
    for(let i=0;i<pts.length-1;i++)for(let k=0;k<3;k++){const a=i*4+k,c=a+4;idx.push(a,c,a+1,a+1,c,c+1);}
    const g=new T.BufferGeometry();g.setAttribute('position',new T.Float32BufferAttribute(P,3));g.setIndex(idx);g.computeVertexNormals();const fl=MM.mesh(g,M.pedra,0,0,0,tun);fl.castShadow=false;}
  /* trilhos e dormentes até a câmara */
  {const rails=[[],[]];for(let i=0;i<pts.length-4;i++){const a=pts[i],c=pts[i+1];const dx=c.x-a.x,dz=c.z-a.z,L=Math.hypot(dx,dz),ry=Math.atan2(dx,dz),sx=-dz/L,sz=dx/L;
      [-1.1,1.1].forEach((o,k)=>{const m=MM.mesh(new T.BoxGeometry(.22,.22,L+.05),K.iron,(a.x+c.x)/2+sx*o,y+.62,(a.z+c.z)/2+sz*o,tun);m.rotation.y=ry;m.castShadow=false;});
      const sl=MM.mesh(new T.BoxGeometry(3.4,.16,.5),K.woodD,(a.x+c.x)/2,y+.52,(a.z+c.z)/2,tun);sl.rotation.y=ry;sl.castShadow=false;}}
  /* quadros de escoramento (esteios, chapéu, mãos-francesas) com lanterna pendurada */
  [7,15,23,31].forEach(i=>{const p=pts[i],q=pts[i+1];const ry=Math.atan2(q.x-p.x,q.z-p.z);const fr=new T.Group();fr.position.set(p.x,y+.5,p.z);fr.rotation.y=ry;tun.add(fr);
    [-1,1].forEach(s=>{MM.mesh(new T.BoxGeometry(.8,9.6,.8),K.woodD,s*5.4,4.8,0,fr);MM.mesh(new T.BoxGeometry(1.2,.4,1.2),K.lav,s*5.4,.2,0,fr);const br=MM.mesh(new T.BoxGeometry(.4,2.6,.4),K.woodD,s*4.5,8.7,0,fr);br.rotation.z=s*.75;
      const c=Math.cos(ry),sn=Math.sin(ry);MM.box(tun,p.x+s*5.4*c,y+5.3,p.z-s*5.4*sn,.9,9.6,.9,ry);});
    MM.mesh(new T.BoxGeometry(12.4,.9,.9),K.woodD,0,10,0,fr);MM.mesh(new T.CylinderGeometry(.05,.05,1.3,4),K.iron,0,8.9,0,fr);
    const gl=MM.mesh(new T.CylinderGeometry(.3,.36,.9,6),K.glass,0,7.9,0,fr);gl.castShadow=false;MM.mesh(new T.ConeGeometry(.46,.4,6),K.iron,0,8.55,0,fr);});
  const ch=new T.Mesh(new T.SphereGeometry(19,20,14),M.pedraEscura.clone());ch.material.side=T.BackSide;ch.scale.set(1,.72,1.1);ch.position.set(-150,y+8,-152);tun.add(ch);
  MM.mesh(new T.CylinderGeometry(17,17,1,24),M.pedra,-150,y,-152,tun);
  /* estalactites */
  for(let i=0;i<16;i++){const a=r()*Math.PI*2,rr=r()*14;const cn=MM.mesh(new T.ConeGeometry(.8+r()*1.4,3+r()*5,6),M.pedraEscura,-150+Math.cos(a)*rr,y+19-r()*2,-152+Math.sin(a)*rr,tun);cn.rotation.x=Math.PI;}
  /* entulho ao pé da parede da câmara */
  const aEq=Math.atan2((-163+152)/1.05,-156+150);for(let i=0;i<10;i++){const a=i/10*Math.PI*2+.3;if(Math.abs(Math.sin(a)-1)<.25)continue;if(Math.abs(Math.atan2(Math.sin(a-aEq),Math.cos(a-aEq)))<.55)continue;/* longe da bobina */const m=MM.mesh(MM.rockGeo(7400+i,1.4+r(),.9+r()*.6,1.2+r()),ctx.rockMat,-150+Math.cos(a)*15.2,y+.4,-152+Math.sin(a)*15.2*1.05,tun);m.rotation.y=r()*6;m.userData.apoio=true;}
  tun.userData.walk=[{type:'flat',y:y+.5,pts:pts.map(p=>[p.x,p.z]),hw:6},{type:'disc',y:y+.5,x:-150,z:-152,r:16}];out.push(tun);
  /* ================= BOBINA ANTIGA (equipamento secreto) ================= */
  const eq=MM.obj('STORM.EQUIP.01.MODEL','Bobina antiga (equipamento secreto)','Props',{notes:'Marcador STORM.EQUIP.01. Mecânica ainda não implementada. Bobina de Tesla de cobre sobre pedestal de pedra, com coluna isolante, toroide, armação de ferro e cabo até a parede.'});eq.position.set(-156,y,-163);
  const e=(g,m,x,yy,z)=>MM.mesh(g,m,x,yy,z,eq);
  e(new T.CylinderGeometry(2.6,2.9,1.1,8),K.lav,0,.55,0).userData.apoio=true;e(new T.CylinderGeometry(2.2,2.3,.3,8),K.iron,0,1.25,0);
  for(let i=0;i<4;i++)e(new T.CylinderGeometry(.55,.75,.5,10),K.lav,0,1.65+i*.5,0);/* coluna de isoladores */
  e(new T.CylinderGeometry(1.15,1.15,4.2,14),K.woodD,0,5.2,0);
  {const hp=[];for(let i=0;i<=180;i++){const t=i/180;const a=t*Math.PI*2*14;hp.push(new T.Vector3(Math.cos(a)*1.24,3.2+t*4,Math.sin(a)*1.24));}const hc=new T.Mesh(new T.TubeGeometry(new T.CatmullRomCurve3(hp),360,.09,5,false),K.copper);hc.castShadow=true;eq.add(hc);}
  e(new T.CylinderGeometry(.2,.2,1.2,8),K.copper,0,7.8,0);const tor=e(new T.TorusGeometry(2.0,.55,10,28),K.copper,0,8.5,0);tor.rotation.x=Math.PI/2;e(new T.SphereGeometry(.35,10,8),K.copper,0,8.6,0);
  for(let k=0;k<4;k++){const a=k/4*Math.PI*2+Math.PI/4;const px=Math.cos(a)*2.3,pz=Math.sin(a)*2.3;e(new T.BoxGeometry(.28,5.6,.28),K.iron,px,4.2,pz);e(new T.SphereGeometry(.2,6,5),K.copper,px,7.05,pz);}
  [[2.3,0],[0,2.3]].forEach(([dx,dz])=>{e(new T.BoxGeometry(dx?4.6:.2,.2,dz?4.6:.2),K.iron,0,6.6,0).rotation.y=Math.PI/4;});
  {const c=MM.catenary(new T.Vector3(1.6,1.4,.6),new T.Vector3(-3.6,3.6,-6.2),.9,14);eq.add(MM.tube(c,.12,K.iron,16,5));}
  MM.box(eq,0,3.5,0,5.6,7,5.6);out.push(eq);
  return out;};
})();
