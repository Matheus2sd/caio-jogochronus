extends SceneTree

func _initialize() -> void:
	call_deferred("run_check")

func run_check() -> void:
	var user_path := ProjectSettings.globalize_path("user://")
	var project_root := ProjectSettings.globalize_path("res://project.godot").get_base_dir().get_base_dir()
	var isolated_profile := project_root.path_join("tools/local/profile").replace("\\", "/")
	if not user_path.replace("\\", "/").begins_with(isolated_profile):
		fail_test("Refusing to touch the user's real save; set APPDATA to tools/local/profile")
		return
	var save = root.get_node("Save")
	save.new_campaign()
	if not FileAccess.file_exists("user://chapter1.json") or save.read_campaign("user://chapter1.json").get("checkpoint", -1) != 0:
		fail_test("new campaign did not persist to user://")
		return
	save.progress.checkpoint = 2
	if not save.store_campaign() or save.read_campaign("user://chapter1.json").get("checkpoint", -1) != 2:
		fail_test("checkpoint did not persist")
		return
	if save.read_campaign("user://chapter1.json.backup").get("checkpoint", -1) != 0:
		fail_test("previous campaign backup was not kept")
		return
	var chapter = load("res://scripts/chapter.gd").new()
	chapter.finish_chapter()
	var completed_save: Dictionary = save.read_campaign("user://chapter1.json")
	if completed_save.get("marks", 0) != 1 or not completed_save.get("chapter1_mark_awarded", false) or not completed_save.get("complete", false):
		fail_test("Chapter I completion and mark did not persist")
		return
	save.progress = completed_save
	chapter.finish_chapter()
	if save.read_campaign("user://chapter1.json").get("marks", 0) != 1:
		fail_test("reloaded completion duplicated the Chapter I mark")
		return
	chapter.free()
	save.progress = {"version": 1, "checkpoint": 3, "complete": true, "daigo_defeated": true}
	save.store_campaign()
	var legacy_chapter = load("res://scripts/chapter.gd").new()
	root.add_child(legacy_chapter)
	legacy_chapter.begin(false)
	var migrated_save: Dictionary = save.read_campaign("user://chapter1.json")
	if migrated_save.get("marks", 0) != 1 or not migrated_save.get("chapter1_mark_awarded", false):
		fail_test("completed legacy save did not persist its missing mark")
		return
	legacy_chapter.begin(false)
	if save.read_campaign("user://chapter1.json").get("marks", 0) != 1:
		fail_test("loading completed legacy save twice duplicated the mark")
		return
	legacy_chapter.queue_free()
	save.settings.parry_assist = true
	save.store_settings()
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") != OK or not config.get_value("settings", "parry_assist", false):
		fail_test("settings did not persist")
		return
	print("SAVE PASS: isolated user:// campaign, checkpoint, backup, completion mark, legacy migration, settings")
	quit(0)

func fail_test(reason: String) -> void:
	push_error("SAVE FAIL: " + reason)
	quit(1)
