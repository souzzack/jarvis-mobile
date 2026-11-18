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
    if(ctx.heightAt(x,z)<2)continue;const s=1.5+r()*r()*7;const sx=s*(1+r()*.6),sy=s*(.6+r()*.6),sz=s*(1+r()*.5);const R=Math.max(sx,sz)*.9;const y=Math.min(...[[0,0],[R,0],[-R,0],[0,R],[0,-R]].map(([a,b])=>ctx.heightAt(x+a,z+b)));/* ponto mais baixo sob a rocha, não o centro */const m=MM.mesh(MM.rockGeo(3000+i,sx,sy,sz,2),ctx.rockMat,x,y+sy*.2,z,rk);m.rotation.y=r()*6;n++;}
  out.push(rk);
  /* rochas altas que escondem a passagem secreta (fresta de 8 studs: STORM.HIDDEN.01) */
  const hid=MM.obj('STORM.PROP.SECRET.ROCKS','Rochas da passagem oculta','Props',{notes:'A fresta entre elas é a entrada da trilha secreta. Colisão nas rochas; vão livre de 8 studs.'});
  I.rochasSecretas/* V2.3.1: as rochas ficavam EM CIMA da trilha secreta P5 (vão real ≈1,4 stud); agora flanqueiam a trilha com ≈9 studs livres */.forEach(([x,z,s],i)=>{const R=s*.75;const y=Math.min(...[[0,0],[R,0],[-R,0],[0,R],[0,-R],[R*.7,R*.7],[-R*.7,-R*.7],[R*.7,-R*.7],[-R*.7,R*.7]].map(([a,b])=>ctx.heightAt(x+a,z+b)));/* V2.3.1: base achatada da rocha (−0,35 × altura) 0,4 abaixo do ponto mais baixo do chão (antes: centro + 0,6 × tamanho, rochas no ar) */
    const cy=y+s*1.4*.35-1.5;MM.mesh(MM.rockGeo(70+i,s*.8,s*1.4,s*.8,2),ctx.rockMat,x,cy,z,hid);MM.box(hid,x,cy,z,s*1.4,s*2.6,s*1.4);});
  out.push(hid);
  /* doca de chegada e arco do portal */
  {const C=P.chegada;const o=MM.obj('STORM.ARCH.ARRIVAL','Doca de chegada e arco do portal','Architecture',{notes:'Área inicial (STORM.SPAWN.01) e arco do portal de volta (STORM.PORTAL.01). Vão do arco: 14 × 18 studs.'});o.position.set(C.x,C.h,C.z);
    MM.mesh(new T.BoxGeometry(30,2,26),M.pedraClara,0,-.9,6,o);for(let i=0;i<6;i++)MM.mesh(new T.BoxGeometry(30,.3,.4),M.pedraEscura,0,.12,-6+i*4.4,o);
    [-9,9].forEach(x=>{MM.mesh(new T.BoxGeometry(3.4,18,3.4),M.pedra,x,9,14,o);MM.mesh(new T.CylinderGeometry(.25,.25,6,5),M.metal,x,21,14,o);MM.mesh(new T.SphereGeometry(.5,8,6),M.cobre,x,24.2,14,o);});
    MM.mesh(new T.BoxGeometry(22,3,3.8),M.pedraClara,0,19.5,14,o);MM.mesh(new T.TorusGeometry(6.8,.5,6,24,Math.PI),M.cobre,0,10.5,14,o);
    const ring=MM.mesh(new T.TorusGeometry(6,.25,6,40),M.energia,0,10.5,14.2,o);ring.castShadow=false;ring.name='AnelPortal';
    MM.mesh(new T.BoxGeometry(1,4,.3),M.madeira,-12,2,-4,o);const sg=MM.mesh(new T.BoxGeometry(5,1.6,.3),M.madeira,-12,4,-4,o);sg.rotation.z=.08;
    MM.box(o,-9,9,14,3.4,18,3.4);MM.box(o,9,9,14,3.4,18,3.4);o.userData.walk=[{type:'rect',y:C.h+.1,x:C.x,z:C.z+6,sx:30,sz:26}];out.push(o);}
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
