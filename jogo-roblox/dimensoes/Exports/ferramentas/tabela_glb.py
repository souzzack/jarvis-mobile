# Uso: python -I tabela_glb.py ARQ.glb pivoX pivoY pivoZ alvoX alvoY alvoZ
# Gera (stdout) uma tabela Luau com, para cada malha: posição final no Studio (centro da caixa), material,
# cor-base autoral (hex), se tem textura e triângulos; e imprime em stderr centro e desvio do pivô.
# A posição final assume: modelo posicionado com o pivô da ilha no alvo e a mesma rotação da ilha.
import json,struct,sys
arq=sys.argv[1]; PIV=[float(v) for v in sys.argv[2:5]]; ALVO=[float(v) for v in sys.argv[5:8]]
b=open(arq,'rb').read(); n=struct.unpack_from('<I',b,12)[0]; js=json.loads(b[20:20+n]); off=20+n; n2=struct.unpack_from('<I',b,off)[0]; binc=b[off+8:off+8+n2]
acc=js['accessors']; bv=js['bufferViews']; nos=js['nodes']; mats=js.get('materials',[])
def ler(i):
    a=acc[i]; v=bv[a['bufferView']]; base=v.get('byteOffset',0)+a.get('byteOffset',0); st=v.get('byteStride',12)
    return [struct.unpack_from('<fff',binc,base+k*st) for k in range(a['count'])]
def trs(nd):
    if 'matrix' in nd: m=nd['matrix']; return [[m[c*4+r] for c in range(4)] for r in range(4)]
    t=nd.get('translation',[0,0,0]); x,y,z,w=nd.get('rotation',[0,0,0,1]); s=nd.get('scale',[1,1,1])
    R=[[1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)],[2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)],[2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)]]
    return [[R[r][0]*s[0],R[r][1]*s[1],R[r][2]*s[2],t[r]] for r in range(3)]+[[0,0,0,1]]
def mul(A,B): return [[sum(A[r][k]*B[k][c] for k in range(4)) for c in range(4)] for r in range(4)]
W={}
def vis(i,P):
    W[i]=mul(P,trs(nos[i]))
    for c in nos[i].get('children',[]): vis(c,W[i])
for r in js['scenes'][0]['nodes']: vis(r,[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]])
def srgb(c): return round(255*((12.92*c) if c<=0.0031308 else (1.055*c**(1/2.4)-0.055)))
gmn=[1e18]*3; gmx=[-1e18]*3; linhas=[]
for i,nd in enumerate(nos):
    if 'mesh' not in nd: continue
    M=W[i]; mn=[1e18]*3; mx=[-1e18]*3; tri=0; mi=None
    for pr in js['meshes'][nd['mesh']]['primitives']:
        mi=pr.get('material'); tri+=(acc[pr['indices']]['count'] if 'indices' in pr else acc[pr['attributes']['POSITION']]['count'])//3
        for (x,y,z) in ler(pr['attributes']['POSITION']):
            w=[M[r][0]*x+M[r][1]*y+M[r][2]*z+M[r][3] for r in range(3)]
            for k in range(3): mn[k]=min(mn[k],w[k]); mx[k]=max(mx[k],w[k])
    for k in range(3): gmn[k]=min(gmn[k],mn[k]); gmx[k]=max(gmx[k],mx[k])
    m=mats[mi] if mi is not None else {}; pbr=m.get('pbrMetallicRoughness',{}); f=pbr.get('baseColorFactor',[1,1,1,1])
    nome=m.get('name') or 'SemMaterial'
    # "Rocha" = substituto do shader triplanar no exportador: cor gravada SEM conversão (autoral #5b5e72)
    cor='5b5e72' if nome=='Rocha' else '%02x%02x%02x'%tuple(srgb(c) for c in f[:3])
    emis=m.get('emissiveFactor') or [0,0,0]
    c=[(mn[k]+mx[k])/2-PIV[k]+ALVO[k] for k in range(3)]
    linhas.append('{%d,%.3f,%.3f,%.3f,"%s","%s",%s,%d,%.2f,%s}'%(i,c[0],c[1],c[2],nome,cor,'true' if 'baseColorTexture' in pbr else 'false',tri,f[3],'true' if max(emis)>0.3 else 'false'))
centro=[(gmn[k]+gmx[k])/2 for k in range(3)]
print('return {'+','.join(linhas)+'}')
print('centro',[round(v,3) for v in centro],'desvio pivo-centro',[round(PIV[k]-centro[k],3) for k in range(3)],file=sys.stderr)
