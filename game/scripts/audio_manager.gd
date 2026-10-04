extends Node
var players: Array[AudioStreamPlayer] = []
var ambient: AudioStreamPlayer
var music: AudioStreamPlayer
var water: AudioStreamPlayer
var current := 0
var context := "start"
var effects: Dictionary = {}
var loops: Dictionary = {}
var mix_transition: Tween
var step_index := 0
const EFFECTS = ["step_1","step_2","step_3","step_wood_1","step_wood_2","step_wood_3","jump","land","dodge","slash","heavy","impact","parry","guard","break","heal","interact","echo","echo_exit","akio","hurt","death","menu","confirm","cancel","boss","boss_impact","boss_defeat"]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for bus in ["Music", "SFX", "Ambient"]:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
	for key in EFFECTS:
		effects[key] = load("res://assets/audio/production/%s.wav" % key)
	# Bounded pool and a final limiter protect the mix during simultaneous impacts.
	if AudioServer.get_bus_effect_count(0) == 0:
		AudioServer.add_bus_effect(0,AudioEffectLimiter.new())
	for i in range(8):
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		players.append(p)
	ambient = AudioStreamPlayer.new()
	ambient.bus = "Ambient"
	add_child(ambient)
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	add_child(music)
	water = AudioStreamPlayer.new()
	water.bus = "Ambient"
	water.volume_db = -10
	water.stream = loop_stream("ambient_water")
	add_child(water)
	switch_streams("start")
	Save.apply_settings()

func loop_stream(key: String) -> AudioStreamWAV:
	if not loops.has(key):
		var stream: AudioStreamWAV = load("res://assets/audio/production/%s.wav" % key).duplicate()
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = int(stream.get_length()*stream.mix_rate)
		loops[key] = stream
	return loops[key]

func switch_streams(next: String) -> void:
	ambient.stream = loop_stream("ambient_"+next)
	music.stream = loop_stream("music_"+next)
	ambient.play()
	music.play()

func set_context(next: String) -> void:
	if next == context:
		return
	context = next
	if mix_transition != null and mix_transition.is_valid():
		mix_transition.kill()
	mix_transition = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	mix_transition.tween_property(ambient,"volume_db",-45.0,0.18)
	mix_transition.parallel().tween_property(music,"volume_db",-45.0,0.18)
	mix_transition.tween_callback(switch_streams.bind(next))
	mix_transition.tween_property(ambient,"volume_db",0.0,0.4)
	mix_transition.parallel().tween_property(music,"volume_db",0.0,0.4)

func set_water(active: bool) -> void:
	if active and not water.playing:
		water.play()
	elif not active:
		water.stop()

func play(kind: String) -> void:
	if kind in ["step","step_wood"]:
		kind = "%s_%d" % [kind,step_index%3+1]
		step_index += 1
	if not effects.has(kind):
		return
	var p := players[current % players.size()]
	current += 1
	p.stream = effects[kind]
	p.pitch_scale = randf_range(0.985,1.015) if kind in ["parry","echo","echo_exit","akio"] else randf_range(0.96,1.04)
	p.play()
