extends Control

var _hover_tweens: Dictionary = {}

func _ready() -> void:
	$Background/StartButton.pressed.connect(_on_start)
	$Background/QuitButton.pressed.connect(_on_quit)

	# Add hover effects
	var start_btn = $Background/StartButton
	start_btn.mouse_entered.connect(_on_btn_hover.bind(start_btn, true))
	start_btn.mouse_exited.connect(_on_btn_hover.bind(start_btn, false))

	var quit_btn = $Background/QuitButton
	quit_btn.mouse_entered.connect(_on_btn_hover.bind(quit_btn, true))
	quit_btn.mouse_exited.connect(_on_btn_hover.bind(quit_btn, false))

func _on_start() -> void:
	# Fade out effect
	var tween = create_tween()
	tween.tween_property($Background, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")
	)

func _on_quit() -> void:
	get_tree().quit()

func _on_btn_hover(btn: Button, hovering: bool) -> void:
	var key = btn.get_instance_id()
	if _hover_tweens.has(key) and _hover_tweens[key]:
		_hover_tweens[key].kill()
	var tween = create_tween()
	_hover_tweens[key] = tween
	if hovering:
		tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.15)
	else:
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15)
