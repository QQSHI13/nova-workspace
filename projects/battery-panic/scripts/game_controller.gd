extends Node2D

# Battery Panic - Main Game Controller (Polished Version)
# Turn-based with real-time toggle, multi-device support, full polish

@export var starting_battery: float = 15.0
@export var time_limit: float = 1200.0  # 20 minutes in seconds
@export var real_time_mode: bool = false  # Toggle for real-time

# Signals
signal battery_changed(new_value: float)
signal time_changed(new_value: float)
signal score_changed(new_score: int)
signal task_completed(task_name: String)
signal turn_ended
signal game_over(win: bool, final_score: int)

var current_battery: float
var current_time: float
var score: int = 0
var tasks_completed: int = 0
var _completed_task_ids: Array[int] = []
var _is_player_turn: bool = true

# Tasks - now shown as post-it notes
const TASKS = [
	{"name": "发送紧急邮件", "time": 180, "battery": 2, "priority": 3, "icon": "📧"},
	{"name": "保存文档", "time": 60, "battery": 1, "priority": 3, "icon": "💾"},
	{"name": "关闭Chrome标签", "time": 30, "battery": -3, "priority": 2, "icon": "🌐"},
	{"name": "调低屏幕亮度", "time": 10, "battery": -5, "priority": 2, "icon": "🔆"},
	{"name": "下载文件", "time": 600, "battery": 4, "priority": 1, "icon": "⬇️"},
	{"name": "刷B站", "time": 900, "battery": 8, "priority": 0, "icon": "📺"}
]

@onready var device_screen = $UI/DeviceScreen
@onready var post_it_notes = $UI/PostItNotes
@onready var os_ui = $UI/OS_UI
@onready var terminal = $UI/DeviceScreen/Terminal
@onready var time_label = $UI/TimeLabel
@onready var score_label = $UI/ScoreLabel
@onready var mode_button = $UI/ModeButton
@onready var flash_overlay = $FlashOverlay

func _ready() -> void:
	current_battery = starting_battery
	current_time = time_limit

	# Connect signals
	device_screen.element_clicked.connect(_on_element_clicked)
	post_it_notes.note_clicked.connect(_on_note_clicked)
	terminal.command_executed.connect(_on_terminal_command)
	mode_button.pressed.connect(_toggle_mode)

	# Spawn post-it notes for tasks
	_spawn_post_it_notes()

	# Initial UI update
	_update_ui()

	# Start animation
	AnimationManager.fade_in($UI)

	print("游戏开始！电池: ", current_battery, "%")
	print("你有20分钟完成关键任务！")

func _process(delta: float) -> void:
	if real_time_mode and _is_player_turn:
		# In real-time mode, drain continuously
		current_time -= delta
		current_battery -= delta * 0.005

		_update_ui()

		if current_battery <= 0:
			_trigger_game_over(false)
		elif current_time <= 0:
			_trigger_game_over(true)

func _spawn_post_it_notes() -> void:
	for i in range(TASKS.size()):
		var task = TASKS[i]
		var note_id = post_it_notes.add_note(task["icon"] + " " + task["name"], -task["battery"])
		# Slide in animation
		AnimationManager.slide_in(post_it_notes.get_node("NotesContainer/Note_%d" % note_id), true, 0.5 + i * 0.1)

func _on_element_clicked(element_name: String) -> void:
	# Direct click on OS element
	print("Clicked: " + element_name)
	_handle_action(element_name)

func _on_note_clicked(note_id: int, task_name: String) -> void:
	# Click on post-it note - bounce effect
	var note = post_it_notes.get_node("NotesContainer/Note_%d" % note_id)
	AnimationManager.bounce(note)
	print("Post-it clicked: " + task_name)
	_handle_action_by_name(task_name)

func _on_terminal_command(command: String, success: bool) -> void:
	if success:
		# Parse command and apply effects
		_handle_terminal_command(command)
		_end_turn()

func _handle_action(element_name: String) -> void:
	# Map element clicks to actions
	match element_name:
		"Chrome":
			_execute_task(2)  # Close Chrome tabs
		"Settings":
			_execute_task(3)  # Dim screen
		"Mail":
			_execute_task(0)  # Send email
		"Files":
			_execute_task(1)  # Save document
		_:
			print("Unknown action: " + element_name)

func _handle_action_by_name(task_name: String) -> void:
	for i in range(TASKS.size()):
		if TASKS[i]["name"] == task_name and not _completed_task_ids.has(i):
			_execute_task(i)
			return

func _handle_terminal_command(command: String) -> void:
	# Apply effects based on terminal command
	if command.begins_with("brightness"):
		current_battery += 5.0  # Save battery
		ParticleEffects.spawn_battery_save_effect(Vector2(960, 540), 5.0)
		print("Brightness lowered, battery +5%")
	elif command.begins_with("killall"):
		current_battery += 3.0
		ParticleEffects.spawn_battery_save_effect(Vector2(960, 540), 3.0)
		print("App killed, battery +3%")
	elif command.begins_with("wifi off"):
		current_battery += 2.0
		ParticleEffects.spawn_battery_save_effect(Vector2(960, 540), 2.0)
		print("WiFi off, battery +2%")

func _execute_task(task_id: int) -> void:
	if _completed_task_ids.has(task_id):
		return

	var task = TASKS[task_id]

	# Validate affordability
	if current_battery < task["battery"] or current_time < task["time"]:
		SoundManager.play_sfx("task_fail")
		AnimationManager.flash_color($UI, Color(1, 0, 0, 0.3), 0.3)
		return

	# Execute task
	var old_battery = current_battery
	current_battery -= task["battery"]
	current_time -= task["time"]
	tasks_completed += 1
	score += task["priority"] * 100
	_completed_task_ids.append(task_id)

	# Visual effects based on battery change
	if current_battery > old_battery:
		# Battery saved - green particles
		ParticleEffects.spawn_battery_save_effect(Vector2(600, 400), abs(task["battery"]))
		flash_overlay.flash_green(0.3, 0.3)
	else:
		# Battery drained - red particles
		ParticleEffects.spawn_battery_drain_effect(Vector2(600, 400), abs(task["battery"]))
		flash_overlay.flash_red(0.2, 0.2)

	# Remove post-it with fade out
	post_it_notes.remove_note_with_animation(task_id)

	# Update UI with animation
	AnimationManager.animate_number(score_label, score - task["priority"] * 100, score, 0.5, "Score: ")
	_update_ui()

	# Play sounds
	SoundManager.play_sfx("task_complete")
	AnimationManager.pulse_scale(score_label, 1.1, 0.3)

	print("完成任务: ", task["name"], " | 剩余电池: ", current_battery, "%")

	# Check for critical battery - screen shake
	if current_battery < 5.0:
		AnimationManager.screen_shake(self, 15.0, 0.5)
		ParticleEffects.spawn_critical_warning_effect(Vector2(600, 400))
		flash_overlay.flash_red(0.6, 0.5)
		flash_overlay.pulse_warning()
	elif current_battery < 10.0:
		AnimationManager.screen_shake(self, 5.0, 0.3)
		flash_overlay.flash_yellow(0.3, 0.3)

	# End turn
	_end_turn()

func _end_turn() -> void:
	if not real_time_mode:
		# In turn-based mode, wait for player
		pass

	turn_ended.emit()

	# Check win/lose
	if tasks_completed >= 3:
		_trigger_game_over(true)

func _update_ui() -> void:
	# Update time display
	var minutes = int(current_time) / 60
	var seconds = int(current_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

	# Update score
	score_label.text = "Score: %d" % score

	# Update OS battery display
	os_ui.update_battery(current_battery)

	# Emit signals
	battery_changed.emit(current_battery)
	time_changed.emit(current_time)

func _toggle_mode() -> void:
	real_time_mode = not real_time_mode
	mode_button.text = "Mode: Real-Time" if real_time_mode else "Mode: Turn-Based"

	# Pulse animation on button
	AnimationManager.pulse_scale(mode_button, 1.05, 0.2)

func _trigger_game_over(win: bool) -> void:
	game_over.emit(win, score)

	# Success or failure effects
	if win:
		SoundManager.play_sfx("game_over_win")
		ParticleEffects.spawn_success_effect(Vector2(960, 540))
		flash_overlay.flash_green(0.5, 1.0)
		print("成功！你在电池耗尽前完成了任务！")
	else:
		SoundManager.play_sfx("game_over_lose")
		ParticleEffects.spawn_critical_warning_effect(Vector2(960, 540))
		AnimationManager.screen_shake(self, 20.0, 1.0)
		flash_overlay.flash_red(0.8, 1.5)
		print("失败！电池耗尽了...")

	# Show game over panel with animation
	var game_over_panel = $UI/GameOverPanel
	game_over_panel.visible = true
	AnimationManager.fade_in(game_over_panel)

	get_tree().paused = true
