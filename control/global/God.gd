extends Node

var player = null
var camera = null

func screen_shake(shakeMagnitude, shakeLength):
	camera.screen_shake(shakeMagnitude, shakeLength)

func cam_move(vec):
	camera.cam_move(vec)

func cam_zoom(v):
	camera.cam_zoom(v)

func cam_free(state):
	camera.cam_free(state)

func cam2player():
	camera.position = player.position
	camera.zoomTarget = 1.0
