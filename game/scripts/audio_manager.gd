extends Node
var players: Array[AudioStreamPlayer] = []
var ambient: AudioStreamPlayer
var music: AudioStreamPlayer
var current := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for bus in ["Music", "SFX", "Ambient"]:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
	for i in range(8):
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		players.append(p)
	ambient = loop_player("ambient", "Ambient")
	music = loop_player("music", "Music")
	Save.apply_settings()

func loop_player(kind: String, bus: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = bus
	var stream = load("res://assets/audio/%s/TEMP_%s.wav" % [kind, kind]).duplicate()
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = int(stream.get_length() * stream.mix_rate)
	p.stream = stream
	add_child(p)
	p.play()
	return p

func play(kind: String) -> void:
	var path := "res://assets/audio/sfx/TEMP_%s.wav" % kind
	if not ResourceLoader.exists(path):
		return
	var p := players[current % players.size()]
	current += 1
	p.stream = load(path)
	p.pitch_scale = randf_range(0.96, 1.04)
	p.play()
