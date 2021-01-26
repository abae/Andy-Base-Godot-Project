extends Area2D

func _on_Checkpoint_body_entered(body):
	GameState.checkpointPosition = position
	GameState.save_gameState()
