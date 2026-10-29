# AgroGest A14 — modelos low-poly (.glb) para js/cena3d.js. Blender 4.2+, separador Scripting:
#   exec(open('blender/modelos.py').read()); construir_todos('AgroGest/src/main/webapp/modelos')  # exporta os 12
#   construir('trator')  # só mostra um, para afinar
import bpy, math
from math import radians as rad

PALETA = {
    'oliva': (0.235, 0.29, 0.165), 'oliva_claro': (0.42, 0.5, 0.26), 'folha': (0.36, 0.55, 0.2),
    'terracota': (0.78, 0.41, 0.17), 'terra': (0.36, 0.24, 0.14), 'terra_escura': (0.22, 0.14, 0.08),
    'milho': (0.85, 0.64, 0.25), 'milho_claro': (0.97, 0.86, 0.5), 'creme': (0.96, 0.94, 0.9),
    'serapilheira': (0.74, 0.62, 0.43), 'madeira': (0.55, 0.36, 0.2), 'madeira_clara': (0.72, 0.53, 0.32),
    'pneu': (0.08, 0.08, 0.07), 'metal': (0.62, 0.64, 0.66), 'vidro': (0.15, 0.22, 0.25),
    'vermelho': (0.66, 0.18, 0.1), 'branco': (0.93, 0.92, 0.88), 'ouro': (0.86, 0.66, 0.24),
}

def mat(nome, rough=0.7, metal=0.0):
    m = bpy.data.materials.get('agro_' + nome)
    if m: return m
    m = bpy.data.materials.new('agro_' + nome)
    m.use_nodes = True
    b = next(n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    b.inputs['Base Color'].default_value = (*PALETA[nome], 1)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Metallic'].default_value = metal
    return m

PARTES = []

def _fim(o, cor, bevel=0.0, rough=0.7, metal=0.0, suave=False):
    o.data.materials.append(mat(cor, rough, metal))
    if bevel:
        mod = o.modifiers.new('bevel', 'BEVEL'); mod.width = bevel; mod.segments = 2
    for p in o.data.polygons: p.use_smooth = suave
    PARTES.append(o)
    return o

def cubo(loc, dim, cor, rot=(0, 0, 0), bevel=0.0, **k):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc, rotation=[rad(a) for a in rot])
    o = bpy.context.object; o.scale = dim
    bpy.ops.object.transform_apply(scale=True)
    return _fim(o, cor, bevel, **k)

def cil(loc, r, h, cor, rot=(0, 0, 0), v=14, r2=None, bevel=0.0, **k):
    if r2 is None:
        bpy.ops.mesh.primitive_cylinder_add(vertices=v, radius=r, depth=h, location=loc, rotation=[rad(a) for a in rot])
    else:
        bpy.ops.mesh.primitive_cone_add(vertices=v, radius1=r, radius2=r2, depth=h, location=loc, rotation=[rad(a) for a in rot])
    return _fim(bpy.context.object, cor, bevel, **k)

def esfera(loc, r, cor, esc=(1, 1, 1), rot=(0, 0, 0), sub=1, **k):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=sub, radius=r, location=loc, rotation=[rad(a) for a in rot])
    o = bpy.context.object; o.scale = esc
    bpy.ops.object.transform_apply(scale=True)
    return _fim(o, cor, **k)

def roda(x, y, z, r, larg, aro='milho'):
    cil((x, y, z), r, larg, 'pneu', rot=(90, 0, 0), v=16, bevel=0.02)
    cil((x, y + (larg / 2 + 0.005) * (1 if y > 0 else -1), z), r * 0.55, 0.02, aro, rot=(90, 0, 0), v=12)

# ---------------------------------------------------------------- modelos

def trator():
    cubo((0.25, 0, 0.55), (0.75, 0.42, 0.32), 'vermelho', bevel=0.04)
    cubo((0.55, 0, 0.42), (0.18, 0.34, 0.16), 'pneu')                      # grelha
    cubo((-0.22, 0, 1.0), (0.5, 0.5, 0.55), 'vermelho', bevel=0.03)        # cabine
    cubo((-0.22, 0, 1.03), (0.52, 0.44, 0.38), 'vidro', rough=0.15)
    cubo((-0.22, 0, 1.31), (0.62, 0.6, 0.06), 'creme', bevel=0.02)         # tejadilho
    cil((0.38, 0.12, 0.92), 0.035, 0.42, 'pneu', v=8)                      # escape
    roda(-0.3, 0.36, 0.42, 0.42, 0.22); roda(-0.3, -0.36, 0.42, 0.42, 0.22)
    roda(0.5, 0.3, 0.24, 0.24, 0.14); roda(0.5, -0.3, 0.24, 0.24, 0.14)

def camiao():
    cubo((0.72, 0, 0.62), (0.5, 0.62, 0.62), 'oliva', bevel=0.05)          # cabine
    cubo((0.9, 0, 0.75), (0.16, 0.56, 0.26), 'vidro', rough=0.15)
    cubo((-0.32, 0, 0.72), (1.45, 0.7, 0.75), 'creme', bevel=0.03)         # caixa
    cubo((-0.32, 0, 0.4), (1.55, 0.6, 0.1), 'pneu')                        # chassis
    cubo((-0.32, 0.355, 0.72), (1.2, 0.01, 0.12), 'terracota')             # faixa
    cubo((-0.32, -0.355, 0.72), (1.2, 0.01, 0.12), 'terracota')
    for x in (0.7, -0.45, -0.8):
        roda(x, 0.3, 0.2, 0.2, 0.14); roda(x, -0.3, 0.2, 0.2, 0.14)

def enxada():
    cil((-0.1, 0, 0.725), 0.04, 1.53, 'madeira_clara', rot=(0, -51.6, 0), v=10)
    cil((0.5, 0, 0.25), 0.065, 0.12, 'metal', rot=(0, -51.6, 0), v=10, rough=0.35, metal=0.8)   # olhal
    cubo((0.62, 0, 0.12), (0.34, 0.42, 0.04), 'metal', rot=(0, 25, 0), bevel=0.01, rough=0.35, metal=0.8)  # lâmina

def saco(cor_saco='branco', faixa='oliva', rot_z=0):
    o = cubo((0, 0, 0.5), (0.7, 0.35, 0.95), cor_saco, bevel=0.14, rot=(0, 0, rot_z), rough=0.9)
    o.modifiers['bevel'].segments = 4
    cubo((0, 0, 0.62), (0.72, 0.37, 0.18), faixa, bevel=0.06, rot=(0, 0, rot_z), rough=0.9)
    cil((0, -0.19, 0.38), 0.13, 0.02, 'milho', rot=(90, 0, rot_z), v=6)   # selo
    for i, x in enumerate((-0.22, 0.22)):                                 # cantos cosidos
        esfera((x, 0, 0.99), 0.07, cor_saco, esc=(1.4, 0.8, 0.6))

def fertilizante():
    saco()
    cubo((0.62, 0.12, 0.2), (0.42, 0.25, 0.4), 'branco', bevel=0.1, rot=(0, 0, -20), rough=0.9)  # saco pequeno
    cubo((0.62, 0.12, 0.25), (0.43, 0.26, 0.08), 'terracota', bevel=0.03, rot=(0, 0, -20))

def semente():
    cil((0, 0, 0.32), 0.36, 0.64, 'serapilheira', v=12, r2=0.3, rough=0.95, bevel=0.03)
    cil((0, 0, 0.66), 0.31, 0.08, 'serapilheira', v=12, rough=0.95, bevel=0.03)   # bainha
    import random; random.seed(7)
    for i in range(34):                                                           # grãos de milho
        a = random.uniform(0, 2 * math.pi); d = random.uniform(0, 0.26)
        z = 0.68 + (0.26 - d) * 0.5 + random.uniform(0, 0.03)
        esfera((math.cos(a) * d, math.sin(a) * d, z), 0.045, 'milho', esc=(1, 0.8, 1.2), rot=(random.uniform(0, 90), 0, math.degrees(a)), sub=1)
    for x, y in ((0.5, -0.1), (0.45, 0.15), (0.6, 0.05)):
        esfera((x, y, 0.035), 0.045, 'milho', esc=(1, 0.8, 1.2))

def planta():
    esfera((0, 0, 0), 0.6, 'terra', esc=(1, 1, 0.35), sub=2, rough=1)
    cil((0, 0, 0.42), 0.03, 0.66, 'folha', v=8)
    for ang, z, esc in ((30, 0.55, 1.0), (210, 0.42, 0.85), (120, 0.68, 0.7)):
        a = rad(ang); r = 0.2 * esc
        esfera((math.cos(a) * r, math.sin(a) * r, z + 0.04), 0.22 * esc, 'folha', esc=(1, 0.42, 0.08), rot=(0, -25, ang), sub=2)
    esfera((0, 0, 0.78), 0.07, 'oliva_claro', esc=(0.7, 0.7, 1.4))
    for x, y in ((0.35, 0.3), (-0.38, 0.15), (0.1, -0.42)):
        esfera((x, y, 0.1), 0.05, 'terra_escura', sub=1)

def milho():
    esfera((0, 0, 0.7), 0.2, 'milho', esc=(1, 1, 3), sub=2, rough=0.5)     # maçaroca
    for ang in (0, 120, 240):                                             # folhas
        a = rad(ang)
        esfera((math.cos(a) * 0.14, math.sin(a) * 0.14, 0.45), 0.18, 'folha', esc=(0.6, 0.25, 2.2), rot=(math.cos(a) * 18, -math.sin(a) * -18, ang), sub=2)
    cil((0, 0, 0.08), 0.06, 0.18, 'oliva_claro', v=8)
    for i, ang in enumerate((40, 160, 280)):                              # grãos soltos
        a = rad(ang)
        esfera((math.cos(a) * 0.45, math.sin(a) * 0.45, 0.03), 0.05, 'milho_claro', esc=(1, 0.8, 1.2))

def celeiro():
    cubo((0, 0, 0.45), (1.1, 0.8, 0.9), 'vermelho', bevel=0.02)
    cubo((0, 0, 0.9), (0.78, 0.8, 0.78), 'vermelho', rot=(0, 45, 0))                 # empena
    for s in (1, -1):
        cubo((s * 0.3, 0, 1.17), (0.92, 0.95, 0.06), 'terra_escura', rot=(0, s * 45, 0), bevel=0.01)  # telhado
    cubo((0, -0.41, 0.33), (0.42, 0.02, 0.62), 'branco')                           # porta
    cubo((0, -0.42, 0.33), (0.36, 0.02, 0.56), 'vermelho')
    for s in (1, -1):
        cubo((0, -0.43, 0.33), (0.5, 0.02, 0.05), 'branco', rot=(0, s * 57, 0))     # X da porta
    cubo((0, -0.41, 0.9), (0.2, 0.02, 0.18), 'branco')                             # janela
    cil((0.85, 0.1, 0.55), 0.24, 1.1, 'metal', v=14, rough=0.4, metal=0.6)         # silo pequeno
    esfera((0.85, 0.1, 1.1), 0.24, 'metal', esc=(1, 1, 0.6), sub=2, rough=0.4, metal=0.6)

def silo():
    cil((0, 0, 0.7), 0.42, 1.4, 'metal', v=20, rough=0.35, metal=0.7)
    esfera((0, 0, 1.4), 0.42, 'metal', esc=(1, 1, 0.55), sub=2, rough=0.35, metal=0.7)
    for z in (0.3, 0.65, 1.0, 1.32):
        cil((0, 0, z), 0.435, 0.04, 'oliva', v=20)
    cubo((0.44, 0, 0.75), (0.04, 0.12, 1.4), 'terracota')                          # escada
    cil((0, 0, 1.66), 0.08, 0.1, 'oliva', v=10)
    cubo((-0.6, 0, 0.18), (0.3, 0.3, 0.36), 'madeira', bevel=0.02)                 # caixote ao lado

def caixa():
    for z, rz, dx in ((0.25, 0, 0), (0.75, 12, 0.05)):
        cubo((dx, 0, z), (0.7, 0.7, 0.48), 'madeira_clara', rot=(0, 0, rz), bevel=0.02)
        for s in (1, -1):
            cubo((dx, 0, z + s * 0.17), (0.72, 0.72, 0.07), 'madeira', rot=(0, 0, rz), bevel=0.01)
    cubo((0.75, 0.0, 0.2), (0.4, 0.4, 0.4), 'madeira_clara', rot=(0, 0, -15), bevel=0.02)
    cubo((0.75, 0.0, 0.2), (0.42, 0.42, 0.05), 'madeira', rot=(0, 0, -15))

def moedas():
    for i in range(7):
        cil((0.02 * math.sin(i), 0.02 * math.cos(i), 0.05 + i * 0.1), 0.34, 0.09, 'ouro', v=20, rough=0.3, metal=0.9)
    for i in range(4):
        cil((0.6, 0.2, 0.05 + i * 0.1), 0.34, 0.09, 'ouro', v=20, rough=0.3, metal=0.9)
    cil((-0.55, -0.25, 0.28), 0.34, 0.09, 'ouro', rot=(70, 0, 30), v=20, rough=0.3, metal=0.9)

def carrinho():
    cil((0, 0, 0.62), 0.42, 0.42, 'oliva', rot=(0, 0, 45), v=4, r2=0.62, bevel=0.03)   # caixa (tronco de pirâmide)
    cubo((0, 0, 0.8), (0.8, 0.8, 0.02), 'terra')                                     # terra lá dentro
    for y in (0.22, -0.22):
        cil((-0.2, y, 0.42), 0.035, 1.45, 'madeira_clara', rot=(0, -76, 0), v=8)     # braços
        cubo((-0.3, y, 0.15), (0.05, 0.05, 0.3), 'metal', metal=0.7, rough=0.4)      # pés
    roda(0.5, 0.0, 0.22, 0.22, 0.1)
    cubo((0.5, 0, 0.22), (0.06, 0.5, 0.06), 'metal', metal=0.7, rough=0.4)            # eixo

MODELOS = {
    'trator': trator, 'camiao': camiao, 'enxada': enxada, 'fertilizante': fertilizante, 'semente': semente,
    'planta': planta, 'milho': milho, 'celeiro': celeiro, 'silo': silo, 'caixa': caixa, 'moedas': moedas,
    'carrinho': carrinho,
}

def limpar():
    for o in list(bpy.data.objects):
        if o.name.startswith('agro_'): bpy.data.objects.remove(o, do_unlink=True)

def construir(nome, x=0.0):
    PARTES.clear()
    MODELOS[nome]()
    for i, o in enumerate(PARTES):
        o.name = 'agro_%s_%02d' % (nome, i)
        o.location.x += x
    return list(PARTES)

def exportar(nome, pasta):
    limpar()
    partes = construir(nome)
    bpy.ops.object.select_all(action='DESELECT')
    for o in partes: o.select_set(True)
    bpy.context.view_layer.objects.active = partes[0]
    bpy.ops.object.convert(target='MESH')                  # aplica os bevel de cada parte antes de juntar
    bpy.ops.object.join()                                  # um só mesh: menos draw calls no browser
    bpy.ops.export_scene.gltf(filepath='%s/%s.glb' % (pasta, nome), export_format='GLB', use_selection=True,
                              export_apply=True, export_yup=True, export_materials='EXPORT', export_texcoords=False)
    limpar()

def construir_todos(pasta):
    for n in MODELOS: exportar(n, pasta)
