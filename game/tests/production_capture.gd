extends SceneTree
var main
var output: String

func _initialize() -> void:
	call_deferred("capture")

func settle() -> void:
	for i in range(8):
		await process_frame
	await RenderingServer.frame_post_draw

func save_shot(name: String) -> void:
	await settle()
	var shot := root.get_texture().get_image()
	shot.resize(640,360,Image.INTERPOLATE_NEAREST)
	if shot.save_png(output.path_join(name + ".png")) != OK:
		push_error("Capture failed: " + name)
		quit(1)

func stage(zone: int, memory: bool = false) -> void:
	main.notice_time = 0
	main.clear_overlay()
	main.screen = "game"
	main.world.load_zone(zone,memory)
	while main.screen == "dialogue":
		main.intro_block = 0
		main.advance_dialogue()
	main.world.locked = false
	for fighter in get_nodes_in_group("fighters"):
		fighter.set_physics_process(false)
	main.world.player.position = Vector2(240,280)
	main.world.camera.position = Vector2(320,180)
	main.world.camera.reset_smoothing()

func pose(state: String, at: float = 0.12) -> void:
	var player = main.world.player
	player.attack = {}
	player.set_state(state)
	if state.begins_with("light_attack"):
		player.start_attack("light")
	player.state_time = at
	player.update_visual()
	if player.production_visual != null:
		player.production_visual.time = at
	player.update_visual()

func capture() -> void:
	output = ProjectSettings.globalize_path("res://").get_base_dir().get_base_dir().path_join("docs/screenshots/chapter1")
	DirAccess.make_dir_recursive_absolute(output)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await save_shot("production_menu")
	main.start_game(true)
	while main.screen == "dialogue":
		main.intro_block = 0
		main.advance_dialogue()
	stage(0)
	pose("idle")
	await save_shot("ren_idle")
	pose("run",0.22)
	await save_shot("ren_run")
	pose("light_attack_1",0.17)
	await save_shot("ren_attack")
	pose("parry",0.08)
	main.world.on_feedback("parry",main.world.player.position+Vector2(24,-30))
	await save_shot("parry")
	pose("idle")
	main.notice_time = 0
	await save_shot("present_parallax_hud")
	stage(1)
	main.world.actors[0].position.x = 340
	main.world.actors[0].start_attack("light")
	main.world.actors[0].state_time = 0.3
	main.world.actors[0].update_visual()
	await save_shot("human_telegraph")
	stage(2)
	main.world.player.position.x = 350
	pose("echo_interact")
	main.world.echo_visual.begin(main.world.player.position,false)
	await save_shot("echo_entry")
	stage(2,true)
	main.world.player.position.x = 470
	pose("idle")
	await save_shot("echo_akio")
	main.world.echo_visual.begin(main.world.player.position,true)
	await save_shot("echo_exit")
	stage(4)
	pose("guard_hold")
	main.world.actors[0].update_visual()
	await save_shot("daigo_arena")
	print("PRODUCTION CAPTURE PASS: staged presentation frames at 640x360")
	main.free()
	await process_frame
	quit(0)
