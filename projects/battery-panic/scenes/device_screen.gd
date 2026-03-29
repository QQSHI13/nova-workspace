extends Control

# DeviceScreen - Shows a device (laptop/phone/tablet) UI - Full HD Version

signal element_clicked(element_name: String)
signal window_closed(window_name: String)
signal app_opened(app_name: String)

@export var os_theme: String = "windows"  # windows, mac, phone
@export var show_terminal: bool = false

@onready var screen_area = $ScreenArea
@onready var taskbar = $Taskbar
@onready var terminal = $Terminal

# Interactive elements
var _interactive_elements: Dictionary = {}

func _ready() -> void:
	_apply_theme()
	_setup_interactive_elements()
	if terminal:
		terminal.visible = show_terminal

func _apply_theme() -> void:
	# Set colors based on OS theme
	match os_theme:
		"windows":
			screen_area.color = Color("#0078d4")  # Windows blue
		"mac":
			screen_area.color = Color("#2d2d2d")  # Dark mode
		"phone":
			screen_area.color = Color("#000000")  # Black

func _setup_interactive_elements() -> void:
	# Add clickable app icons - Full HD sized
	var apps = ["Chrome", "Settings", "Mail", "Files"]
	var icons = ["🌐", "⚙️", "📧", "📁"]
	for i in range(apps.size()):
		var btn = Button.new()
		btn.text = icons[i] + "\n" + apps[i]
		btn.position = Vector2(80 + i * 180, 100)
		btn.size = Vector2(140, 140)
		btn.add_theme_font_size_override("font_size", 24)
		btn.pressed.connect(_on_app_clicked.bind(apps[i]))

		# Add hover effects
		btn.mouse_entered.connect(_on_btn_hover.bind(btn, true))
		btn.mouse_exited.connect(_on_btn_hover.bind(btn, false))

		# Style the button
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = Color(1, 1, 1, 0.2)
		style_normal.corner_radius_top_left = 12
		style_normal.corner_radius_top_right = 12
		style_normal.corner_radius_bottom_left = 12
		style_normal.corner_radius_bottom_right = 12
		btn.add_theme_stylebox_override("normal", style_normal)

		var style_hover = StyleBoxFlat.new()
		style_hover.bg_color = Color(1, 1, 1, 0.4)
		style_hover.corner_radius_top_left = 12
		style_hover.corner_radius_top_right = 12
		style_hover.corner_radius_bottom_left = 12
		style_hover.corner_radius_bottom_right = 12
		btn.add_theme_stylebox_override("hover", style_hover)

		var style_pressed = StyleBoxFlat.new()
		style_pressed.bg_color = Color(1, 1, 1, 0.1)
		style_pressed.corner_radius_top_left = 12
		style_pressed.corner_radius_top_right = 12
		style_pressed.corner_radius_bottom_left = 12
		style_pressed.corner_radius_bottom_right = 12
		btn.add_theme_stylebox_override("pressed", style_pressed)

		screen_area.add_child(btn)
		_interactive_elements[apps[i]] = btn

		# Entrance animation
		btn.scale = Vector2(0, 0)
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1, 1), 0.3)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_delay(i * 0.1)

func _on_app_clicked(app_name: String) -> void:
	element_clicked.emit(app_name)
	app_opened.emit(app_name)

func _on_btn_hover(btn: Button, is_hovering: bool) -> void:
	var tween = create_tween()
	if is_hovering:
		tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.15)
		SoundManager.play_sfx("button_hover")
	else:
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15)

func show_terminal_window(show_it: bool) -> void:
	if terminal:
		terminal.visible = show_it

func add_interactive_element(name: String, position: Vector2) -> void:
	var btn = Button.new()
	btn.text = name
	btn.position = position
	btn.size = Vector2(140, 60)
	btn.pressed.connect(_on_app_clicked.bind(name))
	screen_area.add_child(btn)
	_interactive_elements[name] = btn

func remove_interactive_element(name: String) -> void:
	if _interactive_elements.has(name):
		_interactive_elements[name].queue_free()
		_interactive_elements.erase(name)
