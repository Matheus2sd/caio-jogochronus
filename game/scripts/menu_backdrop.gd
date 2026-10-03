extends Node2D
var scenery := preload("res://scripts/chapter_backdrop.gd").new()
var tree := preload("res://assets/environments/props/env_tree_v001.png")
var house := preload("res://assets/environments/props/env_house_v001.png")
var gate := preload("res://assets/environments/props/env_gate_v001.png")

func _draw() -> void:
	scenery.paint(self,0,false,false)
	draw_texture(house,Vector2(390,190),Color("bab9a6"))
	draw_texture(gate,Vector2(320,214),Color("939b8b"))
	draw_texture(tree,Vector2(455,180))
	draw_rect(Rect2(0,300,640,60),Color("15282c"))
	for y in range(300,360,4):
		draw_rect(Rect2(0,y,640,4),Color(0.04,0.07,0.08,(y-296)/64.0))
