extends Button

# TaskButton - Interactive task selection button
# Emits task_selected signal when clicked

signal task_selected(task_id: int)

@export var task_id: int = 0
@export var task_name: String = "Task Name"
@export var battery_cost: float = 0.0  # Negative = saves battery
@export var time_cost: int = 0
@export var priority: int = 1

@onready var name_label: Label = $NameLabel
@onready var battery_label: Label = $BatteryLabel
@onready var time_label: Label = $TimeLabel

const COLOR_BATTERY_SAVE = Color("#4ecca3")
const COLOR_BATTERY_DRAIN = Color("#e94560")
const COLOR_DISABLED = Color("#666666")

func _ready() -> void:
	pressed.connect(_on_pressed)
	_update_display()

func _update_display() -> void:
	name_label.text = task_name

	# Battery cost display
	if battery_cost < 0:
		battery_label.text = "+%d%%" % abs(int(battery_cost))
		battery_label.add_theme_color_override("font_color", COLOR_BATTERY_SAVE)
	else:
		battery_label.text = "-%d%%" % int(battery_cost)
		battery_label.add_theme_color_override("font_color", COLOR_BATTERY_DRAIN)

	# Time cost display
	var minutes = time_cost / 60
	var seconds = time_cost % 60
	time_label.text = "%d:%02d" % [minutes, seconds]

func _on_pressed() -> void:
	SoundManager.play_sfx("button_click")
	task_selected.emit(task_id)

func set_affordable(can_afford: bool) -> void:
	disabled = not can_afford
	if disabled:
		name_label.add_theme_color_override("font_color", COLOR_DISABLED)
		battery_label.add_theme_color_override("font_color", COLOR_DISABLED)
		time_label.add_theme_color_override("font_color", COLOR_DISABLED)
	else:
		_update_display()

func mark_completed() -> void:
	disabled = true
	name_label.text = task_name + " ✓"
	name_label.add_theme_color_override("font_color", COLOR_BATTERY_SAVE)
