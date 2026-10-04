extends SceneTree
var failed := false

func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var sound = root.get_node("Sound")
	check(sound.players.size()==8,"Sound pool must be bounded")
	for key in sound.EFFECTS:
		check(sound.effects[key] is AudioStreamWAV,"Missing production effect: "+key)
		var stream: AudioStreamWAV = sound.effects[key]
		check(stream.mix_rate==48000,"Production sample rate: "+key)
		check(stream.get_length()>0.05 and stream.get_length()<1.5,"Effect duration: "+key)
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.start_game(true)
	while main.screen == "dialogue":
		main.intro_block = 0
		main.advance_dialogue()
	for entry in [[1,false,"present"],[2,false,"present"],[2,true,"echo"],[4,false,"boss"]]:
		main.world.load_zone(entry[0],entry[1])
		main.world.locked = true
		await create_timer(0.7).timeout
		check(sound.context==entry[2],"Area must choose correct soundscape")
		check(sound.ambient.stream==sound.loop_stream("ambient_"+entry[2]),"Context transition must finish")
		check(sound.water.playing==(entry[0]==2),"Water only around the bridge")
		check(sound.music.stream.stereo,"Context music must be stereo")
	main.show_complete()
	await create_timer(0.7).timeout
	check(sound.context=="ending","Ending cue must replace boss cue")
	sound.set_context("echo")
	sound.set_context("boss")
	main.show_menu()
	await create_timer(0.7).timeout
	check(sound.ambient.stream==sound.loop_stream("ambient_start"),"Interrupted transitions must settle on latest context")
	check(not sound.water.playing,"Menu stops bridge water")
	if not failed:
		print("AUDIO PASS: effects, bounded voices, context transitions, interruption, bridge water and ending")
	main.free()
	await process_frame
	quit(1 if failed else 0)
