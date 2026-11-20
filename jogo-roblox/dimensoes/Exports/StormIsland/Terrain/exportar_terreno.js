/* Exporta o terreno da Ilha das Tempestades em colunas de 4x4 studs (alturas, parte de baixo e material).
   Rodar no console do visualizador.html (servido localmente), depois que a ilha montar (window.__ready).
   Fonte: grade do gerador (isl.terrain.grid: H, W) + contorno (isl.terrain.inside) + malhas BASE/CLIFFS (parte de baixo).
   Usado em 20/11/2026 para gerar terreno_voxels_4studs_v2.json. Não altera nada no visualizador. */
(async()=>{const isl=window.__isl,g=isl.terrain.grid,T=THREE;
const STEP=4,X0=-300,Z0=-264,NX=Math.floor(600/STEP)+1,NZ=Math.floor(508/STEP)+1;
const cell=(x,z)=>{const i=Math.round((x-g.X0)/g.STEP),j=Math.round((z-g.Z0)/g.STEP);if(i<0||j<0||i>=g.NX||j>=g.NZ)return -1;return j*g.NX+i;};
const alvos=[];['STORM.TERRAIN.BASE','STORM.TERRAIN.CLIFFS'].forEach(id=>isl.reg.byId[id].traverse(m=>{if(m.isMesh)alvos.push(m);}));alvos.forEach(m=>m.updateMatrixWorld(true));
const rc=new T.Raycaster(),up=new T.Vector3(0,1,0);const H=[],B=[],M=[];
for(let j=0;j<NZ;j++)for(let i=0;i<NX;i++){const x=X0+i*STEP,z=Z0+j*STEP,k=cell(x,z);
  if(k<0||g.H[k]<=-50||!isl.terrain.inside(x,z)){H.push(-9999);B.push(0);M.push('-');continue;}
  const h=isl.terrain.heightAt(x,z);rc.set(new T.Vector3(x,-600,z),up);rc.far=600+h;const hit=rc.intersectObjects(alvos,false)[0];
  let b=hit?hit.point.y:h-30;if(b>h-4)b=h-4;const rock=g.W[k*4],soil=g.W[k*4+2],path=g.W[k*4+3];
  let mat='G';if(rock>0.55)mat=h>95?'S':'R';else if(path>0.45)mat='P';else if(soil>0.5)mat='D';else if(rock>0.3)mat='L';
  H.push(Math.round(h*10));B.push(Math.round(b));M.push(mat);}
const dados={passo:STEP,origem:[X0,Z0],nx:NX,nz:NZ,alturaX10:H,baixo:B,material:M.join('')};
await fetch('/Exports/StormIsland/Terrain/terreno_voxels_4studs_v2.json',{method:'PUT',body:JSON.stringify(dados)});})();
