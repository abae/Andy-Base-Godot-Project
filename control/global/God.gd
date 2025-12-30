extends Node

var player = null
var camera = null
var actualCamPos : Vector2 = Vector2.ZERO

func screen_shake(shakeMagnitude, shakeLength):
	camera.screen_shake(shakeMagnitude, shakeLength)

func cam_move(vec):
	camera.cam_move(vec)

func cam_zoom(v):
	camera.cam_zoom(v)

func cam_free(state):
	camera.cam_free(state)

func cam2player():
	if player == null or camera == null:
		return

	actualCamPos = actualCamPos.lerp(player.position-Vector2(0, 0), 0.2)
	camera.global_position = actualCamPos
	camera.zoomTarget = 1.0
