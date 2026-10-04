extends SceneTree
# Records the real Master bus, including category buses, limiter and context fades.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var sound = root.get_node("Sound")
	var capture := AudioEffectCapture.new()
	capture.buffer_length = 30.0
	var index := AudioServer.get_bus_effect_count(0)
	AudioServer.add_bus_effect(0,capture)
	for key in ["step","step","step_wood","jump","land","dodge","slash","heavy","impact","guard","parry","break","heal","menu","confirm","cancel"]:
		sound.play(key)
		await create_timer(0.38).timeout
	sound.play("echo")
	sound.set_context("echo")
	sound.set_water(true)
	await create_timer(1.4).timeout
	sound.play("akio")
	await create_timer(0.9).timeout
	sound.play("echo_exit")
	sound.set_context("boss")
	sound.set_water(false)
	await create_timer(1.4).timeout
	for key in ["heavy","boss_impact","parry","break","boss_defeat"]:
		sound.play(key)
		await create_timer(0.45).timeout
	sound.set_context("ending")
	await create_timer(1.3).timeout
	var frames := capture.get_buffer(capture.get_frames_available())
	AudioServer.remove_bus_effect(0,index)
	if frames.size()<AudioServer.get_mix_rate()*10:
		push_error("Insufficient real audio captured")
		quit(1)
		return
	var data := PackedByteArray()
	data.resize(frames.size()*4)
	var peak := 0.0
	for i in range(frames.size()):
		peak = maxf(peak,maxf(absf(frames[i].x),absf(frames[i].y)))
		data.encode_s16(i*4,int(clampf(frames[i].x,-1,1)*32767))
		data.encode_s16(i*4+2,int(clampf(frames[i].y,-1,1)*32767))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.stereo = true
	wav.mix_rate = int(AudioServer.get_mix_rate())
	wav.data = data
	var output := ProjectSettings.globalize_path("res://").get_base_dir().get_base_dir().path_join("docs/audio/chapter1")
	DirAccess.make_dir_recursive_absolute(output)
	var result := wav.save_to_wav(output.path_join("runtime_mix_review.wav"))
	print("AUDIO CAPTURE: frames=%d peak=%.4f rate=%d save=%d" % [frames.size(),peak,wav.mix_rate,result])
	quit(0 if result==OK and peak<0.99 and peak>0.001 else 1)
