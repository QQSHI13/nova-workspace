extends Control

# OS_UI - Battery display in OS-specific location - Full HD with animations

signal battery_clicked

@export var os_type: String = "windows"  # windows, mac, phone
@export var show_percentage: bool = true
@export var calibration_drift: float = 0.0  # Positive = shows higher than actual

@onready var battery_icon = $BatteryIcon
@onready var battery_label = $BatteryLabel

var _actual_battery: float = 100.0
var _displayed_battery: float = 100.0
var _warning_tween: Tween = null

func _ready() -> void:
	_position_for_os()
	update_battery(100.0)

	# Connect click area
	$ClickArea.pressed.connect(_on_battery_clicked)

func _position_for_os() -> void:
	# Position based on OS style - Full HD coordinates
	match os_type:
		"windows":
			# Bottom right
			position = Vector2(1800, 1020)
			battery_icon.position = Vector2(0, 0)
			battery_label.position = Vector2(-100, 10)
		"mac":
			# Top right
			position = Vector2(1820, 20)
			battery_icon.position = Vector2(0, 0)
			battery_label.position = Vector2(-120, 10)
		"phone":
			# Top right
			position = Vector2(1780, 40)
			battery_icon.position = Vector2(0, 0)
			battery_label.position = Vector2(-100, 10)

func update_battery(actual_percent: float) -> void:
	var old_battery = _actual_battery
	_actual_battery = actual_percent

	# Apply calibration drift (surprise mechanic)
	_displayed_battery = _actual_battery + calibration_drift
	_displayed_battery = clampf(_displayed_battery, 0.0, 100.0)

	if show_percentage:
		# Animate number change
		_animate_battery_number(int(old_battery), int(_displayed_battery))

	# Update icon color based on displayed level
	var color = _get_battery_color(_displayed_battery)
	battery_icon.modulate = color

	# Handle warning states
	if _displayed_battery <= 10.0:
		_start_critical_warning()
	elif _displayed_battery <= 20.0:
		_start_low_warning()
	else:
		_stop_warning()

func _animate_battery_number(from_val: int, to_val: int) -> void:
	var tween = create_tween()
	tween.tween_method(
		func(val: int): battery_label.text = "%d%%" % val,
		from_val,
		to_val,
		0.3
	)

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

func _start_low_warning() -> void:
	# Slow pulse for low battery
	if _warning_tween and _warning_tween.is_valid():
		_warning_tween.kill()

	_warning_tween = create_tween()
	_warning_tween.set_loops()
	_warning_tween.tween_property(battery_icon, "modulate:a", 0.5, 0.8)
	_warning_tween.tween_property(battery_icon, "modulate:a", 1.0, 0.8)

func _start_critical_warning() -> void:
	# Fast pulse + scale for critical battery
	if _warning_tween and _warning_tween.is_valid():
		_warning_tween.kill()

	_warning_tween = create_tween()
	_warning_tween.set_loops()
	_warning_tween.set_parallel(true)
	_warning_tween.tween_property(battery_icon, "modulate:a", 0.3, 0.3)
	_warning_tween.tween_property(battery_icon, "scale", Vector2(1.1, 1.1), 0.3)
	_warning_tween.chain()
	_warning_tween.tween_property(battery_icon, "modulate:a", 1.0, 0.3)
	_warning_tween.tween_property(battery_icon, "scale", Vector2(1.0, 1.0), 0.3)

func _stop_warning() -> void:
	if _warning_tween and _warning_tween.is_valid():
		_warning_tween.kill()
	battery_icon.modulate.a = 1.0
	battery_icon.scale = Vector2(1.0, 1.0)

func show_warning() -> void:
	# One-time flash effect
	var tween = create_tween()
	tween.tween_property(battery_icon, "modulate:a", 0.3, 0.5)
	tween.tween_property(battery_icon, "modulate:a", 1.0, 0.5)

func _on_battery_clicked() -> void:
	battery_clicked.emit()
	# Click feedback
	var tween = create_tween()
	tween.tween_property(battery_icon, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(battery_icon, "scale", Vector2(1.0, 1.0), 0.1)
