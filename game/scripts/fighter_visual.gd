extends RefCounted
# Presentation samples SpriteFrames explicitly: combat remains the time authority.
var frames: SpriteFrames
var animation := ""
var time := 0.0
var last_elapsed := 0.0
var last_facing := 1.0
var turn_until := 0.0
var parry_until := -1.0

func confirm_parry(elapsed: float) -> void:
	parry_until = elapsed+0.16
	# Presentation only: do not restart the fighter's defense/counter clocks.
	animation = ""

func _init(kind: String) -> void:
	var folder := "enemies/human_base" if kind == "human" else "characters/" + kind
	var path := "res://assets/%s/%s_frames.tres" % [folder, kind]
	if ResourceLoader.exists(path):
		frames = load(path)

func update(fighter) -> bool:
	if frames == null:
		return false
	var next: String = fighter.state
	var delta: float = maxf(0, fighter.elapsed-last_elapsed)
	last_elapsed = fighter.elapsed
	if fighter.facing != last_facing and fighter.attack.is_empty():
		turn_until = fighter.elapsed + 0.09
	last_facing = fighter.facing
	if next in ["patrol", "approach"]:
		next = "walk" if next == "patrol" else "approach"
	if next in ["guard_hold", "guard_release"]:
		next = "guard"
	elif next == "parry_window":
		next = "guard_start"
	if fighter.elapsed < parry_until and next in ["guard_start","guard","idle","walk"] and frames.has_animation("parry"):
		next = "parry"
	if fighter.kind == "daigo":
		if next == "death": next = "defeat"
		elif not fighter.attack.is_empty() and fighter.attack.type in ["retaliate", "counter"]: next = "counter"
		elif next.begins_with("light_attack"): next = "attack_1" if fighter.ai_cycle % 4 == 1 else "attack_2"
	if fighter.kind == "human" and not fighter.attack.is_empty():
		next = "attack"
	if next == "idle" and not fighter.sword_drawn and frames.has_animation("idle_sheathed"):
		next = "idle_sheathed"
	if next in ["walk", "run", "idle"] and fighter.elapsed < turn_until and frames.has_animation("turn"):
		next = "turn"
	if not frames.has_animation(next):
		next = "walk" if next == "approach" else "idle"
	if next != animation:
		animation = next
		time = 0.0
	else:
		time += delta
	var count := frames.get_frame_count(animation)
	var index := int(time * frames.get_animation_speed(animation))
	if not fighter.attack.is_empty():
		# First third anticipates, middle third contacts, final third recovers.
		var attack: Dictionary = fighter.attack
		var third := maxi(1, count/3)
		if fighter.state_time < attack.windup:
			index = mini(third-1, int(fighter.state_time/attack.windup*third))
		elif fighter.state_time < attack.windup+attack.active:
			index = third + mini(third-1,int((fighter.state_time-attack.windup)/attack.active*third))
		else:
			index = third*2 + int((fighter.state_time-attack.windup-attack.active)/attack.recovery*(count-third*2))
	elif frames.get_animation_loop(animation):
		index %= count
	index = clampi(index,0,count-1)
	fighter.sprite.hframes = 1
	fighter.sprite.texture = frames.get_frame_texture(animation,index)
	fighter.sprite.position = Vector2(0,-32)
	fighter.sprite.rotation = 0
	fighter.sprite.flip_h = fighter.facing < 0
	fighter.sprite.modulate = Color.WHITE
	if fighter.invulnerable > 0 and not fighter.enemy:
		fighter.sprite.modulate.a = 0.65 if fmod(fighter.elapsed,0.12)<0.06 else 1
	return true
