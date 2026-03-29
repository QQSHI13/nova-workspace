extends Node

# SoundManager - Global audio management
# Autoload singleton for Battery Panic

# Audio buses
const BUS_MASTER = "Master"
const BUS_SFX = "SFX"
const BUS_MUSIC = "Music"

# Placeholder sound generators
var _sfx_players: Dictionary = {}

func _ready() -> void:
	_setup_audio_buses()
	_create_placeholder_sfx()
	print("SoundManager ready")

func _setup_audio_buses() -> void:
	# Ensure SFX bus exists
	if AudioServer.get_bus_index(BUS_SFX) == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_SFX)

	# Ensure Music bus exists
	if AudioServer.get_bus_index(BUS_MUSIC) == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_MUSIC)

func _create_placeholder_sfx() -> void:
	# Create AudioStreamPlayer nodes for each SFX
	var sfx_names = ["button_click", "button_hover", "task_complete", "task_fail", "low_battery", "game_over_win", "game_over_lose"]
	for sfx_name in sfx_names:
		var player = AudioStreamPlayer.new()
		player.name = sfx_name
		player.bus = BUS_SFX
		_sfx_players[sfx_name] = player
		add_child(player)

		# Generate simple placeholder beep
		var freq = 440.0
		if "hover" in sfx_name:
			freq = 330.0
		elif "complete" in sfx_name:
			freq = 880.0
		elif "fail" in sfx_name:
			freq = 220.0
		elif "win" in sfx_name:
			freq = 1100.0
		elif "lose" in sfx_name:
			freq = 150.0

		var stream = _generate_beep(freq)
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

func play_sfx(sound_name: String) -> void:
	if _sfx_players.has(sound_name):
		_sfx_players[sound_name].play()
	else:
		push_warning("SFX not found: " + sound_name)

func play_music(_track_name: String) -> void:
	# Placeholder - music not implemented yet
	pass

func set_sfx_volume(volume_db: float) -> void:
	var idx = AudioServer.get_bus_index(BUS_SFX)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)

func set_music_volume(volume_db: float) -> void:
	var idx = AudioServer.get_bus_index(BUS_MUSIC)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)
