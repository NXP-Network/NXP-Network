extends Node3D

# Self-contained first playable Godot 4 prototype. All geometry is built at runtime.
const CYAN := Color(0.15, 0.87, 1.0)
const PINK := Color(1.0, 0.19, 0.59)
const AMBER := Color(1.0, 0.65, 0.24)
const WORLD := 22.0

var player: Node3D
var camera: Camera3D
var enemies: Array[Dictionary] = []
var cores: Array[Node3D] = []
var bolts: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var hp := 100.0
var kills := 0
var credits := 0
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
	rng.seed = 42028
	_build_world()
	_build_player()
	_build_ui()
	for i in range(3):
		_spawn_core(Vector3(-7.0 + i * 7.0, 0, -7.0 + (i % 2) * 10.0))
	for i in range(5):
		_spawn_enemy(false)
	_refresh_ui()

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

func _build_world() -> void:
	var env := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color(0.015, 0.025, 0.06)
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color(0.24, 0.36, 0.54)
	settings.ambient_light_energy = 0.8
	env.environment = settings
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -40, 0)
	sun.light_color = CYAN
	sun.light_energy = 0.65
	add_child(sun)
	block(self, Vector3(46, 0.2, 46), Vector3(0, -0.15, 0), Color(0.035, 0.055, 0.095))
	block(self, Vector3(13, 0.03, 46), Vector3(0, 0, 0), Color(0.08, 0.12, 0.19))
	for z in range(-20, 22, 4):
		block(self, Vector3(0.12, 0.025, 1.8), Vector3(0, 0.04, z), AMBER, true)
	for side in [-1, 1]:
		block(self, Vector3(0.12, 0.08, 45), Vector3(side * 6.4, 0.02, 0), CYAN, true)
		for row in range(6):
			var z := -19.0 + row * 7.5
			var height := rng.randf_range(4.0, 10.0)
			var x := side * rng.randf_range(10.5, 15.0)
			block(self, Vector3(5.2, height, 5.7), Vector3(x, height * 0.5, z), Color(0.045, 0.065, 0.12))
			for level in range(1, int(height / 1.15)):
				var tint: Color = PINK if (row + level) % 3 == 0 else CYAN
				block(self, Vector3(0.06, 0.09, 0.7), Vector3(x - side * 2.64, level * 1.1, z - 1.5), tint, true)
				block(self, Vector3(0.06, 0.09, 0.7), Vector3(x - side * 2.64, level * 1.1, z + 1.5), tint, true)
			block(self, Vector3(5.3, 0.09, 0.08), Vector3(x, height, z - 2.8), PINK if row % 2 else CYAN, true)
			if row % 2 == 0:
				block(self, Vector3(0.12, 3.3, 0.12), Vector3(side * 7.3, 1.65, z), Color(0.3, 0.38, 0.5))
				block(self, Vector3(0.8, 0.14, 0.5), Vector3(side * 7.3, 3.3, z), AMBER, true)
	for i in range(12):
		var side: float = -1.0 if i % 2 == 0 else 1.0
		var z := rng.randf_range(-19.0, 19.0)
		block(self, Vector3(0.9, 0.9, 0.9), Vector3(side * rng.randf_range(6.9, 8.5), 0.45, z), Color(0.24, 0.19, 0.16))
		block(self, Vector3(0.96, 0.07, 0.96), Vector3(side * 7.5, 0.94, z), AMBER, true)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 23.0
	camera.position = Vector3(16, 21, 18)
	add_child(camera)
	camera.look_at(Vector3.ZERO)
	camera.current = true

func _build_player() -> void:
	player = Node3D.new()
	add_child(player)
	block(player, Vector3(0.85, 1.2, 0.6), Vector3(0, 1.05, 0), Color(0.09, 0.15, 0.26))
	block(player, Vector3(0.72, 0.65, 0.7), Vector3(0, 1.92, 0), Color(0.12, 0.18, 0.3))
	block(player, Vector3(0.65, 0.13, 0.08), Vector3(0, 1.96, -0.38), CYAN, true)
	for side in [-1, 1]:
		block(player, Vector3(0.27, 0.85, 0.34), Vector3(side * 0.32, 0.43, 0), Color(0.06, 0.09, 0.18))
		block(player, Vector3(0.12, 0.55, 0.1), Vector3(side * 0.32, 0.4, -0.22), CYAN, true)
		block(player, Vector3(0.23, 0.85, 0.3), Vector3(side * 0.57, 1.0, 0), Color(0.09, 0.14, 0.25))
	block(player, Vector3(0.28, 0.24, 0.85), Vector3(0.6, 1.05, -0.48), Color(0.3, 0.35, 0.45))
	block(player, Vector3(0.3, 0.1, 0.15), Vector3(0.6, 1.08, -0.95), PINK, true)

func _spawn_core(pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	add_child(root)
	block(root, Vector3(0.55, 0.55, 0.55), Vector3(0, 0.65, 0), CYAN, true)
	block(root, Vector3(0.8, 0.07, 0.8), Vector3(0, 0.25, 0), Color(0.16, 0.28, 0.37))
	cores.append(root)

func _spawn_enemy(boss: bool) -> void:
	var root := Node3D.new()
	root.position = Vector3(rng.randf_range(-5.0, 5.0), 0, rng.randf_range(-19.0, 19.0))
	if root.position.distance_to(player.position) < 6.0:
		root.position.z = -19.0 if player.position.z > 0 else 19.0
	add_child(root)
	var scale_factor := 2.1 if boss else 1.0
	root.scale = Vector3.ONE * scale_factor
	block(root, Vector3(0.85, 1.2, 0.7), Vector3(0, 1.0, 0), Color(0.28, 0.08, 0.17))
	block(root, Vector3(0.7, 0.66, 0.65), Vector3(0, 1.93, 0), Color(0.21, 0.08, 0.15))
	block(root, Vector3(0.57, 0.12, 0.1), Vector3(0, 1.94, -0.36), PINK, true)
	for side in [-1, 1]:
		block(root, Vector3(0.24, 0.8, 0.3), Vector3(side * 0.3, 0.42, 0), Color(0.12, 0.07, 0.15))
		block(root, Vector3(0.2, 0.8, 0.3), Vector3(side * 0.56, 1.03, 0), Color(0.15, 0.07, 0.16))
	enemies.append({"node": root, "hp": 220.0 if boss else 65.0, "speed": 1.2 if boss else 2.2, "boss": boss})

func _process(delta: float) -> void:
	if game_over:
		return
	var direction := Input.get_vector("move_left", "move_right", "move_forward", "move_back") + joy_direction
	direction = direction.limit_length(1.0)
	player.position.x = clampf(player.position.x + direction.x * 6.2 * delta, -5.9, 5.9)
	player.position.z = clampf(player.position.z + direction.y * 6.2 * delta, -20, 20)
	if direction.length() > 0.1:
		player.rotation.y = atan2(-direction.x, -direction.y)
	camera.position = camera.position.lerp(player.position + Vector3(16, 21, 18), minf(1.0, delta * 3.0))
	fire_timer = maxf(0.0, fire_timer - delta)
	if fire_held or Input.is_action_pressed("fire"):
		_shoot()
	spawn_timer -= delta
	if spawn_timer <= 0.0 and enemies.size() < 6 and not boss_spawned:
		_spawn_enemy(false)
		spawn_timer = 2.8
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		var node: Node3D = enemy["node"]
		var toward: Vector3 = player.position - node.position
		toward.y = 0
		if toward.length() > 1.15:
			node.position += toward.normalized() * float(enemy["speed"]) * delta
			node.look_at(player.position + Vector3(0, 1, 0), Vector3.UP)
		else:
			hp = maxf(0.0, hp - (22.0 if enemy["boss"] else 11.0) * delta)
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
				enemy["hp"] = float(enemy["hp"]) - 25.0
				hit = true
				if float(enemy["hp"]) <= 0.0:
					credits += 15 if enemy["boss"] else 5
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
	if kills >= 8 and cores.is_empty() and not boss_spawned:
		boss_spawned = true
		_spawn_enemy(true)
	if hp <= 0:
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
	game_over = true
	var title := "BÖLGE TEMİZLENDİ" if victory else "OPERASYON BAŞARISIZ"
	var panel := ColorRect.new()
	panel.color = Color(0.015, 0.025, 0.065, 0.93)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(panel)
	var message := Label.new()
	message.text = "%s\n\n%d düşman • %d kredi" % [title, kills, credits]
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 32)
	message.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	message.position = Vector2(-300, -110)
	message.size = Vector2(600, 130)
	overlay.add_child(message)
	var retry := Button.new()
	retry.text = "YENİDEN OYNA"
	retry.add_theme_font_size_override("font_size", 25)
	retry.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	retry.position = Vector2(-130, 70)
	retry.size = Vector2(260, 75)
	retry.pressed.connect(func() -> void: get_tree().reload_current_scene())
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
	top.offset_bottom = 148
	overlay.add_child(top)
	hud = Label.new()
	hud.position = Vector2(22, 16)
	hud.add_theme_font_size_override("font_size", 24)
	hud.add_theme_color_override("font_color", CYAN)
	overlay.add_child(hud)
	mission = Label.new()
	mission.position = Vector2(22, 95)
	mission.add_theme_font_size_override("font_size", 18)
	mission.add_theme_color_override("font_color", Color.WHITE)
	overlay.add_child(mission)
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
	hud.text = "NXP // NEON DISTRICT\nCAN %d / 100    •    KREDİ %d" % [ceili(hp), credits]
	mission.text = "BOSS: MUTANT BRUTE" if boss_spawned else "GÖREV: %d/8 düşman   •   %d/3 çekirdek" % [mini(kills, 8), 3 - cores.size()]
