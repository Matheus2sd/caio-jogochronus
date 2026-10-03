extends Node2D
var events: Array[Dictionary] = []
var textures: Dictionary = {}

func _ready() -> void:
	z_index = 5
	for effect in ["slash","heavy_slash","impact","parry","posture_break","heal"]:
		textures[effect] = load("res://assets/vfx/combat/fx_%s_v001.png" % effect)

func burst(kind: String, point: Vector2, facing: float = 1.0) -> void:
	if kind == "break": kind = "posture_break"
	if not textures.has(kind): return
	events.append({"kind":kind,"point":point,"time":0.0,"facing":facing})
	queue_redraw()

func _process(delta: float) -> void:
	if get_parent().hitstop > 0: return
	for event in events:
		event.time += delta
	events = events.filter(func(event): return event.time < (0.6 if event.kind=="heal" else 0.3))
	queue_redraw()

func _draw() -> void:
	for event in events:
		var frame := mini(5,int(event.time*(10 if event.kind=="heal" else 20)))
		draw_set_transform(event.point,0,Vector2(event.facing,1))
		draw_texture_rect_region(textures[event.kind],Rect2(-48,-48,96,96),Rect2(frame*96,0,96,96),Color(1,1,1,0.85 if Save.settings.flashes else 0.6))
		draw_set_transform(Vector2.ZERO)
