/* Ilha das Tempestades · Architecture · Ponte Suspensa da Fenda e plataformas elevadas
   A ponte tem superfície caminhável (catenária suave), guarda-corpos de corda e pilares de ancoragem. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
I.buildBridges=function(ctx){const M=ctx.mat,out=[];
  I.pontes.forEach(pb=>{const o=MM.obj(pb.id,pb.nome,'Architecture',{notes:'Vão de '+Math.round(Math.hypot(pb.b[0]-pb.a[0],pb.b[1]-pb.a[1]))+' studs sobre a fenda. Largura '+pb.w+' studs. No Roblox: tábuas ancoradas com colisão em caixa.'});
    const A=new T.Vector3(pb.a[0],ctx.heightAt(pb.a[0],pb.a[1])+.6,pb.a[1]),B=new T.Vector3(pb.b[0],ctx.heightAt(pb.b[0],pb.b[1])+.6,pb.b[1]);const sag=2.2;
    const dir=B.clone().sub(A);const L=dir.length();dir.normalize();const side=new T.Vector3(-dir.z,0,dir.x);const n=Math.round(L/1.25);
    const deckY=t=>MM.lerp(A.y,B.y,t)-sag*4*t*(1-t);
    for(let i=0;i<=n;i++){const t=i/n;const p=A.clone().lerp(B,t);p.y=deckY(t);const pl=MM.mesh(new T.BoxGeometry(pb.w,.4,1.05),M.madeira,p.x,p.y,p.z,o);pl.rotation.y=Math.atan2(dir.x,dir.z);pl.rotation.z=(i%3-1)*.015;
      /* V2.3.1: sobre terra firme o tabuleiro apoia num encontro de pedra (antes: tábuas a 0,2–1 stud do chão nas cabeceiras) */
      const gs=Math.min(...[-1,-.5,0,.5,1].flatMap(k=>[-.7,0,.7].map(q=>ctx.heightAt(p.x+side.x*k*(pb.w/2+.6)+dir.x*q,p.z+side.z*k*(pb.w/2+.6)+dir.z*q))));const gap=p.y-.2-gs;if(gap>-.1&&gap<7){const h=gap+2.5;const ab=MM.mesh(new T.BoxGeometry(pb.w+1.2,h,1.3),M.pedraClara,p.x,p.y-.2-h/2,p.z,o);ab.rotation.y=pl.rotation.y;ab.userData.apoio=true;}}
    [-1,1].forEach(sg=>{const off=side.clone().multiplyScalar(sg*pb.w/2);
      [A,B].forEach(E=>{const p=E.clone().add(off);const g=Math.min(...[[.8,0],[-.8,0],[0,.8],[0,-.8]].map(([a,b])=>ctx.heightAt(p.x+a,p.z+b)))-1;const top=p.y+7;const pi=MM.mesh(new T.BoxGeometry(1.6,top-g,1.6),M.pedraClara,p.x,(top+g)/2,p.z,o);pi.userData.apoio=true;MM.mesh(new T.BoxGeometry(2.6,1.2,2.6),M.pedraClara,p.x,g+1.1,p.z,o).userData.apoio=true;MM.mesh(new T.ConeGeometry(1.3,1.6,4),M.metalEscuro,p.x,p.y+7.8,p.z,o);});
      const rail=[],low=[];for(let i=0;i<=24;i++){const t=i/24;const p=A.clone().lerp(B,t).add(off);p.y=deckY(t)+3.6+sag*.8*4*t*(1-t)*.0;rail.push(p);const q=p.clone();q.y=deckY(t)+.3;low.push(q);}
      o.add(MM.tube(rail,.14,M.corda,40,4));o.add(MM.tube(low,.12,M.corda,40,4));
      for(let i=2;i<24;i+=2){const t=i/24;const p=A.clone().lerp(B,t).add(off);const h=3.4;const v=MM.mesh(new T.CylinderGeometry(.07,.07,h,3),M.corda,p.x,deckY(t)+h/2+.2,p.z,o);v.castShadow=false;}});
    o.userData.walk=[{type:'bridge',a:[A.x,A.z],b:[B.x,B.z],hw:pb.w/2-.4,y:t=>deckY(t)+.2}];out.push(o);});
  /* plataformas elevadas na floresta (Mapa V1): torres de vigia de madeira. Antes: laje lisa, guarda-corpo = anel quadrado flutuando
     3 studs acima do piso sem nenhum montante, escada de colunas maciças de pedra. Agora: tabuado sobre vigas, esteios com cintas de
     ferro e contraventamento em X, guarda-corpo de verdade (com colisão) e vão da escada, telhado de quatro águas com para-raios e
     lanterna, escada de madeira com banzos, degraus de tábua, corrimãos e apoios até o chão. Posição, altura, orientação, pés,
     degraus (mesma quantidade, mesmos colisores) e área caminhável: os de antes. */
  [[-132,-6,10],[-188,44,12]].forEach(([x,z,h],i)=>{const K=I.houseMats(ctx),BB=MM.bevelBox;const o=MM.obj('STORM.ARCH.PLATFORM.0'+(i+1),'Plataforma elevada '+(i+1),'Architecture',{notes:'Torre de vigia caminhável a '+h+' studs; escada de madeira de degraus de 0,9 stud; guarda-corpo com colisão; telhado com para-raios.'});const y=ctx.heightAt(x,z);o.position.set(x,y,z);const rot=i===1?Math.PI:0;o.rotation.y=rot;/* V2.3.1: a 2 vira a escada para o sul (antes a escada entrava na rocha da passagem secreta) */const cR=Math.cos(rot),sR=Math.sin(rot);const HL=(lx,lz)=>ctx.heightAt(x+lx*cR+lz*sR,z-lx*sR+lz*cR);
    const add=(g,m,a,b,c)=>MM.mesh(g,m,a,b,c,o);const top=h+.4;
    /* piso: vigas de borda, barrotes e tabuado */
    [-1,1].forEach(s=>{add(new T.BoxGeometry(12.4,.7,.5),K.woodD,0,h-.15,s*5.95);add(new T.BoxGeometry(.5,.7,12.4),K.woodD,s*5.95,h-.15,0);});for(let k=-2;k<=2;k++)add(new T.BoxGeometry(.35,.55,11.4),K.woodD,k*2.3,h-.2,0);
    for(let k=0;k<16;k++)add(new T.BoxGeometry(12,.18,.7),K.woodD,0,top-.09,-5.65+k*.75).castShadow=k%4===0;
    /* esteios: cada um desce até o chão real sob ele, com sapata de pedra e cintas de ferro; contraventamento em X em três lados */
    const P4=[[-5,-5],[5,-5],[-5,5],[5,5]];const gl={};P4.forEach(([a,b])=>{const g=HL(a,b)-y;gl[a+','+b]=g;const L=top+6.2-(g-.6);const lg=add(BB(.7,L,.7,.06),K.woodD,a,top+6.2-L/2,b);lg.userData.apoio=true;add(new T.CylinderGeometry(.9,1.1,1,7),K.lav,a,g+.2,b).userData.apoio=true;
      [g+1.6,h-1.2].forEach(yy=>add(new T.BoxGeometry(.8,.18,.8),K.iron,a,yy,b).userData.semApoio=true);/* cinta presa ao esteio */});
    const xb=(a0,b0,a1,b1)=>{const lo=Math.max(gl[a0+','+b0],gl[a1+','+b1])+1.6,hi=h-1.2;const dx=a1-a0,dz=b1-b0,L=Math.hypot(dx,dz);[[lo,hi],[hi,lo]].forEach(([y0,y1])=>{const d=new T.Vector3(dx,y1-y0,dz);const m=add(new T.BoxGeometry(.3,d.length(),.3),K.woodD,(a0+a1)/2,(y0+y1)/2,(b0+b1)/2);m.userData.semApoio=true;m.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),d.normalize());});{const tb=add(new T.BoxGeometry(L,.3,.3),K.woodD,(a0+a1)/2,lo,(b0+b1)/2);tb.rotation.y=-Math.atan2(dz,dx);tb.userData.semApoio=true;}};/* contraventamento: preso aos esteios */
    xb(-5,-5,5,-5);xb(-5,-5,-5,5);xb(5,-5,5,5);
    /* guarda-corpo: montantes, corrimão e travessa; vão de 5,6 studs para a escada (+Z) */
    const rail=(x0,z0,x1,z1)=>{const L=Math.hypot(x1-x0,z1-z0),n=Math.max(1,Math.round(L/2));for(let k=0;k<=n;k++){const t=k/n;add(new T.BoxGeometry(.3,3.2,.3),K.woodD,x0+(x1-x0)*t,top+1.6,z0+(z1-z0)*t);}
      const ry=-Math.atan2(z1-z0,x1-x0),cx=(x0+x1)/2,cz=(z0+z1)/2;[[3.1,.3,.35],[1.7,.2,.2]].forEach(([yy,hh,ww])=>{const m=add(new T.BoxGeometry(L,hh,ww),K.woodD,cx,top+yy,cz);m.rotation.y=ry;});MM.box(o,cx,top+1.6,cz,Math.abs(x1-x0)+.35,3.2,Math.abs(z1-z0)+.35);};
    rail(-5.9,-5.9,5.9,-5.9);rail(-5.9,-5.9,-5.9,5.9);rail(5.9,-5.9,5.9,5.9);rail(-5.9,5.9,-2.8,5.9);rail(2.8,5.9,5.9,5.9);
    /* telhado de quatro águas sobre os esteios, para-raios e lanterna */
    {const rf=new T.ConeGeometry(9.4,4.2,4,1,false);rf.rotateY(Math.PI/4);const m=add(rf,K.roof,0,top+6.2+2.1,0);m.castShadow=true;add(new T.BoxGeometry(12.6,.4,12.6),K.woodD,0,top+6.1,0);
      add(new T.CylinderGeometry(.12,.2,3.4,6),K.iron,0,top+6.2+5.4,0);add(new T.TorusGeometry(.4,.12,5,12),K.copper,0,top+6.2+5.2,0).rotation.x=Math.PI/2;add(new T.SphereGeometry(.32,10,8),K.copper,0,top+6.2+7.1,0);
      add(new T.CylinderGeometry(.04,.04,1.2,4),K.iron,0,top+5.3,0);const gl2=add(new T.CylinderGeometry(.28,.34,.8,6),K.glass,0,top+4.4,0);gl2.castShadow=false;add(new T.ConeGeometry(.45,.4,6),K.iron,0,top+4.95,0);}
    /* escada de madeira: degraus do patamar até o chão real (colisores = os blocos de antes), banzos, tábuas, corrimãos e apoios */
    {const run=1.25,rz=.9;let k=0;const steps=[];for(;k<30;k++){const tp=h-(k+1)*rz;const zz=6+run*(k+.5);const gs=Math.min(HL(-2.5,zz),HL(2.5,zz),HL(0,zz+run/2))-y;if(tp<=gs+.25)break;
        const hh=tp-(gs-.6);MM.box(o,0,tp-hh/2,zz,5,hh,run);steps.push([tp,zz,gs]);add(new T.BoxGeometry(5,.22,run+.08),K.woodD,0,tp-.11,zz).userData.semApoio=true;}/* tábua do degrau: apoiada nos banzos */o.userData.degraus=k;
      if(steps.length){const last=steps[steps.length-1];const zb=last[1]+run/2,yb=last[0]-.3;const zt=6,yt=h-.2;
        [-2.65,2.65].forEach(sx=>{const d=new T.Vector3(0,yt-yb,zt-zb);const m=add(new T.BoxGeometry(.32,d.length(),.6),K.woodD,sx,(yt+yb)/2-.25,(zt+zb)/2);m.userData.semApoio=true;/* banzo: apoiado no patamar de pedra, nos apoios e na viga do piso */m.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),d.clone().normalize());
          const hr=add(new T.BoxGeometry(.22,d.length()+.4,.22),K.woodD,sx,(yt+yb)/2+3.0,(zt+zb)/2);hr.quaternion.copy(m.quaternion);hr.userData.semApoio=true;
          steps.forEach(([tp,zz,gs],q)=>{if(q%3===1)add(new T.BoxGeometry(.22,3,.22),K.woodD,sx,tp+1.5,zz).userData.semApoio=true;if(q%4===2){const L=tp-.3-(gs-.4);if(L>1)add(new T.BoxGeometry(.4,L,.4),K.woodD,sx,(tp-.3+gs-.4)/2,zz).userData.apoio=true;}});});
        add(BB(6,.9,2,.08),K.lav,0,last[2]+.15,last[1]+run).userData.apoio=true;}}
    MM.box(o,0,h,0,12,.8,12);o.userData.walk=[{type:'rect',y:y+h+.4,x,z,sx:12,sz:12}];out.push(o);});
  return out;};
})();
