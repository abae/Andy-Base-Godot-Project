extends Node

var menu_music = load("res://sound/music/hhTitle.ogg")
var menu_music_loop = load("res://sound/music/hhTitle2.ogg")
var game_music_bell = load("res://sound/music/hhGameBell.ogg")
var game_music_clarinet = load("res://sound/music/hhGameClarinet.ogg")
var game_music_cowbell = load("res://sound/music/hhGameCowbell.ogg")
var game_music_miracha = load("res://sound/music/hhGameMiracha.ogg")
var game_music_piano = load("res://sound/music/hhGamePiano.ogg")
var game_music_trombone = load("res://sound/music/hhGameTrombone.ogg")
var woods = load("res://sound/sfx/sfx_birds.ogg")

@onready var music1 = $Music1
@onready var music2 = $Music2
@onready var music3 = $Music3
@onready var music4 = $Music4
@onready var music5 = $Music5
@onready var music6 = $Music6

var tracks = []
var current_track_index = 0

func _ready():
	tracks = [music1, music2, music3, music4, music5, music6]

func play_menu_music():
	if music1.stream != menu_music:
		music1.stream = menu_music
		music2.stream = menu_music_loop
		music3.stream = woods
		music2.volume_linear = 0.0
		music3.volume_linear = 0.0
		music1.play()
		music2.play()
		music3.play()
		await crossfade_equal_power(music1, music2, 20.0)

func crossfade_equal_power(a, b, time := 1.0):
	var tween = create_tween()

	tween.tween_method(func(t):
		# t goes 0 → 1
		a.volume_linear = cos(t * PI * 0.5)
		b.volume_linear = sin(t * PI * 0.5)
	, 0.0, 1.0, time)

	tween.finished.connect(func():
		a.volume_linear = 0
		b.volume_linear = 1
	)

func fade_out_menu_music(time := 1.0):
	var start_v1 = music1.volume_linear
	var start_v2 = music2.volume_linear
	var start_v3 = music3.volume_linear

	var tween = create_tween()
	tween.tween_method(func(t):
		music1.volume_linear = lerp(start_v1, 0.0, t)
		music2.volume_linear = lerp(start_v2, 0.0, t)
		music3.volume_linear = lerp(start_v3, 1.0, t)
	, 0.0, 1.0, time)

	tween.finished.connect(func():
		music1.stop()
		music2.stop()
	)

func play_game_music():
	tracks[0].stream = game_music_piano
	tracks[1].stream = game_music_cowbell
	tracks[2].stream = game_music_miracha
	tracks[3].stream = game_music_clarinet
	tracks[4].stream = game_music_bell
	tracks[5].stream = game_music_trombone
	for music_player in tracks:
		music_player.volume_linear = 0.0
		music_player.play()
	tracks[0].volume_linear = 1.0
	current_track_index = 1

func add_new_track():
	var current_player = tracks[current_track_index]

	var tween = create_tween()
	tween.tween_method(func(t):
		current_player.volume_linear = sin(t * PI * 0.5)
	, 0.0, 1.0, 5.0)

	tween.finished.connect(func():
		current_player.volume_linear = 1.0
	)

	current_track_index += 1
