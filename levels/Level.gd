extends Node

const Player = preload("res://player/Player.tscn")

func _ready():
	GameState.load_gameState()
	var spawnPosition
	if GameState.transportPosition == null:
		spawnPosition = GameState.checkpointPosition
	else:
		spawnPosition = GameState.transportPosition
	create_player(spawnPosition)
	God.camera = $PlayerCamera
	God.camera.position = spawnPosition

func create_player(vec):
	var player = Player.instantiate()
	$Players.add_child(player)
	God.player = player
	player.position = vec
	player.get_node("Hair").init_position()
