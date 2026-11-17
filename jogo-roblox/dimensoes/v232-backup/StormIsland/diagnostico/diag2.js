(()=>{const T=THREE,isl=window.__isl;const out={vert:{},inst:{},ocultosReais:[]};
/* volumes das construções = colisores (caixas orientadas) de Architecture/Props, exceto pedras e árvores */
const vol=isl.colliders.filter(c=>{const o=isl.reg.byId[c.id];const cat=o&&o.userData.cat;return (cat==='Architecture'||cat==='Props'||cat==='Resources')&&!/ROCKS/.test(c.id);});
const inside=(x,y,z,c,m)=>{const dx=x-c.p.x,dz=z-c.p.z;const cs=Math.cos(c.ry),sn=Math.sin(c.ry);const lx=dx*cs-dz*sn,lz=dx*sn+dz*cs;return Math.abs(lx)<c.s.x/2-m&&Math.abs(lz)<c.s.z/2-m&&y>c.p.y-c.s.y/2+m&&y<c.p.y+c.s.y/2-m;};
const v=new T.Vector3();
isl.reg.list.forEach(o=>{const id=o.userData.id;if(['Terrain','Lighting','Interactions'].includes(o.userData.cat)&&id!=='STORM.TERRAIN.SURFACE')return;o.updateMatrixWorld(true);
  o.traverse(m=>{if(!m.isMesh)return;if(m.isInstancedMesh){const mt=new T.Matrix4();for(let i=0;i<m.count;i++){m.getMatrixAt(i,mt);v.setFromMatrixPosition(mt).applyMatrix4(m.matrixWorld);v.y+=.5;for(const c of vol){if(c.id===id)continue;if(inside(v.x,v.y,v.z,c,.3)){const k=(m.name||'inst')+' → '+c.id;out.inst[k]=(out.inst[k]||0)+1;}}}return;}
    if(m.material&&m.material.visible===false&&!m.userData.realMat)return;const pa=m.geometry.attributes.position;const st=Math.max(1,Math.floor(pa.count/400));
    for(let i=0;i<pa.count;i+=st){v.fromBufferAttribute(pa,i).applyMatrix4(m.matrixWorld);for(const c of vol){if(c.id===id)continue;if(inside(v.x,v.y,v.z,c,.3)){const k=id+' → '+c.id;out.vert[k]=(out.vert[k]||0)+1;}}}});});
isl.reg.list.forEach(o=>o.traverse(m=>{if(m.isMesh&&!m.visible&&m.name!=='TerrenoLOD0'&&m.name!=='TerrenoLOD1')out.ocultosReais.push([o.userData.id,m.name]);}));
return JSON.stringify(out);})()
