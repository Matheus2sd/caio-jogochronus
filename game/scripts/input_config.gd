extends RefCounted
const KEYS = {
	"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
	"jump": [KEY_SPACE], "dodge": [KEY_SHIFT], "light_attack": [KEY_J],
	"heavy_attack": [KEY_K], "guard": [KEY_L], "interact": [KEY_E],
	"heal": [KEY_H], "pause": [KEY_ESCAPE], "run": [KEY_CTRL]
}
const BUTTONS = {"jump": JOY_BUTTON_A, "dodge": JOY_BUTTON_B,
	"light_attack": JOY_BUTTON_X, "heavy_attack": JOY_BUTTON_Y,
	"guard": JOY_BUTTON_LEFT_SHOULDER, "interact": JOY_BUTTON_RIGHT_SHOULDER,
	"heal": JOY_BUTTON_DPAD_UP, "pause": JOY_BUTTON_START, "run": JOY_BUTTON_LEFT_STICK,
	"move_left": JOY_BUTTON_DPAD_LEFT, "move_right": JOY_BUTTON_DPAD_RIGHT}

static func setup(overrides: Dictionary) -> void:
	for action in KEYS:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.2)
		InputMap.action_erase_events(action)
		var keys = [int(overrides[action])] if overrides.has(action) else KEYS[action]
		for key in keys:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
		var button := InputEventJoypadButton.new()
		button.button_index = BUTTONS[action]
		InputMap.action_add_event(action, button)
	for action in ["move_left", "move_right"]:
		var event := InputEventJoypadMotion.new()
		event.axis = JOY_AXIS_LEFT_X
		event.axis_value = -1 if action == "move_left" else 1
		InputMap.action_add_event(action, event)
	for action in ["light_attack", "heavy_attack"]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT if action == "light_attack" else MOUSE_BUTTON_RIGHT
		InputMap.action_add_event(action, event)

static func prompt(action: String, pad: bool = false) -> String:
	if pad:
		return {"move_left":"←", "move_right":"→", "jump":"A", "dodge":"B",
			"light_attack":"X", "heavy_attack":"Y", "guard":"LB", "interact":"RB",
			"heal":"↑", "pause":"Start", "run":"L3"}.get(action, action)
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode)
	return action
