extends Node2D

# Battery Panic - Main Game Controller (Multi-Device UI Version)
# Turn-based with real-time toggle, multi-device support

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
	{"name": "发送紧急邮件", "time": 180, "battery": 2, "priority": 3},
	{"name": "保存文档", "time": 60, "battery": 1, "priority": 3},
	{"name": "关闭Chrome标签", "time": 30, "battery": -3, "priority": 2},
	{"name": "调低屏幕亮度", "time": 10, "battery": -5, "priority": 2},
	{"name": "下载文件", "time": 600, "battery": 4, "priority": 1},
	{"name": "刷B站", "time": 900, "battery": 8, "priority": 0}
]

@onready var device_screen = $UI/DeviceScreen
@onready var post_it_notes = $UI/PostItNotes
@onready var os_ui = $UI/OS_UI
@onready var terminal = $UI/DeviceScreen/Terminal
@onready var time_label = $UI/TimeLabel
@onready var score_label = $UI/ScoreLabel
@onready var mode_button = $UI/ModeButton

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
		var note_id = post_it_notes.add_note(task["name"], -task["battery"])

func _on_element_clicked(element_name: String) -> void:
	# Direct click on OS element
	print("Clicked: " + element_name)
	_handle_action(element_name)

func _on_note_clicked(note_id: int, task_name: String) -> void:
	# Click on post-it note
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
		"chrome":
			_execute_task(2)  # Close Chrome tabs
		"settings":
			_execute_task(3)  # Dim screen
		"mail":
			_execute_task(0)  # Send email
		"files":
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
		print("Brightness lowered, battery +5%")
	elif command.begins_with("killall"):
		current_battery += 3.0
		print("App killed, battery +3%")
	elif command.begins_with("wifi off"):
		current_battery += 2.0
		print("WiFi off, battery +2%")

func _execute_task(task_id: int) -> void:
	if _completed_task_ids.has(task_id):
		return

	var task = TASKS[task_id]

	# Validate affordability
	if current_battery < task["battery"] or current_time < task["time"]:
		SoundManager.play_sfx("task_fail")
		return

	# Execute task
	current_battery -= task["battery"]
	current_time -= task["time"]
	tasks_completed += 1
	score += task["priority"] * 100
	_completed_task_ids.append(task_id)

	# Remove post-it
	post_it_notes.remove_note(task_id)

	# Update UI
	_update_ui()

	# Play sounds
	SoundManager.play_sfx("task_complete")

	print("完成任务: ", task["name"], " | 剩余电池: ", current_battery, "%")

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

func _trigger_game_over(win: bool) -> void:
	game_over.emit(win, score)

	if win:
		SoundManager.play_sfx("game_over_win")
		print("成功！你在电池耗尽前完成了任务！")
	else:
		SoundManager.play_sfx("game_over_lose")
		print("失败！电池耗尽了...")

	get_tree().paused = true
