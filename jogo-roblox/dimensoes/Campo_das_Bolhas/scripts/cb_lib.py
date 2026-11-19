# Campo das Bolhas — biblioteca comum dos scripts de modelagem (Blender 5.x, bpy em modo sem janela)
# 1 unidade = 1 stud. Z para cima. Toda estrutura: pivô no centro da base, no chão; frente para -Y.
import bpy, bmesh, math, os, sys, json, shutil, time, random
from mathutils import Vector, Matrix, Euler, noise

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # .../Campo_das_Bolhas
TAU = math.tau

# ------------------------------------------------------------------ cena
def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene
    sc.unit_settings.system = 'NONE'  # unidades "soltas": 1 unidade = 1 stud
    for c in list(bpy.data.collections):
        bpy.data.collections.remove(c)
    return sc

def colecao(nome, pai=None):
    c = bpy.data.collections.get(nome) or bpy.data.collections.new(nome)
    p = pai or bpy.context.scene.collection
    if c.name not in [x.name for x in p.children]:
        p.children.link(c)
    return c

# ------------------------------------------------------------------ materiais
# Paleta oficial (DIRECAO-ARTISTICA.md): turquesa #3FE0C8, rosa #FF8FCB, lilás #B9A2FF, verde #7EDC6A, azul-claro #9FD8FF + dourado
def hexrgb(h, a=1.0):
    h = h.lstrip('#'); c = [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]
    return tuple(((x / 12.92) if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4) for x in c) + (a,)

MATS = {
    # nome: base, rugosidade, metálico, extras
    'Blockout':        dict(cor='#c9c4cf', rug=0.9),
    'PedraPerolada':   dict(cor='#efe6f2', rug=0.55, coat=0.35, film=380, ruido=0.12, bump=0.25),
    'PedraLilas':      dict(cor='#a08fc6', rug=0.8, ruido=0.18, bump=0.5),
    'RochaBase':       dict(cor='#8c82a6', rug=0.85, ruido=0.25, bump=0.7),
    'Reboco':          dict(cor='#fbf1e6', rug=0.85, ruido=0.08, bump=0.2),
    'Madeira':         dict(cor='#a0714f', rug=0.7, ruido=0.2, bump=0.35, veio=True),
    'MadeiraClara':    dict(cor='#d9b38c', rug=0.65, ruido=0.15, bump=0.3, veio=True),
    'Dourado':         dict(cor='#e8b54a', rug=0.28, met=1.0),
    'DouradoEscovado': dict(cor='#c99a3c', rug=0.45, met=1.0),
    'Perola':          dict(cor='#f6eef6', rug=0.25, coat=1.0, sheen=0.5, film=450),
    'Vidro':           dict(cor='#bff3ee', rug=0.03, trans=1.0, ior=1.45),
    'VidroLilas':      dict(cor='#e3d8ff', rug=0.05, trans=0.9, ior=1.4),
    'Bolha':           dict(cor='#ffffff', rug=0.0, trans=1.0, ior=1.03, film=420, film_ior=1.33, alpha=1.0),
    'Cristal':         dict(cor='#3fe0c8', rug=0.06, trans=0.85, ior=1.5, emis='#3fe0c8', emis_f=1.2),
    'CristalRosa':     dict(cor='#ff8fcb', rug=0.08, trans=0.8, ior=1.5, emis='#ff8fcb', emis_f=1.0),
    'EnergiaTurquesa': dict(cor='#3fe0c8', rug=0.4, emis='#5ff2dc', emis_f=6.0),
    'EnergiaRosa':     dict(cor='#ff8fcb', rug=0.4, emis='#ffa3d6', emis_f=5.0),
    'Agua':            dict(cor='#5fe3d6', rug=0.02, trans=0.75, ior=1.33, emis='#3fe0c8', emis_f=0.35),
    'TelhadoRosa':     dict(cor='#ff8fcb', rug=0.55, coat=0.3, ruido=0.08, bump=0.3, telha=True),
    'TelhadoLilas':    dict(cor='#b9a2ff', rug=0.55, coat=0.3, ruido=0.08, bump=0.3, telha=True),
    'TelhadoTurquesa': dict(cor='#3fe0c8', rug=0.55, coat=0.3, ruido=0.08, bump=0.3, telha=True),
    'Petala':          dict(cor='#ffa6d5', rug=0.5, sss=0.35, sheen=0.4),
    'PetalaLilas':     dict(cor='#c7b4ff', rug=0.5, sss=0.35, sheen=0.4),
    'Folha':           dict(cor='#7edc6a', rug=0.5, sss=0.25),
    'FolhaEscura':     dict(cor='#3f9a5a', rug=0.55, sss=0.2),
    'Caule':           dict(cor='#6fae6a', rug=0.6, ruido=0.15, bump=0.3),
    'Cogumelo':        dict(cor='#b9a2ff', rug=0.45, sss=0.3, ruido=0.12),
    'CogumeloRosa':    dict(cor='#ff9ccf', rug=0.45, sss=0.3, ruido=0.12),
    'TroncoCogumelo':  dict(cor='#f4ecdc', rug=0.7, ruido=0.1),
    'Tecido':          dict(cor='#9fd8ff', rug=0.9, sheen=0.6),
    'TecidoRosa':      dict(cor='#ff8fcb', rug=0.9, sheen=0.6),
    'Corda':           dict(cor='#c8a77a', rug=0.95),
    'Terreno':         dict(cor='#ffffff', rug=0.9, vcor=True, ruido=0.0, bump=0.35),
    'Inscricao':       dict(cor='#9ffff0', rug=0.3, emis='#7ff7e8', emis_f=3.0),
}

def get_mat(nome):
    m = bpy.data.materials.get(nome)
    if m: return m
    s = MATS[nome]
    m = bpy.data.materials.new(nome)
    try: m.use_nodes = True
    except Exception: pass
    nt = m.node_tree; b = nt.nodes['Principled BSDF']; I = b.inputs
    I['Base Color'].default_value = hexrgb(s['cor'])
    I['Roughness'].default_value = s.get('rug', 0.6)
    I['Metallic'].default_value = s.get('met', 0.0)
    if 'trans' in s:
        I['Transmission Weight'].default_value = s['trans']; I['IOR'].default_value = s.get('ior', 1.45)
    if 'coat' in s: I['Coat Weight'].default_value = s['coat']; I['Coat Roughness'].default_value = 0.15
    if 'sheen' in s: I['Sheen Weight'].default_value = s['sheen']
    if 'sss' in s:
        I['Subsurface Weight'].default_value = s['sss']; I['Subsurface Radius'].default_value = (1.0, 0.6, 0.6)
        I['Subsurface Scale'].default_value = 0.08
    if 'film' in s:
        I['Thin Film Thickness'].default_value = s['film']; I['Thin Film IOR'].default_value = s.get('film_ior', 1.45)
    if 'emis' in s:
        I['Emission Color'].default_value = hexrgb(s['emis']); I['Emission Strength'].default_value = s['emis_f']
    out = nt.nodes['Material Output']; x0 = b.location.x
    if s.get('vcor'):  # cor por vértice (terreno): exporta para o glTF como COLOR_0
        va = nt.nodes.new('ShaderNodeVertexColor'); va.layer_name = 'Cor'; va.location = (x0 - 400, 300)
        nt.links.new(va.outputs['Color'], I['Base Color'])
    # variação e relevo procedurais: só no render (o glTF leva cor, rugosidade, metal, transmissão e emissão)
    if s.get('ruido', 0) > 0 and not s.get('vcor'):
        tc = nt.nodes.new('ShaderNodeTexCoord'); tc.location = (x0 - 900, 0)
        nz = nt.nodes.new('ShaderNodeTexNoise'); nz.location = (x0 - 700, 200); nz.inputs['Scale'].default_value = 0.35
        nz.inputs['Detail'].default_value = 6
        nt.links.new(tc.outputs['Object'], nz.inputs['Vector'])
        mix = nt.nodes.new('ShaderNodeMix'); mix.data_type = 'RGBA'; mix.blend_type = 'MULTIPLY'; mix.location = (x0 - 400, 250)
        mix.inputs['Factor'].default_value = s['ruido']
        mix.inputs[6].default_value = hexrgb(s['cor'])
        nt.links.new(nz.outputs['Color'], mix.inputs[7])
        nt.links.new(mix.outputs[2], I['Base Color'])
    if s.get('bump', 0) > 0:
        tc = nt.nodes.get('Texture Coordinate') or nt.nodes.new('ShaderNodeTexCoord')
        tex = nt.nodes.new('ShaderNodeTexNoise' if not s.get('telha') else 'ShaderNodeTexWave'); tex.location = (x0 - 700, -250)
        if s.get('telha'):
            tex.wave_type = 'RINGS'; tex.inputs['Scale'].default_value = 0.9
        else:
            tex.inputs['Scale'].default_value = 1.6 if not s.get('veio') else 0.6; tex.inputs['Detail'].default_value = 8
        nt.links.new(tc.outputs['Object'], tex.inputs['Vector'])
        bp = nt.nodes.new('ShaderNodeBump'); bp.location = (x0 - 300, -250); bp.inputs['Strength'].default_value = s['bump'] * 0.4
        bp.inputs['Distance'].default_value = 0.1
        nt.links.new(tex.outputs['Fac'], bp.inputs['Height']); nt.links.new(bp.outputs['Normal'], I['Normal'])
    return m

# ------------------------------------------------------------------ malhas
_PECAS = []  # peças criadas no modelo atual (para consolidar por grupo e material)

def _obj(nome, bm, mat, grupo, suave=False, angulo=35):
    me = bpy.data.meshes.new(nome); bm.to_mesh(me); bm.free()
    for p in me.polygons: p.use_smooth = suave
    if suave:
        try: me.set_sharp_from_angle(angle=math.radians(angulo))
        except Exception: pass
    o = bpy.data.objects.new(nome, me)
    bpy.context.scene.collection.objects.link(o)
    o.data.materials.append(get_mat(mat))
    o['cb_grupo'] = grupo; o['cb_mat'] = mat
    _PECAS.append(o)
    return o

def _xf(bm, loc=(0, 0, 0), rot=(0, 0, 0), esc=(1, 1, 1)):
    M = Matrix.Translation(Vector(loc)) @ Euler(rot).to_matrix().to_4x4() @ Matrix.Diagonal((*esc, 1))
    bmesh.ops.transform(bm, matrix=M, verts=bm.verts)

def caixa(nome, tam, loc=(0, 0, 0), rot=(0, 0, 0), mat='Blockout', grupo='Estrutura', chanfro=0.12, seg=2):
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=Vector(tam), verts=bm.verts)
    if chanfro > 0:
        c = min(chanfro, min(tam) * 0.45)
        bmesh.ops.bevel(bm, geom=list(bm.edges), offset=c, segments=seg, affect='EDGES', profile=0.6)
    _xf(bm, loc, rot)
    return _obj(nome, bm, mat, grupo, suave=chanfro > 0)

def cilindro(nome, r1, r2, h, loc=(0, 0, 0), rot=(0, 0, 0), mat='Blockout', grupo='Estrutura', seg=24, chanfro=0.1, tampas=True):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=tampas, cap_tris=False, segments=seg, radius1=r1, radius2=r2, depth=h)
    if chanfro > 0 and tampas:
        es = [e for e in bm.edges if abs(e.verts[0].co.z - e.verts[1].co.z) < 1e-5 and abs(abs(e.verts[0].co.z) - h / 2) < 1e-5]
        bmesh.ops.bevel(bm, geom=es, offset=min(chanfro, h * 0.3, min(r1, r2) * 0.4 + 1e-3), segments=2, affect='EDGES')
    bmesh.ops.translate(bm, vec=Vector((0, 0, h / 2)), verts=bm.verts)  # base em z=0
    _xf(bm, loc, rot)
    return _obj(nome, bm, mat, grupo, suave=True)

def esfera(nome, r, loc=(0, 0, 0), esc=(1, 1, 1), rot=(0, 0, 0), mat='Blockout', grupo='Estrutura', seg=32, aneis=16):
    bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=aneis, radius=r)
    _xf(bm, loc, rot, esc)
    return _obj(nome, bm, mat, grupo, suave=True, angulo=80)

def toro(nome, R, r, loc=(0, 0, 0), rot=(0, 0, 0), mat='Blockout', grupo='Estrutura', segM=48, segm=12, arco=TAU, esc=(1, 1, 1)):
    bm = bmesh.new(); fechado = arco >= TAU - 1e-6
    nM = segM if fechado else segM + 1
    rings = []
    for i in range(nM):
        a = arco * i / segM
        c, s = math.cos(a), math.sin(a)
        ring = []
        for j in range(segm):
            b = TAU * j / segm
            rr = R + r * math.cos(b)
            ring.append(bm.verts.new((rr * c, rr * s, r * math.sin(b))))
        rings.append(ring)
    for i in range(segM if fechado else segM):
        A = rings[i]; Bn = rings[(i + 1) % nM]
        for j in range(segm):
            bm.faces.new((A[j], A[(j + 1) % segm], Bn[(j + 1) % segm], Bn[j]))
    if not fechado:
        bm.faces.new(list(reversed(rings[0]))); bm.faces.new(rings[-1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    _xf(bm, loc, rot, esc)
    return _obj(nome, bm, mat, grupo, suave=True, angulo=60)

def torno(nome, perfil, loc=(0, 0, 0), rot=(0, 0, 0), mat='Blockout', grupo='Estrutura', seg=32, arco=TAU, esc=(1, 1, 1), suave=True):
    """Superfície de revolução em volta de Z. perfil = [(raio, z), ...] de baixo para cima. Raio 0 fecha o polo."""
    bm = bmesh.new(); fechado = arco >= TAU - 1e-6; n = seg if fechado else seg + 1
    rings = []
    for (r, z) in perfil:
        if r <= 1e-5:
            rings.append([bm.verts.new((0, 0, z))])
        else:
            rings.append([bm.verts.new((r * math.cos(arco * i / seg), r * math.sin(arco * i / seg), z)) for i in range(n)])
    for k in range(len(rings) - 1):
        A, B = rings[k], rings[k + 1]
        for i in range(seg):
            i2 = (i + 1) % n if fechado else i + 1
            if len(A) == 1 and len(B) > 1: bm.faces.new((A[0], B[i2], B[i]))
            elif len(B) == 1 and len(A) > 1: bm.faces.new((A[i], A[i2], B[0]))
            elif len(A) > 1: bm.faces.new((A[i], A[i2], B[i2], B[i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    _xf(bm, loc, rot, esc)
    return _obj(nome, bm, mat, grupo, suave=suave, angulo=50)

def tubo(nome, pts, raio, mat='Blockout', grupo='Estrutura', seg=8, res=6, afinar=None, tampas=True):
    """Tubo ao longo de uma curva suave (Catmull-Rom via Bézier automático)."""
    cu = bpy.data.curves.new(nome + '_c', 'CURVE'); cu.dimensions = '3D'
    sp = cu.splines.new('BEZIER'); sp.bezier_points.add(len(pts) - 1)
    for bp, p in zip(sp.bezier_points, pts):
        bp.co = Vector(p); bp.handle_left_type = bp.handle_right_type = 'AUTO'
    cu.bevel_depth = raio; cu.bevel_resolution = max(1, seg // 4 - 1); cu.resolution_u = res; cu.use_fill_caps = tampas
    if afinar:
        for i, bp in enumerate(sp.bezier_points): bp.radius = afinar[i]
    tmp = bpy.data.objects.new(nome + '_tmp', cu); bpy.context.scene.collection.objects.link(tmp)
    dg = bpy.context.evaluated_depsgraph_get(); me = bpy.data.meshes.new_from_object(tmp.evaluated_get(dg))
    bpy.data.objects.remove(tmp); bpy.data.curves.remove(cu)
    bm = bmesh.new(); bm.from_mesh(me); bpy.data.meshes.remove(me)
    return _obj(nome, bm, mat, grupo, suave=True, angulo=70)

def petala(nome, comp, larg, loc=(0, 0, 0), rot=(0, 0, 0), mat='Petala', grupo='Petalas', curva=0.35, concha=0.25, esp=0.12, nu=10, nv=6, ponta=0.85):
    """Pétala/folha/telha curva: grade (u ao longo, v na largura) com espessura. Base na origem, cresce em +Y."""
    bm = bmesh.new(); G = []
    for i in range(nu + 1):
        u = i / nu; w = larg * 0.5 * math.sin(math.pi * min(1.0, u ** 0.85 * ponta + u * (1 - ponta))) + 1e-3
        row = []
        for j in range(nv + 1):
            v = -1 + 2 * j / nv
            x = v * w; y = u * comp; z = curva * comp * u * u + concha * w * v * v
            row.append(bm.verts.new((x, y, z)))
        G.append(row)
    for i in range(nu):
        for j in range(nv):
            bm.faces.new((G[i][j], G[i][j + 1], G[i + 1][j + 1], G[i + 1][j]))
    if esp > 0:
        r = bmesh.ops.solidify(bm, geom=list(bm.faces), thickness=esp)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    _xf(bm, loc, rot)
    return _obj(nome, bm, mat, grupo, suave=True, angulo=70)

def rocha(nome, r, loc=(0, 0, 0), esc=(1, 1, 1), rot=(0, 0, 0), mat='RochaBase', grupo='Rochas', semente=1, sub=2, aspereza=0.35):
    bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=sub, radius=r)
    off = Vector((semente * 7.31, semente * 3.17, semente * 1.93))
    for v in bm.verts:
        n = v.co.normalized()
        d = noise.fractal(v.co / r * 1.3 + off, 0.6, 2.0, 4) * aspereza + noise.noise(v.co / r * 4 + off) * aspereza * 0.25
        v.co = v.co + n * d * r
    # facetas achatadas: rochas lapidadas pela erosão, não bolas
    _xf(bm, loc, rot, esc)
    return _obj(nome, bm, mat, grupo, suave=True, angulo=28)

def grade(nome, f, nx, ny, x0, x1, y0, y1, mat='Blockout', grupo='Estrutura'):
    bm = bmesh.new(); V = []
    for j in range(ny + 1):
        for i in range(nx + 1):
            x = x0 + (x1 - x0) * i / nx; y = y0 + (y1 - y0) * j / ny
            V.append(bm.verts.new((x, y, f(x, y))))
    for j in range(ny):
        for i in range(nx):
            a = j * (nx + 1) + i
            bm.faces.new((V[a], V[a + 1], V[a + nx + 2], V[a + nx + 1]))
    return _obj(nome, bm, mat, grupo, suave=True, angulo=60)

def instancia(o, nome, loc, rot=(0, 0, 0), esc=(1, 1, 1)):
    """Cópia que compartilha a malha (o glTF grava a malha uma vez só)."""
    n = bpy.data.objects.new(nome, o.data); bpy.context.scene.collection.objects.link(n)
    n.location = loc; n.rotation_euler = rot; n.scale = esc
    for k in ('cb_grupo', 'cb_mat'):
        if k in o: n[k] = o[k]
    _PECAS.append(n); return n

def raiz(nome):
    e = bpy.data.objects.new(nome, None); e.empty_display_type = 'PLAIN_AXES'; e.empty_display_size = 2
    bpy.context.scene.collection.objects.link(e); return e

def consolidar(prefixo, pai, separados=()):
    """Junta as peças do modelo atual por (grupo, material). Grupos em 'separados' viram objetos próprios
    (partes animáveis no Roblox). Mantém nomes padronizados: <prefixo>_<Grupo>_<Material>."""
    global _PECAS
    dg = bpy.context.evaluated_depsgraph_get()
    grupos = {}
    for o in _PECAS:
        if o.name not in bpy.data.objects: continue
        grupos.setdefault((o['cb_grupo'], o['cb_mat']), []).append(o)
    novos = []
    for (g, mt), objs in sorted(grupos.items()):
        bm = bmesh.new()
        for o in objs:
            me = o.data.copy(); me.transform(o.matrix_world)
            tmp = bmesh.new(); tmp.from_mesh(me)
            for f in tmp.faces: f.material_index = 0
            tm = bpy.data.meshes.new('t'); tmp.to_mesh(tm); tmp.free(); bm.from_mesh(tm); bpy.data.meshes.remove(tm); bpy.data.meshes.remove(me)
        nome = f'{prefixo}_{g}_{mt}'
        me = bpy.data.meshes.new(nome); bm.to_mesh(me); bm.free()
        ob = bpy.data.objects.new(nome, me); bpy.context.scene.collection.objects.link(ob)
        ob.data.materials.append(get_mat(mt)); ob.parent = pai; ob['cb_grupo'] = g
        novos.append(ob)
        for o in objs:
            d = o.data; bpy.data.objects.remove(o)
            if d.users == 0: bpy.data.meshes.remove(d)
    _PECAS = []
    return novos

def limpar_pecas():
    global _PECAS; _PECAS = []

def colisor(pai, nome, tam, loc, rz=0.0):
    """Caixa de colisão simples (no Roblox: peça invisível CanCollide). Coleção 'Colisores', fora do render."""
    c = colecao('Colisores')
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0); bmesh.ops.scale(bm, vec=Vector(tam), verts=bm.verts)
    me = bpy.data.meshes.new('COL_' + nome); bm.to_mesh(me); bm.free()
    o = bpy.data.objects.new('COL_' + nome, me); c.objects.link(o)
    o.location = loc; o.rotation_euler = (0, 0, rz); o.display_type = 'WIRE'; o.hide_render = True; o.parent = pai
    return o

# ------------------------------------------------------------------ luz, câmera e render
def mundo(sol_elev=16, sol_rot=230, forca=0.55, cor_neblina=None):
    sc = bpy.context.scene; w = bpy.data.worlds.new('CB_Ceu'); sc.world = w
    try: w.use_nodes = True
    except Exception: pass
    nt = w.node_tree; bg = nt.nodes['Background']
    sky = nt.nodes.new('ShaderNodeTexSky'); sky.sky_type = 'MULTIPLE_SCATTERING'
    sky.sun_elevation = math.radians(sol_elev); sky.sun_rotation = math.radians(sol_rot)
    try: sky.air_density = 1.2; sky.aerosol_density = 2.2
    except Exception: pass
    try: sky.dust_density = 2.5
    except Exception: pass
    # tom pastel: o céu físico (horizonte quente, zênite azul) levemente tingido de rosa-lilás
    mix = nt.nodes.new('ShaderNodeMix'); mix.data_type = 'RGBA'; mix.blend_type = 'MULTIPLY'; mix.inputs['Factor'].default_value = 0.35
    mix.inputs[7].default_value = hexrgb('#ffd2ec')
    nt.links.new(sky.outputs['Color'], mix.inputs[6])
    # abaixo do horizonte: mar de nuvens pastel (rosa-lilás claro), emendado no horizonte
    tc = nt.nodes.new('ShaderNodeTexCoord'); sep = nt.nodes.new('ShaderNodeSeparateXYZ'); nt.links.new(tc.outputs['Generated'], sep.inputs[0])
    mr = nt.nodes.new('ShaderNodeMapRange'); mr.inputs['From Min'].default_value = -0.12; mr.inputs['From Max'].default_value = 0.04
    nt.links.new(sep.outputs['Z'], mr.inputs['Value'])
    mar = nt.nodes.new('ShaderNodeMix'); mar.data_type = 'RGBA'; mar.blend_type = 'MIX'
    mar.inputs[6].default_value = tuple(c * 3.6 for c in hexrgb('#f7bfe2')[:3]) + (1,)
    nt.links.new(mr.outputs['Result'], mar.inputs['Factor']); nt.links.new(mix.outputs[2], mar.inputs[7])
    nt.links.new(mar.outputs[2], bg.inputs['Color']); bg.inputs['Strength'].default_value = forca * 0.32
    # sol: quente, sombras suaves (disco angular grande)
    L = bpy.data.lights.new('CB_Sol', 'SUN'); L.energy = 2.4; L.color = hexrgb('#ffd9b8')[:3]; L.angle = math.radians(6)
    so = bpy.data.objects.new('CB_Sol', L); sc.collection.objects.link(so)
    so.rotation_euler = Euler((math.radians(90 - sol_elev), 0, math.radians(sol_rot + 90)))
    return so

def neblina(densidade=0.0018, cor='#f6d7ef', tam=1600, z=-200, altura=600):
    """Névoa atmosférica moderada: volume grande e ralo (só nos renders do mapa)."""
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0); bmesh.ops.scale(bm, vec=Vector((tam, tam, altura)), verts=bm.verts)
    me = bpy.data.meshes.new('CB_Neblina'); bm.to_mesh(me); bm.free()
    o = bpy.data.objects.new('CB_Neblina', me); bpy.context.scene.collection.objects.link(o); o.location = (0, 0, z + altura / 2)
    m = bpy.data.materials.new('Neblina'); nt = m.node_tree if m.node_tree else None
    try: m.use_nodes = True
    except Exception: pass
    nt = m.node_tree; nt.nodes.remove(nt.nodes['Principled BSDF'])
    v = nt.nodes.new('ShaderNodeVolumePrincipled'); v.inputs['Density'].default_value = densidade; v.inputs['Color'].default_value = hexrgb(cor)
    nt.links.new(v.outputs[0], nt.nodes['Material Output'].inputs['Volume'])
    me.materials.append(m); return o

def config_render(larg=1280, alt=720, amostras=48, exposicao=0.0):
    sc = bpy.context.scene; sc.render.engine = 'CYCLES'; sc.cycles.device = 'CPU'
    sc.cycles.samples = amostras; sc.cycles.use_denoising = True
    try: sc.cycles.denoiser = 'OPENIMAGEDENOISE'
    except Exception: pass
    sc.cycles.max_bounces = 8; sc.cycles.transmission_bounces = 8; sc.cycles.volume_bounces = 1
    sc.cycles.use_adaptive_sampling = True
    sc.render.resolution_x = larg; sc.render.resolution_y = alt; sc.render.resolution_percentage = 100
    sc.view_settings.view_transform = 'AgX'
    try: sc.view_settings.look = 'AgX - Medium High Contrast'
    except Exception: pass
    sc.view_settings.exposure = exposicao - 0.35
    sc.render.image_settings.file_format = 'PNG'

def camera(nome='CB_Camera', lente=35):
    c = bpy.data.cameras.new(nome); c.lens = lente; c.clip_end = 5000; c.clip_start = 0.3
    o = bpy.data.objects.new(nome, c); bpy.context.scene.collection.objects.link(o); bpy.context.scene.camera = o
    return o

def mirar(cam, pos, alvo):
    cam.location = Vector(pos); d = Vector(alvo) - Vector(pos)
    cam.rotation_euler = d.to_track_quat('-Z', 'Y').to_euler()

def enquadrar(cam, centro, raio, direcao, elev=0.25, folga=1.15):
    """Põe a câmera para caber uma esfera (centro, raio), olhando de 'direcao' (vetor XY)."""
    fov = cam.data.angle * 0.5 * min(1.0, bpy.context.scene.render.resolution_y / bpy.context.scene.render.resolution_x * 1.6)
    d = raio * folga / math.sin(max(0.15, fov))
    dv = Vector((direcao[0], direcao[1], elev)).normalized()
    mirar(cam, Vector(centro) + dv * d, centro)

def renderizar(caminho):
    os.makedirs(os.path.dirname(caminho), exist_ok=True)
    sc = bpy.context.scene; sc.render.filepath = caminho
    t = time.time(); bpy.ops.render.render(write_still=True)
    print(f'RENDER {os.path.relpath(caminho, ROOT)} {time.time() - t:.0f}s', flush=True)

def chao(raio=60, z=0.0, cor='#8fd47c'):
    """Disco de grama só para as prévias individuais (não faz parte do arquivo da estrutura)."""
    bm = bmesh.new(); bmesh.ops.create_circle(bm, cap_ends=True, segments=64, radius=raio)
    me = bpy.data.meshes.new('PREVIA_Chao'); bm.to_mesh(me); bm.free()
    o = bpy.data.objects.new('PREVIA_Chao', me); bpy.context.scene.collection.objects.link(o); o.location = (0, 0, z)
    m = bpy.data.materials.get('PreviaGrama') or bpy.data.materials.new('PreviaGrama')
    try: m.use_nodes = True
    except Exception: pass
    b = m.node_tree.nodes['Principled BSDF']; b.inputs['Base Color'].default_value = hexrgb(cor); b.inputs['Roughness'].default_value = 0.95
    me.materials.append(m); return o

# ------------------------------------------------------------------ arquivos
def backup(caminho):
    """Antes de substituir um arquivo, guarda a versão anterior em _backup/ com data e hora."""
    if os.path.exists(caminho):
        rel = os.path.relpath(caminho, ROOT).replace(os.sep, '__')
        dst = os.path.join(ROOT, '_backup', time.strftime('%Y%m%d-%H%M%S') + '__' + rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True); shutil.copy2(caminho, dst)
        return dst

def salvar_blend(caminho):
    backup(caminho); os.makedirs(os.path.dirname(caminho), exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=caminho, compress=True, copy=True)

def _selecionar(objs):
    for o in bpy.context.scene.objects: o.select_set(False)
    for o in objs: o.select_set(True)
    if objs: bpy.context.view_layer.objects.active = objs[0]

def exportar(objs, base):
    """Exporta GLB e FBX a partir da cena atual sem tocar no .blend de origem (que já foi salvo)."""
    glb = os.path.join(ROOT, 'Exports', 'glTF', base + '.glb'); fbx = os.path.join(ROOT, 'Exports', 'FBX', base + '.fbx')
    for p in (glb, fbx): backup(p); os.makedirs(os.path.dirname(p), exist_ok=True)
    _selecionar(objs)
    bpy.ops.export_scene.gltf(filepath=glb, export_format='GLB', use_selection=True, export_apply=True, export_yup=True,
                              export_extras=True, export_cameras=False, export_lights=False)
    bpy.ops.export_scene.fbx(filepath=fbx, use_selection=True, apply_unit_scale=True, apply_scale_options='FBX_SCALE_ALL',
                             object_types={'EMPTY', 'MESH'}, use_mesh_modifiers=True, add_leaf_bones=False, bake_anim=False)
    return glb, fbx

def hierarquia(o, nivel=0, linhas=None):
    linhas = [] if linhas is None else linhas
    tris = sum(len(p.vertices) - 2 for p in o.data.polygons) if o.type == 'MESH' else 0
    linhas.append('  ' * nivel + f'{o.name} ({o.type}{", " + str(tris) + " tri" if tris else ""})')
    for c in sorted(o.children, key=lambda x: x.name): hierarquia(c, nivel + 1, linhas)
    return linhas

def tris(objs):
    t = 0
    for o in objs:
        if o.type == 'MESH': t += sum(len(p.vertices) - 2 for p in o.data.polygons)
    return t
