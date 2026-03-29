extends Control

# Terminal - Command line interface for executing actions

signal command_executed(command: String, success: bool)

@onready var output_label: RichTextLabel = $OutputLabel
@onready var input_line: LineEdit = $InputLine

var _command_history: Array[String] = []
var _history_index: int = -1

# Valid commands and their effects
const VALID_COMMANDS = {
	"brightness": {"args": 1, "help": "brightness [0-100] - Set screen brightness"},
	"killall": {"args": 1, "help": "killall [app] - Force close application"},
	"wifi": {"args": 1, "help": "wifi [on/off] - Toggle WiFi"},
	"bluetooth": {"args": 1, "help": "bluetooth [on/off] - Toggle Bluetooth"},
	"help": {"args": 0, "help": "Show available commands"},
	"clear": {"args": 0, "help": "Clear terminal"}
}

func _ready() -> void:
	input_line.text_submitted.connect(_on_command_submitted)
	_append_output("Battery Panic Terminal v1.0")
	_append_output("Type 'help' for available commands")
	_append_output("")

func _on_command_submitted(text: String) -> void:
	var command = text.strip_edges()
	if command.is_empty():
		return

	_command_history.append(command)
	_history_index = _command_history.size()

	_append_output("$ " + command)
	_process_command(command)

	input_line.clear()

func _process_command(command: String) -> void:
	var parts = command.split(" ")
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)

	match cmd:
		"help":
			_show_help()
		"clear":
			output_label.clear()
		"brightness":
			if args.size() >= 1:
				var level = args[0].to_int()
				_append_output("Setting brightness to " + str(level) + "%")
				command_executed.emit("brightness " + str(level), true)
			else:
				_append_output("Usage: brightness [0-100]")
		"killall":
			if args.size() >= 1:
				var app = args[0]
				_append_output("Killing process: " + app)
				command_executed.emit("killall " + app, true)
			else:
				_append_output("Usage: killall [app_name]")
		"wifi":
			if args.size() >= 1:
				var state = args[0].to_lower()
				_append_output("WiFi " + ("enabled" if state == "on" else "disabled"))
				command_executed.emit("wifi " + state, true)
			else:
				_append_output("Usage: wifi [on/off]")
		"bluetooth":
			if args.size() >= 1:
				var state = args[0].to_lower()
				_append_output("Bluetooth " + ("enabled" if state == "on" else "disabled"))
				command_executed.emit("bluetooth " + state, true)
			else:
				_append_output("Usage: bluetooth [on/off]")
		_:
			_append_output("Command not found: " + cmd)
			_append_output("Type 'help' for available commands")

func _show_help() -> void:
	_append_output("Available commands:")
	for cmd in VALID_COMMANDS:
		_append_output("  " + VALID_COMMANDS[cmd]["help"])

func _append_output(text: String) -> void:
	output_label.append_text(text + "\n")

func show_terminal() -> void:
	visible = true
	input_line.grab_focus()

func hide_terminal() -> void:
	visible = false

func toggle_terminal() -> void:
	if visible:
		hide_terminal()
	else:
		show_terminal()

func add_system_message(message: String) -> void:
	_append_output("[SYSTEM] " + message)
