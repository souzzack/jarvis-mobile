/* Ilha das Tempestades · Lighting · céu de tempestade, mar de nuvens, bancos de nuvem, névoa e luzes
   Preset "completo" (sombra + luz da torre) e "simples" (sem sombra, para aparelhos fracos).
   No Roblox: Lighting.Technology Future, Atmosphere Density 0,38 / Haze 1,5, Sky com nuvens próprias, Clouds desligado. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
const NOISE='float h(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}float n2(vec2 p){vec2 i=floor(p),f=fract(p);vec2 u=f*f*(3.-2.*f);return mix(mix(h(i),h(i+vec2(1,0)),u.x),mix(h(i+vec2(0,1)),h(i+vec2(1,1)),u.x),u.y);}float fbm(vec2 p){float s=0.,a=.5;for(int i=0;i<5;i++){s+=a*n2(p);p*=2.03;a*=.5;}return s;}';
I.buildLighting=function(ctx){const pal=I.paleta,scene=ctx.scene;const L={};
  scene.fog=new T.FogExp2(MM.C(pal.nevoa),.00085);
  L.hemi=new T.HemisphereLight(MM.C('#9097c4'),MM.C('#2a2433'),.62);scene.add(L.hemi);
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
  L.setMode=function(full){L.sun.castShadow=full;L.beacon.visible=full;L.rim.visible=full;L.hemi.intensity=full?.62:.95;};
  L.update=function(t,flash){sky.material.uniforms.uT.value=t;sky.material.uniforms.uFlash.value=flash;sea.material.uniforms.uT.value=t;sea.material.uniforms.uFlash.value=flash;L.hemi.intensity=(L.sun.castShadow?.62:.95)+flash*.9;};
  return L;};
})();
