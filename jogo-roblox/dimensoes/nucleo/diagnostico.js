/* Magnata do Multiverso · Dimensões — Diagnóstico Estrutural (V2.3.2)
   Testes automáticos sobre a cena montada + camada visual de depuração. Os testes NÃO substituem a inspeção visual: indicam onde olhar.
   Verde = validado (apoio medido em vários pontos, sem interseção, transformação válida) · Amarelo = inspecionar · Vermelho = problema confirmado.
   Um modelo só fica verde se tiver pontos de contato MEDIDOS com o chão; pivô perto do terreno não conta. */
(function(){const MM=window.MM,T=THREE;
/* exceções explícitas: o que flutua ou fica pendurado por design (fora do teste de apoio, mas listado no relatório) */
MM.excecoesFlutuacao={
  modelos:{'STORM.ARCH.CLIFF.LOOKOUT':'deck em balanço sobre o penhasco, escorado na rocha','STORM.PROP.VILLAGE.CABLES':'cabos pendurados entre para-raios e Coletor',
    'STORM.PROP.POWERLINE':'cabos pendurados entre as torres de transmissão','STORM.FX.CLOUDBANKS':'nuvens'},
  pecas:{'CaptadorDeTempestades':'anéis em cardã e cristal atmosférico (topo da torre)','Estilhaco':'fragmento de energia levitando sobre o disco rúnico',
    'Fragmento':'fragmentos de rocha flutuando em volta da ilha','MusgoFragmento':'musgo dos fragmentos flutuantes','Cachoeira':'queda d’água na borda','EixoDeEnergia':'eixo de luz do cristal'}};
const fin=m=>m.elements.every(Number.isFinite);
const obbCorners=c=>{const cs=Math.cos(c.ry),sn=Math.sin(c.ry);return[[-1,-1],[1,-1],[1,1],[-1,1]].map(([a,b])=>{const lx=a*c.s.x/2,lz=b*c.s.z/2;return[c.p.x+lx*cs+lz*sn,c.p.z-lx*sn+lz*cs];});};
const sat=(A,B)=>{for(const P of [A,B])for(let i=0;i<4;i++){const p=P[i],q=P[(i+1)%4];const nx=-(q[1]-p[1]),nz=q[0]-p[0];const pr=Q=>Q.map(([x,z])=>x*nx+z*nz);const a=pr(A),b=pr(B);if(Math.max(...a)<=Math.min(...b)+1e-3||Math.max(...b)<=Math.min(...a)+1e-3)return false;}return true;};
MM.structuralTests=function(isl,supAt,opts){opts=opts||{};const X=MM.excecoesFlutuacao;const R={modelos:{},globais:{},t0:performance.now()};const st=id=>R.modelos[id]||(R.modelos[id]={status:'verde',motivos:[],info:{}});
  const bad=(id,m)=>{const s=st(id);s.status='vermelho';s.motivos.push(m);};const warn=(id,m)=>{const s=st(id);if(s.status!=='vermelho')s.status='amarelo';s.motivos.push(m);};
  const models=isl.reg.list.filter(o=>!['Terrain','Lighting','Interactions'].includes(o.userData.cat));
  /* 1. transformações, pivô, geometria, material */
  models.forEach(o=>{const id=o.userData.id;st(id);o.updateMatrixWorld(true);const box=new T.Box3();
    o.traverse(c=>{if(!fin(c.matrixWorld))bad(id,'matriz não finita em '+(c.name||c.type));const s=new T.Vector3();c.matrixWorld.decompose(new T.Vector3(),new T.Quaternion(),s);
      if(Math.min(Math.abs(s.x),Math.abs(s.y),Math.abs(s.z))<1e-3)bad(id,'escala ≈ 0 em '+(c.name||c.type));if(c.matrixWorld.determinant()<0)bad(id,'escala negativa (espelhado) em '+(c.name||c.type));
      if(!c.isMesh)return;if(!c.material)bad(id,'material ausente');const pa=c.geometry.attributes.position;for(let i=0;i<pa.array.length;i+=7)if(!Number.isFinite(pa.array[i])){bad(id,'geometria com NaN');break;}
      if(!c.isInstancedMesh){if(!c.geometry.boundingBox)c.geometry.computeBoundingBox();box.union(c.geometry.boundingBox.clone().applyMatrix4(c.matrixWorld));}});
    const e=new T.Euler().setFromQuaternion(o.quaternion,'YXZ');if(Math.abs(e.x)>.001||Math.abs(e.z)>.001)warn(id,'modelo inclinado (rotação X/Z)');
    const piv=new T.Vector3().setFromMatrixPosition(o.matrixWorld);const sz=box.isEmpty()?0:box.getSize(new T.Vector3()).length();
    if(!box.isEmpty()&&piv.length()>1e-6&&!box.clone().expandByScalar(Math.max(5,sz*.25)).containsPoint(piv))bad(id,'pivô fora da geometria (deslocamento duplicado?)');
    (o.userData.colliders||[]).forEach((c,i)=>{const w=new T.Vector3(...c.c).applyMatrix4(o.matrixWorld);if(!box.isEmpty()&&!box.clone().expandByScalar(1).containsPoint(w))bad(id,'colisor '+i+' fora da geometria');});
    const s=st(id);s.box=box;s.pivo=piv;s.rot=o.rotation.y;s.info.escala=o.scale.toArray().map(v=>+v.toFixed(2));});
  /* 2. interseção entre volumes de colisão de modelos diferentes */
  const C=isl.colliders,CC=C.map(obbCorners);let nI=0;
  for(let i=0;i<C.length;i++)for(let j=i+1;j<C.length;j++){const a=C[i],b=C[j];if(a.id===b.id)continue;const L=(a.s.x+a.s.z+b.s.x+b.s.z)/1.4;if(Math.abs(a.p.x-b.p.x)>L||Math.abs(a.p.z-b.p.z)>L)continue;
    if(a.p.y+a.s.y/2<=b.p.y-b.s.y/2||b.p.y+b.s.y/2<=a.p.y-a.s.y/2)continue;if(sat(CC[i],CC[j])){nI++;bad(a.id,'atravessa '+b.id);bad(b.id,'atravessa '+a.id);}}
  R.globais.intersecoes=nI;
  /* 3. peças de outro modelo e instâncias de superfície dentro do volume de uma construção */
  const vol=C.filter(c=>{const o=isl.reg.byId[c.id];const k=o&&o.userData.cat;return(k==='Architecture'||k==='Props'||k==='Resources')&&!/ROCKS/.test(c.id);});
  const inside=(x,y,z,c,m)=>{const dx=x-c.p.x,dz=z-c.p.z;const cs=Math.cos(c.ry),sn=Math.sin(c.ry);const lx=dx*cs-dz*sn,lz=dx*sn+dz*cs;return Math.abs(lx)<c.s.x/2-m&&Math.abs(lz)<c.s.z/2-m&&y>c.p.y-c.s.y/2+m&&y<c.p.y+c.s.y/2-m;};
  const v=new T.Vector3(),mt=new T.Matrix4();let nInst=0;const instPor={};
  isl.reg.list.forEach(o=>{const id=o.userData.id;if(['Lighting','Interactions'].includes(o.userData.cat)||id==='STORM.TERRAIN.MAIN')return;
    o.traverse(m=>{if(!m.isMesh)return;if(m.isInstancedMesh){for(let i=0;i<m.count;i++){m.getMatrixAt(i,mt);v.setFromMatrixPosition(mt).applyMatrix4(m.matrixWorld);v.y+=.5;for(const c of vol){if(c.id===id)continue;if(inside(v.x,v.y,v.z,c,.3)){nInst++;instPor[c.id]=(instPor[c.id]||0)+1;}}}return;}
      if(m.material&&m.material.visible===false&&!m.userData.realMat)return;const pa=m.geometry.attributes.position;const k=Math.max(1,Math.floor(pa.count/300));let n=0,alvo=null;
      for(let i=0;i<pa.count;i+=k){v.fromBufferAttribute(pa,i).applyMatrix4(m.matrixWorld);for(const c of vol){if(c.id===id)continue;if(inside(v.x,v.y,v.z,c,.3)){n++;alvo=c.id;}}}
      const anc=(o.userData.ancoras||[]).includes(alvo);/* cabo preso na própria âncora (torre de transmissão, para-raios) não é interseção */
      if(n>2&&!X.modelos[id]){bad(id,'peças dentro de '+alvo+' ('+n+' vértices)');bad(alvo,'atravessado por '+id);}
      else if(n>2&&!anc)warn(alvo,id+' passa por dentro ('+n+' vértices)');});});
  Object.entries(instPor).forEach(([id,n])=>{if(n>3)warn(id,n+' instâncias de superfície dentro do volume');});R.globais.instanciasDentro=nInst;
  /* 4. apoio medido por raio vertical (exceções fora) */
  const a=MM.supportAudit(models.filter(o=>!X.modelos[o.userData.id]),supAt,{teto:id=>id.startsWith('STORM.VEG.')?2:4});R.apoio=a;
  a.models.forEach(m=>{if(!m.colunas)return;const s=st(m.id);s.info.apoio={contato:m.contato,folga:m.folga,suspenso:m.suspenso,enterrado:m.enterrado,maior:m.maxFolga};
    if(m.suspenso>0){const tol=(opts.toleranciaSuspensa||{})[m.id];if(tol&&m.suspenso<=tol.n&&m.maxFolga<=tol.max)warn(m.id,'trecho suspenso conhecido: '+tol.motivo);else if(/^STORM\.VEG\./.test(m.id)&&m.suspenso<=1&&m.maxFolga<=2)warn(m.id,'raiz orgânica em arco a '+m.maxFolga+' do chão (inspecionar)');else bad(m.id,m.suspenso+' ponto(s) suspenso(s), folga até '+m.maxFolga);}
    else if(m.folga>Math.max(2,m.colunas*.1))warn(m.id,m.folga+' pontos com folga ≤ 1,5');});
  models.forEach(o=>{const id=o.userData.id;const s=st(id);if(X.modelos[id]){s.excecao=X.modelos[id];return;}if(!s.info.apoio&&s.status==='verde')warn(id,'sem ponto de apoio medido');});
  /* 5. rotas (se o visualizador passou o teste de caminhada) */
  if(opts.rotas){R.rotas={};opts.rotas.forEach(([nome,pts,ids])=>{const r=opts.walk(pts);R.rotas[nome]=r;if(!r.ok)(ids||[]).forEach(id=>bad(id,'rota "'+nome+'" interrompida: '+r.motivo));});}
  const cnt={verde:0,amarelo:0,vermelho:0};Object.values(R.modelos).forEach(s=>cnt[s.status]++);R.contagem=cnt;R.ms=Math.round(performance.now()-R.t0);return R;};
/* rotas ao nível do jogador que o diagnóstico percorre (mesmas regras do boneco). [nome, pontos, modelos que dependem dela] */
MM.rotasDaIlha=function(isl,P){const R=isl.reg.byId;const W=(o,lx,lz)=>{const c=Math.cos(o.rotation.y),s=Math.sin(o.rotation.y);return[o.position.x+lx*c+lz*s,o.position.z-lx*s+lz*c];};const out=[];const c=P.caminhos;
  const p1=c[0].pts.map(p=>p.slice());const ip=p1.findIndex(p=>p[0]===-34&&p[1]===92);if(ip>0)p1.splice(ip,1,[-24,100],[-24,84]);/* contorna o Coletor dentro da praça */
  out.push(['P1 chegada → torre',p1,[]]);c.slice(1).forEach(cc=>out.push([cc.id+' '+cc.nome,cc.pts,[]]));
  const tw=R['STORM.ARCH.TOWER'];out.push(['torre: pé da escada → porta',[p1[p1.length-1],W(tw,0,26)],['STORM.ARCH.TOWER']]);
  const ob=R['STORM.ARCH.OBSERVATORY'];const p4=c[3].pts;out.push(['observatório: P4 → porta',[p4[p4.length-1],W(ob,0,22),W(ob,0,16.2)],['STORM.ARCH.OBSERVATORY']]);
  const cb=P.poi.caverna.boca;const p2=c[1].pts;out.push(['caverna: P2 → câmara',[p2[p2.length-1],[cb.x,cb.z+6],[cb.x,cb.z-4],[cb.x+2,cb.z-16],[cb.x-3,cb.z-32],[-150,-140],[-150,-150]],['STORM.ARCH.CAVE.MOUTH','STORM.ARCH.CAVE.TUNNEL']]);
  const sa=R['STORM.ARCH.SANCTUARY'];const p5=c[4].pts;out.push(['santuário: P5 → altar',[p5[p5.length-1],[sa.position.x,sa.position.z+6]],['STORM.ARCH.SANCTUARY']]);
  out.push(['chegada: doca → P1',[[P.poi.chegada.x,P.poi.chegada.z+10],c[0].pts[0]],['STORM.ARCH.ARRIVAL']]);
  const lk=R['STORM.ARCH.CLIFF.LOOKOUT'];const p3=c[2].pts;out.push(['mirante: P3 → deck',[p3[p3.length-1],W(lk,0,8),W(lk,0,14)],[]]);
  P.minas.forEach(m=>{if(m.interno)return;let best=null,bd=1e9;c.forEach(cc=>cc.pts.forEach(p=>{const d=Math.hypot(p[0]-m.x,p[1]-m.z);if(d<bd){bd=d;best=p;}}));const dx=m.x-best[0],dz=m.z-best[1],L=Math.hypot(dx,dz)||1;out.push(['mina '+m.id.slice(-2)+': trilha → frente',[best,[m.x-dx/L*7,m.z-dz/L*7]],[m.id.replace('MINE','RES.MINE')]]);});
  isl.reg.list.filter(o=>/^STORM\.ARCH\.PLATFORM/.test(o.userData.id)).forEach(o=>{const d=o.userData.degraus||10;out.push([o.userData.id.slice(11)+': escada → piso',[W(o,0,6+1.25*d+3),W(o,0,7),W(o,0,0)],[o.userData.id]]);});
  isl.reg.list.filter(o=>/HOUSE/.test(o.userData.id)).forEach(o=>{const fr=o.userData.foot.d/2;out.push(['porta '+o.userData.id.slice(11),[W(o,0,fr+12),W(o,0,fr+1.8)],[o.userData.id]]);});
  {const o=R['STORM.ARCH.WORKSHOP'];out.push(['oficina: frente → interior',[W(o,0,16),W(o,0,2)],['STORM.ARCH.WORKSHOP']]);}
  {const b=P.pontes[0];const dx=b.b[0]-b.a[0],dz=b.b[1]-b.a[1],L=Math.hypot(dx,dz);out.push(['ponte: travessia',[[b.a[0]-dx/L*8,b.a[1]-dz/L*8],[b.b[0]+dx/L*8,b.b[1]+dz/L*8]],[b.id]]);}
  return out;};
/* camada visual: caixa de cada modelo na cor do estado, pivô e eixos locais; pontos de apoio e lacunas vêm de MM.supportDebug */
MM.structuralDebug=function(isl,R){const g=new T.Group();g.name='DiagnosticoEstrutural';const cor={verde:0x3ee07a,amarelo:0xffd23f,vermelho:0xff3b3b};
  const piv=new T.SphereGeometry(.6,8,6);Object.entries(R.modelos).forEach(([id,s])=>{if(!s.box||s.box.isEmpty())return;const h=new T.Box3Helper(s.box,cor[s.status]);h.material.depthTest=false;h.material.transparent=true;h.material.opacity=.85;h.renderOrder=998;h.userData.diagId=id;g.add(h);
    const p=new T.Mesh(piv,new T.MeshBasicMaterial({color:cor[s.status],depthTest:false}));p.position.copy(s.pivo);p.renderOrder=999;g.add(p);
    const ax=new T.AxesHelper(Math.max(2.5,Math.min(12,s.box.getSize(new T.Vector3()).length()*.12)));ax.position.copy(s.pivo);ax.rotation.y=s.rot||0;ax.material.depthTest=false;ax.renderOrder=999;g.add(ax);});
  g.add(MM.supportDebug(R.apoio));g.children[g.children.length-1].visible=true;return g;};
})();
