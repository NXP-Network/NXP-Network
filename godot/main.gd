extends Node3D

# Four-map mobile defense prototype. Geometry is built at runtime.
const CYAN := Color(0.15, 0.87, 1.0)
const PINK := Color(1.0, 0.19, 0.59)
const AMBER := Color(1.0, 0.65, 0.24)
const WORLD := 22.0
const MAPS := ["NEON DISTRICT", "DATA WASTELAND", "QUANTUM PORT", "ORBITAL CORE"]
const SAVE_PATH := "user://nxp_defense.cfg"

var player: Node3D
var camera: Camera3D
var enemies: Array[Dictionary] = []
var cores: Array[Node3D] = []
var bolts: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var hp := 100.0
var kills := 0
var credits := 0
var level := 1
var stage := 0
var unlocked := 0
var base_hp := 150.0
var base_node: Node3D
var kill_goal := 8
var choosing_map := false
var fire_timer := 0.0
var spawn_timer := 0.0
var game_over := false
var boss_spawned := false
var joy_origin := Vector2.ZERO
var joy_direction := Vector2.ZERO
var joy_pointer := -1
var fire_pointer := -1
var fire_held := false
var joy_base: Control
var joy_knob: Control
var hud: Label
var mission: Label
var overlay: Control

func _ready() -> void:
	_load_progress()
	rng.seed = 42028 + stage * 101
	kill_goal = 8 + stage * 2
	_build_world()
	_build_base()
	_build_player()
	_build_ui()
	for i in range(3):
		_spawn_core(Vector3(-4.2 + i * 4.2, 0, -3.0 + (i % 2) * 4.0))
	for i in range(5):
		_spawn_enemy(false)
	_refresh_ui()

func _load_progress() -> void:
	var save := ConfigFile.new()
	if save.load(SAVE_PATH) == OK:
		unlocked = clampi(int(save.get_value("progress", "unlocked", 0)), 0, MAPS.size() - 1)
		stage = clampi(int(save.get_value("progress", "stage", 0)), 0, unlocked)
		level = maxi(1, int(save.get_value("progress", "level", 1)))
		credits = maxi(0, int(save.get_value("progress", "credits", 0)))

func _save_progress() -> void:
	var save := ConfigFile.new()
	save.set_value("progress", "stage", stage)
	save.set_value("progress", "unlocked", unlocked)
	save.set_value("progress", "level", level)
	save.set_value("progress", "credits", credits)
	save.save(SAVE_PATH)

func material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = 0.35
	m.roughness = 0.32
	if glow:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.emission_enabled = true
		m.emission = color
	return m

func block(parent: Node3D, size: Vector3, pos: Vector3, color: Color, glow: bool = false) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = size
	mesh.mesh = cube
	mesh.material_override = material(color, glow)
	mesh.position = pos
	parent.add_child(mesh)
	return mesh

func oval(parent: Node3D, radii: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	node.mesh = sphere
	node.scale = radii
	node.position = pos
	node.material_override = material(color)
	parent.add_child(node)
	return node

func limb(parent: Node3D, start: Vector3, finish: Vector3, radius: float, color: Color) -> void:
	var length := start.distance_to(finish)
	var node := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius * 1.12
	cylinder.height = length
	node.mesh = cylinder
	node.position = (start + finish) * 0.5
	node.quaternion = Quaternion(Vector3.UP, (finish - start).normalized())
	node.material_override = material(color)
	parent.add_child(node)

func _build_world() -> void:
	var env := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = [Color(0.035, 0.05, 0.08), Color(0.16, 0.11, 0.08), Color(0.04, 0.11, 0.17), Color(0.055, 0.035, 0.12)][stage]
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color(0.4, 0.48, 0.58)
	settings.ambient_light_energy = 1.0
	env.environment = settings
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -40, 0)
	sun.light_color = Color(0.64, 0.75, 0.86)
	sun.light_energy = 0.85
	add_child(sun)
	var ground: Color = [Color(0.14, 0.18, 0.23), Color(0.26, 0.2, 0.14), Color(0.04, 0.17, 0.22), Color(0.11, 0.1, 0.19)][stage]
	var road: Color = [Color(0.2, 0.24, 0.29), Color(0.32, 0.26, 0.19), Color(0.21, 0.29, 0.34), Color(0.25, 0.26, 0.35)][stage]
	block(self, Vector3(46, 0.2, 46), Vector3(0, -0.15, 0), ground)
	block(self, Vector3(13, 0.03, 46), Vector3(0, 0, 0), road)
	# Asphalt panels and narrow seams make the walking surface legible on a phone.
	for row in range(11):
		for lane in range(3):
			var tile: Color = road.lightened(0.07) if (row + lane) % 2 == 0 else road.darkened(0.03)
			block(self, Vector3(3.7, 0.012, 3.75), Vector3((lane - 1) * 4.1, 0.027, -19.9 + row * 4.0), tile)
	for z in range(-20, 22, 4):
		block(self, Vector3(0.08, 0.03, 1.4), Vector3(0, 0.042, z), Color(0.6, 0.43, 0.23))
	for side_value in ([-1, 1] if stage == 0 else []):
		var side := float(side_value)
		block(self, Vector3(0.1, 0.055, 45), Vector3(side * 6.4, 0.02, 0), Color(0.11, 0.42, 0.5))
		for row in range(6):
			var z := -19.0 + row * 7.5
			var height := rng.randf_range(4.0, 10.0)
			var x: float = side * rng.randf_range(10.5, 15.0)
			block(self, Vector3(5.2, height, 5.7), Vector3(x, height * 0.5, z), Color(0.045, 0.065, 0.12))
			for level in range(1, int(height / 1.15)):
				var tint: Color = Color(0.5, 0.13, 0.32) if (row + level) % 3 == 0 else Color(0.13, 0.42, 0.5)
				block(self, Vector3(0.06, 0.09, 0.7), Vector3(x - side * 2.64, level * 1.1, z - 1.5), tint, true)
				block(self, Vector3(0.06, 0.09, 0.7), Vector3(x - side * 2.64, level * 1.1, z + 1.5), tint, true)
			block(self, Vector3(5.3, 0.09, 0.08), Vector3(x, height, z - 2.8), Color(0.4, 0.12, 0.3) if row % 2 else Color(0.1, 0.35, 0.43), true)
			if row % 2 == 0:
				block(self, Vector3(0.12, 3.3, 0.12), Vector3(side * 7.3, 1.65, z), Color(0.3, 0.38, 0.5))
				block(self, Vector3(0.8, 0.14, 0.5), Vector3(side * 7.3, 3.3, z), Color(0.56, 0.36, 0.18))
	for i in range(12 if stage == 0 else 0):
		var side: float = -1.0 if i % 2 == 0 else 1.0
		var z := rng.randf_range(-19.0, 19.0)
		block(self, Vector3(0.9, 0.9, 0.9), Vector3(side * rng.randf_range(6.9, 8.5), 0.45, z), Color(0.24, 0.19, 0.16))
		block(self, Vector3(0.96, 0.07, 0.96), Vector3(side * 7.5, 0.94, z), Color(0.55, 0.39, 0.21))
	_build_map_props()
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 19.0
	camera.position = Vector3(12, 23, 17)
	add_child(camera)
	camera.look_at(Vector3.ZERO)
	camera.current = true

func _build_map_props() -> void:
	if stage == 0:
		return
	for side_value in [-1, 1]:
		var side := float(side_value)
		for i in range(7):
			var z := -19.0 + i * 6.2
			if stage == 1:
				# Sandy wasteland with rock piles, ruined walls and rusted equipment.
				oval(self, Vector3(1.8, 0.7, 1.2), Vector3(side * 9.5, 0.4, z), Color(0.4, 0.31, 0.23))
				block(self, Vector3(0.55, 2.6, 3.0), Vector3(side * 12.2, 1.3, z + 1.8), Color(0.31, 0.25, 0.22))
				block(self, Vector3(2.3, 0.9, 1.1), Vector3(side * 8.2, 0.45, z - 1.4), Color(0.32, 0.27, 0.24))
			elif stage == 2:
				# Water surrounds a cargo dock with alternating containers.
				block(self, Vector3(14, 0.02, 46), Vector3(side * 15.0, 0.005, 0), Color(0.04, 0.21, 0.29))
				block(self, Vector3(3.4, 2.4, 5.3), Vector3(side * 10.5, 1.2, z), Color(0.19, 0.32, 0.38) if i % 2 else Color(0.46, 0.24, 0.18))
				for seam in range(4):
					block(self, Vector3(0.06, 2.2, 0.06), Vector3(side * 8.75, 1.2, z - 1.9 + seam * 1.2), Color(0.48, 0.52, 0.53))
			else:
				# Metal orbital platforms, reactor pylons and dark void.
				block(self, Vector3(6.0, 0.25, 5.0), Vector3(side * 10.5, 0.15, z), Color(0.19, 0.2, 0.3))
				block(self, Vector3(1.0, 4.3, 1.0), Vector3(side * 11.3, 2.3, z), Color(0.2, 0.24, 0.33))
				block(self, Vector3(1.2, 0.12, 1.2), Vector3(side * 11.3, 4.4, z), Color(0.31, 0.21, 0.48))

func _build_base() -> void:
	base_node = Node3D.new()
	base_node.position = Vector3(0, 0, 6.5)
	add_child(base_node)
	var wall: Color = [Color(0.36, 0.41, 0.46), Color(0.43, 0.36, 0.29), Color(0.28, 0.41, 0.45), Color(0.36, 0.35, 0.5)][stage]
	block(base_node, Vector3(4.0, 2.6, 3.4), Vector3(0, 1.3, 0), wall)
	block(base_node, Vector3(4.7, 0.38, 4.1), Vector3(0, 2.78, 0), wall.darkened(0.25))
	for side_value in [-1, 1]:
		var side := float(side_value)
		block(base_node, Vector3(0.85, 3.9, 0.85), Vector3(side * 2.1, 1.95, -1.7), wall.darkened(0.1))
		block(base_node, Vector3(0.78, 0.16, 0.78), Vector3(side * 2.1, 3.95, -1.7), wall.lightened(0.12))
		block(base_node, Vector3(0.54, 0.6, 0.08), Vector3(side * 1.28, 1.6, -1.76), Color(0.15, 0.2, 0.25))
	block(base_node, Vector3(1.1, 1.55, 0.09), Vector3(0, 0.78, -1.76), Color(0.11, 0.14, 0.17))
	block(base_node, Vector3(1.8, 0.12, 0.1), Vector3(0, 2.25, -1.76), Color(0.23, 0.45, 0.47))
	block(base_node, Vector3(5.5, 0.13, 0.2), Vector3(0, 0.12, -3.0), Color(0.34, 0.4, 0.42))

func _build_player() -> void:
	player = Node3D.new()
	add_child(player)
	var suit := Color(0.23, 0.33, 0.43)
	var skin := Color(0.73, 0.48, 0.33)
	oval(player, Vector3(0.39, 0.56, 0.27), Vector3(0, 1.25, 0), suit)
	oval(player, Vector3(0.27, 0.32, 0.26), Vector3(0, 2.08, 0), skin)
	block(player, Vector3(0.51, 0.13, 0.29), Vector3(0, 2.31, 0), Color(0.11, 0.15, 0.2))
	block(player, Vector3(0.54, 0.07, 0.08), Vector3(0, 2.08, -0.265), Color(0.18, 0.56, 0.6))
	for side_value in [-1, 1]:
		var side := float(side_value)
		limb(player, Vector3(side * 0.2, 0.91, 0), Vector3(side * 0.25, 0.16, 0.05), 0.17, Color(0.16, 0.23, 0.3))
		block(player, Vector3(0.3, 0.17, 0.52), Vector3(side * 0.26, 0.09, -0.16), Color(0.11, 0.15, 0.2))
		limb(player, Vector3(side * 0.4, 1.61, 0), Vector3(side * 0.61, 1.08, -0.24), 0.13, suit)
		oval(player, Vector3(0.12, 0.13, 0.12), Vector3(side * 0.62, 1.04, -0.25), skin)
	block(player, Vector3(0.23, 0.21, 0.67), Vector3(0.64, 1.1, -0.62), Color(0.14, 0.17, 0.2))
	block(player, Vector3(0.22, 0.1, 0.12), Vector3(0.64, 1.1, -1.0), Color(0.37, 0.18, 0.23))
	block(player, Vector3(0.56, 0.4, 0.11), Vector3(0, 1.4, -0.28), suit.lightened(0.22))
	block(player, Vector3(0.45, 0.52, 0.18), Vector3(0, 1.35, 0.31), Color(0.13, 0.18, 0.21))
	block(player, Vector3(0.42, 0.12, 0.38), Vector3(0, 0.83, 0), Color(0.14, 0.19, 0.24))

func _spawn_core(pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	add_child(root)
	block(root, Vector3(0.55, 0.55, 0.55), Vector3(0, 0.65, 0), CYAN, true)
	block(root, Vector3(0.8, 0.07, 0.8), Vector3(0, 0.25, 0), Color(0.16, 0.28, 0.37))
	cores.append(root)

func _spawn_enemy(boss: bool) -> void:
	var root := Node3D.new()
	root.position = Vector3(rng.randf_range(-5.0, 5.0), 0, rng.randf_range(-19.0, -13.0))
	add_child(root)
	var scale_factor := 2.1 if boss else 1.0
	root.scale = Vector3.ONE * scale_factor
	var shell := Color(0.28, 0.15, 0.22) if boss else Color(0.16, 0.2, 0.25)
	if stage == 1:
		shell = Color(0.35, 0.24, 0.16)
	elif stage == 2:
		shell = Color(0.13, 0.28, 0.3)
	elif stage == 3:
		shell = Color(0.3, 0.22, 0.39)
	var legs := Color(0.25, 0.15, 0.19) if boss else Color(0.13, 0.17, 0.21)
	oval(root, Vector3(0.65, 0.37, 0.72), Vector3(0, 0.78, 0.42), shell)
	oval(root, Vector3(0.42, 0.29, 0.43), Vector3(0, 0.76, -0.49), shell.lightened(0.15))
	for stripe in range(3):
		oval(root, Vector3(0.44 - stripe * 0.08, 0.04, 0.06), Vector3(0, 1.11 + stripe * 0.025, 0.05 + stripe * 0.27), shell.lightened(0.35))
	for side_value in [-1, 1]:
		var side := float(side_value)
		for leg_index in range(4):
			var z: float = -0.6 + leg_index * 0.42
			var knee := Vector3(side * (0.95 + leg_index * 0.08), 0.95, z * 1.7)
			var foot := Vector3(side * (1.35 + leg_index * 0.16), 0.1, z * 2.2)
			limb(root, Vector3(side * 0.34, 0.78, z), knee, 0.09, legs)
			limb(root, knee, foot, 0.065, legs)
			oval(root, Vector3(0.1, 0.1, 0.1), knee, legs.lightened(0.13))
	for side_value in [-1, 1]:
		var side := float(side_value)
		oval(root, Vector3(0.09, 0.09, 0.06), Vector3(side * 0.19, 0.87, -0.87), Color(0.85, 0.19, 0.2))
		limb(root, Vector3(side * 0.21, 0.69, -0.77), Vector3(side * 0.25, 0.39, -0.98), 0.055, legs)
	enemies.append({"node": root, "hp": 220.0 + stage * 70.0 if boss else 65.0 + stage * 17.0, "speed": 1.2 + stage * 0.1 if boss else 2.2 + stage * 0.2, "boss": boss})

func _process(delta: float) -> void:
	if game_over:
		return
	var direction := Input.get_vector("move_left", "move_right", "move_forward", "move_back") + joy_direction
	direction = direction.limit_length(1.0)
	player.position.x = clampf(player.position.x + direction.x * 6.2 * delta, -5.9, 5.9)
	player.position.z = clampf(player.position.z + direction.y * 6.2 * delta, -20, 20)
	if direction.length() > 0.1:
		player.rotation.y = atan2(-direction.x, -direction.y)
	camera.position = camera.position.lerp(player.position + Vector3(12, 23, 17), minf(1.0, delta * 3.0))
	fire_timer = maxf(0.0, fire_timer - delta)
	if fire_held or Input.is_action_pressed("fire"):
		_shoot()
	spawn_timer -= delta
	if spawn_timer <= 0.0 and enemies.size() < 6 and not boss_spawned and kills < kill_goal:
		_spawn_enemy(false)
		spawn_timer = maxf(1.8, 2.8 - stage * 0.25)
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		var node: Node3D = enemy["node"]
		var target_position: Vector3 = player.position if node.position.distance_to(player.position) < 3.5 else base_node.position
		var toward: Vector3 = target_position - node.position
		toward.y = 0
		if toward.length() > (2.6 if target_position == base_node.position else 1.15):
			node.position += toward.normalized() * float(enemy["speed"]) * delta
			node.look_at(target_position + Vector3(0, 1, 0), Vector3.UP)
			node.position.y = sin(Time.get_ticks_msec() * 0.006 + float(i) * 1.4) * 0.045
		else:
			var damage := (22.0 if enemy["boss"] else 11.0) * delta
			if target_position == base_node.position:
				base_hp = maxf(0.0, base_hp - damage)
			else:
				hp = maxf(0.0, hp - damage)
	for i in range(cores.size() - 1, -1, -1):
		var core := cores[i]
		core.rotate_y(delta * 1.7)
		if core.position.distance_to(player.position) < 1.3:
			cores.remove_at(i)
			core.queue_free()
			credits += 10
	for i in range(bolts.size() - 1, -1, -1):
		var bolt: Dictionary = bolts[i]
		var mesh: Node3D = bolt["node"]
		var velocity: Vector3 = bolt["velocity"]
		mesh.position += velocity * delta
		bolt["life"] = float(bolt["life"]) - delta
		var hit := false
		for j in range(enemies.size() - 1, -1, -1):
			var enemy: Dictionary = enemies[j]
			var target: Node3D = enemy["node"]
			if mesh.position.distance_to(target.position + Vector3(0, 1, 0)) < (1.5 if enemy["boss"] else 0.8):
				enemy["hp"] = float(enemy["hp"]) - (25.0 + level * 2.0)
				hit = true
				if float(enemy["hp"]) <= 0.0:
					credits += 15 + stage * 5 if enemy["boss"] else 5 + stage * 2
					kills += 1
					var was_boss: bool = enemy["boss"]
					target.queue_free()
					enemies.remove_at(j)
					if was_boss:
						_end_game(true)
				break
		if hit or float(bolt["life"]) <= 0.0:
			mesh.queue_free()
			bolts.remove_at(i)
	if kills >= kill_goal and cores.is_empty() and not boss_spawned:
		boss_spawned = true
		_spawn_enemy(true)
	if hp <= 0 or base_hp <= 0:
		_end_game(false)
	_refresh_ui()

func _shoot() -> void:
	if fire_timer > 0 or game_over:
		return
	fire_timer = 0.25
	var direction := -player.global_basis.z
	var nearest := 13.0
	for enemy in enemies:
		var target: Node3D = enemy["node"]
		var offset: Vector3 = target.position - player.position
		if offset.length() < nearest:
			nearest = offset.length()
			direction = offset.normalized()
	direction.y = 0
	direction = direction.normalized()
	player.rotation.y = atan2(-direction.x, -direction.z)
	var bolt := Node3D.new()
	bolt.position = player.position + Vector3(0, 1.1, 0) + direction * 0.85
	add_child(bolt)
	block(bolt, Vector3(0.22, 0.22, 0.55), Vector3.ZERO, CYAN, true)
	bolt.rotation.y = atan2(-direction.x, -direction.z)
	bolts.append({"node": bolt, "velocity": direction * 19.0, "life": 0.85})

func _end_game(victory: bool) -> void:
	if game_over:
		return
	game_over = true
	var finished_stage := stage
	if victory:
		level += 1
		credits += 60 + stage * 25
		unlocked = maxi(unlocked, mini(stage + 1, MAPS.size() - 1))
	_save_progress()
	var title := "ÜS KORUNDU!" if victory else "ÜS DÜŞTÜ!" if base_hp <= 0 else "OPERASYON BAŞARISIZ"
	var panel := ColorRect.new()
	panel.color = Color(0.015, 0.025, 0.065, 0.93)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(panel)
	var message := Label.new()
	message.text = "%s\n%s • LV %d\n%d örümcek • %d kredi" % [title, MAPS[finished_stage], level, kills, credits]
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 32)
	message.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	message.position = Vector2(-330, -140)
	message.size = Vector2(660, 190)
	overlay.add_child(message)
	var retry := Button.new()
	retry.text = "SONRAKİ BÖLÜM" if victory and finished_stage < MAPS.size() - 1 else "YENİDEN OYNA"
	retry.add_theme_font_size_override("font_size", 25)
	retry.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	retry.position = Vector2(-130, 70)
	retry.size = Vector2(260, 75)
	retry.pressed.connect(func() -> void:
		if victory and finished_stage < MAPS.size() - 1:
			stage = finished_stage + 1
			_save_progress()
		get_tree().reload_current_scene()
	)
	overlay.add_child(retry)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(overlay)
	var top := ColorRect.new()
	top.color = Color(0.02, 0.04, 0.1, 0.9)
	top.anchor_right = 1
	top.offset_bottom = 162
	overlay.add_child(top)
	hud = Label.new()
	hud.position = Vector2(22, 16)
	hud.add_theme_font_size_override("font_size", 22)
	hud.add_theme_color_override("font_color", CYAN)
	overlay.add_child(hud)
	mission = Label.new()
	mission.position = Vector2(22, 105)
	mission.add_theme_font_size_override("font_size", 18)
	mission.add_theme_color_override("font_color", Color.WHITE)
	overlay.add_child(mission)
	var maps_button := Button.new()
	maps_button.text = "HARİTALAR"
	maps_button.position = Vector2(551, 17)
	maps_button.size = Vector2(150, 50)
	maps_button.add_theme_font_size_override("font_size", 18)
	maps_button.pressed.connect(_show_map_menu)
	overlay.add_child(maps_button)
	joy_base = _touch_circle("", Vector2(34, -206), Vector2(170, 170), false)
	joy_base.anchor_top = 1
	joy_base.anchor_bottom = 1
	joy_base.gui_input.connect(_joy_input)
	joy_knob = ColorRect.new()
	joy_knob.color = Color(0.23, 0.85, 0.97, 0.8)
	joy_knob.position = Vector2(56, 56)
	joy_knob.size = Vector2(58, 58)
	joy_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	joy_base.add_child(joy_knob)
	var fire_button := _touch_circle("ATEŞ", Vector2(-176, -205), Vector2(150, 150), true)
	fire_button.anchor_left = 1
	fire_button.anchor_right = 1
	fire_button.anchor_top = 1
	fire_button.anchor_bottom = 1
	fire_button.gui_input.connect(_fire_input)

func _show_map_menu() -> void:
	if game_over:
		return
	game_over = true
	var menu := Control.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(menu)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.06, 0.95)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(shade)
	var title := Label.new()
	title.text = "AÇILAN HARİTALAR • LV %d" % level
	title.position = Vector2(55, 270)
	title.size = Vector2(610, 70)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 27)
	menu.add_child(title)
	for i in range(MAPS.size()):
		var map_index := i
		var button := Button.new()
		button.text = "%d. %s%s" % [i + 1, MAPS[i], " 🔒" if i > unlocked else ""]
		button.disabled = i > unlocked
		button.position = Vector2(75, 370 + i * 94)
		button.size = Vector2(570, 76)
		button.add_theme_font_size_override("font_size", 23)
		button.pressed.connect(func() -> void:
			stage = map_index
			_save_progress()
			get_tree().reload_current_scene()
		)
		menu.add_child(button)
	var close := Button.new()
	close.text = "OYUNA DÖN"
	close.position = Vector2(220, 790)
	close.size = Vector2(280, 75)
	close.pressed.connect(func() -> void:
		menu.queue_free()
		game_over = false
	)
	menu.add_child(close)

func _touch_circle(caption: String, pos: Vector2, dims: Vector2, pink: bool) -> Control:
	var control := Panel.new()
	control.position = pos
	control.size = dims
	control.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.35, 0.07, 0.22, 0.7) if pink else Color(0.04, 0.16, 0.29, 0.7)
	style.border_color = PINK if pink else CYAN
	style.set_border_width_all(3)
	style.set_corner_radius_all(90)
	control.add_theme_stylebox_override("panel", style)
	overlay.add_child(control)
	if caption != "":
		var label := Label.new()
		label.text = caption
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", 26)
		control.add_child(label)
	return control

func _joy_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and joy_pointer == -1:
			joy_pointer = event.index
			_set_joy(event.position)
		elif not event.pressed and event.index == joy_pointer:
			joy_pointer = -1
			joy_direction = Vector2.ZERO
			joy_knob.position = Vector2(56, 56)
	elif event is InputEventScreenDrag and event.index == joy_pointer:
		_set_joy(event.position)
	elif event is InputEventMouseButton:
		if event.pressed:
			_set_joy(event.position)
		else:
			joy_direction = Vector2.ZERO
			joy_knob.position = Vector2(56, 56)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_set_joy(event.position)

func _set_joy(local_pos: Vector2) -> void:
	joy_direction = ((local_pos - Vector2(85, 85)) / 56.0).limit_length(1.0)
	joy_knob.position = Vector2(56, 56) + joy_direction * 56.0

func _fire_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and fire_pointer == -1:
			fire_pointer = event.index
			fire_held = true
		elif not event.pressed and event.index == fire_pointer:
			fire_pointer = -1
			fire_held = false
	elif event is InputEventMouseButton:
		fire_held = event.pressed

func _refresh_ui() -> void:
	hud.text = "NXP // %s\nLV %d   CAN %d   ÜS %d/150   KREDİ %d" % [MAPS[stage], level, ceili(hp), ceili(base_hp), credits]
	mission.text = "BOSS: ÖRÜMCEK KRALİÇE • ÜSSÜ KORU" if boss_spawned else "ÜSSÜ KORU • %d/%d örümcek • %d/3 çekirdek" % [mini(kills, kill_goal), kill_goal, 3 - cores.size()]
