extends CharacterBody2D
## Shared combat contract; separate player intent and enemy decision making.
signal defeated(fighter)
signal feedback(kind, point)
@export var walk_speed := 110.0
@export var run_speed := 160.0
@export var acceleration := 1800.0
@export var braking := 2400.0
@export var gravity := 800.0
@export var jump_speed := 320.0
@export var parry_window := 0.15
@export var heal_amount := 45.0
var kind := "ren"
var enemy := false
var defender := false
var world: Node2D
var hp := 100.0
var max_hp := 100.0
var stamina := 100.0
var posture := 100.0
var max_posture := 100.0
var cures := 2
var facing := 1.0
var state := "idle"
var state_time := 0.0
var invulnerable := 0.0
var stamina_delay := 0.0
var parry_regen_bonus := 0.0
var posture_delay := 0.0
var parry_cooldown := 0.0
var counter_window := 0.0
var dodge_cooldown := 0.0
var coyote := 0.0
var jump_buffer := 0.0
var attack: Dictionary = {}
var attack_hit := false
var combo := 0
var queued_light := false
var ai_cooldown := 0.7
var ai_cycle := 0
var start_x := 0.0
var sword_drawn := true
var sprite: Sprite2D
var hurtbox: Area2D
var last_safe := Vector2.ZERO
var elapsed := 0.0
var previous_floor := false
var step_clock := 0.0
var test_control := false
var production_visual: RefCounted

func _ready() -> void:
	add_to_group("fighters")
	collision_layer = 2
	collision_mask = 1
	var shape := RectangleShape2D.new()
	shape.size = Vector2(16, 42 if kind != "daigo" else 48)
	var body := CollisionShape2D.new()
	body.shape = shape
	body.position.y = -shape.size.y / 2
	add_child(body)
	hurtbox = Area2D.new()
	hurtbox.collision_layer = 4
	hurtbox.collision_mask = 0
	var hurt_shape := CollisionShape2D.new()
	hurt_shape.shape = shape.duplicate()
	hurt_shape.position = body.position
	hurtbox.add_child(hurt_shape)
	add_child(hurtbox)
	sprite = Sprite2D.new()
	production_visual = preload("res://scripts/fighter_visual.gd").new(kind)
	var folder := "enemies/human_base" if kind == "human" else "characters/" + kind
	if production_visual.frames == null:
		sprite.texture = load("res://assets/" + folder + "/TEMP_poses.png")
		sprite.hframes = 8
	sprite.position = Vector2(0, -32)
	add_child(sprite)
	if enemy:
		max_hp = 180 if kind == "daigo" else (72 if defender else 54)
		max_posture = 120 if kind == "daigo" else (110 if defender else 100)
		hp = max_hp
		posture = max_posture
	start_x = position.x
	last_safe = position
	update_visual()

func set_state(next: String) -> void:
	state = next
	state_time = 0.0
	if next in ["hurt", "posture_break", "death", "heal", "echo_interact"]:
		queued_light = false
		attack = {}

func _physics_process(delta: float) -> void:
	if world == null or world.hitstop > 0:
		return
	if world.locked:
		# Dialogue freezes combat, but the living defeat and memory gesture still settle.
		if state in ["death", "echo_interact"]:
			elapsed += delta
			update_visual()
		return
	elapsed += delta
	state_time += delta
	invulnerable = maxf(0, invulnerable - delta)
	stamina_delay = maxf(0, stamina_delay - delta)
	parry_regen_bonus = maxf(0, parry_regen_bonus - delta)
	posture_delay = maxf(0, posture_delay - delta)
	parry_cooldown = maxf(0, parry_cooldown - delta)
	counter_window = maxf(0, counter_window - delta)
	dodge_cooldown = maxf(0, dodge_cooldown - delta)
	ai_cooldown = maxf(0, ai_cooldown - delta)
	if state == "death":
		update_visual()
		return
	if not is_on_floor():
		var g := gravity
		if not enemy and velocity.y < 0 and not Input.is_action_pressed("jump"):
			g *= 2
		velocity.y = minf(520, velocity.y + g * delta)
	else:
		coyote = 0.1
		last_safe = position
	coyote -= delta
	jump_buffer -= delta
	if stamina_delay <= 0 and state in ["idle", "walk", "run", "parry_window", "parry", "guard_hold", "guard_release", "jump", "fall", "land"]:
		stamina = minf(100, stamina + delta * (12 if state == "guard_hold" else 24) * (1.2 if parry_regen_bonus > 0 else 1.0))
	if posture_delay <= 0 and state != "posture_break" and attack.is_empty():
		posture = minf(max_posture, posture + delta * (30 if state == "guard_hold" else 22))
	if state in ["hurt", "posture_break"]:
		velocity.x = move_toward(velocity.x, 0, braking * delta)
		if state_time > (0.25 if state == "hurt" else (1.8 if enemy else 1.0)):
			if state == "posture_break":
				posture = max_posture
			set_state("idle")
	elif state == "dodge":
		velocity.x = facing * 200
		if state_time >= 0.24:
			set_state("idle")
	elif not attack.is_empty():
		process_attack(delta)
	elif state == "heal":
		velocity.x = 0
		if Input.get_axis("move_left", "move_right") != 0 or Input.is_action_just_pressed("dodge"):
			set_state("idle")
		elif state_time >= 1:
			cures -= 1
			hp = minf(max_hp, hp + heal_amount)
			feedback.emit("heal", global_position + Vector2(0,-24))
			set_state("idle")
	elif state in ["draw_sword", "sheathe_sword", "interact", "echo_interact"]:
		velocity.x = 0
		if state_time > 0.3:
			set_state("idle")
	elif enemy:
		process_enemy(delta)
	elif not test_control:
		process_player(delta)
	move_and_slide()
	position.x = clampf(position.x, 18, world.level_width - 18)
	if is_on_floor() and not previous_floor and state in ["jump", "fall"]:
		set_state("land")
		Sound.play("land")
	previous_floor = is_on_floor()
	if position.y > 430:
		position = last_safe
		velocity = Vector2.ZERO
		hp = maxf(0, hp - 10)
		if hp <= 0:
			die()
	update_visual()
	queue_redraw()

func process_player(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer = 0.14 if Save.progress.get("garca_equipped", false) else 0.1
	if jump_buffer > 0 and coyote > 0:
		velocity.y = -jump_speed
		jump_buffer = 0
		coyote = 0
		set_state("jump_start")
		Sound.play("jump")
	if Input.is_action_just_pressed("guard"):
		start_guard()
	if state in ["guard_start", "parry_window", "guard_hold", "parry"]:
		velocity.x = move_toward(velocity.x, 0, braking * delta)
		if Input.is_action_just_pressed("light_attack") and counter_window > 0:
			start_attack("counter")
		elif not Input.is_action_pressed("guard"):
			set_state("guard_release")
		elif state_time > active_parry_window():
			state = "guard_hold"
		return
	if Input.is_action_just_pressed("dodge") and is_on_floor() and dodge_cooldown <= 0 and spend(18):
		set_state("dodge")
		Sound.play("dodge")
		dodge_cooldown = 0.45
		return
	if Input.is_action_just_pressed("heal") and cures > 0 and hp < max_hp and is_on_floor():
		parry_regen_bonus = 0
		set_state("heal")
		return
	if Input.is_action_just_pressed("light_attack"):
		start_attack("counter" if counter_window > 0 else "light")
		return
	if Input.is_action_just_pressed("heavy_attack"):
		start_attack("heavy")
		return
	var axis := Input.get_axis("move_left", "move_right")
	var target := axis * (run_speed if Input.is_action_pressed("run") else walk_speed)
	velocity.x = move_toward(velocity.x, target, (acceleration if axis != 0 else braking) * delta)
	if axis != 0:
		facing = signf(axis)
	if not is_on_floor():
		state = "jump" if velocity.y < 0 else "fall"
	elif state != "land" or state_time > (0.04 if Save.progress.get("garca_equipped", false) else 0.08):
		state = ("run" if absf(target) > walk_speed else "walk") if axis != 0 else "idle"
	if is_on_floor() and absf(velocity.x) > 30:
		step_clock -= delta
		if step_clock <= 0:
			Sound.play("step_wood" if world.memory and position.x>400 and position.x<680 else "step")
			step_clock = 0.32

func start_guard() -> void:
	if state in ["death", "hurt", "posture_break"] or not attack.is_empty():
		return
	if parry_cooldown <= 0:
		set_state("parry_window")
		parry_cooldown = 0.25
	else:
		set_state("guard_hold")

func active_parry_window() -> float:
	return 0.22 if Save.settings.parry_assist else parry_window

func spend(cost: float) -> bool:
	if stamina < cost:
		return false
	stamina -= cost
	stamina_delay = 0.6
	parry_regen_bonus = 0
	return true

func start_attack(type: String) -> bool:
	if state in ["death", "hurt", "posture_break"]:
		return false
	if not attack.is_empty():
		return false
	if not enemy and type == "light":
		for foe in get_tree().get_nodes_in_group("fighters"):
			if foe.enemy and foe.state == "posture_break" and global_position.distance_to(foe.global_position) <= 40:
				type = "rupture"
	var cost: float = (15 if kind == "ren" and Save.has_upgrade("l3") else 18) if type == "heavy" else (0 if type == "rupture" else 8)
	if not enemy and not spend(cost):
		return false
	sword_drawn = true
	if type == "light":
		combo = combo % 3 + 1
	else:
		combo = 0
	var windup := 0.32 if type == "heavy" else 0.14
	var recovery := 0.38 if type == "heavy" else 0.22
	var damage := 28.0 if type == "heavy" else 18.0
	var pressure := 22.0 if type == "heavy" else 12.0
	if type == "counter":
		windup = 0.09 if kind == "akio" else 0.12
		damage = 22
		pressure = 18 + (6 if kind == "ren" and Save.has_upgrade("l1") else 0)
		counter_window = 0
	if type == "rupture":
		damage = 36
		windup = 0.12
		pressure = 0
	if enemy:
		windup = 0.8 if type == "heavy" else 0.58
		recovery = 0.8 if type == "heavy" else 0.58
		damage = (24 if type == "heavy" else 16) if kind == "daigo" else (20 if type == "heavy" else 12)
		if kind == "daigo" and type == "retaliate":
			windup = 0.44
			pressure = 24
	attack = {"type": type, "windup": windup, "active": 0.1, "recovery": recovery,
		"damage": damage, "pressure": pressure, "reach": 62.0 if type == "heavy" else 48.0}
	attack_hit = false
	queued_light = false
	posture_delay = 1
	set_state("heavy_attack" if type == "heavy" else ("counter_attack" if type == "counter" else "light_attack_%d" % maxi(1, combo)))
	return true

func process_attack(delta: float) -> void:
	var type: String = attack.type
	velocity.x = facing * 130 if type == "counter" and state_time < 0.15 else move_toward(velocity.x, 0, braking * delta)
	var duration: float = attack.windup + attack.active + attack.recovery
	if not enemy and Input.is_action_just_pressed("light_attack") and type == "light" and combo < 3 and state_time >= duration - 0.15:
		queued_light = true
	if not attack_hit and state_time >= attack.windup:
		attack_hit = true
		strike()
	if state_time >= duration:
		var chain := queued_light
		attack = {}
		set_state("idle")
		if chain:
			start_attack("light")
		else:
			combo = 0

func strike() -> void:
	Sound.play("heavy" if attack.type == "heavy" else "slash")
	world.combat_fx.burst("heavy_slash" if attack.type == "heavy" else "slash",global_position+Vector2(facing*12,-30),facing)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(attack.reach, 40)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, global_position + Vector2(facing * (float(attack.reach)/2+8), -24))
	query.collision_mask = 4
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.exclude = [hurtbox.get_rid()]
	for result in get_world_2d().direct_space_state.intersect_shape(query):
		var target = result.collider.get_parent()
		if target.enemy == enemy or target.hp <= 0:
			continue
		var ray := PhysicsRayQueryParameters2D.create(global_position+Vector2(0,-24), target.global_position+Vector2(0,-24), 1)
		if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
			continue
		target.receive_hit(self, attack.damage, attack.pressure, attack.type == "heavy", attack.type == "rupture")

func receive_hit(source, damage: float, pressure: float, heavy: bool = false, rupture: bool = false) -> String:
	if hp <= 0 or world.locked or invulnerable > 0 or (state == "dodge" and state_time >= 0.06 and state_time <= 0.14):
		return "immune"
	var front: bool = (source.global_position.x - global_position.x) * facing >= -3
	if front and state == "parry_window" and state_time <= active_parry_window():
		production_visual.confirm_parry(elapsed)
		counter_window = 0.35
		posture = minf(max_posture, posture + 12)
		if kind == "ren" and Save.has_upgrade("l2"):
			stamina_delay = 0
			parry_regen_bonus = 1.0
		source.damage_posture(26 if kind == "akio" else 20)
		if source.state != "posture_break":
			source.set_state("hurt")
			source.ai_cooldown = 0.55
		feedback.emit("parry", global_position + Vector2(facing*18,-30))
		return "parry"
	if front and state in ["guard_hold", "guard_start", "parry_window", "parry"] and not rupture:
		if not enemy:
			if not spend(16 if heavy else 8):
				stamina = 0
				damage_posture(max_posture)
		damage_posture(32 if heavy else 20)
		feedback.emit("guard", global_position + Vector2(facing*18,-30))
		if kind == "daigo" and state != "posture_break":
			set_state("idle")
			start_attack("retaliate")
		return "guard"
	if not enemy and Save.settings.damage_assist:
		damage *= 0.85
	hp = maxf(0, hp - damage)
	if not enemy:
		Sound.play("hurt")
	feedback.emit("impact", global_position + Vector2(0,-25))
	if source.kind == "daigo" and heavy:
		Sound.play("boss_impact")
	if hp <= 0:
		die()
		return "defeat"
	if rupture:
		posture = max_posture
		set_state("hurt")
	else:
		var already_broken := state == "posture_break"
		if not already_broken:
			set_state("hurt")
			damage_posture(pressure)
	velocity.x = signf(global_position.x - source.global_position.x) * 70
	invulnerable = 0.08 if enemy else 0.5
	return "hit"

func damage_posture(amount: float) -> void:
	posture_delay = 1
	posture = maxf(0, posture - amount)
	if posture <= 0 and hp > 0:
		set_state("posture_break")
		feedback.emit("break", global_position + Vector2(0,-30))

func die() -> void:
	Sound.play("boss_defeat" if kind == "daigo" else "death")
	set_state("death")
	velocity = Vector2.ZERO
	hurtbox.set_deferred("monitorable", false)
	defeated.emit(self)

func process_enemy(delta: float) -> void:
	var player = world.player
	if not is_instance_valid(player) or player.hp <= 0:
		return
	var distance: float = absf(player.position.x-position.x)
	if distance > 290:
		state = "patrol"
		velocity.x = sin(elapsed * 0.6) * 18
		return
	facing = signf(player.position.x-position.x)
	if facing == 0:
		facing = 1
	if state == "guard_hold":
		velocity.x = 0
		if state_time > 0.65:
			set_state("idle")
		return
	if distance > 49:
		state = "approach"
		velocity.x = move_toward(velocity.x, facing * (52 if kind == "daigo" else 65), acceleration * delta)
	elif ai_cooldown <= 0 and world.can_enemy_attack(self):
		velocity.x = 0
		ai_cycle += 1
		if (kind == "daigo" or defender) and ai_cycle % 3 == 0:
			set_state("guard_hold")
			ai_cooldown = 0.75
		else:
			start_attack("heavy" if kind == "daigo" and ai_cycle % 2 == 0 else "light")
			ai_cooldown = 1.0
	else:
		velocity.x = move_toward(velocity.x, 0, braking*delta)
		state = "idle"

func update_visual() -> void:
	if sprite == null:
		return
	if production_visual != null and production_visual.update(self):
		return
	var frame := 0
	if state in ["walk", "run", "patrol", "approach", "dodge"]:
		frame = 1
	elif state in ["jump", "jump_start", "fall"]:
		frame = 2
	elif not attack.is_empty():
		frame = 4 if attack.type == "heavy" else 3
	elif state in ["guard_start", "guard_hold", "parry_window", "parry"]:
		frame = 5
	elif state in ["hurt", "posture_break"]:
		frame = 6
	elif state == "death":
		frame = 7
	sprite.frame = frame
	sprite.flip_h = facing < 0
	sprite.position.y = -32 + (roundf(sin(elapsed*16)) if frame == 1 else 0)
	sprite.modulate = Color(0.8,0.91,1) if world.memory else Color.WHITE
	if invulnerable > 0 and not enemy:
		sprite.modulate.a = 0.65 if fmod(elapsed,0.12) < 0.06 else 1
	if state == "death" and kind == "daigo":
		sprite.position.y = -23
		sprite.rotation = -0.15

func _draw() -> void:
	draw_set_transform(Vector2(0,-1), 0, Vector2(1,0.23))
	draw_circle(Vector2.ZERO, 17, Color(0.015,0.025,0.04,0.5))
	draw_set_transform(Vector2.ZERO)
	if enemy and hp > 0 and world != null and is_instance_valid(world.player) and absf(position.x-world.player.position.x) < 250:
		draw_texture_rect(preload("res://assets/ui/production/enemy_posture.png"),Rect2(-21,-66,42,5),false)
		draw_rect(Rect2(-20,-65,40*posture/max_posture,3),Color("d9b66f"))
		if not attack.is_empty() and state_time < float(attack.windup):
			var progress: float = state_time / float(attack.windup)
			draw_arc(Vector2(0,-74),5,-PI/2,-PI/2+TAU*progress,16,Color("f4ce8c"),2)
	if world != null and world.debug_mode:
		draw_rect(Rect2(-8,-42,16,42),Color(0,1,0,0.7),false)
		if not attack.is_empty():
			draw_rect(Rect2(8 if facing>0 else -float(attack.reach)-8,-44,attack.reach,40),Color(1,0,0,0.6),false)
		draw_string(ThemeDB.fallback_font,Vector2(-30,-85),"%s %d/%d/%d" % [state,hp,stamina,posture],HORIZONTAL_ALIGNMENT_LEFT,-1,9)
