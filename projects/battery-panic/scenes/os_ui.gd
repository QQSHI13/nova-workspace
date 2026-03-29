
extends Control

# OS_UI - Battery display in OS-specific location

signal battery_clicked

@export var os_type: String = "windows"  # windows, mac, phone
@export var show_percentage: bool = true
@export var calibration_drift: float = 0.0  # Positive = shows higher than actual

@onready var battery_icon = $BatteryIcon
@onready var battery_label = $BatteryLabel

var _actual_battery: float = 100.0
var _displayed_battery: float = 100.0

func _ready() -> void:
	_position_for_os()
	update_battery(100.0)

func _position_for_os() -> void:
	# Position based on OS style
	match os_type:
		"windows":
			# Bottom right
			position = Vector2(560, 320)
			battery_icon.position = Vector2(0, 0)
			battery_label.position = Vector2(-40, 0)
		"mac":
			# Top right
			position = Vector2(560, 10)
			battery_icon.position = Vector2(0, 0)
			battery_label.position = Vector2(-50, 0)
		"phone":
			# Top right
			position = Vector2(550, 25)
			battery_icon.position = Vector2(0, 0)
			battery_label.position = Vector2(-35, 0)

func update_battery(actual_percent: float) -> void:
	_actual_battery = actual_percent

	# Apply calibration drift (surprise mechanic)
	_displayed_battery = _actual_battery + calibration_drift
	_displayed_battery = clampf(_displayed_battery, 0.0, 100.0)

	if show_percentage:
		battery_label.text = "%d%%" % int(_displayed_battery)

	# Update icon color based on displayed level
	var color = _get_battery_color(_displayed_battery)
	battery_icon.modulate = color

func _get_battery_color(percent: float) -> Color:
	if percent > 50:
		return Color.GREEN
	elif percent > 20:
		return Color.YELLOW
	else:
		return Color.RED

func set_calibration_drift(drift: float) -> void:
	calibration_drift = drift
	update_battery(_actual_battery)

func show_warning() -> void:
	# Flash effect for low battery
	var tween = create_tween()
	tween.tween_property(battery_icon, "modulate:a", 0.3, 0.5)
	tween.tween_property(battery_icon, "modulate:a", 1.0, 0.5)

func _on_battery_clicked() -> void:
	battery_clicked.emit()
