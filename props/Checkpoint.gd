extends Area2D

func _on_Checkpoint_body_entered(body):
	print("fasdf")
	GameState.checkpointPosition = position
	GameState.save_gameState()
