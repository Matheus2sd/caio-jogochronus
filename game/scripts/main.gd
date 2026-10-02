extends Node2D
const Chapter = preload("res://scripts/chapter.gd")
const InputConfig = preload("res://scripts/input_config.gd")
var world
var ui: CanvasLayer
var hud: Control
var overlay: Control
var bars: Dictionary = {}
var resource_text: Label
var name_text: Label
var area_text: Label
var prompt: Label
var notice: Label
var boss_label: Label
var boss_hp: ProgressBar
var boss_posture: ProgressBar
var notice_time := 0.0
var screen := "menu"
var dialogue_lines: Array = []
var dialogue_index := 0
var dialogue_after: Callable
var dialogue_text: Label
var dialogue_name: Label
var rebind_action := ""
var rebind_pending_action := ""
var rebind_conflict_action := ""
var rebind_pending_key := 0
var settings_return := "menu"
var gamepad := false
var intro_block := 0.0
var theme_ui: Theme
var test_mode := false
const ACTION_NAMES = {"move_left":"Esquerda","move_right":"Direita","jump":"Salto","dodge":"Esquiva","light_attack":"Leve / contra-ataque","heavy_attack":"Forte","guard":"Guarda / parry","interact":"Interação","heal":"Cura","pause":"Pausa","run":"Corrida"}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	test_mode = "--test" in OS.get_cmdline_user_args()
	InputConfig.setup(Save.settings.keys)
	theme_ui = make_theme()
	ui = CanvasLayer.new()
	add_child(ui)
	build_hud()
	show_menu()
	if test_mode:
		get_tree().call_group("tests", "game_ready", self)

func make_style(color: Color, border: Color, width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(width)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style

func make_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = 13
	theme.set_color("font_color","Label",Color("e7e1d1"))
	theme.set_color("font_color","Button",Color("e7e1d1"))
	theme.set_color("font_hover_color","Button",Color("fff2cb"))
	theme.set_stylebox("normal","Button",make_style(Color("14242a"),Color("51615e")))
	theme.set_stylebox("hover","Button",make_style(Color("293c40"),Color("d5b77b")))
	theme.set_stylebox("pressed","Button",make_style(Color("39473f"),Color("f2d8a3")))
	theme.set_stylebox("focus","Button",make_style(Color(0,0,0,0),Color("e6c98f"),2))
	theme.set_stylebox("panel","PanelContainer",make_style(Color("101e26"),Color("526466")))
	return theme

func label(text: String, size: int = 13) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size",size)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func button(parent: Control, text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size.y = 28
	b.pressed.connect(action)
	parent.add_child(b)
	return b

func clear_overlay() -> void:
	if is_instance_valid(overlay):
		overlay.hide()
		overlay.queue_free()
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.theme = theme_ui
	ui.add_child(overlay)

func shade(alpha: float = 0.8) -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.018,0.033,0.045,alpha)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)

func menu_box(title: String, subtitle: String = "", wide: bool = false) -> VBoxContainer:
	clear_overlay()
	shade(0.91 if wide else 0.77)
	var box := VBoxContainer.new()
	box.position = Vector2(70,32) if wide else Vector2(42,37)
	box.size = Vector2(500,290) if wide else Vector2(246,286)
	box.add_theme_constant_override("separation",5)
	overlay.add_child(box)
	box.add_child(label(title,23 if wide else 32))
	if not subtitle.is_empty():
		box.add_child(label(subtitle,11))
	var space := Control.new()
	space.custom_minimum_size.y = 5
	box.add_child(space)
	return box

func show_menu() -> void:
	reset_rebind()
	get_tree().paused = false
	if is_instance_valid(world):
		world.queue_free()
		world = null
	screen = "menu"
	hud.hide()
	var box := menu_box("C H R O N U S", "CAPÍTULO I  /  PRIMAVERA")
	# Reference-derived landscape, deliberately without concept-sheet text.
	var bg := TextureRect.new()
	bg.texture = load("res://assets/environments/present/TEMP_background.png")
	bg.position = Vector2(0,0)
	bg.size = Vector2(640,360)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.45,0.53,0.55)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(bg)
	overlay.move_child(bg,0)
	var first: Button
	if not Save.progress.is_empty():
		first = button(box,"Continuar",func(): start_game(false))
	var new_button := button(box,"Novo jogo",confirm_new_game)
	if first == null:
		first = new_button
	button(box,"Configurações",func(): show_settings("menu"))
	button(box,"Controles",func(): show_controls("menu"))
	button(box,"Créditos",show_credits)
	button(box,"Sair",func(): get_tree().quit())
	first.grab_focus()
	var caption := label("TEMPO  ·  MEMÓRIA  ·  HERANÇA",12)
	caption.position = Vector2(370,294)
	overlay.add_child(caption)
	var build_label := label("Fatia jogável • arte e áudio provisórios",10)
	build_label.position = Vector2(42,337)
	overlay.add_child(build_label)

func confirm_new_game() -> void:
	if Save.progress.is_empty():
		start_game(true)
		return
	var box := menu_box("Novo jogo", "Substituir o progresso atual?")
	button(box,"Cancelar",show_menu).grab_focus()
	button(box,"Iniciar nova jornada",func(): start_game(true))

func start_game(fresh: bool) -> void:
	get_tree().paused = false
	clear_overlay()
	screen = "game"
	hud.show()
	if is_instance_valid(world):
		world.free()
	world = Chapter.new()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	world.request_dialogue.connect(show_dialogue)
	world.player_died.connect(show_death)
	world.chapter_finished.connect(show_complete)
	world.message.connect(show_notice)
	world.pad = gamepad
	world.begin(fresh)

func build_hud() -> void:
	hud = Control.new()
	hud.theme = theme_ui
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(hud)
	var panel := PanelContainer.new()
	panel.position = Vector2(12,10)
	panel.size = Vector2(202,90)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation",2)
	panel.add_child(rows)
	name_text = label("REN",12)
	rows.add_child(name_text)
	for entry in [["VIDA","b9665e"],["STAMINA","78aa9a"],["POSTURA","c5a976"]]:
		var row := HBoxContainer.new()
		rows.add_child(row)
		var title := label(entry[0],8)
		title.custom_minimum_size.x = 52
		row.add_child(title)
		var bar := make_bar(Color(entry[1]))
		bar.custom_minimum_size = Vector2(119,7)
		row.add_child(bar)
		bars[entry[0]] = bar
	resource_text = label("CURAS  ◆ ◆",9)
	rows.add_child(resource_text)
	area_text = label("",11)
	area_text.position = Vector2(285,14)
	area_text.size.x = 342
	area_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hud.add_child(area_text)
	boss_label = label("DAIGO",12)
	boss_label.position = Vector2(268,40)
	hud.add_child(boss_label)
	boss_hp = make_bar(Color("b9665e"))
	boss_hp.position = Vector2(268,59)
	boss_hp.size = Vector2(275,6)
	hud.add_child(boss_hp)
	boss_posture = make_bar(Color("c5a976"))
	boss_posture.position = Vector2(268,69)
	boss_posture.size = Vector2(275,4)
	hud.add_child(boss_posture)
	prompt = label("",12)
	prompt.position = Vector2(12,329)
	prompt.size = Vector2(616,23)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_color_override("font_shadow_color",Color.BLACK)
	prompt.add_theme_constant_override("shadow_offset_x",1)
	prompt.add_theme_constant_override("shadow_offset_y",1)
	hud.add_child(prompt)
	notice = label("",11)
	notice.position = Vector2(16,305)
	notice.size.x = 608
	notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice.add_theme_color_override("font_color",Color("ffdfa3"))
	notice.add_theme_color_override("font_shadow_color",Color.BLACK)
	notice.add_theme_constant_override("shadow_offset_y",1)
	hud.add_child(notice)

func make_bar(color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = 100
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("background",make_style(Color("23343a"),Color("435054"),0))
	bar.add_theme_stylebox_override("fill",make_style(color,color,0))
	return bar

func _process(delta: float) -> void:
	intro_block = maxf(0,intro_block-delta)
	if not get_tree().paused:
		notice_time = maxf(0,notice_time-delta)
		notice.visible = notice_time>0
	if not is_instance_valid(world) or not is_instance_valid(world.player):
		return
	var player = world.player
	name_text.text = "AKIO · MEMÓRIA" if world.memory else "REN · 22 ANOS"
	bars.VIDA.value = player.hp
	bars.STAMINA.value = player.stamina
	bars.POSTURA.value = player.posture
	resource_text.text = "CURAS %s   %s" % ["◆".repeat(player.cures)+"◇".repeat(2-player.cures),"GARÇA" if Save.progress.get("garca_equipped",false) else ""]
	area_text.text = "E01   A PONTE LEMBRADA" if world.memory else world.TITLES[world.zone]
	prompt.text = world.prompt_text()
	var boss: bool = world.zone==4 and world.actors.size()>0 and world.actors[0].hp>0
	boss_label.visible = boss
	boss_hp.visible = boss
	boss_posture.visible = boss
	if boss:
		boss_hp.value = world.actors[0].hp/world.actors[0].max_hp*100
		boss_posture.value = world.actors[0].posture/world.actors[0].max_posture*100
	queue_redraw()

func show_notice(text: String) -> void:
	notice.text = text
	notice_time = 3.0

func show_dialogue(lines: Array, after: Callable) -> void:
	world.locked = true
	if is_instance_valid(world.player):
		world.player.attack = {}
		world.player.queued_light = false
		world.player.velocity = Vector2.ZERO
	screen = "dialogue"
	dialogue_lines = lines
	dialogue_index = 0
	dialogue_after = after
	intro_block = 0.2
	clear_overlay()
	var panel := PanelContainer.new()
	panel.position = Vector2(16,240)
	panel.size = Vector2(608,108)
	overlay.add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	dialogue_name = label("",13)
	dialogue_name.add_theme_color_override("font_color",Color("d7b977"))
	box.add_child(dialogue_name)
	dialogue_text = label("",15 if Save.settings.large_text else 13)
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.custom_minimum_size = Vector2(578,45)
	box.add_child(dialogue_text)
	button(box,"Continuar  [%s / Enter]" % InputConfig.prompt("interact",gamepad),advance_dialogue).grab_focus()
	render_dialogue()

func render_dialogue() -> void:
	dialogue_name.text = dialogue_lines[dialogue_index][0]
	dialogue_text.text = dialogue_lines[dialogue_index][1]

func advance_dialogue() -> void:
	if intro_block>0:
		return
	dialogue_index += 1
	if dialogue_index>=dialogue_lines.size():
		clear_overlay()
		screen = "game"
		world.locked = false
		intro_block = 0.15
		dialogue_after.call()
	else:
		render_dialogue()
		intro_block = 0.12

func show_pause() -> void:
	get_tree().paused = true
	screen = "pause"
	var box := menu_box("Pausa", "CAPÍTULO I / PRIMAVERA")
	button(box,"Retomar",resume).grab_focus()
	button(box,"Progressão",func(): show_progression("pause"))
	button(box,"Equipamento",show_equipment)
	button(box,"Controles",func(): show_controls("pause"))
	button(box,"Configurações",func(): show_settings("pause"))
	button(box,"Voltar ao menu",show_menu)

func resume() -> void:
	reset_rebind()
	clear_overlay()
	get_tree().paused = false
	screen = "game"

func progression_editable() -> bool:
	return is_instance_valid(world) and is_instance_valid(world.player) and not Save.progress.get("complete", false) and world.near_checkpoint() and not world.nearby_threat()

func show_progression(back: String) -> void:
	settings_return = back
	screen = "progression"
	var editable := progression_editable()
	var box := menu_box("Progressão", "Marcas disponíveis: %d/3" % Save.available_marks(), true)
	var cards := GridContainer.new()
	cards.columns = 2
	cards.add_theme_constant_override("h_separation", 8)
	cards.add_theme_constant_override("v_separation", 8)
	box.add_child(cards)
	for entry in [["l1", "L1 · Resposta firme", "Resposta: 18 → 24 postura"],
		["l2", "L2 · Respiração", "Após parry: +20% stamina por 1 s"],
		["l3", "L3 · Corte econômico", "Forte: 18 → 15 stamina"],
		["e1", "E1 · Passo sereno", "Capítulo IV · bloqueada"]]:
		var key: String = entry[0]
		var owned := Save.has_upgrade(key)
		var state_text := "Equipada · remover" if owned else ("Bloqueada" if key == "e1" else ("Aplicar 1 marca" if Save.available_marks() > 0 else "Sem marca"))
		var card := button(cards, "%s\n%s\n%s" % [entry[1], entry[2], state_text], func(): toggle_upgrade(key, back))
		card.custom_minimum_size = Vector2(235, 75)
		card.add_theme_stylebox_override("disabled", make_style(Color("18282b"), Color("63736e")))
		card.add_theme_color_override("font_disabled_color", Color("c1c4bc"))
		card.disabled = key == "e1" or not editable or (not owned and Save.available_marks() <= 0)
	box.add_child(label("Alterações disponíveis no descanso" if not editable else "Aplicar e remover marcas sem custo no ponto seguro", 11))
	button(box, "Voltar", func(): return_to(back)).grab_focus()

func toggle_upgrade(key: String, back: String) -> void:
	if progression_editable() and Save.set_upgrade(key, not Save.has_upgrade(key)):
		show_progression(back)

func show_equipment() -> void:
	var box := menu_box("Equipamento", "Espada de Akio • arma fixa",true)
	box.add_child(label("Curas: 2 por descanso · restauram 45 de vida",13))
	box.add_child(label("Talismã da Garça: pouso 0,04 s · buffer do salto 0,14 s",13))
	box.add_child(label("%s" % ("Equipado no slot 1" if Save.progress.get("garca_equipped",false) else ("Encontrado; equipe no descanso" if Save.progress.get("garca",false) else "Não encontrado — procure o desvio elevado")),12))
	box.add_child(label("Técnica herdada: parry → avanço curto → corte diagonal",13))
	box.add_child(label("O Capítulo I não concede Passo do Eco.",12))
	button(box,"Voltar",show_pause).grab_focus()

func show_settings(back: String) -> void:
	settings_return = back
	screen = "settings"
	var box := menu_box("Configurações","Alterações salvas automaticamente",true)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(500,210)
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for item in [["fullscreen","Tela cheia"],["vsync","VSync"],["shake","Tremor de câmera"],["flashes","Flashes de impacto"],["large_text","Texto grande"],["parry_assist","Assistência de parry (0,22 s)"],["damage_assist","Dano recebido reduzido (85%)"]]:
		var check := CheckButton.new()
		check.text = item[1]
		check.button_pressed = Save.settings[item[0]]
		var key: String = item[0]
		check.toggled.connect(func(value): Save.settings[key]=value; Save.store_settings())
		list.add_child(check)
	for item in [["master","Geral"],["music","Música"],["sfx","Efeitos"],["ambient","Ambiente"]]:
		var row := HBoxContainer.new()
		list.add_child(row)
		var text := label(item[1],12)
		text.custom_minimum_size.x = 110
		row.add_child(text)
		var slider := HSlider.new()
		slider.min_value = 0
		slider.max_value = 1
		slider.step = 0.05
		slider.value = Save.settings[item[0]]
		slider.custom_minimum_size.x = 270
		var key: String = item[0]
		slider.value_changed.connect(func(value): Save.settings[key]=value; Save.store_settings())
		row.add_child(slider)
	button(box,"Voltar",func(): return_to(back)).grab_focus()

func return_to(back: String) -> void:
	reset_rebind()
	if back=="pause":
		show_pause()
	elif back=="complete":
		show_complete()
	else:
		show_menu()

func show_controls(back: String) -> void:
	reset_rebind()
	screen = "controls"
	settings_return = back
	var box := menu_box("Controles","Selecione uma ação para remapear o teclado. Esc cancela.",true)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(500,200)
	box.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(rows)
	for action in InputConfig.KEYS:
		var text: String = "%s   [%s]   Controle: %s" % [ACTION_NAMES[action],InputConfig.prompt(action),InputConfig.prompt(action,true)]
		button(rows,text,func(): rebind_action=action; show_notice("Pressione uma tecla para "+ACTION_NAMES[action]))
	button(rows,"Restaurar padrões",func(): Save.settings.keys={}; InputConfig.setup({}); Save.store_settings(); show_controls(back))
	button(box,"Voltar",func():return_to(back)).grab_focus()

func show_rebind_conflict() -> void:
	screen = "controls_conflict"
	var key_name := OS.get_keycode_string(rebind_pending_key)
	var box := menu_box("Tecla em uso", "%s já controla %s." % [key_name, ACTION_NAMES[rebind_conflict_action]], true)
	box.add_child(label("Trocar as teclas de %s e %s?" % [ACTION_NAMES[rebind_pending_action], ACTION_NAMES[rebind_conflict_action]], 12))
	button(box,"Trocar ações",confirm_rebind_swap).grab_focus()
	button(box,"Cancelar",cancel_rebind_swap)

func confirm_rebind_swap() -> void:
	var old_key := 0
	for mapped in InputMap.action_get_events(rebind_pending_action):
		if mapped is InputEventKey:
			old_key = mapped.physical_keycode
			break
	if old_key == 0:
		cancel_rebind_swap()
		return
	Save.settings.keys[rebind_pending_action] = rebind_pending_key
	Save.settings.keys[rebind_conflict_action] = old_key
	InputConfig.setup(Save.settings.keys)
	Save.store_settings()
	cancel_rebind_swap()

func cancel_rebind_swap() -> void:
	reset_rebind()
	show_controls(settings_return)

func reset_rebind() -> void:
	rebind_action = ""
	rebind_pending_action = ""
	rebind_conflict_action = ""
	rebind_pending_key = 0

func show_credits() -> void:
	var box := menu_box("CHRONUS", "Créditos desta versão",true)
	var text := label("Conceito, personagens e direção: documentação oficial do projeto.\nArte: recortes das pranchas fornecidas pelo autor.\nImplementação e processamento: assistência de Codex.\nÁudio: síntese original provisória, sem samples externos.\nEngine: Godot, licença MIT. Fonte: padrão da engine.\n\nAnimações, UI e áudio permanecem em produção.",13)
	box.add_child(text)
	button(box,"Voltar",show_menu).grab_focus()

func show_death(in_memory: bool) -> void:
	screen = "death"
	var box := menu_box("A memória falhou" if in_memory else "Você caiu", "Retome o gesto." if in_memory else "O caminho permanece.")
	button(box,"Repetir a memória" if in_memory else "Retornar ao descanso",func():
		clear_overlay(); screen="game"; world.respawn()).grab_focus()
	button(box,"Voltar ao menu",show_menu)

func show_complete() -> void:
	screen = "complete"
	var box := menu_box("CAPÍTULO I — FIM","PRIMAVERA",true)
	box.add_child(label("Daigo cede a passagem. A dúvida segue com Ren.",15))
	box.add_child(label("O mesmo caminho. Outro peso.",13))
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 25
	box.add_child(spacer)
	button(box,"Progressão",func(): show_progression("complete"))
	button(box,"Voltar ao menu",show_menu).grab_focus()

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		gamepad = true
	elif event is InputEventKey:
		gamepad = false
	if is_instance_valid(world):
		world.pad = gamepad
	if screen == "controls_conflict" and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		cancel_rebind_swap()
		get_viewport().set_input_as_handled()
		return
	if not rebind_action.is_empty() and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode != KEY_ESCAPE:
			var conflict := ""
			for action in InputConfig.KEYS:
				if action == rebind_action:
					continue
				for mapped in InputMap.action_get_events(action):
					if mapped is InputEventKey and mapped.physical_keycode == event.physical_keycode:
						conflict = action
						break
				if not conflict.is_empty():
					break
			if not conflict.is_empty():
				rebind_pending_action = rebind_action
				rebind_conflict_action = conflict
				rebind_pending_key = event.physical_keycode
				rebind_action = ""
				show_rebind_conflict()
				get_viewport().set_input_as_handled()
				return
			Save.settings.keys[rebind_action] = event.physical_keycode
			InputConfig.setup(Save.settings.keys)
			Save.store_settings()
		rebind_action = ""
		show_controls(settings_return)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause"):
		if screen=="game":
			show_pause()
		elif screen=="pause":
			resume()
		elif screen in ["settings","controls","progression"]:
			return_to(settings_return)
		elif screen == "controls_conflict":
			cancel_rebind_swap()
		get_viewport().set_input_as_handled()
	if screen=="dialogue" and event.is_action_pressed("interact"):
		advance_dialogue()
		get_viewport().set_input_as_handled()
	if OS.is_debug_build() and event is InputEventKey and event.pressed and is_instance_valid(world):
		if event.keycode==KEY_F3:
			world.debug_mode = not world.debug_mode
		if event.keycode==KEY_F6 and world.debug_mode:
			world.respawn()

func _draw() -> void:
	# World-space flash intentionally optional; no information relies on it.
	if is_instance_valid(world) and world.hitstop>0 and Save.settings.flashes:
		draw_rect(Rect2(world.camera.position-Vector2(320,180),Vector2(640,360)),Color(0.6,0.8,1,0.1))
