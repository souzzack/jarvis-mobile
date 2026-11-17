/* Ilha das Tempestades · Terrain · superfície (V2)
   Detalhes que tiram o "chão liso": tufos de grama irregular, seixos, poças de chuva nas trilhas, afloramentos de rocha fraturada
   nas encostas e depósitos de cristal. Tudo instanciado (uma chamada de desenho por tipo).
   No Roblox: grama = Terrain Grass/decoração; seixos e afloramentos = MeshParts clonadas; poças = Parts finas com Glass/SmoothPlastic. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
function tuftGeo(seed){const r=MM.rng(seed);const P=[],C=[];const g0=new T.Color('#24382a'),g1=new T.Color('#4f6744');
  for(let b=0;b<9;b++){const a=r()*Math.PI*2,rad=r()*.5,h=.6+r()*.9,w=.09+r()*.06,lean=.25+r()*.45;const bx=Math.cos(a)*rad,bz=Math.sin(a)*rad;const dx=Math.cos(a+1.6),dz=Math.sin(a+1.6);
    const tx=bx+Math.cos(a)*lean,tz=bz+Math.sin(a)*lean;P.push(bx-dx*w,0,bz-dz*w,bx+dx*w,0,bz+dz*w,tx,h,tz);[g0,g0,g1].forEach(c=>C.push(c.r,c.g,c.b));}
  const g=new T.BufferGeometry();g.setAttribute('position',new T.Float32BufferAttribute(P,3));g.setAttribute('color',new T.Float32BufferAttribute(C,3));g.computeVertexNormals();return g;}
I.buildSurface=function(ctx){const out=[],P=I.poi;const r=MM.rng(3131);const H=ctx.heightAt;const nrmAt=(x,z)=>{const e=1.5;const dx=(H(x+e,z)-H(x-e,z))/(2*e),dz=(H(x,z+e)-H(x,z-e))/(2*e);return new T.Vector3(-dx,1,-dz).normalize();};
  const near=(x,z,list,d)=>list.some(p=>Math.hypot(p.x-x,p.z-z)<d);const keep=[P.vila,P.torre,P.chegada,P.observatorio].map(p=>({x:p.x,z:p.z,r:(p.r||24)-2}));keep.push({x:P.torre.x,z:P.torre.z+34,r:16});/* pé da escadaria da torre */
  const G=ctx.terrain.grid;const aoAt=(x,z)=>{const i=Math.round((x-G.X0)/G.STEP),j=Math.round((z-G.Z0)/G.STEP);return G.AO[MM.clamp(j,0,G.NZ-1)*G.NX+MM.clamp(i,0,G.NX-1)];};const free=(x,z)=>!keep.some(k=>Math.hypot(k.x-x,k.z-z)<k.r);const dummy=new T.Object3D();
  /* ---- grama irregular ---- */
  const tg=tuftGeo(5);const gm=new T.MeshStandardMaterial({vertexColors:true,roughness:.9,side:T.DoubleSide});gm.name='GramaTufos';
  const NG=5200;const grass=new T.InstancedMesh(tg,gm,NG);grass.name='GramaInstanciada';let n=0;
  for(let t=0;t<NG*6&&n<NG;t++){const x=-270+r()*540,z=-220+r()*430;if(!ctx.inside(x,z)||!free(x,z))continue;const y=H(x,z);if(y<2||y>60)continue;const nn=nrmAt(x,z);if(nn.y<.86)continue;if(ctx.pathDist(x,z)<1)continue;
    /* tufos em manchas, não uniformes */if(MM.fbm(x/26,z/26,3,77)<-.05&&r()<.75)continue;
    dummy.position.set(x,y-.05,z);dummy.rotation.set(0,r()*6.28,0);const s=.7+r()*1.1;dummy.scale.set(s,s*(.7+r()*.8),s);dummy.updateMatrix();grass.setMatrixAt(n++,dummy.matrix);}
  grass.count=n;grass.receiveShadow=true;
  /* ---- seixos ---- */
  const pebG=[0,1,2].map(i=>{const g=new T.DodecahedronGeometry(.4,0);const p=g.attributes.position;const rr=MM.rng(5000+i);for(let q=0;q<p.count;q++){p.setXYZ(q,p.getX(q)*(1+(rr()-.5)*.5)*1.1,p.getY(q)*.62,p.getZ(q)*(1+(rr()-.5)*.5));}g.computeVertexNormals();return g;});/* 36 triângulos cada; sem sombra (pequenos demais) */const pebs=pebG.map((g,i)=>{const m=new T.InstancedMesh(g,ctx.rockMat,700);m.name='Seixos'+i;m.castShadow=false;m.receiveShadow=true;m.count=0;return m;});
  for(let t=0;t<9000;t++){const x=-270+r()*540,z=-220+r()*430;if(!ctx.inside(x,z))continue;const y=H(x,z);if(y<1)continue;const pd=ctx.pathDist(x,z);if(pd>6&&r()<.6)continue;/* mais perto das trilhas (desgaste) */
    const m=pebs[t%3];if(m.count>=700)continue;dummy.position.set(x,y,z);dummy.rotation.set(r()*.5,r()*6.28,r()*.5);const s=.6+r()*r()*2.6;dummy.scale.setScalar(s);dummy.updateMatrix();m.setMatrixAt(m.count++,dummy.matrix);}
  /* ---- afloramentos de rocha fraturada nas encostas e montanhas ---- */
  const outG=[0,1,2,3,4,5].map(i=>MM.rockGeo(7000+i*13,3.4+i*.3,2.2+(i%3)*.8,3+(i%2),2));const outs=outG.map((g,i)=>{const m=new T.InstancedMesh(g,ctx.rockMat,70);m.name='Afloramentos'+i;m.castShadow=true;m.receiveShadow=true;m.count=0;return m;});
  for(let t=0;t<14000;t++){const x=-270+r()*540,z=-230+r()*440;if(!ctx.inside(x,z)||!free(x,z))continue;const y=H(x,z);const nn=nrmAt(x,z);const steep=1-nn.y;if(ctx.pathDist(x,z)<5)continue;
    const m=outs[t%6];if(m.count>=70)continue;
    /* posição com lógica geológica: bordas de estrato (degrau pouco inclinado no meio da encosta) e tálus no pé dos paredões (cavidade alta) */
    const ao=aoAt(x,z);const ledge=y>34&&steep>.08&&steep<.3&&MM.noise2(x/30,z/30,81)>-.1;const talus=ao<.86&&steep<.32;if(!(ledge||talus))continue;
    dummy.position.set(x,y-.9,z);dummy.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),nn.clone().lerp(new T.Vector3(0,1,0),.5).normalize());dummy.rotateY(r()*6.28);
    const s=(talus?.8+r()*1.2:.5+r()*.8);dummy.scale.set(s*(.8+r()*.4),s*(.5+r()*.5),s*(.8+r()*.4));dummy.position.y-=s*.7;/* meio enterradas */dummy.updateMatrix();m.setMatrixAt(m.count++,dummy.matrix);}
  /* ---- poças de chuva nas trilhas planas (refletem o céu) ---- */
  const pm=new T.MeshStandardMaterial({color:MM.C('#1c2236'),roughness:.04,metalness:.15,envMapIntensity:1.6,transparent:true,opacity:.86,polygonOffset:true,polygonOffsetFactor:-4});pm.name='PocaDeChuva';
  const pud=new T.Group();pud.name='Pocas';
  ctx.terrain.paths.forEach(p=>{for(let i=4;i<p.S.length-4;i+=5){if(r()<.45)continue;const [x0,z0]=p.S[i];const x=x0+(r()-.5)*p.hw,z=z0+(r()-.5)*p.hw;const nn=nrmAt(x,z);if(nn.y<.985||!ctx.inside(x,z))continue;
    const s=new T.Shape();const k=10,R0=1+r()*2.2;for(let q=0;q<k;q++){const a=q/k*Math.PI*2,rr=R0*(.7+.5*r());q?s.lineTo(Math.cos(a)*rr,Math.sin(a)*rr*.7):s.moveTo(Math.cos(a)*rr,Math.sin(a)*rr*.7);}
    const m=new T.Mesh(new T.ShapeGeometry(s),pm);m.rotation.x=-Math.PI/2;m.rotation.z=r()*3;m.position.set(x,H(x,z)+.06,z);m.receiveShadow=true;pud.add(m);}});
  /* ---- depósitos de cristal nas rochas das montanhas ---- */
  const dc=new T.MeshPhysicalMaterial({color:MM.C('#8fe6ff'),roughness:.06,transmission:.5,transparent:true,opacity:.9,emissive:MM.C('#2aa8ff'),emissiveIntensity:.45,clearcoat:1,flatShading:true});dc.name='DepositoCristal';
  const dep=new T.Group();dep.name='DepositosCristal';
  for(let t=0,k=0;t<3000&&k<26;t++){const x=-250+r()*500,z=-230+r()*240;if(!ctx.inside(x,z))continue;const y=H(x,z);if(y<38)continue;const nn=nrmAt(x,z);if(nn.y>.8)continue;
    const g=new T.Group();g.position.set(x,y-.3,z);g.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),nn);const c=3+Math.floor(r()*4);for(let q=0;q<c;q++){const m=MM.mesh(MM.crystalGeo(.35+r()*.5,1.4+r()*2.6,.9+r()*.8),dc,(r()-.5)*1.6,0,(r()-.5)*1.6,g);m.rotation.set((r()-.5)*.9,r()*3,(r()-.5)*.9);}dep.add(g);k++;}
  /* ---- vegetação variada (formas próprias, instanciadas; nenhuma colisão para não atrapalhar a caminhada) ---- */
  const vegM=new T.MeshStandardMaterial({vertexColors:true,roughness:.85,side:T.DoubleSide});vegM.name='VegetacaoRasteira';
  const colGeo=(g,c0,c1,yMax)=>{const p=g.attributes.position,C=[];const a=MM.C(c0),b=MM.C(c1);for(let i=0;i<p.count;i++){const t=MM.clamp(p.getY(i)/yMax,0,1);const c=a.clone().lerp(b,t);C.push(c.r,c.g,c.b);}g.setAttribute('color',new T.Float32BufferAttribute(C,3));return g;};
  const shrubGeo=(seed,c0,c1)=>{const rr=MM.rng(seed);const parts=[];const n=10+Math.floor(rr()*4);for(let k=0;k<n;k++){const g=new T.IcosahedronGeometry(.6+rr()*.45,0);const p=g.attributes.position;for(let i=0;i<p.count;i++)p.setXYZ(i,p.getX(i)*(1+(rr()-.5)*.35),p.getY(i)*(.7+rr()*.3),p.getZ(i)*(1+(rr()-.5)*.35));
      const a=rr()*6.28,d=Math.sqrt(rr())*1.5;g.translate(Math.cos(a)*d,.4+rr()*1.3*(1-d/2),Math.sin(a)*d);parts.push(g.toNonIndexed());}
    const g=MM.merge(parts);/* normais suaves apontando para fora da copa: folhagem macia com poucos triângulos */const p=g.attributes.position,nr=g.attributes.normal;for(let i=0;i<p.count;i++){const v=new T.Vector3(p.getX(i),p.getY(i)-.7,p.getZ(i)).normalize();nr.setXYZ(i,v.x,v.y,v.z);}return colGeo(g,c0,c1,2.6);};
  const fernGeo=(seed,c0,c1)=>{const rr=MM.rng(seed);const P=[];const n=6+Math.floor(rr()*3);for(let k=0;k<n;k++){const a=k/n*6.28+rr()*.4,L=1+rr()*.8,w=.18;let px=0,py=0,pz=0;
      for(let s=0;s<4;s++){const t0=s/4,t1=(s+1)/4;const pt=t=>[Math.cos(a)*L*t,Math.sin(t*2.2)*.9*L-.45*t*t*L,Math.sin(a)*L*t];const A=pt(t0),B=pt(t1);const wx=-Math.sin(a)*w*(1-t0),wz=Math.cos(a)*w*(1-t0),vx=-Math.sin(a)*w*(1-t1),vz=Math.cos(a)*w*(1-t1);
        P.push(A[0]-wx,A[1],A[2]-wz,A[0]+wx,A[1],A[2]+wz,B[0]+vx,B[1],B[2]+vz,A[0]-wx,A[1],A[2]-wz,B[0]+vx,B[1],B[2]+vz,B[0]-vx,B[1],B[2]-vz);}}
    const g=new T.BufferGeometry();g.setAttribute('position',new T.Float32BufferAttribute(P,3));g.computeVertexNormals();return colGeo(g,c0,c1,1);};
  const mushGeo=(seed,cap)=>{const rr=MM.rng(seed);const parts=[];const n=1+Math.floor(rr()*3);for(let k=0;k<n;k++){const h=.35+rr()*.5,R=.22+rr()*.25;const st=new T.CylinderGeometry(.06,.09,h,5,1,true);st.translate(0,h/2,0);
      const cp=new T.SphereGeometry(R,7,3,0,6.28,0,Math.PI*.5);cp.scale(1,.55,1);cp.translate(0,h,0);const ox=(rr()-.5)*.6,oz=(rr()-.5)*.6;st.translate(ox,0,oz);cp.translate(ox,0,oz);
      parts.push(colGeo(st.toNonIndexed(),'#6e685e','#8a8378',1),colGeo(cp.toNonIndexed(),cap,cap,1));}return MM.merge(parts);};
  const veg=new T.Group();veg.name='VegetacaoVariada';const F=P.floresta;
  const put=(geo,mat,max,name,test,scl)=>{const m=new T.InstancedMesh(geo,mat,max);m.name=name;m.count=0;m.castShadow=false;m.receiveShadow=true;
    for(let t=0;t<max*14&&m.count<max;t++){const x=-270+r()*540,z=-230+r()*440;if(!ctx.inside(x,z)||!free(x,z))continue;const y=H(x,z);const nn=nrmAt(x,z);const k=test(x,y,z,nn);if(!k)continue;
      dummy.position.set(x,y-.08,z);dummy.rotation.set((r()-.5)*.2,r()*6.28,(r()-.5)*.2);const s=scl(k);dummy.scale.set(s*(.85+r()*.3),s*(.75+r()*.5),s*(.85+r()*.3));dummy.updateMatrix();m.setMatrixAt(m.count++,dummy.matrix);}veg.add(m);return m;};
  const pd=(x,z)=>ctx.pathDist(x,z);const fd=(x,z)=>Math.hypot(x-F.x,z-F.z);
  /* arbustos: bordas da floresta, pé de rochas e encostas suaves, longe das trilhas (3 formas × cores) */
  [['#141c19','#2c3d33'],['#17161f','#34304a'],['#191f15','#3c4530']].forEach((c,i)=>put(shrubGeo(900+i,c[0],c[1]),vegM,210,'Arbustos'+i,(x,y,z,nn)=>{if(y<2||y>58||nn.y<.82)return 0;const d=pd(x,z);if(d<2.5)return 0;
    const edgeF=MM.ss(F.r+30,F.r-10,fd(x,z))*(1-MM.ss(F.r-30,F.r-60,fd(x,z)));const cav=1-aoAt(x,z);const patch=MM.fbm(x/22,z/22,2,90+i)>.05;return (edgeF>.3||cav>.08||(patch&&d<9))&&r()<.7?1:0;},()=>.55+r()*.75));
  /* samambaias e plantas pequenas: lugares úmidos e sombreados, beira de trilha */
  [['#13241d','#34553f'],['#171a24','#3c4a5c']].forEach((c,i)=>put(fernGeo(950+i,c[0],c[1]),vegM,700,'PlantasPequenas'+i,(x,y,z,nn)=>{if(y<2||y>56||nn.y<.85)return 0;const d=pd(x,z);if(d<.6)return 0;
    const damp=(1-aoAt(x,z))*6+MM.ss(F.r,F.r-40,fd(x,z))+(d<4?.6:0);return damp>.5&&r()<.8?1:0;},()=>.6+r()*.9));
  /* almofadas de altitude: só nas bordas de estrato das montanhas */
  {const ag=tuftGeo(77);const C=ag.attributes.color;const a=MM.C('#2a2936'),b=MM.C('#55593f');for(let i=0;i<C.count;i++){const c=(i%3===2?b:a);C.setXYZ(i,c.r,c.g,c.b);}
    put(ag,gm,1400,'VegetacaoDeAltitude',(x,y,z,nn)=>y>44&&nn.y>.78&&nn.y<.97&&MM.noise2(x/18,z/18,91)>-.15?1:0,()=>.45+r()*.5);}
  /* cogumelos em anéis, dentro da floresta e perto da boca da caverna (levemente bioluminescentes) */
  {const mm=new T.MeshStandardMaterial({vertexColors:true,roughness:.6,emissive:MM.C('#0e2a36'),emissiveIntensity:.3});mm.name='Cogumelos';
    const caps=['#4a3760','#2c5560','#5e4a36'];caps.forEach((cap,i)=>{const m=new T.InstancedMesh(mushGeo(970+i,cap),mm,110);m.name='Cogumelos'+i;m.count=0;m.receiveShadow=true;
      for(let t=0;t<4000&&m.count<100;t++){const cx=(i===1?P.caverna.boca.x:F.x)+(r()-.5)*(i===1?60:F.r*1.6),cz=(i===1?P.caverna.boca.z+20:F.z)+(r()-.5)*(i===1?40:F.r*1.6);if(!ctx.inside(cx,cz)||pd(cx,cz)<2)continue;
        const n=5+Math.floor(r()*5),R=1.2+r()*1.8;for(let q=0;q<n&&m.count<100;q++){const a=q/n*6.28+r()*.3;const x=cx+Math.cos(a)*R,z=cz+Math.sin(a)*R;const y=H(x,z);dummy.position.set(x,y-.05,z);dummy.rotation.set(0,r()*6.28,0);dummy.scale.setScalar(.7+r()*.9);dummy.updateMatrix();m.setMatrixAt(m.count++,dummy.matrix);}t+=40;}
      veg.add(m);});}
  /* raízes superficiais na floresta: arcos meio enterrados */
  {const rg=new T.TorusGeometry(1.6,.22,5,10,Math.PI);const rm=new T.MeshStandardMaterial({color:MM.C('#3a2e2a'),roughness:.95});rm.name='RaizSuperficial';put(rg,rm,260,'RaizesSuperficiais',(x,y,z,nn)=>fd(x,z)<F.r-6&&pd(x,z)>1.5&&nn.y>.8?1:0,()=>.6+r()*1.1);
    const m=veg.children[veg.children.length-1];const mt=new T.Matrix4();for(let i=0;i<m.count;i++){m.getMatrixAt(i,mt);mt.multiply(new T.Matrix4().makeTranslation(0,-.5,0));m.setMatrixAt(i,mt);}}
  /* ---- trilhas: pedras de borda e cascalho (ficam fora da faixa de passagem) ---- */
  const bord=new T.InstancedMesh(MM.rockGeo(5100,.6,.32,.5,0),ctx.rockMat,900);bord.name='PedrasDeBorda';bord.count=0;bord.castShadow=false;bord.receiveShadow=true;
  ctx.terrain.paths.forEach(p=>{for(let i=1;i<p.S.length-1;i++){if(bord.count>=900)break;const [ax,az]=p.S[i-1],[bx,bz]=p.S[i+1];const dx=bx-ax,dz=bz-az,L=Math.hypot(dx,dz)||1;const nx=-dz/L,nz=dx/L;
    for(const sd of [-1,1]){if(r()<.45)continue;const off=p.hw+.4+r()*1.4;const x=p.S[i][0]+nx*off*sd+(r()-.5),z=p.S[i][1]+nz*off*sd+(r()-.5);if(!ctx.inside(x,z))continue;
      dummy.position.set(x,H(x,z)-.12,z);dummy.rotation.set((r()-.5)*.4,r()*6.28,(r()-.5)*.4);dummy.scale.setScalar(.6+r()*.9);dummy.updateMatrix();bord.setMatrixAt(bord.count++,dummy.matrix);}}});
  const o=MM.obj('STORM.TERRAIN.SURFACE','Superfície: grama, seixos, afloramentos, poças, depósitos','Terrain',{notes:'Instanciado: '+n+' tufos, '+pebs.reduce((a,m)=>a+m.count,0)+' seixos, '+outs.reduce((a,m)=>a+m.count,0)+' afloramentos (6 formas), '+pud.children.length+' poças, '+dep.children.length+' depósitos, '+veg.children.reduce((a,m)=>a+m.count,0)+' plantas (arbustos, samambaias, altitude, cogumelos, raízes), '+bord.count+' pedras de borda de trilha.'});
  o.add(grass);o.add(veg);o.add(bord);pebs.forEach(m=>o.add(m));outs.forEach(m=>o.add(m));o.add(pud);o.add(dep);out.push(o);return out;};
})();
