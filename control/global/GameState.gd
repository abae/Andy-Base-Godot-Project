#Global singleton which holds all game important info

extends Node

onready var playerStats = $PlayerStats

var checkpointPosition := Vector2(0,0)
var savePath = "user://gameState.dat"

func save_gameState():
	var data = {
		"checkpointPosition" : [checkpointPosition.x, checkpointPosition.y] \
	}
	
	var file = File.new()
	var err = file.open_encrypted_with_pass(savePath, File.WRITE, OS.get_unique_id())
	if err == OK:
		file.store_var(data)
		file.close()
		print("game saved!")
		return
	print("game failed to save")

func load_gameState():
	var file = File.new()
	if file.file_exists(savePath):
		var err = file.open_encrypted_with_pass(savePath, File.READ, OS.get_unique_id())
		if err == OK:
			var data = file.get_var()
			file.close()
			print(data)
			print("game loaded!")
			return
		print("game failed to load")
