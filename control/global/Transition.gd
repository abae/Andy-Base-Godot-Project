extends CanvasLayer

signal scene_changed()

@onready var animationPlayer = $AnimationPlayer
@onready var black = $Control/ColorRect

func _ready():
	black.visible = false

func change_scene_to_file(path, delay = 0.5):
	if !black.visible:
		black.visible = true
		await get_tree().create_timer(delay).timeout
		animationPlayer.play("Out")
		await animationPlayer.animation_finished
		assert(get_tree().change_scene_to_file(path) == OK)
		animationPlayer.play("In")
		await animationPlayer.animation_finished
		emit_signal("scene_changed")
		black.visible = false
