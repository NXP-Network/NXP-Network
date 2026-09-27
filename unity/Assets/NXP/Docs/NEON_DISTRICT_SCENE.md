# Neon District — production scene spec
Camera: perspective isometric, ~55° pitch, 38–45° yaw.
Rendering: URP, HDR on, MSAA 4x, render scale 1.0–1.2 on Ultra.
Post FX: Bloom, Tonemapping, Color Adjustments, Vignette; subtle Depth of Field only in menus/cinematics.
Lighting: mixed neon emissives + baked GI where possible, soft realtime key shadows, reflection probes.
Materials: PBR wet asphalt, metal/roughness variation, emissive signage, puddle decals.
Environment: dense modular street kit, alleys, storefronts, vehicles, barriers, crates, cables, vents, steam.
Actors: armored NXP operative, red-visored soldier, spider drone, Mutant Brute.
VFX: muzzle flash, tracer, impact sparks, smoke, boss slam, core glow/collect burst.
Mobile: GPU instancing, LOD groups, occlusion culling, pooled VFX/enemies, baked lighting for static props.
Gameplay loop: 8 enemies -> 3 data cores -> Mutant Brute -> region reward -> next district.
