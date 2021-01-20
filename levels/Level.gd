extends Node

onready var camera = $Camera
onready var enemies = $Enemies
onready var player = $Players/Player
var enemy_exists = true
var player_exists = true

func _ready():
	player.connect("screen_shake", camera, "screen_shake")
	player.connect("cam_move", camera, "cam_move")
	player.connect("cam_zoom", camera, "cam_zoom")
	player.connect("cam_free", camera, "cam_free")
	camera.connect("cam2player", self, "cam2player")
	
	
func cam2player():
	camera.position = player.position
	camera.zoomTarget = 1.0
