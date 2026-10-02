extends SceneTree

func _initialize() -> void:
	call_deferred("run_menu")

func run_menu() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.start_game(true)
	while main.screen == "dialogue":
		main.intro_block = 0.0
		main.advance_dialogue()
		await process_frame
	main.show_pause()
	if main.screen != "pause" or not paused:
		fail_test("pause menu did not pause the game")
		return
	main.show_settings("pause")
	if main.screen != "settings" or main.overlay.find_children("*", "CheckButton", true, false).size() < 5:
		fail_test("settings menu did not open")
		return
	main.show_controls("pause")
	var jump_button: Button
	for candidate in main.overlay.find_children("*", "Button", true, false):
		if candidate.text.begins_with("Salto"):
			jump_button = candidate
			break
	if jump_button == null:
		fail_test("Jump remapping button was not shown")
		return
	jump_button.pressed.emit()
	if main.rebind_action != "jump":
		fail_test("Jump remapping button did not arm the action")
		return
	var key := InputEventKey.new()
	key.physical_keycode = KEY_J
	key.pressed = true
	main._input(key)
	if main.screen != "controls_conflict":
		fail_test("duplicate key did not ask for swap or cancel")
		return
	if root.get_node("Save").settings.keys.has("jump"):
		fail_test("duplicate key changed the binding before confirmation")
		return
	main.confirm_rebind_swap()
	var input_config = load("res://scripts/input_config.gd")
	if input_config.prompt("jump") != "J" or input_config.prompt("light_attack") != "Space":
		fail_test("confirmed swap did not exchange Jump and Light keys")
		return
	main.rebind_action = "jump"
	key.physical_keycode = KEY_K
	main._input(key)
	if main.screen != "controls_conflict":
		fail_test("second conflicting key was not detected")
		return
	main.cancel_rebind_swap()
	if input_config.prompt("jump") != "J" or input_config.prompt("heavy_attack") != "K":
		fail_test("cancel changed a key binding")
		return
	main.rebind_action = "jump"
	key.physical_keycode = KEY_Q
	main._input(key)
	if input_config.prompt("jump") != "Q" or main.screen != "controls":
		fail_test("unused key was not assigned to Jump")
		return
	main.rebind_action = "heavy_attack"
	main.return_to("pause")
	if not main.rebind_action.is_empty():
		fail_test("leaving Controls kept a key rebinding armed")
		return
	main.resume()
	if paused or main.screen != "game":
		fail_test("resume did not return to gameplay")
		return
	key.physical_keycode = KEY_P
	main._input(key)
	if input_config.prompt("heavy_attack") != "K" or main.screen != "game":
		fail_test("gameplay key was captured by abandoned remapping")
		return
	main.show_pause()
	main.show_controls("pause")
	main.rebind_action = "pause"
	key.physical_keycode = KEY_P
	key.keycode = KEY_P
	main._input(key)
	if input_config.prompt("pause") != "P":
		fail_test("Pause could not be remapped away from Escape")
		return
	main.rebind_action = "jump"
	key.physical_keycode = KEY_K
	key.keycode = KEY_K
	main._input(key)
	if main.screen != "controls_conflict":
		fail_test("conflict was not shown after Pause remap")
		return
	key.physical_keycode = KEY_ESCAPE
	key.keycode = KEY_ESCAPE
	main._input(key)
	if main.screen != "controls" or input_config.prompt("jump") != "Q":
		fail_test("Escape did not cancel conflict after Pause remap")
		return
	main.rebind_action = "jump"
	main._input(key)
	if main.screen != "controls" or not main.rebind_action.is_empty():
		fail_test("Escape did not cancel an armed remap")
		return
	print("MENU PASS: pause, settings, remap button, swap/cancel, free key, abandoned remap, Escape after Pause remap, resume")
	main.queue_free()
	await process_frame
	quit(0)

func fail_test(reason: String) -> void:
	push_error("MENU FAIL: " + reason)
	quit(1)
