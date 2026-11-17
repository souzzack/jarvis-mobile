/* Ilha das Tempestades · Vegetation · Floresta Eletrificada
   Árvores retorcidas por ramificação recursiva: 12 formas distintas (semente própria cada), mais escala e rotação por instância.
   Veios elétricos finos subindo pelos troncos (energia ≤ 10% da área). Folhagem esparsa violeta-escura, em tufos pontiagudos. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
function treeGeos(seed,big){const r=MM.rng(seed);const wood=[],veins=[],leaves=[];
  function branch(start,dir,len,rad,depth){const pts=[start.clone()];let p=start.clone(),d=dir.clone();const segs=6;
    for(let i=1;i<=segs;i++){const twist=new T.Vector3((r()-.5)*.9,(r()-.2)*.35,(r()-.5)*.9);d.add(twist.multiplyScalar(.35)).normalize();p=p.clone().addScaledVector(d,len/segs);pts.push(p);}
    const curve=new T.CatmullRomCurve3(pts);const tg=new T.TubeGeometry(curve,segs*2,rad,6,false);
    /* afina até a ponta */const pa=tg.attributes.position;for(let i=0;i<pa.count;i++){const ring=Math.floor(i/7)/(segs*2);const c=curve.getPointAt(Math.min(1,ring));const v=new T.Vector3(pa.getX(i),pa.getY(i),pa.getZ(i)).sub(c).multiplyScalar(1-.7*ring).add(c);pa.setXYZ(i,v.x,v.y,v.z);}
    tg.computeVertexNormals();wood.push(tg);
    if(depth<=1&&rad>.5){const vp=curve.getPoints(16).map((q,i)=>{const a=i*.7+seed;return q.clone().add(new T.Vector3(Math.cos(a)*rad*.95,0,Math.sin(a)*rad*.95));});veins.push(new T.TubeGeometry(new T.CatmullRomCurve3(vp),24,.09,3,false));}
    if(depth<(big?4:3)){const n=depth===0?(big?4:3):2+(r()<.4?1:0);for(let k=0;k<n;k++){const t=.45+r()*.5;const sp=curve.getPointAt(t);const nd=d.clone().add(new T.Vector3((r()-.5)*1.8,.3+r()*.6,(r()-.5)*1.8)).normalize();branch(sp,nd,len*(.55+r()*.2),rad*.55,depth+1);}}
    else if(r()<.5){/* tufo pontiagudo e pequeno (não guarda-chuva) */const lg=MM.rockGeo(seed*13+leaves.length,.9+r()*.9,1.1+r()*.9,.9+r()*.9,0);lg.translate(p.x,p.y+.4,p.z);leaves.push(lg);}}
  const H=big?22:9+r()*7;branch(new T.Vector3(0,-1,0),new T.Vector3((r()-.5)*.3,1,(r()-.5)*.3).normalize(),H,big?2.6:.75+r()*.45,0);
  /* raízes aparentes */const nr=big?7:3;for(let k=0;k<nr;k++){const a=k/nr*Math.PI*2+r();const rp=[new T.Vector3(0,1.2,0),new T.Vector3(Math.cos(a)*1.4,.4,Math.sin(a)*1.4),new T.Vector3(Math.cos(a)*(big?6:2.6),-.6,Math.sin(a)*(big?6:2.6))];wood.push(new T.TubeGeometry(new T.CatmullRomCurve3(rp),6,big?1:.35,5,false));}
  return{wood:MM.merge(wood),veins:veins.length?MM.merge(veins):null,leaves:leaves.length?MM.merge(leaves):null};}
I.buildForest=function(ctx){const M=ctx.mat,F=I.poi.floresta,out=[];const variants=[];for(let v=0;v<12;v++)variants.push(treeGeos(1000+v*37,false));
  const r=MM.rng(808);let n=0;const placed=[];
  for(let tries=0;tries<900&&n<52;tries++){const a=r()*Math.PI*2,rr=Math.sqrt(r())*(F.r+18);const x=F.x+Math.cos(a)*rr,z=F.z+Math.sin(a)*rr;
    if(!ctx.inside(x,z)||ctx.pathDist(x,z)<4.5)continue;if(placed.some(p=>Math.hypot(p[0]-x,p[1]-z)<9))continue;if(Math.hypot(x-F.x,z-F.z)<16)continue;
    if(I.minas.some(m=>Math.hypot(m.x-x,m.z-z)<12))continue;const cb=I.poi.caverna.boca;if(Math.hypot(x-cb.x,z-cb.z)<34)continue;/* boca da caverna livre */const y=ctx.heightAt(x,z);if(y<3||y>40)continue;
    const vg=variants[n%variants.length];const o=MM.obj('STORM.VEG.TREE.'+String(n+1).padStart(2,'0'),'Árvore retorcida '+(n+1)+' (forma '+(n%12+1)+')','Vegetation',{notes:'Forma '+(n%12+1)+' de 12. Colisão só no tronco.'});
    o.position.set(x,y,z);o.rotation.y=r()*Math.PI*2;const sc=.75+r()*.6;o.scale.setScalar(sc);
    MM.mesh(vg.wood,M.casca,0,0,0,o);if(vg.veins){const vm=MM.mesh(vg.veins,M.veio,0,0,0,o);vm.castShadow=false;}if(vg.leaves)MM.mesh(vg.leaves,M.folhagem,0,0,0,o);
    MM.box(o,0,5,0,2.2,10,2.2);out.push(o);placed.push([x,z]);n++;}
  /* Árvore-Para-raios Ancestral: peça única no centro da floresta */
  {const g=treeGeos(4242,true);const o=MM.obj('STORM.VEG.ANCESTRAL','Árvore-Para-raios Ancestral','Vegetation',{notes:'Ponto de interesse da floresta: cristais presos nos galhos e veios mais fortes.'});const y=ctx.heightAt(F.x,F.z);o.position.set(F.x,y,F.z);
    MM.mesh(g.wood,M.casca,0,0,0,o);if(g.veins)MM.mesh(g.veins,M.veio,0,0,0,o).castShadow=false;if(g.leaves)MM.mesh(g.leaves,M.folhagem,0,0,0,o);
    const rr=MM.rng(9);for(let i=0;i<6;i++){const a=i/6*Math.PI*2;MM.mesh(MM.crystalGeo(.7+rr()*.5,2+rr()*2,1.6),M.cristal,Math.cos(a)*(5+rr()*4),16+rr()*10,Math.sin(a)*(5+rr()*4),o).rotation.set(rr()-.5,rr()*3,rr()-.5);}
    MM.box(o,0,10,0,6,20,6);out.push(o);}
  /* troncos caídos e flores-faísca (coleta) */
  const lg=MM.obj('STORM.VEG.UNDERGROWTH','Troncos caídos e flores-faísca','Vegetation',{notes:'Flores-faísca = pontos de coleta STORM.COLLECT.01.'});
  for(let i=0;i<9;i++){const a=r()*Math.PI*2,rr=20+r()*60;const x=F.x+Math.cos(a)*rr,z=F.z+Math.sin(a)*rr;if(!ctx.inside(x,z)||ctx.pathDist(x,z)<5)continue;const y=ctx.heightAt(x,z);
    const L=6+r()*7;const t=MM.mesh(new T.CylinderGeometry(.7,.9,L,7),M.casca,x,y+.5,z,lg);t.rotation.set(Math.PI/2,0,r()*3);t.rotation.order='YXZ';t.rotation.y=r()*3;}
  const fl=new T.MeshStandardMaterial({color:'#9fe8ff',emissive:MM.C('#43d9ff'),emissiveIntensity:.8,roughness:.4});fl.name='FlorFaisca';
  for(let i=0;i<34;i++){const a=r()*Math.PI*2,rr=r()*(F.r);const x=F.x+Math.cos(a)*rr,z=F.z+Math.sin(a)*rr;if(!ctx.inside(x,z)||ctx.pathDist(x,z)<2)continue;const y=ctx.heightAt(x,z);
    const st=MM.mesh(new T.CylinderGeometry(.06,.08,1.2,3),M.folhagem,x,y+.6,z,lg);st.castShadow=false;const b=MM.mesh(new T.OctahedronGeometry(.28,0),fl,x,y+1.3,z,lg);b.castShadow=false;}
  out.push(lg);return out;};
})();
