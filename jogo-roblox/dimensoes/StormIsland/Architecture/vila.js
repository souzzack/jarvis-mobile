/* Ilha das Tempestades · Architecture · Vila dos Para-raios
   Casas geradas por variante (térreo de alvenaria com cunhais de pedra, andar de madeira enxaimel, telhado em duas águas,
   cônico ou de uma água, chaminé e para-raios com bobinas de cobre). Praça com o Coletor, oficina, barracas, lanternas e cabos. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
/* ---------- Casas da vila (Mapa V1): arquitetura completa ----------
   Mesma planta, posição, orientação, altura e colisores de antes. Muda só a construção:
   plinto de pedra lavrada, térreo de cantaria com ABERTURAS REAIS (porta em arco recuada, janelas com caixilho, peitoril e verga),
   cunhais alternados, andar em enxaimel sobre balanço com mãos-francesas, telhado com espessura (chapas de junta em pé,
   cumeeira, beirais, calhas, condutores), empenas fechadas com óculo, chaminé com capelo, lanterna junto à porta e para-raios.
   Materiais compartilhados por todas as casas (8 por casa, mesma família da Oficina dos Inventores). */
function wallG(u0,u1,v0,v1,holes,t){const s=new T.Shape();s.moveTo(u0,v0);s.lineTo(u1,v0);s.lineTo(u1,v1);s.lineTo(u0,v1);s.lineTo(u0,v0);
  (holes||[]).forEach(h=>{const p=new T.Path();if(h.circ)p.absarc(h.u,h.v,h.r,0,Math.PI*2,true);
    else if(h.arch){p.moveTo(h.u0,h.v0);p.lineTo(h.u0,h.v1);p.absarc((h.u0+h.u1)/2,h.v1,(h.u1-h.u0)/2,Math.PI,0,true);p.lineTo(h.u1,h.v0);p.lineTo(h.u0,h.v0);}
    else{p.moveTo(h.u0,h.v0);p.lineTo(h.u0,h.v1);p.lineTo(h.u1,h.v1);p.lineTo(h.u1,h.v0);p.lineTo(h.u0,h.v0);}s.holes.push(p);});
  const g=new T.ExtrudeGeometry(s,{depth:t,bevelEnabled:false,curveSegments:10});g.translate(0,0,-t/2);return g;}
function polyG(pts,t){const s=new T.Shape();pts.forEach((p,i)=>i?s.lineTo(p[0],p[1]):s.moveTo(p[0],p[1]));s.lineTo(pts[0][0],pts[0][1]);const g=new T.ExtrudeGeometry(s,{depth:t,bevelEnabled:false});g.translate(0,0,-t/2);return g;}
function archRingG(ri,ro,spring,t){const s=new T.Shape();s.moveTo(-ro,0);s.lineTo(-ro,spring);s.absarc(0,spring,ro,Math.PI,0,true);s.lineTo(ro,0);s.lineTo(ri,0);s.lineTo(ri,spring);s.absarc(0,spring,ri,0,Math.PI,false);s.lineTo(-ri,0);s.lineTo(-ro,0);
  const g=new T.ExtrudeGeometry(s,{depth:t,bevelEnabled:false,curveSegments:12});g.translate(0,0,-t/2);return g;}
function archLeafG(r,spring,t){const s=new T.Shape();s.moveTo(-r,0);s.lineTo(-r,spring);s.absarc(0,spring,r,Math.PI,0,true);s.lineTo(r,0);s.lineTo(-r,0);const g=new T.ExtrudeGeometry(s,{depth:t,bevelEnabled:false,curveSegments:12});g.translate(0,0,-t/2);return g;}
I.houseMats=function(ctx){if(ctx.__casaM)return ctx.__casaM;const tx=MM.tex;
  const cant=MM.triplanar({mode:'rocha',name:'IlhaCantaria',rockScale:.11,strata:0,tint:'#e3dbd2',mossTop:.35,env:.5});cant.userData.u.tRockC.value=tx.blocos.map;cant.userData.u.tRockN.value=tx.blocos.normalMap;
  const lav=MM.triplanar({mode:'rocha',name:'IlhaPedraLavrada',rockScale:.07,strata:0,tint:'#fff3e4',env:.5});
  const std=(name,t,o)=>new T.MeshStandardMaterial(Object.assign({name,map:t.map,normalMap:t.normalMap,roughnessMap:t.roughnessMap},o));
  const pm=tx.terra.map.clone();pm.needsUpdate=true;pm.repeat.set(.16,.16);
  ctx.__casaM={cant,lav,
    woodD:std('IlhaMadeiraEstrutural',tx.madeira,{roughness:1,color:MM.C('#7d604c')}),
    plaster:new T.MeshStandardMaterial({name:'IlhaReboco',color:MM.C('#e2d4c0'),map:pm,roughness:.95}),
    roof:std('IlhaChapaTelhado',tx.metal,{metalness:.6,roughness:.88,envMapIntensity:.5,color:MM.C('#4c5f6e')}),
    iron:std('IlhaFerroEscuro',tx.metal,{metalness:.75,roughness:.9,color:MM.C('#4a4d55')}),
    copper:std('IlhaCobre',tx.cobre,{metalness:.8,roughness:.75,color:MM.C('#d39a6a')}),
    glass:new T.MeshStandardMaterial({name:'IlhaVidroAceso',color:MM.C('#3b3226'),roughness:.25,metalness:.1,emissive:MM.C('#ffb468'),emissiveIntensity:.55})};
  return ctx.__casaM;};
I.buildHouse=function(ctx,id,name,opt){const M=ctx.mat,K=I.houseMats(ctx),r=MM.rng(opt.seed);const g=MM.obj(id,name,'Architecture',{notes:'Casa da vila (não explorável). Porta em arco 4 × 7,4 studs recuada na parede. Para-raios com bobinas no topo, ligado ao Coletor da praça.'});
  const w=opt.w,d=opt.d,two=opt.floors>1,round=opt.roof==='cone';const BB=MM.bevelBox;
  const add=(geo,m,x,y,z,p)=>MM.mesh(geo,m,x,y,z,p||g);
  /* face: grupo com +Z local = para fora da parede; u ao longo da parede, v para cima a partir de y0 */
  const face=(ry,dist,y0)=>{const f=new T.Group();f.rotation.y=ry;f.position.set(Math.sin(ry)*dist,y0,Math.cos(ry)*dist);g.add(f);return f;};
  /* janela numa abertura real: vidro recuado, caixilho no vão, montante e travessa, peitoril e (na pedra) verga */
  const janela=(f,c,v0,ww,wh,t,pedra)=>{add(new T.BoxGeometry(ww,wh,.1),K.glass,c,v0+wh/2,-t/2+.25,f).castShadow=false;
    [[0,v0+.1,ww,.2],[0,v0+wh-.1,ww,.2]].forEach(([u,v,a,b])=>add(new T.BoxGeometry(a,b,t-.1),K.woodD,c+u,v,0,f));[-1,1].forEach(s=>add(new T.BoxGeometry(.2,wh,t-.1),K.woodD,c+s*(ww/2-.1),v0+wh/2,0,f));
    add(new T.BoxGeometry(.13,wh,.12),K.woodD,c,v0+wh/2,-t/2+.35,f);add(new T.BoxGeometry(ww,.13,.12),K.woodD,c,v0+wh*.64,-t/2+.35,f);
    add(BB(ww+.7,.24,.75,.06),pedra?K.lav:K.woodD,c,v0-.1,t/2+.12,f);if(pedra)add(BB(ww+.8,.55,.6,.08),K.lav,c,v0+wh+.27,t/2-.25,f);};
  const lanterna=(f,u,v,t)=>{add(new T.BoxGeometry(.3,.3,.7),K.iron,u,v+.9,t/2+.35,f);add(new T.CylinderGeometry(.1,.1,.5,6),K.iron,u,v+.65,t/2+.75,f);
    add(new T.CylinderGeometry(.22,.28,.7,6),K.glass,u,v+.15,t/2+.75,f).castShadow=false;add(new T.ConeGeometry(.36,.35,6),K.iron,u,v+.67,t/2+.75,f);add(new T.CylinderGeometry(.3,.18,.12,6),K.iron,u,v-.26,t/2+.75,f);};
  /* plinto lavrado com pingadeira (o topo continua em 1,6: laje pisável e degraus de MM.seat) */
  const pw=w+1.6,pd=(round?w:d)+1.6;add(BB(pw,1.5,pd,.12),K.lav,0,.75,0);add(BB(pw+.3,.22,pd+.3,.06),K.lav,0,1.49,0);
  let top;
  if(round){const R=w/2;
    add(new T.CylinderGeometry(R,R+.4,9,24),K.cant,0,6.1,0);
    [[1.85,R+.42,.22],[3.6,R+.33,.16]].forEach(([y,rr,tb])=>add(new T.TorusGeometry(rr,tb,6,32),K.lav,0,y,0).rotation.x=Math.PI/2);
    add(new T.CylinderGeometry(R+.3,R+.3,.5,24),K.woodD,0,10.4,0);
    const hc=10+r()*3;const rb=10.6;/* cone apoiado no topo da parede (antes a base ficava até 0,4 acima, com fresta) */
    const roof=add(new T.ConeGeometry(R+2,hc,20,1,true),K.roof,0,rb+hc/2,0);add(new T.CylinderGeometry(R+.3,R+2,.25,20),K.woodD,0,rb+.12,0);/* forro do beiral */
    const rr0=r();for(let i=0;i<10;i++){const a=rr0+i/10*Math.PI*2,L=Math.hypot(hc,R+2),tilt=Math.atan2(R+2,hc);const sm=new T.Mesh(new T.BoxGeometry(.16,L,.16),K.iron);sm.position.set(Math.sin(a)*(R+2)/2,rb+hc/2,Math.cos(a)*(R+2)/2);sm.rotation.set(0,a,0);sm.rotateX(-tilt);sm.castShadow=true;g.add(sm);}
    add(new T.TorusGeometry(R+1.9,.2,5,32),K.iron,0,rb+.05,0).rotation.x=Math.PI/2;/* calha */
    top=rb+hc;r();/* mantém a sequência do sorteio */
    add(new T.CylinderGeometry(.55,.75,.6,10),K.copper,0,top-.25,0);
    /* janelas emolduradas na parede curva (lados e fundo), voltadas para fora */
    [Math.PI/2,Math.PI,-Math.PI/2].forEach(a=>{const f=face(a,R+.22,0);janela(f,0,4.4,1.7,2.6,.5,true);});
    /* porta em arco cravada no cilindro, ombreiras e verga de pedra, ferragens */
    add(MM.arcSlab(R-.15,R+.5,4.4/R,8.4),K.woodD,0,1.6,0);add(MM.arcSlab(R-.15,R+.75,5.6/R,.9),K.lav,0,10.0-.9+.05,0);
    [-1,1].forEach(s=>{const j=add(MM.arcSlab(R-.1,R+.75,.7/R,8.3),K.lav,0,1.6,0);j.rotation.y=s*(2.55/R);});
    [3.4,7.2].forEach(y=>add(MM.arcSlab(R+.45,R+.6,4.0/R,.25),K.iron,0,y,0));for(let i=-3;i<=3;i++){const b=add(MM.arcSlab(R+.45,R+.56,.07/R,8.2,2),K.iron,0,1.7,0);b.rotation.y=i*.6/R;}/* juntas das tábuas */
    {const f=face(0,R+.55,1.6);add(new T.TorusGeometry(.25,.06,5,10),K.copper,.9,3.9,0,f);lanterna(face(.95,R+.3,1.6),0,5.6,.2);}
    MM.box(g,0,6,0,R*2,10.6,R*2);}
  else{const t0=.8;
    /* térreo: cantaria com aberturas reais */
    const wc=w/2-2.6,frontWin=wc-1.25>=3.0;const doorH={arch:1,u0:-2,u1:2,v0:0,v1:5.0};
    const fF=face(0,d/2-t0/2,1.6),fB=face(Math.PI,d/2-t0/2,1.6),fL=face(-Math.PI/2,w/2-t0/2,1.6),fR=face(Math.PI/2,w/2-t0/2,1.6);
    const fw=frontWin?[-wc,wc]:[];
    add(wallG(-w/2,w/2,0,8,[doorH].concat(fw.map(c=>({u0:c-.85,u1:c+.85,v0:2.2,v1:5}))),t0),K.cant,0,0,0,fF);
    add(wallG(-w/2,w/2,0,8,[-w/4,w/4].map(c=>({u0:c-.85,u1:c+.85,v0:2.2,v1:5})),t0),K.cant,0,0,0,fB);
    [fL,fR].forEach(f=>add(wallG(-(d/2-t0),d/2-t0,0,8,[{u0:-.85,u1:.85,v0:2.2,v1:5}],t0),K.cant,0,0,0,f));
    fw.forEach(c=>janela(fF,c,2.2,1.7,2.8,t0,true));[-w/4,w/4].forEach(c=>janela(fB,c,2.2,1.7,2.8,t0,true));[fL,fR].forEach(f=>janela(f,0,2.2,1.7,2.8,t0,true));
    /* porta: aduelas, fecho, folha de tábuas recuada, ferragens, soleira */
    add(archRingG(2,2.65,5.0,t0+.3),K.lav,0,0,.15,fF);add(BB(.85,.9,t0+.5,.08),K.lav,0,7.55,.22,fF);
    add(archLeafG(2,5.0,.3),K.woodD,0,0,-.05,fF);for(let i=-3;i<=3;i++){const hh=5+Math.sqrt(4-(i*.55)**2)-.35;add(new T.BoxGeometry(.06,hh,.06),K.iron,i*.55,hh/2,.12,fF);}
    [1.6,5.0].forEach(v=>add(new T.BoxGeometry(3.6,.22,.08),K.iron,0,v,.14,fF));add(new T.TorusGeometry(.25,.06,5,10),K.copper,1.2,3.6,.2,fF);add(BB(4.6,.18,1.1,.05),K.lav,0,.09,.2,fF);
    if(!frontWin||wc-1.25>=3.3)[-1,1].forEach(s=>{if(!frontWin||s<0)lanterna(fF,s*3.1,5.3,t0);});if(frontWin&&wc-1.25<3.3)lanterna(fR,-(d/2-1.7),5.3,t0);
    /* cunhais alternados nos quatro cantos */
    [[-1,-1],[1,-1],[-1,1],[1,1]].forEach(([sx,sz])=>{for(let k=0;k<9;k++){const lx=k%2===0;const a=lx?1.6:1.0,b=lx?1.0:1.6;add(BB(a,.84,b,.07),K.lav,sx*(w/2+.1-a/2),1.6+.45+k*.89,sz*(d/2+.1-b/2));}});
    let yTop=9.6,Wt=w,Dt=d;
    if(two){const uw=w-.6,ud=d-.6,tu=.5;Wt=uw;Dt=ud;
      /* balanço: viga de borda, frechal e consolos */
      add(BB(w+.6,.6,d+.6,.08),K.woodD,0,9.8,0);for(let x=-w/2+2.4;x<=w/2-2.39;x+=1.6)[-1,1].forEach(s=>{if(s>0&&Math.abs(x)<1.1)return;add(BB(.35,.5,.8,.05),K.woodD,x,9.25,s*(d/2+.1));});
      const y0=10.1,H=5.9;const uF=face(0,ud/2-tu/2,y0),uB=face(Math.PI,ud/2-tu/2,y0),uL=face(-Math.PI/2,uw/2-tu/2,y0),uR=face(Math.PI/2,uw/2-tu/2,y0);
      const winFB=[-uw/4,uw/4],hw={v0:1.4,v1:3.8};
      [uF,uB].forEach(f=>{add(wallG(-uw/2,uw/2,0,H,winFB.map(c=>({u0:c-.8,u1:c+.8,v0:hw.v0,v1:hw.v1})),tu),K.plaster,0,0,0,f);winFB.forEach(c=>janela(f,c,hw.v0,1.6,2.4,tu,false));});
      [uL,uR].forEach(f=>{add(wallG(-(ud/2-tu),ud/2-tu,0,H,[{u0:-.8,u1:.8,v0:hw.v0,v1:hw.v1}],tu),K.plaster,0,0,0,f);janela(f,0,hw.v0,1.6,2.4,tu,false);});
      /* enxaimel: esteios, baldrame, frechal, travessa e escoras (salientes 0,12 da parede) */
      const enx=(f,uh,posts,braces)=>{const z=tu/2+.06;posts.forEach(u=>add(new T.BoxGeometry(.38,H,.14),K.woodD,u,H/2,z,f));
        [[.17,.34],[H-.17,.34],[.95,.24]].forEach(([v,hh])=>add(new T.BoxGeometry(uh*2,hh,.14),K.woodD,0,v,z,f));
        if(braces)[-1,1].forEach(s=>{const u0=s*(uh-.35),u1=s*(uh-1.9),v0=.35,v1=3.0;const L=Math.hypot(u1-u0,v1-v0);const b=add(new T.BoxGeometry(.3,L,.12),K.woodD,(u0+u1)/2,(v0+v1)/2,z,f);b.rotation.z=Math.atan2(u0-u1,v1-v0);});};
      enx(uF,uw/2,[-uw/2+.19,0,uw/2-.19],true);enx(uB,uw/2,[-uw/2+.19,0,uw/2-.19],true);
      enx(uL,ud/2-tu,[-(ud/2-tu)+.19,-(ud/2-tu)/2,(ud/2-tu)/2,(ud/2-tu)-.19],false);enx(uR,ud/2-tu,[-(ud/2-tu)+.19,-(ud/2-tu)/2,(ud/2-tu)/2,(ud/2-tu)-.19],false);
      yTop=16;}
    else add(BB(w+.3,.4,d+.3,.06),K.woodD,0,9.45,0);/* frechal do térreo */
    const rh=5+r()*3.5;
    /* telhado: grupo com cumeeira ao longo de Z local; vira 90° quando a casa é girada */
    const rot=!!opt.rot90&&opt.roof!=='shed';const RG=new T.Group();RG.position.y=yTop;if(rot)RG.rotation.y=Math.PI/2;g.add(RG);
    const S=rot?Dt:Wt,L=rot?Wt:Dt,G=rot?d/2:w/2,ov=1.3,tk=.45;
    const slab=(x0,y0,x1,y1,zl)=>{const dx=x1-x0,dy=y1-y0,Ls=Math.hypot(dx,dy),a=Math.atan2(dy,dx);const nx=-Math.sin(a),ny=Math.cos(a);const cx=(x0+x1)/2+nx*tk/2,cy=(y0+y1)/2+ny*tk/2;
      const s=add(new T.BoxGeometry(Ls,tk,zl),K.roof,cx,cy,0,RG);s.rotation.z=a;
      for(let z=-zl/2+.6;z<=zl/2-.59;z+=1.25){const sm=add(new T.BoxGeometry(Ls,.14,.12),K.roof,cx+nx*(tk/2+.06),cy+ny*(tk/2+.06),z,RG);sm.rotation.z=a;sm.castShadow=false;}
      [-1,1].forEach(sg=>{const b=add(new T.BoxGeometry(Ls+.1,.75,.22),K.woodD,cx-nx*.15,cy-ny*.15,sg*(zl/2-.05),RG);b.rotation.z=a;});return{a,nx,ny};};
    const calha=(x,y,zl)=>{const c=add(new T.CylinderGeometry(.24,.24,zl,8),K.iron,x,y,0,RG);c.rotation.x=Math.PI/2;};
    const desce=(xg,yg,xp,z)=>{const s=Math.sign(xp);const dx=xp-xg;const con=add(new T.CylinderGeometry(.14,.14,Math.hypot(dx,.8),6),K.iron,(xg+xp)/2,yg-.4,z,RG);con.rotation.z=Math.atan2(-dx,-.8);
      const yb=1.6-yTop,ytop=yg-.8;add(new T.CylinderGeometry(.17,.17,ytop-yb,6),K.iron,xp,(ytop+yb)/2,z,RG);add(new T.CylinderGeometry(.17,.3,.35,6),K.iron,xp,yb+.18,z,RG);
      for(let y=ytop-1.5;y>yb+1;y-=2.5)add(new T.BoxGeometry(.5,.12,.5),K.iron,xp,y,z+0,RG).position.x=xp-s*.05;};
    if(opt.roof==='shed'){const H1=rh+1,ta=(H1-1)/S;
      slab(-S/2-ov,H1+ov*ta,S/2+ov,1-ov*ta,L+2*ov);
      [-1,1].forEach(sg=>add(polyG([[-S/2,0],[S/2,0],[S/2,1],[-S/2,H1]],.5),K.plaster,0,0,sg*(L/2-.25),RG));
      {const wl=add(polyG([[-(L/2-.5),0],[L/2-.5,0],[L/2-.5,H1],[-(L/2-.5),H1]],.5),K.plaster,-S/2+.25,0,0,RG);wl.rotation.y=Math.PI/2;}
      add(new T.BoxGeometry(.5,1,L-1),K.plaster,S/2-.25,.5,0,RG);
      calha(S/2+ov-.05,1-ov*ta-.2,L+2*ov);desce(S/2+ov-.05,1-ov*ta-.2,G+.55,L/2-.4);desce(S/2+ov-.05,1-ov*ta-.2,G+.55,-(L/2-.4));
      /* frechais de madeira aparentes na empena */[-1,1].forEach(sg=>add(new T.BoxGeometry(S,.3,.2),K.woodD,0,.15,sg*(L/2+.02),RG));
      top=yTop+H1;}
    else{const ta=rh/(S/2);
      slab(-(S/2+ov),-ov*ta,0,rh,L+2*ov);slab(0,rh,S/2+ov,-ov*ta,L+2*ov);
      add(BB(.9,.38,L+2*ov+.1,.08),K.iron,0,rh+tk/Math.cos(Math.atan(ta))-.05,0,RG);
      const gab=()=>{const v=Math.min(rh*.42,rh-1.6);const s=new T.Shape();s.moveTo(-S/2,0);s.lineTo(S/2,0);s.lineTo(0,rh);s.lineTo(-S/2,0);if(v>1.3){const p=new T.Path();p.absarc(0,v,.72,0,Math.PI*2,true);s.holes.push(p);}const gg=new T.ExtrudeGeometry(s,{depth:.5,bevelEnabled:false,curveSegments:14});gg.translate(0,0,-.25);return gg;};
      [-1,1].forEach(sg=>{add(gab(),K.plaster,0,0,sg*(L/2-.25),RG);
        const v=Math.min(rh*.42,rh-1.6);if(v>1.3){add(new T.CylinderGeometry(.7,.7,.12,16),K.glass,0,v,sg*(L/2-.3),RG).rotation.x=Math.PI/2;add(new T.TorusGeometry(.78,.13,6,16),K.copper,0,v,sg*(L/2+.02),RG);}
        add(new T.BoxGeometry(S,.3,.2),K.woodD,0,.15,sg*(L/2+.02),RG);});
      [-1,1].forEach(sg=>{calha(sg*(S/2+ov-.05),-ov*ta-.2,L+2*ov);desce(sg*(S/2+ov-.05),-ov*ta-.2,sg*(G+.55),L/2-.4);});
      top=yTop+rh;}
    if(r()<.8){/* chaminé de cantaria: nasce no sótão, atravessa a chapa, capelo e dois potes */const cx=w/2-2.6,cz=-d/4,ct=yTop+rh*.55+3.2,cb=yTop+.3;
      add(BB(2,ct-cb,2,.1),K.cant,cx,(ct+cb)/2,cz);add(BB(2.5,.35,2.5,.08),K.lav,cx,ct+.1,cz);[-.45,.45].forEach(o=>add(new T.CylinderGeometry(.28,.34,.9,8),K.iron,cx+o,ct+.7,cz));}
    MM.box(g,0,(yTop+rh)/2,0,w+1,yTop+rh,d+1);}
  /* para-raios: haste, isolador, duas bobinas de cobre e esfera captora */
  const rodH=8+r()*4;const rx=round?0:(opt.roof==='shed'?-w/2+1:0);add(new T.CylinderGeometry(.16,.32,rodH,6),K.iron,rx,top+rodH/2-.4,0);
  add(new T.CylinderGeometry(.42,.5,.5,8),K.copper,rx,top+.65,0);add(new T.CylinderGeometry(.3,.3,.7,8),K.lav,rx,top+1.25,0);
  [.35,.6].forEach(f=>{const c=add(new T.TorusGeometry(.8,.22,6,14),K.copper,rx,top+rodH*f,0);c.rotation.x=Math.PI/2;});
  add(new T.SphereGeometry(.45,10,8),K.copper,rx,top+rodH-.2,0);
  g.userData.rodTip=new T.Vector3(rx,top+rodH-.2,0);const sw=w+1.6,sd=(round?w:d)+1.6;MM.box(g,0,.8,0,sw,1.6,sd);/* laje pisável */g.userData.foot={w:sw,d:sd,base:0,floor:1.6,front:sd/2,stepW:5.6,mat:K.lav};/* mesmo material do plinto: sem chamada de desenho extra */
  g.userData.materiais=Object.values(K).map(m=>m.name);return g;};
I.buildVillage=function(ctx){const M=ctx.mat,V=I.poi.vila,out=[];const H=V.h;
  /* praça e Coletor (Mapa V1): calçamento de cantaria com anel de pedra lavrada, raios e frisos de cobre, bancos curvos fora das trilhas,
     postes de luz; Coletor em pedestal octogonal de três degraus, coluna de cobre com colares de isoladores, bobina helicoidal,
     coroa de garras segurando o cristal. Topo da esfera de energia na mesma altura de antes (raiz dos cabos dos para-raios). */
  const K=I.houseMats(ctx),BB=MM.bevelBox;
  const pz=MM.obj('STORM.ARCH.VILLAGE.PLAZA','Praça do Coletor','Architecture',{notes:'Ponto de encontro da vila e raiz dos cabos. Praça de 35 studs; bancos curvos só fora das trilhas.'});pz.position.set(V.x,H,V.z);
  {const a=(g,m,x,y,z)=>MM.mesh(g,m,x,y,z,pz);
    a(new T.CylinderGeometry(17,17.6,.6,48),K.lav,0,.3,0).userData.apoio=true;a(new T.CylinderGeometry(11,11,.66,40),K.cant,0,.33,0);
    [[11,.16],[16.7,.12],[5.9,.12]].forEach(([r,t])=>{const tr=a(new T.TorusGeometry(r,t,4,64),K.copper,0,.64,0);tr.rotation.x=Math.PI/2;tr.scale.z=.5;tr.castShadow=false;});
    for(let i=0;i<12;i++){const an=i/12*Math.PI*2;const s=a(new T.BoxGeometry(.45,.06,5.4),K.lav,Math.sin(an)*13.9,.62,Math.cos(an)*13.9);s.rotation.y=an;s.castShadow=false;
      const c=a(new T.BoxGeometry(.18,.05,4.6),K.copper,Math.sin(an+Math.PI/12)*8.3,.68,Math.cos(an+Math.PI/12)*8.3);c.rotation.y=an+Math.PI/12;c.castShadow=false;}
    /* bancos curvos e postes, só onde não há trilha */
    const livre=(an,r,half)=>[-half,0,half].every(d=>ctx.pathDist(V.x+Math.sin(an+d)*r,V.z+Math.cos(an+d)*r)>.8);let nb=0,nl=0;
    for(let i=0;i<12;i++){const an=(i+.5)/12*Math.PI*2;
      if(livre(an,14.2,.26)){nb++;const s=a(MM.arcSlab(13.6,14.8,.44,.32),K.lav,0,1.45,0);s.rotation.y=an;[-.15,.15].forEach(d=>{const p=a(MM.arcSlab(13.85,14.55,.07,.8),K.cant,0,.66,0);p.rotation.y=an+d;});MM.box(pz,Math.sin(an)*14.2,1.2,Math.cos(an)*14.2,6,1.2,1.3,an);}
      else if(nl<4&&livre(an,16,.08)){nl++;const x=Math.sin(an)*16,z=Math.cos(an)*16;a(new T.CylinderGeometry(.45,.6,.5,8),K.iron,x,.85,z);a(new T.CylinderGeometry(.15,.2,6,8),K.iron,x,3.9,z);
        const g=a(new T.CylinderGeometry(.34,.42,1,6),K.glass,x,7.3,z);g.castShadow=false;a(new T.ConeGeometry(.55,.5,6),K.iron,x,8.05,z);a(new T.CylinderGeometry(.42,.3,.15,6),K.iron,x,6.75,z);MM.box(pz,x,3.9,z,.6,6.4,.6);}}
    pz.userData.bancos=nb;pz.userData.postes=nl;
    /* Coletor */
    [[5.2,5.6,1.06,K.lav],[4.2,4.5,1.86,K.cant],[3.2,3.5,2.66,K.lav]].forEach(([r0,r1,y,m])=>a(new T.CylinderGeometry(r0,r1,.8,8),m,0,y,0));
    a(new T.CylinderGeometry(1.25,1.6,15.2,20),K.copper,0,10.66,0);
    [3.5,4.05].forEach(y=>a(new T.CylinderGeometry(2,2.1,.4,16),K.lav,0,y,0));[4.75,16.4].forEach(y=>a(new T.TorusGeometry(2.2,.26,8,24),M.patina,0,y,0).rotation.x=Math.PI/2);
    {const hp=[];for(let i=0;i<=200;i++){const t=i/200,an=t*Math.PI*2*10;hp.push(new T.Vector3(Math.cos(an)*1.95,5.3+t*10.6,Math.sin(an)*1.95));}const hc=new T.Mesh(new T.TubeGeometry(new T.CatmullRomCurve3(hp),400,.17,5,false),K.copper);hc.castShadow=true;pz.add(hc);}
    for(let i=0;i<6;i++){const an=i/6*Math.PI*2;const s=a(new T.BoxGeometry(.2,11,.22),K.iron,Math.cos(an)*1.42,10.6,Math.sin(an)*1.42);s.rotation.y=-an;}
    a(new T.TorusGeometry(1.75,.22,6,20),K.iron,0,17.7,0).rotation.x=Math.PI/2;
    for(let i=0;i<6;i++){const an=i/6*Math.PI*2+.3;const cl=a(new T.BoxGeometry(.24,1.9,.24),K.iron,Math.cos(an)*1.35,18.55,Math.sin(an)*1.35);cl.rotation.set(0,-an,0);cl.rotateZ(.42);}
    a(MM.crystalGeo(1,2.2,2.2),M.cristal,0,18.4,0).castShadow=false;
    [[.9,.2,.3],[-.7,.6,-.35],[.1,-.95,.25]].forEach(([x,z,t],i)=>{const c=a(MM.crystalGeo(.35,.9,.7),M.cristal,x,18.2,z);c.rotation.set(t,i,-t);c.castShadow=false;});
    a(new T.SphereGeometry(.55,12,8),M.energia,0,19.6,0).castShadow=false;a(new T.TorusGeometry(.95,.1,5,16),K.copper,0,19.6,0).rotation.x=Math.PI/2;}
  MM.box(pz,0,9,0,9,18,9);pz.userData.assento=MM.seat(ctx,pz,{r:17.6,bury:.25,mat:K.cant});pz.userData.top=new T.Vector3(V.x,pz.position.y+19.6,V.z);out.push(pz);
  /* casas: candidatas em anel; descarta as que tocam caminhos ou a praça */
  const r=MM.rng(404);const variants=[{w:14,d:12,floors:2,roof:'gable'},{w:12,d:12,floors:1,roof:'cone'},{w:16,d:12,floors:2,roof:'shed'},{w:13,d:11,floors:1,roof:'gable',rot90:true},{w:15,d:13,floors:2,roof:'gable',rot90:true},{w:11,d:11,floors:1,roof:'cone'},{w:14,d:10,floors:1,roof:'shed'},{w:12,d:13,floors:2,roof:'gable'}];
  let n=0;const placed=[];
  for(let ring=0;ring<2;ring++)for(let k=0;k<14&&n<11;k++){const a=k/14*Math.PI*2+ring*.22+r()*.12;const rad=31+ring*15+r()*4;const x=V.x+Math.sin(a)*rad,z=V.z+Math.cos(a)*rad;
    if(ctx.pathDist(x,z)<10.5)continue;if(placed.some(p=>Math.hypot(p[0]-x,p[1]-z)<18))continue;if(Math.hypot(x-V.x,z-V.z)>V.r-6)continue;
    const vv=variants[n%variants.length];const hs=I.buildHouse(ctx,'STORM.ARCH.HOUSE.'+String(n+1).padStart(2,'0'),'Casa da vila '+(n+1),Object.assign({seed:900+n*7},vv));
    hs.position.set(x,H,z);hs.rotation.y=Math.atan2(V.x-x,V.z-z)+(r()-.5)*.25;/* frente para a praça */
    /* V2.3.1: piso pela área inteira da casa + alicerce e degraus onde o chão desce (antes: altura fixa da vila para todas) */hs.userData.assento=MM.seat(ctx,hs,hs.userData.foot);out.push(hs);placed.push([x,z]);n++;}
  /* Oficina dos Inventores (V2.3.4): edifício completo em oficina.js. Aqui só a posição, a orientação e o assentamento no terreno. */
  {const ws=MM.obj('STORM.ARCH.WORKSHOP','Oficina dos Inventores','Architecture',{notes:'Edifício 26 × 20 studs, interior explorável (bancadas, laboratório atmosférico, depósito, canto do inventor) e o Condensador Atmosférico. Lugar do NPC STORM.NPC.02. Porta 6,4 × 10,8.'});
    /* posição livre mais próxima da original (−60,74): a planta nova (≈ 28 × 22 com o plinto, + escada) pede mais folga de trilhas e casas */
    let x=-60,z=74;{let best=null;for(let rr=0;rr<=80&&!best;rr+=2)for(let k=0;k<24&&!best;k++){const a=k/24*6.283;const cx=-60+Math.cos(a)*rr,cz=74+Math.sin(a)*rr;if(ctx.pathDist(cx,cz)<13)continue;if(out.some(o=>(o.userData.foot||/PLAZA|STALL/.test(o.userData.id))&&Math.hypot(o.position.x-cx,o.position.z-cz)<24))continue;
      let ok=true;const hs=[ctx.heightAt(cx,cz)];for(let q=0;q<16&&ok;q++){const aa=q/16*6.283;if(!ctx.inside(cx+Math.cos(aa)*19,cz+Math.sin(aa)*19))ok=false;for(const rr2 of [8,15])hs.push(ctx.heightAt(cx+Math.cos(aa)*rr2,cz+Math.sin(aa)*rr2));}if(!ok)continue;
      /* V2.3.4: terreno quase plano sob a planta e a escada (variação ≤ 2,5 studs) — senão o alicerce vira um pedestal e a escada não alcança o chão */if(Math.max(...hs)-Math.min(...hs)>2.5)continue;best=[cx,cz];}if(best){x=best[0];z=best[1];}else console.warn('oficina: nenhum terreno plano livre encontrado; usando a posição original');}
    ws.position.set(x,0,z);
    /* frente (porta) virada para o lado mais livre e mais perto de uma trilha */
    {const houses=out.filter(o=>o.userData.foot);let bestR=.9,bestS=-1e9;for(const ry of [.9,.9+Math.PI/2,.9+Math.PI,.9-Math.PI/2]){let sc=0;for(const d of [14,18,22]){const fx=x+Math.sin(ry)*d,fz=z+Math.cos(ry)*d;const hd=Math.min(...houses.map(o=>Math.hypot(o.position.x-fx,o.position.z-fz)),99);sc+=Math.min(hd,20)-(ctx.inside(fx,fz)?0:50)-Math.max(0,ctx.pathDist(fx,fz))*.25;}if(sc>bestS){bestS=sc;bestR=ry;}}ws.rotation.y=bestR;}
    const b=I.buildWorkshop(ctx,ws);
    ws.userData.assento=MM.seat(ctx,ws,{w:27.6,d:21.6,base:0,floor:1.6,front:10.8,stepW:8,mat:b.stone,bury:.3});
    I.workshopIntegrate(ctx,ws);I.workshopComponents(ws);
    /* custo: o interior fica à sombra do telhado e das paredes — não projeta sombra; cada grupo animado é fundido por material internamente */
    ['Bancadas','Laboratório atmosférico','Depósito','Canto do inventor','Piso de tabuado','Condensador Atmosférico','Janelas'].forEach(n=>{const g=ws.getObjectByName(n);if(g)g.traverse(m=>{if(m.isMesh)m.castShadow=false;});});
    ws.traverse(g=>{if(g.userData&&g.userData.animated&&g!==b.roof)MM.bake(g);});MM.bake(b.roof);MM.bake(ws.__oficina.interior);ws.__oficina.interior.userData.animated=true;/* interior fundido à parte: nível de detalhe por distância */b.roof.userData.animated=true;MM.bake(ws.__oficina.front);ws.__oficina.front.userData.animated=true;/* telhado fundido à parte para poder ser ocultado na inspeção */
    out.push(ws);}
  /* barracas do mercado */
  [[-14,104,.4],[-50,108,-.5]].forEach(([x0,z0,ry],i)=>{/* V2.3.1: barraca nunca na frente de uma porta (antes a 2 ficava colada na porta da casa 2) */
    const fronts=out.filter(o=>o.userData.foot).map(o=>{const f=o.userData.foot,c=Math.cos(o.rotation.y),s=Math.sin(o.rotation.y);const lz=f.d/2+5;return[o.position.x+lz*s,o.position.z+lz*c,o];});
    let x=x0,z=z0;for(let t=0;t<12;t++){const bad=fronts.some(([fx,fz])=>Math.hypot(fx-x,fz-z)<9)||out.some(o=>o.userData.foot&&Math.hypot(o.position.x-x,o.position.z-z)<14)||Math.hypot(V.x-x,V.z-z)<17.6+5.5;/* V2.3.2: fora do anel da praça */if(!bad&&ctx.pathDist(x,z)>=4)break;const a=t*1.3;x=x0+Math.cos(a)*(4+t*1.5);z=z0+Math.sin(a)*(4+t*1.5);}
    if(ctx.pathDist(x,z)<4)return;const st=MM.obj('STORM.PROP.STALL.0'+(i+1),'Barraca do mercado '+(i+1),'Props',{notes:'Barraca de tábuas com toldo listrado, balcão e mercadorias (cristais, peças de cobre, frascos). Frente = +Z local.'});st.position.set(x,0,z);st.rotation.y=ry;
    /* Mapa V1: barraca de verdade — estrado de tábuas, balcão com painéis e tampo, esteios, toldo listrado com babado, mercadorias */
    const K=I.houseMats(ctx),BB=MM.bevelBox,s=(g,m,x,y,z)=>MM.mesh(g,m,x,y,z,st);
    if(!ctx.__lona){ctx.__lona=new T.MeshStandardMaterial({name:'IlhaLona',color:MM.C('#d9cba9'),roughness:1,side:T.DoubleSide});}const lona=ctx.__lona;
    s(BB(8,.5,5.4,.06),K.woodD,0,.25,0).userData.apoio=true;/* estrado da barraca */for(let k=-3;k<=3;k++)s(new T.BoxGeometry(.06,.03,5.3),K.iron,k*1.1,.51,0).castShadow=false;
    st.userData.assento=MM.seat(ctx,st,{w:8,d:5.4,base:0,mat:K.woodD});
    s(BB(6,2.6,.3,.05),K.woodD,0,1.8,1.35);[-1,1].forEach(k=>s(BB(.3,2.6,2.7,.05),K.woodD,k*2.85,1.8,0));s(BB(6.6,.25,3.4,.05),M.madeira,0,3.22,0);s(BB(5.4,.12,2.4,.04),M.madeira,0,1.9,0);
    for(let k=-2;k<=2;k++)s(new T.BoxGeometry(.06,2.4,.05),K.iron,k*1.15,1.8,1.53);[.9,2.7].forEach(y=>s(new T.BoxGeometry(5.8,.14,.06),K.iron,0,y,1.54));
    {const pl=s(new T.CylinderGeometry(.5,.5,.08,16),K.copper,0,2.2,1.56);pl.rotation.x=Math.PI/2;s(MM.crystalGeo(.12,.3,.25),M.cristal,0,2.05,1.62).castShadow=false;}
    [[-2.8,-1.3,7.8],[2.8,-1.3,7.8],[-2.8,1.3,7.0],[2.8,1.3,7.0]].forEach(([a,b,h])=>{s(BB(.32,h-.5,.32,.04),K.woodD,a,.5+(h-.5)/2,b);});
    s(new T.BoxGeometry(6,.25,.25),K.woodD,0,7.0,1.3);s(new T.BoxGeometry(6,.25,.25),K.woodD,0,7.8,-1.3);
    /* toldo listrado inclinado (frente mais baixa) e babado */
    {const aw=new T.Group();aw.position.set(0,7.6,0);aw.rotation.x=.18;st.add(aw);for(let k=0;k<6;k++){MM.mesh(new T.BoxGeometry(7.2/6,.07,4.8),k%2?lona:M.tecido,-3.6+7.2/6*(k+.5),.12,0,aw);}
      for(let k=0;k<12;k++){const f=MM.mesh(new T.ConeGeometry(.32,.6,3),k%2?lona:M.tecido,-3.3+k*.6,-.2,2.4,aw);f.rotation.x=Math.PI;f.castShadow=false;}}
    /* mercadorias */
    s(BB(1.4,.6,1,.04),K.woodD,-1.7,3.65,.2);[[-1.95,.1,.7],[-1.5,.35,.9],[-1.7,0,.5]].forEach(([x,z,h],k)=>{const c=s(MM.crystalGeo(.2,h,.35),M.cristal,x,3.95,z);c.rotation.set(.15*k,k,-.1*k);c.castShadow=false;});
    s(BB(1.2,1,1,.06),M.cobre,1.4,3.85,-.2);s(new T.CylinderGeometry(.35,.35,.25,12),K.iron,1.4,4.47,-.2);s(new T.TorusGeometry(.3,.07,5,10),K.copper,1.4,4.75,-.2);
    [-.3,.2,.65].forEach((x,k)=>{s(new T.CylinderGeometry(.22,.22,.6,8),K.glass,x,3.65,.6-k*.15).castShadow=false;s(new T.CylinderGeometry(.14,.14,.12,8),K.woodD,x,4.01,.6-k*.15);});
    s(new T.CylinderGeometry(.04,.04,.9,4),K.iron,.4,6.5,1.1);{const g=s(new T.CylinderGeometry(.24,.3,.7,6),K.glass,.4,5.8,1.1);g.castShadow=false;s(new T.ConeGeometry(.38,.3,6),K.iron,.4,6.3,1.1);}
    s(new T.CylinderGeometry(.55,.55,1.5,10),K.woodD,3.4,1.25,-1.6);[.8,1.7].forEach(y=>s(new T.CylinderGeometry(.58,.58,.1,10),K.iron,3.4,y,-1.6));s(BB(1.2,1,1.1,.05),K.woodD,-3.4,1,-1.6);
    MM.box(st,0,2,0,6,3,3);out.push(st);});
  /* cabos de cada para-raios até o Coletor (catenárias) */
  const cab=MM.obj('STORM.PROP.VILLAGE.CABLES','Cabos dos para-raios','Props',{notes:'No Roblox: Beam ou RopeConstraint visual entre Attachments.'});const top=pz.userData.top;
  out.forEach(o=>{if(!o.userData.rodTip)return;o.updateMatrixWorld(true);const a=o.localToWorld(o.userData.rodTip.clone());const sag=2+a.distanceTo(top)*.06;cab.add(MM.tube(MM.catenary(a,top,sag,20),.12,M.metalEscuro,24,4));});
  cab.userData.ancoras=out.filter(o=>o.userData.rodTip).map(o=>o.userData.id).concat(['STORM.ARCH.VILLAGE.PLAZA']);out.push(cab);
  /* lanternas ao longo dos caminhos da vila e até a torre */
  const lan=MM.obj('STORM.PROP.LANTERNS','Lanternas dos caminhos','Props',{notes:'Luz quente e fraca; no Roblox: PointLight sem sombra só nas mais próximas.'});
  ctx.terrain.paths.forEach(p=>{if(p.c.tipo!=='principal')return;let acc=0;for(let i=1;i<p.S.length;i++){const [x0,z0]=p.S[i-1],[x1,z1]=p.S[i];acc+=Math.hypot(x1-x0,z1-z0);if(acc<22)continue;acc=0;
      const dx=x1-x0,dz=z1-z0,L=Math.hypot(dx,dz)||1;const side=(i%2?1:-1)*(p.hw+1.6);const x=x1-dz/L*side,z=z1+dx/L*side;const y=ctx.heightAt(x,z);if(y<0)continue;if(out.some(o=>o.userData.id==='STORM.ARCH.WORKSHOP'&&Math.hypot(o.position.x-x,o.position.z-z)<19))continue;/* V2.3.4: nenhuma lanterna dentro da oficina */
      const yb=Math.min(y,ctx.heightAt(x+.4,z),ctx.heightAt(x-.4,z),ctx.heightAt(x,z+.4),ctx.heightAt(x,z-.4));const post=new T.Group();post.position.set(x,yb-.3,z);MM.mesh(new T.CylinderGeometry(.2,.3,6.3,6),M.metalEscuro,0,3.15,0,post);MM.mesh(new T.CylinderGeometry(.45,.55,.6,6),M.metalEscuro,0,.3,0,post);MM.mesh(new T.BoxGeometry(1.3,.25,.25),M.metalEscuro,.5,6.1,0,post);
      const l=MM.mesh(new T.BoxGeometry(.7,1,.7),M.lanterna,1,5.4,0,post);l.castShadow=false;lan.add(post);}});
  out.push(lan);return out;};
})();
