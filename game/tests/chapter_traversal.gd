extends SceneTree

func _initialize() -> void:
	call_deferred("run_traversal")

func run_traversal() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.start_game(true)
	await clear_dialogue(main)
	var world = main.world
	if not await walk_to(world, 900.0, [330.0, 570.0]):
		fail_test("Ren could not cross the arrival path")
		return
	world.interact()
	await wait_transition()
	if world.zone != 1:
		fail_test("arrival exit did not open")
		return
	for actor in world.actors:
		actor.hp = 0
		actor.die()
	if not await walk_to(world, 1510.0, [930.0, 1050.0]):
		fail_test("Ren could not cross the tutorial terrain")
		return
	world.interact()
	await wait_transition()
	if world.zone != 2:
		fail_test("tutorial exit did not open")
		return
	if not await walk_to(world, 350.0, []):
		fail_test("Ren could not reach the Echo threshold")
		return
	world.interact()
	await wait_transition()
	await clear_dialogue(main)
	if not world.memory or world.player.kind != "akio":
		fail_test("Echo did not switch to Akio")
		return
	for actor in world.actors:
		actor.hp = 0
		actor.die()
	if not await walk_to(world, 925.0, []):
		fail_test("Akio could not cross the remembered bridge")
		return
	world.interact()
	await wait_transition()
	await clear_dialogue(main)
	if world.zone != 3 or world.player.kind != "ren":
		fail_test("Echo did not return to Ren")
		return
	for actor in world.actors:
		actor.hp = 0
		actor.die()
	if not await walk_to(world, 1190.0, []):
		fail_test("Ren could not reach Daigo's shelter")
		return
	world.interact()
	await wait_transition()
	await clear_dialogue(main)
	if world.zone != 4 or not world.boss_started:
		fail_test("Daigo encounter did not start")
		return
	world.actors[0].hp = 0
	world.actors[0].die()
	await clear_dialogue(main)
	if main.screen != "complete":
		fail_test("Chapter I ending did not appear")
		return
	print("TRAVERSAL PASS: Ren and Akio moved across every Chapter I area without position teleport")
	main.queue_free()
	await process_frame
	quit(0)

func walk_to(world, goal_x: float, jump_points: Array) -> bool:
	var jumped := {}
	var jump_hold := 0
	var last_x: float = world.player.position.x
	var stagnant := 0
	Input.action_press("move_right")
	Input.action_press("run")
	for i in range(1500):
		await physics_frame
		var x: float = world.player.position.x
		if x >= goal_x:
			Input.action_release("jump")
			Input.action_release("move_right")
			Input.action_release("run")
			return true
		if jump_hold > 0:
			jump_hold -= 1
			if jump_hold == 0:
				Input.action_release("jump")
		else:
			for point in jump_points:
				if not jumped.has(point) and x >= point and world.player.is_on_floor():
					jumped[point] = true
					Input.action_press("jump")
					jump_hold = 5
					break
		if x > last_x + 0.1:
			stagnant = 0
		else:
			stagnant += 1
		if stagnant > 150:
			break
		last_x = x
	Input.action_release("jump")
	Input.action_release("move_right")
	Input.action_release("run")
	print("TRAVERSAL STOP: zone=%s memory=%s x=%s goal=%s state=%s" % [world.zone, world.memory, world.player.position.x, goal_x, world.player.state])
	return false

func wait_transition() -> void:
	for i in range(35):
		await physics_frame

func clear_dialogue(main) -> void:
	while main.screen == "dialogue":
		main.intro_block = 0.0
		main.advance_dialogue()
		await process_frame

func fail_test(reason: String) -> void:
	push_error("TRAVERSAL FAIL: " + reason)
	quit(1)
