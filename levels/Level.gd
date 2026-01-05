extends Node

@export var create = true

var credits_y_offset = 1740

const Player = preload("res://player/Player.tscn")

func _ready():
	GameState.load_gameState()
	var spawnPosition
	if $Players/Spawn:
		GameState.transportPosition = $Players/Spawn.position
	if GameState.transportPosition == null:
		spawnPosition = GameState.checkpointPosition
	else:
		spawnPosition = GameState.transportPosition
	if create:
		create_player(spawnPosition)
	God.camera = $PlayerCamera

func _process(_delta):
	for npc in $Props/npcs.get_children():
		if Dialogic.VAR.get(npc.progress_disable):
			npc.visible = true
			npc.process_mode = Node.PROCESS_MODE_INHERIT
	if Dialogic.VAR.bunnyOpen and MusicController.current_track_index == 0:
		MusicController.play_game_music()
	if Dialogic.VAR.foxOpen and MusicController.current_track_index == 1:
		MusicController.add_new_track()
	if Dialogic.VAR.mouseOpen and MusicController.current_track_index == 2:
		MusicController.add_new_track()
	if Dialogic.VAR.squirrelOpen and MusicController.current_track_index == 3:
		MusicController.add_new_track()
	if Dialogic.VAR.skunkOpen and MusicController.current_track_index == 4:
		MusicController.add_new_track()
	if Dialogic.VAR.gameEnd and MusicController.current_track_index == 5:
		MusicController.add_new_track()
	
	$CanvasLayer/Credits.position = Vector2(0, credits_y_offset)
	if Dialogic.VAR.gameEnd:
		credits_y_offset -= 1.5
		if credits_y_offset < -1000:
			$CanvasLayer/Sprite2D.visible = true
			$CanvasLayer/Exit.visible = true
			if Input.is_action_just_pressed("pause"):
				get_tree().quit()


func create_player(vec):
	var player = Player.instantiate()
	God.player = player
	player.position = vec
	$Players.add_child(player)
