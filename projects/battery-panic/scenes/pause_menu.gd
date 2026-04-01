extends CanvasLayer

# PauseMenu - In-game pause menu with settings

signal resume_pressed
signal restart_pressed
signal quit_pressed

@onready var panel = $Panel
@onready var sfx_slider = $Panel/VBoxContainer/SFXSlider
@onready var music_slider = $Panel/VBoxContainer/MusicSlider

func _ready() -> void:
	# Connect buttons
	$Panel/VBoxContainer/ResumeButton.pressed.connect(_on_resume)
	$Panel/VBoxContainer/RestartButton.pressed.connect(_on_restart)
	$Panel/VBoxContainer/QuitButton.pressed.connect(_on_quit)

	# Connect sliders
	sfx_slider.value_changed.connect(_on_sfx_changed)
	music_slider.value_changed.connect(_on_music_changed)

	# Hide initially
	visible = false

func show_pause_menu() -> void:
	visible = true
	get_tree().paused = true
	AnimationManager.fade_in(panel, 0.2)

func hide_pause_menu() -> void:
	AnimationManager.fade_out(panel, 0.2)
	await get_tree().create_timer(0.2).timeout
	visible = false
	get_tree().paused = false

func _on_resume() -> void:
	SoundManager.play_sfx("button_click")
	hide_pause_menu()
	resume_pressed.emit()

func _on_restart() -> void:
	SoundManager.play_sfx("button_click")
	get_tree().paused = false
	restart_pressed.emit()
	get_tree().reload_current_scene()

func _on_quit() -> void:
	SoundManager.play_sfx("button_click")
	get_tree().paused = false
	quit_pressed.emit()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_sfx_changed(value: float) -> void:
	SoundManager.set_sfx_volume(linear_to_db(value / 100.0))

func _on_music_changed(value: float) -> void:
	SoundManager.set_music_volume(linear_to_db(value / 100.0))

func linear_to_db(linear: float) -> float:
	if linear <= 0:
		return -80.0
	return 20.0 * log(linear) / log(10)
