/* Ilha das Tempestades · Lighting · céu de tempestade, mar de nuvens, bancos de nuvem, névoa e luzes
   Preset "completo" (sombra + luz da torre) e "simples" (sem sombra, para aparelhos fracos).
   No Roblox: Lighting.Technology Future, Atmosphere Density 0,38 / Haze 1,5, Sky com nuvens próprias, Clouds desligado. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
const NOISE='float h(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}float n2(vec2 p){vec2 i=floor(p),f=fract(p);vec2 u=f*f*(3.-2.*f);return mix(mix(h(i),h(i+vec2(1,0)),u.x),mix(h(i+vec2(0,1)),h(i+vec2(1,1)),u.x),u.y);}float fbm(vec2 p){float s=0.,a=.5;for(int i=0;i<5;i++){s+=a*n2(p);p*=2.03;a*=.5;}return s;}';
I.buildLighting=function(ctx){const pal=I.paleta,scene=ctx.scene;const L={};
  scene.fog=new T.FogExp2(MM.C(pal.nevoa),.00085);
  L.hemi=new T.HemisphereLight(MM.C('#8e92b2'),MM.C('#2b2630'),.62);scene.add(L.hemi);
  L.sun=new T.DirectionalLight(MM.C('#dfe2fb'),1.4);L.sun.position.set(-220,320,180);L.sun.castShadow=true;const sc=L.sun.shadow.camera;sc.left=-330;sc.right=330;sc.top=300;sc.bottom=-300;sc.near=50;sc.far=900;L.sun.shadow.mapSize.set(2048,2048);L.sun.shadow.bias=-.0006;L.sun.shadow.normalBias=.6;scene.add(L.sun);
  L.rim=new T.DirectionalLight(MM.C('#7a4dff'),.35);L.rim.position.set(260,120,-260);scene.add(L.rim);
  L.beacon=new T.PointLight(MM.C('#43d9ff'),1.4,190,2);L.beacon.position.set(I.poi.torre.x,I.poi.torre.h+76,I.poi.torre.z);scene.add(L.beacon);
  /* céu */
  const sky=new T.Mesh(new T.SphereGeometry(1800,40,20),new T.ShaderMaterial({side:T.BackSide,depthWrite:false,fog:false,uniforms:{uT:{value:0},uFlash:{value:0},top:{value:MM.C(pal.ceuTopo)},mid:{value:MM.C(pal.ceuMeio)},hor:{value:MM.C(pal.ceuHorizonte)}},
    vertexShader:'varying vec3 vP;void main(){vP=normalize(position);gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.);}',
    fragmentShader:'varying vec3 vP;uniform float uT,uFlash;uniform vec3 top,mid,hor;'+NOISE+'void main(){float y=vP.y;vec3 c=mix(hor,mid,smoothstep(-.05,.25,y));c=mix(c,top,smoothstep(.25,.85,y));vec2 q=vP.xz/(abs(y)+.35)*1.6;float n=fbm(q+vec2(uT*.006,uT*.003));float m=fbm(q*2.2-vec2(uT*.01,0.));float cl=smoothstep(.42,.78,n*.7+m*.4);c=mix(c,vec3(.16,.18,.32),cl*smoothstep(-.1,.3,y));c+=vec3(.42,.46,.8)*uFlash*cl*1.4+vec3(.15,.16,.3)*uFlash;c=mix(c,hor*.6,smoothstep(.0,-.4,y));gl_FragColor=vec4(c,1.);}'}));
  sky.name='CeuTempestade';scene.add(sky);L.sky=sky;
  /* mar de nuvens abaixo da ilha */
  const sea=new T.Mesh(new T.PlaneGeometry(9000,9000,1,1),new T.ShaderMaterial({transparent:true,depthWrite:false,fog:false,uniforms:{uT:{value:0},uFlash:{value:0}},
    vertexShader:'varying vec2 vU;void main(){vU=position.xy;gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.);}',
    fragmentShader:'varying vec2 vU;uniform float uT,uFlash;'+NOISE+'void main(){vec2 p=vU/260.;float n=fbm(p+vec2(uT*.01,uT*.004));float m=fbm(p*3.+n*2.);vec3 c=mix(vec3(.05,.06,.13),vec3(.2,.22,.38),smoothstep(.35,.85,n*.6+m*.5));c+=vec3(.25,.3,.6)*uFlash*m;float d=length(vU)/4200.;gl_FragColor=vec4(c,1.-smoothstep(.35,1.,d));}'}));
  sea.rotation.x=-Math.PI/2;sea.position.y=-260;sea.name='MarDeNuvens';scene.add(sea);L.sea=sea;
  /* bancos de nuvem estilizados (esferas achatadas facetadas) em volta da ilha */
  const cl=MM.obj('STORM.FX.CLOUDBANKS','Bancos de nuvem','Lighting',{notes:'Decoração distante, sem colisão. No Roblox: MeshParts de nuvem com transparência e Atmosphere.'});
  const cm=new T.MeshStandardMaterial({color:MM.C('#34364f'),roughness:1,flatShading:true,transparent:true,opacity:.9,fog:true});cm.name='Nuvem';
  const r=MM.rng(2024);for(let k=0;k<26;k++){const a=k/26*Math.PI*2+r()*.2;const rad=470+r()*320;const cx=Math.cos(a)*rad,cz=Math.sin(a)*rad,cy=-190+r()*150;const g=new T.Group();g.position.set(cx,cy,cz);
    const n=4+Math.floor(r()*4);for(let i=0;i<n;i++){const s=26+r()*40;const m=new T.Mesh(new T.IcosahedronGeometry(s,1),cm);m.scale.y=.45+r()*.2;m.position.set((r()-.5)*90,(r()-.3)*18,(r()-.5)*60);g.add(m);}cl.add(g);}
  scene.add(cl);L.clouds=cl;
  /* mapa de ambiente gerado do próprio céu: o que o metal, o cobre e as superfícies molhadas refletem */
  if(MM.renderer){const c=document.createElement('canvas');c.width=512;c.height=256;const g=c.getContext('2d');const gr=g.createLinearGradient(0,0,0,256);
    gr.addColorStop(0,'#0b0e22');gr.addColorStop(.38,'#232a55');gr.addColorStop(.5,'#6a72a6');gr.addColorStop(.56,'#3a4070');gr.addColorStop(1,'#14131f');g.fillStyle=gr;g.fillRect(0,0,512,256);
    const rr=MM.rng(5);for(let i=0;i<60;i++){g.fillStyle='rgba(170,180,230,'+(.04+rr()*.08)+')';g.beginPath();g.ellipse(rr()*512,90+rr()*40,30+rr()*80,6+rr()*14,0,0,Math.PI*2);g.fill();}
    const sx=(Math.atan2(L.sun.position.z,L.sun.position.x)/(Math.PI*2)+.5)*512;const sg=g.createRadialGradient(sx,70,0,sx,70,70);sg.addColorStop(0,'rgba(230,234,255,.9)');sg.addColorStop(1,'rgba(230,234,255,0)');g.fillStyle=sg;g.fillRect(sx-80,0,160,150);
    const t=new T.CanvasTexture(c);t.mapping=T.EquirectangularReflectionMapping;t.encoding=T.sRGBEncoding;const pm=new T.PMREMGenerator(MM.renderer);scene.environment=pm.fromEquirectangular(t).texture;pm.dispose();}
  /* neblina baixa nos vales: camadas de sprites suaves que derivam devagar */
  {const c=document.createElement('canvas');c.width=c.height=128;const g=c.getContext('2d');const gr=g.createRadialGradient(64,64,0,64,64,64);gr.addColorStop(0,'rgba(255,255,255,.55)');gr.addColorStop(.6,'rgba(255,255,255,.18)');gr.addColorStop(1,'rgba(255,255,255,0)');g.fillStyle=gr;g.fillRect(0,0,128,128);
    const tx=new T.CanvasTexture(c);const mist=new T.Group();mist.name='NeblinaBaixa';const rr=MM.rng(9);
    const spots=[[I.poi.floresta.x,I.poi.floresta.z,70,10],[110,110,30,-20],[I.poi.vila.x,I.poi.vila.z+30,40,18],[-60,-110,60,40],[60,-120,50,50],[180,0,40,30],[0,40,50,14]];
    spots.forEach(([x,z,R,y])=>{for(let i=0;i<9;i++){const sm=new T.SpriteMaterial({map:tx,color:MM.C('#8f97c6'),transparent:true,opacity:.16+rr()*.1,depthWrite:false,fog:true});const s=new T.Sprite(sm);const a=rr()*6.28,d=rr()*R;
      s.position.set(x+Math.cos(a)*d,y+rr()*8,z+Math.sin(a)*d);const k=40+rr()*50;s.scale.set(k*1.8,k*.5,1);s.userData.base=s.position.clone();s.userData.ph=rr()*6;mist.add(s);}});
    scene.add(mist);L.mist=mist;}
  L.setMode=function(full){L.sun.castShadow=full;L.beacon.visible=full;L.rim.visible=full;L.hemi.intensity=full?.62:.95;};
  L.update=function(t,flash){if(L.mist)L.mist.children.forEach(s=>{s.position.x=s.userData.base.x+Math.sin(t*.05+s.userData.ph)*14;s.position.z=s.userData.base.z+Math.cos(t*.04+s.userData.ph)*10;});sky.material.uniforms.uT.value=t;sky.material.uniforms.uFlash.value=flash;sea.material.uniforms.uT.value=t;sea.material.uniforms.uFlash.value=flash;L.hemi.intensity=(L.sun.castShadow?.62:.95)+flash*.9;};
  return L;};
})();
