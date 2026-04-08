extends Node

# SoundManager - Enhanced audio management with dynamic music
# Autoload singleton for Battery Panic

# Audio buses
const BUS_MASTER = "Master"
const BUS_SFX = "SFX"
const BUS_MUSIC = "Music"
const BUS_AMBIENCE = "Ambience"

# Music intensity levels
enum MusicIntensity { CALM, TENSE, CRITICAL }

# Audio players
var _sfx_players: Dictionary = {}
var _music_player: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer  # For crossfading
var _ambience_player: AudioStreamPlayer
var _current_music_track: String = ""
var _target_intensity: int = MusicIntensity.CALM
var _current_intensity: int = MusicIntensity.CALM

# Music tracks (placeholder paths - would be actual audio files)
var _music_tracks = {
	"menu": "res://assets/audio/music/menu_theme.ogg",
	"gameplay_calm": "res://assets/audio/music/gameplay_calm.ogg",
	"gameplay_tense": "res://assets/audio/music/gameplay_tense.ogg",
	"gameplay_critical": "res://assets/audio/music/gameplay_critical.ogg",
	"victory": "res://assets/audio/music/victory.ogg",
	"defeat": "res://assets/audio/music/defeat.ogg"
}

# SFX volumes for mixing
var _sfx_volumes = {
	"button_click": 0.0,
	"button_hover": -10.0,
	"task_complete": 0.0,
	"task_fail": 0.0,
	"low_battery": -5.0,
	"battery_save": 0.0,
	"game_over_win": 0.0,
	"game_over_lose": 0.0,
	"terminal_type": -15.0,
	"terminal_execute": -5.0
}

func _ready() -> void:
	_setup_audio_buses()
	_create_sfx_players()
	_create_music_players()
	_create_ambience_player()
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

	# Ensure Ambience bus exists
	if AudioServer.get_bus_index(BUS_AMBIENCE) == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_AMBIENCE)

func _create_sfx_players() -> void:
	# Create AudioStreamPlayer nodes for each SFX
	var sfx_names = _sfx_volumes.keys()
	for sfx_name in sfx_names:
		var player = AudioStreamPlayer.new()
		player.name = sfx_name
		player.bus = BUS_SFX
		player.volume_db = _sfx_volumes[sfx_name]
		_sfx_players[sfx_name] = player
		add_child(player)

		# Generate placeholder beep
		var stream = _generate_sfx_stream(sfx_name)
		player.stream = stream

func _generate_sfx_stream(sfx_name: String) -> AudioStreamWAV:
	var frequency = 440.0
	var duration = 0.1
	var waveform = "sine"

	match sfx_name:
		"button_click":
			frequency = 800.0
			duration = 0.05
			waveform = "square"
		"button_hover":
			frequency = 600.0
			duration = 0.03
			waveform = "sine"
		"task_complete":
			frequency = 880.0
			duration = 0.2
			waveform = "sine"
		"task_fail":
			frequency = 220.0
			duration = 0.3
			waveform = "saw"
		"low_battery":
			frequency = 440.0
			duration = 0.4
			waveform = "square"
		"battery_save":
			frequency = 660.0
			duration = 0.25
			waveform = "sine"
		"game_over_win":
			frequency = 1100.0
			duration = 0.5
			waveform = "sine"
		"game_over_lose":
			frequency = 150.0
			duration = 0.8
			waveform = "saw"
		"terminal_type":
			frequency = 2000.0
			duration = 0.01
			waveform = "noise"
		"terminal_execute":
			frequency = 400.0
			duration = 0.15
			waveform = "square"

	return _generate_waveform(frequency, duration, waveform)

func _generate_waveform(frequency: float, duration: float, waveform: String) -> AudioStreamWAV:
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
		var sample = 128.0

		match waveform:
			"sine":
				sample = sin(t * frequency * 2.0 * PI) * 127.0 + 128.0
			"square":
				sample = 128.0 + (127.0 if sin(t * frequency * 2.0 * PI) > 0 else -127.0)
			"saw":
				var phase = fmod(t * frequency, 1.0)
				sample = 128.0 + (phase * 2.0 - 1.0) * 127.0
			"noise":
				sample = randf() * 255.0
			_:
				sample = sin(t * frequency * 2.0 * PI) * 127.0 + 128.0

		data[i] = int(clamp(sample, 0, 255))

	stream.data = data
	return stream

func _create_music_players() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayerA"
	_music_player.bus = BUS_MUSIC
	add_child(_music_player)

	_music_player_b = AudioStreamPlayer.new()
	_music_player_b.name = "MusicPlayerB"
	_music_player_b.bus = BUS_MUSIC
	add_child(_music_player_b)

func _create_ambience_player() -> void:
	_ambience_player = AudioStreamPlayer.new()
	_ambience_player.name = "AmbiencePlayer"
	_ambience_player.bus = BUS_AMBIENCE
	_ambience_player.volume_db = -20.0
	add_child(_ambience_player)

# Public API

func play_sfx(sound_name: String) -> void:
	if _sfx_players.has(sound_name):
		_sfx_players[sound_name].play()
	else:
		push_warning("SFX not found: " + sound_name)

func play_sfx_random_pitch(sound_name: String, min_pitch: float = 0.9, max_pitch: float = 1.1) -> void:
	if _sfx_players.has(sound_name):
		var player = _sfx_players[sound_name]
		var cb = _on_player_finished_reset_pitch.bind(player)
		if player.finished.is_connected(cb):
			player.finished.disconnect(cb)
		player.pitch_scale = randf_range(min_pitch, max_pitch)
		player.play()
		player.finished.connect(cb, CONNECT_ONE_SHOT)

func _on_player_finished_reset_pitch(player: AudioStreamPlayer) -> void:
	player.pitch_scale = 1.0

func play_music(track_name: String, fade_duration: float = 1.0) -> void:
	if track_name == _current_music_track:
		return

	var track_path = _music_tracks.get(track_name, "")
	if track_path.is_empty():
		push_warning("Music track not found: " + track_name)
		return

	# For now, just switch (actual file loading would go here)
	_current_music_track = track_name
	print("Playing music: " + track_name)

func stop_music(fade_duration: float = 1.0) -> void:
	_current_music_track = ""
	if _music_player.playing:
		_music_player.stop()
	if _music_player_b.playing:
		_music_player_b.stop()

func update_music_intensity(battery_percent: float) -> void:
	# Change music based on battery level
	if battery_percent > 20:
		_target_intensity = MusicIntensity.CALM
	elif battery_percent > 10:
		_target_intensity = MusicIntensity.TENSE
	else:
		_target_intensity = MusicIntensity.CRITICAL

	if _target_intensity != _current_intensity:
		_current_intensity = _target_intensity
		_apply_music_intensity()

func _apply_music_intensity() -> void:
	match _current_intensity:
		MusicIntensity.CALM:
			if _current_music_track.begins_with("gameplay"):
				play_music("gameplay_calm", 2.0)
		MusicIntensity.TENSE:
			if _current_music_track.begins_with("gameplay"):
				play_music("gameplay_tense", 2.0)
		MusicIntensity.CRITICAL:
			if _current_music_track.begins_with("gameplay"):
				play_music("gameplay_critical", 1.0)

func play_ambience(ambience_name: String) -> void:
	# Ambience sounds: "computer_hum", "keyboard_clicks", "fan_noise"
	print("Playing ambience: " + ambience_name)

func stop_ambience() -> void:
	if _ambience_player.playing:
		_ambience_player.stop()

# Volume Control

func set_sfx_volume(volume_db: float) -> void:
	var idx = AudioServer.get_bus_index(BUS_SFX)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)

func set_music_volume(volume_db: float) -> void:
	var idx = AudioServer.get_bus_index(BUS_MUSIC)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)

func set_ambience_volume(volume_db: float) -> void:
	var idx = AudioServer.get_bus_index(BUS_AMBIENCE)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)

func set_master_volume(volume_db: float) -> void:
	var idx = AudioServer.get_bus_index(BUS_MASTER)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)

func linear_to_db(linear: float) -> float:
	if linear <= 0:
		return -80.0
	return 20.0 * log(linear) / log(10)
