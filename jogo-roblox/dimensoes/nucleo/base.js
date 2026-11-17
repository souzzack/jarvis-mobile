/* Magnata do Multiverso · Dimensões — núcleo compartilhado
   Unidade: 1 = 1 stud do Roblox. Eixo Y para cima; +Z aponta para a chegada (sul) de cada ilha.
   Tudo aqui é reaproveitado pelas seis dimensões: ruído, materiais, registro de objetos, colisores e utilitários. */
(function(){
const T=THREE;const MM=window.MM=window.MM||{};MM.T=T;MM.islands=MM.islands||{};

/* ---------- números ---------- */
MM.rng=function(seed){let a=(seed|0)||1;return function(){a=(a+0x6D2B79F5)|0;let t=Math.imul(a^(a>>>15),1|a);t=(t+Math.imul(t^(t>>>7),61|t))^t;return((t^(t>>>14))>>>0)/4294967296;};};
function hash(x,y,s){let h=Math.imul(x|0,374761393)^Math.imul(y|0,668265263)^Math.imul(s|0,1442695041);h=Math.imul(h^(h>>>13),1274126177);h^=h>>>16;return (h>>>0)/4294967296;}
MM.noise2=function(x,y,s){s=s||0;const xi=Math.floor(x),yi=Math.floor(y),xf=x-xi,yf=y-yi;const u=xf*xf*(3-2*xf),v=yf*yf*(3-2*yf);
  const a=hash(xi,yi,s),b=hash(xi+1,yi,s),c=hash(xi,yi+1,s),d=hash(xi+1,yi+1,s);return(a+(b-a)*u+(c-a)*v+(a-b-c+d)*u*v)*2-1;};
MM.fbm=function(x,y,o,s){o=o||5;s=s||0;let t=0,a=.5,f=1,n=0;for(let i=0;i<o;i++){t+=a*MM.noise2(x*f,y*f,s+i*17);n+=a;a*=.5;f*=2.03;}return t/n;};
MM.ridged=function(x,y,o,s){o=o||5;s=s||0;let t=0,a=.5,f=1,n=0,w=1;for(let i=0;i<o;i++){let r=1-Math.abs(MM.noise2(x*f,y*f,s+i*31));r*=r;r*=w;w=Math.min(1,r*1.6);t+=a*r;n+=a;a*=.5;f*=2.1;}return t/n;};
MM.clamp=(x,a,b)=>Math.max(a,Math.min(b,x));MM.lerp=(a,b,t)=>a+(b-a)*t;
MM.ss=(a,b,x)=>{const t=MM.clamp((x-a)/(b-a),0,1);return t*t*(3-2*t);};
MM.segDist=function(px,pz,ax,az,bx,bz){const dx=bx-ax,dz=bz-az;const L=dx*dx+dz*dz||1;const t=MM.clamp(((px-ax)*dx+(pz-az)*dz)/L,0,1);const qx=ax+dx*t-px,qz=az+dz*t-pz;return{d:Math.sqrt(qx*qx+qz*qz),t};};
MM.C=h=>new T.Color(h).convertSRGBToLinear();/* cores da paleta em sRGB → espaço linear do renderizador */

/* ---------- materiais: poucos, nomeados e adaptáveis (no Roblox viram MaterialVariant/SurfaceAppearance) ---------- */
function std(name,o){if(typeof o.color==='string')o.color=MM.C(o.color);const m=new T.MeshStandardMaterial(Object.assign({roughness:.85,metalness:0},o));m.name=name;return m;}
MM.makeMaterials=function(pal){return{
  pedra:std('PedraArdosia',{color:pal.pedra,roughness:.92,flatShading:true}),
  pedraClara:std('PedraClara',{color:pal.pedraClara,roughness:.9,flatShading:true}),
  pedraEscura:std('PedraEscura',{color:pal.pedraEscura,roughness:.95,flatShading:true}),
  alvenaria:std('Alvenaria',{color:pal.alvenaria,roughness:.9}),
  metal:std('MetalRebitado',{color:pal.metal,metalness:.75,roughness:.38}),
  metalEscuro:std('MetalEscuro',{color:pal.metalEscuro,metalness:.6,roughness:.5}),
  cobre:std('Cobre',{color:pal.cobre,metalness:.8,roughness:.35}),
  patina:std('CobrePatina',{color:pal.patina,metalness:.35,roughness:.6}),
  madeira:std('MadeiraEscura',{color:pal.madeira,roughness:.85}),
  telhado:std('TelhadoMetal',{color:pal.telhado,metalness:.5,roughness:.5,flatShading:true}),
  corda:std('Corda',{color:pal.corda,roughness:1}),
  vidro:std('VidroEscuro',{color:pal.vidro,metalness:.2,roughness:.15,emissive:MM.C(pal.janela),emissiveIntensity:.85}),
  cristal:std('CristalEnergizado',{color:pal.cristal,roughness:.15,metalness:.1,transparent:true,opacity:.82,emissive:MM.C(pal.energia),emissiveIntensity:.55,flatShading:true}),
  energia:std('Energia',{color:pal.energia,emissive:MM.C(pal.energia),emissiveIntensity:1.6,roughness:.4}),
  lanterna:std('Lanterna',{color:pal.lanterna,emissive:MM.C(pal.lanterna),emissiveIntensity:1.1}),
  folhagem:std('Folhagem',{color:pal.folhagem,roughness:.9,flatShading:true}),
  casca:std('Casca',{color:pal.casca,roughness:.95,flatShading:true}),
  veio:std('VeioEletrico',{color:pal.veio,emissive:MM.C(pal.veio),emissiveIntensity:1.2}),
  tecido:std('Tecido',{color:pal.tecido,roughness:1,side:T.DoubleSide})};};

/* ---------- registro de objetos (cada modelo inspecionável) ---------- */
MM.Registry=function(){this.list=[];this.byId={};};
MM.Registry.prototype.add=function(o){if(this.byId[o.userData.id])console.warn('id repetido',o.userData.id);this.byId[o.userData.id]=o;this.list.push(o);return o;};
/* obj(): um modelo com identidade. cat = pasta do módulo (Terrain, Architecture, Vegetation, Resources, Props, Interactions, Lighting, Effects) */
MM.obj=function(id,name,cat,extra){const g=new T.Group();g.name=name;g.userData=Object.assign({id,name,cat,colliders:[],walk:[],animated:false,notes:''},extra||{});return g;};
/* colisor em caixa, em coordenadas locais do modelo (no Roblox: peça invisível CanCollide) */
MM.box=function(g,cx,cy,cz,sx,sy,sz,ry){g.userData.colliders.push({c:[cx,cy,cz],s:[sx,sy,sz],ry:ry||0});};
MM.mesh=function(geo,mat,x,y,z,parent){const m=new T.Mesh(geo,mat);m.position.set(x||0,y||0,z||0);m.castShadow=true;m.receiveShadow=true;if(parent)parent.add(m);return m;};

/* ---------- geometria utilitária ---------- */
MM.catenary=function(a,b,sag,n){n=n||24;const pts=[];for(let i=0;i<=n;i++){const t=i/n;const p=new T.Vector3().lerpVectors(a,b,t);p.y-=sag*4*t*(1-t);pts.push(p);}return pts;};
MM.tube=function(pts,r,mat,seg,rad){const c=new T.CatmullRomCurve3(pts);const m=new T.Mesh(new T.TubeGeometry(c,seg||Math.max(8,pts.length*2),r,rad||5,false),mat);m.castShadow=true;return m;};
/* rocha única: icosaedro deformado por ruído e achatado (cada semente gera uma forma diferente) */
MM.rockGeo=function(seed,sx,sy,sz,detail){const g=new T.IcosahedronGeometry(1,detail===undefined?1:detail);const p=g.attributes.position;const r=MM.rng(seed);const o=[r()*50,r()*50];
  for(let i=0;i<p.count;i++){const x=p.getX(i),y=p.getY(i),z=p.getZ(i);const n=1+.28*MM.noise2(x*1.6+o[0],z*1.6+y*1.3+o[1],seed)+.12*MM.noise2(x*3.7,y*3.7+z,seed+3);
    let yy=y*n*sy;if(yy<-sy*.35)yy=-sy*.35-(yy+sy*.35)*.15;p.setXYZ(i,x*n*sx,yy,z*n*sz);}
  /* fraturas: planos de corte achatam partes da rocha (faces quebradas) e sulcos de estrato */
  if((detail||0)>=2){const v=new T.Vector3();const planes=[];const k=2+Math.floor(r()*3);for(let q=0;q<k;q++){const n=new T.Vector3(r()-.5,(r()-.3)*.8,r()-.5).normalize();planes.push([n,.55+r()*.25]);}
    for(let i=0;i<p.count;i++){v.set(p.getX(i)/sx,p.getY(i)/sy,p.getZ(i)/sz);for(const [n,d] of planes){const t=v.dot(n);if(t>d)v.addScaledVector(n,-(t-d)*.92);}
      const str=1-.035*Math.max(0,Math.sin(v.y*14+r()*0))*(v.y>-.3?1:0);p.setXYZ(i,v.x*sx*str,v.y*sy,v.z*sz*str);}}
  g.computeVertexNormals();return g;};
/* prisma hexagonal facetado (cristal) apontando para +Y */
MM.crystalGeo=function(r,h,tip){const g=new T.CylinderGeometry(r*.8,r,h,6,1);g.translate(0,h/2,0);const c=new T.ConeGeometry(r*.8,tip||r*1.8,6);c.translate(0,h+(tip||r*1.8)/2,0);return MM.merge([g,c]);};
MM.merge=function(geos){const nonIdx=geos.map(g=>g.index?g.toNonIndexed():g);let n=0;nonIdx.forEach(g=>n+=g.attributes.position.count);const P=new Float32Array(n*3),N=new Float32Array(n*3);let o=0;
  nonIdx.forEach(g=>{if(!g.attributes.normal)g.computeVertexNormals();P.set(g.attributes.position.array,o*3);N.set(g.attributes.normal.array,o*3);o+=g.attributes.position.count;});
  const out=new T.BufferGeometry();out.setAttribute('position',new T.BufferAttribute(P,3));out.setAttribute('normal',new T.BufferAttribute(N,3));
  if(nonIdx.every(g=>g.attributes.color)){const C=new Float32Array(n*3);let q=0;nonIdx.forEach(g=>{C.set(g.attributes.color.array,q*3);q+=g.attributes.color.count;});out.setAttribute('color',new T.BufferAttribute(C,3));}return out;};
/* bake(): funde as peças estáticas de um modelo por material (menos chamadas de desenho e GLB mais limpo).
   Partes animadas (userData.animated) e sprites ficam separadas. */
MM.bake=function(obj){obj.updateMatrixWorld(true);const inv=new T.Matrix4().copy(obj.matrixWorld).invert();const groups=new Map();const kill=[];
  obj.traverse(m=>{if(!m.isMesh||m.isInstancedMesh)return;let p=m.parent;while(p&&p!==obj){if(p.userData&&p.userData.animated)return;p=p.parent;}if(m.name)return;
    const g=m.geometry.index?m.geometry.toNonIndexed():m.geometry.clone();if(!g.attributes.normal)g.computeVertexNormals();
    const mat=new T.Matrix4().multiplyMatrices(inv,m.matrixWorld);g.applyMatrix4(mat);const key=m.material.uuid+(m.material.side===T.BackSide?'b':'');if(!groups.has(key))groups.set(key,{mat:m.material,geos:[],cast:m.castShadow});groups.get(key).geos.push(g);kill.push(m);});
  kill.forEach(m=>m.parent.remove(m));
  groups.forEach(v=>{const merged=MM.merge(v.geos);const mm=new T.Mesh(merged,v.mat);mm.castShadow=v.cast;mm.receiveShadow=true;obj.add(mm);});};
MM.tris=function(o){let t=0;o.traverse(m=>{if(m.isMesh&&m.geometry){const g=m.geometry;t+=(g.index?g.index.count:g.attributes.position.count)/3*(m.isInstancedMesh?m.count:1);}});return Math.round(t);};

/* ---------- boneco de escala com as proporções do avatar padrão (≈5,2 studs) ---------- */
MM.makeDummy=function(){const g=new T.Group();g.name='BonecoEscala';const skin=std('BonecoPele',{color:'#f2c28b'}),shirt=std('BonecoCamisa',{color:'#3b6fd8'}),pants=std('BonecoCalca',{color:'#2b3550'});
  const b=(w,h,d,m,x,y,z)=>{const k=MM.mesh(new T.BoxGeometry(w,h,d),m,x,y,z,g);return k;};
  b(.95,2,.95,pants,-.5,1,0);b(.95,2,.95,pants,.5,1,0);b(2,2,1,shirt,0,3,0);b(.95,2,.95,skin,-1.5,3,0);b(.95,2,.95,skin,1.5,3,0);
  const head=MM.mesh(new T.CylinderGeometry(.62,.62,1.2,16),skin,0,4.6,0,g);
  const face=MM.mesh(new T.PlaneGeometry(.5,.25),std('BonecoRosto',{color:'#1b1b1b'}),0,4.6,.63,g);face.castShadow=false;
  g.userData={id:'DUMMY',name:'Boneco de escala (5,2 studs)',cat:'Escala',colliders:[]};return g;};

/* ---------- zip sem compressão (vários arquivos) para o pacote de exportação ---------- */
MM.zip=function(files){const crcT=[];for(let n=0;n<256;n++){let c=n;for(let k=0;k<8;k++)c=c&1?0xEDB88320^(c>>>1):c>>>1;crcT[n]=c>>>0;}
  const crc=u8=>{let c=0xFFFFFFFF;for(let i=0;i<u8.length;i++)c=crcT[(c^u8[i])&255]^(c>>>8);return(c^0xFFFFFFFF)>>>0;};
  const enc=new TextEncoder();const parts=[],cent=[];let off=0;
  files.forEach(f=>{const nm=enc.encode(f.name),d=f.data instanceof Uint8Array?f.data:enc.encode(f.data);const c=crc(d);const L=new DataView(new ArrayBuffer(30));
    L.setUint32(0,0x04034b50,true);L.setUint16(4,20,true);L.setUint16(6,0x0800,true);L.setUint32(14,c,true);L.setUint32(18,d.length,true);L.setUint32(22,d.length,true);L.setUint16(26,nm.length,true);
    const Cd=new DataView(new ArrayBuffer(46));Cd.setUint32(0,0x02014b50,true);Cd.setUint16(4,20,true);Cd.setUint16(6,20,true);Cd.setUint16(8,0x0800,true);Cd.setUint32(16,c,true);Cd.setUint32(20,d.length,true);Cd.setUint32(24,d.length,true);Cd.setUint16(28,nm.length,true);Cd.setUint32(42,off,true);
    parts.push(L.buffer,nm,d);cent.push(Cd.buffer,nm);off+=30+nm.length+d.length;});
  let cs=0;cent.forEach(p=>cs+=p.byteLength||p.length);const E=new DataView(new ArrayBuffer(22));E.setUint32(0,0x06054b50,true);E.setUint16(8,files.length,true);E.setUint16(10,files.length,true);E.setUint32(12,cs,true);E.setUint32(16,off,true);
  return new Blob(parts.concat(cent,[E.buffer]));};
})();
