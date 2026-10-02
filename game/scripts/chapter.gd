extends Node2D
signal request_dialogue(lines, after)
signal player_died(in_memory)
signal chapter_finished
signal message(text)
const Fighter = preload("res://scripts/fighter.gd")
const InputConfig = preload("res://scripts/input_config.gd")
var player
var camera: Camera2D
var geometry: Node2D
var cast: Node2D
var zone := 0
var memory := false
var level_width := 1000.0
var locked := false
var hitstop := 0.0
var debug_mode := false
var clock := 0.0
var particles: Array[Dictionary] = []
var actors: Array = []
var platforms: Array[Rect2] = []
var ren_snapshot: Dictionary = {}
var memory_won := false
var transition := 0.0
var transition_action: Callable
var shake := 0.0
var pad := false
var checkpoint_notice := false
var boss_started := false
var background: Texture2D
var tiles := preload("res://assets/environments/tilesets/TEMP_tiles.png")
var props: Dictionary = {}
var prop_positions: Array = []
const TITLES = ["01   O CAMINHO ANTIGO", "02   A LINGUAGEM DA ESPADA", "03   TRAVESSIA INTERROMPIDA", "04   O GESTO HERDADO", "05   O ABRIGO DE DAIGO"]
const BEFORE = [["Ren", "Estou procurando Masaru. Disseram que você lutou com ele."],
	["Daigo", "Lutei. Não recomendo."], ["Ren", "Preciso saber por onde ele passou."],
	["Daigo", "Você precisa de outra coisa. Ainda não percebeu."],
	["Ren", "Não vim pedir sua permissão."], ["Daigo", "Então vai tentar passar por mim."]]
const AFTER = [["Ren", "Não fale como se o conhecesse melhor do que eu."],
	["Daigo", "Eu conheci uma parte que ele não levou para casa."],
	["Ren", "E o que isso diz sobre mim?"], ["Daigo", "Masaru também achava que parar era perder."],
	["Daigo", "Isamu cuidava de um lugar marcado por essas memórias. Comece por lá. Não espere que ele goste da visita."]]

func _ready() -> void:
	geometry = Node2D.new()
	add_child(geometry)
	cast = Node2D.new()
	add_child(cast)
	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7
	add_child(camera)
	for name in ["tree", "pine", "gate", "lantern", "house", "fence"]:
		props[name] = load("res://assets/environments/props/TEMP_%s.png" % name)

func begin(fresh: bool) -> void:
	if fresh:
		Save.new_campaign()
	if Save.progress.get("complete", false):
		chapter_finished.emit()
		return
	if Save.progress.get("daigo_defeated", false):
		load_zone(4)
		for actor in actors:
			actor.hp = 0
			actor.set_state("death")
		request_dialogue.emit(AFTER, finish_chapter)
		return
	load_zone(int(Save.progress.get("checkpoint", 0)))
	if fresh:
		request_dialogue.emit([["PRIMAVERA · REN, 22 ANOS", "Sete anos após a morte de Akio, Ren segue os caminhos antigos em busca de Masaru."],
			["Ren", "Disseram que Daigo vive além da ponte."]], func(): locked = false)

func clear_level() -> void:
	for node in geometry.get_children():
		node.free()
	for node in cast.get_children():
		node.free()
	actors.clear()
	platforms.clear()
	prop_positions.clear()
	particles.clear()

func load_zone(next: int, in_memory: bool = false, resources: Dictionary = {}) -> void:
	clear_level()
	zone = next
	memory = in_memory
	memory_won = false
	boss_started = false
	checkpoint_notice = false
	level_width = [1000.0, 1600.0, 1000.0, 1280.0, 640.0][zone]
	background = load("res://assets/environments/%s/TEMP_background.png" % ("echo" if memory else "present"))
	if zone == 4:
		background = load("res://assets/environments/backgrounds/TEMP_arena.png")
	if zone == 2 and not memory:
		add_platform(Rect2(0,280,400,140),0)
		add_platform(Rect2(680,280,320,140),0)
	else:
		add_platform(Rect2(0,280,level_width,140),2 if zone==4 else 0)
	if zone == 0:
		add_platform(Rect2(390,256,80,24),2)
		add_platform(Rect2(630,248,80,32),2)
	if zone == 1:
		add_platform(Rect2(990,246,96,34),2)
		add_platform(Rect2(1110,218,112,16),2)
		spawn_enemy(400)
		spawn_enemy(780)
		spawn_enemy(1370)
	if memory:
		spawn_enemy(650)
	if zone == 3:
		spawn_enemy(390)
		spawn_enemy(780, true)
	if zone == 4:
		spawn_enemy(470, true, "daigo")
		locked = true
	player = Fighter.new()
	player.kind = "akio" if memory else "ren"
	player.world = self
	player.position = Vector2(72,280)
	cast.add_child(player)
	player.defeated.connect(on_defeated)
	player.feedback.connect(on_feedback)
	if not resources.is_empty():
		for key in ["hp", "stamina", "posture", "cures"]:
			player.set(key, resources[key])
	if zone == 3 and Save.progress.get("checkpoint", 0) == 3:
		player.position.x = 1080
		for actor in actors:
			actor.position.x = minf(actor.position.x, 780)
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_bottom = 360
	camera.limit_right = int(level_width)
	camera.position = Vector2(player.position.x,180)
	camera.reset_smoothing()
	for x in range(0, int(level_width), 240):
		prop_positions.append(["tree" if x%480==0 else "pine", Vector2(x+80,280)])
		prop_positions.append(["fence",Vector2(x+170,280)])
	if zone == 4:
		prop_positions = [["house",Vector2(290,280)],["tree",Vector2(40,280)],["tree",Vector2(610,280)]]
	else:
		prop_positions.append(["gate", Vector2(level_width-90,280)])
	if zone in [0,2,3]:
		prop_positions.append(["lantern", Vector2(checkpoint_x(),280)])
	if zone == 4:
		if Save.progress.get("daigo_intro", false):
			locked = false
			boss_started = true
		else:
			request_dialogue.emit(BEFORE, start_boss)
	queue_redraw()

func add_platform(rect: Rect2, tile: int) -> void:
	platforms.append(rect)
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = rect.position + rect.size/2
	body.set_meta("tile", tile)
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)
	geometry.add_child(body)

func spawn_enemy(x: float, defender: bool = false, kind: String = "human") -> void:
	var enemy = Fighter.new()
	enemy.kind = kind
	enemy.enemy = true
	enemy.defender = defender
	enemy.world = self
	enemy.position = Vector2(x,280)
	enemy.facing = -1
	cast.add_child(enemy)
	enemy.defeated.connect(on_defeated)
	enemy.feedback.connect(on_feedback)
	actors.append(enemy)

func can_enemy_attack(who) -> bool:
	if absf(who.position.x-camera.get_screen_center_position().x) > 290:
		return false
	for actor in actors:
		if actor != who and not actor.attack.is_empty():
			return false
	return true

func living_enemies() -> int:
	var count := 0
	for actor in actors:
		if actor.hp > 0:
			count += 1
	return count

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	hitstop = maxf(0,hitstop-delta)
	if not locked:
		clock += delta
	shake = maxf(0, shake-delta*16)
	if is_instance_valid(player):
		camera.position = Vector2(player.position.x + player.facing*35,180)
		camera.offset = Vector2(randf_range(-shake,shake),randf_range(-shake,shake)) if Save.settings.shake else Vector2.ZERO
	if transition > 0:
		transition -= delta
		if transition <= 0 and transition_action.is_valid():
			transition_action.call_deferred()
	for fx in particles:
		fx.life -= delta
		fx.pos += fx.vel * delta
	particles = particles.filter(func(fx): return fx.life > 0)
	if is_instance_valid(player) and not locked and hitstop<=0 and player.hp>0:
		if Input.is_action_just_pressed("interact"):
			interact()
		if zone == 2 and not memory and player.position.x > 380:
			player.position.x = 380
		if zone == 4 and boss_started and actors.size()>0 and actors[0].hp < 90 and not actors[0].has_meta("line"):
			actors[0].set_meta("line",true)
			message.emit("Daigo: A guarda é do seu pai. Essa pressa, não.")
	queue_redraw()

func checkpoint_x() -> float:
	return 1080 if zone==3 else 180

func near_checkpoint() -> bool:
	return not memory and zone in [0,2,3] and absf(player.position.x-checkpoint_x()) < 45

func interact() -> void:
	if not player.attack.is_empty() or player.state in ["hurt","posture_break","death"]:
		return
	if near_checkpoint() and not nearby_threat():
		Save.progress.checkpoint = zone
		player.hp = 100
		player.stamina = 100
		player.posture = 100
		player.cures = 2
		if Save.progress.get("garca",false):
			Save.progress.garca_equipped = true
		var saved := Save.store_campaign()
		player.set_state("interact")
		message.emit("Descanso • recursos restaurados • " + ("progresso salvo" if saved else "ERRO AO SALVAR"))
		Sound.play("heal")
		return
	if zone==1 and not Save.progress.garca and player.position.distance_to(Vector2(1170,218))<48:
		Save.progress.garca = true
		Save.store_campaign()
		message.emit("Talismã da Garça • disponível no próximo descanso")
		return
	if zone==2 and not memory and absf(player.position.x-350)<60:
		enter_memory()
		return
	if player.position.x > level_width-115:
		if living_enemies()>0:
			message.emit("A passagem ainda está disputada.")
		elif memory:
			leave_memory()
		elif zone<4:
			var resources := snapshot()
			fade_to(func(): load_zone(zone+1,false,resources); locked=false)
		return
	player.sword_drawn = not player.sword_drawn
	player.set_state("draw_sword" if player.sword_drawn else "sheathe_sword")

func nearby_threat() -> bool:
	for actor in actors:
		if actor.hp>0 and absf(actor.position.x-player.position.x)<250:
			return true
	return false

func snapshot() -> Dictionary:
	return {"hp":player.hp,"stamina":player.stamina,"posture":player.posture,"cures":player.cures}

func enter_memory() -> void:
	ren_snapshot = snapshot()
	player.set_state("echo_interact")
	Sound.play("echo")
	fade_to(func():
		load_zone(2,true)
		request_dialogue.emit([["ECO · UMA PASSAGEM DO PASSADO", "A ponte recorda sua forma. Um gesto permanece."],
			["AKIO JOVEM · CONTROLE, PRECISÃO", "Apare com %s no instante do golpe. Pressione %s logo depois para avançar e cortar." % [InputConfig.prompt("guard",pad),InputConfig.prompt("light_attack",pad)]]],func():locked=false))

func leave_memory() -> void:
	Save.progress.echo_done = true
	# Resume after memory at a valid checkpoint on reload, never inside the gap.
	Save.progress.checkpoint = 3
	Save.store_campaign()
	Sound.play("echo")
	fade_to(func():
		load_zone(3,false,ren_snapshot)
		player.position.x = 72
		camera.reset_smoothing()
		request_dialogue.emit([["REN", "O mesmo gesto. Parar a lâmina, entrar no espaço, cortar."],
			["PRESENTE", "A ponte permanece partida. A memória se desfaz na outra margem."]],func():locked=false))

func fade_to(action: Callable) -> void:
	locked = true
	transition = 0.4
	transition_action = action
	if is_instance_valid(player):
		player.attack = {}
		player.queued_light = false

func start_boss() -> void:
	Save.progress.daigo_intro = true
	Save.store_campaign()
	locked = false
	boss_started = true

func on_defeated(fighter) -> void:
	if fighter == player:
		locked = true
		player_died.emit(memory)
	elif fighter.kind == "daigo":
		Save.progress.daigo_defeated = true
		Save.store_campaign()
		locked = true
		request_dialogue.emit(AFTER,finish_chapter)
	elif memory and living_enemies()==0:
		memory_won = true
		message.emit("A passagem se abre. Atravesse a ponte lembrada.")

func finish_chapter() -> void:
	Save.progress.complete = true
	Save.store_campaign()
	locked = true
	chapter_finished.emit()

func respawn() -> void:
	locked = false
	if memory:
		load_zone(2,true)
	else:
		load_zone(int(Save.progress.checkpoint))

func on_feedback(kind: String, point: Vector2) -> void:
	Sound.play(kind)
	if kind in ["parry","impact","break"]:
		hitstop = 0.06 if kind=="parry" else 0.04
		shake = 2.5 if kind=="parry" else 1.3
	var color := Color("9eeafa") if kind=="parry" else (Color("9fcc9e") if kind=="heal" else Color("eed09b"))
	for i in range(12 if kind=="parry" else 7):
		particles.append({"pos":point,"vel":Vector2.from_angle(randf()*TAU)*randf_range(12,65),"life":0.32,"color":color})
	if kind=="parry":
		message.emit("PARRY • %s para resposta herdada" % InputConfig.prompt("light_attack",pad))
	elif kind=="break":
		message.emit("POSTURA QUEBRADA • corte leve próximo para ruptura")

func prompt_text() -> String:
	if not is_instance_valid(player) or locked:
		return ""
	var interact_key := InputConfig.prompt("interact",pad)
	if near_checkpoint():
		return "[%s] Descansar / salvar%s" % [interact_key, " / equipar Garça" if Save.progress.get("garca",false) else ""]
	if zone==1 and not Save.progress.get("garca",false) and player.position.distance_to(Vector2(1170,218))<50:
		return "[%s] Recolher talismã da Garça" % interact_key
	if zone==2 and not memory:
		return "[%s] Tocar o limiar" % interact_key if player.position.x>285 else "A ponte está partida. Uma lembrança permanece."
	if player.position.x>level_width-115 and zone<4:
		return "[%s] %s" % [interact_key,"Atravessar" if living_enemies()==0 else "Derrote a oposição para seguir"]
	if memory:
		return "AKIO • %s: parry → %s: avanço e corte" % [InputConfig.prompt("guard",pad),InputConfig.prompt("light_attack",pad)]
	if zone==0:
		return "Mover: %s/%s  •  Correr: %s  •  Saltar: %s" % [InputConfig.prompt("move_left",pad),InputConfig.prompt("move_right",pad),InputConfig.prompt("run",pad),InputConfig.prompt("jump",pad)]
	if zone==1:
		return "Leve %s • Forte %s • Guarda/parry %s • Esquiva %s" % [InputConfig.prompt("light_attack",pad),InputConfig.prompt("heavy_attack",pad),InputConfig.prompt("guard",pad),InputConfig.prompt("dodge",pad)]
	return "Cura [%s] • duas cargas por descanso" % InputConfig.prompt("heal",pad)

func _draw() -> void:
	if background == null:
		return
	var cam_x := 0.0 if camera==null else clampf(camera.position.x-320,0,level_width-640)
	draw_rect(Rect2(cam_x-30,0,700,360),Color("0c1927") if memory else Color("b6c7be"))
	# Background moves more slowly than collision geometry and characters.
	for i in range(-1,4):
		var x := float(i*640) + floorf(cam_x*0.6/640)*640 - cam_x*0.25
		draw_texture_rect(background,Rect2(x,45,640,240),false,Color(0.78,0.85,0.91) if memory else Color(0.85,0.9,0.85))
	for prop in prop_positions:
		var texture: Texture2D = props[prop[0]]
		var tint := Color(0.43,0.62,0.79,0.7) if memory else Color(0.82,0.86,0.78,0.85)
		draw_texture(texture,prop[1]-Vector2(texture.get_width()/2.0,texture.get_height()),tint)
	for r in platforms:
		var base := 2 if zone==4 or r.position.y<280 else 0
		for x in range(int(r.position.x),int(r.end.x),16):
			if x<cam_x-32 or x>cam_x+672:
				continue
			for y in range(int(r.position.y),int(minf(r.end.y,368)),16):
				var tile := base if y==int(r.position.y) else 7
				draw_texture_rect_region(tiles,Rect2(x,y,16,16),Rect2(tile*16,0,16,16),Color(0.48,0.68,0.8) if memory else Color.WHITE)
			draw_line(Vector2(x,r.position.y),Vector2(x+16,r.position.y),Color("b0ad69") if not memory else Color("70d9df"),2)
	if zone==2:
		draw_rect(Rect2(400,280,280,80),Color("102c42"))
		for i in range(12):
			draw_line(Vector2(410+i*22,310+sin(clock+i)*3),Vector2(425+i*22,310+sin(clock+i)*3),Color("57859a"))
		if memory:
			for x in range(400,680,16):
				draw_rect(Rect2(x,280,15,8),Color("64a9b8"))
				draw_line(Vector2(x,252),Vector2(x+16,252),Color("97dbe7"),2)
				if x%48==16:
					draw_rect(Rect2(x,246,4,36),Color("468ba6"))
		else:
			draw_line(Vector2(386,280),Vector2(426,310),Color("5b4839"),5)
			draw_line(Vector2(654,306),Vector2(691,280),Color("5b4839"),5)
			draw_arc(Vector2(350,258),21+sin(clock*2)*2,0,TAU,24,Color("8aceed"),2)
	if zone==1 and not Save.progress.get("garca",false):
		draw_colored_polygon(PackedVector2Array([Vector2(1170,187),Vector2(1179,198),Vector2(1170,207),Vector2(1161,198)]),Color("f4d394"))
	# Eco reconstructs displaced architecture as well as the usable bridge.
	if memory:
		for i in range(18):
			var x := 210+i*37.0
			var y := 170+sin(i*2.1+clock)*12
			draw_rect(Rect2(x,y,12,5),Color(0.32,0.78,0.94,0.22+sin(clock+i)*0.1))
	for i in range(35):
		var x := fmod(i*77.7+clock*(9 if memory else -7),level_width)
		var y := fmod(i*47.3+clock*( -9 if memory else 7)+360,280)
		draw_rect(Rect2(x,y,2,2),Color(0.5,0.85,1,0.45) if memory else Color(1,0.76,0.78,0.55))
	for fx in particles:
		draw_rect(Rect2(fx.pos,Vector2(2,2)),fx.color)
	if debug_mode:
		for r in platforms:
			draw_rect(r,Color(0,1,0,0.6),false)
