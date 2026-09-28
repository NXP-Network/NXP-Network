"""Build compact, deterministic glTF models for Godot 4 without external tools."""
import json
import math
import struct
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent.parent / "models"
ROOT.mkdir(exist_ok=True)


class Model:
    def __init__(self):
        self.parts = {}

    def triangle(self, color, a, b, c):
        key = tuple(color)
        part = self.parts.setdefault(key, ([], []))
        normal = np.cross(np.subtract(b, a), np.subtract(c, a))
        normal = normal / max(float(np.linalg.norm(normal)), 1e-8)
        for point in (a, b, c):
            part[0].extend(point)
            part[1].extend(normal)

    def quad(self, color, a, b, c, d):
        self.triangle(color, a, b, c)
        self.triangle(color, a, c, d)

    def box(self, color, center, size):
        x, y, z = center
        w, h, d = [v / 2 for v in size]
        pts = [(x + sx*w, y + sy*h, z + sz*d)
               for sx, sy, sz in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),
                                  (-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]]
        for ids in [(0,3,2,1),(4,5,6,7),(0,4,7,3),(1,2,6,5),(3,7,6,2),(0,1,5,4)]:
            self.quad(color, *(pts[i] for i in ids))

    def ellipsoid(self, color, center, radii, rings=6, sides=10):
        def p(latitude, longitude):
            a, b = latitude * math.pi / rings, longitude * 2 * math.pi / sides
            return (center[0] + radii[0]*math.sin(a)*math.cos(b),
                    center[1] + radii[1]*math.cos(a),
                    center[2] + radii[2]*math.sin(a)*math.sin(b))
        for j in range(rings):
            for i in range(sides):
                a,b,c,d = p(j,i),p(j+1,i),p(j+1,i+1),p(j,i+1)
                if j:
                    self.triangle(color,a,b,d)
                if j < rings-1:
                    self.triangle(color,d,b,c)

    def rod(self, color, a, b, radius, sides=8):
        start, end = np.array(a, dtype=float), np.array(b, dtype=float)
        axis = (end-start) / np.linalg.norm(end-start)
        u = np.cross(axis, (0,0,1) if abs(axis[2]) < .9 else (0,1,0))
        u /= np.linalg.norm(u)
        v = np.cross(axis,u)
        for i in range(sides):
            t, s = 2*math.pi*i/sides, 2*math.pi*(i+1)/sides
            r1, r2 = radius*(u*math.cos(t)+v*math.sin(t)), radius*(u*math.cos(s)+v*math.sin(s))
            self.quad(color, tuple(start+r1),tuple(start+r2),tuple(end+r2),tuple(end+r1))

    def write(self, path):
        binary = bytearray()
        views, accessors, meshes, nodes, materials = [], [], [], [], []
        for color, (positions, normals) in self.parts.items():
            attrs = {}
            for name, values in (("POSITION", positions), ("NORMAL", normals)):
                while len(binary) % 4:
                    binary.append(0)
                offset = len(binary)
                raw = np.asarray(values, dtype="<f4")
                binary.extend(raw.tobytes())
                views.append({"buffer":0,"byteOffset":offset,"byteLength":raw.nbytes,"target":34962})
                accessor = {"bufferView":len(views)-1,"componentType":5126,"count":len(values)//3,"type":"VEC3"}
                if name == "POSITION":
                    coords = raw.reshape((-1,3))
                    accessor.update(min=coords.min(axis=0).tolist(),max=coords.max(axis=0).tolist())
                accessors.append(accessor)
                attrs[name] = len(accessors)-1
            materials.append({"pbrMetallicRoughness":{"baseColorFactor":[*color,1],"metallicFactor":0.12,"roughnessFactor":0.85},"doubleSided":True})
            meshes.append({"primitives":[{"attributes":attrs,"material":len(materials)-1,"mode":4}]})
            nodes.append({"mesh":len(meshes)-1})
        scene = {"asset":{"version":"2.0","generator":"NXP model builder"},
                 "buffers":[{"byteLength":len(binary)}],"bufferViews":views,"accessors":accessors,
                 "materials":materials,"meshes":meshes,"nodes":nodes,
                 "scenes":[{"nodes":list(range(len(nodes)))}],"scene":0}
        encoded = json.dumps(scene,separators=(",",":")).encode()
        encoded += b" " * (-len(encoded) % 4)
        binary += b"\0" * (-len(binary) % 4)
        payload = b"glTF" + struct.pack("<II",2,12+8+len(encoded)+8+len(binary))
        payload += struct.pack("<I4s",len(encoded),b"JSON") + encoded
        payload += struct.pack("<I4s",len(binary),b"BIN\0") + binary
        (ROOT/path).write_bytes(payload)


def soldier():
    m=Model()
    cloth=(.11,.18,.22); armor=(.20,.27,.32); plates=(.30,.37,.39)
    skin=(.68,.47,.34); dark=(.065,.075,.085); steel=(.28,.32,.34)
    m.ellipsoid(cloth,(0,1.35,0),(.36,.54,.27))
    m.box(armor,(0,1.43,-.18),(.62,.66,.13))
    m.box(dark,(0,1.35,.32),(.46,.56,.22))
    m.box(plates,(0,1.45,.45),(.35,.17,.07))
    m.ellipsoid(skin,(0,2.12,-.04),(.25,.29,.23))
    m.ellipsoid(dark,(0,2.35,0),(.29,.16,.28))
    m.box(plates,(0,2.25,-.25),(.4,.1,.13))
    m.box(steel,(0,2.09,-.255),(.29,.07,.07))
    for side in (-1,1):
        m.ellipsoid(armor,(side*.43,1.72,0),(.21,.17,.27))
        m.rod(cloth,(side*.44,1.65,-.05),(side*.38,1.27,-.55),.13)
        m.ellipsoid(dark,(side*.37,1.23,-.59),(.14,.12,.14))
        m.rod(cloth,(side*.22,.95,0),(side*.26,.22,.03),.17)
        m.box(plates,(side*.25,.67,-.14),(.26,.31,.15))
        m.box(dark,(side*.27,.11,-.16),(.31,.17,.5))
        m.box(steel,(side*.29,1.45,.22),(.08,.5,.07))
    m.box(steel,(0,1.23,-.87),(.36,.25,.88))
    m.box(dark,(0,1.24,-.32),(.39,.29,.42))
    m.rod(steel,(0,1.25,-1.22),(0,1.25,-2.12),.105)
    m.box(dark,(0,1.27,-2.16),(.24,.19,.17))
    m.box(dark,(0,1.53,-1.11),(.18,.13,.42))
    m.box(plates,(0,1.58,-1.31),(.12,.09,.12))
    m.write("character.glb")


def spider(name, shell, scale):
    m=Model(); dark=(.08,.09,.12); joints=(.15,.16,.2); eye=(.7,.12,.16)
    def q(point): return tuple(v*scale for v in point)
    def e(color,center,size): m.ellipsoid(color,q(center),q(size))
    e(shell,(0,.8,.42),(.66,.39,.75))
    e(dark,(0,.67,.45),(.58,.22,.65))
    e(shell,(0,.78,-.48),(.44,.32,.45))
    for stripe in range(3):
        e(tuple(min(1,c+.11) for c in shell),(0,1.14,.05+stripe*.27),(.41-stripe*.06,.045,.085))
    for side in (-1,1):
        for i in range(4):
            z=-.58+i*.4
            a=q((side*.32,.79,z)); b=q((side*(.91+i*.08),1.02,z*1.6)); c=q((side*(1.35+i*.14),.07,z*2.05))
            m.rod(joints,a,b,.085*scale)
            m.rod(dark,b,c,.057*scale)
            e(shell,(side*(.91+i*.08),1.02,z*1.6),(.11,.11,.11))
        e(eye,(side*.19,.87,-.84),(.09,.08,.06))
        m.rod(dark,q((side*.2,.66,-.75)),q((side*.16,.37,-1.05)),.065*scale)
    m.write(name+".glb")


def castle():
    m=Model(); stone=(.42,.43,.46); light=(.53,.54,.55); mortar=(.29,.30,.32)
    iron=(.08,.09,.11); wood=(.19,.13,.09); blue=(.09,.24,.29)
    m.box(stone,(0,2,1.6),(4.4,4,3))
    m.box(stone,(-2.7,1.33,-2.15),(2.7,2.65,.7))
    m.box(stone,(2.7,1.33,-2.15),(2.7,2.65,.7))
    for side in (-1,1):
        m.box(stone,(side*3.75,1.5,.05),(.75,3,4.4))
        for z in (-2.2,3.2):
            # Eight sided tower shaft and upper stone ring.
            for ring in range(8):
                a=2*math.pi*ring/8
                m.box(stone,(side*4+math.cos(a)*.65,2.45,z+math.sin(a)*.65),(.56,4.9,.56))
            m.box(mortar,(side*4,5,z),(2.2,.26,2.2))
            for dx in (-.74,.74):
                for dz in (-.74,.74):
                    m.box(light,(side*4+dx,5.37,z+dz),(.52,.54,.52))
            m.box(iron,(side*4,3.28,z-1.03),(.5,.68,.09))
        m.box(iron,(side*1.27,2.15,-.09),(.7,.85,.1))
    for row in range(6):
        for col in range(10):
            x=-3.75+col*.81+(row%2)*.4
            if abs(x)<1 and row<4:
                continue
            m.box(light if (row+col)%5==0 else stone,(x,.25+row*.45,-2.54),(.76,.41,.05))
    for col in range(7):
        x=-3.3+col*1.1
        if abs(x)>1:
            m.box(light,(x,2.94,-2.15),(.65,.57,.76))
    for col in range(5):
        m.box(light,(-2.1+col*1.05,4.5,-.03),(.65,.55,.75))
    for col in range(6):
        m.box(wood,(-.65+col*.26,1.03,-2.68),(.24,1.9,.11))
    for height in (.55,1.7):
        m.box(iron,(0,height,-2.77),(1.74,.1,.09))
    m.box(light,(-1.05,1.25,-2.66),(.28,2.5,.34))
    m.box(light,(1.05,1.25,-2.66),(.28,2.5,.34))
    m.box(light,(0,2.64,-2.66),(2.34,.27,.34))
    m.box(blue,(0,3.35,-2.59),(1.6,.18,.12))
    m.write("castle.glb")


if __name__ == "__main__":
    soldier()
    spider("spider_normal",(.17,.21,.25),1)
    spider("spider_scout",(.23,.38,.34),.77)
    spider("spider_armored",(.32,.31,.38),1.27)
    spider("spider_queen",(.29,.16,.23),2.1)
    castle()
