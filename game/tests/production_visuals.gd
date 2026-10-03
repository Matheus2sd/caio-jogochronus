extends SceneTree
var failed := false

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		push_error(message)

func run() -> void:
	var path := "res://assets/characters/ren/ren_frames.tres"
	check(ResourceLoader.exists(path), "Ren production SpriteFrames must exist")
	var frames: SpriteFrames = load(path)
	for animation in ["idle", "walk", "run", "jump_start", "jump", "fall", "land", "turn", "dodge", "draw_sword", "sheathe_sword", "light_attack_1", "light_attack_2", "light_attack_3", "heavy_attack", "guard_start", "guard", "parry", "counter_attack", "hurt", "posture_break", "heal", "death", "interact", "echo_interact"]:
		check(frames.has_animation(animation), "Missing animation: " + animation)
		check(frames.get_frame_count(animation) >= 2, "At least two authored poses: " + animation)
	var akio: SpriteFrames = load("res://assets/characters/akio/akio_frames.tres")
	for animation in frames.get_animation_names():
		check(akio.has_animation(animation), "Akio playable coverage: " + animation)
		check(akio.get_frame_count(animation)>=2, "Akio pose sequence: " + animation)
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.start_game(true)
	while main.screen == "dialogue":
		main.intro_block = 0.0
		main.advance_dialogue()
	var player = main.world.player
	player.test_control = true
	player.set_state("run")
	player.update_visual()
	var first = player.sprite.texture
	for i in range(10):
		await physics_frame
	check(player.sprite.texture != first, "Run must advance drawn poses")
	player.start_attack("heavy")
	player.state_time = 0.01
	player.update_visual()
	var preparation = player.sprite.texture
	player.state_time = player.attack.windup + 0.02
	player.update_visual()
	check(player.sprite.texture != preparation, "Contact must differ from preparation")
	check(player.sprite.position == Vector2(0,-32), "Feet pivot must remain fixed")
	player.facing = -1
	player.update_visual()
	check(player.sprite.flip_h, "Left facing must mirror the visual")
	main.world.load_zone(2,true)
	player = main.world.player
	player.start_attack("counter")
	player.state_time = 0.01
	player.update_visual()
	preparation = player.sprite.texture
	player.state_time = player.attack.windup+0.01
	player.update_visual()
	check(player.production_visual.frames == akio, "Memory must use Akio's own drawings")
	check(player.sprite.texture != preparation, "Akio response must reach its own contact pose")
	check(player.sprite.position == Vector2(0,-32), "Akio feet pivot must remain fixed")
	main.world.load_zone(4)
	var boss = main.world.actors[0]
	var daigo: SpriteFrames = boss.production_visual.frames
	for clip in ["idle","walk","guard","attack_1","attack_2","heavy_attack","counter","push","hurt","posture_break","defeat"]:
		check(daigo.has_animation(clip), "Daigo production coverage: " + clip)
	boss.hp = 0
	boss.die()
	check(main.world.locked, "Daigo dialogue locks combat")
	for i in range(50):
		await physics_frame
	check(boss.production_visual.animation == "defeat", "Locked dialogue must still show Daigo defeated alive")
	check(boss.sprite.texture == daigo.get_frame_texture("defeat",2), "Defeat must settle on living kneeling pose")
	if not failed:
		print("PRODUCTION VISUALS PASS: character coverage, motion/contact, pivots and living Daigo defeat")
	main.free()
	await process_frame
	quit(1 if failed else 0)
