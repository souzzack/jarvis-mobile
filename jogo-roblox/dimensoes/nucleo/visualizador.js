/* Magnata do Multiverso · Atlas das Dimensões — visualizador (compartilhado pelas seis ilhas)
   Câmera livre (órbita) e modo caminhada com o boneco de escala (valores padrão do Roblox: WalkSpeed 16, JumpHeight 7,2, gravidade 196,2),
   inspeção de modelos, camadas (efeitos, chuva, colisões, marcadores, rótulos, escala), vistas e exportação do pacote. */
(function(){const MM=window.MM,T=THREE;const $=id=>document.getElementById(id);
const ISLANDS=[['StormIsland','Ilha das Tempestades','#43d9ff'],['BubbleField','Campo das Bolhas','#3fe0c8'],['VolcanoIsland','Ilha dos Vulcões','#ff7a1a'],['FrozenCity','Cidade Congelada','#7fd8ff'],['GiantBack','Costas do Gigante','#c9a24a'],['LostAndFound','Achados e Perdidos','#e040c8']];
const WALK={speed:16,jump:Math.sqrt(2*196.2*7.2),g:196.2,step:2.6,r:1.1,h:5.2};
MM.startViewer=function(){const stage=$('stage');const status=$('status');
  const renderer=new T.WebGLRenderer({antialias:true,powerPreference:'high-performance'});renderer.outputEncoding=T.sRGBEncoding;renderer.toneMapping=T.ACESFilmicToneMapping;renderer.toneMappingExposure=1.08;
  renderer.shadowMap.enabled=true;renderer.shadowMap.type=T.PCFSoftShadowMap;stage.insertBefore(renderer.domElement,stage.firstChild);
  MM.renderer=renderer;const scene=new T.Scene();const cam=new T.PerspectiveCamera(55,1,.5,6000);const controls=new T.OrbitControls(cam,renderer.domElement);controls.enableDamping=true;controls.maxPolarAngle=Math.PI*.495;controls.minDistance=4;controls.maxDistance=1700;
  const clayMat=new T.MeshStandardMaterial({color:0xb8b5ae,roughness:.85});const S={clay:false,quality:matchMedia('(pointer:coarse)').matches||innerWidth<700?'low':'high',fx:true,rain:true,full:true,neutral:false,support:false,oficina:false,telhado:false,frente:false,cols:false,marks:true,labels:innerWidth>=700,scale:true,mode:'orbit',sel:null,isolated:false,island:null};
  let composer=null,bloom=null;
  function resize(){const w=stage.clientWidth,h=stage.clientHeight;renderer.setPixelRatio(S.quality==='low'?1:Math.min(devicePixelRatio||1,2));renderer.setSize(w,h,false);cam.aspect=w/h;cam.updateProjectionMatrix();if(composer){composer.setPixelRatio(renderer.getPixelRatio());composer.setSize(w,h);}}
  new ResizeObserver(resize).observe(stage);
  if(T.EffectComposer&&T.UnrealBloomPass){composer=new T.EffectComposer(renderer);composer.addPass(new T.RenderPass(scene,cam));bloom=new T.UnrealBloomPass(new T.Vector2(256,256),.3,.45,.88);/* contido: cristais brilham sem perder o desenho */composer.addPass(bloom);}
  resize();
  /* ---- lista de ilhas (só a piloto está construída) ---- */
  $('islands').innerHTML=ISLANDS.map(([id,n,c],i)=>`<li><button class="isl${i?'':' on'}" ${i?'disabled':''} data-id="${id}"><span class="dot" style="--c:${c}"></span><span>${n}</span><em>${i?'aguardando aprovação':'piloto'}</em></button></li>`).join('');
  /* ---- montagem ---- */
  status.textContent='Construindo a Ilha das Tempestades…';
  setTimeout(()=>{try{build();}catch(e){status.textContent='Erro: '+e.message;console.error(e);}},20);
  let isl,dummy,grid,colGroup,sel=null,selBox=null;
  function build(){isl=MM.islands.StormIsland.build(scene);S.island=isl;window.__isl=isl;
    dummy=MM.makeDummy();scene.add(dummy);dummy.position.copy(isl.spawn);dummy.rotation.y=Math.PI;
    grid=new T.GridHelper(100,10,0x9fb4ff,0x4a5590);grid.material.transparent=true;grid.material.opacity=.45;grid.material.depthWrite=false;scene.add(grid);
    colGroup=new T.Group();colGroup.name='Colisores';colGroup.visible=false;scene.add(colGroup);
    const cm=new T.MeshBasicMaterial({color:0xff5c8a,wireframe:true,transparent:true,opacity:.65});isl.colliders.forEach(c=>{const m=new T.Mesh(new T.BoxGeometry(c.s.x,c.s.y,c.s.z),cm);m.position.copy(c.p);m.rotation.y=c.ry;colGroup.add(m);});
    const wm=new T.MeshBasicMaterial({color:0x7cffb2,wireframe:true,transparent:true,opacity:.5});isl.walks.forEach(w=>{if(w.type==='rect'){const m=new T.Mesh(new T.PlaneGeometry(w.sx,w.sz),wm);m.rotation.x=-Math.PI/2;m.position.set(w.x,w.y+.05,w.z);colGroup.add(m);}});
    /* contorno caminhável dos caminhos */
    isl.terrain.paths.forEach(p=>{const pts=p.S.map(([x,z])=>new T.Vector3(x,isl.terrain.heightAt(x,z)+.4,z));colGroup.add(new T.Line(new T.BufferGeometry().setFromPoints(pts),new T.LineBasicMaterial({color:p.c.tipo==='secreto'?0xffffff:p.c.tipo==='alternativo'?0xffd27a:0x7cffb2})));});
    buildUI();setView('Três quartos',true);applyQuality();status.hidden=true;
    const info=renderer.info;$('buildInfo').textContent=`montada em ${isl.ms} ms · ${isl.reg.list.length} modelos · ${isl.colliders.length} colisores`;window.__ready=true;}
  /* ---- vistas ---- */
  let camAnim=null;
  function setView(n,instant){if(S.mode==='walk')setMode('orbit');const v=isl.views[n];if(!v)return;const p=new T.Vector3(...v.pos),t=new T.Vector3(...v.tgt);
    if(instant){cam.position.copy(p);controls.target.copy(t);controls.update();return;}camAnim={p0:cam.position.clone(),t0:controls.target.clone(),p,t,k:0};}
  function focusObj(o){const b=new T.Box3().setFromObject(o);const c=b.getCenter(new T.Vector3()),s=b.getSize(new T.Vector3()).length();const dir=cam.position.clone().sub(controls.target).normalize();camAnim={p0:cam.position.clone(),t0:controls.target.clone(),p:c.clone().addScaledVector(dir,Math.max(12,s*1.1)),t:c,k:0};if(S.mode==='walk')setMode('orbit');}
  /* ---- caminhada ---- */
  const keys={};const vel=new T.Vector3();let grounded=true;
  addEventListener('keydown',e=>{if(e.target.tagName==='INPUT'||e.target.tagName==='SELECT')return;keys[e.code]=true;if(S.mode==='walk'&&['Space','ArrowUp','ArrowDown','ArrowLeft','ArrowRight'].includes(e.code))e.preventDefault();});addEventListener('keyup',e=>{keys[e.code]=false;});
  document.querySelectorAll('[data-key]').forEach(b=>{const k=b.dataset.key;const on=e=>{e.preventDefault();keys[k]=true;},off=()=>{keys[k]=false;};b.addEventListener('pointerdown',on);b.addEventListener('pointerup',off);b.addEventListener('pointerleave',off);});
  function groundAt(x,z,y){let g=isl.terrain.inside(x,z)?isl.terrain.heightAt(x,z):-1e9;let under=false;
    for(const w of isl.walks){let h=null;if(w.type==='rect'){if(Math.abs(x-w.x)<=w.sx/2&&Math.abs(z-w.z)<=w.sz/2)h=w.y;}
      else if(w.type==='disc'){if(Math.hypot(x-w.x,z-w.z)<=w.r)h=w.y;}
      else if(w.type==='bridge'){const q=MM.segDist(x,z,w.a[0],w.a[1],w.b[0],w.b[1]);if(q.d<=w.hw&&q.t>0&&q.t<1)h=w.y(q.t);}
      else if(w.type==='flat'){for(let i=0;i<w.pts.length-1;i++){const q=MM.segDist(x,z,w.pts[i][0],w.pts[i][1],w.pts[i+1][0],w.pts[i+1][1]);if(q.d<=w.hw){h=w.y;break;}}}
      if(h!==null&&(w.type==='flat'||w.type==='disc')&&y<g-6&&h<=y+WALK.step){under=true;g=h;continue;}/* dentro do túnel: o chão é o do túnel, não o topo da montanha */
      if(h!==null&&h<=y+WALK.step&&h>g&&!under)g=h;}
    /* V2.3.1: topo de colisor baixo (degrau, alicerce, sapata) também é chão — antes só o terreno e as superfícies declaradas */
    for(const c of isl.colliders){const top=c.p.y+c.s.y/2;if(top<=g||top>y+WALK.step)continue;const dx=x-c.p.x,dz=z-c.p.z;const cs=Math.cos(c.ry),sn=Math.sin(c.ry);const lx=dx*cs-dz*sn,lz=dx*sn+dz*cs;/* V2.3.1: inversa correta da rotação Y do three (antes girava para o lado errado e espelhava o colisor) */if(Math.abs(lx)<=c.s.x/2&&Math.abs(lz)<=c.s.z/2)g=top;}
    return g;}
  function blocked(x,z,y){for(const c of isl.colliders){const dx=x-c.p.x,dz=z-c.p.z;const cs=Math.cos(c.ry),sn=Math.sin(c.ry);const lx=dx*cs-dz*sn,lz=dx*sn+dz*cs;/* V2.3.1: inversa correta da rotação Y do three (antes girava para o lado errado e espelhava o colisor) */
      if(Math.abs(lx)<c.s.x/2+WALK.r&&Math.abs(lz)<c.s.z/2+WALK.r&&y+WALK.step<c.p.y+c.s.y/2&&y+WALK.h>c.p.y-c.s.y/2)return c;}return null;}/* bloqueia só o que é mais alto que um degrau */
  function stepWalk(dt){const az=Math.atan2(cam.position.x-controls.target.x,cam.position.z-controls.target.z);let mx=0,mz=0;
    if(keys.KeyW||keys.ArrowUp)mz-=1;if(keys.KeyS||keys.ArrowDown)mz+=1;if(keys.KeyA||keys.ArrowLeft)mx-=1;if(keys.KeyD||keys.ArrowRight)mx+=1;
    const len=Math.hypot(mx,mz);const p=dummy.position;
    if(len>0){mx/=len;mz/=len;const dx=(mx*Math.cos(az)+mz*Math.sin(az))*WALK.speed*dt,dz=(-mx*Math.sin(az)+mz*Math.cos(az))*WALK.speed*dt;
      dummy.rotation.y=Math.atan2(dx,dz);
      for(const [ax,az2] of [[dx,0],[0,dz]]){const nx=p.x+ax,nz=p.z+az2;const g=groundAt(nx,nz,p.y);const cur=groundAt(p.x,p.z,p.y);
        if(grounded&&g>cur+WALK.step)continue;/* degrau alto demais = parede */if(blocked(nx,nz,p.y))continue;p.x=nx;p.z=nz;}}
    if((keys.Space)&&grounded){vel.y=WALK.jump;grounded=false;}
    vel.y-=WALK.g*dt;p.y+=vel.y*dt;const g=groundAt(p.x,p.z,p.y);if(p.y<=g){p.y=g;vel.y=0;grounded=true;}else if(p.y-g>.3)grounded=false;
    if(p.y<-140){p.copy(isl.spawn);vel.set(0,0,0);}
    /* câmera em terceira pessoa: o alvo segue a cabeça do boneco */
    const head=p.clone().add(new T.Vector3(0,4.4,0));const d=head.clone().sub(controls.target);controls.target.add(d);cam.position.add(d);}
  function setMode(m){S.mode=m;$('mWalk').setAttribute('aria-pressed',m==='walk');$('mOrbit').setAttribute('aria-pressed',m==='orbit');document.body.classList.toggle('walking',m==='walk');
    if(m==='walk'){controls.maxDistance=60;controls.minDistance=6;const p=dummy.position;controls.target.set(p.x,p.y+4.4,p.z);cam.position.set(p.x,p.y+11,p.z+18);dummy.visible=true;}
    else{controls.maxDistance=1700;controls.minDistance=4;}}
  /* ---- inspeção ---- */
  const ray=new T.Raycaster();let downAt=null;
  renderer.domElement.addEventListener('pointerdown',e=>{downAt=[e.clientX,e.clientY];});
  renderer.domElement.addEventListener('pointerup',e=>{if(!downAt||Math.hypot(e.clientX-downAt[0],e.clientY-downAt[1])>5)return;const r=renderer.domElement.getBoundingClientRect();
    ray.setFromCamera(new T.Vector2((e.clientX-r.left)/r.width*2-1,-(e.clientY-r.top)/r.height*2+1),cam);const hits=ray.intersectObjects(isl.root.children,true).filter(h=>h.object.visible&&!(h.object.isSprite));
    if(S.oficina&&hits.length){const c=window.__ofiPick(hits[0].point);if(c){window.__ofiSelect(c);return;}}
    for(const h of hits){let o=h.object;while(o&&!(o.userData&&o.userData.id&&isl.reg.byId[o.userData.id]===o))o=o.parent;if(o){select(o);return;}}select(null);});
  function select(o){sel=o;if(selBox){scene.remove(selBox);selBox=null;}const P=$('inspect');if(!o){P.hidden=true;$('modelList').querySelectorAll('.on').forEach(b=>b.classList.remove('on'));return;}
    selBox=new T.BoxHelper(o,0x43d9ff);scene.add(selBox);const b=new T.Box3().setFromObject(o),s=b.getSize(new T.Vector3());const u=o.userData;
    P.hidden=false;$('iName').textContent=u.name;$('iId').textContent=u.id;$('iCat').textContent='Dimensions/StormIsland/'+u.cat;
    $('iTris').textContent=MM.tris(o).toLocaleString('pt-BR');$('iSize').textContent=`${s.x.toFixed(1)} × ${s.y.toFixed(1)} × ${s.z.toFixed(1)}`;
    $('iPivot').textContent=`${o.position.x.toFixed(1)}, ${o.position.y.toFixed(1)}, ${o.position.z.toFixed(1)}`;$('iCols').textContent=(u.colliders||[]).length+' caixa(s)'+((u.walk||[]).length?' · '+u.walk.length+' superfície(s) caminhável(is)':'');
    $('iNotes').textContent=u.notes||'—';{const R=S.support&&diagR&&diagR.modelos[u.id];const el=$('iDiag');if(el){el.parentNode.hidden=!R;el.previousElementSibling&&(el.previousElementSibling.hidden=!R);if(R){const c={verde:'#3ee07a',amarelo:'#ffd23f',vermelho:'#ff6b6b'}[R.status];const a=R.info.apoio;el.innerHTML='<b style="color:'+c+'">'+R.status+'</b>'+(R.excecao?' · exceção: '+R.excecao:'')+(a?' · apoio: '+a.contato+' contato, '+a.folga+' folga, '+a.suspenso+' suspenso, '+a.enterrado+' alicerce':'')+(R.motivos.length?'<br>'+R.motivos.slice(0,5).join('<br>'):'')+'<br>escala '+R.info.escala.join(' × ')+' · rotação Y '+(o.rotation.y*180/Math.PI).toFixed(1)+'°';}}}$('modelList').querySelectorAll('button').forEach(bt=>bt.classList.toggle('on',bt.dataset.id===u.id));}
  function isolate(on){S.isolated=on;isl.reg.list.forEach(o=>{if(o.userData.cat==='Terrain')o.visible=!on||o===sel;else o.visible=!on||o===sel;});if(sel)sel.traverse(m=>{if(m.userData&&m.userData.realMat&&MM.realMats)m.material=on?MM.realMats[m.userData.realMat]:MM.hidMat;});$('iIso').textContent=on?'Mostrar tudo':'Isolar';}
  /* ---- interface ---- */
  function buildUI(){const vb=$('views');vb.innerHTML=Object.keys(isl.views).map(n=>`<button class="chip" data-view="${n}">${n}</button>`).join('');vb.querySelectorAll('button').forEach(b=>b.onclick=()=>setView(b.dataset.view));
    const groups={};isl.reg.list.forEach(o=>{(groups[o.userData.cat]=groups[o.userData.cat]||[]).push(o);});
    const order=['Terrain','Architecture','Vegetation','Resources','Props','Interactions','Lighting'];
    $('modelList').innerHTML=order.filter(k=>groups[k]).map(k=>`<details ${k==='Architecture'?'open':''}><summary><span>${k}</span><b>${groups[k].length}</b></summary><div>${groups[k].map(o=>`<button data-id="${o.userData.id}"><span>${o.userData.name}</span><code>${o.userData.id}</code></button>`).join('')}</div></details>`).join('');
    $('modelList').querySelectorAll('button').forEach(b=>b.onclick=()=>{const o=isl.reg.byId[b.dataset.id];select(o);focusObj(o);});
    const tg=(id,key,fn)=>{const b=$(id);b.setAttribute('aria-pressed',S[key]);b.onclick=()=>{S[key]=!S[key];b.setAttribute('aria-pressed',S[key]);fn&&fn();};};
    tg('tFx','fx',()=>{isl.fx.on=S.fx;});tg('tRain','rain',()=>{isl.fx.rain=S.rain;});tg('tFull','full',()=>isl.light.setMode(S.full));tg('tCols','cols',()=>{colGroup.visible=S.cols;});
    tg('tMarks','marks',()=>{isl.folders.Interactions.visible=S.marks;});if(!S.labels)isl.folders.Interactions.traverse(o=>{if(o.name==='rotulo')o.visible=false;});let supG=null,supA=null;const supAt=(x,z,y)=>{const C=[];const t=isl.terrain.heightAt(x,z);if(t>-150&&isl.terrain.inside(x,z))C.push(t);/* V2.3.2: fora do contorno da ilha não há chão desenhado (antes contava como chão 5 studs abaixo) */
      for(const w of isl.walks){let h=null;if(w.type==='rect'){if(Math.abs(x-w.x)<=w.sx/2&&Math.abs(z-w.z)<=w.sz/2)h=w.y;}else if(w.type==='disc'){if(Math.hypot(x-w.x,z-w.z)<=w.r)h=w.y;}
        else if(w.type==='bridge'){const q=MM.segDist(x,z,w.a[0],w.a[1],w.b[0],w.b[1]);if(q.d<=w.hw&&q.t>0&&q.t<1)h=w.y(q.t);}else if(w.type==='flat'){for(let i=0;i<w.pts.length-1;i++){const q=MM.segDist(x,z,w.pts[i][0],w.pts[i][1],w.pts[i+1][0],w.pts[i+1][1]);if(q.d<=w.hw){h=w.y;break;}}}if(h!==null)C.push(h);}
      if(!C.length)return null;const below=C.filter(c=>c<=y+3);return below.length?Math.max(...below):Math.min(...C);};
    const NAO=['STORM.PROP.VILLAGE.CABLES','STORM.PROP.POWERLINE','STORM.PROP.LANTERNS'];/* cabos ficam pendurados entre apoios (intencional); lanternas: postes finos auditados à parte */
    /* teste de rota: percorre uma polilinha a passos de 0,25 stud com as MESMAS regras do boneco (degrau máximo, colisores, gravidade) */
    window.__walkTest=(pts,y0)=>{let x=pts[0][0],z=pts[0][1],y=y0!==undefined?y0:groundAt(x,z,1e4);let maxUp=0,maxDrop=0,n=0;
      for(let i=1;i<pts.length;i++){const [tx,tz]=pts[i];let L=Math.hypot(tx-x,tz-z);const k=Math.ceil(L/.25);const dx=(tx-x)/k,dz=(tz-z)/k;
        for(let s=0;s<k;s++){const nx=x+dx,nz=z+dz;const g=groundAt(nx,nz,y);if(g>y+WALK.step)return{ok:false,motivo:'degrau alto demais',em:[+nx.toFixed(1),+nz.toFixed(1)],sobe:+(g-y).toFixed(2)};
          const c=blocked(nx,nz,Math.max(y,g));if(c)return{ok:false,motivo:'colisor',id:c.id,em:[+nx.toFixed(1),+nz.toFixed(1)]};maxUp=Math.max(maxUp,g-y);maxDrop=Math.max(maxDrop,y-g);x=nx;z=nz;y=g;n++;}}
      return{ok:true,passos:n,maiorSubida:+maxUp.toFixed(2),maiorDescida:+maxDrop.toFixed(2),yFinal:+y.toFixed(2)};};
    window.__supportAudit=()=>{if(!supA){const models=isl.reg.list.filter(o=>!['Terrain','Lighting','Interactions'].includes(o.userData.cat)&&!NAO.includes(o.userData.id));const t0=performance.now();supA=MM.supportAudit(models,supAt,{teto:id=>id.startsWith('STORM.VEG.')?2:4});supA.ms=Math.round(performance.now()-t0);}return supA;};
    /* Diagnóstico Estrutural: testes automáticos + camada visual (caixa, pivô e eixos por modelo na cor do estado, colisores, pontos de apoio e lacunas) */
    let diagR=null,diagG=null;const TOL={'STORM.BRIDGE.01':{n:3,max:4,motivo:'bordas das tábuas sobre o lábio da fenda (início do vão)'}};
    window.__diagnostico=()=>{if(!diagR){diagR=MM.structuralTests(isl,supAt,{walk:p=>window.__walkTest(p),rotas:MM.rotasDaIlha(isl,MM.islands.StormIsland),toleranciaSuspensa:TOL});supA=diagR.apoio;}return diagR;};
    tg('tSupport','support',()=>{const R=window.__diagnostico();if(!diagG){diagG=MM.structuralDebug(isl,R);scene.add(diagG);}diagG.visible=S.support;colGroup.visible=S.support||S.cols;
      const red=Object.entries(R.modelos).filter(([,s])=>s.status==='vermelho'),yel=Object.entries(R.modelos).filter(([,s])=>s.status==='amarelo');const rot=R.rotas?Object.values(R.rotas):[];
      $('supInfo').hidden=!S.support;$('supInfo').innerHTML='<b>Diagnóstico Estrutural</b> · <span style="color:#3ee07a">'+R.contagem.verde+' validados</span> · <span style="color:#ffd23f">'+R.contagem.amarelo+' inspecionar</span> · <span style="color:#ff6b6b">'+R.contagem.vermelho+' com problema</span> · rotas '+rot.filter(r=>r.ok).length+'/'+rot.length+' · interseções '+R.globais.intersecoes
        +(red.length?'<br><span style="color:#ff6b6b">'+red.map(([id,s])=>id.replace('STORM.','')+': '+s.motivos[0]).join(' · ')+'</span>':'')+'<br><span style="opacity:.75">clique num modelo para ver o nome técnico e os motivos · pontos: verde contato, amarelo folga, vermelho suspenso, azul alicerce</span>';
      if(sel)select(sel);});
    /* ---- Inspecionar Oficina: isola a oficina (só visibilidade — nada é removido da ilha), enquadra, oculta telhado/frente, seleciona componentes ---- */
    const ofi=isl.reg.byId['STORM.ARCH.WORKSHOP'];let ofiVis=null,compBox=null;
    const ofiFrame=(lc,lt)=>{if(!ofi)return;if(S.mode==='walk')setMode('orbit');const C=ofi.localToWorld(new T.Vector3(...lc)),Tt=ofi.localToWorld(new T.Vector3(...lt));cam.position.copy(C);controls.target.copy(Tt);controls.update();};
    const OV={'Frente':[[0,9,50],[0,7,0]],'Lateral':[[50,9,0],[0,7,0]],'Três quartos':[[36,22,40],[0,6,0]],'Superior':[[0,62,4],[0,0,0]],'Interior':[[0,12.5,8.5],[0,3,-5]],'Bancadas':[[-1,7.4,5],[-10,3.6,3]],
      'Condensador':[[4.5,7,3.5],[0,6.5,-4.6]],'Telhado':[[22,26,26],[0,17,0]],'Fundação':[[30,5,16],[6,1,6]],'Jogador':[[3,6.8,22],[0,5,0]]};
    if(ofi){$('oficinaViews').innerHTML=Object.keys(OV).map(n=>`<button class="chip" data-ov="${n}">${n}</button>`).join('');$('oficinaViews').querySelectorAll('button').forEach(b=>b.onclick=()=>ofiFrame(...OV[b.dataset.ov]));}
    window.__ofiView=n=>ofiFrame(...OV[n]);
    tg('tOficina','oficina',()=>{if(!ofi)return;if(S.oficina){ofiVis=new Map();isl.root.traverse(o=>{if(o===isl.root||!o.parent||o.parent!==isl.root&&!o.userData.id)return;if(o.userData.id||o.parent===isl.root){ofiVis.set(o,o.visible);}});
        isl.reg.list.forEach(o=>{if(o!==ofi)o.visible=false;});isl.light.clouds&&(isl.light.clouds.visible=false);grid.visible=false;
        dummy.visible=true;dummy.position.copy(ofi.localToWorld(new T.Vector3(3,1.8,14)));dummy.rotation.y=ofi.rotation.y+Math.PI;ofiFrame(...OV['Três quartos']);}
      else{if(ofiVis)ofiVis.forEach((v,o)=>o.visible=v);ofiVis=null;if(compBox){scene.remove(compBox);compBox=null;}grid.visible=S.scale;}});
    tg('tTelhado','telhado',()=>{if(ofi&&ofi.__oficina)ofi.__oficina.roof.visible=!S.telhado;});
    tg('tFrente','frente',()=>{if(ofi&&ofi.__oficina)ofi.__oficina.front.visible=!S.frente;});
    window.__ofiPick=(p)=>{if(!ofi||!ofi.userData.componentes)return null;let best=null,bv=1e18;ofi.userData.componentes.forEach(c=>{const b=c.box;if(p.x<b[0]-.05||p.x>b[3]+.05||p.y<b[1]-.05||p.y>b[4]+.05||p.z<b[2]-.05||p.z>b[5]+.05)return;const v=(b[3]-b[0])*(b[4]-b[1])*(b[5]-b[2]);if(v<bv){bv=v;best=c;}});return best;};
    window.__ofiSelect=(c)=>{if(compBox){scene.remove(compBox);compBox=null;}if(!c)return;const b=new T.Box3(new T.Vector3(c.box[0],c.box[1],c.box[2]),new T.Vector3(c.box[3],c.box[4],c.box[5]));compBox=new T.Box3Helper(b,0xffd23f);compBox.material.depthTest=false;compBox.renderOrder=999;scene.add(compBox);
      const P=$('inspect');P.hidden=false;$('iName').textContent=c.nome;$('iId').textContent='STORM.ARCH.WORKSHOP › '+c.nome;$('iCat').textContent='Componente da Oficina dos Inventores';const s=b.getSize(new T.Vector3());$('iSize').textContent=`${s.x.toFixed(1)} × ${s.y.toFixed(1)} × ${s.z.toFixed(1)}`;};
    tg('tNeutral','neutral',()=>isl.light.setNeutral(S.neutral));tg('tClay','clay',()=>{scene.overrideMaterial=S.clay?clayMat:null;scene.traverse(o=>{if(S.clay){if(o.visible&&(o.isSprite||o.isPoints||o.isLine||(o.material&&o.material.transparent&&!o.isInstancedMesh))){o.visible=false;o.userData._clayHid=true;}}else if(o.userData._clayHid){o.visible=true;delete o.userData._clayHid;}});});tg('tLabels','labels',()=>{isl.folders.Interactions.traverse(o=>{if(o.name==='rotulo')o.visible=S.labels;});});tg('tScale','scale',()=>{grid.visible=S.scale;if(S.mode==='orbit')dummy.visible=S.scale;});
    $('tLow').setAttribute('aria-pressed',S.quality==='low');$('tLow').onclick=()=>{S.quality=S.quality==='low'?'high':'low';$('tLow').setAttribute('aria-pressed',S.quality==='low');applyQuality();};
    $('mWalk').onclick=()=>setMode('walk');$('mOrbit').onclick=()=>setMode('orbit');$('iFocus').onclick=()=>sel&&focusObj(sel);$('iIso').onclick=()=>isolate(!S.isolated);$('iClose').onclick=()=>select(null);
    $('iGlb').onclick=()=>sel&&exportPack([sel],'modelo');$('tExport').onclick=()=>exportPack(null,'pacote');}
  function applyQuality(){const low=S.quality==='low';renderer.shadowMap.enabled=!low;isl.light.sun.castShadow=!low&&S.full;resize();scene.traverse(o=>{if(o.material&&o.isMesh)o.material.needsUpdate=true;});}
  /* ---- exportação: GLB por pasta + heightmap/colormap + marcadores + manifesto (zip) ---- */
  async function exportPack(only,kind){const btn=kind==='modelo'?$('iGlb'):$('tExport');const old=btn.textContent;btn.textContent='Exportando…';btn.disabled=true;
    try{const files=await buildPack(only);const blob=MM.zip(files);const name=kind==='modelo'?('StormIsland-'+only[0].userData.id+'.zip'):'StormIsland-pacote.zip';
      const dl=window.claude&&window.claude.use?await window.claude.use('downloads'):null;
      if(dl){try{await dl.save({filename:name,data:blob});btn.textContent='Salvo';}catch(e){btn.textContent=e&&e.code==='declined'?old:'Download indisponível';}}
      else{const a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download=name;a.click();btn.textContent='Exportado';}}
    catch(e){btn.textContent='Falhou: '+e.message;console.error(e);}setTimeout(()=>{btn.textContent=old;btn.disabled=false;},2600);}
  const expTerrain=new T.MeshStandardMaterial({vertexColors:true,roughness:.9});expTerrain.name='TerrenoCoresPorVertice';const expRock=new T.MeshStandardMaterial({color:0x5b5e72,roughness:.9});expRock.name='Rocha';
  function glb(objs){return new Promise((res,rej)=>{const g=new T.Group();objs.forEach(o=>{const c=o.clone(true);c.traverse(m=>{if(m.isSprite)m.visible=false;if(m.name==='TerrenoLOD1'||(m.isInstancedMesh&&m.userData.renderOnly))m.visible=false;if(m.name==='InteriorLOD')m.visible=true;if(m.userData&&m.userData.pedacos)m.visible=false;/* Mapa V1: pedaços do recorte da vegetação só servem ao desenho; o pacote usa as malhas originais *//* exporta o interior mesmo que a câmera esteja longe */if(m.userData&&m.userData.realMat&&MM.realMats)m.material=MM.realMats[m.userData.realMat];/* só o nível de detalhe 0 */if(m.material&&m.material.userData&&m.material.userData.triplanar)m.material=m.material.name==='TerrenoTempestadeV2'?expTerrain:expRock;/* shader triplanar não exporta: cor por vértice + texturas em PNG à parte */});o.updateMatrixWorld(true);c.matrix.copy(o.matrixWorld);c.matrix.decompose(c.position,c.quaternion,c.scale);g.add(c);});
    new T.GLTFExporter().parse(g,b=>res(new Uint8Array(b)),{binary:true,onlyVisible:true});});}
  async function buildPack(only){const files=[];const manifest={dimensao:'StormIsland',nome:'Ilha das Tempestades',unidade:'1 = 1 stud',eixos:'Y para cima, +Z = sul (chegada)',gerado:new Date().toISOString().slice(0,10),modelos:[],aviso:'Exportado do visualizador web. Não importado nem testado no Roblox Studio.'};
    const desc=o=>{const b=new T.Box3().setFromObject(o),s=b.getSize(new T.Vector3());return{id:o.userData.id,nome:o.userData.name,pasta:o.userData.cat,triangulos:MM.tris(o),tamanho:[+s.x.toFixed(2),+s.y.toFixed(2),+s.z.toFixed(2)],pivo:[+o.position.x.toFixed(2),+o.position.y.toFixed(2),+o.position.z.toFixed(2)],rotY:+o.rotation.y.toFixed(4),colisores:o.userData.colliders,notas:o.userData.notes};};
    if(only){files.push({name:only[0].userData.id+'.glb',data:await glb(only)});manifest.modelos=only.map(desc);}
    else{for(const k of ['Terrain','Architecture','Vegetation','Resources','Props']){const list=isl.reg.list.filter(o=>o.userData.cat===k);if(!list.length)continue;files.push({name:'Dimensions/StormIsland/'+k+'/'+k+'.glb',data:await glb(list)});list.forEach(o=>manifest.modelos.push(desc(o)));}
      const g=isl.terrain.grid;let lo=1e9,hi=-1e9;for(let i=0;i<g.H.length;i++){if(g.H[i]>-50){lo=Math.min(lo,g.H[i]);hi=Math.max(hi,g.H[i]);}}
      const png=async(fill)=>{const c=document.createElement('canvas');c.width=g.NX;c.height=g.NZ;const x=c.getContext('2d');const im=x.createImageData(g.NX,g.NZ);for(let k=0;k<g.NX*g.NZ;k++)fill(k,im.data);x.putImageData(im,0,0);const b=await new Promise(r=>c.toBlob(r,'image/png'));return new Uint8Array(await b.arrayBuffer());};
      files.push({name:'Dimensions/StormIsland/Terrain/heightmap.png',data:await png((k,d)=>{const v=Math.round(MM.clamp((g.H[k]-lo)/(hi-lo),0,1)*255);d[k*4]=d[k*4+1]=d[k*4+2]=v;d[k*4+3]=255;})});
      files.push({name:'Dimensions/StormIsland/Terrain/heightmap16-RG.png',data:await png((k,d)=>{const v=Math.round(MM.clamp((g.H[k]-lo)/(hi-lo),0,1)*65535);d[k*4]=v>>8;d[k*4+1]=v&255;d[k*4+2]=0;d[k*4+3]=255;})});
      files.push({name:'Dimensions/StormIsland/Terrain/colormap.png',data:await png((k,d)=>{d[k*4]=Math.round(Math.pow(g.col[k*3],1/2.2)*255);d[k*4+1]=Math.round(Math.pow(g.col[k*3+1],1/2.2)*255);d[k*4+2]=Math.round(Math.pow(g.col[k*3+2],1/2.2)*255);d[k*4+3]=g.H[k]>-50?255:0;})});
      manifest.terreno={pixels:[g.NX,g.NZ],studsPorPixel:g.STEP,origem:[g.X0,g.Z0],alturaMin:+lo.toFixed(2),alturaMax:+hi.toFixed(2),heightmap:'8 bits em cinza (0 = alturaMin, 255 = alturaMax); heightmap16-RG.png guarda 16 bits (R = alto, G = baixo).'};
      files.push({name:'Dimensions/StormIsland/Interactions/marcadores.json',data:JSON.stringify(MM.islands.StormIsland.marcadores.map(([id,tipo,desc,x,z])=>({id,tipo,descricao:desc,x,z,y:+isl.terrain.heightAt(x,z).toFixed(2),implementado:false})),null,1)});}
    files.push({name:'manifest.json',data:JSON.stringify(manifest,null,1)});return files;}
  window.__exportPack=async()=>{const f=await buildPack(null);return f.map(x=>({name:x.name,bytes:x.data.length}));};
  window.__buildPack=buildPack;
  /* ---- laço ---- */
  const clock=new T.Clock();const fps=[];let hudT=0;
  renderer.info.autoReset=false;
  (function loop(){requestAnimationFrame(loop);renderer.info.reset();const dt=Math.min(clock.getDelta(),.05);if(!isl){renderer.render(scene,cam);return;}
    if(camAnim){camAnim.k=Math.min(1,camAnim.k+dt/1.1);const k=camAnim.k<.5?2*camAnim.k*camAnim.k:1-Math.pow(-2*camAnim.k+2,2)/2;cam.position.lerpVectors(camAnim.p0,camAnim.p,k);controls.target.lerpVectors(camAnim.t0,camAnim.t,k);if(camAnim.k>=1)camAnim=null;}
    if(S.mode==='walk')stepWalk(dt);
    /* sob a rocha (caverna) não chove */isl.fx.rain=S.rain&&!(cam.position.y<isl.terrain.heightAt(cam.position.x,cam.position.z)-3);
    isl.fx.update(dt,cam);isl.light.update(isl.fx.t,isl.fx.flash);
    grid.visible=S.scale&&cam.position.distanceTo(controls.target)<260;
    if(grid.visible){const f=S.mode==='walk'?dummy.position:controls.target;grid.position.set(Math.round(f.x/10)*10,(S.mode==='walk'?dummy.position.y:isl.terrain.heightAt(f.x,f.z))+.15,Math.round(f.z/10)*10);}
    /* no modo caminhada, marcadores a menos de 14 studs do boneco somem para não tapar a visão */
    if(S.marks)isl.folders.Interactions.children[0].children.forEach(m=>{m.visible=S.mode!=='walk'||(m.position.distanceTo(dummy.position)>14&&m.position.distanceTo(cam.position)>16);});
    if(selBox)selBox.update();controls.update();
    if(composer&&S.fx&&S.quality!=='low')composer.render();else renderer.render(scene,cam);
    fps.push(dt);if(fps.length>40)fps.shift();hudT+=dt;if(hudT>.4){hudT=0;const f=Math.round(fps.length/fps.reduce((a,b)=>a+b,0));
      const ref=S.mode==='walk'?dummy.position:controls.target;const dist=cam.position.distanceTo(controls.target);const px=stage.clientHeight/(2*Math.tan(cam.fov*Math.PI/360)*dist)*10;
      $('scaleBar').style.width=Math.max(4,Math.min(220,px))+'px';$('scaleTxt').textContent='10 studs';
      $('hud').textContent=`${f} fps · ${renderer.info.render.triangles.toLocaleString('pt-BR')} triângulos · ${renderer.info.render.calls} chamadas\n${S.mode==='walk'?'boneco':'alvo'}: x ${ref.x.toFixed(0)} · y ${ref.y.toFixed(0)} · z ${ref.z.toFixed(0)} (studs)`;}})();
  window.__setView=setView;window.__setMode=setMode;window.__S=S;window.__select=id=>select(isl.reg.byId[id]);window.__dummy=()=>dummy;window.__keys=keys;window.__cam=cam;window.__controls=controls;
};})();
