/* Ilha das Tempestades · Resources · Cristais energizados (locais de mineração)
   Cada mina é um modelo separado: base de rocha, cristais em leque (vocabulário da ilha) e núcleo de luz pequeno.
   No Roblox: Glass com transparência 0,3–0,5 + núcleo Neon menor por dentro. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
/* V2.3.1: mina fora da faixa da trilha (a MINE.01 ficava a 4,5 studs do eixo da P2, dentro dos 12 de largura). Roda logo após o terreno,
   antes da floresta, para que as árvores e os marcadores já usem a posição corrigida. */
I.fixMinas=function(ctx){I.minas=I.minas.map(m=>{if(m.interno||ctx.pathDist(m.x,m.z)>=5)return m;for(let rr=2;rr<=20;rr+=2)for(let k=0;k<12;k++){const a=k/12*6.283;const cx=m.x+Math.cos(a)*rr,cz=m.z+Math.sin(a)*rr;if(ctx.inside(cx,cz)&&ctx.pathDist(cx,cz)>=5)return Object.assign({},m,{x:+cx.toFixed(1),z:+cz.toFixed(1),movida:[+(cx-m.x).toFixed(1),+(cz-m.z).toFixed(1)]});}return m;});
  I.marcadores.forEach(mk=>{const m=I.minas.find(q=>q.id===mk[0]);if(m&&m.movida){mk[3]=m.x;mk[4]=m.z;}});/* marcador acompanha a mina */};
I.buildResources=function(ctx){const M=ctx.mat,out=[];
  I.minas.forEach((m,mi)=>{const o=MM.obj(m.id.replace('MINE','RES.MINE'),'Mina: '+m.nome,'Resources',{notes:'Local de mineração '+m.id+'. A extração ainda não está implementada; aqui é só a forma e a posição.'});
    if(m.movida)o.userData.movida=m.movida;
    const y=m.interno?26.4:Math.min(...[[0,0],[5,0],[-5,0],[0,4],[0,-4]].map(([a,b])=>ctx.heightAt(m.x+a,m.z+b)))-.2;/* ponto mais baixo sob a rocha-base */o.position.set(m.x,y,m.z);const r=MM.rng(500+mi*11);
    MM.mesh(MM.rockGeo(600+mi,6,2.4,5,1),M.pedraEscura,0,.6,0,o);
    const n=7+Math.floor(r()*4);for(let k=0;k<n;k++){const a=-.9+k/(n-1)*1.8+(r()-.5)*.2;const h=2.5+r()*5*(1-Math.abs(a)*.4);const c=MM.mesh(MM.crystalGeo(.5+r()*.6,h,1+r()*1.2),M.cristal,(r()-.5)*4,1.2,(r()-.5)*3,o);
      c.rotation.set((r()-.5)*.5,r()*Math.PI,a*.55);}
    MM.box(o,0,2.5,0,9,5,7);out.push(o);});
  return out;};
})();
