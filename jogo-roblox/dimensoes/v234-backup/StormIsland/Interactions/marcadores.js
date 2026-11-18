/* Ilha das Tempestades · Interactions · marcadores técnicos
   Representam ONDE cada sistema vai existir. Nenhuma mecânica está implementada aqui.
   No Roblox: Part invisível (Anchored, CanCollide false) com atributos Id/Tipo/Descricao, numa pasta Interactions. */
(function(){const MM=window.MM,T=THREE;const I=MM.islands.StormIsland;
I.markerColors={Spawn:'#7CFFB2',Portal:'#B48CFF',NPC:'#FFD27A',Mineração:'#43D9FF',Coleta:'#8EF0C8',Puzzle:'#FF8FCB','Área secreta':'#FFFFFF',Descoberta:'#F5C76B','Equipamento secreto':'#FF9D5C','Evento climático':'#7AA8FF','Passagem oculta':'#C8C8C8'};
function label(text,sub,color){const c=document.createElement('canvas');c.width=512;c.height=112;const g=c.getContext('2d');g.fillStyle='rgba(10,12,28,.82)';g.fillRect(0,0,512,112);g.fillStyle=color;g.fillRect(0,0,10,112);
  g.font='600 34px "Space Grotesk",system-ui,sans-serif';g.fillStyle='#fff';g.fillText(text,26,46);g.font='400 26px Inter,system-ui,sans-serif';g.fillStyle='#c9cfe6';g.fillText(sub.slice(0,34),26,88);
  const t=new T.CanvasTexture(c);const s=new T.Sprite(new T.SpriteMaterial({map:t,depthTest:false,transparent:true,sizeAttenuation:false}));s.scale.set(.16,.035,1);s.renderOrder=10;return s;}/* tamanho fixo na tela */
I.buildMarkers=function(ctx){const out=[];const grp=MM.obj('STORM.INTERACTIONS','Marcadores de interação','Interactions',{notes:'Marcadores técnicos, não mecânicas.'});
  I.marcadores.forEach(([id,tipo,desc,x,z])=>{const col=I.markerColors[tipo]||'#fff';let y=ctx.heightAt(x,z);if(id==='STORM.MINE.02'||id==='STORM.EQUIP.01')y=26.4;if(id==='STORM.PUZZLE.TOWER')y=I.poi.torre.h+60;if(id==='STORM.PUZZLE.OBS')y=I.poi.observatorio.h+14;
    const m=new T.Group();m.name=id;m.position.set(x,y,z);m.userData={id,tipo,desc,marker:true};
    const mat=new T.MeshBasicMaterial({color:col,depthTest:true});const d=new T.Mesh(new T.OctahedronGeometry(1.4,0),mat);d.position.y=7;d.scale.y=1.6;m.add(d);
    const ln=new T.Mesh(new T.CylinderGeometry(.12,.12,6,4),mat);ln.position.y=3;m.add(ln);const ring=new T.Mesh(new T.RingGeometry(2,2.5,24),new T.MeshBasicMaterial({color:col,side:T.DoubleSide,transparent:true,opacity:.7}));ring.rotation.x=-Math.PI/2;ring.position.y=.3;m.add(ring);
    const lb=label(id,tipo+' · '+desc,col);lb.position.y=13;lb.name='rotulo';m.add(lb);grp.add(m);});
  out.push(grp);return out;};
})();
