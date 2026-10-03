extends RefCounted
var sky := preload("res://assets/environments/present/bg_sky_v001.png")
var layers: Array = []

func _init() -> void:
	for entry in [["mountains",68,0.12],["far_forest",152,0.28],["mid_forest",186,0.48],["near_forest",0,0.72]]:
		layers.append({"texture":load("res://assets/environments/present/bg_%s_v001.png" % entry[0]),"y":entry[1],"speed":entry[2]})

func paint(canvas: Node2D, camera_x: float, memory: bool, arena: bool) -> void:
	canvas.draw_texture_rect(sky,Rect2(floorf(camera_x)-32,-8,704,376),false,Color("6d759e") if memory else Color.WHITE)
	for layer in layers:
		var tint := Color("6883b8") if memory else Color.WHITE
		if arena:
			tint = tint.darkened(0.13)
		var origin := floorf(camera_x) - floorf(fposmod(camera_x*float(layer.speed),1280.0))
		for i in range(-1,2):
			canvas.draw_texture(layer.texture,Vector2(origin+i*1280,layer.y),tint)
