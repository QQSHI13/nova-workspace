extends Control

# BatteryTipsScreen - Shows educational content after gameplay
# Displays real battery-saving tips based on game context

const TIPS_DB = {
	"browser": [
		{"title": "Close Unused Tabs", "desc": "Each Chrome tab uses 5-15% battery", "icon": "🌐", "saving": "+15% battery life"},
		{"title": "Use Edge Efficiency Mode", "desc": "Built-in power saving features", "icon": "⚡", "saving": "+25% longer use"},
		{"title": "Block Auto-Play Videos", "desc": "Background videos drain power fast", "icon": "🎬", "saving": "+15% less drain"},
	],
	"display": [
		{"title": "Lower Screen Brightness", "desc": "Screen uses 20-40% of total power", "icon": "🔆", "saving": "+40% battery"},
		{"title": "Shorter Screen Timeout", "desc": "Set to 1 minute or less", "icon": "⏱️", "saving": "+20% life"},
		{"title": "Use Dark Mode", "desc": "OLED screens save 30-40%", "icon": "🌙", "saving": "+30% on OLED"},
	],
	"system": [
		{"title": "Enable Battery Saver", "desc": "Limits background activity", "icon": "🔋", "saving": "+50% longer"},
		{"title": "Close Background Apps", "desc": "Apps running hidden use 10-15%/hr", "icon": "📱", "saving": "+25% battery"},
		{"title": "Unplug USB Devices", "desc": "External drives draw power", "icon": "🔌", "saving": "+10% life"},
	],
	"hardware": [
		{"title": "Clean Air Vents", "desc": "Overheating = faster drain", "icon": "🌡️", "saving": "+15% efficiency"},
		{"title": "Lower Refresh Rate", "desc": "144Hz uses 30% more than 60Hz", "icon": "📺", "saving": "+30% battery"},
		{"title": "Turn Off RGB Lights", "desc": "Keyboard backlighting drains power", "icon": "💡", "saving": "+8% life"},
	]
}

const BATTERY_FACTS = [
	"Lithium batteries last longest when kept between 20%-80% charge",
	"Heat above 40°C permanently damages battery capacity",
	"Modern laptops don't need full discharge cycles",
	"Fast charging generates heat which reduces lifespan",
	"Battery health below 80% means it's time to replace",
	"Cold weather temporarily reduces battery capacity",
	"Original chargers are optimized for your battery",
	"Sleep mode still drains 1-2% per hour",
]

var tips_to_show: Array[Dictionary] = []
var game_result: Dictionary = {}

@onready var tips_container = $Panel/TipsContainer
@onready var fact_label = $Panel/FactLabel
@onready var title_label = $Panel/TitleLabel
@onready var continue_btn = $Panel/ContinueButton

func _ready() -> void:
	continue_btn.pressed.connect(_on_continue)
	_show_random_tips()
	_show_random_fact()
	_animate_entry()

func set_game_result(won: bool, tasks_completed: int, battery_left: float) -> void:
	game_result = {
		"won": won,
		"tasks": tasks_completed,
		"battery": battery_left
	}
	_update_title(won)

func _update_title(won: bool) -> void:
	if won:
		title_label.text = "🎉 Victory! Learn These Tips"
		title_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4))
	else:
		title_label.text = "💡 Learn From This!"
		title_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.3))

func _show_random_tips() -> void:
	# Pick one tip from each category
	var categories = TIPS_DB.keys()
	for category in categories:
		var tips = TIPS_DB[category]
		var random_tip = tips[randi() % tips.size()]
		tips_to_show.append(random_tip)

	# Create tip cards
	for tip in tips_to_show:
		_create_tip_card(tip)

func _create_tip_card(tip: Dictionary) -> void:
	var card = Panel.new()
	card.custom_minimum_size = Vector2(280, 140)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.17, 0.22)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	card.add_theme_stylebox_override("panel", style)

	# Icon
	var icon = Label.new()
	icon.text = tip.icon
	icon.add_theme_font_size_override("font_size", 40)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.position = Vector2(0, 10)
	icon.size = Vector2(280, 50)
	card.add_child(icon)

	# Title
	var title = Label.new()
	title.text = tip.title
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(10, 60)
	title.size = Vector2(260, 25)
	card.add_child(title)

	# Description
	var desc = Label.new()
	desc.text = tip.desc
	desc.add_theme_font_size_override("font_size", 12)
	desc.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.position = Vector2(10, 85)
	desc.size = Vector2(260, 50)
	card.add_child(desc)

	# Saving badge
	var saving = Label.new()
	saving.text = tip.saving
	saving.add_theme_font_size_override("font_size", 11)
	saving.add_theme_color_override("font_color", Color(0.3, 0.9, 0.5))
	saving.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	saving.position = Vector2(10, 120)
	saving.size = Vector2(260, 20)
	card.add_child(saving)

	tips_container.add_child(card)

func _show_random_fact() -> void:
	var fact = BATTERY_FACTS[randi() % BATTERY_FACTS.size()]
	fact_label.text = "💡 Did you know? " + fact

func _animate_entry() -> void:
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)

func _on_continue() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)

func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		accept_event()
		_on_continue()
