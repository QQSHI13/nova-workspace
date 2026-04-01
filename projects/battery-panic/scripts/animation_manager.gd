extends Node

# AnimationManager - Global animation utilities for juice and polish

# Screen shake
func screen_shake(node: Node2D, intensity: float = 10.0, duration: float = 0.5) -> void:
	var tween = create_tween()
	var original_pos = node.position

	for i in range(int(duration * 60)):
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(node, "position", original_pos + offset, 0.016)

	tween.tween_property(node, "position", original_pos, 0.1)

# Pulse scale effect
func pulse_scale(node: Node2D, target_scale: float = 1.2, duration: float = 0.3) -> void:
	var tween = create_tween()
	var original_scale = node.scale

	tween.tween_property(node, "scale", Vector2(target_scale, target_scale), duration * 0.5)
	tween.tween_property(node, "scale", original_scale, duration * 0.5)

# Flash color effect
func flash_color(node: CanvasItem, color: Color, duration: float = 0.2) -> void:
	var tween = create_tween()
	var original_modulate = node.modulate

	tween.tween_property(node, "modulate", color, duration * 0.5)
	tween.tween_property(node, "modulate", original_modulate, duration * 0.5)

# Slide in animation
func slide_in(node: Control, from_right: bool = true, duration: float = 0.5) -> void:
	var tween = create_tween()
	var target_pos = node.position
	var start_pos = target_pos

	if from_right:
		start_pos.x += 200
	else:
		start_pos.x -= 200

	node.position = start_pos
	tween.tween_property(node, "position", target_pos, duration)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

# Bounce effect
func bounce(node: Control, height: float = 20.0, duration: float = 0.4) -> void:
	var tween = create_tween()
	var original_pos = node.position

	tween.tween_property(node, "position:y", original_pos.y - height, duration * 0.4)
	tween.tween_property(node, "position:y", original_pos.y, duration * 0.6)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)

# Fade in/out - works with CanvasItem or CanvasLayer
func fade_in(node: Node, duration: float = 0.3) -> void:
	if node is CanvasItem:
		node.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(node, "modulate:a", 1.0, duration)
	elif node is CanvasLayer:
		# For CanvasLayer, get the first child Control and fade that
		for child in node.get_children():
			if child is CanvasItem:
				child.modulate.a = 0.0
				var tween = create_tween()
				tween.tween_property(child, "modulate:a", 1.0, duration)
				break

func fade_out(node: Node, duration: float = 0.3) -> void:
	if node is CanvasItem:
		var tween = create_tween()
		tween.tween_property(node, "modulate:a", 0.0, duration)
	elif node is CanvasLayer:
		for child in node.get_children():
			if child is CanvasItem:
				var tween = create_tween()
				tween.tween_property(child, "modulate:a", 0.0, duration)
				break

# Number counting animation
func animate_number(label: Label, from_value: int, to_value: int, duration: float = 1.0, prefix: String = "") -> void:
	var tween = create_tween()
	var current = from_value

	tween.tween_method(
		func(val: int): label.text = prefix + str(val),
		from_value,
		to_value,
		duration
	)
