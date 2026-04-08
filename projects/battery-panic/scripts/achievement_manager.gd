extends Node

# AchievementManager - Tracks and awards achievements
# Autoload singleton for Battery Panic

enum AchievementType { ONCE, PROGRESS, COUNT }

const ACHIEVEMENTS = {
	# Completion Achievements
	"first_win": {
		"id": "first_win",
		"name": "First Victory",
		"description": "Complete level 1",
		"icon": "🏆",
		"type": AchievementType.ONCE,
		"secret": false
	},
	"all_levels": {
		"id": "all_levels",
		"name": "Master Technician",
		"description": "Complete all 5 levels",
		"icon": "👑",
		"type": AchievementType.ONCE,
		"secret": false
	},
	"perfect_run": {
		"id": "perfect_run",
		"name": "Perfect Run",
		"description": "Complete a level with 3 stars",
		"icon": "⭐",
		"type": AchievementType.ONCE,
		"secret": false
	},

	# Battery Management Achievements
	"battery_saver": {
		"id": "battery_saver",
		"name": "Battery Saver",
		"description": "Finish with >50% battery",
		"icon": "🔋",
		"type": AchievementType.ONCE,
		"secret": false
	},
	"close_call": {
		"id": "close_call",
		"name": "Close Call",
		"description": "Finish with <5% battery",
		"icon": "⚡",
		"type": AchievementType.ONCE,
		"secret": false
	},
	"last_second": {
		"id": "last_second",
		"name": "Last Second Save",
		"description": "Complete task with <10 seconds remaining",
		"icon": "⏰",
		"type": AchievementType.ONCE,
		"secret": false
	},

	# Speed Achievements
	"speed_demon": {
		"id": "speed_demon",
		"name": "Speed Demon",
		"description": "Complete in under 2 minutes",
		"icon": "🏃",
		"type": AchievementType.ONCE,
		"secret": false
	},
	"speed_runner": {
		"id": "speed_runner",
		"name": "Speed Runner",
		"description": "Complete any level in under 1 minute",
		"icon": "⚡",
		"type": AchievementType.ONCE,
		"secret": false
	},

	# Terminal Achievements
	"terminal_master": {
		"id": "terminal_master",
		"name": "Terminal Master",
		"description": "Use 5 terminal commands in one game",
		"icon": "⌨️",
		"type": AchievementType.COUNT,
		"target": 5,
		"secret": false
	},
	"command_expert": {
		"id": "command_expert",
		"name": "Command Expert",
		"description": "Use all available commands",
		"icon": "💻",
		"type": AchievementType.ONCE,
		"secret": false
	},

	# Task Achievements
	"task_master": {
		"id": "task_master",
		"name": "Task Master",
		"description": "Complete 50 tasks total",
		"icon": "📋",
		"type": AchievementType.COUNT,
		"target": 50,
		"secret": false
	},
	"no_distractions": {
		"id": "no_distractions",
		"name": "No Distractions",
		"description": "Win without watching videos",
		"icon": "🎯",
		"type": AchievementType.ONCE,
		"secret": true
	},

	# Mode Achievements
	"real_time_hero": {
		"id": "real_time_hero",
		"name": "Real-Time Hero",
		"description": "Win in real-time mode",
		"icon": "🔥",
		"type": AchievementType.ONCE,
		"secret": false
	},
	"turn_based_master": {
		"id": "turn_based_master",
		"name": "Strategist",
		"description": "Win in turn-based mode",
		"icon": "🧠",
		"type": AchievementType.ONCE,
		"secret": false
	}
}

# Runtime achievement progress (not saved, per session)
var _session_progress: Dictionary = {}

signal achievement_unlocked(achievement_id: String, achievement_data: Dictionary)

func _ready() -> void:
	print("AchievementManager ready with %d achievements" % ACHIEVEMENTS.size())

# Achievement Unlocking

func unlock(achievement_id: String) -> bool:
	if not ACHIEVEMENTS.has(achievement_id):
		push_warning("Achievement not found: " + achievement_id)
		return false

	if is_unlocked(achievement_id):
		return false

	# Save to LevelManager's save data
	var save_data = LevelManager.get_save_data()
	if not save_data.has("achievements"):
		save_data["achievements"] = {}

	save_data.achievements[achievement_id] = {
		"unlocked_at": Time.get_unix_time_from_system()
	}
	LevelManager.set_save_data(save_data)

	var achievement = ACHIEVEMENTS[achievement_id]
	achievement_unlocked.emit(achievement_id, achievement)

	print("Achievement unlocked: %s - %s" % [achievement.name, achievement.description])
	return true

func progress(achievement_id: String, amount: int = 1) -> bool:
	if not ACHIEVEMENTS.has(achievement_id):
		return false

	var achievement = ACHIEVEMENTS[achievement_id]
	if achievement.type != AchievementType.COUNT:
		return false

	if not _session_progress.has(achievement_id):
		_session_progress[achievement_id] = 0

	_session_progress[achievement_id] += amount

	if _session_progress[achievement_id] >= achievement.target:
		return unlock(achievement_id)

	return false

func set_progress(achievement_id: String, value: int) -> bool:
	if not ACHIEVEMENTS.has(achievement_id):
		return false

	var achievement = ACHIEVEMENTS[achievement_id]
	if achievement.type != AchievementType.COUNT:
		return false

	_session_progress[achievement_id] = value

	if value >= achievement.target:
		return unlock(achievement_id)

	return false

# Queries

func is_unlocked(achievement_id: String) -> bool:
	var save_data = LevelManager.get_save_data()
	if not save_data.has("achievements"):
		return false
	return save_data.achievements.has(achievement_id)

func get_progress(achievement_id: String) -> int:
	return _session_progress.get(achievement_id, 0)

func get_all_achievements() -> Dictionary:
	return ACHIEVEMENTS

func get_unlocked_achievements() -> Array:
	var unlocked = []
	var save_data = LevelManager.get_save_data()
	if not save_data.has("achievements"):
		return unlocked

	for id in save_data.achievements.keys():
		if ACHIEVEMENTS.has(id):
			unlocked.append(ACHIEVEMENTS[id])
	return unlocked

func get_locked_achievements() -> Array:
	var locked = []
	var save_data = LevelManager.get_save_data()
	var unlocked_ids = save_data.get("achievements", {}).keys()

	for id in ACHIEVEMENTS.keys():
		if not unlocked_ids.has(id):
			locked.append(ACHIEVEMENTS[id])
	return locked

func get_completion_percentage() -> float:
	var save_data = LevelManager.get_save_data()
	var unlocked_count = save_data.get("achievements", {}).size()
	return float(unlocked_count) / ACHIEVEMENTS.size() * 100.0

# Session Tracking Helpers

func track_terminal_command() -> void:
	progress("terminal_master")

func track_task_completed(task_name: String) -> void:
	progress("task_master")

func check_battery_achievement(final_battery: float) -> void:
	if final_battery > 50:
		unlock("battery_saver")
	elif final_battery < 5:
		unlock("close_call")

func check_time_achievement(time_remaining: float, time_limit: float) -> void:
	var elapsed = time_limit - time_remaining
	if elapsed < 60:
		unlock("speed_runner")
	if elapsed < 120:
		unlock("speed_demon")
	if time_remaining < 10:
		unlock("last_second")

func check_level_completion(level_id: int, stars: int) -> void:
	if level_id == 1:
		unlock("first_win")

	if stars == 3:
		unlock("perfect_run")

	# Check if all levels completed
	var save_data = LevelManager.get_save_data()
	var level_scores = save_data.get("level_scores", {})
	var all_completed = true
	for i in range(1, 6):
		if not level_scores.has(str(i)):
			all_completed = false
			break
	if all_completed:
		unlock("all_levels")

func reset_achievements() -> void:
	_session_progress.clear()
	var save_data = LevelManager.get_save_data()
	save_data.achievements = {}
	LevelManager.set_save_data(save_data)
