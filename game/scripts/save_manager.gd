extends Node
## One campaign, settings independent, previous valid campaign as fallback.
var test_mode := false
var progress: Dictionary = {}
var settings: Dictionary = {
	"fullscreen": false, "vsync": true, "master": 0.8, "music": 0.45,
	"sfx": 0.8, "ambient": 0.6, "shake": true, "flashes": false,
	"large_text": false, "parry_assist": false, "damage_assist": false,
	"keys": {}
}
const SAVE_PATH = "user://chapter1.json"
const SETTINGS_PATH = "user://settings.cfg"

func _ready() -> void:
	test_mode = "--test" in OS.get_cmdline_user_args()
	if test_mode:
		return
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		for key in settings:
			settings[key] = config.get_value("settings", key, settings[key])
	progress = read_campaign(SAVE_PATH)
	if progress.is_empty():
		progress = read_campaign(SAVE_PATH + ".backup")
	apply_settings()

func read_campaign(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if data is Dictionary and data.get("version", 0) == 1 and int(data.get("checkpoint", -1)) in [0, 2, 3]:
		return data
	return {}

func new_campaign() -> void:
	progress = {"version": 1, "checkpoint": 0, "echo_done": false,
		"garca": false, "garca_equipped": false, "daigo_intro": false,
		"daigo_defeated": false, "complete": false,
		"marks": 0, "chapter1_mark_awarded": false, "upgrades": []}
	store_campaign()

func has_upgrade(key: String) -> bool:
	return key in progress.get("upgrades", [])

func available_marks() -> int:
	return maxi(0, int(progress.get("marks", 0)) - progress.get("upgrades", []).size())

func set_upgrade(key: String, enabled: bool) -> bool:
	if key not in ["l1", "l2", "l3"] or progress.is_empty():
		return false
	var upgrades: Array = progress.get("upgrades", []).duplicate()
	if enabled:
		if key in upgrades or available_marks() <= 0:
			return false
		upgrades.append(key)
	else:
		if key not in upgrades:
			return false
		upgrades.erase(key)
	var previous: Array = progress.get("upgrades", []).duplicate()
	progress.upgrades = upgrades
	if store_campaign():
		return true
	progress.upgrades = previous
	return false

func award_chapter1_mark() -> bool:
	if progress.get("chapter1_mark_awarded", false):
		return false
	progress.marks = mini(3, int(progress.get("marks", 0)) + 1)
	progress.chapter1_mark_awarded = true
	return true

func store_campaign() -> bool:
	if test_mode:
		return true
	var temp := SAVE_PATH + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		push_error("Não foi possível gravar o progresso.")
		return false
	file.store_string(JSON.stringify(progress))
	file.close()
	if not read_campaign(SAVE_PATH).is_empty():
		DirAccess.copy_absolute(SAVE_PATH, SAVE_PATH + ".backup")
	return DirAccess.rename_absolute(temp, SAVE_PATH) == OK

func store_settings() -> void:
	apply_settings()
	if test_mode:
		return
	var config := ConfigFile.new()
	for key in settings:
		config.set_value("settings", key, settings[key])
	config.save(SETTINGS_PATH)

func apply_settings() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings.vsync else DisplayServer.VSYNC_DISABLED)
	for pair in [["Master", "master"], ["Music", "music"], ["SFX", "sfx"], ["Ambient", "ambient"]]:
		var index := AudioServer.get_bus_index(pair[0])
		if index >= 0:
			AudioServer.set_bus_volume_db(index, linear_to_db(maxf(0.001, float(settings[pair[1]]))))
