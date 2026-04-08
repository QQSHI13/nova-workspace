extends CanvasLayer

# Tutorial - Step-by-step guided tutorial

signal tutorial_completed
signal tutorial_skipped

const TUTORIAL_STEPS = [
	{
		"title": "Welcome to Battery Panic!",
		"text": "Your battery is at 15%. Complete critical tasks before it dies!",
		"highlight": "",
		"position": Vector2(960, 600)
	},
	{
		"title": "Post-It Notes",
		"text": "These notes show your tasks. Each task takes time and battery.",
		"highlight": "post_it",
		"position": Vector2(1400, 300)
	},
	{
		"title": "Device Screen",
		"text": "Click app icons directly. Try clicking Chrome or VS Code: to do tasks!",
		"highlight": "device",
		"position": Vector2(600, 400)
	},
	{
		"title": "Terminal Commands",
		"text": "Type commands like 'brightness 30' or 'killall chrome' in the terminal.",
		"highlight": "terminal",
		"position": Vector2(600, 400)
	},
	{
		"title": "Battery Display",
		"text": "Watch your battery! Green = good, Yellow = warning, Red = critical!",
		"highlight": "battery",
		"position": Vector2(1800, 100)
	},
	{
		"title": "Complete 3 Tasks",
		"text": "Finish 3 critical tasks before time runs out. Good luck!",
		"highlight": "",
		"position": Vector2(960, 600)
	}
]

var _current_step: int = 0
var _is_active: bool = false

@onready var title_label = $Panel/TitleLabel
@onready var text_label = $Panel/TextLabel
@onready var next_button = $Panel/NextButton
@onready var skip_button = $Panel/SkipButton
@onready var panel = $Panel
@onready var highlight_box = $HighlightBox

func _ready() -> void:
	next_button.pressed.connect(_on_next)
	skip_button.pressed.connect(_on_skip)
	visible = false
	highlight_box.visible = false

func start_tutorial() -> void:
	_is_active = true
	_current_step = 0
	visible = true
	_show_step(0)
	AnimationManager.fade_in(panel)

func _show_step(index: int) -> void:
	if index >= TUTORIAL_STEPS.size():
		_complete_tutorial()
		return

	var step = TUTORIAL_STEPS[index]
	title_label.text = step["title"]
	text_label.text = step["text"]

	# Position panel
	panel.position = step["position"] - Vector2(panel.size.x / 2, panel.size.y / 2)

	# Show highlight if needed
	if step["highlight"] != "":
		_show_highlight(step["highlight"])
	else:
		highlight_box.visible = false

	# Update button text
	if index == TUTORIAL_STEPS.size() - 1:
		next_button.text = "Start Game!"
	else:
		next_button.text = "Next"

func _show_highlight(element: String) -> void:
	highlight_box.visible = true
	# Position highlight box based on element
	match element:
		"post_it":
			highlight_box.position = Vector2(1400, 100)
			highlight_box.size = Vector2(280, 160)
		"device":
			highlight_box.position = Vector2(100, 100)
			highlight_box.size = Vector2(1200, 800)
		"terminal":
			highlight_box.position = Vector2(200, 100)
			highlight_box.size = Vector2(800, 500)
		"battery":
			highlight_box.position = Vector2(1700, 20)
			highlight_box.size = Vector2(200, 60)

func _on_next() -> void:
	SoundManager.play_sfx("button_click")
	_current_step += 1
	_show_step(_current_step)

func _on_skip() -> void:
	SoundManager.play_sfx("button_click")
	tutorial_skipped.emit()
	_hide_tutorial()

func _complete_tutorial() -> void:
	tutorial_completed.emit()
	_hide_tutorial()

func _hide_tutorial() -> void:
	AnimationManager.fade_out(panel)
	await get_tree().create_timer(0.3, true).timeout
	visible = false
	_is_active = false

func is_active() -> bool:
	return _is_active

func _input(event: InputEvent) -> void:
	if not _is_active:
		return
	if not event is InputEventKey:
		return
	if event.is_echo():
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		accept_event()
		if event.is_action_pressed("ui_cancel"):
			_on_skip()
		else:
			_on_next()
