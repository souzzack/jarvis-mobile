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
I.buildSanctuary=function(ctx){const M=ctx.mat,P=I.poi.santuario;const s=MM.obj('STORM.ARCH.SANCTUARY','Santuário da Tempestade','Architecture',{notes:'Área secreta. Seis pilares condutores em volta de um altar: o mesmo símbolo das Sete Estrelas do Axolote Nebular (STORM.DISCOVERY.01).'});
  s.position.set(P.x,P.h,P.z);const add=(g,m,x,y,z)=>MM.mesh(g,m,x,y,z,s);
  add(new T.CylinderGeometry(15,16,1.4,7),M.pedraClara,0,.7,0);add(new T.CylinderGeometry(11,11,.5,7),M.pedra,0,1.5,0);
  const cores=['#3B82F6','#2DD4BF','#EF4444','#BAE6FD','#F5C76B','#A855F7'];
  for(let i=0;i<6;i++){const a=Math.PI/2+i*Math.PI/3;const rr=i%2?9:11;const x=Math.cos(a)*rr,z=-Math.sin(a)*rr;const h=9+(i%2?0:2);
    add(new T.CylinderGeometry(1.2,1.6,h,6),M.pedra,x,h/2+1.4,z);add(new T.CylinderGeometry(1.8,1.8,.7,6),M.metalEscuro,x,h+1.6,z);
    const gem=new T.MeshStandardMaterial({color:cores[i],emissive:MM.C(cores[i]),emissiveIntensity:.7,roughness:.3});gem.name='Gema'+i;const gm=add(new T.OctahedronGeometry(.6,0),gem,x,h+2.6,z);gm.castShadow=false;}
  add(new T.BoxGeometry(4,3,4),M.pedraClara,0,3,0);const core=new T.MeshStandardMaterial({color:'#FFF4D6',emissive:MM.C('#FFF4D6'),emissiveIntensity:.5,roughness:.3});core.name='SetimaEstrela';
  add(new T.OctahedronGeometry(.9,0),core,0,5.4,0).castShadow=false;
  MM.box(s,0,3,0,4,3,4);s.userData.assento=MM.seat(ctx,s,{r:16,bury:.3,mat:M.pedraClara});/* V2.3.1: o fim da trilha P5 rebaixa o platô para ≈5; antes o santuário ficava fixo em 10, flutuando ≈5 studs */return[s];};
})();
