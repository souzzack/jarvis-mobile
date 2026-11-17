/* Ilha das Tempestades · Architecture · Ponte Suspensa da Fenda e plataformas elevadas
   A ponte tem superfície caminhável (catenária suave), guarda-corpos de corda e pilares de ancoragem. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
I.buildBridges=function(ctx){const M=ctx.mat,out=[];
  I.pontes.forEach(pb=>{const o=MM.obj(pb.id,pb.nome,'Architecture',{notes:'Vão de '+Math.round(Math.hypot(pb.b[0]-pb.a[0],pb.b[1]-pb.a[1]))+' studs sobre a fenda. Largura '+pb.w+' studs. No Roblox: tábuas ancoradas com colisão em caixa.'});
    const A=new T.Vector3(pb.a[0],ctx.heightAt(pb.a[0],pb.a[1])+.6,pb.a[1]),B=new T.Vector3(pb.b[0],ctx.heightAt(pb.b[0],pb.b[1])+.6,pb.b[1]);const sag=2.2;
    const dir=B.clone().sub(A);const L=dir.length();dir.normalize();const side=new T.Vector3(-dir.z,0,dir.x);const n=Math.round(L/1.25);
    const deckY=t=>MM.lerp(A.y,B.y,t)-sag*4*t*(1-t);
    for(let i=0;i<=n;i++){const t=i/n;const p=A.clone().lerp(B,t);p.y=deckY(t);const pl=MM.mesh(new T.BoxGeometry(pb.w,.4,1.05),M.madeira,p.x,p.y,p.z,o);pl.rotation.y=Math.atan2(dir.x,dir.z);pl.rotation.z=(i%3-1)*.015;}
    [-1,1].forEach(sg=>{const off=side.clone().multiplyScalar(sg*pb.w/2);
      [A,B].forEach(E=>{const p=E.clone().add(off);MM.mesh(new T.BoxGeometry(1.6,8,1.6),M.pedraClara,p.x,p.y+3,p.z,o);MM.mesh(new T.ConeGeometry(1.3,1.6,4),M.metalEscuro,p.x,p.y+7.8,p.z,o);});
      const rail=[],low=[];for(let i=0;i<=24;i++){const t=i/24;const p=A.clone().lerp(B,t).add(off);p.y=deckY(t)+3.6+sag*.8*4*t*(1-t)*.0;rail.push(p);const q=p.clone();q.y=deckY(t)+.3;low.push(q);}
      o.add(MM.tube(rail,.14,M.corda,40,4));o.add(MM.tube(low,.12,M.corda,40,4));
      for(let i=2;i<24;i+=2){const t=i/24;const p=A.clone().lerp(B,t).add(off);const h=3.4;const v=MM.mesh(new T.CylinderGeometry(.07,.07,h,3),M.corda,p.x,deckY(t)+h/2+.2,p.z,o);v.castShadow=false;}});
    o.userData.walk=[{type:'bridge',a:[A.x,A.z],b:[B.x,B.z],hw:pb.w/2-.4,y:t=>deckY(t)+.2}];out.push(o);});
  /* plataformas elevadas na floresta (mirantes de madeira com escada) */
  [[-132,-6,10],[-188,44,12]].forEach(([x,z,h],i)=>{const o=MM.obj('STORM.ARCH.PLATFORM.0'+(i+1),'Plataforma elevada '+(i+1),'Architecture',{notes:'Mirante caminhável a '+h+' studs; escada de degraus de 1 stud.'});const y=ctx.heightAt(x,z);o.position.set(x,y,z);
    MM.mesh(new T.BoxGeometry(12,.8,12),M.madeira,0,h,0,o);[[-5,-5],[5,-5],[-5,5],[5,5]].forEach(([a,b])=>MM.mesh(new T.CylinderGeometry(.45,.6,h,6),M.madeira,a,h/2,b,o));
    MM.mesh(new T.TorusGeometry(8.2,.18,4,4),M.madeira,0,h+3,0,o).rotation.set(Math.PI/2,0,Math.PI/4);
    for(let k=0;k<h;k++){MM.mesh(new T.BoxGeometry(5,.5,1.6),M.madeira,0,k+.5,6.8+ (h-k)*1.1,o);}
    MM.box(o,0,h,0,12,.8,12);o.userData.walk=[{type:'rect',y:y+h+.4,x,z,sx:12,sz:12}];out.push(o);});
  return out;};
})();
