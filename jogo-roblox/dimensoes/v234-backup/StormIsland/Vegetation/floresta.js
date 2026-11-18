/* Ilha das Tempestades · Vegetation · Floresta Eletrificada
   Árvores retorcidas por ramificação recursiva: 12 formas distintas (semente própria cada), mais escala e rotação por instância.
   Veios elétricos finos subindo pelos troncos (energia ≤ 10% da área). Folhagem esparsa violeta-escura, em tufos pontiagudos. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
function treeGeos(seed,big){const r=MM.rng(seed);const wood=[],veins=[],leaves=[];
  function branch(start,dir,len,rad,depth){const pts=[start.clone()];let p=start.clone(),d=dir.clone();const segs=6;
    for(let i=1;i<=segs;i++){const twist=new T.Vector3((r()-.5)*.9,(r()-.2)*.35,(r()-.5)*.9);d.add(twist.multiplyScalar(.35)).normalize();p=p.clone().addScaledVector(d,len/segs);pts.push(p);}
    const curve=new T.CatmullRomCurve3(pts);const TS=segs+2,RS=5;const tg=new T.TubeGeometry(curve,TS,rad,RS,false);/* V2.3.4: 8 × 5 segmentos (antes 12 × 6): −44% de triângulos nas árvores, a maior fonte de sombra da cena */
    /* afina até a ponta */const pa=tg.attributes.position;for(let i=0;i<pa.count;i++){const ring=Math.floor(i/(RS+1))/TS;const c=curve.getPointAt(Math.min(1,ring));const v=new T.Vector3(pa.getX(i),pa.getY(i),pa.getZ(i)).sub(c).multiplyScalar(1-.7*ring).add(c);pa.setXYZ(i,v.x,v.y,v.z);}
    tg.computeVertexNormals();wood.push(tg);
    if(depth<=1&&rad>.5){const vp=curve.getPoints(16).map((q,i)=>{const a=i*.7+seed;return q.clone().add(new T.Vector3(Math.cos(a)*rad*.95,0,Math.sin(a)*rad*.95));});veins.push(new T.TubeGeometry(new T.CatmullRomCurve3(vp),24,.09,3,false));}
    if(depth<(big?4:3)){const n=depth===0?(big?4:3):2+(r()<.4?1:0);for(let k=0;k<n;k++){const t=.45+r()*.5;const sp=curve.getPointAt(t);const nd=d.clone().add(new T.Vector3((r()-.5)*1.8,.3+r()*.6,(r()-.5)*1.8)).normalize();branch(sp,nd,len*(.55+r()*.2),rad*.55,depth+1);}}
    else if(r()<.5){/* tufo pontiagudo e pequeno (não guarda-chuva) */const lg=MM.rockGeo(seed*13+leaves.length,.9+r()*.9,1.1+r()*.9,.9+r()*.9,0);lg.translate(p.x,p.y+.4,p.z);leaves.push(lg);}}
  const H=big?22:9+r()*7;branch(new T.Vector3(0,-1,0),new T.Vector3((r()-.5)*.3,1,(r()-.5)*.3).normalize(),H,big?2.6:.75+r()*.45,0);
  /* raízes aparentes */const nr=big?7:3;for(let k=0;k<nr;k++){const a=k/nr*Math.PI*2+r();const rp=[new T.Vector3(0,1.2,0),new T.Vector3(Math.cos(a)*1.4,.4,Math.sin(a)*1.4),new T.Vector3(Math.cos(a)*(big?6:2.6),-.6,Math.sin(a)*(big?6:2.6))];wood.push(new T.TubeGeometry(new T.CatmullRomCurve3(rp),6,big?1:.35,5,false));}
  return{wood:MM.merge(wood),veins:veins.length?MM.merge(veins):null,leaves:leaves.length?MM.merge(leaves):null};}
I.buildForest=function(ctx){const M=ctx.mat,F=I.poi.floresta,out=[];const variants=[];for(let v=0;v<12;v++)variants.push(treeGeos(1000+v*37,false));
  const r=MM.rng(808);let n=0;const placed=[];
  for(let tries=0;tries<900&&n<52;tries++){const a=r()*Math.PI*2,rr=Math.sqrt(r())*(F.r+18);let x=F.x+Math.cos(a)*rr,z=F.z+Math.sin(a)*rr;
    if(!ctx.inside(x,z)||ctx.pathDist(x,z)<4.5)continue;if(placed.some(p=>Math.hypot(p[0]-x,p[1]-z)<9))continue;if(Math.hypot(x-F.x,z-F.z)<16)continue;
    if(I.minas.some(m=>Math.hypot(m.x-x,m.z-z)<12))continue;const cb=I.poi.caverna.boca;if(Math.hypot(x-cb.x,z-cb.z)<34)continue;/* boca da caverna livre */const y=ctx.heightAt(x,z);if(y<3||y>40)continue;
    /* V2.3.1: árvore não nasce na escada nem no piso das plataformas (só desloca esta; as demais não mudam) */
    {let xx=x,zz=z;for(const pl of ctx.reg.list.filter(o=>/^STORM\.ARCH\.PLATFORM/.test(o.userData.id))){const c=Math.cos(pl.rotation.y),s=Math.sin(pl.rotation.y);const L=6+1.25*(pl.userData.degraus||0);
      for(let t=0;t<=L;t+=2){const px=pl.position.x+t*s,pz=pl.position.z+t*c;const d=Math.hypot(xx-px,zz-pz);if(d<8){xx=px+(xx-px)/(d||1)*8.5;zz=pz+(zz-pz)/(d||1)*8.5;}}}
     /* V2.3.2: nem dentro das rochas da passagem secreta (na V2.3.1 as árvores 25, 46 e 49 ficaram dentro delas) */
     for(const [rx,rz,rs] of I.rochasSecretas){const d=Math.hypot(xx-rx,zz-rz),R=rs*.9+3;if(d<R){xx=rx+(xx-rx)/(d||1)*(R+.5);zz=rz+(zz-rz)/(d||1)*(R+.5);}}
     if(xx!==x||zz!==z){if(!ctx.inside(xx,zz)||ctx.pathDist(xx,zz)<4.5)continue;x=xx;z=zz;}}
    const vg=variants[n%variants.length];const o=MM.obj('STORM.VEG.TREE.'+String(n+1).padStart(2,'0'),'Árvore retorcida '+(n+1)+' (forma '+(n%12+1)+')','Vegetation',{notes:'Forma '+(n%12+1)+' de 12. Colisão só no tronco.'});
    const sc=.75+r()*.6;const R=3.4*sc;let ym=ctx.heightAt(x,z);for(let k=0;k<24;k++){const a2=k/24*6.283;ym=Math.min(ym,ctx.heightAt(x+Math.cos(a2)*R,z+Math.sin(a2)*R));}/* V2.3.1: raízes pelo ponto mais baixo do chão em volta, não pelo centro */
    o.position.set(x,ym-.15,z);o.rotation.y=r()*Math.PI*2;o.scale.setScalar(sc);
    MM.mesh(vg.wood,M.casca,0,0,0,o);if(vg.veins){const vm=MM.mesh(vg.veins,M.veio,0,0,0,o);vm.castShadow=false;}if(vg.leaves)MM.mesh(vg.leaves,M.folhagem,0,0,0,o);
    MM.box(o,0,5,0,2.2,10,2.2);out.push(o);placed.push([x,z]);n++;}
  /* Árvore-Para-raios Ancestral: peça única no centro da floresta */
  {const g=treeGeos(4242,true);const o=MM.obj('STORM.VEG.ANCESTRAL','Árvore-Para-raios Ancestral','Vegetation',{notes:'Ponto de interesse da floresta: cristais presos nos galhos e veios mais fortes.'});/* V2.3.1: a Ancestral ficava a 1,4 stud do eixo da trilha P2 (12 de largura); vai para o ponto livre mais próximo dentro da clareira */
    let ax=F.x,az=F.z;if(ctx.pathDist(ax,az)<4.5){let ok=false;for(let rr=2;rr<=13&&!ok;rr+=1)for(let k=0;k<24&&!ok;k++){const a2=k/24*6.283;const cx=F.x+Math.cos(a2)*rr,cz=F.z+Math.sin(a2)*rr;if(ctx.pathDist(cx,cz)>=4.5){ax=cx;az=cz;ok=true;}}o.userData.movida=[+(ax-F.x).toFixed(1),+(az-F.z).toFixed(1)];}
    let y=ctx.heightAt(ax,az);for(let k=0;k<12;k++){const a2=k/12*6.283;y=Math.min(y,ctx.heightAt(ax+Math.cos(a2)*6,az+Math.sin(a2)*6));}o.position.set(ax,y-.2,az);
    MM.mesh(g.wood,M.casca,0,0,0,o);if(g.veins)MM.mesh(g.veins,M.veio,0,0,0,o).castShadow=false;if(g.leaves)MM.mesh(g.leaves,M.folhagem,0,0,0,o);
    const rr=MM.rng(9);for(let i=0;i<6;i++){const a=i/6*Math.PI*2;MM.mesh(MM.crystalGeo(.7+rr()*.5,2+rr()*2,1.6),M.cristal,Math.cos(a)*(5+rr()*4),16+rr()*10,Math.sin(a)*(5+rr()*4),o).rotation.set(rr()-.5,rr()*3,rr()-.5);}
    MM.box(o,0,10,0,6,20,6);out.push(o);}
  /* troncos caídos e flores-faísca (coleta) */
  const lg=MM.obj('STORM.VEG.UNDERGROWTH','Troncos caídos e flores-faísca','Vegetation',{notes:'Flores-faísca = pontos de coleta STORM.COLLECT.01.'});
  for(let i=0;i<9;i++){const a=r()*Math.PI*2,rr=20+r()*60;const x=F.x+Math.cos(a)*rr,z=F.z+Math.sin(a)*rr;if(!ctx.inside(x,z)||ctx.pathDist(x,z)<5)continue;const y=ctx.heightAt(x,z);
    const L=6+r()*7;const yaw=r()*6.28;const dx=Math.sin(yaw)*L/2,dz=Math.cos(yaw)*L/2;const A=new T.Vector3(x-dx,ctx.heightAt(x-dx,z-dz)+.55,z-dz),Bv=new T.Vector3(x+dx,ctx.heightAt(x+dx,z+dz)+.6,z+dz);/* tronco deitado entre dois pontos reais do chão */
    const t=MM.mesh(new T.CylinderGeometry(.7,.9,L,7),M.casca,(A.x+Bv.x)/2,(A.y+Bv.y)/2,(A.z+Bv.z)/2,lg);t.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),Bv.clone().sub(A).normalize());t.userData.apoio=true;}
  const fl=new T.MeshStandardMaterial({color:'#9fe8ff',emissive:MM.C('#43d9ff'),emissiveIntensity:.8,roughness:.4});fl.name='FlorFaisca';
  for(let i=0;i<34;i++){const a=r()*Math.PI*2,rr=r()*(F.r);const x=F.x+Math.cos(a)*rr,z=F.z+Math.sin(a)*rr;if(!ctx.inside(x,z)||ctx.pathDist(x,z)<2)continue;const y=ctx.heightAt(x,z);
    const st=MM.mesh(new T.CylinderGeometry(.06,.08,1.2,3),M.folhagem,x,y+.6,z,lg);st.castShadow=false;const b=MM.mesh(new T.OctahedronGeometry(.28,0),fl,x,y+1.3,z,lg);b.castShadow=false;}
  /* desenho instanciado: as 52 árvores viram 1 InstancedMesh por forma × material (≈ 36 chamadas em vez de ≈ 160 + sombras).
     Cada árvore continua sendo um modelo próprio (inspeção, colisão, exportação): sua malha vira um "proxy" invisível que guarda o material real. */
  {const hid=new T.MeshBasicMaterial({visible:false});hid.name='ProxyInstanciado';MM.hidMat=hid;MM.realMats=MM.realMats||{};const groups=new Map();
    out.filter(o=>o.userData.id.startsWith('STORM.VEG.TREE.')).forEach(o=>{o.updateMatrix();o.children.forEach(m=>{if(!m.isMesh)return;const k=m.geometry.uuid+'|'+m.material.uuid;if(!groups.has(k))groups.set(k,{g:m.geometry,mat:m.material,cs:m.castShadow,mats:[]});groups.get(k).mats.push(o.matrix.clone());
      MM.realMats[m.material.name]=m.material;m.userData.realMat=m.material.name;m.material=hid;});});
    groups.forEach(({g,mat,cs,mats})=>{const im=new T.InstancedMesh(g,mat,mats.length);im.name='ArvoresInstanciadas';im.userData.renderOnly=true;im.castShadow=cs;im.receiveShadow=true;mats.forEach((m,i)=>im.setMatrixAt(i,m));lg.add(im);});}
  out.push(lg);return out;};
})();
