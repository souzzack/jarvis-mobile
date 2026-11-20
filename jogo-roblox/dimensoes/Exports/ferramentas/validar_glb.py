import json, struct, sys, math
p=sys.argv[1]
b=open(p,'rb').read()
magic,ver,tam=struct.unpack_from('<4sII',b,0)
assert magic==b'glTF', 'cabeçalho não é glTF'
assert tam==len(b), f'tamanho no cabeçalho {tam} != arquivo {len(b)}'
off=12; chunks=[]
while off<len(b):
    n,t=struct.unpack_from('<I4s',b,off); chunks.append((t,b[off+8:off+8+n])); off+=8+n
js=json.loads(chunks[0][1]); binc=chunks[1][1] if len(chunks)>1 else b''
acc=js.get('accessors',[]); bv=js.get('bufferViews',[])
COMP={5120:1,5121:1,5122:2,5123:2,5125:4,5126:4}; NC={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4,'MAT4':16}
def ler(i):
    a=acc[i]; v=bv[a['bufferView']]; base=v.get('byteOffset',0)+a.get('byteOffset',0)
    fmt={5126:'f',5125:'I',5123:'H',5121:'B'}[a['componentType']]; nc=NC[a['type']]; st=v.get('byteStride',COMP[a['componentType']]*nc)
    return [struct.unpack_from('<'+fmt*nc,binc,base+k*st) for k in range(a['count'])]
# matrizes dos nós (TRS) para posição no mundo
def mat_trs(n):
    if 'matrix' in n: m=n['matrix']; return [[m[c*4+r] for c in range(4)] for r in range(4)]
    t=n.get('translation',[0,0,0]); q=n.get('rotation',[0,0,0,1]); s=n.get('scale',[1,1,1]); x,y,z,w=q
    R=[[1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)],[2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)],[2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)]]
    return [[R[r][0]*s[0],R[r][1]*s[1],R[r][2]*s[2],t[r]] for r in range(3)]+[[0,0,0,1]]
def mul(A,B): return [[sum(A[r][k]*B[k][c] for k in range(4)) for c in range(4)] for r in range(4)]
nos=js['nodes']; mundo={}
def visitar(i,P):
    M=mul(P,mat_trs(nos[i])); mundo[i]=M
    for c in nos[i].get('children',[]): visitar(c,M)
I4=[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]
for r in js['scenes'][js.get('scene',0)]['nodes']: visitar(r,I4)
mn=[1e18]*3; mx=[-1e18]*3; tri_total=0; maior=('',0); prims=0; nan=0; malhas_usadas=0; por_malha=[]
for i,n in enumerate(nos):
    if 'mesh' not in n or i not in mundo: continue
    malhas_usadas+=1; M=mundo[i]; me=js['meshes'][n['mesh']]; t_malha=0
    for pr in me['primitives']:
        prims+=1; pos=ler(pr['attributes']['POSITION'])
        t=(acc[pr['indices']]['count'] if 'indices' in pr else len(pos))//3; t_malha+=t
        for (x,y,z) in pos:
            if any(math.isnan(v) or math.isinf(v) for v in (x,y,z)): nan+=1; continue
            w=[M[r][0]*x+M[r][1]*y+M[r][2]*z+M[r][3] for r in range(3)]
            for k in range(3): mn[k]=min(mn[k],w[k]); mx[k]=max(mx[k],w[k])
    tri_total+=t_malha; por_malha.append((t_malha,n.get('name') or me.get('name') or f'no{i}'))
    if t_malha>maior[1]: maior=(n.get('name') or me.get('name'),t_malha)
mats=js.get('materials',[]); texs=js.get('textures',[]); imgs=js.get('images',[])
cores_vertice=sum(1 for m in js['meshes'] for pr in m['primitives'] if 'COLOR_0' in pr['attributes'])
print(json.dumps({'arquivo':p,'bytes':len(b),'versao_gltf':ver,'gerador':js.get('asset',{}).get('generator'),'nos':len(nos),'malhas_com_no':malhas_usadas,'primitivas':prims,
 'triangulos':tri_total,'maior_malha':maior,'malhas_acima_10k':[x for x in por_malha if x[0]>10000],'malhas_acima_20k':[x for x in por_malha if x[0]>20000],
 'materiais':len(mats),'nomes_materiais':[m.get('name') for m in mats],'texturas':len(texs),'imagens':len(imgs),'primitivas_com_cor_por_vertice':cores_vertice,
 'vertices_nan':nan,'caixa_min':[round(v,2) for v in mn],'caixa_max':[round(v,2) for v in mx],'tamanho':[round(mx[k]-mn[k],2) for k in range(3)],
 'raiz':{k:nos[js['scenes'][0]['nodes'][0]].get(k) for k in ('name','translation','rotation','scale')}},ensure_ascii=False,indent=1))
