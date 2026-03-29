extends CanvasLayer

# PostItNotes - Physical post-it notes showing tasks and hints

signal note_clicked(task_id: int, task_name: String)
signal note_hover(task_name: String)

const COLOR_YELLOW = Color("#ffeb3b")  # Available tasks
const COLOR_GREEN = Color("#4caf50")   # Tips
const COLOR_RED = Color("#f44336")     # Urgent

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
	note.custom_minimum_size = Vector2(120, 80)

	# Position on right side, stacked
	note.position = Vector2(500, 50 + note_id * 90)

	# Color based on type
	var color = COLOR_YELLOW
	if note_type == "tip":
		color = COLOR_GREEN
	elif note_type == "urgent":
		color = COLOR_RED

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	note.add_theme_stylebox_override("panel", style)

	# Task name label
	var label = Label.new()
	label.text = task_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.position = Vector2(5, 5)
	label.size = Vector2(110, 40)
	note.add_child(label)

	# Battery save label
	var battery_label = Label.new()
	if battery_save > 0:
		battery_label.text = "+%d%%" % battery_save
	else:
		battery_label.text = "-%d%%" % abs(battery_save)
	battery_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battery_label.position = Vector2(5, 50)
	battery_label.size = Vector2(110, 25)
	battery_label.add_theme_color_override("font_color", Color.BLACK)
	note.add_child(battery_label)

	# Make clickable
	var btn = Button.new()
	btn.flat = true
	btn.size = Vector2(120, 80)
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
