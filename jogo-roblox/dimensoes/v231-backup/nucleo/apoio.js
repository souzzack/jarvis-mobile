/* Magnata do Multiverso · Dimensões — auditoria de apoio (V2.3.1)
   Para cada modelo que deve estar apoiado: varre a projeção dele no chão numa grade e lança um raio VERTICAL de baixo para cima
   contra as peças de base (as que chegam até 1 stud acima do ponto mais baixo do modelo, ou marcadas com userData.apoio).
   O primeiro ponto atingido é comparado com a superfície de apoio naquela coluna (terreno exato, ou piso de túnel/ponte).
   Não usa o pivô: cada coluna é um ponto de contato. Resultado por modelo + pontos para o modo de depuração.
   Classes: contato (|folga| ≤ 0,35) · folga (0,35–1,5) · suspenso (> 1,5) · enterrado (< −0,35; normal em alicerces).
   Modelos com userData.flutua (intencional) e peças dentro de grupos userData.flutua/animated ficam de fora. */
(function(){const MM=window.MM,T=THREE;
MM.supportAudit=function(models,groundAt,opts){opts=opts||{};const ray=new T.Raycaster();ray.far=400;const nm=new T.Matrix3(),nv=new T.Vector3();const up=new T.Vector3(0,1,0);const out={models:[],pts:[]};
  const box=new T.Box3(),tmp=new T.Box3();
  models.forEach(o=>{const u=o.userData;if(u.flutua){out.models.push({id:u.id,nome:o.name||u.nome,intencional:u.flutua});return;}
    o.updateMatrixWorld(true);const meshes=[];
    o.traverse(m=>{if(!m.isMesh||m.isInstancedMesh)return;let p=m,skip=false;while(p&&p!==o){if(p.userData&&(p.userData.flutua||p.userData.float))skip=true;p=p.parent;}if(skip||m.userData.semApoio)return;
      if(m.material&&m.material.visible===false&&!m.userData.realMat)return;if(!m.geometry.boundingBox)m.geometry.computeBoundingBox();tmp.copy(m.geometry.boundingBox).applyMatrix4(m.matrixWorld);meshes.push({m,b:tmp.clone()});});
    if(!meshes.length)return;const minY=Math.min(...meshes.map(q=>q.b.min.y));
    const base=meshes.filter(q=>{if(q.m.userData.apoio)return true;const g=groundAt((q.b.min.x+q.b.max.x)/2,(q.b.min.z+q.b.max.z)/2,q.b.min.y);return g!==null&&q.b.min.y<=g+4;});/* peças cuja base fica a menos de 4 studs do chão = peças de apoio */if(!base.length)return;box.makeEmpty();base.forEach(q=>box.union(q.b));
    const sx=box.max.x-box.min.x,sz=box.max.z-box.min.z;const st=Math.max(.75,Math.sqrt(sx*sz/(opts.maxRays||420)));const objs=base.map(q=>q.m);
    const r={id:u.id,nome:u.nome||o.name,cat:u.cat,contato:0,folga:0,suspenso:0,enterrado:0,colunas:0,maxFolga:-1e9,piorPonto:null,minFolga:1e9};
    for(let x=box.min.x+st/2;x<box.max.x;x+=st)for(let z=box.min.z+st/2;z<box.max.z;z+=st){ray.set(new T.Vector3(x,box.min.y-30,z),up);const hit=ray.intersectObjects(objs,false)[0];if(!hit)continue;
      const y=hit.point.y;const g=groundAt(x,z,y);if(g===null||g<-150)continue;const gap=y-g;
      /* só conta superfície virada para baixo (fundo real da peça); flanco arredondado de rocha ou raiz é contorno, não base */
      const inB=(L)=>L&&L.some(b=>x>=b[0]-.05&&x<=b[3]+.05&&y>=b[1]-.05&&y<=b[4]+.05&&z>=b[2]-.05&&z<=b[5]+.05);if(inB(u.semApoioBoxes)&&!inB(u.apoioBoxes))continue;const ehApoio=hit.object.userData.apoio||inB(u.apoioBoxes);
      if(hit.face){nm.getNormalMatrix(hit.object.matrixWorld);nv.copy(hit.face.normal).applyMatrix3(nm).normalize();if(nv.y>-.75&&gap>.35)continue;}
      /* acima do teto (4 studs; 2 nas árvores) e sem marca de apoio = beiral, galho ou balanço: não é a base */const teto=(opts.teto&&opts.teto(u.id))||4;if(gap>teto&&!ehApoio)continue;
      r.colunas++;let cls;if(gap<-.35){cls=3;r.enterrado++;}else if(gap<=.35){cls=0;r.contato++;}else if(gap<=1.5){cls=1;r.folga++;}else{cls=2;r.suspenso++;}
      if(gap>r.maxFolga){r.maxFolga=gap;r.piorPonto=[+x.toFixed(1),+y.toFixed(1),+z.toFixed(1)];}r.minFolga=Math.min(r.minFolga,gap);out.pts.push(x,y,z,g,cls);}
    if(r.colunas)out.models.push(r);});
  out.models.forEach(r=>{if(r.colunas){r.maxFolga=+r.maxFolga.toFixed(2);r.minFolga=+r.minFolga.toFixed(2);r.semApoio=r.suspenso>0;}});
  return out;};
/* modo de depuração: pontos de contato coloridos + linhas da folga até o chão */
MM.supportDebug=function(audit){const g=new T.Group();g.name='DepuracaoApoio';const P=audit.pts;const n=P.length/5;const cols=[MM.C('#3ee07a'),MM.C('#ffd23f'),MM.C('#ff3b3b'),MM.C('#4aa3ff')];
  const im=new T.InstancedMesh(new T.BoxGeometry(.5,.5,.5),new T.MeshBasicMaterial({color:0xffffff,depthTest:false,transparent:true,opacity:.9}),n);im.renderOrder=999;const d=new T.Object3D();const L=[];
  for(let i=0;i<n;i++){const x=P[i*5],y=P[i*5+1],z=P[i*5+2],gy=P[i*5+3],c=P[i*5+4];d.position.set(x,y,z);d.updateMatrix();im.setMatrixAt(i,d.matrix);im.setColorAt(i,cols[c]);if(c===1||c===2)L.push(x,y,z,x,gy,z);}
  im.instanceMatrix.needsUpdate=true;if(im.instanceColor)im.instanceColor.needsUpdate=true;g.add(im);
  const lg=new T.BufferGeometry();lg.setAttribute('position',new T.Float32BufferAttribute(L,3));const ls=new T.LineSegments(lg,new T.LineBasicMaterial({color:MM.C('#ff6a6a'),depthTest:false}));ls.renderOrder=999;g.add(ls);g.visible=false;return g;};
})();
