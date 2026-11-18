/* Ilha das Tempestades · Props
   Rochas únicas, linha de transmissão (torres de treliça + cabos), doca de chegada com arco do portal, mirante do Penhasco das Nuvens,
   ruínas tecnológicas e as rochas que escondem a passagem para o santuário. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
function pylon(ctx,id,name,x,z,h){const M=ctx.mat;const o=MM.obj(id,name,'Props',{notes:'Torre de treliça da linha de transmissão.'});const y=ctx.heightAt(x,z);o.position.set(x,y,z);
  const legs=[[-2.6,-2.6],[2.6,-2.6],[-2.6,2.6],[2.6,2.6]];legs.forEach(([a,b])=>{const L=new T.Vector3(a*.35,h,b*.35).sub(new T.Vector3(a,0,b));const m=MM.mesh(new T.CylinderGeometry(.18,.24,L.length(),4),M.metalEscuro,a*.675,h/2,b*.675,o);m.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),L.normalize());});
  for(let k=1;k<4;k++){const yy=k*h/4;const s=2.6*(1-k/4*.65);MM.mesh(new T.BoxGeometry(s*2,.25,.25),M.metal,0,yy,s,o);MM.mesh(new T.BoxGeometry(s*2,.25,.25),M.metal,0,yy,-s,o);MM.mesh(new T.BoxGeometry(.25,.25,s*2),M.metal,s,yy,0,o);MM.mesh(new T.BoxGeometry(.25,.25,s*2),M.metal,-s,yy,0,o);}
  MM.mesh(new T.BoxGeometry(9,.5,.6),M.metal,0,h,0,o);[-4,4].forEach(xx=>MM.mesh(new T.CylinderGeometry(.35,.35,1.2,6),M.patina,xx,h-.6,0,o));
  legs.forEach(([a,b])=>{const gl=Math.min(ctx.heightAt(x+a,z+b),ctx.heightAt(x+a*1.15,z+b*1.15))-y;const hh=Math.max(1.2,.5-gl+.8);MM.mesh(new T.BoxGeometry(1.3,hh,1.3),M.metalEscuro,a,.5-hh/2,b,o).userData.apoio=true;});/* V2.3.2: sapata de ferro fundido na base REAL de cada perna inclinada (a,b)=±2,6; na V2.3.1 ficava em ±1,75, solta ao lado */
  MM.box(o,0,h/2,0,5.4,h,5.4);o.userData.arms=[new T.Vector3(-4,h-1.1,0),new T.Vector3(4,h-1.1,0)];return o;}
I.buildProps=function(ctx){const M=ctx.mat,P=I.poi,out=[];const r=MM.rng(1212);
  /* rochas únicas espalhadas fora dos caminhos */
  const rk=MM.obj('STORM.PROP.ROCKS','Rochas da ilha','Props',{notes:'Cada rocha tem forma própria (semente diferente). No Roblox: 3–4 malhas base reaproveitadas com escala e rotação.'});
  for(let i=0,n=0;i<500&&n<44;i++){const x=-260+r()*520,z=-200+r()*400;if(!ctx.inside(x,z)||ctx.pathDist(x,z)<6)continue;if(Math.hypot(x-P.vila.x,z-P.vila.z)<P.vila.r-4)continue;if(Math.hypot(x-P.torre.x,z-P.torre.z)<34||Math.hypot(x-P.torre.x,z-P.torre.z-36)<18)continue;
    if(ctx.heightAt(x,z)<2)continue;const s=1.5+r()*r()*7;const sx=s*(1+r()*.6),sy=s*(.6+r()*.6),sz=s*(1+r()*.5);const R=Math.max(sx,sz)*.9;const y=Math.min(...[[0,0],[R,0],[-R,0],[0,R],[0,-R]].map(([a,b])=>ctx.heightAt(x+a,z+b)));/* ponto mais baixo sob a rocha, não o centro */const rot=r()*6;n++;/* Mapa V1: nada diante do pórtico da caverna (a rocha atravessava o contraforte); o sorteio das demais continua igual */if(Math.abs(x-P.caverna.boca.x)<27&&z>-112&&z<-88)continue;const m=MM.mesh(MM.rockGeo(3000+i,sx,sy,sz,2),ctx.rockMat,x,y+sy*.2,z,rk);m.rotation.y=rot;}
  out.push(rk);
  /* rochas altas que escondem a passagem secreta (fresta de 8 studs: STORM.HIDDEN.01) */
  const hid=MM.obj('STORM.PROP.SECRET.ROCKS','Rochas da passagem oculta','Props',{notes:'A fresta entre elas é a entrada da trilha secreta. Colisão nas rochas; vão livre de 8 studs.'});
  I.rochasSecretas/* V2.3.1: as rochas ficavam EM CIMA da trilha secreta P5 (vão real ≈1,4 stud); agora flanqueiam a trilha com ≈9 studs livres */.forEach(([x,z,s],i)=>{const R=s*.75;const y=Math.min(...[[0,0],[R,0],[-R,0],[0,R],[0,-R],[R*.7,R*.7],[-R*.7,-R*.7],[R*.7,-R*.7],[-R*.7,R*.7]].map(([a,b])=>ctx.heightAt(x+a,z+b)));/* V2.3.1: base achatada da rocha (−0,35 × altura) 0,4 abaixo do ponto mais baixo do chão (antes: centro + 0,6 × tamanho, rochas no ar) */
    const cy=y+s*1.4*.35-1.5;MM.mesh(MM.rockGeo(70+i,s*.8,s*1.4,s*.8,2),ctx.rockMat,x,cy,z,hid);MM.box(hid,x,cy,z,s*1.4,s*2.6,s*1.4);});
  out.push(hid);
  /* doca de chegada e arco do portal (Mapa V1): praça de pedra lavrada com rosa-dos-ventos de cobre no spawn, alicerce até o chão real
     na borda do penhasco, balaustrada, postes de luz, placa de direções e bagagens; portal em anel de aduelas de pedra sobre um estrado
     de dois degraus, entre pilares com bobinas de cobre, entablamento, cristais e para-raios. O anel de energia continua 'AnelPortal'. */
  {const C=P.chegada,K=I.houseMats(ctx),BB=MM.bevelBox;const o=MM.obj('STORM.ARCH.ARRIVAL','Doca de chegada e arco do portal','Architecture',{notes:'Área inicial (STORM.SPAWN.01) e portal de volta (STORM.PORTAL.01). Praça 30 × 26 studs com balaustrada no lado do penhasco. Portal: anel de pedra de 18,8 studs sobre estrado, vão de energia de 12 studs.'});o.position.set(C.x,C.h,C.z);
    const add=(g,m,x,y,z,p)=>MM.mesh(g,m,x,y,z,p||o);const vg=(ri,ro,a0,a1,cy,t)=>{const s=new T.Shape();const Pt=(r,a)=>[Math.cos(a)*r,cy+Math.sin(a)*r];s.moveTo(...Pt(ri,a0));for(let i=0;i<=4;i++)s.lineTo(...Pt(ro,a0+(a1-a0)*i/4));for(let i=4;i>=0;i--)s.lineTo(...Pt(ri,a0+(a1-a0)*i/4));const g=new T.ExtrudeGeometry(s,{depth:t,bevelEnabled:true,bevelSize:.07,bevelThickness:.07,bevelSegments:1});g.translate(0,0,-t/2);return g;};
    /* piso: laje de 30 × 26 (topo em +0,1) com meio-fio de pedra lavrada e juntas de lajes */
    add(BB(30,2,26,.15),K.cant,0,-.9,6).userData.apoio=true;add(BB(28.4,.12,24.4,.05),K.lav,0,.1,6).castShadow=false;
    for(let i=-6;i<=6;i++)add(new T.BoxGeometry(.12,.03,24.2),K.cant,i*2.2,.17,6).castShadow=false;for(let j=0;j<11;j++)add(new T.BoxGeometry(28.2,.03,.12),K.cant,0,.17,-5.6+j*2.25).castShadow=false;/* juntas das lajes */
    [[0,-6.6,30.2,.9],[0,18.6,30.2,.9]].forEach(([x,z,a,c])=>add(BB(a,.4,c,.08),K.lav,x,.25,z));[-1,1].forEach(s=>add(BB(.9,.4,26,.08),K.lav,s*14.6,.25,6));
    /* rosa-dos-ventos de cobre no ponto de chegada */
    {const z0=-2;add(new T.TorusGeometry(3.6,.12,6,40),K.copper,0,.2,z0).rotation.x=Math.PI/2;add(new T.TorusGeometry(2.4,.08,6,32),K.copper,0,.2,z0).rotation.x=Math.PI/2;
      for(let i=0;i<8;i++){const a=i/8*Math.PI*2,L=i%2?2.2:3.4;const st=add(new T.BoxGeometry(.16,.06,L),K.copper,Math.sin(a)*L/2,.2,z0+Math.cos(a)*L/2);st.rotation.y=a;st.castShadow=false;}
      add(new T.CylinderGeometry(.5,.5,.08,12),M.energia,0,.2,z0).castShadow=false;}
    /* alicerce: onde o chão desce (borda do penhasco), paredes de cantaria do fundo da laje até o chão real */
    {const seg=(x0,z0,x1,z1)=>{const n=Math.max(1,Math.round(Math.hypot(x1-x0,z1-z0)/5));for(let i=0;i<n;i++){const ax=x0+(x1-x0)*i/n,az=z0+(z1-z0)*i/n,bx=x0+(x1-x0)*(i+1)/n,bz=z0+(z1-z0)*(i+1)/n;
        const g=Math.min(...[0,.5,1].map(t=>ctx.heightAt(C.x+ax+(bx-ax)*t,C.z+az+(bz-az)*t)))-C.h;if(g>-1.7)continue;const top=-1.6,bot=g-.8;const L=Math.hypot(bx-ax,bz-az)+.6;
        const w=add(BB(L,top-bot,1.4,.1),K.cant,(ax+bx)/2,(top+bot)/2,(az+bz)/2);w.rotation.y=Math.atan2(bz-az,bx-ax)*-1;w.userData.apoio=true;}};
      seg(-15,19,15,19);seg(-15,-7,-15,19);seg(15,-7,15,19);seg(-15,-7,15,-7);}
    /* balaustrada no lado do penhasco (fundo e metade sul das laterais) */
    {const bal=(x0,z0,x1,z1)=>{const L=Math.hypot(x1-x0,z1-z0),ry=-Math.atan2(z1-z0,x1-x0);const cx=(x0+x1)/2,cz=(z0+z1)/2;const g=new T.Group();g.position.set(cx,0,cz);g.rotation.y=ry;o.add(g);
        add(BB(L,.4,.9,.06),K.lav,0,.65,0,g);add(BB(L+.2,.35,1,.08),K.lav,0,3.05,0,g);const n=Math.round(L/1.1);for(let i=0;i<=n;i++){const u=-L/2+i*L/n;add(new T.CylinderGeometry(.22,.3,2.0,8),K.lav,u,1.85,0,g);}
        for(let u=-L/2;u<=L/2+.01;u+=L/Math.max(1,Math.round(L/6)))add(BB(1,3.4,1,.08),K.cant,u,1.7,0,g);MM.box(o,cx,1.6,cz,L,3.2,1,ry);};
      bal(-14.6,18.6,-11.5,18.6);bal(11.5,18.6,14.6,18.6);bal(-14.6,6.5,-14.6,18.6);bal(14.6,6.5,14.6,18.6);}
    /* estrado do portal (2 degraus de 0,5) */
    add(BB(23,.5,7.4,.08),K.lav,0,.35,15.2);add(BB(19.6,.5,5.6,.08),K.lav,0,.85,15.2);MM.box(o,0,.55,15.2,23,1.1,7.4);
    /* pilares: base, fuste de cantaria com cintas de cobre, bobina em espiral, capitel */
    [-1,1].forEach(s=>{const x=s*9.6;add(BB(4.8,1.6,4.8,.12),K.lav,x,1.9,14);add(BB(3.4,15,3.4,.12),K.cant,x,10.2,14);[5.2,11,16.4].forEach(y=>add(BB(3.7,.35,3.7,.05),K.copper,x,y,14));
      add(BB(4.6,1.2,4.6,.1),K.lav,x,18.3,14);
      const hp=[];for(let i=0;i<=120;i++){const t=i/120,a=t*Math.PI*2*6;hp.push(new T.Vector3(x+Math.cos(a)*2.35,6.2+t*4.2,14+Math.sin(a)*2.35));}const hc=new T.Mesh(new T.TubeGeometry(new T.CatmullRomCurve3(hp),240,.12,5,false),K.copper);hc.castShadow=true;o.add(hc);
      MM.box(o,x,9.5,14,4.8,19,4.8);});
    /* anel de aduelas (20) em pé sobre o estrado, fecho com o emblema da tempestade */
    {const cy=10.5,ri=7.2,ro=9.4,N=20,off=Math.PI/2-Math.PI/N;for(let i=0;i<N;i++){if(i===0)continue;const a0=off+i/N*Math.PI*2,a1=off+(i+1)/N*Math.PI*2;add(vg(ri,ro,a0+.01,a1-.01,cy,2.6),i%2?K.lav:K.cant,0,0,14);}
      add(vg(ri-.2,ro+.5,off+.01,off+Math.PI*2/N-.01,cy,3.2),K.lav,0,0,14);/* fecho */
      for(let i=0;i<12;i++){const a=i/12*Math.PI*2;const rn=add(new T.BoxGeometry(.25,.9,.12),K.copper,Math.cos(a)*6.7,cy+Math.sin(a)*6.7,15.36);rn.rotation.z=a-Math.PI/2;rn.castShadow=false;const rb=add(new T.BoxGeometry(.25,.9,.12),K.copper,Math.cos(a)*6.7,cy+Math.sin(a)*6.7,12.64);rb.rotation.z=a-Math.PI/2;rb.castShadow=false;}
      const ring=add(new T.TorusGeometry(6,.25,6,48),M.energia,0,cy,14.2);ring.castShadow=false;ring.name='AnelPortal';
      const r2=add(new T.TorusGeometry(5.3,.1,4,48),M.energia,0,cy,14);r2.castShadow=false;
      for(let i=0;i<8;i++){const a=i/8*Math.PI*2+.2;const cr=add(MM.crystalGeo(.18,.5,.45),M.cristal,Math.cos(a)*7.05,cy+Math.sin(a)*7.05,14);cr.rotation.z=a+Math.PI/2;cr.castShadow=false;}
      const em=new T.Group();em.position.set(0,cy+ri+1.1,15.85);o.add(em);add(new T.TorusGeometry(1.1,.16,8,24),K.copper,0,0,0,em);add(new T.CylinderGeometry(.95,.95,.12,20),K.iron,0,0,-.08,em).rotation.x=Math.PI/2;
      const s=new T.Shape();[[.35,1.6],[-.45,.1],[.05,.1],[-.35,-1.6],[.55,-.05],[.05,-.05],[.35,1.6]].forEach((p,i)=>i?s.lineTo(p[0],p[1]):s.moveTo(p[0],p[1]));const bo=add(new T.ExtrudeGeometry(s,{depth:.25,bevelEnabled:false}),K.copper,0,0,0,em);bo.scale.set(.52,.52,1);}
    /* entablamento sobre os pilares, cristais e para-raios */
    add(BB(25,1.8,3,.12),K.lav,0,19.8,13.9);add(BB(26,.45,3.6,.08),K.lav,0,20.9,13.9);add(BB(14,1.2,2.6,.1),K.cant,0,21.7,13.9);add(BB(14.6,.35,3,.06),K.lav,0,22.45,13.9);
    [-1,1].forEach(s=>{const x=s*9.6;add(new T.CylinderGeometry(.42,.5,.5,8),K.copper,x,21.4,14);add(new T.CylinderGeometry(.18,.3,4.2,6),K.iron,x,23.3,14);[22.3,23.4].forEach(y=>add(new T.TorusGeometry(.55,.15,5,12),K.copper,x,y,14).rotation.x=Math.PI/2);add(new T.SphereGeometry(.5,10,8),K.copper,x,25.5,14);
      [[.9,.3,1.6,.3],[-.7,-.4,1.1,-.4],[.2,.9,1.3,.1]].forEach(([dx,dz,h,tl],i)=>{const c=add(MM.crystalGeo(.32,h,.6),M.cristal,x+dx*1.2,21.1,14+dz*1.2);c.rotation.set(tl,i,-tl);c.castShadow=false;});});
    /* postes de luz nos cantos da praça */
    [[-13,-5],[13,-5],[-13,9],[13,9]].forEach(([x,z])=>{add(new T.CylinderGeometry(.5,.65,.6,8),K.iron,x,.4,z);add(new T.CylinderGeometry(.16,.22,6.4,8),K.iron,x,3.6,z);add(new T.BoxGeometry(1.4,.18,.18),K.iron,x,6.6,z);
      const gl=add(new T.CylinderGeometry(.34,.42,1,6),K.glass,x,6.95,z);gl.castShadow=false;add(new T.ConeGeometry(.55,.5,6),K.iron,x,7.7,z);MM.box(o,x,3.4,z,.7,6.8,.7);});
    /* placa de direções (mesmo lugar da placa antiga) */
    {const x=-12,z=-4.6;add(new T.CylinderGeometry(.22,.26,6.2,8),K.woodD,x,3.2,z);add(new T.ConeGeometry(.35,.5,8),K.iron,x,6.55,z);
      [[5.4,.35,'N'],[4.1,2.4,'L'],[2.9,-2.1,'O']].forEach(([y,ry])=>{const g=new T.Group();g.position.set(x,y,z);g.rotation.y=ry;o.add(g);const sh=new T.Shape();sh.moveTo(0,-.35);sh.lineTo(2.6,-.35);sh.lineTo(3.1,0);sh.lineTo(2.6,.35);sh.lineTo(0,.35);sh.lineTo(0,-.35);
        add(new T.ExtrudeGeometry(sh,{depth:.16,bevelEnabled:false}),K.woodD,.15,0,-.08,g);add(new T.BoxGeometry(2.2,.08,.04),K.copper,1.4,.12,.1,g);add(new T.BoxGeometry(1.6,.08,.04),K.copper,1.2,-.1,.1,g);});
      MM.box(o,x,3.1,z,.6,6.2,.6);}
    /* bagagens de quem chega: baús e barris junto ao lado oeste */
    [[-10.2,2.6,1.8,1.3,1.3,.2],[-10.6,4.6,1.5,1.1,1.1,-.3],[-10.2,2.6,1.1,.9,.9,.5,1.3]].forEach(([x,z,a,b,c,ry,yo])=>{const g=new T.Group();g.position.set(x,.1+(yo||0),z);g.rotation.y=ry;o.add(g);add(BB(a,b,c,.06),K.woodD,0,b/2,0,g);[-1,1].forEach(s=>add(new T.BoxGeometry(.12,b+.04,c+.04),K.iron,s*a*.3,b/2,0,g));});
    [[-12.4,1.4],[-12.8,3.1]].forEach(([x,z])=>{add(new T.CylinderGeometry(.6,.6,1.6,10),K.woodD,x,.9,z);[.45,1.35].forEach(y=>add(new T.CylinderGeometry(.63,.63,.12,10),K.iron,x,y,z));});
    MM.box(o,-11.3,1,3,4,2,4.6);
    o.userData.walk=[{type:'rect',y:C.h+.1,x:C.x,z:C.z+6,sx:30,sz:26}];out.push(o);}
  /* mirante do Penhasco das Nuvens: deck de metal em balanço sobre o vazio */
  {const C=P.penhasco;const o=MM.obj('STORM.ARCH.CLIFF.LOOKOUT','Mirante do Penhasco das Nuvens','Architecture',{notes:'Deck caminhável em balanço (16 × 10 studs). Fragmentos de nuvem: STORM.COLLECT.02.'});o.userData.flutua='balanço intencional sobre o penhasco (escorado)';const x=C.x+6,z=C.z;const y=ctx.heightAt(C.x,C.z);o.position.set(x,y,z);o.rotation.y=-Math.PI/2+.35;
    MM.mesh(new T.BoxGeometry(10,.8,18),M.metalEscuro,0,.4,8,o);for(let i=0;i<6;i++)MM.mesh(new T.BoxGeometry(10,.15,.3),M.metal,0,.85,2+i*2.6,o);
    [-5,5].forEach(xx=>{MM.mesh(new T.BoxGeometry(.3,3.4,18),M.metal,xx,2.1,8,o);const st=MM.mesh(new T.BoxGeometry(.6,.6,13),M.metal,xx,-4,6,o);st.rotation.x=.55;});
    MM.mesh(new T.BoxGeometry(10,3.4,.3),M.metal,0,2.1,17,o);const sc=MM.mesh(new T.CylinderGeometry(.5,.8,3,6),M.cobre,2,2.3,14,o);
    const tl=MM.mesh(new T.CylinderGeometry(.5,.6,4,8),M.cobre,2,4.2,14.6,o);tl.rotation.x=1.1;
    MM.box(o,0,.4,8,10,.8,18);out.push(o);o.updateMatrixWorld(true);const c0=o.localToWorld(new T.Vector3(0,0,8));o.userData.walk=[{type:'rect',y:y+.8,x:c0.x,z:c0.z,sx:13,sz:13}];}
  /* linha de transmissão: torre → vila → estrada do penhasco */
  {const T0=P.torre;/* V2.3.1: torre de transmissão nunca na frente de porta nem colada em casa (antes a 3ª ficava na porta da casa 3) */
    /* V2.3.2: cada torre vai para o ponto livre mais próximo do planejado, testando também o VÃO do cabo até a torre anterior
       (na V2.3.1 só a torre era testada e o cabo 2→3 passava por dentro da casa 3) */
    const casas=ctx.reg.list.filter(o=>o.userData.foot);const segD=(px,pz,ax,az,bx,bz)=>MM.segDist(px,pz,ax,az,bx,bz).d;
    const livre=(x,z,prev)=>!casas.some(o=>{const f=o.userData.foot,c=Math.cos(o.rotation.y),s=Math.sin(o.rotation.y);const fx=o.position.x+(f.d/2+5)*s,fz=o.position.z+(f.d/2+5)*c;return Math.hypot(fx-x,fz-z)<10||Math.hypot(o.position.x-x,o.position.z-z)<15||(prev&&segD(o.position.x,o.position.z,prev[0],prev[1],x,z)<14);})&&ctx.pathDist(x,z)>3;
    const pts=[];I.linhaTransmissao.forEach(([x0,z0])=>{const prev=pts[pts.length-1];let best=[x0,z0];search:for(let rr=0;rr<=40;rr+=2)for(let k=0;k<(rr?16:1);k++){const a=k/16*6.283;const x=x0+Math.cos(a)*rr,z=z0+Math.sin(a)*rr;if(livre(x,z,prev)){best=[x,z];break search;}}pts.push(best);});const line=MM.obj('STORM.PROP.POWERLINE','Linha de transmissão','Props',{notes:'Cabos visuais. No Roblox: Beam entre Attachments.'});line.userData.ancoras=pts.map((p,i)=>'STORM.PROP.PYLON.0'+(i+1));
    const pyl=pts.map(([x,z],i)=>{const p=pylon(ctx,'STORM.PROP.PYLON.0'+(i+1),'Torre de transmissão '+(i+1),x,z,20+(i%2)*3);out.push(p);return p;});
    for(let i=0;i<pyl.length-1;i++){const a=pyl[i],b=pyl[i+1];a.updateMatrixWorld(true);b.updateMatrixWorld(true);for(let k=0;k<2;k++){const A=a.localToWorld(a.userData.arms[k].clone()),B=b.localToWorld(b.userData.arms[k].clone());line.add(MM.tube(MM.catenary(A,B,3.5,20),.1,M.metalEscuro,24,3));}}
    out.push(line);}
  /* ruínas tecnológicas */
  const lay=(geo,mat,x,z,yaw,len,rad,parent)=>{const dx=Math.sin(yaw)*len/2,dz=Math.cos(yaw)*len/2;const A=new T.Vector3(x-dx,ctx.heightAt(x-dx,z-dz)+rad*.7,z-dz),B=new T.Vector3(x+dx,ctx.heightAt(x+dx,z+dz)+rad*.7,z+dz);
    /* reta ajustada ao chão ao longo da peça e rebaixada até nenhum trecho ficar acima do chão (fica semienterrada nas partes altas) */
    const N=9,S=[];for(let i=0;i<N;i++){const t=i/(N-1)-.5;S.push([t,ctx.heightAt(x+2*dx*t,z+2*dz*t)]);}const mt=S.reduce((a,s)=>a+s[0],0)/N,mg=S.reduce((a,s)=>a+s[1],0)/N;const k=S.reduce((a,s)=>a+(s[0]-mt)*(s[1]-mg),0)/S.reduce((a,s)=>a+(s[0]-mt)**2,0);
    let c=mg;const over=Math.max(...S.map(([t,g])=>(c+k*t)-g));c-=Math.max(0,over-rad*.15);A.y=c-k*.5+rad*.85;B.y=c+k*.5+rad*.85;
    const m=MM.mesh(geo,mat,(A.x+B.x)/2,(A.y+B.y)/2,(A.z+B.z)/2,parent);m.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),B.clone().sub(A).normalize());m.userData.apoio=true;return m;};
  const ru=MM.obj('STORM.PROP.RUINS','Ruínas tecnológicas','Props',{notes:'Anel de bobina caído, torre tombada e placas de metal semienterradas.'});
  {let x=-92,z=-24,y=ctx.heightAt(x,z);const ring=MM.mesh(new T.TorusGeometry(7,.9,8,30),M.cobre,x,y+2.2,z,ru);ring.rotation.set(1.2,.4,.2);ring.updateMatrixWorld();
    {/* anel encostado no chão pelo ponto mais baixo real */let low=1e9;const pa=ring.geometry.attributes.position,v=new T.Vector3();for(let q=0;q<pa.count;q+=3){v.fromBufferAttribute(pa,q).applyMatrix4(ring.matrixWorld);low=Math.min(low,v.y-ctx.heightAt(v.x,v.z));}ring.position.y-=low+.35;ring.userData.semApoio=true;}/* V2.3.2: assentado pelo ponto mais baixo real; o lado de dentro do aro (sobre o vazio do anel) não é base */
    lay(new T.CylinderGeometry(1,1.2,9,8),M.metalEscuro,x+5,z+3,1.1,9,1.2,ru);
    x=118;z=-30;y=ctx.heightAt(x,z);lay(new T.BoxGeometry(2.4,22,2.4),M.metalEscuro,x,z,1.97,22,1.2,ru);for(let i=0;i<4;i++){const xx=x-8+i*4.5,zz=z+.3*i;lay(new T.BoxGeometry(.25,5,.25),M.metal,xx,zz,.4+Math.PI/2,5,.15,ru);}/* V2.3.2: barras deitadas no chão pelos dois extremos (antes só pelo centro) */
    for(let i=0;i<6;i++){const xx=60+r()*40,zz=-60+r()*30;if(ctx.pathDist(xx,zz)<5)continue;const sx=4+r()*4,sz=3+r()*3,R=Math.max(sx,sz)/2;const gm=Math.min(...[[0,0],[R,0],[-R,0],[0,R],[0,-R]].map(([a,b])=>ctx.heightAt(xx+a,zz+b)));const pl=MM.mesh(new T.BoxGeometry(sx,.35,sz),M.metal,xx,gm+.25,zz,ru);pl.rotation.set((r()-.5)*.12,r()*3,(r()-.5)*.12);pl.userData.apoio=true;}}
  out.push(ru);
  return out;};
})();
