extends Control

# MainMenu - Polished main menu with animations

func _ready() -> void:
	# Connect button signals
	$StartButton.pressed.connect(_on_start)
	$QuitButton.pressed.connect(_on_quit)

	# Add hover effects to buttons
	_setup_button_hover($StartButton)
	_setup_button_hover($QuitButton)

	# Entrance animations
	AnimationManager.fade_in($Background, 0.5)
	AnimationManager.slide_in($Title, false, 0.8)
	AnimationManager.slide_in($Subtitle, true, 0.8)

	$StartButton.modulate.a = 0
	$QuitButton.modulate.a = 0
	await get_tree().create_timer(0.5).timeout
	AnimationManager.fade_in($StartButton, 0.5)
	await get_tree().create_timer(0.2).timeout
	AnimationManager.fade_in($QuitButton, 0.5)

func _setup_button_hover(btn: Button) -> void:
	btn.mouse_entered.connect(_on_button_hover.bind(btn, true))
	btn.mouse_exited.connect(_on_button_hover.bind(btn, false))

	# Style the button
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color("#2d7dd2")
	style_normal.corner_radius_top_left = 8
	style_normal.corner_radius_top_right = 8
	style_normal.corner_radius_bottom_left = 8
	style_normal.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style_normal)

	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color("#4a9eff")
	style_hover.corner_radius_top_left = 8
	style_hover.corner_radius_top_right = 8
	style_hover.corner_radius_bottom_left = 8
	style_hover.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("hover", style_hover)

	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color("#1a5aa0")
	style_pressed.corner_radius_top_left = 8
	style_pressed.corner_radius_top_right = 8
	style_pressed.corner_radius_bottom_left = 8
	style_pressed.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("pressed", style_pressed)

func _on_button_hover(btn: Button, is_hovering: bool) -> void:
	var tween = create_tween()
	if is_hovering:
		tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.15)
		SoundManager.play_sfx("button_hover")
	else:
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15)

func _on_start() -> void:
	SoundManager.play_sfx("button_click")
	AnimationManager.fade_out(self, 0.3)
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_quit() -> void:
	SoundManager.play_sfx("button_click")
	AnimationManager.fade_out(self, 0.3)
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()
