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

var task_buttons: Array[Button] = []

@onready var screens = $Screens
@onready var hud = $HUD

func _ready():
	# Menu buttons
	var play_btn = screens.get_node_or_null("Menu/PlayButton")
	if play_btn:
		play_btn.pressed.connect(_start_game)

	var quit_btn = screens.get_node_or_null("Menu/QuitButton")
	if quit_btn:
		quit_btn.pressed.connect(get_tree().quit)

	# Game over restart button (inside Panel)
	var restart_btn = screens.get_node_or_null("GameOverScreen/Panel/RestartBtn")
	if restart_btn:
		restart_btn.pressed.connect(_restart)

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

	# Setup task buttons
	_setup_tasks()

	_show_screen("Menu")

func _setup_tasks():
	var task_list = hud.get_node_or_null("TasksPanel/TaskList")
	if not task_list:
		return

	# Clear existing
	for child in task_list.get_children():
		child.queue_free()
	task_buttons.clear()

	for i in tasks.size():
		var task = tasks[i]
		var btn = Button.new()
		btn.text = "%s\n⚡ %d%% battery  •  ⏱ %ds" % [task.name, task.battery, task.time]
		btn.custom_minimum_size = Vector2(320, 70)
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(_do_task.bind(i))
		task_list.add_child(btn)
		task_buttons.append(btn)

		_update_task_button_style(i)

func _update_task_button_style(idx: int):
	if idx < 0 or idx >= task_buttons.size():
		return

	var btn = task_buttons[idx]
	var task = tasks[idx]

	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8

	if task.done:
		style.bg_color = Color(0.2, 0.5, 0.3, 0.6)
		btn.disabled = true
		btn.text = "✓ " + task.name + " (DONE)"
	elif battery < task.battery or time_left < task.time:
		style.bg_color = Color(0.5, 0.2, 0.2, 0.4)
	else:
		style.bg_color = Color(0.2, 0.3, 0.5, 0.6)

	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)

func _start_game():
	battery = START_BATTERY
	time_left = START_TIME
	game_running = true

	# Reset tasks
	for t in tasks:
		t.done = false

	# Reset apps
	for id in apps:
		apps[id].open = true
		_show_app_window(id, true)

	_setup_tasks()
	_update_hud()
	_update_taskbar()
	_show_screen("Game")

func _close_app(id: String):
	if not game_running:
		return
	if not apps.has(id):
		return
	apps[id].open = false
	_show_app_window(id, false)
	_update_taskbar()

func _toggle_app(id: String):
	if not game_running:
		return
	if not apps.has(id):
		return
	apps[id].open = !apps[id].open
	_show_app_window(id, apps[id].open)
	_update_taskbar()

func _show_app_window(id: String, show: bool):
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

func _update_taskbar():
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

func _do_task(idx: int):
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

	_update_task_button_style(idx)
	_flash(Color(0.2, 1, 0.3, 0.3))
	_update_hud()

func _process(delta):
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

func _update_hud():
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
		if battery < 20:
			tray_battery.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
		else:
			tray_battery.add_theme_color_override("font_color", Color(0.9, 0.9, 0.2))

	# Update clock
	var clock = screens.get_node_or_null("GameScreen/Taskbar/SystemTray/Clock")
	if clock:
		var total_m = int(START_TIME - time_left) / 60
		var total_s = int(START_TIME - time_left) % 60
		clock.text = "%d:%02d" % [2 + total_m, total_s]

	# Update task availability
	for i in tasks.size():
		_update_task_button_style(i)

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

func _game_over(win: bool, message: String):
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

func _flash(col: Color):
	var f = hud.get_node_or_null("FlashOverlay")
	if not f:
		return
	f.color = col
	f.visible = true

	var t = create_tween()
	t.tween_property(f, "color:a", 0.0, 0.4)
	t.tween_callback(func(): f.visible = false)

func _restart():
	_start_game()

func _show_screen(name: String):
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
