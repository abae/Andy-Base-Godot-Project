#Global singleton which holds all game important info

extends Node

@onready var playerStats = $PlayerStats

var transportPosition = null
var checkpointPosition := Vector2(0,0)
var savePath = "user://gameState.dat"

func save_gameState():
	var data = {
		"checkpointPosition" : [checkpointPosition.x, checkpointPosition.y] \
	}
	
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	if file != null:
		file.store_var(data)
		file.close()
		print("game saved!")
		return
	print("game failed to save")

func load_gameState():
	var file = FileAccess.open(savePath, FileAccess.READ)
	if file != null:
		var data = file.get_var()
		file.close()
		checkpointPosition = Vector2(data["checkpointPosition"][0], data["checkpointPosition"][1])
		print("game loaded!")
		return
	print("game failed to load")
