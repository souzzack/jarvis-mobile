/* Ilha das Tempestades · Architecture · Observatório Abandonado e Santuário da Tempestade */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
I.buildObservatory=function(ctx){const M=ctx.mat,P=I.poi.observatorio;const o=MM.obj('STORM.ARCH.OBSERVATORY','Observatório Abandonado','Architecture',{notes:'Cúpula partida, telescópio de latão (STORM.PUZZLE.OBS) e anexo em ruínas. Porta 9 × 10 studs.'});
  o.position.set(P.x,P.h,P.z);const add=(g,m,x,y,z)=>MM.mesh(g,m,x,y,z,o);
  add(new T.CylinderGeometry(15.5,16.5,1.4,24),M.pedraClara,0,.7,0);add(new T.CylinderGeometry(14,14.6,10,20),M.alvenaria,0,5.7,0);
  add(new T.TorusGeometry(14.2,.5,6,24),M.metalEscuro,0,10.6,0).rotation.x=Math.PI/2;
  MM.mesh(MM.arcSlab(13.75,14.95,9/14.4,10),M.madeira,0,.7,0,o);MM.mesh(MM.arcSlab(13.75,15.25,10.6/14.4,1),M.pedraClara,0,10.4,0,o);/* V2.3.2: porta em arco cravada no cilindro (antes placa reta com as bordas soltas) */
  /* cúpula partida: casca incompleta + nervuras soltas + placas caídas */
  const dome=add(new T.SphereGeometry(13.6,18,9,.6,4.3,0,Math.PI/2),M.metalEscuro,0,10.8,0);dome.material=M.metalEscuro;
  for(let i=0;i<9;i++){const rib=add(new T.TorusGeometry(13.8,.3,4,12,Math.PI/2*(i%3===0?.6:1)),M.cobre,0,10.8,0);rib.rotation.set(0,.6+i*.5,0);rib.rotateZ(Math.PI/2);rib.rotateX(0);}
  /* telescópio */
  const tel=new T.Group();tel.name='Telescopio';tel.position.set(0,11,0);o.add(tel);MM.mesh(new T.CylinderGeometry(1.4,2,3,8),M.metalEscuro,0,0,0,tel);
  const tube=MM.mesh(new T.CylinderGeometry(1.5,1.9,19,12),M.cobre,0,7,3,tel);tube.rotation.x=-.75;MM.mesh(new T.TorusGeometry(1.7,.3,6,14),M.metal,0,13.4,9.5,tel).rotation.x=Math.PI/2-.75;
  /* anexo em ruínas e entulho */
  const r=MM.rng(55);const gl=(lx,lz,R)=>Math.min(...[[0,0],[R,0],[-R,0],[0,R],[0,-R]].map(([a,b])=>ctx.heightAt(P.x+lx+a,P.z+lz+b)))-P.h;
  /* V2.3.1: cada parede do anexo apoiada no próprio chão (antes: centro fixo em y=3 → as mais baixas flutuavam) */
  for(let i=0;i<5;i++){const h=4+r()*7,lx=20+i*1.2,lz=-6+i*5;const g0=gl(lx,lz,4.2);const w=add(new T.BoxGeometry(8,h+1,1.4),M.alvenaria,lx,g0+h/2-.5,lz);w.rotation.y=.4+r()*.2;w.userData.apoio=true;}
  for(let i=0;i<10;i++){const a=r()*Math.PI*2,rr=17+r()*9;const sx=2+r()*3,sz=2+r()*3,px=Math.cos(a)*rr,pz=Math.sin(a)*rr;const pl=add(new T.BoxGeometry(sx,.4,sz),i%2?M.metalEscuro:M.pedra,px,gl(px,pz,Math.max(sx,sz)/2)+.12,pz);pl.rotation.set((r()-.5)*.2,r()*3,(r()-.5)*.2);pl.userData.apoio=true;}
  [[0,0,22.6,9.4,0],[0,0,9.4,22.6,0],[0,0,22.6,9.4,Math.PI/4],[0,0,9.4,22.6,Math.PI/4]].forEach(([x,z,sx,sz,ry])=>MM.box(o,x,5.7,z,sx,11.4,sz,ry));/* V2.3.2: colisor segue o cilindro r≈16 (antes um quadrado de 28 cujos cantos fechavam a frente da porta) */o.userData.assento=MM.seat(ctx,o,{r:16.5,y:P.h,mat:M.pedraClara});return[o];};
I.buildSanctuary=function(ctx){const M=ctx.mat,P=I.poi.santuario,K=I.houseMats(ctx),BB=MM.bevelBox;const s=MM.obj('STORM.ARCH.SANCTUARY','Santuário da Tempestade','Architecture',{notes:'Área secreta. Seis pilares condutores em volta de um altar: o mesmo símbolo das Sete Estrelas do Axolote Nebular (STORM.DISCOVERY.01). Plataforma hexagonal de dois degraus, entrada pelo norte (fim da trilha P5), muro de runas ao sul. Pilares com colisão.'});
  /* Mapa V1: base hexagonal coerente com os 6 pilares (antes heptagonal), pilares de cantaria com sulcos de runas na cor de cada gema,
     garras que seguram as gemas, condutores de cobre até o altar, altar escalonado com esfera armilar em volta da Sétima Estrela,
     muro curvo de runas com a constelação, braseiros de cristal na entrada e degraus. Posições, alturas e cores dos pilares: as de antes. */
  s.position.set(P.x,P.h,P.z);const add=(g,m,x,y,z)=>MM.mesh(g,m,x,y,z,s);const hex=(r0,r1,h,m,y)=>{const c=add(new T.CylinderGeometry(r0,r1,h,6),m,0,y,0);c.rotation.y=Math.PI/6;return c;};
  hex(16,16.6,.8,K.cant,.4).userData.apoio=true;hex(15,15.4,.7,K.lav,1.15);hex(11,11,.5,K.cant,1.5);
  {const tr=add(new T.TorusGeometry(11.1,.14,4,6),K.copper,0,1.76,0);tr.rotation.set(Math.PI/2,0,Math.PI/6);tr.scale.z=.5;const c2=add(new T.TorusGeometry(5,.1,4,48),K.copper,0,1.76,0);c2.rotation.x=Math.PI/2;c2.scale.z=.5;}
  /* degraus na entrada (norte, −Z local) */
  add(BB(8,.9,1.4,.06),K.lav,0,.05,-15.1).userData.apoio=true;MM.box(s,0,.05,-15.1,8,.9,1.4);
  const cores=['#3B82F6','#2DD4BF','#EF4444','#BAE6FD','#F5C76B','#A855F7'];const tops=[];
  for(let i=0;i<6;i++){const a=Math.PI/2+i*Math.PI/3;const rr=i%2?9:11;const x=Math.cos(a)*rr,z=-Math.sin(a)*rr;const h=9+(i%2?0:2);
    const gem=new T.MeshStandardMaterial({color:cores[i],emissive:MM.C(cores[i]),emissiveIntensity:.7,roughness:.3});gem.name='Gema'+i;
    const pg=new T.Group();pg.position.set(x,1.75,z);pg.rotation.y=Math.atan2(x,z);s.add(pg);const q=(g,m,yy,zz)=>{const mm=MM.mesh(g,m,0,yy,zz||0,pg);if(g.type==='CylinderGeometry')mm.rotation.y=Math.PI/6;return mm;};/* faces planas para fora */
    q(new T.CylinderGeometry(1.95,2.15,.8,6),K.lav,.4);q(new T.CylinderGeometry(1.0,1.25,h-1.5,6),K.cant,.8+(h-1.5)/2);
    [2.2,h*.55,h-1.2].forEach(yy=>q(new T.CylinderGeometry(1.3-.25*(yy/h),1.3-.25*(yy/h),.28,6),K.copper,yy));
    [-1,1].forEach(sd=>{const g=q(new T.BoxGeometry(.24,h-3.2,.14),gem,1.5+(h-3.2)/2,sd*1.0);g.rotation.x=sd*.028;g.castShadow=false;});/* sulcos de runas (para dentro e para fora) */
    q(new T.CylinderGeometry(1.95,1.35,.7,6),K.lav,h-.45);q(new T.CylinderGeometry(1.8,1.8,.35,6),K.iron,h+.05);
    for(let k=0;k<3;k++){const an=k/3*Math.PI*2;const c=q(new T.BoxGeometry(.16,1.3,.16),K.iron,h+.75,0);c.position.x=Math.cos(an)*.55;c.position.z=Math.sin(an)*.55;c.rotation.y=-an;c.rotateZ(.35);}
    const gm=q(new T.OctahedronGeometry(.6,0),gem,h+.85);gm.castShadow=false;/* gema na mesma altura de antes (y local h+2,6) */
    tops.push(new T.Vector3(x,1.75+h+.2,z));MM.box(s,x,1.75+.8+(h-.8)/2,z,2.1,h-.8,2.1,Math.atan2(x,z)+Math.atan2(7,14));/* girado para alinhar com a chegada da trilha P5 (o fuste é hexagonal: qualquer giro cobre as faces) *//* fuste: faces planas a 1,08 na base; o plinto de 0,8 é pisável */}
  /* altar escalonado e a Sétima Estrela com esfera armilar */
  hex(2.9,3.2,.8,K.lav,2.15);hex(2.15,2.4,1.6,K.cant,3.35);hex(2.5,2.25,.45,K.lav,4.38);
  const core=new T.MeshStandardMaterial({color:'#FFF4D6',emissive:MM.C('#FFF4D6'),emissiveIntensity:.5,roughness:.3});core.name='SetimaEstrela';
  add(new T.OctahedronGeometry(.9,0),core,0,5.4,0).castShadow=false;
  [[Math.PI/2,0],[Math.PI/2,Math.PI/2],[0,0]].forEach(([rx,ry],k)=>{const t=add(new T.TorusGeometry(1.45+k*.12,.06,5,32),K.copper,0,5.4,0);t.rotation.set(rx,ry,k*.4);t.castShadow=false;});
  add(new T.CylinderGeometry(.08,.08,1,6),K.copper,0,4.9,0);
  /* condutores de cobre: do capitel de cada pilar ao altar */
  tops.forEach(p=>{const c=MM.catenary(p,new T.Vector3(p.x*.12,5.9,p.z*.12),.4,14);s.add(MM.tube(c,.08,K.copper,16,4));});
  /* muro curvo de runas ao sul, com a constelação das Sete Estrelas */
  add(MM.arcSlab(12.4,13.5,1.7,4.1),K.cant,0,.8,0);add(MM.arcSlab(12.25,13.65,1.76,.4),K.lav,0,4.9,0);/* apoiado no degrau de baixo (antes ficava 0,7 acima dele) */
  [-1,1].forEach(sd=>{const e=add(BB(1.5,5.4,1.6,.08),K.lav,0,3.5,0);const an=sd*.85;e.position.set(Math.sin(an)*12.95,3.5,Math.cos(an)*12.95);e.rotation.y=an;});
  [[-.62,2.9],[-.4,3.9],[-.18,2.6],[0,4.0],[.2,3.1],[.42,4.1],[.6,2.8]].forEach(([an,yy],k)=>{const st=add(new T.OctahedronGeometry(.22,0),k===3?core:M.energia,Math.sin(an)*12.32,1.5+yy-1.2,Math.cos(an)*12.32);st.castShadow=false;});
  for(let k=-4;k<=4;k++){const an=k*.2;MM.box(s,Math.sin(an)*12.95,2.85,Math.cos(an)*12.95,2.75,4.1,1.1,an);}
  /* braseiros de cristal na entrada */
  [-1,1].forEach(sd=>{const x=sd*7.6,z=-12.4;add(new T.CylinderGeometry(.5,.7,.4,8),K.iron,x,1.95,z);add(new T.CylinderGeometry(.18,.24,2,8),K.iron,x,3.1,z);add(new T.CylinderGeometry(.9,.45,.6,8),K.iron,x,4.3,z);
    [[0,0,.9],[.3,.2,.6],[-.3,-.1,.5]].forEach(([dx,dz,hh],k)=>{const c=add(MM.crystalGeo(.18,hh,.35),M.cristal,x+dx,4.45,z+dz);c.rotation.set(dz,k,dx);c.castShadow=false;});MM.box(s,x,3.2,z,1.4,2.9,1.4);});
  /* rochas que assentam a plataforma no platô (fora da entrada) */
  {const r=MM.rng(1717);for(let k=0;k<7;k++){const an=Math.PI/7+k*(2*Math.PI-2*Math.PI/7)/6;const x=Math.sin(an)*17.6,z=-Math.cos(an)*17.6;if(Math.abs(Math.atan2(x,-z))<.6)continue;const sx=1.6+r()*1.4,sy=1+r()*.8,sz=1.4+r()*1.2;const R=Math.max(sx,sz)*.8;
    const g=Math.min(...[[0,0],[R,0],[-R,0],[0,R],[0,-R]].map(([a,b])=>ctx.heightAt(P.x+x+a,P.z+z+b)))-P.h;const m=add(MM.rockGeo(7600+k,sx,sy,sz,2),ctx.rockMat,x,g+sy*.15+.3,z);m.rotation.y=r()*6;m.userData.apoio=true;}}
  MM.box(s,0,3,0,4,3,4);s.userData.assento=MM.seat(ctx,s,{r:16.6,bury:.3,mat:K.cant});/* V2.3.1: o fim da trilha P5 rebaixa o platô para ≈5; antes o santuário ficava fixo em 10, flutuando ≈5 studs */return[s];};
})();
