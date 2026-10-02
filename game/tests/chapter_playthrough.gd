extends SceneTree

func _initialize() -> void:
	call_deferred("run_probe")

func run_probe() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.start_game(true)
	await clear_dialogue(main)
	var world = main.world
	if not await walk_to(world, 900.0, [330.0, 570.0]):
		return fail_test("arrival traversal")
	await use_interact()
	await wait_transition()
	if world.zone != 1:
		return fail_test("arrival exit")
	for actor in world.actors:
		if not await beat(world, actor, main):
			return fail_test("tutorial enemy at %s" % actor.start_x)
	print("PLAYTHROUGH: tutorial clear hp=%s cures=%s" % [world.player.hp,world.player.cures])
	if not await walk_to(world, 1510.0, []):
		return fail_test("tutorial exit traversal")
	await use_interact()
	await wait_transition()
	if world.zone != 2:
		return fail_test("tutorial exit")
	if not await walk_to(world, 350.0, []):
		return fail_test("Echo threshold traversal")
	await use_interact()
	await wait_transition()
	await clear_dialogue(main)
	if not world.memory or world.player.kind != "akio":
		return fail_test("Akio transition")
	for actor in world.actors:
		if not await beat(world, actor, main):
			return fail_test("Akio memory enemy")
	if not await walk_to(world, 925.0, []):
		return fail_test("memory bridge traversal")
	await use_interact()
	await wait_transition()
	await clear_dialogue(main)
	if world.memory or world.zone != 3 or world.player.kind != "ren":
		return fail_test("Ren return")
	for actor in world.actors:
		if not await beat(world, actor, main):
			return fail_test("post-Echo enemy at %s" % actor.start_x)
	if not await walk_to(world, 1190.0, []):
		return fail_test("Daigo approach")
	await use_interact()
	await wait_transition()
	await clear_dialogue(main)
	if world.zone != 4 or not world.boss_started:
		return fail_test("Daigo intro")
	if not await beat(world, world.actors[0], main):
		return fail_test("Daigo duel")
	await clear_dialogue(main)
	if main.screen != "complete":
		return fail_test("Chapter I ending")
	print("PLAYTHROUGH PASS: full Chapter I traversal, attack inputs, Echo/Akio, Daigo and ending; hp=%s cures=%s" % [world.player.hp,world.player.cures])
	quit(0)

func beat(world, actor, main) -> bool:
	var held_guard := 0
	var held_attack := 0
	var jumped := {}
	var jump_hold := 0
	for i in range(1800):
		if actor.hp <= 0:
			Input.action_release("move_left")
			Input.action_release("move_right")
			Input.action_release("guard")
			Input.action_release("heavy_attack")
			Input.action_release("jump")
			return true
		if main.screen == "death":
			print("PLAYTHROUGH DEATH: enemy=%s hp=%s x=%s enemyhp=%s" % [actor.start_x,world.player.hp,world.player.position.x,actor.hp])
			return false
		var ren = world.player
		var dx: float = actor.position.x-ren.position.x
		if absf(dx)>43 and ren.attack.is_empty():
			Input.action_press("move_right" if dx>0 else "move_left")
			Input.action_release("move_left" if dx>0 else "move_right")
		else:
			Input.action_release("move_left")
			Input.action_release("move_right")
		ren.facing = signf(dx)
		var released_attack := false
		if held_attack > 0:
			held_attack -= 1
			if held_attack == 0:
				Input.action_release("heavy_attack")
				released_attack = true
		if jump_hold>0:
			jump_hold-=1
			if jump_hold==0:
				Input.action_release("jump")
		elif world.zone==1 and dx>0:
			for point in [930.0,975.0,1050.0]:
				if not jumped.has(point) and ren.position.x>=point and ren.is_on_floor():
					jumped[point]=true
					Input.action_press("jump")
					jump_hold=5
					break
		if held_guard>0:
			held_guard-=1
			if held_guard==0:
				Input.action_release("guard")
		elif not actor.attack.is_empty() and ren.attack.is_empty() and actor.state_time >= float(actor.attack.windup)-0.12 and actor.state_time < float(actor.attack.windup)-0.08:
			Input.action_press("guard")
			held_guard=12
		elif absf(dx)<58 and ren.attack.is_empty() and ren.state in ["idle","walk","run","guard_release"] and ren.stamina>=18 and held_attack==0 and not released_attack:
			Input.action_press("heavy_attack")
			held_attack = 2
		if ren.hp<35 and ren.cures>0 and ren.attack.is_empty() and ren.state in ["idle","walk","run"]:
			Input.action_press("heal")
		else:
			Input.action_release("heal")
		await physics_frame
	print("PLAYTHROUGH STALL: enemy=%s hp=%s x=%s enemyhp=%s state=%s" % [actor.start_x,world.player.hp,world.player.position.x,actor.hp,world.player.state])
	return false

func walk_to(world, goal_x: float, jump_points: Array) -> bool:
	var jumped := {}
	var jump_hold := 0
	Input.action_press("move_right")
	Input.action_press("run")
	for i in range(1500):
		await physics_frame
		var x: float = world.player.position.x
		if x>=goal_x:
			Input.action_release("jump")
			Input.action_release("move_right")
			Input.action_release("run")
			return true
		if jump_hold>0:
			jump_hold-=1
			if jump_hold==0:
				Input.action_release("jump")
		else:
			for point in jump_points:
				if not jumped.has(point) and x>=point and world.player.is_on_floor():
					jumped[point]=true
					Input.action_press("jump")
					jump_hold=5
					break
	return false

func wait_transition() -> void:
	for i in range(35):
		await physics_frame

func use_interact() -> void:
	Input.action_press("interact")
	for i in range(3):
		await process_frame
	Input.action_release("interact")

func clear_dialogue(main) -> void:
	while main.screen == "dialogue":
		main.intro_block = 0.0
		main.advance_dialogue()
		await process_frame

func fail_test(reason: String) -> void:
	push_error("PLAYTHROUGH FAIL: " + reason)
	quit(1)
