extends Node

onready var camera = $Camera2D
onready var enemies = $Enemies
onready var player = $Players/Player
var enemy_exists = true
var player_exists = true

func camera_shake(shakeMagnitude, shakeLength):
	camera.camera_shake(shakeMagnitude, shakeLength)
