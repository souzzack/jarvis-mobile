/* Ilha das Tempestades · Architecture · Vila dos Para-raios
   Casas geradas por variante (térreo de alvenaria com cunhais de pedra, andar de madeira enxaimel, telhado em duas águas,
   cônico ou de uma água, chaminé e para-raios com bobinas de cobre). Praça com o Coletor, oficina, barracas, lanternas e cabos. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
function gableGeo(w,d,h,over){const s=new T.Shape();s.moveTo(-w/2-over,0);s.lineTo(0,h);s.lineTo(w/2+over,0);s.lineTo(-w/2-over,0);const g=new T.ExtrudeGeometry(s,{depth:d+over*2,bevelEnabled:false});g.translate(0,0,-(d+over*2)/2);return g;}
function shedGeo(w,d,h1,h2,over){const s=new T.Shape();s.moveTo(-w/2-over,h1);s.lineTo(w/2+over,h2);s.lineTo(w/2+over,h2-.9);s.lineTo(-w/2-over,h1-.9);s.lineTo(-w/2-over,h1);const g=new T.ExtrudeGeometry(s,{depth:d+over*2,bevelEnabled:false});g.translate(0,0,-(d+over*2)/2);return g;}
I.buildHouse=function(ctx,id,name,opt){const M=ctx.mat,r=MM.rng(opt.seed);const g=MM.obj(id,name,'Architecture',{notes:'Casa da vila. Porta 4,5 × 8,5 studs. Para-raios com bobina no topo.'});
  const w=opt.w,d=opt.d,two=opt.floors>1,round=opt.roof==='cone';const add=(geo,m,x,y,z)=>MM.mesh(geo,m,x,y,z,g);
  add(new T.BoxGeometry(w+1.6,1.6,d+1.6),M.pedraClara,0,.8,0);
  let top;
  if(round){const R=w/2;add(new T.CylinderGeometry(R,R+.4,9,10),M.alvenaria,0,6.1,0);add(new T.TorusGeometry(R+.2,.35,5,10),M.metalEscuro,0,10.5,0).rotation.x=Math.PI/2;
    const roof=add(new T.ConeGeometry(R+2,10+r()*3,10),M.telhado,0,16,0);top=21+r()*1;roof.rotation.y=r();
    MM.box(g,0,6,0,R*2,10.6,R*2);}
  else{add(new T.BoxGeometry(w,8,d),M.alvenaria,0,5.6,0);
    [[-1,-1],[1,-1],[-1,1],[1,1]].forEach(([a,b])=>add(new T.BoxGeometry(1.4,8.4,1.4),M.pedra,a*(w/2-.3),5.8,b*(d/2-.3)));
    let yTop=9.6;
    if(two){const uw=w-.6,ud=d-.6;add(new T.BoxGeometry(uw,6.4,ud),M.madeira,0,12.8,0);add(new T.BoxGeometry(w+.6,.6,d+.6),M.madeira,0,9.8,0);
      for(let k=-1;k<=1;k+=2){add(new T.BoxGeometry(.5,6.4,.5),M.pedraEscura,k*uw/2,12.8,ud/2+.05);const br=add(new T.BoxGeometry(.4,7.6,.4),M.pedraEscura,k*uw/4,12.8,ud/2+.1);br.rotation.z=k*.62;}
      [-uw/4,uw/4].forEach(x=>add(new T.BoxGeometry(2.2,2.6,.3),M.vidro,x,13.3,ud/2+.2));yTop=16;}
    const rh=5+r()*3.5;
    if(opt.roof==='shed'){add(shedGeo(w,d,rh+1,1,1.2),M.telhado,0,yTop,0);top=yTop+rh+1;}
    else{const rf=add(opt.rot90?gableGeo(d,w,rh,1.3):gableGeo(w,d,rh,1.3),M.telhado,0,yTop,0);if(opt.rot90)rf.rotation.y=Math.PI/2;top=yTop+rh;}
    if(r()<.8){const ch=add(new T.BoxGeometry(2,6,2),M.pedra,w/2-2.6,yTop+rh*.55,-d/4);ch.rotation.y=.1;add(new T.BoxGeometry(2.6,.6,2.6),M.pedraEscura,w/2-2.6,yTop+rh*.55+3.2,-d/4);}
    MM.box(g,0,(yTop+rh)/2,0,w+1,yTop+rh,d+1);}
  /* porta e janelas na frente (+Z local) */
  const fz=round?w/2+.05:d/2+.05;
  if(round){/* V2.3.2: porta e verga em arco, cravadas na parede cilíndrica (antes: placa reta tangente, bordas soltas no ar) */const R=w/2;MM.mesh(MM.arcSlab(R-.15,R+.55,4.6/R,8.6),M.madeira,0,1.8,0,g);MM.mesh(MM.arcSlab(R-.15,R+.95,5.8/R,.9),M.pedraClara,0,10.15,0,g);}
  else{add(new T.BoxGeometry(4.6,8.6,.5),M.madeira,0,6.1,fz);add(new T.BoxGeometry(5.8,.9,.9),M.pedraClara,0,10.6,fz+.1);}
  if(!round){[-w/2+2.4,w/2-2.4].forEach(x=>{if(Math.abs(x)>3.8)add(new T.BoxGeometry(2,2.6,.3),M.vidro,x,6.6,fz+.05);});}
  /* para-raios com duas bobinas e esfera */
  const rodH=8+r()*4;const rx=round?0:(opt.roof==='shed'?-w/2+1:0);add(new T.CylinderGeometry(.16,.32,rodH,5),M.metal,rx,top+rodH/2-.4,0);
  [.35,.6].forEach(f=>{const c=add(new T.TorusGeometry(.8,.22,5,12),M.cobre,rx,top+rodH*f,0);c.rotation.x=Math.PI/2;});
  add(new T.SphereGeometry(.45,8,6),M.cobre,rx,top+rodH-.2,0);
  g.userData.rodTip=new T.Vector3(rx,top+rodH-.2,0);const sw=w+1.6,sd=(round?w:d)+1.6;MM.box(g,0,.8,0,sw,1.6,sd);/* laje pisável */g.userData.foot={w:sw,d:sd,base:0,floor:1.6,front:sd/2,stepW:5.6,mat:M.pedraClara};/* mesmo material da laje: sem chamada de desenho extra */return g;};
I.buildVillage=function(ctx){const M=ctx.mat,V=I.poi.vila,out=[];const H=V.h;
  /* praça e Coletor */
  const pz=MM.obj('STORM.ARCH.VILLAGE.PLAZA','Praça do Coletor','Architecture',{notes:'Ponto de encontro da vila e raiz dos cabos.'});pz.position.set(V.x,H,V.z);
  MM.mesh(new T.CylinderGeometry(17,17.6,.6,40),M.pedraClara,0,.3,0,pz);MM.mesh(new T.CylinderGeometry(11,11,.66,32),M.pedra,0,.33,0,pz);
  for(let i=0;i<24;i++){const a=i/24*Math.PI*2;MM.mesh(new T.BoxGeometry(1.2,.7,4),M.pedraEscura,Math.sin(a)*14,.35,Math.cos(a)*14,pz).rotation.y=a;}
  MM.mesh(new T.CylinderGeometry(4,4.6,2.2,8),M.pedra,0,1.4,0,pz);MM.mesh(new T.CylinderGeometry(1.25,1.6,17,8),M.cobre,0,10,0,pz);
  [6,10,14].forEach(y=>MM.mesh(new T.TorusGeometry(2.3,.45,6,16),M.patina,0,y,0,pz).rotation.x=Math.PI/2);
  MM.mesh(MM.crystalGeo(1,2.2,2.2),M.cristal,0,18.4,0,pz);MM.mesh(new T.SphereGeometry(.55,8,6),M.energia,0,19.6,0,pz).castShadow=false;
  MM.box(pz,0,9,0,9,18,9);pz.userData.assento=MM.seat(ctx,pz,{r:17.6,bury:.25,mat:M.pedra});pz.userData.top=new T.Vector3(V.x,pz.position.y+19.6,V.z);out.push(pz);
  /* casas: candidatas em anel; descarta as que tocam caminhos ou a praça */
  const r=MM.rng(404);const variants=[{w:14,d:12,floors:2,roof:'gable'},{w:12,d:12,floors:1,roof:'cone'},{w:16,d:12,floors:2,roof:'shed'},{w:13,d:11,floors:1,roof:'gable',rot90:true},{w:15,d:13,floors:2,roof:'gable',rot90:true},{w:11,d:11,floors:1,roof:'cone'},{w:14,d:10,floors:1,roof:'shed'},{w:12,d:13,floors:2,roof:'gable'}];
  let n=0;const placed=[];
  for(let ring=0;ring<2;ring++)for(let k=0;k<14&&n<11;k++){const a=k/14*Math.PI*2+ring*.22+r()*.12;const rad=31+ring*15+r()*4;const x=V.x+Math.sin(a)*rad,z=V.z+Math.cos(a)*rad;
    if(ctx.pathDist(x,z)<10.5)continue;if(placed.some(p=>Math.hypot(p[0]-x,p[1]-z)<18))continue;if(Math.hypot(x-V.x,z-V.z)>V.r-6)continue;
    const vv=variants[n%variants.length];const hs=I.buildHouse(ctx,'STORM.ARCH.HOUSE.'+String(n+1).padStart(2,'0'),'Casa da vila '+(n+1),Object.assign({seed:900+n*7},vv));
    hs.position.set(x,H,z);hs.rotation.y=Math.atan2(V.x-x,V.z-z)+(r()-.5)*.25;/* frente para a praça */
    /* V2.3.1: piso pela área inteira da casa + alicerce e degraus onde o chão desce (antes: altura fixa da vila para todas) */hs.userData.assento=MM.seat(ctx,hs,hs.userData.foot);out.push(hs);placed.push([x,z]);n++;}
  /* oficina da Ferreira dos Para-raios (NPC 02): galpão aberto com toldo, bigorna e bobina em montagem */
  {const ws=MM.obj('STORM.ARCH.WORKSHOP','Oficina dos Para-raios','Architecture',{notes:'Espaço do NPC STORM.NPC.02. Frente aberta de 18 studs.'});/* V2.3.1: posição livre mais próxima da original (−60,74), que ficava em cima do início da trilha P2 */
    let x=-60,z=74;{let best=null;for(let rr=0;rr<=46&&!best;rr+=2)for(let k=0;k<16&&!best;k++){const a=k/16*6.283;const cx=-60+Math.cos(a)*rr,cz=74+Math.sin(a)*rr;if(ctx.pathDist(cx,cz)<19)continue;if(out.some(o=>o.userData.foot&&Math.hypot(o.position.x-cx,o.position.z-cz)<22))continue;best=[cx,cz];}if(best){x=best[0];z=best[1];}}
    ws.position.set(x,0,z);
    /* frente aberta virada para um lado livre (sem casa a menos de 12 studs diante dela) */
    {const houses=out.filter(o=>o.userData.foot);let bestR=.9,bestS=-1e9;for(const ry of [.9,.9+Math.PI/2,.9+Math.PI,.9-Math.PI/2]){let sc=0;for(const d of [10,14,18]){const fx=x+Math.sin(ry)*d,fz=z+Math.cos(ry)*d;const hd=Math.min(...houses.map(o=>Math.hypot(o.position.x-fx,o.position.z-fz)),99);sc+=Math.min(hd,20)-(ctx.inside(fx,fz)?0:50)-Math.max(0,ctx.pathDist(fx,fz))*.2;}if(sc>bestS){bestS=sc;bestR=ry;}}ws.userData.ry=bestR;}ws.rotation.y=ws.userData.ry;MM.box(ws,0,.7,0,22,1.4,16);ws.userData.assento=MM.seat(ctx,ws,{w:22,d:16,base:0,floor:1.4,front:8,stepW:14,mat:M.pedraClara});
    MM.mesh(new T.BoxGeometry(22,1.4,16),M.pedraClara,0,.7,0,ws);MM.mesh(new T.BoxGeometry(22,10,1.2),M.alvenaria,0,6,-7.4,ws);[-10.4,10.4].forEach(xx=>MM.mesh(new T.BoxGeometry(1.2,10,15),M.alvenaria,xx,6,0,ws));
    const roof=MM.mesh(shedGeo(22,16,3.5,1,1.4),M.telhado,0,11,0,ws);roof.rotation.y=Math.PI/2;
    [-7,0,7].forEach(xx=>MM.mesh(new T.CylinderGeometry(.35,.35,10,6),M.madeira,xx,6,7.2,ws));
    MM.mesh(new T.BoxGeometry(2.4,2.2,1.4),M.metalEscuro,-3,2.5,1,ws);MM.mesh(new T.BoxGeometry(3.4,.9,1.6),M.metal,-3,4,1,ws);
    for(let i=0;i<5;i++)MM.mesh(new T.TorusGeometry(1.6,.28,6,16),M.cobre,4,2.6+i*.65,-2,ws).rotation.x=Math.PI/2;
    MM.mesh(new T.CylinderGeometry(.4,.4,6,6),M.metal,4,4,-2,ws);MM.mesh(new T.BoxGeometry(2,1.6,2),M.pedraEscura,8,2.2,-4,ws);
    MM.box(ws,0,6,-7.4,22,12,1.6);MM.box(ws,-10.4,6,0,1.6,12,15);MM.box(ws,10.4,6,0,1.6,12,15);out.push(ws);}
  /* barracas do mercado */
  [[-14,104,.4],[-50,108,-.5]].forEach(([x0,z0,ry],i)=>{/* V2.3.1: barraca nunca na frente de uma porta (antes a 2 ficava colada na porta da casa 2) */
    const fronts=out.filter(o=>o.userData.foot).map(o=>{const f=o.userData.foot,c=Math.cos(o.rotation.y),s=Math.sin(o.rotation.y);const lz=f.d/2+5;return[o.position.x+lz*s,o.position.z+lz*c,o];});
    let x=x0,z=z0;for(let t=0;t<12;t++){const bad=fronts.some(([fx,fz])=>Math.hypot(fx-x,fz-z)<9)||out.some(o=>o.userData.foot&&Math.hypot(o.position.x-x,o.position.z-z)<14)||Math.hypot(V.x-x,V.z-z)<17.6+5.5;/* V2.3.2: fora do anel da praça */if(!bad&&ctx.pathDist(x,z)>=4)break;const a=t*1.3;x=x0+Math.cos(a)*(4+t*1.5);z=z0+Math.sin(a)*(4+t*1.5);}
    if(ctx.pathDist(x,z)<4)return;const st=MM.obj('STORM.PROP.STALL.0'+(i+1),'Barraca do mercado '+(i+1),'Props');st.position.set(x,0,z);st.rotation.y=ry;MM.mesh(new T.BoxGeometry(8,.5,5.4),M.madeira,0,.25,0,st).userData.apoio=true;/* estrado da barraca */st.userData.assento=MM.seat(ctx,st,{w:8,d:5.4,base:0,mat:M.madeira});
    MM.mesh(new T.BoxGeometry(6,3,3),M.madeira,0,2,0,st);[[-2.8,-1.3],[2.8,-1.3],[-2.8,1.3],[2.8,1.3]].forEach(([a,b])=>MM.mesh(new T.CylinderGeometry(.18,.18,7,5),M.madeira,a,4,b,st));
    const aw=MM.mesh(new T.BoxGeometry(7,.2,4.4),M.tecido,0,7.5,0,st);aw.rotation.x=.18;MM.mesh(MM.crystalGeo(.4,.8,.8),M.cristal,-1.5,3.6,0,st);MM.mesh(new T.BoxGeometry(1.2,1,1),M.cobre,1.4,4,0,st);
    MM.box(st,0,2,0,6,3,3);out.push(st);});
  /* cabos de cada para-raios até o Coletor (catenárias) */
  const cab=MM.obj('STORM.PROP.VILLAGE.CABLES','Cabos dos para-raios','Props',{notes:'No Roblox: Beam ou RopeConstraint visual entre Attachments.'});const top=pz.userData.top;
  out.forEach(o=>{if(!o.userData.rodTip)return;o.updateMatrixWorld(true);const a=o.localToWorld(o.userData.rodTip.clone());const sag=2+a.distanceTo(top)*.06;cab.add(MM.tube(MM.catenary(a,top,sag,20),.12,M.metalEscuro,24,4));});
  cab.userData.ancoras=out.filter(o=>o.userData.rodTip).map(o=>o.userData.id).concat(['STORM.ARCH.VILLAGE.PLAZA']);out.push(cab);
  /* lanternas ao longo dos caminhos da vila e até a torre */
  const lan=MM.obj('STORM.PROP.LANTERNS','Lanternas dos caminhos','Props',{notes:'Luz quente e fraca; no Roblox: PointLight sem sombra só nas mais próximas.'});
  ctx.terrain.paths.forEach(p=>{if(p.c.tipo!=='principal')return;let acc=0;for(let i=1;i<p.S.length;i++){const [x0,z0]=p.S[i-1],[x1,z1]=p.S[i];acc+=Math.hypot(x1-x0,z1-z0);if(acc<22)continue;acc=0;
      const dx=x1-x0,dz=z1-z0,L=Math.hypot(dx,dz)||1;const side=(i%2?1:-1)*(p.hw+1.6);const x=x1-dz/L*side,z=z1+dx/L*side;const y=ctx.heightAt(x,z);if(y<0)continue;
      const yb=Math.min(y,ctx.heightAt(x+.4,z),ctx.heightAt(x-.4,z),ctx.heightAt(x,z+.4),ctx.heightAt(x,z-.4));const post=new T.Group();post.position.set(x,yb-.3,z);MM.mesh(new T.CylinderGeometry(.2,.3,6.3,6),M.metalEscuro,0,3.15,0,post);MM.mesh(new T.CylinderGeometry(.45,.55,.6,6),M.metalEscuro,0,.3,0,post);MM.mesh(new T.BoxGeometry(1.3,.25,.25),M.metalEscuro,.5,6.1,0,post);
      const l=MM.mesh(new T.BoxGeometry(.7,1,.7),M.lanterna,1,5.4,0,post);l.castShadow=false;lan.add(post);}});
  out.push(lan);return out;};
})();
