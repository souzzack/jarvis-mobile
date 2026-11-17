/* Ilha das Tempestades · montagem
   Chama cada módulo na ordem (Terrain → Architecture → Vegetation → Resources → Props → Interactions → Lighting → Effects),
   registra cada modelo com id único e junta colisores, superfícies caminháveis e vistas de câmera. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
I.build=function(scene){const t0=performance.now();if(!MM.tex.rocha)MM.makeTextures();const mat=MM.makeMaterials(I.paleta);const reg=new MM.Registry();const root=new T.Group();root.name='Dimensions/StormIsland';scene.add(root);
  const ctx={scene,mat,reg};const terr=I.buildTerrain(ctx);ctx.terrain=terr;ctx.heightAt=terr.heightAt;ctx.inside=terr.inside;ctx.rockMat=terr.rockMat;
  ctx.pathDist=function(x,z){let m=1e9;for(const p of terr.paths){for(let s=0;s<p.S.length-1;s++){const a=p.S[s],b=p.S[s+1];if(Math.abs(x-a[0])>m+p.hw+6&&Math.abs(z-a[1])>m+p.hw+6)continue;const q=MM.segDist(x,z,a[0],a[1],b[0],b[1]);m=Math.min(m,q.d-p.hw);}}return m;};
  const folders={};const put=(list)=>list.forEach(o=>{reg.add(o);const f=o.userData.cat;if(!folders[f]){folders[f]=new T.Group();folders[f].name=f;root.add(folders[f]);}folders[f].add(o);});
  put(terr.objects);put(I.buildSurface(ctx));
  put(I.buildTower(ctx));put(I.buildVillage(ctx));put(I.buildCave(ctx));put(I.buildObservatory(ctx));put(I.buildSanctuary(ctx));put(I.buildBridges(ctx));
  put(I.buildForest(ctx));put(I.buildResources(ctx));put(I.buildProps(ctx));put(I.buildMarkers(ctx));
  const light=I.buildLighting(ctx);put([light.clouds]);
  /* funde peças estáticas por material (exceto terreno, marcadores e vegetação instanciada por forma) */
  reg.list.forEach(o=>{const id=o.userData.id;if(o.userData.cat==='Interactions'||id==='STORM.TERRAIN.MAIN'||id.startsWith('STORM.VEG.TREE.'))return;MM.bake(o);});/* árvores mantêm a geometria compartilhada (12 formas reaproveitadas, como num Roblox com MeshParts clonadas) */
  const fx=I.buildEffects(ctx);
  root.updateMatrixWorld(true);
  /* colisores em coordenadas de mundo (caixas orientadas só em Y) e superfícies caminháveis */
  const colliders=[],walks=[];reg.list.forEach(o=>{o.updateMatrixWorld(true);(o.userData.colliders||[]).forEach(c=>{const p=new T.Vector3(...c.c).applyMatrix4(o.matrixWorld);const s=new T.Vector3();o.matrixWorld.decompose(new T.Vector3(),new T.Quaternion(),s);
      const ry=new T.Euler().setFromRotationMatrix(o.matrixWorld,'YXZ').y+c.ry;colliders.push({id:o.userData.id,p,s:new T.Vector3(c.s[0]*s.x,c.s[1]*s.y,c.s[2]*s.z),ry});});
    (o.userData.walk||[]).forEach(w=>walks.push(w));});
  const P=I.poi;
  const views={'Aérea':{pos:[40,560,330],tgt:[0,0,-10]},'Frontal':{pos:[0,90,470],tgt:[0,30,20]},'Três quartos':{pos:[360,210,330],tgt:[0,30,-10]},
    'Torre':{pos:[120,90,90],tgt:[P.torre.x,P.torre.h+60,P.torre.z]},'Vila':{pos:[40,60,170],tgt:[P.vila.x,P.vila.h+6,P.vila.z]},'Floresta':{pos:[-60,60,90],tgt:[P.floresta.x,20,P.floresta.z]},
    'Caverna':{pos:[-128,44,-48],tgt:[-150,32,-104]},'Observatório':{pos:[210,110,-60],tgt:[P.observatorio.x,P.observatorio.h+8,P.observatorio.z]},'Penhasco':{pos:[300,40,120],tgt:[P.penhasco.x,P.penhasco.h,P.penhasco.z]},'Ponte':{pos:[150,40,130],tgt:[114,20,89]},'Santuário (secreto)':{pos:[-190,40,190],tgt:[P.santuario.x,P.santuario.h+4,P.santuario.z]}};
  return{id:I.id,nome:I.nome,root,reg,terrain:terr,light,fx,colliders,walks,views,spawn:new T.Vector3(P.chegada.x,P.chegada.h,P.chegada.z-2),ms:Math.round(performance.now()-t0),folders};};
})();
