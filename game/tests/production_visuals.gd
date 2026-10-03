extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		quit(1)
		assert(ok, message)

func run() -> void:
	var path := "res://assets/characters/ren/ren_frames.tres"
	check(ResourceLoader.exists(path), "Ren production SpriteFrames must exist")
	var frames: SpriteFrames = load(path)
	for animation in ["idle", "walk", "run", "jump_start", "jump", "fall", "land", "turn", "dodge", "draw_sword", "sheathe_sword", "light_attack_1", "light_attack_2", "light_attack_3", "heavy_attack", "guard_start", "guard", "parry", "counter_attack", "hurt", "posture_break", "heal", "death", "interact", "echo_interact"]:
		check(frames.has_animation(animation), "Missing animation: " + animation)
		check(frames.get_frame_count(animation) >= 2, "At least two authored poses: " + animation)
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
	print("PRODUCTION VISUALS PASS: Ren animation coverage, advancement, phases, pivot and flip")
	main.free()
	await process_frame
	quit(0)
