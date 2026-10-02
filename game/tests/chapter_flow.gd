extends SceneTree

func _initialize() -> void:
	call_deferred("run_flow")

func run_flow() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.start_game(true)
	await clear_dialogue(main)
	var world = main.world
	var progress: Dictionary = root.get_node("Save").progress
	if world.zone != 0 or world.player.kind != "ren":
		fail_test("new campaign did not start in C101 with Ren")
		return
	world.player.position.x = 900
	world.interact()
	await wait_transition()
	if world.zone != 1:
		fail_test("C101 gate did not lead to the tutorial combat area")
		return
	world.player.position.x = 1520
	world.interact()
	if world.zone != 1:
		fail_test("tutorial gate opened while enemies were alive")
		return
	for actor in world.actors:
		actor.hp = 0
		actor.die()
	world.interact()
	await wait_transition()
	if world.zone != 2:
		fail_test("tutorial gate did not lead to the broken bridge")
		return
	world.player.position.x = 180
	world.interact()
	if progress.get("checkpoint", -1) != 2:
		fail_test("broken bridge checkpoint was not saved")
		return
	world.player.hp = 63
	world.player.cures = 1
	world.player.position.x = 350
	world.interact()
	await wait_transition()
	await clear_dialogue(main)
	if not world.memory or world.player.kind != "akio":
		fail_test("bridge Echo did not hand control to Akio")
		return
	world.player.hp = 0
	world.player.die()
	if main.screen != "death":
		fail_test("Akio failure did not open memory retry")
		return
	world.respawn()
	main.clear_overlay()
	main.screen = "game"
	await physics_frame
	if not world.memory or world.player.kind != "akio" or world.player.hp <= 0:
		fail_test("memory retry did not restart Akio")
		return
	world.player.position.x = 925
	world.interact()
	if not world.memory:
		fail_test("Akio crossed before the opponent was defeated")
		return
	for actor in world.actors:
		actor.hp = 0
		actor.die()
	world.interact()
	await wait_transition()
	await clear_dialogue(main)
	if world.zone != 3 or world.memory or world.player.kind != "ren":
		fail_test("Echo exit did not return to present-day Ren")
		return
	if world.player.hp != 63 or world.player.cures != 1 or not progress.get("echo_done", false):
		fail_test("Echo exit changed Ren resources or did not record memory")
		return
	world.player.position.x = 1200
	for actor in world.actors:
		actor.hp = 0
		actor.die()
	world.interact()
	await wait_transition()
	await clear_dialogue(main)
	if world.zone != 4 or not world.boss_started:
		fail_test("Daigo arena and introduction did not open")
		return
	world.player.hp = 0
	world.player.die()
	if main.screen != "death":
		fail_test("Daigo defeat did not open respawn")
		return
	world.respawn()
	main.clear_overlay()
	main.screen = "game"
	await physics_frame
	if world.zone != 3 or world.player.hp <= 0:
		fail_test("Daigo retry did not return to CP3")
		return
	world.player.position.x = 1200
	for actor in world.actors:
		actor.hp = 0
		actor.die()
	world.interact()
	await wait_transition()
	if world.zone != 4 or not world.boss_started or main.screen == "dialogue":
		fail_test("Daigo retry repeated the first conversation")
		return
	world.actors[0].hp = 0
	world.actors[0].die()
	await clear_dialogue(main)
	if main.screen != "complete" or not progress.get("complete", false):
		fail_test("Daigo defeat did not show Chapter I ending")
		return
	if not progress.get("chapter1_mark_awarded", false) or progress.get("marks", 0) != 1:
		fail_test("Chapter I mark was not recorded")
		return
	world.finish_chapter()
	if progress.get("marks", 0) != 1:
		fail_test("Chapter I mark was duplicated on repeated completion")
		return
	var save = root.get_node("Save")
	save.progress = {"version": 1, "checkpoint": 3, "complete": true, "daigo_defeated": true}
	world.begin(false)
	if save.progress.get("marks", 0) != 1 or not save.progress.get("chapter1_mark_awarded", false):
		fail_test("completed legacy v1 save did not receive its Chapter I mark")
		return
	world.begin(false)
	if save.progress.get("marks", 0) != 1:
		fail_test("completed legacy v1 save received a duplicate mark")
		return
	print("FLOW PASS: area gates, enemy locks, checkpoints, Echo/Akio retry, Ren return, Daigo retry, Chapter I ending, legacy mark")
	main.queue_free()
	await process_frame
	quit(0)

func wait_transition() -> void:
	for i in range(35):
		await physics_frame

func clear_dialogue(main) -> void:
	while main.screen == "dialogue":
		main.intro_block = 0.0
		main.advance_dialogue()
		await process_frame

func fail_test(reason: String) -> void:
	push_error("FLOW FAIL: " + reason)
	quit(1)
