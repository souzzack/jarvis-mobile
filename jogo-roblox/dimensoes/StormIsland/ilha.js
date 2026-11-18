/* Ilha das Tempestades · montagem
   Chama cada módulo na ordem (Terrain → Architecture → Vegetation → Resources → Props → Interactions → Lighting → Effects),
   registra cada modelo com id único e junta colisores, superfícies caminháveis e vistas de câmera. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
I.build=function(scene){const t0=performance.now();if(!MM.tex.rocha)MM.makeTextures();const mat=MM.makeMaterials(I.paleta);const reg=new MM.Registry();const root=new T.Group();root.name='Dimensions/StormIsland';scene.add(root);
  const ctx={scene,mat,reg};const terr=I.buildTerrain(ctx);ctx.terrain=terr;ctx.heightAt=terr.heightAt;ctx.inside=terr.inside;ctx.rockMat=terr.rockMat;
  ctx.pathDist=function(x,z){let m=1e9;for(const p of terr.paths){for(let s=0;s<p.S.length-1;s++){const a=p.S[s],b=p.S[s+1];if(Math.abs(x-a[0])>m+p.hw+6&&Math.abs(z-a[1])>m+p.hw+6)continue;const q=MM.segDist(x,z,a[0],a[1],b[0],b[1]);m=Math.min(m,q.d-p.hw);}}return m;};
  const folders={};const put=(list)=>list.forEach(o=>{reg.add(o);const f=o.userData.cat;if(!folders[f]){folders[f]=new T.Group();folders[f].name=f;root.add(folders[f]);}folders[f].add(o);});
  I.fixMinas(ctx);put(terr.objects);put(I.buildSurface(ctx));
  put(I.buildTower(ctx));put(I.buildVillage(ctx));put(I.buildCave(ctx));put(I.buildObservatory(ctx));put(I.buildSanctuary(ctx));put(I.buildBridges(ctx));
  put(I.buildForest(ctx));put(I.buildResources(ctx));put(I.buildDeposits(ctx));put(I.buildProps(ctx));put(I.buildMarkers(ctx));
  const light=I.buildLighting(ctx);put([light.clouds]);
  /* V2.3.2 — recorte da superfície pelo volume REAL das construções (a superfície é gerada antes delas e só evitava um raio fixo por área).
     Remove instâncias de grama, seixos, plantas, cogumelos, raízes, afloramentos e poças/depósitos cujo volume cruza um colisor de construção. */
  {root.updateMatrixWorld(true);const vols=[];reg.list.forEach(o=>{const c=o.userData.cat;if(!['Architecture','Props','Resources'].includes(c)||/ROCKS/.test(o.userData.id))return;o.updateMatrixWorld(true);
      (o.userData.colliders||[]).forEach(cc=>{const p=new T.Vector3(...cc.c).applyMatrix4(o.matrixWorld);const ry=new T.Euler().setFromRotationMatrix(o.matrixWorld,'YXZ').y+cc.ry;vols.push({p,s:cc.s,ry,id:o.userData.id});});});
    const hit=(v,r)=>vols.some(c=>{const dx=v.x-c.p.x,dz=v.z-c.p.z;const cs=Math.cos(c.ry),sn=Math.sin(c.ry);const lx=dx*cs-dz*sn,lz=dx*sn+dz*cs;return Math.abs(lx)<c.s[0]/2+r&&Math.abs(lz)<c.s[2]/2+r&&v.y<c.p.y+c.s[1]/2+r&&v.y>c.p.y-c.s[1]/2-r;});
    const surf=reg.byId['STORM.TERRAIN.SURFACE'];const rep={};const v=new T.Vector3(),sc=new T.Vector3(),q=new T.Quaternion(),mt=new T.Matrix4();surf.updateMatrixWorld(true);
    surf.traverse(m=>{if(!m.isInstancedMesh)return;if(!m.geometry.boundingSphere)m.geometry.computeBoundingSphere();const r0=m.geometry.boundingSphere.radius;let k=0;const n=m.count;
      for(let i=0;i<n;i++){m.getMatrixAt(i,mt);mt.decompose(v,q,sc);v.applyMatrix4(m.matrixWorld);const r=r0*Math.max(sc.x,sc.z)*.7;if(hit(v,r))continue;if(k!==i)m.setMatrixAt(k,mt);k++;}
      if(k<n){rep[m.name]=n-k;m.count=k;m.instanceMatrix.needsUpdate=true;}});
    ['Pocas','DepositosCristal'].forEach(nm=>{const g=surf.getObjectByName(nm);if(!g)return;g.children.slice().forEach(c=>{c.getWorldPosition(v);if(hit(v,1.5)){g.remove(c);rep[nm]=(rep[nm]||0)+1;}});});
    surf.userData.recorte=rep;}
  /* Mapa V1 (depois da limpeza acima, que mede o tamanho das plantas pela esfera da geometria): recorte da vegetação instanciada por pedaços (câmera) e, para as miudezas, por distância */
  const vegRule=m=>{const g=m.geometry,tri=(g.index?g.index.count:g.attributes.position.count)/3*m.count;if(tri<15000)return null;/* só o que pesa: malhas leves ficam como estão (cada pedaço é uma chamada a mais) */const n=m.name||'';if(/^Grama/.test(n))return{dist:150};if(/^(Seixos|Cogumelos|PedrasDeBorda|Flores|Tufos)/.test(n))return{dist:170};if(/^(Arvores|Afloramentos|Contrafortes)/.test(n))return{};return{dist:200};};
  const recVeg=MM.chunkInstanced(root,vegRule,128);
  /* funde peças estáticas por material (exceto terreno, marcadores e vegetação instanciada por forma) */
  reg.list.forEach(o=>{const id=o.userData.id;if(o.userData.cat==='Interactions'||id==='STORM.TERRAIN.MAIN'||id.startsWith('STORM.VEG.TREE.'))return;MM.bake(o);});/* árvores mantêm a geometria compartilhada (12 formas reaproveitadas, como num Roblox com MeshParts clonadas) */
  const fx=I.buildEffects(ctx);fx.light=light;
  root.updateMatrixWorld(true);
  /* colisores em coordenadas de mundo (caixas orientadas só em Y) e superfícies caminháveis */
  const colliders=[],walks=[];reg.list.forEach(o=>{o.updateMatrixWorld(true);(o.userData.colliders||[]).forEach(c=>{const p=new T.Vector3(...c.c).applyMatrix4(o.matrixWorld);const s=new T.Vector3();o.matrixWorld.decompose(new T.Vector3(),new T.Quaternion(),s);
      const ry=new T.Euler().setFromRotationMatrix(o.matrixWorld,'YXZ').y+c.ry;colliders.push({id:o.userData.id,p,s:new T.Vector3(c.s[0]*s.x,c.s[1]*s.y,c.s[2]*s.z),ry});});
    (o.userData.walk||[]).forEach(w=>walks.push(w));});
  const P=I.poi;
  const views={'Aérea':{pos:[40,560,330],tgt:[0,0,-10]},'Frontal':{pos:[0,90,470],tgt:[0,30,20]},'Três quartos':{pos:[360,210,330],tgt:[0,30,-10]},
    'Torre':{pos:[120,90,90],tgt:[P.torre.x,P.torre.h+60,P.torre.z]},'Vila':{pos:[40,60,170],tgt:[P.vila.x,P.vila.h+6,P.vila.z]},'Floresta':{pos:[-60,60,90],tgt:[P.floresta.x,20,P.floresta.z]},
    'Caverna':{pos:[-128,44,-48],tgt:[-150,32,-104]},'Observatório':{pos:[210,110,-60],tgt:[P.observatorio.x,P.observatorio.h+8,P.observatorio.z]},'Penhasco':{pos:[300,40,120],tgt:[P.penhasco.x,P.penhasco.h,P.penhasco.z]},'Ponte':{pos:[150,40,130],tgt:[114,20,89]},'Santuário (secreto)':{pos:[-190,40,190],tgt:[P.santuario.x,P.santuario.h+4,P.santuario.z]},
    'Nível do jogador':(()=>{const h=terr.heightAt(40,46);return{pos:[40,h+5.2,46],tgt:[32,h+12,-4]};})(),'Montanhas':{pos:[90,150,60],tgt:[-60,60,-170]},'Montanhas (perto)':{pos:[-30,95,-80],tgt:[-96,80,-184]},'Bordas':{pos:[330,40,150],tgt:[210,-15,40]}};
  return{id:I.id,nome:I.nome,root,reg,terrain:terr,light,fx,colliders,walks,views,recorteVegetacao:recVeg,spawn:new T.Vector3(P.chegada.x,P.chegada.h,P.chegada.z-2),ms:Math.round(performance.now()-t0),folders};};
})();
