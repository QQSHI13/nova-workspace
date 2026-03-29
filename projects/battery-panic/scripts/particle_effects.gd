extends Node2D

# ParticleEffects - Visual effects for battery events

@export var particle_texture: Texture2D

var _pooled_particles: Array[GPUParticles2D] = []

func _ready() -> void:
	# Pre-pool some particles
	for i in range(10):
		var particles = _create_particle_system()
		_pooled_particles.append(particles)

func _create_particle_system() -> GPUParticles2D:
	var particles = GPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0

	var material = ParticleProcessMaterial.new()
	particles.process_material = material

	add_child(particles)
	return particles

func spawn_battery_drain_effect(position: Vector2, amount: float) -> void:
	var particles = _get_particle()
	particles.position = position
	particles.amount = int(clampf(amount * 5, 10, 50))

	var material = particles.process_material as ParticleProcessMaterial
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 30.0
	material.direction = Vector3(0, -1, 0)
	material.spread = 45.0
	material.gravity = Vector3(0, 200, 0)
	material.initial_velocity_min = 100.0
	material.initial_velocity_max = 200.0
	material.color = Color("#ff4444")  # Red for drain

	particles.emitting = true

	# Return to pool after emission
	await get_tree().create_timer(2.0).timeout
	_return_particle(particles)

func spawn_battery_save_effect(position: Vector2, amount: float) -> void:
	var particles = _get_particle()
	particles.position = position
	particles.amount = int(clampf(amount * 5, 10, 50))

	var material = particles.process_material as ParticleProcessMaterial
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 30.0
	material.direction = Vector3(0, 1, 0)
	material.spread = 30.0
	material.gravity = Vector3(0, -100, 0)
	material.initial_velocity_min = 150.0
	material.initial_velocity_max = 300.0
	material.color = Color("#44ff44")  # Green for save

	particles.emitting = true

	await get_tree().create_timer(2.0).timeout
	_return_particle(particles)

func spawn_critical_warning_effect(position: Vector2) -> void:
	var particles = _get_particle()
	particles.position = position
	particles.amount = 100

	var material = particles.process_material as ParticleProcessMaterial
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 100.0
	material.spread = 180.0
	material.gravity = Vector3.ZERO
	material.initial_velocity_min = 200.0
	material.initial_velocity_max = 400.0
	material.color = Color("#ff0000")  # Bright red

	particles.emitting = true

	await get_tree().create_timer(3.0).timeout
	_return_particle(particles)

func spawn_success_effect(position: Vector2) -> void:
	var particles = _get_particle()
	particles.position = position
	particles.amount = 30

	var material = particles.process_material as ParticleProcessMaterial
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	material.direction = Vector3(0, -1, 0)
	material.spread = 60.0
	material.gravity = Vector3(0, 300, 0)
	material.initial_velocity_min = 200.0
	material.initial_velocity_max = 400.0
	material.color = Color("#ffd700")  # Gold

	particles.emitting = true

	await get_tree().create_timer(2.0).timeout
	_return_particle(particles)

func _get_particle() -> GPUParticles2D:
	if _pooled_particles.size() > 0:
		return _pooled_particles.pop_back()
	return _create_particle_system()

func _return_particle(particles: GPUParticles2D) -> void:
	particles.emitting = false
	_pooled_particles.append(particles)
