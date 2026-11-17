/* Ilha das Tempestades · Resources · Cristais energizados (locais de mineração)
   Cada mina é um modelo separado: base de rocha, cristais em leque (vocabulário da ilha) e núcleo de luz pequeno.
   No Roblox: Glass com transparência 0,3–0,5 + núcleo Neon menor por dentro. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
I.buildResources=function(ctx){const M=ctx.mat,out=[];
  I.minas.forEach((m,mi)=>{const o=MM.obj(m.id.replace('MINE','RES.MINE'),'Mina: '+m.nome,'Resources',{notes:'Local de mineração '+m.id+'. A extração ainda não está implementada; aqui é só a forma e a posição.'});
    const y=m.interno?26.4:ctx.heightAt(m.x,m.z);o.position.set(m.x,y,m.z);const r=MM.rng(500+mi*11);
    MM.mesh(MM.rockGeo(600+mi,6,2.4,5,1),M.pedraEscura,0,.6,0,o);
    const n=7+Math.floor(r()*4);for(let k=0;k<n;k++){const a=-.9+k/(n-1)*1.8+(r()-.5)*.2;const h=2.5+r()*5*(1-Math.abs(a)*.4);const c=MM.mesh(MM.crystalGeo(.5+r()*.6,h,1+r()*1.2),M.cristal,(r()-.5)*4,1.2,(r()-.5)*3,o);
      c.rotation.set((r()-.5)*.5,r()*Math.PI,a*.55);}
    MM.box(o,0,2.5,0,9,5,7);out.push(o);});
  return out;};
})();
