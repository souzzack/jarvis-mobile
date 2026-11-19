# Campo das Bolhas — driver das estruturas.
# Uso: python build_asset.py <modulo> [--variante X] [--previas] [--so-previas]
#   <modulo> = arquivo em scripts/assets/ (portal, gerador, casa, mercado, altar, observatorio, ponte, vegetacao, props)
# Para cada estrutura: .blend na pasta dela, GLB + FBX em Exports/, colisores em GLB separado, ficha JSON e prévias.
import sys, os, json, math, importlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'assets'))
import bpy
from mathutils import Vector
import cb_lib as L

def args():
    a = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else sys.argv[1:]
    mod = a[0]; var = None
    if '--variante' in a: var = a[a.index('--variante') + 1]
    return mod, var, '--previas' in a or '--so-previas' in a, '--so-previas' in a

def montar(mod, nivel, var):
    L.reset()
    info = mod.build(nivel, var) if var is not None else mod.build(nivel)
    return info

def ficha(info, meta, arquivos):
    root = info['root']; objs = [o for o in root.children_recursive]
    meshes = [o for o in objs if o.type == 'MESH' and not o.name.startswith('COL_')]
    cols = [o for o in objs if o.name.startswith('COL_')]
    bb_min = Vector((1e9,) * 3); bb_max = Vector((-1e9,) * 3)
    for o in meshes:
        for c in o.bound_box:
            w = o.matrix_world @ Vector(c); bb_min = Vector(map(min, bb_min, w)); bb_max = Vector(map(max, bb_max, w))
    return dict(id=meta['id'], titulo=meta['titulo'], arquivos=arquivos, objetos=len(meshes), colisores=len(cols),
                triangulos=L.tris(meshes), materiais=sorted({s.material.name for o in meshes for s in o.material_slots if s.material}),
                limites_min=[round(v, 2) for v in bb_min], limites_max=[round(v, 2) for v in bb_max],
                tamanho_studs=[round(v, 2) for v in (bb_max - bb_min)], pivo='centro da base, no chão (0,0,0); frente para -Y',
                partes_animaveis=info.get('animaveis', []), flutuantes_intencionais=info.get('flutuantes', []),
                hierarquia=L.hierarquia(root))

def final(mod, meta, var):
    info = montar(mod, 3, var); root = info['root']
    nome = meta['arquivo'] + (f'_{var}' if var and meta.get('variante_no_nome', True) else '')
    blend = os.path.join(L.ROOT, meta['pasta'], nome + '.blend')
    L.salvar_blend(blend)
    vis = [root] + [o for o in root.children_recursive if not o.name.startswith('COL_')]
    glb, fbx = L.exportar(vis, nome)
    cols = [o for o in root.children_recursive if o.name.startswith('COL_')]
    arqs = [os.path.relpath(p, L.ROOT) for p in (blend, glb, fbx)]
    if cols:
        p = os.path.join(L.ROOT, 'Exports', 'glTF', nome + '_Colisores.glb'); L.backup(p)
        for o in cols: o.hide_render = False
        L._selecionar(cols)
        bpy.ops.export_scene.gltf(filepath=p, export_format='GLB', use_selection=True, export_yup=True, export_extras=True)
        arqs.append(os.path.relpath(p, L.ROOT))
    f = ficha(info, meta, arqs)
    json.dump(f, open(os.path.join(L.ROOT, meta['pasta'], nome + '_ficha.json'), 'w'), ensure_ascii=False, indent=1)
    print('FINAL', nome, f['triangulos'], 'tri', f['objetos'], 'objetos', f['tamanho_studs'], flush=True)
    return info, nome

def previas(mod, meta, var, nome):
    pasta = os.path.join(L.ROOT, 'Renders', meta['pasta'])
    for nivel, etapa, amostras in ((1, 'blockout', 10), (2, 'intermediario', 16), (3, 'final', 40)):
        info = montar(mod, nivel, var)
        L.mundo(sol_elev=24, sol_rot=225, forca=1.0)
        L.chao(info.get('chao', 90), cor='#8fd47c')
        if nivel == 1: bpy.context.view_layer.material_override = L.get_mat('Blockout')
        cam = L.camera(lente=40); L.config_render(1280, 720, amostras)
        c = Vector(info['centro']); r = info['raio']; fr = info.get('frente', (0, -1))
        vistas = [('frente', fr, 0.12, c, r), ('tres_quartos', (fr[0] + 0.8 * -fr[1], fr[1] + 0.8 * fr[0]), 0.32, c, r)]
        for k, d in enumerate(info.get('detalhes', [])):
            vistas.append((f'detalhe{k + 1}', d.get('dir', fr), d.get('elev', 0.2), Vector(d['alvo']), d['raio']))
        for vn, d, elev, alvo, raio in vistas:
            L.enquadrar(cam, alvo, raio, d, elev, folga=1.05)
            L.renderizar(os.path.join(pasta, f'{nome}_{etapa}_{vn}.png'))

if __name__ == '__main__':
    modn, var, prev, so_prev = args()
    mod = importlib.import_module(modn); meta = dict(mod.META)
    nome = meta['arquivo'] + (f'_{var}' if var and meta.get('variante_no_nome', True) else '')
    if not so_prev: info, nome = final(mod, meta, var)
    if prev: previas(mod, meta, var, nome)
