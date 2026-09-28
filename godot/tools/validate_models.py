"""Check generated model structure and the project links before packaging."""
import json
import math
import re
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
source = (ROOT / "main.gd").read_text()
models = sorted((ROOT / "models").glob("*.glb"))
assert len(models) == 6, "Expected character, castle and four spider models"

for path in models:
    data = path.read_bytes()
    magic, version, total = struct.unpack_from("<4sII", data)
    assert (magic, version, total) == (b"glTF", 2, len(data)), path
    json_len, chunk_type = struct.unpack_from("<I4s", data, 12)
    assert chunk_type == b"JSON" and json_len % 4 == 0, path
    scene = json.loads(data[20:20 + json_len])
    binary_offset = 20 + json_len
    binary_len, binary_type = struct.unpack_from("<I4s", data, binary_offset)
    assert binary_type == b"BIN\0" and binary_offset + 8 + binary_len == len(data), path
    assert scene["buffers"][0]["byteLength"] == binary_len, path
    assert scene["scenes"][scene["scene"]]["nodes"], path
    for mesh in scene["meshes"]:
        for prim in mesh["primitives"]:
            assert prim["mode"] == 4, path
            assert prim["material"] < len(scene["materials"]), path
            pos = scene["accessors"][prim["attributes"]["POSITION"]]
            norm = scene["accessors"][prim["attributes"]["NORMAL"]]
            assert pos["count"] == norm["count"] and pos["count"] % 3 == 0, path
            for acc in (pos, norm):
                view = scene["bufferViews"][acc["bufferView"]]
                assert view["byteOffset"] + view["byteLength"] <= binary_len, path
                assert view["byteLength"] == acc["count"] * 12, path
                values = struct.unpack_from("<" + "f" * (acc["count"] * 3), data,
                                            binary_offset + 8 + view["byteOffset"])
                assert all(math.isfinite(v) for v in values), path
    reference = 'res://models/' + path.name
    assert reference in source, f"Missing Godot model reference: {reference}"

assert 'kill_goal = 12' in source
assert 'enemies.size() <= 2' in source
assert 'boss_prep_done' in source
print(f"Validated {len(models)} GLB files and their Godot references")
