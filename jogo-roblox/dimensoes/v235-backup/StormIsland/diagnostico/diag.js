(async()=>{const T=THREE,MM=window.MM,isl=window.__isl,R=isl.reg.byId,P=MM.islands.StormIsland,H=isl.terrain.heightAt;const out={modelos:[],transform:[],pivo:[],geometria:[],material:[],intersecoes:[],colisorFora:[],terrenoVsMalha:null,rotas:{},ocultos:[]};
const box=new T.Box3(),tb=new T.Box3();const fin=m=>m.elements.every(Number.isFinite);
isl.reg.list.forEach(o=>{const u=o.userData;o.updateMatrixWorld(true);let nm=0,tris=0;const mats=new Set();box.makeEmpty();
  o.traverse(c=>{if(!fin(c.matrixWorld))out.transform.push([u.id,c.name||c.type,'matriz não finita']);const s=new T.Vector3(),q=new T.Quaternion(),p=new T.Vector3();c.matrixWorld.decompose(p,q,s);
    if(Math.min(Math.abs(s.x),Math.abs(s.y),Math.abs(s.z))<1e-3)out.transform.push([u.id,c.name||c.type,'escala ~0']);if(c.matrixWorld.determinant()<0)out.transform.push([u.id,c.name||c.type,'escala negativa (espelhado)']);
    if(c.children.length&&c.scale&&(Math.abs(c.scale.x-c.scale.y)>.01||Math.abs(c.scale.y-c.scale.z)>.01))out.transform.push([u.id,c.name||c.type,'escala não uniforme em grupo com filhos']);
    if(!c.isMesh)return;nm++;const g=c.geometry;const pa=g.attributes.position;if(!pa){out.geometria.push([u.id,c.name,'sem posições']);return;}
    for(let i=0;i<pa.array.length;i++)if(!Number.isFinite(pa.array[i])){out.geometria.push([u.id,c.name||'(sem nome)','NaN/Inf na geometria']);break;}
    tris+=(g.index?g.index.count:pa.count)/3*(c.isInstancedMesh?c.count:1);
    if(!c.material)out.material.push([u.id,c.name,'material ausente']);else{const ms=Array.isArray(c.material)?c.material:[c.material];ms.forEach(m=>{mats.add(m.name||m.type);if(m.visible===false&&!c.userData.realMat)out.ocultos.push([u.id,c.name||'(sem nome)','material invisível sem proxy']);if(m.transparent&&m.opacity<.02)out.ocultos.push([u.id,c.name,'opacidade ~0']);});}
    if(!c.visible)out.ocultos.push([u.id,c.name||'(sem nome)','malha invisível']);if(c.isInstancedMesh&&c.count===0)out.ocultos.push([u.id,c.name,'instâncias = 0']);
    if(!g.boundingBox)g.computeBoundingBox();tb.copy(g.boundingBox).applyMatrix4(c.matrixWorld);const sz=tb.getSize(new T.Vector3());if(sz.x<1e-4&&sz.y<1e-4&&sz.z<1e-4)out.geometria.push([u.id,c.name,'geometria de tamanho zero']);
    if(!c.isInstancedMesh)box.union(tb);});
  const piv=new T.Vector3().setFromMatrixPosition(o.matrixWorld);const sz=box.isEmpty()?new T.Vector3():box.getSize(new T.Vector3());const exp=box.clone().expandByScalar(Math.max(5,.25*Math.max(sz.x,sz.y,sz.z)));
  const colecao=piv.length()<1e-6;if(!box.isEmpty()&&!exp.containsPoint(piv)&&!colecao)out.pivo.push([u.id,'pivô fora da geometria',piv.toArray().map(v=>+v.toFixed(1)),box.min.toArray().map(v=>+v.toFixed(1)),box.max.toArray().map(v=>+v.toFixed(1))]);
  const e=new T.Euler().setFromQuaternion(o.quaternion,'YXZ');const tilt=Math.max(Math.abs(e.x),Math.abs(e.z));
  const gp=H(piv.x,piv.z);out.modelos.push({id:u.id,nome:u.nome,cat:u.cat,pivo:piv.toArray().map(v=>+v.toFixed(1)),chaoNoPivo:+gp.toFixed(1),rotY:+e.y.toFixed(2),inclinacao:+tilt.toFixed(3),escala:o.scale.toArray().map(v=>+v.toFixed(2)),malhas:nm,tris:Math.round(tris),mats:mats.size,
    bb:box.isEmpty()?null:[box.min.y,box.max.y].map(v=>+v.toFixed(1)),colecao,colisores:(u.colliders||[]).length,assento:u.assento||null});
  /* colisores fora da geometria do próprio modelo */
  (u.colliders||[]).forEach((c,i)=>{const w=new T.Vector3(...c.c).applyMatrix4(o.matrixWorld);if(!box.isEmpty()&&!box.clone().expandByScalar(1).containsPoint(w))out.colisorFora.push([u.id,i,w.toArray().map(v=>+v.toFixed(1))]);});});
/* interseções entre colisores de modelos diferentes (caixas orientadas em Y, teste de eixos separadores no plano + sobreposição vertical) */
const C=isl.colliders;const corners=c=>{const cs=Math.cos(c.ry),sn=Math.sin(c.ry);return[[-1,-1],[1,-1],[1,1],[-1,1]].map(([a,b])=>{const lx=a*c.s.x/2,lz=b*c.s.z/2;return[c.p.x+lx*cs+lz*sn,c.p.z-lx*sn+lz*cs];});};
const sat=(A,B)=>{const ax=[];[A,B].forEach(P=>{for(let i=0;i<4;i++){const p=P[i],q=P[(i+1)%4];ax.push([-(q[1]-p[1]),q[0]-p[0]]);}});for(const [nx,nz] of ax){const pr=P=>P.map(([x,z])=>x*nx+z*nz);const a=pr(A),b=pr(B);if(Math.max(...a)<=Math.min(...b)+1e-3||Math.max(...b)<=Math.min(...a)+1e-3)return false;}return true;};
const CC=C.map(corners);const seen=new Set();
for(let i=0;i<C.length;i++)for(let j=i+1;j<C.length;j++){const a=C[i],b=C[j];if(a.id===b.id)continue;if(Math.abs(a.p.x-b.p.x)>(a.s.x+a.s.z+b.s.x+b.s.z)/1.4||Math.abs(a.p.z-b.p.z)>(a.s.x+a.s.z+b.s.x+b.s.z)/1.4)continue;
  if(a.p.y+a.s.y/2<=b.p.y-b.s.y/2||b.p.y+b.s.y/2<=a.p.y-a.s.y/2)continue;if(sat(CC[i],CC[j])){const k=[a.id,b.id].sort().join(' × ');if(!seen.has(k)){seen.add(k);out.intersecoes.push([a.id,b.id,[(a.p.x+b.p.x)/2,(a.p.z+b.p.z)/2].map(v=>+v.toFixed(1))]);}}}
/* terreno: altura consultada × malha desenhada (raio vertical na malha LOD0) */
{const ray=new T.Raycaster();const meshes=[];R['STORM.TERRAIN.MAIN'].traverse(m=>{if(m.isMesh&&m.name==='TerrenoLOD0')meshes.push(m);});let mx=0,n=0,at=null;const rr=MM.rng(5);
  for(let k=0;k<400;k++){const x=-250+rr()*500,z=-200+rr()*380;if(!isl.terrain.inside(x,z))continue;ray.set(new T.Vector3(x,500,z),new T.Vector3(0,-1,0));const h=ray.intersectObjects(meshes,false)[0];if(!h)continue;const d=Math.abs(h.point.y-H(x,z));n++;if(d>mx){mx=d;at=[x,z].map(v=>+v.toFixed(1));}}
  out.terrenoVsMalha={amostras:n,maiorDiferenca:+mx.toFixed(3),onde:at};}
/* rotas ao nível do jogador (mesmas regras do boneco) */
const W=(o,lx,lz)=>{const c=Math.cos(o.rotation.y),s=Math.sin(o.rotation.y);return[o.position.x+lx*c+lz*s,o.position.z-lx*s+lz*c];};const f=r=>r.ok?'ok (maior degrau '+r.maiorSubida+')':'FALHA: '+r.motivo+' '+(r.id||r.sobe||'')+' em '+r.em;
const wt=(n,p,y)=>{out.rotas[n]=f(window.__walkTest(p,y));};
const c=P.caminhos;const p1=c[0].pts.map(p=>p.slice());const ip=p1.findIndex(p=>p[0]===-34&&p[1]===92);if(ip>0)p1.splice(ip,1,[-24,100],[-24,84]);wt('P1 chegada→torre',p1);c.slice(1).forEach(cc=>wt(cc.id+' '+cc.nome.slice(0,28),cc.pts));
const tw=R['STORM.ARCH.TOWER'];wt('torre: pé da escada→porta',[p1[p1.length-1],W(tw,0,25)]);
const ob=R['STORM.ARCH.OBSERVATORY'];const p4=c[3].pts;wt('observatório: fim da P4→porta',[p4[p4.length-1],W(ob,0,22),W(ob,0,15.4)]);
const cb=P.poi.caverna.boca;const p2=c[1].pts;wt('caverna: fim da P2→câmara',[p2[p2.length-1],[cb.x,cb.z+6],[cb.x,cb.z-4],[cb.x+2,cb.z-16],[cb.x-3,cb.z-32],[-150,-140],[-150,-150]]);
const sa=R['STORM.ARCH.SANCTUARY'];const p5=c[4].pts;wt('santuário: fim da P5→altar',[p5[p5.length-1],[sa.position.x,sa.position.z+6]]);
wt('chegada: doca→P1',[[P.poi.chegada.x,P.poi.chegada.z+10],c[0].pts[0]]);
const lk=R['STORM.ARCH.CLIFF.LOOKOUT'];const p3=c[2].pts;wt('mirante: fim da P3→deck',[p3[p3.length-1],W(lk,0,8),W(lk,0,14)]);
P.minas.forEach(m=>{if(m.interno)return;let best=null,bd=1e9;c.forEach(cc=>cc.pts.forEach(p=>{const d=Math.hypot(p[0]-m.x,p[1]-m.z);if(d<bd){bd=d;best=p;}}));const dx=m.x-best[0],dz=m.z-best[1],L=Math.hypot(dx,dz)||1;wt('mina '+m.id.slice(-2)+': trilha→frente',[best,[m.x-dx/L*7,m.z-dz/L*7]]);});
['STORM.ARCH.PLATFORM.01','STORM.ARCH.PLATFORM.02'].forEach(id=>{const o=R[id];const d=o.userData.degraus||10;wt(id.slice(-11)+': escada→piso',[W(o,0,6+1.25*d+3),W(o,0,7),W(o,0,0)]);});
isl.reg.list.filter(o=>/HOUSE/.test(o.userData.id)).forEach(o=>{const fr=o.userData.foot.d/2;wt('porta '+o.userData.id.slice(-8),[W(o,0,fr+12),W(o,0,fr+1.8)]);});
{const o=R['STORM.ARCH.WORKSHOP'];wt('oficina: frente→interior',[W(o,0,16),W(o,0,2)]);}
{const b=P.pontes[0];const dx=b.b[0]-b.a[0],dz=b.b[1]-b.a[1],L=Math.hypot(dx,dz);wt('ponte: travessia',[[b.a[0]-dx/L*8,b.a[1]-dz/L*8],[b.b[0]+dx/L*8,b.b[1]+dz/L*8]]);}
/* apoio */
const a=window.__supportAudit();out.apoio=a.models.filter(m=>m.colunas).map(m=>[m.id,m.contato,m.folga,m.suspenso,m.enterrado,m.maxFolga,m.minFolga]);out.apoioIntencional=a.models.filter(m=>m.intencional).map(m=>[m.id,m.intencional]);
window.__diag=out;return 'ok';})()
