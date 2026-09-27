# Neon District scene setup
Create a Unity 6 URP project and copy/open this repository's unity/Assets/NXP folder.

Scene hierarchy:
- NXP_Bootstrap: NXPSceneBootstrap + NXPGraphicsBootstrap + NXPProgression
- World: NXPNeonDistrictBuilder
- Player: prefab with CharacterController, NXPHealth, NXPPlayerController, NXPWeapon
- CameraRig/Main Camera: NXPCameraRig, perspective camera
- Mission: NXPMissionDirector
- Global Volume: Bloom + Tonemapping + Color Adjustments + Vignette
- Directional Light: soft shadows
- Reflection Probes: street blocks
- RainFX: NXPRainFX
- UI Canvas: joystick, Fire, Dash, HP, Skill, mission HUD

Art direction:
Perspective isometric cyberpunk. Wet PBR asphalt, dense modular buildings, emissive cyan/magenta signs, fog/steam, rain, puddle decals, vehicles and street clutter. Do not use primitive cubes as final visible production art; NXPNeonDistrictBuilder is only a scene-layout scaffold to be replaced by licensed/imported production meshes.

Ultra:
HDR on, MSAA 4x, soft shadows, bloom, reflection probes, render scale 1.1 where device allows. Target 60 FPS.
