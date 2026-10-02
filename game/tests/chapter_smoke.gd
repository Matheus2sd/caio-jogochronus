extends SceneTree

func _initialize() -> void:
	call_deferred("run_smoke")

func run_smoke() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	if main.screen != "menu":
		fail_test("main menu did not open")
		return
	main.start_game(true)
	await process_frame
	if not is_instance_valid(main.world) or not is_instance_valid(main.world.player):
		fail_test("new game did not create Ren")
		return
	var ren = main.world.player
	if ren.kind != "ren" or ren.sprite.texture == null or ren.sprite.texture.get_width() == 0:
		fail_test("Ren sprite was not loaded")
		return
	main.intro_block = 0.0
	main.advance_dialogue()
	main.intro_block = 0.0
	main.advance_dialogue()
	await physics_frame
	var start_x: float = ren.position.x
	Input.action_press("move_right")
	for i in range(15):
		await physics_frame
	Input.action_release("move_right")
	if ren.position.x <= start_x + 3.0:
		fail_test("Ren did not respond to movement input")
		return
	var world = main.world
	var jump_y: float = ren.position.y
	Input.action_press("jump")
	for i in range(6):
		await physics_frame
	Input.action_release("jump")
	if ren.position.y >= jump_y - 5.0:
		fail_test("Ren did not jump")
		return
	for i in range(50):
		await physics_frame
	var stamina_before: float = ren.stamina
	Input.action_press("dodge")
	await physics_frame
	await physics_frame
	Input.action_release("dodge")
	if ren.state != "dodge" or ren.stamina >= stamina_before:
		fail_test("dodge did not activate or spend stamina")
		return
	world.load_zone(1)
	await physics_frame
	ren = world.player
	var enemy = world.actors[0]
	ren.position.x = enemy.position.x - 45
	ren.facing = 1
	var enemy_hp: float = enemy.hp
	if not ren.start_attack("light"):
		fail_test("Ren could not start a light attack")
		return
	for i in range(12):
		await physics_frame
	if enemy.hp >= enemy_hp:
		fail_test("light attack did not damage the enemy")
		return
	ren.attack = {}
	ren.set_state("parry_window")
	ren.facing = 1
	enemy.position.x = ren.position.x + 35
	enemy.set_state("idle")
	var enemy_posture: float = enemy.posture
	if ren.receive_hit(enemy, 15, 10) != "parry" or enemy.posture >= enemy_posture:
		fail_test("parry did not protect Ren and reduce enemy posture")
		return
	ren.set_state("guard_hold")
	ren.invulnerable = 0
	var guarded_hp: float = ren.hp
	var guarded_stamina: float = ren.stamina
	if ren.receive_hit(enemy, 15, 10) != "guard" or ren.hp != guarded_hp or ren.stamina >= guarded_stamina:
		fail_test("guard did not preserve life and spend stamina")
		return
	ren.posture = 10
	ren.set_state("guard_hold")
	ren.receive_hit(enemy, 15, 10, true)
	if ren.state != "posture_break":
		fail_test("posture did not break under heavy guard pressure")
		return
	ren.hp = 1
	ren.invulnerable = 0
	ren.set_state("idle")
	if ren.receive_hit(enemy, 100, 10) != "defeat" or main.screen != "death":
		fail_test("death did not open the respawn menu")
		return
	world.respawn()
	await physics_frame
	if world.zone != 0 or world.player.hp <= 0:
		fail_test("respawn did not restore the last checkpoint")
		return
	main.clear_overlay()
	main.screen = "game"
	for i in range(4):
		await physics_frame
	world.player.hp = 40
	Input.action_press("heal")
	await physics_frame
	await physics_frame
	Input.action_release("heal")
	for i in range(65):
		await physics_frame
	if world.player.hp != 85 or world.player.cures != 1:
		fail_test("healing did not spend one charge and restore 45 life")
		return
	world.load_zone(2)
	await physics_frame
	world.player.hp = 67
	world.player.cures = 1
	world.player.position.x = 350
	world.interact()
	for i in range(30):
		await physics_frame
	if not world.memory or world.player.kind != "akio":
		fail_test("Echo did not enter playable Akio memory")
		return
	await clear_dialogue(main)
	world.actors[0].receive_hit(world.player, 999, 0)
	world.player.position.x = 925
	world.interact()
	for i in range(30):
		await physics_frame
	if world.memory or world.zone != 3 or world.player.kind != "ren":
		fail_test("Echo did not return control to Ren")
		return
	if world.player.hp != 67 or world.player.cures != 1:
		fail_test("Echo did not restore Ren resources")
		return
	await clear_dialogue(main)
	world.load_zone(4)
	await clear_dialogue(main)
	if not world.boss_started or world.actors[0].kind != "daigo":
		fail_test("Daigo encounter did not start")
		return
	world.actors[0].receive_hit(world.player, 999, 0)
	await clear_dialogue(main)
	if main.screen != "complete" or not root.get_node("Save").progress.get("complete", false):
		fail_test("Daigo defeat did not reach Chapter I ending")
		return
	print("SMOKE PASS: menu, Ren movement/jump/dodge, attack/guard/parry/posture/heal, death/respawn, Echo/Akio, Daigo, ending")
	var sound = root.get_node("Sound")
	for audio_player in sound.players:
		audio_player.stop()
		audio_player.stream = null
	sound.ambient.stop()
	sound.ambient.stream = null
	sound.music.stop()
	sound.music.stream = null
	main.queue_free()
	await process_frame
	quit(0)

func clear_dialogue(main) -> void:
	while main.screen == "dialogue":
		main.intro_block = 0.0
		main.advance_dialogue()
		await process_frame

func fail_test(reason: String) -> void:
	push_error("SMOKE FAIL: " + reason)
	quit(1)
