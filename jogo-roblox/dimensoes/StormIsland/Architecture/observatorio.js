/* Ilha das Tempestades · Architecture · Observatório Abandonado e Santuário da Tempestade */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
I.buildObservatory=function(ctx){const M=ctx.mat,P=I.poi.observatorio,K=I.houseMats(ctx),BB=MM.bevelBox;const o=MM.obj('STORM.ARCH.OBSERVATORY','Observatório Abandonado','Architecture',{notes:'Tambor de cantaria com pilastras e janelas tapadas com tábuas, porta em arco com moldura, cúpula de chapa com fenda de observação e um painel desabado, luneta equatorial de latão (STORM.PUZZLE.OBS) apontando pela fenda, e anexo em ruínas. Porta 5,6 × 8,6 studs.'});
  /* Mapa V1. Antes: argola da luneta solta no ar, nervuras de toros girados ao acaso cruzando a cúpula, porta-placa da altura do tambor,
     anexo de 5 placas soltas. Posição, raio do tambor, porta em +Z (rota P4), colisores do tambor e o grupo 'Telescopio': os mesmos. */
  o.position.set(P.x,P.h,P.z);const add=(g,m,x,y,z,p)=>MM.mesh(g,m,x,y,z,p||o);const r=MM.rng(55);
  /* plinto e tambor */
  add(new T.CylinderGeometry(15.5,16.5,1.4,40),K.lav,0,.7,0).userData.apoio=true;add(new T.CylinderGeometry(15.9,15.9,.25,40),K.lav,0,1.45,0);
  add(new T.CylinderGeometry(14,14.6,10,40),K.cant,0,5.7,0);
  [[1.9,14.75,.3],[7.6,14.2,.2]].forEach(([y,rr,tb])=>add(new T.TorusGeometry(rr,tb,6,48),K.lav,0,y,0).rotation.x=Math.PI/2);
  add(new T.CylinderGeometry(14.9,14.5,.9,40),K.lav,0,10.95,0);add(new T.TorusGeometry(14.3,.28,6,48),K.iron,0,11.45,0).rotation.x=Math.PI/2;/* cornija e trilho da cúpula */
  /* pilastras e janelas cegas em arco (vidro escuro) entre elas */
  for(let i=0;i<12;i++){const an=i/12*Math.PI*2+Math.PI/12;const pl=add(MM.arcSlab(14.2,14.95,.09,9.1),K.lav,0,1.6,0);pl.rotation.y=an;
    const wa=an+Math.PI/12;if(Math.abs(Math.atan2(Math.sin(wa),Math.cos(wa)))<.35)continue;/* nenhuma janela na porta */
    const w=add(MM.arcSlab(14.05,14.42,1.4/14.3,4.2),K.woodD,0,3.8,0);w.rotation.y=wa;w.castShadow=false;[4.6,7.0].forEach(yy=>{const st=add(MM.arcSlab(14.4,14.5,1.5/14.3,.18),K.iron,0,yy,0);st.rotation.y=wa;});/* janelas tapadas com tábuas (abandonado) */const sill=add(MM.arcSlab(14.2,14.8,1.9/14.3,.3),K.lav,0,3.5,0);sill.rotation.y=wa;const top=add(MM.arcSlab(14.2,14.75,1.9/14.3,.5),K.lav,0,8.0,0);top.rotation.y=wa;}
  /* porta: pórtico saliente com ombreiras, arco, fecho e folhas de tábua recuadas */
  {const g=new T.Group();g.position.set(0,1.6,14.15);o.add(g);const q=(geo,m,x,y,z)=>MM.mesh(geo,m,x,y,z,g);
    const ring=new T.Shape();ring.moveTo(-3.9,0);ring.lineTo(-3.9,6.2);ring.absarc(0,6.2,3.9,Math.PI,0,true);ring.lineTo(3.9,0);ring.lineTo(2.8,0);ring.lineTo(2.8,6.2);ring.absarc(0,6.2,2.8,0,Math.PI,false);ring.lineTo(-2.8,0);ring.lineTo(-3.9,0);
    q(new T.ExtrudeGeometry(ring,{depth:1.6,bevelEnabled:false,curveSegments:14}),K.lav,0,0,0);
    const leaf=new T.Shape();leaf.moveTo(-2.8,0);leaf.lineTo(-2.8,6.2);leaf.absarc(0,6.2,2.8,Math.PI,0,true);leaf.lineTo(2.8,0);leaf.lineTo(-2.8,0);q(new T.ExtrudeGeometry(leaf,{depth:.3,bevelEnabled:false,curveSegments:14}),K.woodD,0,0,.35);
    q(new T.BoxGeometry(.08,8.6,.06),K.iron,0,4.3,.68);[1.4,4.6].forEach(y=>q(new T.BoxGeometry(5.2,.22,.06),K.iron,0,y,.7));[-.6,.6].forEach(x=>q(new T.TorusGeometry(.24,.06,5,10),K.copper,x,3.6,.72));
    q(BB(1.1,1.3,1.9,.08),K.lav,0,10.15,.95);q(BB(9.2,.5,2,.08),K.lav,0,.25,1.1);}
  /* cúpula de chapa: fenda de observação (norte, −Z) com trilhos e veneziana meio aberta; um painel desabado a sudoeste */
  const R=13.6,Y0=11.5,slit=.42,fz=Math.PI*1.5;/* ângulo phi do three: 0=−X, π/2=+Z, π=+X, 3π/2=−Z → fenda ao norte (−Z) */const hole0=6.6,hole1=7.2;/* painel desabado a oés-sudoeste (phi além de 2π) */
  const seg=(a0,a1,t0,t1)=>{const g=new T.SphereGeometry(R,Math.max(3,Math.round((a1-a0)*8)),10,a0,a1-a0,t0,t1-t0);const m=add(g,K.roof,0,Y0,0);m.material=K.roof;return m;};
  /* SphereGeometry: phi a partir de +X girando para −Z… usa ângulos do three; a fenda fica em [fz−slit/2, fz+slit/2] */
  const A=(x)=>x;seg(A(fz+slit/2),A(hole0),0,Math.PI/2);seg(A(hole0),A(hole1),0,Math.PI/2*.55);seg(A(hole1),A(fz-slit/2+Math.PI*2),0,Math.PI/2);
  /* nervuras meridianas (quartos de toro do horizonte ao zênite), fora da fenda; aro da base */
  const sphDir=phi=>new T.Vector3(-Math.cos(phi),0,Math.sin(phi));/* direção horizontal do three para o ângulo phi da esfera */
  for(let i=0;i<16;i++){const phi=i/16*Math.PI*2;const dd=Math.atan2(Math.sin(phi-fz),Math.cos(phi-fz));if(Math.abs(dd)<slit/2+.08)continue;const ph=phi<fz?phi+Math.PI*2:phi;const inHole=ph>hole0+.05&&ph<hole1-.05;
    const d=sphDir(phi);const rib=add(new T.TorusGeometry(R+.12,.16,5,16,inHole?Math.PI/2*.55:Math.PI/2),K.copper,0,Y0,0);rib.rotation.y=Math.atan2(-d.z,d.x);}
  add(new T.TorusGeometry(R+.1,.3,6,64),K.copper,0,Y0+.1,0).rotation.x=Math.PI/2;
  [-1,1].forEach(s=>{const phi=fz+s*(slit/2+.03);const d=sphDir(phi);const rl=add(new T.TorusGeometry(R+.25,.22,5,20,Math.PI/2),K.iron,0,Y0,0);rl.rotation.y=Math.atan2(-d.z,d.x);});
  {const sh=new T.SphereGeometry(R+.35,3,6,fz-slit/2-.02,slit+.04,.15,.55);add(sh,K.roof,0,Y0,0);}/* veneziana recolhida até a metade */
  /* chão de observação dentro do tambor e a luneta equatorial (grupo 'Telescopio', mesmo ponto) */
  add(new T.CylinderGeometry(13.9,13.9,.2,40),K.woodD,0,10.75,0).castShadow=false;
  const tel=new T.Group();tel.name='Telescopio';tel.position.set(0,11,0);o.add(tel);const t=(geo,m,x,y,z,p)=>MM.mesh(geo,m,x,y,z,p||tel);
  t(new T.CylinderGeometry(1.4,2,3,8),K.cant,0,0,0);t(new T.CylinderGeometry(1.6,1.6,.3,12),K.iron,0,1.6,0);
  {const fk=new T.Group();fk.position.set(0,1.75,0);fk.rotation.y=Math.PI;tel.add(fk);[-1,1].forEach(s=>t(new T.BoxGeometry(.35,3.4,.8),K.iron,s*1.4,1.7,0,fk));
    const tb=new T.Group();tb.position.set(0,3.2,0);tb.rotation.x=.82;fk.add(tb);/* tubo inclinado para cima, pela fenda */
    t(new T.CylinderGeometry(1.15,1.0,15,18),K.copper,0,4,0,tb);t(new T.CylinderGeometry(1.35,1.35,1.4,18),K.copper,0,11.2,0,tb);t(new T.CylinderGeometry(.5,.5,1.6,10),K.iron,0,-4.2,0,tb);
    [-1,5,9.6].forEach(y=>t(new T.TorusGeometry(1.2,.13,6,20),K.iron,0,y,0,tb).rotation.x=Math.PI/2);t(new T.CylinderGeometry(.18,.18,2.9,6),K.iron,0,0,0,tb).rotation.z=Math.PI/2;
    const lens=t(new T.TorusGeometry(1.3,.1,5,16),K.copper,1.1,10.4,.6,tb);lens.rotation.set(1.2,.4,0);/* aro da objetiva solto, pendurado (a luneta está quebrada) */}
  /* anexo em ruínas a leste: planta 10 × 16, paredes de cantaria com topo quebrado, aberturas, piso de lajes e entulho */
  {const ax=23,az=0,gl=(lx,lz,Rr)=>Math.min(...[[0,0],[Rr,0],[-Rr,0],[0,Rr],[0,-Rr]].map(([a,b])=>ctx.heightAt(P.x+lx+a,P.z+lz+b)))-P.h;
    const g0=gl(ax,az,7);add(BB(11,1,17,.1),K.lav,ax,g0+.2,az).userData.apoio=true;
    const wall=(x0,z0,x1,z1,hs,holes)=>{const L=Math.hypot(x1-x0,z1-z0);const s=new T.Shape();s.moveTo(0,-1);hs.forEach(([u,h])=>s.lineTo(u*L,h));s.lineTo(L,-1);s.lineTo(0,-1);
        (holes||[]).forEach(([u0,u1,v0,v1])=>{const p=new T.Path();p.moveTo(u0*L,v0);p.lineTo(u0*L,v1);p.absarc((u0+u1)/2*L,v1,(u1-u0)/2*L,Math.PI,0,true);p.lineTo(u1*L,v0);p.lineTo(u0*L,v0);s.holes.push(p);});
        const geo=new T.ExtrudeGeometry(s,{depth:1.2,bevelEnabled:false,curveSegments:8});geo.translate(0,0,-.6);const m=add(geo,K.cant,x0,g0+.7,z0);m.rotation.y=-Math.atan2(z1-z0,x1-x0);m.userData.apoio=true;
        const hmax=Math.max(...hs.map(q=>q[1]));MM.box(o,(x0+x1)/2,g0+.7+hmax*.45,(z0+z1)/2,Math.abs(x1-x0)+1.2,hmax*.9,Math.abs(z1-z0)+1.2);};
    wall(18,-8,28,-8,[[0,7.5],[.25,8.2],[.42,6.4],[.55,5],[.7,3.2],[.85,2.1],[1,1.6]],[[.1,.3,2.4,4.6]]);
    wall(28,-8,28,8,[[0,1.5],[.18,2.8],[.3,4.6],[.5,6.6],[.62,5.4],[.8,3],[1,2.2]],[[.38,.58,1.8,4.2]]);
    wall(18,8,23,8,[[0,6.8],[.4,7.4],[.7,5.2],[1,3.6]],[]);wall(18,-8,18,-2,[[0,7.5],[.5,7.9],[1,6.6]],[]);wall(18,2.6,18,8,[[0,6.2],[.4,6.9],[1,6.8]],[]);/* vão de porta para o tambor */
    [[18,-8],[28,-8],[18,8]].forEach(([x,z])=>add(BB(1.8,3.2,1.8,.1),K.lav,x,g0+1.9,z));
    /* arco partido que ligava o anexo ao tambor */
    {const sh=new T.Shape();sh.moveTo(-2.6,0);sh.lineTo(-2.6,4);sh.absarc(0,4,2.6,Math.PI,Math.PI*.42,true);sh.lineTo(Math.cos(Math.PI*.42)*1.6,4+Math.sin(Math.PI*.42)*1.6);sh.absarc(0,4,1.6,Math.PI*.42,Math.PI,false);sh.lineTo(-1.6,0);sh.lineTo(-2.6,0);
      const ar=add(new T.ExtrudeGeometry(sh,{depth:1.2,bevelEnabled:false,curveSegments:10}),K.lav,16.8,g0+.7,.3);ar.rotation.y=Math.PI/2;}
    /* entulho: blocos de cantaria e placas da cúpula caídas */
    for(let i=0;i<14;i++){const lx=17+r()*13,lz=-10+r()*21;if(lx>19&&lx<27&&lz>-6.5&&lz<6.5&&i%2)continue;const s=.7+r()*1.1;const b=add(BB(s*1.4,s*.8,s,.08),i%3?K.cant:K.lav,lx,gl(lx,lz,s*.7)+s*.35,lz);b.rotation.set((r()-.5)*.3,r()*3,(r()-.5)*.3);b.userData.apoio=true;}
    for(let i=0;i<5;i++){const an=hole0+.1+r()*(hole1-hole0-.2);const d=sphDir(an);const rr=17+r()*4;const px=d.x*rr,pz=d.z*rr;const sx=2.2+r()*1.5,sz=1.8+r()*1.2;
      const pl=add(new T.SphereGeometry(R,3,2,0,sx/R,Math.PI/2-sz/R,sz/R),K.roof,px,gl(px,pz,1.6)-R+.35,pz);pl.rotation.set((r()-.5)*.25,r()*6,(r()-.5)*.25);pl.material=K.roof;pl.userData.apoio=true;}}
  /* colisores do tambor (seguem o cilindro r≈16, porta livre na frente) */
  [[0,0,22.6,9.4,0],[0,0,9.4,22.6,0],[0,0,22.6,9.4,Math.PI/4],[0,0,9.4,22.6,Math.PI/4]].forEach(([x,z,sx,sz,ry])=>MM.box(o,x,5.7,z,sx,11.4,sz,ry));
  o.userData.assento=MM.seat(ctx,o,{r:16.5,y:P.h,mat:K.lav});return[o];};
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
