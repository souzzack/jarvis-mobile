/* Ilha das Tempestades · Architecture · Torre Meteorológica (monumento visível de toda a ilha)
   ~131 studs de altura sobre a colina de 36 studs. Base pesada de pedra → fuste com escada externa → treliça de metal com núcleo
   de energia → cúpula de cobre com anemômetro → agulha para-raios (o alvo dos relâmpagos). */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
I.buildTower=function(ctx){const M=ctx.mat,P=I.poi.torre;const y0=P.h;
  const tw=MM.obj('STORM.ARCH.TOWER','Torre Meteorológica','Architecture',{notes:'Monumento e futuro puzzle (STORM.PUZZLE.TOWER). Porta 10 × 12 studs voltada para a vila. Peças giratórias separadas (anemômetro, cata-vento).'});
  tw.position.set(P.x,y0,P.z);
  const add=(g,m,x,y,z)=>MM.mesh(g,m,x,y,z,tw);
  /* 1. base octogonal com contrafortes */
  add(new T.CylinderGeometry(22,26,12,8),M.pedra,0,6,0).rotation.y=Math.PI/8;
  add(new T.CylinderGeometry(27.5,28,1.4,8),M.pedraClara,0,.7,0).rotation.y=Math.PI/8;
  for(let i=0;i<8;i++){const a=i/8*Math.PI*2;if(i===0)continue;const b=add(new T.BoxGeometry(3.2,13,7),M.pedraClara,Math.sin(a)*24.5,6.5,Math.cos(a)*24.5);b.rotation.y=a;
    const cap=add(new T.CylinderGeometry(0,2.3,4,4),M.metalEscuro,Math.sin(a)*25.5,14.5,Math.cos(a)*25.5);cap.rotation.y=a+Math.PI/4;}
  /* porta (voltada para +Z, a vila): vão escuro, batentes e arco de aduelas */
  add(new T.BoxGeometry(10,12,1.2),M.madeira,0,6,23.6);
  for(let k=0;k<=8;k++){const a=Math.PI*k/8;const v=add(new T.BoxGeometry(2.2,2.6,2.4),M.pedraClara,Math.cos(a)*6.4,12+Math.sin(a)*5.2,24);v.rotation.z=a-Math.PI/2;}
  [-6.4,6.4].forEach(x=>add(new T.BoxGeometry(2.2,12,2.4),M.pedraClara,x,6,24));
  add(new T.TorusGeometry(22.6,.7,6,8),M.metal,0,12.3,0).rotation.set(Math.PI/2,0,Math.PI/8);
  /* 2. fuste de pedra com cintas de metal e seteiras */
  add(new T.CylinderGeometry(12.5,16,44,8),M.alvenaria,0,34,0).rotation.y=Math.PI/8;
  [22,33,44,55].forEach(y=>add(new T.TorusGeometry(15.4-(y-12)/44*3.3,.55,6,8),M.metalEscuro,0,y,0).rotation.set(Math.PI/2,0,Math.PI/8));
  for(let lv=0;lv<3;lv++)for(let i=0;i<4;i++){const a=i/4*Math.PI*2+Math.PI/4;const r=15-lv*1.1;const w=add(new T.BoxGeometry(1.4,4.2,1),M.vidro,Math.sin(a)*r,20+lv*12,Math.cos(a)*r);w.rotation.y=a;}
  /* escada em espiral (degraus de 5 × 1 × 3; 1,1 stud de subida por degrau) */
  const steps=40;for(let s=0;s<steps;s++){const a=s/steps*Math.PI*2.6+Math.PI*.6,y=12.6+s*1.1;const r=18.2;const st=add(new T.BoxGeometry(6,1,3.2),M.pedraClara,Math.sin(a)*r,y,Math.cos(a)*r);st.rotation.y=a+Math.PI/2;
    if(s%3===0){const po=add(new T.CylinderGeometry(.25,.25,3.6,5),M.metal,Math.sin(a)*(r+2.8),y+2.2,Math.cos(a)*(r+2.8));po.castShadow=false;}}
  /* 3. sacada e treliça */
  add(new T.CylinderGeometry(20,19,1.6,16),M.metalEscuro,0,56.8,0);
  add(new T.TorusGeometry(19.6,.3,5,32),M.metal,0,60.2,0).rotation.x=Math.PI/2;
  for(let i=0;i<24;i++){const a=i/24*Math.PI*2;add(new T.CylinderGeometry(.22,.22,3.6,4),M.metal,Math.sin(a)*19.6,58.4,Math.cos(a)*19.6).castShadow=false;}
  const S=6.5;[[1,1],[1,-1],[-1,1],[-1,-1]].forEach(([a,b])=>add(new T.BoxGeometry(1.6,36,1.6),M.metal,a*S,75.5,b*S));
  for(let lv=0;lv<4;lv++){const ya=58+lv*9,yb=ya+9;[[[S,S],[S,-S]],[[S,-S],[-S,-S]],[[-S,-S],[-S,S]],[[-S,S],[S,S]]].forEach(([p,q])=>{
      const A=new T.Vector3(p[0],ya,p[1]),B=new T.Vector3(q[0],yb,q[1]);const L=A.distanceTo(B);const br=add(new T.CylinderGeometry(.35,.35,L,5),M.metalEscuro,(A.x+B.x)/2,(A.y+B.y)/2,(A.z+B.z)/2);
      br.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),B.clone().sub(A).normalize());});
    add(new T.BoxGeometry(S*2+1.6,.8,1.2),M.metal,0,ya,S);add(new T.BoxGeometry(S*2+1.6,.8,1.2),M.metal,0,ya,-S);add(new T.BoxGeometry(1.2,.8,S*2+1.6),M.metal,S,ya,0);add(new T.BoxGeometry(1.2,.8,S*2+1.6),M.metal,-S,ya,0);}
  /* núcleo de energia (a única área de brilho grande da torre, protegida pela treliça) */
  add(new T.CylinderGeometry(2.6,2.6,30,6),M.cristal,0,74,0);const core=add(new T.CylinderGeometry(.7,.7,31,6),M.energia,0,74,0);core.castShadow=false;
  [64,74,84].forEach(y=>{const c=add(new T.TorusGeometry(8.8,.75,8,28),M.cobre,0,y,0);c.rotation.x=Math.PI/2;});
  /* 4. plataforma do topo, cúpula de cobre envelhecido, anemômetro e agulha */
  add(new T.CylinderGeometry(12.5,10,4,12),M.metalEscuro,0,95,0);
  add(new T.TorusGeometry(12.2,.28,5,24),M.metal,0,99,0).rotation.x=Math.PI/2;
  for(let i=0;i<16;i++){const a=i/16*Math.PI*2;add(new T.CylinderGeometry(.2,.2,3,4),M.metal,Math.sin(a)*12.2,98,Math.cos(a)*12.2).castShadow=false;}
  const dome=add(new T.SphereGeometry(8.5,12,6,0,Math.PI*2,0,Math.PI/2),M.patina,0,97,0);
  for(let i=0;i<6;i++){const rib=add(new T.TorusGeometry(8.65,.28,4,14,Math.PI),M.cobre,0,97,0);rib.rotation.y=i/6*Math.PI;}/* nervuras: meridianos sobre a cúpula */
  const spire=add(new T.CylinderGeometry(.35,1.4,28,6),M.metal,0,119,0);
  [110,116,122].forEach((y,i)=>{const c=add(new T.TorusGeometry(2.2-i*.45,.35,6,16),M.cobre,0,y,0);c.rotation.x=Math.PI/2;});
  const tip=add(new T.SphereGeometry(.9,10,8),M.energia,0,133.4,0);tip.castShadow=false;tip.name='PontaParaRaios';
  /* para-raios secundários na sacada (alvos do puzzle STORM.PUZZLE.TOWER) */
  for(let i=0;i<4;i++){const a=i/4*Math.PI*2+Math.PI/4;const x=Math.sin(a)*16,z=Math.cos(a)*16;add(new T.CylinderGeometry(.18,.5,10,5),M.metal,x,62.6,z);
    const b=add(new T.SphereGeometry(.55,8,6),M.cobre,x,67.8,z);b.name='ParaRaiosSecundario'+i;}
  /* anemômetro e cata-vento: peças animadas separadas (no Roblox: girar no cliente) */
  const anem=new T.Group();anem.name='Anemometro';anem.position.set(4.2,104,0);tw.add(anem);anem.userData.animated=true;
  MM.mesh(new T.CylinderGeometry(.25,.25,6,5),M.metal,0,-1,0,anem);
  for(let i=0;i<3;i++){const a=i/3*Math.PI*2;const arm=MM.mesh(new T.CylinderGeometry(.14,.14,4,4),M.metal,Math.sin(a)*2,2,Math.cos(a)*2,anem);arm.rotation.set(Math.PI/2,0,-a,'YXZ');arm.rotation.set(0,a,0);arm.rotateX(Math.PI/2);
    const cup=MM.mesh(new T.SphereGeometry(.8,8,6,0,Math.PI*2,0,Math.PI/2),M.cobre,Math.sin(a)*4,2,Math.cos(a)*4,anem);cup.rotation.set(0,a,Math.PI/2);}
  const vane=new T.Group();vane.name='CataVento';vane.position.set(-4,103,0);tw.add(vane);vane.userData.animated=true;
  MM.mesh(new T.CylinderGeometry(.2,.2,5,5),M.metal,0,0,0,vane);const ar=MM.mesh(new T.ConeGeometry(.9,3,4),M.cobre,0,2.6,1.6,vane);ar.rotation.x=Math.PI/2;MM.mesh(new T.BoxGeometry(.2,2,3),M.cobre,0,2.6,-1.8,vane);
  /* colisores: base, fuste, sacada */
  MM.box(tw,0,6,0,52,12,52);MM.box(tw,0,34,0,30,44,30);MM.box(tw,0,74,0,15,36,15);MM.box(tw,0,97,0,24,8,24);
  tw.userData.anim={anem,vane};tw.userData.tip=new T.Vector3(P.x,y0+133.4,P.z);tw.userData.coils=[64,74,84].map(y=>new T.Vector3(P.x,y0+y,P.z));
  return[tw];};
})();
