/* Ilha das Tempestades · Architecture · Caverna do Trovão
   Arco de aduelas na boca (o terreno é vazado ali), túnel de 15 studs de largura e câmara com a mina STORM.MINE.02
   e a bobina antiga STORM.EQUIP.01. O interior é renderizado pelo lado de dentro (BackSide). */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
I.buildCave=function(ctx){const M=ctx.mat,b=I.poi.caverna.boca;const out=[];const y=26;
  const arch=MM.obj('STORM.ARCH.CAVE.MOUTH','Boca da Caverna do Trovão','Architecture',{notes:'Vão 19 × 15 studs. Aduelas de pedra com placas de metal rebitado.'});arch.position.set(b.x,y,b.z+1);
  for(let k=0;k<=12;k++){const a=Math.PI*k/12;const v=MM.mesh(new T.BoxGeometry(3.2,3.4,4.6),k%3===0?M.metalEscuro:M.pedraClara,Math.cos(a)*10.6,8+Math.sin(a)*8.4,0,arch);v.rotation.z=a-Math.PI/2;v.userData.semApoio=true;/* aduela: apoiada pelo arco e pelas ombreiras, não pelo chão */}
  [-10.6,10.6].forEach(x=>{MM.mesh(new T.BoxGeometry(3.4,8.4,4.8),M.pedraClara,x,4.2,0,arch);MM.mesh(new T.CylinderGeometry(.3,.3,7,6),M.metal,x*1.12,11,2.6,arch);});
  MM.mesh(new T.BoxGeometry(9,1.2,.6),M.metalEscuro,0,17.5,2.4,arch);
  /* V2.3.2 — pórtico encaixado no paredão: muros de arrimo laterais e verga de pedra que entram no corte do terreno e fecham as frestas
     entre o arco e a rocha (antes o arco era um bloco solto diante de um corte retangular, com o tubo do túnel exposto pelos lados) */
  [-1,1].forEach(sd=>{const w=MM.mesh(MM.bevelBox(6.4,23,12.5,.3),M.pedra,sd*15.3,10.3,-3.9,arch);w.userData.apoio=true;MM.mesh(MM.bevelBox(7.2,1.2,13.2,.2),M.pedraClara,sd*15.3,21.9,-3.9,arch);MM.box(arch,sd*15.3,10.3,-3.9,6.4,23,12.5);});
  MM.mesh(MM.bevelBox(37,7.5,12.5,.3),M.pedra,0,20.6,-3.9,arch);MM.mesh(MM.bevelBox(38,1,13.2,.2),M.pedraClara,0,24.8,-3.9,arch);
  MM.box(arch,-10.6,8,0,3.4,17,4.8);MM.box(arch,10.6,8,0,3.4,17,4.8);out.push(arch);
  /* túnel e câmara */
  const tun=MM.obj('STORM.ARCH.CAVE.TUNNEL','Túnel e câmara da caverna','Architecture',{notes:'Chão plano caminhável; teto alto o bastante para pular (≥ 12 studs).'});
  const curve=new T.CatmullRomCurve3([new T.Vector3(b.x,y+7,b.z+2),new T.Vector3(b.x+2,y+7.5,b.z-16),new T.Vector3(b.x-3,y+8,b.z-32),new T.Vector3(-150,y+8.5,-140)]);
  const tg=new T.TubeGeometry(curve,48,8,12,false);{const p=tg.attributes.position;for(let i=0;i<p.count;i++){const n=MM.noise2(p.getX(i)*.35,p.getY(i)*.35+p.getZ(i)*.2,4);p.setXYZ(i,p.getX(i)+n*.9,p.getY(i)+n*.6,p.getZ(i));}tg.computeVertexNormals();}
  const tm=new T.Mesh(tg,M.pedraEscura.clone());tm.material.side=T.BackSide;tm.material.name='PedraEscuraInterna';tm.receiveShadow=true;tun.add(tm);
  const pts=curve.getPoints(40);for(let i=0;i<pts.length-1;i++){const a=pts[i],c=pts[i+1];const L=a.distanceTo(c);const fl=MM.mesh(new T.BoxGeometry(12,1,L+.4),M.pedra,(a.x+c.x)/2,y+.0,(a.z+c.z)/2,tun);fl.rotation.y=Math.atan2(c.x-a.x,c.z-a.z);}
  const ch=new T.Mesh(new T.SphereGeometry(19,20,14),M.pedraEscura.clone());ch.material.side=T.BackSide;ch.scale.set(1,.72,1.1);ch.position.set(-150,y+8,-152);tun.add(ch);
  MM.mesh(new T.CylinderGeometry(17,17,1,24),M.pedra,-150,y,-152,tun);
  /* estalactites */
  const r=MM.rng(31);for(let i=0;i<16;i++){const a=r()*Math.PI*2,rr=r()*14;const cn=MM.mesh(new T.ConeGeometry(.8+r()*1.4,3+r()*5,6),M.pedraEscura,-150+Math.cos(a)*rr,y+19-r()*2,-152+Math.sin(a)*rr,tun);cn.rotation.x=Math.PI;}
  tun.userData.walk=[{type:'flat',y:y+.5,pts:pts.map(p=>[p.x,p.z]),hw:6},{type:'disc',y:y+.5,x:-150,z:-152,r:16}];out.push(tun);
  /* bobina antiga (equipamento secreto) */
  const eq=MM.obj('STORM.EQUIP.01.MODEL','Bobina antiga (equipamento secreto)','Props',{notes:'Marcador STORM.EQUIP.01. Mecânica ainda não implementada.'});eq.position.set(-156,y,-163);
  MM.mesh(new T.CylinderGeometry(2.4,2.8,1.2,10),M.metalEscuro,0,.6,0,eq);MM.mesh(new T.CylinderGeometry(.8,.8,6,8),M.metal,0,4,0,eq);
  for(let i=0;i<7;i++)MM.mesh(new T.TorusGeometry(1.6,.3,6,14),M.cobre,0,1.8+i*.7,0,eq).rotation.x=Math.PI/2;MM.mesh(new T.TorusGeometry(2.4,.4,6,18),M.metal,0,7.4,0,eq).rotation.x=Math.PI/2;
  MM.box(eq,0,3.5,0,5.6,7,5.6);out.push(eq);
  return out;};
})();
