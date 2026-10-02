extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	for i in range(4):
		await process_frame
	var project_root := ProjectSettings.globalize_path("res://project.godot").get_base_dir().get_base_dir()
	var output_dir := project_root.path_join("tools/local")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var image := root.get_texture().get_image()
	if image.save_png(output_dir.path_join("menu-capture.png")) != OK:
		push_error("Could not capture main menu")
		quit(1)
		return
	main.start_game(true)
	while main.screen == "dialogue":
		main.intro_block = 0.0
		main.advance_dialogue()
		await process_frame
	for i in range(4):
		await process_frame
	image = root.get_texture().get_image()
	if image.save_png(output_dir.path_join("chapter-start-capture.png")) != OK:
		push_error("Could not capture chapter start")
		quit(1)
		return
	var sky_colors := {}
	for x in range(450, 900, 40):
		for y in range(10, 70, 20):
			sky_colors[image.get_pixel(x, y).to_html()] = true
	if sky_colors.size() < 5:
		push_error("Chapter start has a flat, uncovered strip above the background")
		quit(1)
		return
	root.get_node("Save").progress.marks = 1
	main.world.player.position.x = main.world.checkpoint_x()
	main.show_pause()
	main.show_progression("pause")
	for i in range(4):
		await process_frame
	image = root.get_texture().get_image()
	if image.save_png(output_dir.path_join("progression-capture.png")) != OK:
		push_error("Could not capture progression")
		quit(1)
		return
	print("VISUAL CAPTURE: menu, Chapter I start, and Progression saved")
	main.queue_free()
	await process_frame
	quit(0)
