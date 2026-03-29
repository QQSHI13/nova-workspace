extends CanvasLayer

# PostItNotes - Physical post-it notes showing tasks and hints - Full HD

signal note_clicked(task_id: int, task_name: String)
signal note_hover(task_name: String)

const COLOR_YELLOW = Color("#ffeb3b")  # Available tasks
const COLOR_GREEN = Color("#81c784")   # Tips
const COLOR_RED = Color("#e57373")     # Urgent

var _notes: Dictionary = {}
var _note_counter: int = 0

@onready var notes_container = $NotesContainer

func _ready() -> void:
	pass

func add_note(task_name: String, battery_save: int, note_type: String = "task") -> int:
	var note_id = _note_counter
	_note_counter += 1

	var note = Panel.new()
	note.name = "Note_%d" % note_id
	note.custom_minimum_size = Vector2(280, 160)

	# Position on right side, stacked - Full HD spacing
	note.position = Vector2(1400, 100 + note_id * 200)

	# Color based on type
	var color = COLOR_YELLOW
	if note_type == "tip":
		color = COLOR_GREEN
	elif note_type == "urgent":
		color = COLOR_RED

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 4
	note.add_theme_stylebox_override("panel", style)

	# Task name label
	var label = Label.new()
	label.text = task_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.position = Vector2(10, 15)
	label.size = Vector2(260, 80)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color("#333333"))
	note.add_child(label)

	# Battery save label
	var battery_label = Label.new()
	if battery_save > 0:
		battery_label.text = "+%d%% battery" % battery_save
	else:
		battery_label.text = "-%d%% battery" % abs(battery_save)
	battery_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battery_label.position = Vector2(10, 100)
	battery_label.size = Vector2(260, 40)
	battery_label.add_theme_font_size_override("font_size", 28)
	battery_label.add_theme_color_override("font_color", Color("#1565c0"))
	note.add_child(battery_label)

	# Make clickable
	var btn = Button.new()
	btn.flat = true
	btn.size = Vector2(280, 160)
	btn.pressed.connect(_on_note_clicked.bind(note_id, task_name))
	btn.mouse_entered.connect(_on_note_hover.bind(task_name))
	note.add_child(btn)

	notes_container.add_child(note)
	_notes[note_id] = {"panel": note, "task_name": task_name, "battery": battery_save}

	return note_id

func remove_note(note_id: int) -> void:
	if _notes.has(note_id):
		_notes[note_id]["panel"].queue_free()
		_notes.erase(note_id)

func remove_note_with_animation(note_id: int) -> void:
	if _notes.has(note_id):
		var note = _notes[note_id]["panel"]
		# Fade out and scale down
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(note, "modulate:a", 0.0, 0.3)
		tween.tween_property(note, "scale", Vector2(0.8, 0.8), 0.3)
		await tween.finished
		note.queue_free()
		_notes.erase(note_id)

func clear_all_notes() -> void:
	for note_id in _notes.keys():
		remove_note(note_id)

func _on_note_clicked(note_id: int, task_name: String) -> void:
	note_clicked.emit(note_id, task_name)

func _on_note_hover(task_name: String) -> void:
	note_hover.emit(task_name)

func highlight_related_element(task_name: String) -> void:
	# Emit signal for DeviceScreen to handle
	pass
