extends Node

var menu_music = load("res://Music and Sounds/New Hope.ogg")
var game_music = load("res://Music and Sounds/Common Fight.ogg")
var victory_music = load("res://Music and Sounds/Chiptronical.ogg")

func play_menu_music():
	if $Music.stream != menu_music:
		$Music.stream = menu_music
		$Music.play()
	
func play_game_music():
	if $Music.stream != game_music:
		$Music.stream = game_music
		$Music.play()

func play_victory_music():
	if $Music.stream != victory_music:
		$Music.stream = victory_music
		$Music.play()
