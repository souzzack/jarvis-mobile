/* Ilha das Tempestades · Effects (todos desligáveis; a ilha não depende deles para ser legível)
   Relâmpagos distantes e na agulha da torre, clarão do céu, chuva fina em volta da câmera, arcos elétricos nas bobinas
   e nos para-raios da vila, anemômetro e cata-vento girando. No Roblox: Beam/Trail/ParticleEmitter + script no cliente. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
function bolt(a,b,jag,branches,r){const pts=[a.clone()];const n=14;for(let i=1;i<n;i++){const p=a.clone().lerp(b,i/n);p.x+=(r()-.5)*jag;p.z+=(r()-.5)*jag;p.y+=(r()-.5)*jag*.3;pts.push(p);}pts.push(b.clone());
  const segs=[];for(let i=0;i<pts.length-1;i++)segs.push(pts[i],pts[i+1]);for(let k=0;k<branches;k++){const s=pts[2+Math.floor(r()*(n-4))];let p=s.clone();for(let i=0;i<5;i++){const q=p.clone().add(new T.Vector3((r()-.5)*jag*1.2,-jag*(.5+r()*.6),(r()-.5)*jag*1.2));segs.push(p,q);p=q;}}return segs;}
I.buildEffects=function(ctx){const scene=ctx.scene,E={on:true,rain:true,t:0,flash:0,next:2,nextTower:6};const r=MM.rng(99);const grp=new T.Group();grp.name='Efeitos';scene.add(grp);
  const bMat=new T.LineBasicMaterial({color:MM.C('#dfe9ff'),transparent:true,opacity:0,fog:false});const bGeo=new T.BufferGeometry();const bolts=new T.LineSegments(bGeo,bMat);bolts.frustumCulled=false;grp.add(bolts);
  const glow=new T.LineSegments(bGeo,new T.LineBasicMaterial({color:MM.C('#7aa8ff'),transparent:true,opacity:0,fog:false,linewidth:3}));glow.frustumCulled=false;grp.add(glow);
  /* chuva: linhas curtas recicladas num cilindro em volta da câmera */
  const NR=2400,rp=new Float32Array(NR*6);const rGeo=new T.BufferGeometry();rGeo.setAttribute('position',new T.BufferAttribute(rp,3));const rain=new T.LineSegments(rGeo,new T.LineBasicMaterial({color:MM.C('#9fb4ff'),transparent:true,opacity:.28}));rain.frustumCulled=false;grp.add(rain);
  const drops=[];for(let i=0;i<NR;i++)drops.push({x:(r()-.5)*160,y:r()*90,z:(r()-.5)*160,v:70+r()*30});
  /* arcos elétricos: bobinas da torre e para-raios da vila → Coletor */
  const aGeo=new T.BufferGeometry();const arcs=new T.LineSegments(aGeo,new T.LineBasicMaterial({color:MM.C('#8fe9ff'),transparent:true,opacity:.85}));arcs.frustumCulled=false;grp.add(arcs);
  const edgeObj=ctx.reg.byId['STORM.TERRAIN.EDGE'],edgeAnim=edgeObj&&edgeObj.userData.anim;const tower=ctx.reg.byId['STORM.ARCH.TOWER'],plaza=ctx.reg.byId['STORM.ARCH.VILLAGE.PLAZA'];const rods=ctx.reg.list.filter(o=>o.userData.rodTip).map(o=>{o.updateMatrixWorld(true);return o.localToWorld(o.userData.rodTip.clone());});
  function setBolt(segs){const a=new Float32Array(segs.length*3);segs.forEach((p,i)=>{a[i*3]=p.x;a[i*3+1]=p.y;a[i*3+2]=p.z;});bGeo.setAttribute('position',new T.BufferAttribute(a,3));bGeo.computeBoundingSphere();}
  E.update=function(dt,cam){E.t+=dt;const on=E.on;grp.visible=on;
    if(tower){const A=tower.userData.anim;A.anem.rotation.y+=dt*(on?2.4:.6);A.vane.rotation.y=Math.sin(E.t*.3)*.5;if(tower.userData.update)tower.userData.update(dt,E.t,on);}
    if(edgeAnim&&edgeAnim.wMat)edgeAnim.wMat.uniforms.uT.value=E.t;
    if(!on){E.flash=0;return;}
    /* relâmpago distante ou na agulha */
    E.next-=dt;E.nextTower-=dt;let fired=false;
    if(E.nextTower<=0&&tower){E.nextTower=9+r()*8;const tip=tower.userData.tip;setBolt(bolt(new T.Vector3(tip.x+(r()-.5)*60,tip.y+260,tip.z+(r()-.5)*60),tip,9,3,r));fired=true;E.lastTower=E.t;}
    else if(E.next<=0){E.next=3+r()*6;const a=r()*Math.PI*2,d=520+r()*500;const top=new T.Vector3(Math.cos(a)*d,320+r()*120,Math.sin(a)*d);setBolt(bolt(top,top.clone().add(new T.Vector3((r()-.5)*80,-330-r()*120,(r()-.5)*80)),26,4,r));fired=true;}
    if(fired){E.boltAge=0;E.flash=1;}E.boltAge=(E.boltAge||9)+dt;const vis=E.boltAge<.08||(E.boltAge>.14&&E.boltAge<.22)?1:Math.max(0,1-E.boltAge*5);bMat.opacity=vis;glow.material.opacity=vis*.5;E.flash=Math.max(0,E.flash-dt*3.2);
    /* chuva */
    rain.visible=E.rain;if(E.rain){const c=cam.position;for(let i=0;i<NR;i++){const d=drops[i];d.y-=d.v*dt;if(d.y<-10){d.y=80+r()*20;d.x=(r()-.5)*160;d.z=(r()-.5)*160;}const x=c.x+d.x,y=c.y-30+d.y,z=c.z+d.z;rp[i*6]=x;rp[i*6+1]=y;rp[i*6+2]=z;rp[i*6+3]=x+.3;rp[i*6+4]=y-2.2;rp[i*6+5]=z+.2;}rGeo.attributes.position.needsUpdate=true;}
    /* arcos a ~12 quadros por segundo: bobinas da torre e um para-raios por vez até o Coletor */
    E.arcT=(E.arcT||0)-dt;if(E.arcT<=0){E.arcT=.08;const segs=[];
      if(tower)tower.userData.coils.forEach((c,i)=>{if(r()<.55){const a=r()*Math.PI*2;const p0=c.clone().add(new T.Vector3(Math.cos(a)*2.6,0,Math.sin(a)*2.6)),p1=c.clone().add(new T.Vector3(Math.cos(a+.6)*8.8,(r()-.5)*2,Math.sin(a+.6)*8.8));segs.push(...bolt(p0,p1,1.6,0,r));}});
      if(plaza&&rods.length&&r()<.5){const k=Math.floor(r()*rods.length);segs.push(...bolt(rods[k],plaza.userData.top,3,0,r));}
      const a=new Float32Array(segs.length*3);segs.forEach((p,i)=>{a[i*3]=p.x;a[i*3+1]=p.y;a[i*3+2]=p.z;});aGeo.setAttribute('position',new T.BufferAttribute(a,3));}
  };
  return E;};
})();
