extends Node

# Global audio manager - simple and reliable
var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer

const SOUNDS = {
	"click": preload("res://assets/audio/click.wav"),
	"task": preload("res://assets/audio/task.wav"),
	"error": preload("res://assets/audio/error.wav"),
	"win": preload("res://assets/audio/win.wav"),
	"lose": preload("res://assets/audio/lose.wav"),
}

func _ready():
	# Create pool of SFX players
	for i in 8:
		var player = AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)

	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"

func play_sfx(name: String):
	if not SOUNDS.has(name):
		return

	for player in sfx_players:
		if not player.playing:
			player.stream = SOUNDS[name]
			player.play()
			return

func play_music(stream: AudioStream):
	music_player.stream = stream
	music_player.play()
