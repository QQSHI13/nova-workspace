extends Node

# LevelManager - Handles level progression and data
# Autoload singleton for Battery Panic

# Level definitions
const LEVELS = [
	{
		"id": 1,
		"name": "Office Emergency",
		"description": "Your laptop is at 15%. Complete critical tasks before the meeting!",
		"starting_battery": 15.0,
		"time_limit": 1200,  # 20 minutes
		"devices": ["laptop"],
		"tasks_required": 3,
		"unlocks": [2]
	},
	{
		"id": 2,
		"name": "Coffee Shop Crisis",
		"description": "Both your laptop and phone are dying. Manage both devices!",
		"starting_battery": 12.0,
		"time_limit": 900,  # 15 minutes
		"devices": ["laptop", "phone"],
		"tasks_required": 4,
		"unlocks": [3]
	},
	{
		"id": 3,
		"name": "Library Silence",
		"description": "Quiet mode required. No notifications, save battery smartly.",
		"starting_battery": 10.0,
		"time_limit": 1800,  # 30 minutes
		"devices": ["laptop", "tablet"],
		"tasks_required": 5,
		"special_rules": ["quiet_mode"],
		"unlocks": [4]
	},
	{
		"id": 4,
		"name": "Airport Chaos",
		"description": "Multiple devices, multiple gates. Time is critical!",
		"starting_battery": 8.0,
		"time_limit": 600,  # 10 minutes
		"devices": ["laptop", "phone", "tablet"],
		"tasks_required": 6,
		"unlocks": [5]
	},
	{
		"id": 5,
		"name": "Total Emergency",
		"description": "Everything is failing. Can you survive the battery panic?",
		"starting_battery": 5.0,
		"time_limit": 300,  # 5 minutes
		"devices": ["laptop", "phone", "tablet", "watch"],
		"tasks_required": 8,
		"special_rules": ["cascading_failures", "rapid_drain"]
	}
]

# Save data
var _save_data: Dictionary = {
	"highest_level_unlocked": 1,
	"level_scores": {},  # level_id: {score: int, stars: int, best_time: float}
	"achievements": {},  # achievement_id: unlocked_timestamp
	"total_play_time": 0.0,
	"games_played": 0,
	"games_won": 0
}

const SAVE_FILE_PATH = "user://battery_panic_save.json"

signal level_unlocked(level_id: int)
signal high_score_beaten(level_id: int, new_score: int)

func _ready() -> void:
	_load_save_data()
	print("LevelManager ready. Highest level unlocked: %d" % _save_data.highest_level_unlocked)

# Level Access

func get_level(level_id: int) -> Dictionary:
	for level in LEVELS:
		if level.id == level_id:
			return level
	return {}

func get_all_levels() -> Array:
	return LEVELS

func get_unlocked_levels() -> Array:
	var unlocked = []
	for level in LEVELS:
		if is_level_unlocked(level.id):
			unlocked.append(level)
	return unlocked

func is_level_unlocked(level_id: int) -> bool:
	return level_id <= _save_data.highest_level_unlocked

func unlock_level(level_id: int) -> void:
	if level_id > _save_data.highest_level_unlocked:
		_save_data.highest_level_unlocked = level_id
		_save_save_data()
		level_unlocked.emit(level_id)
		print("Level %d unlocked!" % level_id)

func complete_level(level_id: int, score: int, time_remaining: float, tasks_completed: int) -> Dictionary:
	var level = get_level(level_id)
	if level.is_empty():
		return {}

	# Calculate stars (1-3)
	var stars = 1
	if score > 500:
		stars = 2
	if score > 1000:
		stars = 3

	# Update high score
	var level_key = str(level_id)
	var previous_best = _save_data.level_scores.get(level_key, {})
	var new_record = false

	if not previous_best.has("score") or score > previous_best.score:
		new_record = true
		high_score_beaten.emit(level_id, score)

	_save_data.level_scores[level_key] = {
		"score": max(score, previous_best.get("score", 0)),
		"stars": max(stars, previous_best.get("stars", 0)),
		"best_time": max(time_remaining, previous_best.get("best_time", 0.0))
	}

	# Update stats
	_save_data.games_won += 1

	# Unlock next levels
	if level.has("unlocks"):
		for next_id in level.unlocks:
			unlock_level(next_id)

	_save_save_data()

	return {
		"score": score,
		"stars": stars,
		"new_record": new_record,
		"tasks_completed": tasks_completed
	}

func get_level_stats(level_id: int) -> Dictionary:
	return _save_data.level_scores.get(str(level_id), {
		"score": 0,
		"stars": 0,
		"best_time": 0.0
	})

# Stats

func get_total_stats() -> Dictionary:
	return {
		"games_played": _save_data.games_played,
		"games_won": _save_data.games_won,
		"win_rate": float(_save_data.games_won) / max(_save_data.games_played, 1) * 100.0,
		"total_play_time": _save_data.total_play_time
	}

func increment_games_played() -> void:
	_save_data.games_played += 1
	_save_save_data()

func add_play_time(seconds: float) -> void:
	_save_data.total_play_time += seconds
	_save_save_data()

# Save/Load

func _load_save_data() -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			_save_data = json.data
		file.close()

func _save_save_data() -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_save_data, "\t"))
		file.close()

func reset_all_progress() -> void:
	_save_data = {
		"highest_level_unlocked": 1,
		"level_scores": {},
		"achievements": {},
		"total_play_time": 0.0,
		"games_played": 0,
		"games_won": 0
	}
	_save_save_data()
