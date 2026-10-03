extends RefCounted
# Remembered architecture is presentation only; Chapter owns physical traversal.
var textures: Dictionary = {}
var transition_age := 10.0
var transition_point := Vector2.ZERO
var exiting := false

func _init() -> void:
	for key in ["gate", "lantern", "fragments", "bridge", "tree", "memory"]:
		textures[key] = load("res://assets/environments/echo/echo_%s_v001.png" % key)

func begin(point: Vector2, exit_memory: bool) -> void:
	transition_age = 0.0
	transition_point = point
	exiting = exit_memory

func tick(delta: float) -> void:
	transition_age += delta

func prop(canvas: Node2D, key: String, feet: Vector2, tint := Color.WHITE) -> void:
	var texture: Texture2D = textures[key]
	canvas.draw_texture(texture, feet-Vector2(texture.get_width()/2.0,texture.get_height()),tint)

func atmosphere(canvas: Node2D, camera_x: float, clock: float) -> void:
	# Broken vertical silhouettes and displaced islands distinguish memory from a filter.
	for i in range(6):
		var x := float(i*220+70)
		var y := 202.0 + sin(clock*0.55+i)*3.0
		prop(canvas,"fragments",Vector2(x,y),Color(0.6,0.7,0.95,0.45))
		if i%2==0:
			prop(canvas,"gate",Vector2(x+35,228),Color(0.55,0.65,0.9,0.4))
	# Sparse two-pixel motes, never a full-screen flash or a combat-obscuring overlay.
	for i in range(32):
		var x := camera_x + fposmod(i*73.0+clock*(3+i%3),660.0)-10
		var y := fposmod(i*43.0-clock*5,248.0)+16
		var tint := Color(0.57,0.85,0.95,0.22+sin(clock+i)*0.12)
		canvas.draw_rect(Rect2(floorf(x),floorf(y),1,3 if i%5==0 else 1),tint)

func limiar(canvas: Node2D, point: Vector2, clock: float) -> void:
	prop(canvas,"memory",point)
	for i in range(12):
		var angle := clock*0.6+i*TAU/12
		var p := point+Vector2(cos(angle)*23,-20+sin(angle)*9)
		canvas.draw_rect(Rect2(p.floor(),Vector2(2,2)),Color(0.62,0.87,1,0.65))

func transition(canvas: Node2D, current_point: Vector2, reduced: bool) -> void:
	if transition_age >= 0.85:
		return
	var t := transition_age/0.85
	var center := transition_point if transition_age<0.4 else current_point
	var opacity := sin(t*PI)*(0.3 if reduced else 0.65)
	for i in range(22):
		var direction := -1.0 if exiting else 1.0
		var x := sin(i*2.4)*28*(1-t if exiting else t)
		var y := -fposmod(i*13+t*70*direction,70)
		canvas.draw_rect(Rect2((center+Vector2(x,y)).floor(),Vector2(2+i%3,2)),Color(0.59,0.77,1,opacity))
	for band in range(3):
		var y := -12-band*20+t*5
		var radius := 12+t*26
		# Segmented pixel ellipse: a restrained spiral around the remembered body.
		for i in range(20):
			var angle := i*TAU/20+t*2
			var p := center+Vector2(cos(angle)*radius,y+sin(angle)*5)
			canvas.draw_rect(Rect2(p.floor(),Vector2(2,1)),Color(0.65,0.86,1,opacity))
