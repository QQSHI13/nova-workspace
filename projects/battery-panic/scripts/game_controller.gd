extends Node2D

# Battery Panic - Main Game Controller
# Signal-driven architecture for UI updates

@export var starting_battery: float = 15.0
@export var time_limit: float = 1200.0  # 20 minutes in seconds

# Signals for UI updates
signal battery_changed(new_value: float, max_value: float)
signal time_changed(new_value: float, max_value: float)
signal score_changed(new_score: int)
signal task_completed(task_name: String)
signal game_over(win: bool, final_score: int)

var current_battery: float
var current_time: float
var score: int = 0
var tasks_completed: int = 0
var _completed_task_ids: Array[int] = []

# Task button instances
var _task_buttons: Dictionary = {}

# Tasks that need to be completed
const TASKS = [
	{"name": "发送紧急邮件", "time": 180, "battery": 2, "priority": 3},
	{"name": "保存文档", "time": 60, "battery": 1, "priority": 3},
	{"name": "关闭Chrome标签", "time": 30, "battery": -3, "priority": 2},
	{"name": "调低屏幕亮度", "time": 10, "battery": -5, "priority": 2},
	{"name": "下载文件", "time": 600, "battery": 4, "priority": 1},
	{"name": "刷B站", "time": 900, "battery": 8, "priority": 0}
]

@onready var task_container: VBoxContainer = $UI/TaskContainer
@onready var time_label: Label = $UI/TimeLabel
@onready var score_label: Label = $UI/ScoreLabel
@onready var battery_display = $UI/BatteryDisplay

func _ready() -> void:
	current_battery = starting_battery
	current_time = time_limit

	_spawn_task_buttons()
	_update_ui()

	print("游戏开始！电池: ", current_battery, "%")
	print("你有20分钟完成关键任务！")

func _spawn_task_buttons() -> void:
	var task_button_scene = preload("res://scenes/task_button.tscn")

	for i in range(TASKS.size()):
		var task = TASKS[i]
		var button = task_button_scene.instantiate()

		button.task_id = i
		button.task_name = task["name"]
		button.battery_cost = task["battery"]
		button.time_cost = task["time"]
		button.priority = task["priority"]

		button.task_selected.connect(_on_task_selected)

		task_container.add_child(button)
		_task_buttons[i] = button

	_update_button_affordability()

func _process(delta: float) -> void:
	# Drain battery over time
	current_time -= delta
	current_battery -= delta * 0.005  # Battery drains slowly

	# Emit signals for UI updates
	battery_changed.emit(current_battery, 100.0)
	time_changed.emit(current_time, time_limit)

	# Update displays
	_update_ui()
	_update_button_affordability()

	if current_battery <= 0:
		_trigger_game_over(false)
	elif current_time <= 0:
		_trigger_game_over(true)

	# Check if all critical tasks done
	if tasks_completed >= 3 and current_battery > 0:
		_trigger_game_over(true)

func _update_ui() -> void:
	# Update time display
	var minutes = int(current_time) / 60
	var seconds = int(current_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

	# Update score
	score_label.text = "Score: %d" % score

	# Update battery display if it exists
	if battery_display:
		battery_display.update_display(current_battery)

func _update_button_affordability() -> void:
	for i in range(TASKS.size()):
		if _completed_task_ids.has(i):
			continue

		var task = TASKS[i]
		var can_afford = current_battery >= task["battery"] and current_time >= task["time"]

		if _task_buttons.has(i):
			_task_buttons[i].set_affordable(can_afford)

func _on_task_selected(task_id: int) -> void:
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

	# Update UI
	battery_changed.emit(current_battery, 100.0)
	time_changed.emit(current_time, time_limit)
	score_changed.emit(score)
	task_completed.emit(task["name"])

	# Update button
	if _task_buttons.has(task_id):
		_task_buttons[task_id].mark_completed()

	# Play sounds
	SoundManager.play_sfx("task_complete")
	if current_battery < 10.0:
		SoundManager.play_sfx("low_battery")

	print("完成任务: ", task["name"], " | 剩余电池: ", current_battery, "%")

func _trigger_game_over(win: bool) -> void:
	game_over.emit(win, score)

	if win:
		SoundManager.play_sfx("game_over_win")
		print("成功！你在电池耗尽前完成了任务！")
	else:
		SoundManager.play_sfx("game_over_lose")
		print("失败！电池耗尽了...")

	# Show game over panel
	var game_over_panel = $UI/GameOverPanel
	if game_over_panel:
		game_over_panel.visible = true
		var label = game_over_panel.get_node("GameOverLabel")
		if label:
			label.text = "Victory!" if win else "Battery Dead!"

	get_tree().paused = true
