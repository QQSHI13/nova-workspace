extends CanvasLayer

# FlashOverlay - Screen flash effects for critical events

@onready var flash_rect: ColorRect = $FlashRect

func _ready() -> void:
	flash_rect.color = Color(1, 0, 0, 0)

func flash_red(intensity: float = 0.5, duration: float = 0.3) -> void:
	_flash_color(Color(1, 0, 0, intensity), duration)

func flash_green(intensity: float = 0.3, duration: float = 0.3) -> void:
	_flash_color(Color(0, 1, 0, intensity), duration)

func flash_yellow(intensity: float = 0.3, duration: float = 0.3) -> void:
	_flash_color(Color(1, 1, 0, intensity), duration)

func _flash_color(color: Color, duration: float) -> void:
	flash_rect.color = color

	var tween = create_tween()
	tween.tween_property(flash_rect, "color:a", 0.0, duration)
	tween.set_ease(Tween.EASE_OUT)

func pulse_warning() -> void:
	# Continuous pulsing for critical battery
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(flash_rect, "color", Color(1, 0, 0, 0.3), 0.5)
	tween.tween_property(flash_rect, "color", Color(1, 0, 0, 0.0), 0.5)
