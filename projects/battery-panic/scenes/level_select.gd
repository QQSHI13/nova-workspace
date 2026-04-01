extends Control

# LevelSelect - Level selection screen with progression display

@onready var level_container = $CenterContainer/ScrollContainer/LevelContainer
@onready var back_button = $BackButton
@onready var stats_label = $StatsLabel

func _ready() -> void:
	back_button.pressed.connect(_on_back)
	_populate_levels()
	_update_stats()

	# Entrance animation
	AnimationManager.fade_in($Background, 0.3)
	AnimationManager.slide_in($Title, false, 0.5)

	SoundManager.play_music("menu")

func _populate_levels() -> void:
	# Clear existing
	for child in level_container.get_children():
		child.queue_free()

	# First, create and add all buttons
	var buttons = []
	var levels = LevelManager.get_all_levels()
	for level in levels:
		var button = _create_level_button(level)
		button.modulate.a = 0
		buttons.append(button)
		level_container.add_child(button)

	# Wait for layout to settle
	await get_tree().process_frame

	# Then animate them with stagger using individual tweens
	for i in range(buttons.size()):
		await get_tree().create_timer(0.08).timeout
		var tween = create_tween()
		tween.tween_property(buttons[i], "modulate:a", 1.0, 0.25)

func _create_level_button(level: Dictionary) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(600, 120)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	var is_unlocked = LevelManager.is_level_unlocked(level.id)
	var stats = LevelManager.get_level_stats(level.id)

	if is_unlocked:
		button.text = "%d. %s\n%s" % [level.id, level.name, level.description]
		button.pressed.connect(_on_level_selected.bind(level.id))

		# Style based on stars earned
		if stats.stars > 0:
			button.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
			button.text += "\n" + "⭐".repeat(stats.stars)
	else:
		button.text = "%d. [LOCKED]\nComplete previous level to unlock" % level.id
		button.disabled = true
		button.modulate = Color(0.5, 0.5, 0.5)

	# Style the button
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.25) if is_unlocked else Color(0.1, 0.1, 0.12)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	button.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate()
	hover_style.bg_color = Color(0.3, 0.3, 0.4)
	button.add_theme_stylebox_override("hover", hover_style)

	button.add_theme_font_size_override("font_size", 24)

	return button

func _update_stats() -> void:
	var stats = LevelManager.get_total_stats()
	var achievement_pct = AchievementManager.get_completion_percentage()
	stats_label.text = "Games Won: %d/%d | Achievements: %.0f%%" % [
		stats.games_won, stats.games_played, achievement_pct
	]

func _on_level_selected(level_id: int) -> void:
	SoundManager.play_sfx("button_click")
	LevelManager.increment_games_played()

	# Store selected level in a global or pass it to the game
	# For now, just start the main game
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_back() -> void:
	SoundManager.play_sfx("button_click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
