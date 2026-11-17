/* Magnata do Multiverso · Dimensões — material triplanar PBR
   Projeta as texturas pelos três eixos do mundo: paredões verticais recebem rocha de verdade em vez de textura esticada.
   Modo "terreno": mistura rocha/musgo/terra/lajes por vértice (atributo aW) + umidade (aWet). Modo "rocha": só rocha.
   Funciona em malhas instanciadas. No Roblox: vira MaterialVariant de Rock/Slate/Grass/Mud/Cobblestone com as mesmas texturas. */
(function(){const MM=window.MM,T=THREE;
const FUNCS=`
vec3 mmSrgb(vec3 c){return pow(c,vec3(2.2));}
vec3 mmTri(sampler2D t,vec3 p,vec3 b,float s){return texture2D(t,p.zy*s).rgb*b.x+texture2D(t,p.xz*s).rgb*b.y+texture2D(t,p.xy*s).rgb*b.z;}
vec3 mmTriN(sampler2D t,vec3 p,vec3 n,vec3 b,float s,float k){vec3 tx=texture2D(t,p.zy*s).xyz*2.-1.,ty=texture2D(t,p.xz*s).xyz*2.-1.,tz=texture2D(t,p.xy*s).xyz*2.-1.;
  tx.xy*=k;ty.xy*=k;tz.xy*=k;tx=vec3(tx.xy+n.zy,abs(tx.z)*n.x);ty=vec3(ty.xy+n.xz,abs(ty.z)*n.y);tz=vec3(tz.xy+n.xy,abs(tz.z)*n.z);return normalize(tx.zyx*b.x+ty.xzy*b.y+tz.xyz*b.z);}
vec3 mmTopN(sampler2D t,vec3 p,vec3 n,float s,float k){vec3 ty=texture2D(t,p.xz*s).xyz*2.-1.;ty.xy*=k;ty=vec3(ty.xy+n.xz,abs(ty.z)*n.y);return normalize(ty.xzy);}`;
MM.triplanar=function(opts){const tx=MM.tex;const terrain=opts.mode==='terreno';const m=new T.MeshStandardMaterial({color:0xffffff,roughness:.9,metalness:0,envMapIntensity:opts.env||.7});m.name=opts.name||'Triplanar';
  const u={tRockC:{value:tx.rocha.map},tRockN:{value:tx.rocha.normalMap},tMossC:{value:tx.musgo.map},tMossN:{value:tx.musgo.normalMap},tSoilC:{value:tx.terra.map},tSoilN:{value:tx.terra.normalMap},tPathC:{value:tx.lajes.map},tPathN:{value:tx.lajes.normalMap},
    uRockS:{value:opts.rockScale||.045},uTint:{value:new T.Color(opts.tint||'#ffffff')},uStrata:{value:opts.strata===undefined?1:opts.strata},uMossTop:{value:opts.mossTop||0}};
  m.userData.u=u;
  m.onBeforeCompile=sh=>{Object.assign(sh.uniforms,u);
    sh.vertexShader=sh.vertexShader.replace('#include <common>','#include <common>\nvarying vec3 vWP;varying vec3 vWN;varying vec4 vW;varying float vWet;varying float vAO;'+(terrain?'attribute vec4 aW;attribute float aWet;attribute float aAO;':''))
      .replace('#include <fog_vertex>','#include <fog_vertex>\n{vec4 wp=vec4(transformed,1.);vec3 wn=objectNormal;\n#ifdef USE_INSTANCING\nwp=instanceMatrix*wp;wn=mat3(instanceMatrix)*wn;\n#endif\nvWP=(modelMatrix*wp).xyz;vWN=normalize(mat3(modelMatrix)*wn);}'+(terrain?'vW=aW;vWet=aWet;vAO=aAO;':'vW=vec4(1.,0.,0.,0.);vWet=0.;vAO=1.;'));
    sh.fragmentShader=sh.fragmentShader.replace('#include <common>','#include <common>\nvarying vec3 vWP;varying vec3 vWN;varying vec4 vW;varying float vWet;varying float vAO;uniform sampler2D tRockC,tRockN,tMossC,tMossN,tSoilC,tSoilN,tPathC,tPathN;uniform float uRockS,uStrata,uMossTop;uniform vec3 uTint;'+FUNCS)
      .replace('vec4 diffuseColor = vec4( diffuse, opacity );',`
        vec3 N=normalize(vWN);vec3 b=pow(abs(N),vec3(5.));b/=(b.x+b.y+b.z);float slope=1.-N.y;
        float wR=clamp(max(vW.x,smoothstep(.34,.58,slope)),0.,1.);
        float topMoss=uMossTop*smoothstep(.62,.9,N.y)*smoothstep(.45,.75,texture2D(tMossC,vWP.xz*.013).g*1.6);wR*=1.-topMoss;
        float wP=vW.w*(1.-wR);float wS=vW.z*(1.-wR)*(1.-wP);float wM=max(0.,1.-wR-wP-wS);
        vec3 cR=mmSrgb(mmTri(tRockC,vWP,b,uRockS));float sn=texture2D(tRockC,vWP.xz*.0035).r;float sy=vWP.y+vWP.x*.05-vWP.z*.03+sn*14.;float strata=.95+.025*sin(sy*.11)+.02*sin(sy*.29+sn*6.)+.015*sin(sy*.71);float mt=texture2D(tMossC,vWP.xz*.0021+vWP.y*.002).g;strata*=.8+.4*smoothstep(.2,.8,mt);cR*=mix(1.,strata,uStrata);
        float macro=texture2D(tMossC,vWP.xz*.0045).g;
        vec3 cM=mmSrgb(texture2D(tMossC,vWP.xz*.07).rgb)*(.72+.56*macro);vec3 cS=mmSrgb(texture2D(tSoilC,vWP.xz*.11).rgb);vec3 cP=mmSrgb(texture2D(tPathC,vWP.xz*.075).rgb);
        vec3 alb=(cR*wR+cM*wM+cS*wS+cP*wP)*uTint;float wet=clamp(vWet,0.,1.);alb*=1.-.38*wet;alb*=mix(1.,vAO,.85);
        vec4 diffuseColor=vec4(alb,opacity);`)
      .replace('#include <roughnessmap_fragment>',`float roughnessFactor=wR*.88+wM*.93+wS*.72+wP*.62;roughnessFactor=mix(roughnessFactor,.16,wet*.85);`)
      .replace('#include <normal_fragment_maps>',`{vec3 nR=mmTriN(tRockN,vWP,N,b,uRockS,1.2);vec3 nM=mmTopN(tMossN,vWP,N,.07,.8);vec3 nS=mmTopN(tSoilN,vWP,N,.11,1.);vec3 nP=mmTopN(tPathN,vWP,N,.075,1.1);
        vec3 nW=normalize(nR*wR+nM*wM+nS*wS+nP*wP);nW=normalize(mix(nW,N,wet*.6));normal=normalize((viewMatrix*vec4(nW,0.)).xyz);}`);};
  m.customProgramCacheKey=()=>'tri-'+(terrain?'t':'r');return m;};
})();
