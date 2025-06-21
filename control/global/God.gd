extends Node

var player = null
var camera = null
var actualCamPos : Vector2

func screen_shake(shakeMagnitude, shakeLength):
	camera.screen_shake(shakeMagnitude, shakeLength)

func cam_move(vec):
	camera.cam_move(vec)

func cam_zoom(v):
	camera.cam_zoom(v)

func cam_free(state):
	camera.cam_free(state)

func cam2player():
	actualCamPos = actualCamPos.lerp(player.position, 0.2)
	var camSubpixelOffset = actualCamPos.round() - actualCamPos
	
	camera.get_parent().get_parent().get_parent().material.set_shader_parameter("cam_offset", camSubpixelOffset)
	
	camera.position = actualCamPos.round()
	camera.zoomTarget = 1.0
