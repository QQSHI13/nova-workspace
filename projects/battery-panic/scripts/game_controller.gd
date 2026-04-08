extends Node2D

# Battery Panic - Realistic OS Desktop Game
# A polished game where you manage a dying laptop

const START_BATTERY = 30.0
const START_TIME = 120.0

var battery: float
var time_left: float
var game_running: bool = false

# Apps with realistic drain rates - BALANCED for gameplay
var apps = {
	"chrome": {"name": "Chrome", "drain": 0.025, "open": true, "window": "ChromeWindow", "task": "ChromeTask"},
	"vscode": {"name": "VS Code", "drain": 0.015, "open": true, "window": "CodeWindow", "task": "CodeTask"},
	"slack": {"name": "Slack", "drain": 0.012, "open": true, "window": "SlackWindow", "task": "SlackTask"},
	"spotify": {"name": "Spotify", "drain": 0.008, "open": true, "window": "SpotifyWindow", "task": "SpotifyTask"},
}

var tasks = [
	{"name": "Email Boss", "battery": 4, "time": 15, "done": false},
	{"name": "Save Project", "battery": 3, "time": 10, "done": false},
	{"name": "Git Commit", "battery": 2, "time": 8, "done": false},
]

var task_panels: Array[Panel] = []
var task_buttons: Dictionary = {}  # app -> Button for task triggers

var _prev_battery: float = -1.0
var _prev_time: float = -1.0
var _prev_tray_warn: bool = false
var _bezel: CanvasLayer = null
var _bezel_camera: ColorRect = null
var _bezel_led: ColorRect = null

@onready var screens = $Screens
@onready var hud = $HUD

func _ready() -> void:
	# Menu buttons
	var play_btn = screens.get_node_or_null("Menu/PlayButton")
	if play_btn:
		play_btn.pressed.connect(_start_game)

	var quit_btn = screens.get_node_or_null("Menu/QuitButton")
	if quit_btn:
		quit_btn.pressed.connect(get_tree().quit)

	# Game over buttons (inside Panel)
	var tips_btn = screens.get_node_or_null("GameOverScreen/Panel/TipsBtn")
	if tips_btn:
		tips_btn.pressed.connect(_show_tips)

	var restart_btn = screens.get_node_or_null("GameOverScreen/Panel/RestartBtn")
	if restart_btn:
		restart_btn.pressed.connect(_start_game)

	# Window close buttons
	for app_id in apps:
		var app = apps[app_id]
		var window = screens.get_node_or_null("GameScreen/AppWindows/" + app.window)
		if window:
			var close_btn = window.get_node_or_null("TitleBar/CloseBtn")
			if close_btn:
				close_btn.pressed.connect(_close_app.bind(app_id))

			var minimize_btn = window.get_node_or_null("TitleBar/MinimizeBtn")
			if minimize_btn:
				minimize_btn.pressed.connect(_toggle_app.bind(app_id))

		var task_btn = screens.get_node_or_null("GameScreen/Taskbar/TaskbarApps/" + app.task)
		if task_btn:
			task_btn.pressed.connect(_toggle_app.bind(app_id))

	_setup_monitor_bezel()
	_setup_tasks()
	_setup_task_triggers()
	_setup_post_it_notes()

	_show_screen("Menu")

func _setup_tasks() -> void:
	var task_list = hud.get_node_or_null("TasksPanel/TaskList")
	if not task_list:
		return

	# Clear existing immediately
	for child in task_list.get_children():
		child.free()
	task_panels.clear()

	for i in tasks.size():
		var task = tasks[i]
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(320, 70)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var label = Label.new()
		label.text = "%s\n⚡ %d%% battery  •  ⏱ %ds" % [task.name, task.battery, task.time]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size = Vector2(320, 70)
		label.add_theme_font_size_override("font_size", 16)
		label.name = "TaskLabel"
		panel.add_child(label)

		task_list.add_child(panel)
		task_panels.append(panel)

		_update_task_panel_style(i)

func _update_task_panel_style(idx: int) -> void:
	if idx < 0 or idx >= task_panels.size():
		return

	var panel = task_panels[idx]
	var task = tasks[idx]
	var label = panel.get_node_or_null("TaskLabel")

	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8

	if task.done:
		style.bg_color = Color(0.2, 0.5, 0.3, 0.6)
		if label:
			label.text = "✓ " + task.name + " (DONE)"
			label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.7))
	elif battery < task.battery or time_left < task.time:
		style.bg_color = Color(0.5, 0.2, 0.2, 0.4)
		if label:
			label.add_theme_color_override("font_color", Color(0.9, 0.6, 0.6))
	else:
		style.bg_color = Color(0.2, 0.3, 0.5, 0.6)
		if label:
			label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))

	panel.add_theme_stylebox_override("panel", style)

func _setup_monitor_bezel() -> void:
	if _bezel:
		_bezel.queue_free()

	_bezel = CanvasLayer.new()
	_bezel.name = "MonitorBezel"
	_bezel.layer = 20

	var frame = Panel.new()
	frame.name = "Frame"
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = Color(0.12, 0.12, 0.14)
	style.border_width_left = 40
	style.border_width_right = 40
	style.border_width_top = 50
	style.border_width_bottom = 60
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	frame.add_theme_stylebox_override("panel", style)

	# Camera dot
	_bezel_camera = ColorRect.new()
	_bezel_camera.name = "CameraDot"
	_bezel_camera.color = Color(0.08, 0.08, 0.1)
	_bezel_camera.size = Vector2(12, 12)
	_bezel_camera.position = Vector2(get_viewport().get_visible_rect().size.x * 0.5 - 6, 20)
	_bezel_camera.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Power LED
	_bezel_led = ColorRect.new()
	_bezel_led.name = "PowerLED"
	_bezel_led.color = Color(0.2, 0.9, 0.3)
	_bezel_led.size = Vector2(10, 10)
	_bezel_led.position = Vector2(get_viewport().get_visible_rect().size.x - 50, get_viewport().get_visible_rect().size.y - 50)
	_bezel_led.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_bezel.add_child(frame)
	_bezel.add_child(_bezel_camera)
	_bezel.add_child(_bezel_led)
	add_child(_bezel)

	if not get_viewport().size_changed.is_connected(_on_resize_bezel):
		get_viewport().size_changed.connect(_on_resize_bezel)

func _on_resize_bezel() -> void:
	if _bezel_camera:
		_bezel_camera.position = Vector2(get_viewport().get_visible_rect().size.x * 0.5 - 6, 20)
	if _bezel_led:
		_bezel_led.position = Vector2(get_viewport().get_visible_rect().size.x - 50, get_viewport().get_visible_rect().size.y - 50)

func _setup_post_it_notes() -> void:
	var existing = get_node_or_null("PostItNotes")
	if existing:
		existing.queue_free()

	var post_it_scene = load("res://scenes/post_it_notes.tscn")
	if not post_it_scene:
		return

	var notes = post_it_scene.instantiate()
	notes.name = "PostItNotes"
	add_child(notes)

	# Add task notes (must be after add_child so @onready vars are initialized)
	for task in tasks:
		var save = -task.battery  # negative cost = "saving" display
		notes.add_note(task.name, save, "urgent" if task.battery >= 4 else "task")

func _setup_task_triggers() -> void:
	# Clear old tracked buttons
	for btn in task_buttons.values():
		if is_instance_valid(btn):
			btn.free()
	task_buttons.clear()

	# Email Boss trigger inside Chrome window
	var chrome_content = screens.get_node_or_null("GameScreen/AppWindows/ChromeWindow/Content")
	if chrome_content:
		var existing = chrome_content.get_node_or_null("TaskBtn_Email")
		if existing:
			existing.free()
		var btn = Button.new()
		btn.name = "TaskBtn_Email"
		btn.text = "📧 Email Boss"
		btn.position = Vector2(20, 280)
		btn.size = Vector2(180, 40)
		btn.add_theme_font_size_override("font_size", 14)
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.2, 0.4, 0.8)
		btn_style.corner_radius_top_left = 6
		btn_style.corner_radius_top_right = 6
		btn_style.corner_radius_bottom_left = 6
		btn_style.corner_radius_bottom_right = 6
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.pressed.connect(_do_task.bind(0))
		chrome_content.add_child(btn)
		task_buttons["email"] = btn

	# Save Project & Git Commit triggers inside VS Code: window
	var code_content = screens.get_node_or_null("GameScreen/AppWindows/CodeWindow/Content")
	if code_content:
		var existing_save = code_content.get_node_or_null("TaskBtn_Save")
		if existing_save:
			existing_save.free()
		var existing_commit = code_content.get_node_or_null("TaskBtn_Commit")
		if existing_commit:
			existing_commit.free()

		var save_btn = Button.new()
		save_btn.name = "TaskBtn_Save"
		save_btn.text = "💾 Save Project"
		save_btn.position = Vector2(20, 280)
		save_btn.size = Vector2(160, 36)
		save_btn.add_theme_font_size_override("font_size", 13)
		var save_style = StyleBoxFlat.new()
		save_style.bg_color = Color(0.1, 0.5, 0.9)
		save_style.corner_radius_top_left = 6
		save_style.corner_radius_top_right = 6
		save_style.corner_radius_bottom_left = 6
		save_style.corner_radius_bottom_right = 6
		save_btn.add_theme_stylebox_override("normal", save_style)
		save_btn.pressed.connect(_do_task.bind(1))
		code_content.add_child(save_btn)
		task_buttons["save"] = save_btn

		var commit_btn = Button.new()
		commit_btn.name = "TaskBtn_Commit"
		commit_btn.text = "📝 Git Commit"
		commit_btn.position = Vector2(20, 325)
		commit_btn.size = Vector2(160, 36)
		commit_btn.add_theme_font_size_override("font_size", 13)
		var commit_style = StyleBoxFlat.new()
		commit_style.bg_color = Color(0.2, 0.6, 0.4)
		commit_style.corner_radius_top_left = 6
		commit_style.corner_radius_top_right = 6
		commit_style.corner_radius_bottom_left = 6
		commit_style.corner_radius_bottom_right = 6
		commit_btn.add_theme_stylebox_override("normal", commit_style)
		commit_btn.pressed.connect(_do_task.bind(2))
		code_content.add_child(commit_btn)
		task_buttons["commit"] = commit_btn

func _update_task_button_disabled_states() -> void:
	if task_buttons.has("email"):
		task_buttons["email"].disabled = tasks[0].done
	if task_buttons.has("save"):
		task_buttons["save"].disabled = tasks[1].done
	if task_buttons.has("commit"):
		task_buttons["commit"].disabled = tasks[2].done

func _start_game() -> void:
	battery = START_BATTERY
	time_left = START_TIME
	game_running = true
	_prev_battery = -1.0
	_prev_time = -1.0
	_prev_tray_warn = true  # force color refresh on first frame

	# Reset tasks
	for t in tasks:
		t.done = false

	# Reset apps
	for id in apps:
		apps[id].open = true
		_show_app_window(id, true)

	_setup_tasks()
	_setup_post_it_notes()
	_setup_task_triggers()
	_update_hud()
	_update_taskbar()
	_show_screen("Game")

func _close_app(id: String) -> void:
	if not game_running:
		return
	if not apps.has(id):
		return
	apps[id].open = false
	_show_app_window(id, false)
	_update_taskbar()

func _toggle_app(id: String) -> void:
	if not game_running:
		return
	if not apps.has(id):
		return
	apps[id].open = !apps[id].open
	_show_app_window(id, apps[id].open)
	_update_taskbar()

func _show_app_window(id: String, show: bool) -> void:
	if not apps.has(id):
		return
	var window = screens.get_node_or_null("GameScreen/AppWindows/" + apps[id].window)
	if not window:
		return

	window.visible = show

	if show:
		# Animate in
		window.scale = Vector2(0.9, 0.9)
		window.modulate.a = 0.0
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(window, "scale", Vector2(1, 1), 0.2)
		tween.tween_property(window, "modulate:a", 1.0, 0.2)

func _update_taskbar() -> void:
	for id in apps:
		var task_btn = screens.get_node_or_null("GameScreen/Taskbar/TaskbarApps/" + apps[id].task)
		if not task_btn:
			continue

		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4

		if apps[id].open:
			style.bg_color = Color(0.3, 0.4, 0.6, 0.8)
			task_btn.add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			style.bg_color = Color(0.15, 0.17, 0.2, 0.5)
			task_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

		task_btn.add_theme_stylebox_override("normal", style)

func _do_task(idx: int) -> void:
	if not game_running:
		return

	if idx < 0 or idx >= tasks.size():
		return

	var task = tasks[idx]
	if task.done:
		return

	if battery < task.battery or time_left < task.time:
		_flash(Color(1, 0.2, 0.2, 0.4))
		return

	battery -= task.battery
	time_left -= task.time
	task.done = true

	_update_task_panel_style(idx)
	_flash(Color(0.2, 1, 0.3, 0.3))
	_update_hud()

func _process(delta: float) -> void:
	if not game_running:
		return

	# Drain battery from open apps
	var drain = 0.0
	for id in apps:
		if apps[id].open:
			drain += apps[id].drain
	battery -= drain * delta * 60

	time_left -= delta
	_update_hud()

	# Check end conditions
	if battery <= 0:
		_game_over(false, "Battery depleted!")
	elif time_left <= 0:
		_game_over(false, "Time's up!")
	elif _all_tasks_done():
		_game_over(true, "All tasks completed!")

func _update_hud() -> void:
	var battery_bar = hud.get_node_or_null("TopBar/BatteryPanel/ProgressBar")
	var battery_label = hud.get_node_or_null("TopBar/BatteryPanel/Label")

	if battery_bar:
		battery_bar.value = max(0, battery)
	if battery_label:
		battery_label.text = "%.0f%%" % max(0, battery)

	# Battery color
	if battery_bar:
		var battery_col = Color(0.2, 0.9, 0.3) if battery > 50 else Color(0.9, 0.9, 0.2) if battery > 20 else Color(0.9, 0.2, 0.2)
		battery_bar.modulate = battery_col

	# Time display
	var time_label = hud.get_node_or_null("TopBar/TimePanel/Label")
	if time_label:
		var m = int(time_left) / 60
		var s = int(time_left) % 60
		time_label.text = "%d:%02d" % [m, s]

	# Update taskbar battery
	var tray_battery = screens.get_node_or_null("GameScreen/Taskbar/SystemTray/Battery")
	if tray_battery:
		tray_battery.text = "🔋 %.0f%%" % max(0, battery)
		var is_warn = battery < 20.0
		if is_warn != _prev_tray_warn:
			tray_battery.add_theme_color_override("font_color", Color(1, 0.3, 0.3) if is_warn else Color(0.9, 0.9, 0.2))
			_prev_tray_warn = is_warn

	# Update clock
	var clock = screens.get_node_or_null("GameScreen/Taskbar/SystemTray/Clock")
	if clock:
		var total_m = int(START_TIME - time_left) / 60
		var total_s = int(START_TIME - time_left) % 60
		clock.text = "%d:%02d" % [2 + total_m, total_s]

	# Update task availability only when thresholds crossed
	var battery_int = int(battery)
	var time_int = int(time_left)
	if battery_int != int(_prev_battery) or time_int != int(_prev_time):
		_prev_battery = battery
		_prev_time = time_left
		for i in tasks.size():
			_update_task_panel_style(i)
		_update_task_button_disabled_states()

func _all_tasks_done() -> bool:
	for t in tasks:
		if not t.done:
			return false
	return true

func _done_count() -> int:
	var n = 0
	for t in tasks:
		if t.done:
			n += 1
	return n

func _game_over(win: bool, message: String) -> void:
	game_running = false

	var panel = screens.get_node_or_null("GameOverScreen/Panel")
	if not panel:
		return

	var title = panel.get_node_or_null("Title")
	var msg = panel.get_node_or_null("Message")
	var stats = panel.get_node_or_null("Stats")

	if title:
		if win:
			title.text = "SUCCESS!"
			title.add_theme_color_override("font_color", Color(0.2, 1, 0.3))
		else:
			title.text = "SYSTEM FAILURE"
			title.add_theme_color_override("font_color", Color(1, 0.2, 0.2))

	if msg:
		msg.text = message

	if stats:
		stats.text = "Tasks Completed: %d/%d\nBattery Remaining: %.1f%%" % [_done_count(), tasks.size(), max(0, battery)]

	_show_screen("GameOver")

func _flash(col: Color) -> void:
	var f = hud.get_node_or_null("FlashOverlay")
	if not f:
		return
	f.color = Color(col.r, col.g, col.b, col.a)
	f.visible = true

	var t = create_tween()
	t.tween_property(f, "color:a", 0.0, 0.4)
	t.tween_callback(func(): f.visible = false)

func _show_tips() -> void:
	var current = get_tree().current_scene
	if not current:
		return
	if current.get_node_or_null("BatteryTipsScreen"):
		return

	var tips_scene = load("res://scenes/battery_tips_screen.tscn")
	if tips_scene:
		var tips = tips_scene.instantiate()
		var done = _done_count()
		tips.set_game_result(battery > 0, done, battery)
		current.add_child(tips)

func _show_screen(name: String) -> void:
	var menu = screens.get_node_or_null("Menu")
	var game_screen = screens.get_node_or_null("GameScreen")
	var game_over = screens.get_node_or_null("GameOverScreen")

	if menu:
		menu.visible = (name == "Menu")
	if game_screen:
		game_screen.visible = (name == "Game")
	if game_over:
		game_over.visible = (name == "GameOver")

	if hud:
		hud.visible = (name == "Game")
