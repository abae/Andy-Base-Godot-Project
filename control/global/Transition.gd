extends CanvasLayer

signal scene_changed()

onready var animationPlayer = $AnimationPlayer
onready var black = $Control/ColorRect

func _ready():
	black.visible = false

func change_scene(path, delay = 0.5):
	if !black.visible:
		black.visible = true
		yield(get_tree().create_timer(delay), "timeout")
		animationPlayer.play("Out")
		yield(animationPlayer, "animation_finished")
		assert(get_tree().change_scene(path) == OK)
		animationPlayer.play("In")
		yield(animationPlayer, "animation_finished")
		emit_signal("scene_changed")
		black.visible = false
