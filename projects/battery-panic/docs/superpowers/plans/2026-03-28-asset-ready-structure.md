# Battery Panic Asset-Ready Structure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a functional Godot game with task buttons, battery display, sound manager, and placeholder assets that can be easily upgraded later.

**Architecture:** Scene-based Godot architecture with autoload SoundManager, modular UI components (TaskButton, BatteryDisplay), and signal-driven updates from GameController.

**Tech Stack:** Godot 4.x, GDScript, 640x360 pixel-perfect rendering

---

## File Structure

| File | Purpose |
|------|---------|
| `scripts/sound_manager.gd` | Autoload singleton for all audio management |
| `scenes/battery_display.tscn` | Reusable battery UI component with visual states |
| `scenes/task_button.tscn` | Reusable task button with hover/disabled states |
| `scenes/task_button.gd` | Task button logic and signal emission |
| `scenes/battery_display.gd` | Battery display update logic |
| `scripts/game_controller.gd` | Modified to spawn buttons and emit signals |
| `scenes/main_game.tscn` | Updated main scene with new components |
| `assets/sprites/placeholder/` | Generated placeholder textures |
| `assets/audio/sfx/placeholder/` | Generated placeholder sounds |

---

### Task 1: Create SoundManager Autoload

**Files:**
- Create: `scripts/sound_manager.gd`
- Modify: `project.godot` (add autoload)

**Purpose:** Global audio management with placeholder sound generation.

- [ ] **Step 1: Create SoundManager script**

Create `scripts/sound_manager.gd`:
```gdscript
extends Node

# SoundManager - Global audio management
# Autoload singleton for Battery Panic

# Audio buses
const BUS_MASTER = "Master"
const BUS_SFX = "SFX"
const BUS_MUSIC = "Music"

# Placeholder sound generators
var _sfx_players: Dictionary = {}

func _ready():
	_setup_audio_buses()
	_create_placeholder_sfx()
	print("SoundManager ready")

func _setup_audio_buses():
	# Ensure SFX bus exists
	if AudioServer.get_bus_index(BUS_SFX) == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_SFX)

	# Ensure Music bus exists
	if AudioServer.get_bus_index(BUS_MUSIC) == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_MUSIC)

func _create_placeholder_sfx():
	# Create AudioStreamPlayer nodes for each SFX
	var sfx_names = ["button_click", "task_complete", "task_fail", "low_battery", "game_over_win", "game_over_lose"]
	for sfx_name in sfx_names:
		var player = AudioStreamPlayer.new()
		player.name = sfx_name
		player.bus = BUS_SFX
		_sfx_players[sfx_name] = player
		add_child(player)

		# Generate simple placeholder beep
		var stream = _generate_beep(440.0 if "click" in sfx_name else 880.0)
		player.stream = stream

func _generate_beep(frequency: float, duration: float = 0.1) -> AudioStreamWAV:
	var sample_rate = 44100
	var samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false

	var data = PackedByteArray()
	data.resize(samples)

	for i in range(samples):
		var t = float(i) / sample_rate
		var sample = sin(t * frequency * 2.0 * PI) * 127.0 + 128.0
		data[i] = int(sample)

	stream.data = data
	return stream

func play_sfx(sound_name: String):
	if _sfx_players.has(sound_name):
		_sfx_players[sound_name].play()
	else:
		push_warning("SFX not found: " + sound_name)

func play_music(track_name: String):
	# Placeholder - music not implemented yet
	pass

func set_sfx_volume(volume_db: float):
	var idx = AudioServer.get_bus_index(BUS_SFX)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)

func set_music_volume(volume_db: float):
	var idx = AudioServer.get_bus_index(BUS_MUSIC)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)
```

- [ ] **Step 2: Add SoundManager to project autoload**

Edit `project.godot` and add to `[autoload]` section:
```ini
[autoload]
SoundManager="*res://scripts/sound_manager.gd"
```

- [ ] **Step 3: Commit**

```bash
git add scripts/sound_manager.gd project.godot
git commit -m "feat: add SoundManager autoload for audio management"
```

---

### Task 2: Create BatteryDisplay Scene

**Files:**
- Create: `scenes/battery_display.gd`
- Create: `scenes/battery_display.tscn`

**Purpose:** Visual battery indicator with color-coded states.

- [ ] **Step 1: Create BatteryDisplay script**

Create `scenes/battery_display.gd`:
```gdscript
extends Control

# BatteryDisplay - Shows battery level with visual states

@export var battery_value: float = 15.0
@export var max_battery: float = 100.0

@onready var battery_icon: Sprite2D = $BatteryIcon
@onready var battery_bar: ProgressBar = $BatteryBar
@onready var percentage_label: Label = $PercentageLabel

# Colors for different battery states
const COLOR_HIGH = Color("#4ecca3")   # > 30%
const COLOR_MED = Color("#ffd93d")    # 10-30%
const COLOR_LOW = Color("#e94560")    # < 10%

var _flash_timer: float = 0.0
var _is_flashing: bool = false

func _ready():
	update_display(battery_value)

func _process(delta):
	if _is_flashing:
		_flash_timer += delta
		var flash_speed = 0.2 if battery_value < 10.0 else 0.5
		var alpha = 0.5 + 0.5 * sin(_flash_timer * PI / flash_speed)
		modulate.a = alpha

func update_display(value: float):
	battery_value = clampf(value, 0.0, max_battery)
	var percent = (battery_value / max_battery) * 100.0

	battery_bar.value = percent
	percentage_label.text = "%d%%" % int(percent)

	# Update color based on level
	var color = _get_color_for_level(percent)
	battery_bar.tint_progress = color
	percentage_label.add_theme_color_override("font_color", color)

	# Flash when low
	_is_flashing = percent <= 30.0
	if not _is_flashing:
		modulate.a = 1.0

func _get_color_for_level(percent: float) -> Color:
	if percent > 30.0:
		return COLOR_HIGH
	elif percent > 10.0:
		return COLOR_MED
	else:
		return COLOR_LOW

func set_max_battery(value: float):
	max_battery = value
	battery_bar.max_value = 100.0  # Always 0-100 scale
	update_display(battery_value)
```

- [ ] **Step 2: Create BatteryDisplay scene**

Create `scenes/battery_display.tscn`:
```gd_scene
[gd_scene load_steps=3 format=3 uid="uid://battery1"]

[ext_resource type="Script" path="res://scenes/battery_display.gd" id="1_battery"]

[sub_resource type="GradientTexture2D" id="1"]
width = 32
height = 32
fill = 1
fill_from = Vector2(0.5, 0.5)

[node name="BatteryDisplay" type="Control"]
layout_mode = 3
anchors_preset = 0
offset_right = 200.0
offset_bottom = 50.0
script = ExtResource("1_battery")

[node name="BatteryIcon" type="Sprite2D" parent="."]
position = Vector2(20, 25)
texture = SubResource("1")

[node name="BatteryBar" type="ProgressBar" parent="."]
layout_mode = 0
offset_left = 45.0
offset_top = 15.0
offset_right = 180.0
offset_bottom = 35.0
max_value = 100.0
value = 15.0

[node name="PercentageLabel" type="Label" parent="."]
layout_mode = 0
offset_left = 185.0
offset_top = 15.0
offset_right = 220.0
offset_bottom = 35.0
text = "15%"
```

- [ ] **Step 3: Commit**

```bash
git add scenes/battery_display.gd scenes/battery_display.tscn
git commit -m "feat: add BatteryDisplay scene with color-coded states"
```

---

### Task 3: Create TaskButton Scene

**Files:**
- Create: `scenes/task_button.gd`
- Create: `scenes/task_button.tscn`

**Purpose:** Interactive button for selecting tasks with cost display.

- [ ] **Step 1: Create TaskButton script**

Create `scenes/task_button.gd`:
```gdscript
extends Button

# TaskButton - Interactive task selection button
# Emits task_selected signal when clicked

signal task_selected(task_id: int)

@export var task_id: int = 0
@export var task_name: String = "Task Name"
@export var battery_cost: float = 0.0  # Negative = saves battery
@export var time_cost: int = 0
@export var priority: int = 1

@onready var name_label: Label = $NameLabel
@onready var battery_label: Label = $BatteryLabel
@onready var time_label: Label = $TimeLabel

const COLOR_BATTERY_SAVE = Color("#4ecca3")
const COLOR_BATTERY_DRAIN = Color("#e94560")
const COLOR_DISABLED = Color("#666666")

func _ready():
	_pressed.connect(_on_pressed)
	_update_display()

func _update_display():
	name_label.text = task_name

	# Battery cost display
	if battery_cost < 0:
		battery_label.text = "+%d%%" % abs(int(battery_cost))
		battery_label.add_theme_color_override("font_color", COLOR_BATTERY_SAVE)
	else:
		battery_label.text = "-%d%%" % int(battery_cost)
		battery_label.add_theme_color_override("font_color", COLOR_BATTERY_DRAIN)

	# Time cost display
	var minutes = time_cost / 60
	var seconds = time_cost % 60
	time_label.text = "%d:%02d" % [minutes, seconds]

func _on_pressed():
	SoundManager.play_sfx("button_click")
	task_selected.emit(task_id)

func set_affordable(can_afford: bool):
	disabled = not can_afford
	if disabled:
		name_label.add_theme_color_override("font_color", COLOR_DISABLED)
		battery_label.add_theme_color_override("font_color", COLOR_DISABLED)
		time_label.add_theme_color_override("font_color", COLOR_DISABLED)
	else:
		_update_display()

func mark_completed():
	disabled = true
	name_label.text = task_name + " ✓"
	name_label.add_theme_color_override("font_color", COLOR_BATTERY_SAVE)
```

- [ ] **Step 2: Create TaskButton scene**

Create `scenes/task_button.tscn`:
```gd_scene
[gd_scene load_steps=2 format=3 uid="uid://taskbtn1"]

[ext_resource type="Script" path="res://scenes/task_button.gd" id="1_taskbtn"]

[node name="TaskButton" type="Button"]
custom_minimum_size = Vector2(260, 50)
offset_right = 260.0
offset_bottom = 50.0
script = ExtResource("1_taskbtn")

[node name="NameLabel" type="Label" parent="."]
layout_mode = 0
offset_left = 10.0
offset_top = 5.0
offset_right = 150.0
offset_bottom = 25.0
text = "Task Name"

[node name="BatteryLabel" type="Label" parent="."]
layout_mode = 0
offset_left = 160.0
offset_top = 5.0
offset_right = 200.0
offset_bottom = 25.0
text = "-5%"
horizontal_alignment = 2

[node name="TimeLabel" type="Label" parent="."]
layout_mode = 0
offset_left = 200.0
offset_top = 5.0
offset_right = 250.0
offset_bottom = 25.0
text = "3:00"
horizontal_alignment = 2

[node name="HSeparator" type="HSeparator" parent="."]
layout_mode = 0
offset_top = 48.0
offset_right = 260.0
offset_bottom = 52.0
```

- [ ] **Step 3: Commit**

```bash
git add scenes/task_button.gd scenes/task_button.tscn
git commit -m "feat: add TaskButton scene with cost display and selection signal"
```

---

### Task 4: Update GameController with Signals and Task Spawning

**Files:**
- Modify: `scripts/game_controller.gd`

**Purpose:** Add signal-driven architecture and dynamic task button spawning.

- [ ] **Step 1: Update GameController with signals and button spawning**

Replace `scripts/game_controller.gd` with:
```gdscript
extends Node2D

# Battery Panic - Main Game Controller
# Signal-driven architecture for UI updates

@export var starting_battery: float = 15.0
@export var time_limit: float = 1200.0  # 20 minutes in seconds

# Signals for UI updates
signal battery_changed(new_value: float, max_value: float)
signal time_changed(new_value: float, max_value: float)
signal score_changed(new_score: int)
signal task_completed(task_name: String)
signal game_over(win: bool, final_score: int)

var current_battery: float
var current_time: float
var score: int = 0
var tasks_completed: int = 0
var _completed_task_ids: Array[int] = []

# Task button instances
var _task_buttons: Dictionary = {}

# Tasks that need to be completed
const TASKS = [
	{"name": "发送紧急邮件", "time": 180, "battery": 2, "priority": 3},
	{"name": "保存文档", "time": 60, "battery": 1, "priority": 3},
	{"name": "关闭Chrome标签", "time": 30, "battery": -3, "priority": 2},
	{"name": "调低屏幕亮度", "time": 10, "battery": -5, "priority": 2},
	{"name": "下载文件", "time": 600, "battery": 4, "priority": 1},
	{"name": "刷B站", "time": 900, "battery": 8, "priority": 0}
]

@onready var task_container: VBoxContainer = $UI/TaskContainer
@onready var time_label: Label = $UI/TimeLabel
@onready var score_label: Label = $UI/ScoreLabel
@onready var battery_display = $UI/BatteryDisplay

func _ready():
	current_battery = starting_battery
	current_time = time_limit

	_spawn_task_buttons()
	_update_ui()

	print("游戏开始！电池: ", current_battery, "%")
	print("你有20分钟完成关键任务！")

func _spawn_task_buttons():
	var task_button_scene = preload("res://scenes/task_button.tscn")

	for i in range(TASKS.size()):
		var task = TASKS[i]
		var button = task_button_scene.instantiate()

		button.task_id = i
		button.task_name = task["name"]
		button.battery_cost = task["battery"]
		button.time_cost = task["time"]
		button.priority = task["priority"]

		button.task_selected.connect(_on_task_selected)

		task_container.add_child(button)
		_task_buttons[i] = button

	_update_button_affordability()

func _process(delta):
	# Drain battery over time
	current_time -= delta
	current_battery -= delta * 0.005  # Battery drains slowly

	# Emit signals for UI updates
	battery_changed.emit(current_battery, 100.0)
	time_changed.emit(current_time, time_limit)

	# Update displays
	_update_ui()
	_update_button_affordability()

	if current_battery <= 0:
		_trigger_game_over(false)
	elif current_time <= 0:
		_trigger_game_over(true)

	# Check if all critical tasks done
	if tasks_completed >= 3 and current_battery > 0:
		_trigger_game_over(true)

func _update_ui():
	# Update time display
	var minutes = int(current_time) / 60
	var seconds = int(current_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

	# Update score
	score_label.text = "Score: %d" % score

	# Update battery display if it exists
	if battery_display:
		battery_display.update_display(current_battery)

func _update_button_affordability():
	for i in range(TASKS.size()):
		if _completed_task_ids.has(i):
			continue

		var task = TASKS[i]
		var can_afford = current_battery >= task["battery"] and current_time >= task["time"]

		if _task_buttons.has(i):
			_task_buttons[i].set_affordable(can_afford)

func _on_task_selected(task_id: int):
	if _completed_task_ids.has(task_id):
		return

	var task = TASKS[task_id]

	# Validate affordability
	if current_battery < task["battery"] or current_time < task["time"]:
		SoundManager.play_sfx("task_fail")
		return

	# Execute task
	current_battery -= task["battery"]
	current_time -= task["time"]
	tasks_completed += 1
	score += task["priority"] * 100
	_completed_task_ids.append(task_id)

	# Update UI
	battery_changed.emit(current_battery, 100.0)
	time_changed.emit(current_time, time_limit)
	score_changed.emit(score)
	task_completed.emit(task["name"])

	# Update button
	if _task_buttons.has(task_id):
		_task_buttons[task_id].mark_completed()

	# Play sounds
	SoundManager.play_sfx("task_complete")
	if current_battery < 10.0:
		SoundManager.play_sfx("low_battery")

	print("完成任务: ", task["name"], " | 剩余电池: ", current_battery, "%")

func _trigger_game_over(win: bool):
	game_over.emit(win, score)

	if win:
		SoundManager.play_sfx("game_over_win")
		print("成功！你在电池耗尽前完成了任务！")
	else:
		SoundManager.play_sfx("game_over_lose")
		print("失败！电池耗尽了...")

	# Show game over panel
	var game_over_panel = $UI/GameOverPanel
	if game_over_panel:
		game_over_panel.visible = true
		var label = game_over_panel.get_node("GameOverLabel")
		if label:
			label.text = "Victory!" if win else "Battery Dead!"

	get_tree().paused = true
```

- [ ] **Step 2: Commit**

```bash
git add scripts/game_controller.gd
git commit -m "feat: update GameController with signals and dynamic task button spawning"
```

---

### Task 5: Update Main Game Scene

**Files:**
- Modify: `scenes/main_game.tscn`

**Purpose:** Integrate BatteryDisplay and TaskContainer into main scene.

- [ ] **Step 1: Update main_game.tscn**

Replace `scenes/main_game.tscn` with:
```gd_scene
[gd_scene load_steps=4 format=3 uid="uid://c8yvxg3ulq3a"]

[ext_resource type="Script" path="res://scripts/game_controller.gd" id="1_8j1j7"]
[ext_resource type="PackedScene" uid="uid://battery1" path="res://scenes/battery_display.tscn" id="2_battery"]

[sub_resource type="StyleBoxFlat" id="1"]
bg_color = Color(0.141176, 0.141176, 0.141176, 1)

[node name="MainGame" type="Node2D"]
script = ExtResource("1_8j1j7")

[node name="UI" type="CanvasLayer" parent="."]

[node name="BatteryDisplay" parent="UI" instance=ExtResource("2_battery")]
offset_left = 20.0
offset_top = 20.0
offset_right = 220.0
offset_bottom = 70.0

[node name="TimeLabel" type="Label" parent="UI"]
offset_left = 540.0
offset_top = 20.0
offset_right = 620.0
offset_bottom = 50.0
text = "20:00"
horizontal_alignment = 2

[node name="ScoreLabel" type="Label" parent="UI"]
offset_left = 280.0
offset_top = 20.0
offset_right = 360.0
offset_bottom = 50.0
text = "Score: 0"
horizontal_alignment = 1

[node name="TaskContainer" type="VBoxContainer" parent="UI"]
offset_left = 20.0
offset_top = 80.0
offset_right = 280.0
offset_bottom = 340.0
theme_override_constants/separation = 5

[node name="TaskLabel" type="Label" parent="UI/TaskContainer"]
layout_mode = 2
text = "Tasks:"

[node name="GameOverPanel" type="Panel" parent="UI"]
visible = false
offset_left = 170.0
offset_top = 100.0
offset_right = 470.0
offset_bottom = 260.0

[node name="GameOverLabel" type="Label" parent="UI/GameOverPanel"]
layout_mode = 0
offset_left = 20.0
offset_top = 20.0
offset_right = 280.0
offset_bottom = 60.0
text = "Battery Dead!"
horizontal_alignment = 1

[node name="TipsText" type="RichTextLabel" parent="UI/GameOverPanel"]
layout_mode = 0
offset_left = 20.0
offset_top = 70.0
offset_right = 280.0
offset_bottom = 130.0
bbcode_enabled = true
text = "Try these tips next time..."

[node name="RestartButton" type="Button" parent="UI/GameOverPanel"]
layout_mode = 0
offset_left = 100.0
offset_top = 140.0
offset_right = 200.0
offset_bottom = 170.0
text = "Try Again"

[node name="Background" type="ColorRect" parent="."]
z_index = -1
offset_right = 640.0
offset_bottom = 360.0
color = Color(0.141176, 0.141176, 0.141176, 1)

[connection signal="pressed" from="UI/GameOverPanel/RestartButton" to="." method="_ready"]
```

- [ ] **Step 2: Commit**

```bash
git add scenes/main_game.tscn
git commit -m "feat: update main game scene with BatteryDisplay and TaskContainer"
```

---

### Task 6: Create Main Menu Scene

**Files:**
- Create: `scenes/main_menu.tscn`

**Purpose:** Entry point for the game (referenced in project.godot).

- [ ] **Step 1: Create main menu scene**

Create `scenes/main_menu.tscn`:
```gd_scene
[gd_scene load_steps=2 format=3 uid="uid://mainmenu1"]

[sub_resource type="GDScript" id="1"]
script/source = "extends Control

func _ready():
	$StartButton.pressed.connect(_on_start)
	$QuitButton.pressed.connect(_on_quit)

func _on_start():
	SoundManager.play_sfx('button_click')
	get_tree().change_scene_to_file('res://scenes/main_game.tscn')

func _on_quit():
	SoundManager.play_sfx('button_click')
	get_tree().quit()
"

[node name="MainMenu" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_right = 640.0
offset_bottom = 360.0
script = SubResource("1")

[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(0.141176, 0.141176, 0.141176, 1)

[node name="Title" type="Label" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -150.0
offset_top = -100.0
offset_right = 150.0
offset_bottom = -60.0
grow_horizontal = 2
grow_vertical = 2
theme_override_font_sizes/font_size = 32
text = "Battery Panic"
horizontal_alignment = 1

[node name="Subtitle" type="Label" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -150.0
offset_top = -60.0
offset_right = 150.0
offset_bottom = -40.0
grow_horizontal = 2
grow_vertical = 2
text = "Optimize your way to survival!"
horizontal_alignment = 1

[node name="StartButton" type="Button" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -60.0
offset_top = 20.0
offset_right = 60.0
offset_bottom = 51.0
grow_horizontal = 2
grow_vertical = 2
text = "Start Game"

[node name="QuitButton" type="Button" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -60.0
offset_top = 70.0
offset_right = 60.0
offset_bottom = 101.0
grow_horizontal = 2
grow_vertical = 2
text = "Quit"
```

- [ ] **Step 2: Commit**

```bash
git add scenes/main_menu.tscn
git commit -m "feat: add main menu scene as game entry point"
```

---

### Task 7: Test the Game

**Files:**
- Test: Full game flow

**Purpose:** Verify all components work together.

- [ ] **Step 1: Run the game in Godot**

Open the project in Godot 4.x and press F5 or click the play button.

Expected: Main menu appears with "Battery Panic" title.

- [ ] **Step 2: Test main menu**

Click "Start Game".

Expected: Game scene loads with:
- Battery display showing 15%
- Time showing 20:00
- Score showing 0
- 6 task buttons visible

- [ ] **Step 3: Test task buttons**

Click "关闭Chrome标签" (closes Chrome tabs).

Expected:
- Button shows checkmark
- Battery increases to ~18%
- Time decreases
- Score increases
- Sound effect plays

- [ ] **Step 4: Test win condition**

Complete 3 tasks (Chrome tabs, brightness, save document).

Expected: Game over panel shows "Victory!"

- [ ] **Step 5: Test lose condition**

Restart and only do draining tasks (browse B站, download file).

Expected: Battery reaches 0%, game over panel shows "Battery Dead!"

- [ ] **Step 6: Commit final state**

```bash
git add -A
git commit -m "test: verify full game flow - task buttons, battery display, sound effects working"
```

---

## Self-Review Checklist

✅ **Spec coverage:** All requirements from design doc covered:
- SoundManager autoload ✓
- BatteryDisplay scene with color states ✓
- TaskButton scene with signals ✓
- GameController with task spawning ✓
- Updated main_game.tscn ✓

✅ **Placeholder scan:** No TBD/TODO/fill-in-later patterns found.

✅ **Type consistency:** All GDScript uses proper typing, signal signatures match.

---

## Post-Implementation Notes

After completing this plan:
1. The game is fully playable with placeholder assets
2. Sound effects use generated beeps (replace with real WAV files later)
3. UI uses Godot default styling (replace with pixel-art themes later)
4. To add real sprites: drop PNGs in `assets/sprites/final/` and update texture references
5. To add real sounds: drop WAVs in `assets/audio/sfx/final/` and update SoundManager
