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
  const free=(x,z)=>!keep.some(k=>Math.hypot(k.x-x,k.z-z)<k.r);const dummy=new T.Object3D();
  /* ---- grama irregular ---- */
  const tg=tuftGeo(5);const gm=new T.MeshStandardMaterial({vertexColors:true,roughness:.9,side:T.DoubleSide});gm.name='GramaTufos';
  const NG=5200;const grass=new T.InstancedMesh(tg,gm,NG);grass.name='GramaInstanciada';let n=0;
  for(let t=0;t<NG*6&&n<NG;t++){const x=-270+r()*540,z=-220+r()*430;if(!ctx.inside(x,z)||!free(x,z))continue;const y=H(x,z);if(y<2||y>60)continue;const nn=nrmAt(x,z);if(nn.y<.86)continue;if(ctx.pathDist(x,z)<1)continue;
    /* tufos em manchas, não uniformes */if(MM.fbm(x/26,z/26,3,77)<-.05&&r()<.75)continue;
    dummy.position.set(x,y-.05,z);dummy.rotation.set(0,r()*6.28,0);const s=.7+r()*1.1;dummy.scale.set(s,s*(.7+r()*.8),s);dummy.updateMatrix();grass.setMatrixAt(n++,dummy.matrix);}
  grass.count=n;grass.receiveShadow=true;
  /* ---- seixos ---- */
  const pebG=[0,1,2].map(i=>MM.rockGeo(5000+i,.45,.28,.4,1));const pebs=pebG.map((g,i)=>{const m=new T.InstancedMesh(g,ctx.rockMat,700);m.name='Seixos'+i;m.castShadow=true;m.receiveShadow=true;m.count=0;return m;});
  for(let t=0;t<9000;t++){const x=-270+r()*540,z=-220+r()*430;if(!ctx.inside(x,z))continue;const y=H(x,z);if(y<1)continue;const pd=ctx.pathDist(x,z);if(pd>6&&r()<.6)continue;/* mais perto das trilhas (desgaste) */
    const m=pebs[t%3];if(m.count>=700)continue;dummy.position.set(x,y,z);dummy.rotation.set(r()*.5,r()*6.28,r()*.5);const s=.6+r()*r()*2.6;dummy.scale.setScalar(s);dummy.updateMatrix();m.setMatrixAt(m.count++,dummy.matrix);}
  /* ---- afloramentos de rocha fraturada nas encostas e montanhas ---- */
  const outG=[0,1,2,3,4,5].map(i=>MM.rockGeo(7000+i*13,3.4+i*.3,2.2+(i%3)*.8,3+(i%2),2));const outs=outG.map((g,i)=>{const m=new T.InstancedMesh(g,ctx.rockMat,34);m.name='Afloramentos'+i;m.castShadow=true;m.receiveShadow=true;m.count=0;return m;});
  for(let t=0;t<6000;t++){const x=-270+r()*540,z=-230+r()*440;if(!ctx.inside(x,z)||!free(x,z))continue;const y=H(x,z);const nn=nrmAt(x,z);const steep=1-nn.y;if(steep<.18&&y<40)continue;if(ctx.pathDist(x,z)<5)continue;
    const m=outs[t%6];if(m.count>=34)continue;if(y>70&&r()<.85)continue;/* poucos no alto: o relevo e os estratos é que mostram a montanha */dummy.position.set(x,y-.6,z);dummy.quaternion.setFromUnitVectors(new T.Vector3(0,1,0),nn.clone().lerp(new T.Vector3(0,1,0),.5).normalize());dummy.rotateY(r()*6.28);
    const s=.6+r()*1.3;dummy.scale.set(s*(.8+r()*.4),s*(.6+r()*.7),s*(.8+r()*.4));dummy.updateMatrix();m.setMatrixAt(m.count++,dummy.matrix);}
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
  const o=MM.obj('STORM.TERRAIN.SURFACE','Superfície: grama, seixos, afloramentos, poças, depósitos','Terrain',{notes:'Instanciado: '+n+' tufos, '+pebs.reduce((a,m)=>a+m.count,0)+' seixos, '+outs.reduce((a,m)=>a+m.count,0)+' afloramentos (6 formas), '+pud.children.length+' poças, '+dep.children.length+' depósitos.'});
  o.add(grass);pebs.forEach(m=>o.add(m));outs.forEach(m=>o.add(m));o.add(pud);o.add(dep);out.push(o);return out;};
})();
