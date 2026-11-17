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
  /* plataformas elevadas na floresta (mirantes de madeira com escada) */
  [[-132,-6,10],[-188,44,12]].forEach(([x,z,h],i)=>{const o=MM.obj('STORM.ARCH.PLATFORM.0'+(i+1),'Plataforma elevada '+(i+1),'Architecture',{notes:'Mirante caminhável a '+h+' studs; escada de degraus de 1 stud.'});const y=ctx.heightAt(x,z);o.position.set(x,y,z);const rot=i===1?Math.PI:0;o.rotation.y=rot;/* V2.3.1: a 2 vira a escada para o sul (antes a escada entrava na rocha da passagem secreta) */const cR=Math.cos(rot),sR=Math.sin(rot);const HL=(lx,lz)=>ctx.heightAt(x+lx*cR+lz*sR,z-lx*sR+lz*cR);
    MM.mesh(new T.BoxGeometry(12,.8,12),M.madeira,0,h,0,o);
    /* V2.3.1: cada pilar desce até o chão real sob ele, com sapata de pedra (antes: todos com o comprimento da altura do centro) */
    [[-5,-5],[5,-5],[-5,5],[5,5]].forEach(([a,b])=>{const gl=HL(a,b)-y;const L=h-(gl-.6);const lg=MM.mesh(new T.CylinderGeometry(.45,.6,L,6),M.madeira,a,h-L/2,b,o);lg.userData.apoio=true;MM.mesh(new T.CylinderGeometry(.9,1.1,1,7),M.pedraClara,a,gl+.2,b,o).userData.apoio=true;});
    MM.mesh(new T.TorusGeometry(8.2,.18,4,4),M.madeira,0,h+3,0,o).rotation.set(Math.PI/2,0,Math.PI/4);
    /* escada: degraus maciços de pedra do patamar até o chão real ao longo da descida (antes: tábuas soltas no ar) */
    {const run=1.25,rz=.9;let k=0;for(;k<30;k++){const top=h-(k+1)*rz;const zz=6+run*(k+.5);/* encostada na borda do piso (antes 0,4 stud de vão) */const gs=Math.min(HL(-2.5,zz),HL(2.5,zz),HL(0,zz+run/2))-y;if(top<=gs+.25)break;
      const hh=top-(gs-.6);const st=MM.mesh(MM.bevelBox(5,hh,run,.1),M.pedraClara,0,top-hh/2,zz,o);st.userData.apoio=true;MM.box(o,0,top-hh/2,zz,5,hh,run);}o.userData.degraus=k;}
    MM.box(o,0,h,0,12,.8,12);o.userData.walk=[{type:'rect',y:y+h+.4,x,z,sx:12,sz:12}];out.push(o);});
  return out;};
})();
