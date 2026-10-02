extends SceneTree

func _initialize() -> void:
	call_deferred("run_progression")

func run_progression() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.start_game(true)
	while main.screen == "dialogue":
		main.intro_block = 0.0
		main.advance_dialogue()
		await process_frame
	var save = root.get_node("Save")
	var ren = main.world.player
	save.progress.marks = 1
	ren.position.x = main.world.checkpoint_x()
	main.world.interact()
	main.show_pause()
	main.show_progression("pause")
	if main.screen != "progression" or progression_button(main, "E1").disabled == false:
		fail_test("Progression screen or Chapter IV lock is missing")
		return
	progression_button(main, "L1").pressed.emit()
	if not save.has_upgrade("l1") or save.available_marks() != 0:
		fail_test("L1 was not applied with the one available mark")
		return
	main.resume()
	if not ren.start_attack("counter") or ren.attack.pressure != 24:
		fail_test("L1 did not add six posture to Ren's counter")
		return
	ren.attack = {}
	ren.set_state("idle")
	main.show_pause()
	main.show_progression("pause")
	progression_button(main, "L1").pressed.emit()
	if save.has_upgrade("l1") or save.available_marks() != 1:
		fail_test("Removing L1 did not refund its mark")
		return
	progression_button(main, "L2").pressed.emit()
	main.resume()
	ren.stamina = 50
	ren.stamina_delay = 0.6
	ren.set_state("parry_window")
	var source = load("res://scripts/fighter.gd").new()
	source.world = main.world
	source.enemy = true
	source.position = ren.position + Vector2(30, 0)
	main.world.cast.add_child(source)
	ren.facing = 1
	if ren.receive_hit(source, 12, 10) != "parry" or ren.stamina_delay != 0 or ren.parry_regen_bonus <= 0:
		fail_test("L2 did not start enhanced stamina regeneration after parry")
		return
	var stamina_after_parry: float = ren.stamina
	main.world.hitstop = 0
	Input.action_press("guard")
	await physics_frame
	await physics_frame
	Input.action_release("guard")
	if ren.stamina <= stamina_after_parry or ren.state != "parry_window":
		fail_test("L2 did not regenerate stamina immediately during the held parry window")
		return
	main.show_pause()
	main.show_progression("pause")
	progression_button(main, "L2").pressed.emit()
	progression_button(main, "L3").pressed.emit()
	main.resume()
	ren.set_state("idle")
	ren.attack = {}
	ren.stamina = 100
	if not ren.start_attack("heavy") or ren.stamina != 85:
		fail_test("L3 did not reduce heavy attack cost from 18 to 15")
		return
	main.show_pause()
	ren.position.x = 350
	main.show_progression("pause")
	if not progression_button(main, "L3").disabled or save.set_upgrade("e1", true):
		fail_test("Progression changed away from a safe point or unlocked E1")
		return
	print("PROGRESSION PASS: safe-point cards, L1/L2/L3 effects, refund, E1 lock, read-only outside rest")
	main.queue_free()
	await process_frame
	quit(0)

func progression_button(main, prefix: String) -> Button:
	for candidate in main.overlay.find_children("*", "Button", true, false):
		if candidate.text.begins_with(prefix):
			return candidate
	return null

func fail_test(reason: String) -> void:
	push_error("PROGRESSION FAIL: " + reason)
	quit(1)
