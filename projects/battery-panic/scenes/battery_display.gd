extends Control

# BatteryDisplay - Shows battery level with visual states

@export var battery_value: float = 15.0
@export var max_battery: float = 100.0

@onready var battery_icon: Sprite2D = $BatteryIcon
@onready var battery_bar: ProgressBar = $BatteryBar
@onready var percentage_label: Label = $PercentageLabel

# Colors for different battery states
const COLOR_HIGH = Color("#4ecca3")   # > 30%
const COLOR_MED = Color("#ffd93d")    # 10-30%
const COLOR_LOW = Color("#e94560")    # < 10%

var _flash_timer: float = 0.0
var _is_flashing: bool = false

func _ready() -> void:
	update_display(battery_value)

func _process(delta: float) -> void:
	if _is_flashing:
		_flash_timer += delta
		var flash_speed = 0.2 if battery_value < 10.0 else 0.5
		var alpha = 0.5 + 0.5 * sin(_flash_timer * PI / flash_speed)
		modulate.a = alpha

func update_display(value: float) -> void:
	battery_value = clampf(value, 0.0, max_battery)
	var percent = (battery_value / max_battery) * 100.0

	battery_bar.value = percent
	percentage_label.text = "%d%%" % int(percent)

	# Update color based on level
	var color = _get_color_for_level(percent)
	battery_bar.tint_progress = color
	percentage_label.add_theme_color_override("font_color", color)

	# Flash when low
	_is_flashing = percent <= 30.0
	if not _is_flashing:
		modulate.a = 1.0

func _get_color_for_level(percent: float) -> Color:
	if percent > 30.0:
		return COLOR_HIGH
	elif percent > 10.0:
		return COLOR_MED
	else:
		return COLOR_LOW

func set_max_battery(value: float) -> void:
	max_battery = value
	battery_bar.max_value = 100.0  # Always 0-100 scale
	update_display(battery_value)
