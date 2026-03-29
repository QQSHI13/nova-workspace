extends Node

# EventManager - Surprise events (scripted, random, player-triggered)

signal event_triggered(event_name: String, event_data: Dictionary)
signal event_resolved(event_name: String)

# Scripted events at battery thresholds
const SCRIPTED_EVENTS = {
	20: {
		"name": "low_battery_warning",
		"message": "Low battery warning: 20% remaining",
		"type": "warning"
	},
	10: {
		"name": "critical_battery",
		"message": "Critical battery! Enable power saver now!",
		"type": "critical"
	},
	5: {
		"name": "emergency_mode",
		"message": "Emergency mode activated. Limited functionality.",
		"type": "emergency"
	}
}

# Random events with weights
const RANDOM_EVENTS = [
	{
		"name": "windows_update",
		"message": "Windows Update started! Draining battery fast!",
		"type": "negative",
		"weight": 10,
		"battery_drain": 2.0
	},
	{
		"name": "chrome_background",
		"message": "Chrome using 40% CPU in background!",
		"type": "negative",
		"weight": 15,
		"action_required": "close_chrome"
	},
	{
		"name": "brightness_auto",
		"message": "Brightness auto-adjusted to 100%",
		"type": "negative",
		"weight": 10,
		"effect": "brightness_100"
	},
	{
		"name": "forgot_to_save",
		"message": "Document has unsaved changes!",
		"type": "warning",
		"weight": 12,
		"action_required": "save_document"
	},
	{
		"name": "app_crashed",
		"message": "Application crashed! Task unavailable.",
		"type": "negative",
		"weight": 8,
		"effect": "disable_task"
	},
	{
		"name": "found_charger",
		"message": "Found a charger! +10% battery",
		"type": "positive",
		"weight": 5,
		"battery_gain": 10.0
	}
]

# Player-triggered events (consequences of actions)
const PLAYER_TRIGGERED_EVENTS = {
	"close_chrome_unsaved": {
		"name": "lost_work",
		"message": "Closed Chrome without saving! Lost 2 hours of work!",
		"type": "negative",
		"stress_penalty": 10
	},
	"force_quit": {
		"name": "data_corrupted",
		"message": "Force quit caused data corruption!",
		"type": "negative",
		"extra_task": "fix_files"
	},
	"skip_update": {
		"name": "security_risk",
		"message": "Security risk! Update vulnerability detected.",
		"type": "warning",
		"future_event_chance": 0.3
	}
}

var _active_events: Dictionary = {}
var _event_counter: int = 0
var _random_event_chance: float = 0.1

func _ready() -> void:
	pass

func check_scripted_events(battery_percent: float) -> void:
	# Check if any scripted event should trigger
	for threshold in SCRIPTED_EVENTS.keys():
		if battery_percent <= threshold and battery_percent > threshold - 1:
			var event = SCRIPTED_EVENTS[threshold]
			_trigger_event(event)

func try_random_event() -> bool:
	# Try to trigger a random event
	if randf() < _random_event_chance:
		var event = _pick_random_event()
		if event:
			_trigger_event(event)
			return true
	return false

func _pick_random_event() -> Dictionary:
	var total_weight = 0
	for event in RANDOM_EVENTS:
		total_weight += event["weight"]

	var roll = randi() % total_weight
	var current_weight = 0

	for event in RANDOM_EVENTS:
		current_weight += event["weight"]
		if roll < current_weight:
			return event

	return RANDOM_EVENTS[0]

func trigger_player_event(action: String) -> void:
	if PLAYER_TRIGGERED_EVENTS.has(action):
		var event = PLAYER_TRIGGERED_EVENTS[action]
		_trigger_event(event)

func _trigger_event(event: Dictionary) -> void:
	var event_id = _event_counter
	_event_counter += 1

	_active_events[event_id] = event

	emit_signal("event_triggered", event["name"], event)

	print("[EVENT] " + event["message"])

func resolve_event(event_id: int) -> void:
	if _active_events.has(event_id):
		var event = _active_events[event_id]
		_active_events.erase(event_id)
		emit_signal("event_resolved", event["name"])

func get_active_events() -> Dictionary:
	return _active_events

func set_random_event_chance(chance: float) -> void:
	_random_event_chance = clampf(chance, 0.0, 1.0)

func clear_all_events() -> void:
	for event_id in _active_events.keys():
		resolve_event(event_id)
